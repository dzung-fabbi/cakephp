# encoding: UTF-8
#=============================================================================
# Contents   : 設定フォルダ転送
# Author     : Ascend Corp
# Since      : 2015/09/07        1.0
#=============================================================================
load File.join(File.dirname(__FILE__),'common.rb')
load File.join(File.dirname(__FILE__),'config.rb')

instance =  AscConfig.new
instance.instance_eval File.read File.join(File.dirname(__FILE__),'config.ini')
config = instance.getData

def getExternalPrefix(mysql_cli, schedule_id)
	external_prefix = ""
	query = <<EOS
		select 
			m07.external_prefix
		from
			t20_out_schedules t20 
				inner join
			m07_server_externals m07 on t20.external_number = m07.external_number
				and m07.del_flag = 'N'
		where
			t20.id = #{schedule_id} 
			and t20.del_flag = "N"
EOS
	mysql_cli.query(query).each do | row |
		external_prefix = row[0]
	end
	return external_prefix
end

############################################
#
# バッチのメイン処理
#
############################################
retried = 0
limit = 5
begin
	program_name = "[発信リスト編集転送]"
	server_id = ARGV[0]
	schedule_no = ARGV[1]
	schedule_id = ARGV[2]
	template_id = ARGV[3]
	list_id = ARGV[4]
	tel_no = ARGV[5]
	#DB接続情報
	db_ip = config[:database_ip]
	db_id = config[:database_id]
	db_pass = config[:database_pass]
	db_schema = config[:database_schema]
	mysql_cli=Mysql.connect(db_ip, db_id, db_pass, db_schema)
	mysql_cli.charset="utf8"
	localPathSchedule = config[:local_schedule]
	remotePath = config[:remote_path]
	localPathScheduleId = config[:local_schedule] + schedule_no
	localPathIndata = localPathScheduleId + '/indata/'
	localPathPcmVar = localPathIndata + 'pcm_var/'	
	remotePathScheduleId = config[:remote_path] + schedule_no
	remotePathIndata = remotePathScheduleId + '/indata/'
	remotePathPcmVar = remotePathIndata + 'pcm_var/'	
	remotePathBackup = config[:remote_path] + schedule_no + "_edit_calllist_backup"
	
	external_prefix = getExternalPrefix(mysql_cli, schedule_no.to_i)
	pcm_filename = external_prefix.to_s + tel_no.to_s + ".pcm"
	arr_item = Array.new()
	arr_item_code = Array.new()
	unless tel_no.blank?
		#質問情報を取る
		queryGetQues = queryGetQues(template_id)
		mysql_cli.query(queryGetQues).each do | row |
			question_type = row[1]
			audio_type = row[3]
			audio_content = row[4]
			recheck_flag = row[8]
			recheck_audio_type = row[10]
			recheck_audio_content = row[11]
			if (audio_type == "1" || audio_type == "2")
				arr_item = audio_content.scan(/{(.*?)}/u)
				arr_item_type = audio_type
			end
			#数値認証・番号入力・文字列認証
			if (question_type.to_s == "3" || question_type.to_s == "4" || question_type.to_s == "10") && recheck_flag.to_s == "1" && (recheck_audio_type.to_s == "1" || recheck_audio_type.to_s == "2")
				arr_item_recheck = recheck_audio_content.scan(/{(.*?)}/u)
				arr_item_recheck.each do | row |
					unless arr_item.include? row
						arr_item.push(row)
						arr_item_type = recheck_audio_type.to_s
					end
				end
			end
			arr_item.each do | row |
				item_column = getColumnByItemName(mysql_cli, row[0], list_id)
				arr_item_code.push(item_column)
				tel_column = getColumnByItemCode(mysql_cli, "tel_no", list_id)
				path = localPathPcmVar + item_column.to_s + "/"
				query = <<EOS
					SELECT
						#{item_column}
					FROM
						t11_tel_lists t11 
					WHERE
						t11.list_id = '#{list_id}' and
						t11.#{tel_column} = '#{tel_no}' and
						t11.del_flag = 'N'
EOS
				mysql_cli.query(query).each do | arr |
					item_txt = arr[0]
					processGetFilePcmMix(mysql_cli, item_txt, path, pcm_filename, arr_item_type, "read_list")
				end
			end
		end
	end
	
	query = <<EOS
		select 
			server_ip,
			username,
			password,
			server_port
		from
			m01_servers
		where
			server_id = '#{server_id}' and
			del_flag = 'N';
EOS
	mysql_cli.query(query).each do | row |
		server_ip = row[0]
		server_user = row[1]
		server_pass = row[2]
		server_port = row[3]
		options = {}
		options[:password] = server_pass
		unless server_port.blank?
			options[:port] = server_port
		end
		Net::SSH.start( server_ip, server_user, options) do |ssh|
			ssh.exec!("cp -R " + remotePathScheduleId + " " + remotePathBackup)
			writeLog(program_name + schedule_no + "フォルダバックアップ ： OK")
			begin
				writeLog(program_name + schedule_no + "フォルダ転送 ： START")
				ssh.sftp.connect do |sftp|
					sftp.upload!(localPathScheduleId + "/indata/dial", remotePathScheduleId + "/indata/dial")
					unless tel_no.blank?
						arr_item_code.each do | item |
							sftp.upload!(localPathPcmVar + item + "/" + pcm_filename, remotePathPcmVar + item + "/" + pcm_filename)
						end
					end
				end
				writeLog(program_name + schedule_no + "フォルダ転送 ： END")
				ssh.exec!("rm -rf " + remotePathBackup)
				writeLog(program_name + "フォルダバックアップを削除 : OK")
			rescue Exception, Timeout::Error, StandardError =>e
				writeLog(program_name + "サーバにフォルダ転送のエラーを発生")
				ssh.exec!("rm -rf " + remotePathScheduleId)
				writeLog(program_name + schedule_no + "エラーフォルダ削除 ： OK")
				ssh.exec!("mv " + remotePathBackup + " " + remotePathScheduleId)
				writeLog(program_name + schedule_no + "ロールバックフォルダ ： OK")
				writeLog(e.backtrace.join("\n"))
			end
		end
	end
rescue Timeout::Error =>e
	if retried < limit
		puts "retry : " + retried.to_s
		retried+=1
		sleep(5)
		retry
	else
		puts "err_send_folder_edit_calllist"
		writeLog(program_name + "err_send_folder_edit_calllist : " + e.message)
		writeLog(program_name + "発信リスト編集転送のエラーを発生")
		writeLog(e.backtrace.join("\n"))
		sendMailError(schedule_no.to_i)
	end
	exit 9
rescue Exception, StandardError =>e
	puts "err_send_folder_edit_calllist"
	writeLog(program_name + "err_send_folder_edit_calllist : " + e.message)
	writeLog(program_name + "発信リスト編集転送のエラーを発生")
	writeLog(e.backtrace.join("\n"))
	sendMailError(schedule_no.to_i)
	exit 9
end