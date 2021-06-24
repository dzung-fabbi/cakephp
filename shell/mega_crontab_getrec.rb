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

############################################
#
# スケジュールを取得
#
############################################
def queryGetSchedule(server_id)
	date_time = Time.at(Time.now.to_i - 86400).strftime("%Y-%m-%d")
	query = <<EOS
		select 
			t20.id,
			t20.call_type		
		from
			t20_out_schedules t20
				inner join
			m07_server_externals m07 ON t20.external_number = m07.external_number
				and m07.del_flag = 'N'
				and m07.server_id = '#{server_id}'
				inner join
			t21_out_times t21 on t20.id = t21.schedule_id
				and t21.time_end like '#{date_time}%'
				and t21.del_flag = 'N'
				inner join 
			t31_template_questions t31 on t20.template_id = t31.template_id
				and t31.question_type = '6'
				and t31.del_flag = 'N'
		where
			t20.status in ('2', '3', '4')
				and t20.del_flag = 'N'
				and t20.cron_record_flag = 'Y'
		group by t20.id
		order by t21.time_end desc
				
EOS
	return query
end

############################################
#
# DBの録音フラグを更新
#
############################################
def updateRecordFlag(mysql_cli, schedule_id)
	query = <<EOS
		UPDATE t20_out_schedules t20 
		SET 
			t20.cron_record_flag = 'N'
		WHERE
			t20.id = '#{schedule_id}'
EOS
	mysql_cli.query(query)
end


############################################
#
# バッチのメイン処理
#
############################################
begin
	#メール
	#DB接続情報
	program_name = "[録音ファイル取得]"
	db_ip = config[:database_ip]
	db_id = config[:database_id]
	db_pass = config[:database_pass]
	db_schema = config[:database_schema]
	mysql_cli = Mysql.connect(db_ip, db_id, db_pass, db_schema)
	mysql_cli.charset = "utf8"
	#ローカルパス
	localSchedule = config[:local_schedule]
	remotePath = config[:remote_path]
	
	#ログファイルを取る
	query = <<EOS
		select 
			server_ip,
			username,
			password,
			server_port,
			server_id
		from
			m01_servers
		where
			server_type = '1' and
			del_flag = 'N';
EOS
	mysql_cli.query(query).each do | row |
		server_ip = row[0]
		server_user = row[1]
		server_pass = row[2]
		server_port = row[3]
		server_id = row[4]
		options = {}
		options[:password] = server_pass
		unless server_port.blank?
			options[:port] = server_port
		end
		queryGetSchedule = queryGetSchedule(server_id)
		mysql_cli.query(queryGetSchedule).each do | arr |
			#情報を取る
			schedule_id = arr[0]
			call_type = arr[1]
			schedule_no = "000000".slice(1..6-schedule_id.to_s.length) + schedule_id.to_s
			localPathSchedule = localSchedule + schedule_no
			remotePathSchedule = remotePath + schedule_no
			exist_rec = false
			#録音ファイルを取る
			Net::SSH.start( server_ip, server_user, options) do |ssh|
				exist_string = "exist"
				# 今回の発信設定で、録音セクションを1度も通過しない場合は、エrecフォルダが作られないため、フォルダの取得を行わない。
				# 階層がない場合は、nilが戻る。
				if ssh.exec!("if [ -d " + remotePathSchedule + "/rec" + " ]; then echo '" + exist_string + "' ; fi")
					ssh.exec!("cd " + remotePathSchedule + "&& tar cfvz rec.tar rec")
					exist_rec = true
				end
			end
			#音声展開・変換
			begin
				if exist_rec
					remoteFolderRecTar = remotePathSchedule + "/rec.tar"
					if server_port.blank?
						system("scp -r " + server_ip + ":"+ remoteFolderRecTar + " " + localPathSchedule)
					else
						system("scp -r -P " + server_port + " " + server_ip + ":" + remoteFolderRecTar + " " + localPathSchedule)
					end
					system("tar xfvz " + localPathSchedule + "/rec.tar -C " + localPathSchedule)
					system("rm -rf " + localPathSchedule + "/rec.tar")
					localPathFileRec = localPathSchedule + "/rec"
					Dir.entries(localPathFileRec).each do | e |
						if e != "." && e != ".."
							localFileRecPcm = localPathFileRec + "/" + e
							filename = File.basename(e, ".*")
							if call_type.to_s == "1"
								filename = filename.slice(9..filename.length)
							elsif call_type.to_s == "0"
								filename = filename.slice(6..filename.length)
							end
							localFileRecWav = localPathFileRec + "/" + filename + ".wav"
							system("ffmpeg -f s16le -ar 8000 -ac 1 -i " + localFileRecPcm + " -ar 8000 -ac 1 " + localFileRecWav)
							FileUtils.rm_rf(localFileRecPcm)
						end
					end
					writeLog(program_name + schedule_no + " 録音音声展開・変換	：　OK")
				else
					writeLog(program_name + schedule_no + " 録音音声展開・変換・rec階層がないためスキップ	：　OK")
				end
				updateRecordFlag(mysql_cli, schedule_id)
				writeLog(program_name + schedule_no + " 録音フラグ更新	：　OK")
			rescue Exception => e
				writeLog(program_name + "録音音声展開・変換エラー - " + e.message)
				writeLog(e.backtrace.join("\n"))
				sendMailError("")
			end
		end		
	end
	mysql_cli.close()
rescue Timeout::Error =>e
	if retried < limit
		puts retried
		retried+=1
		sleep(5)
		retry
	else
		puts "err_connect_getrec"
		writeLog(program_name + "err_connect_getrec : " + e.message)
		writeLog(program_name + "コールクライアントでのコマンド呼び出しエラーが発生")
		writeLog(e.backtrace.join("\n"))
		sendMailError("")
	end
	exit 9
rescue Exception => e
	puts "err_connect_getrec"
	writeLog(program_name + "エラー：録音ファイル取得バッチ実行：失敗 - " + e.message)
	writeLog(e.backtrace.join("\n"))
	sendMailError("")
	exit 9
end