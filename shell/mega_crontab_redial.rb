# encoding: UTF-8
#=============================================================================
# Contents   : 実行コマンドーすぐ発信
# Author     : Ascend Corp
# Since      : 2015/09/25        1.0
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
def getTimeRun(mysql_cli, schedule_id)
	arr = Array.new()
	query = <<EOS
			select 
				t21.time_start,
				t21.time_end
			from
				t21_out_times t21
			where
				t21.schedule_id = '#{schedule_id}'
					and t21.del_flag = 'N'
EOS
	mysql_cli.query(query).each do | row |
		arr = arr + Array.new(1, row)
	end
	return arr
end

def getScheduleRedial(mysql_cli, server_id, time_now)
	query = <<EOS
		select 
			t20.id,
			t20.list_id,
			t20.recall_time,
			MAX(t22.time_end),
			t20.recall_flag,
			t20.list_ng_id
		from
			t20_out_schedules t20
				inner join
			m07_server_externals m07 ON t20.external_number = m07.external_number
				and m07.del_flag = 'N'
				and m07.server_id = '#{server_id}'
				inner join
			t22_out_logs t22 ON t22.schedule_id = t20.id 
				and t22.del_flag = 'N'
		where
			t20.status in ('7')
				and t20.recall > t20.recall_flag
				and t20.del_flag = 'N'
				and t20.cron_flag = 'N'
		group by t20.id
EOS
	data=Array.new()
	mysql_cli.query(query).each do | row |
		schedule_id = row[0]
		list_id = row[1]
		if row[2].to_i == 0
			recall_time = 1
		else
			recall_time = row[2]
		end
		time_end = row[3]
		current_time =  Time.parse(time_now).to_i
		time_recall = Time.parse(time_end).to_i + recall_time.to_i*60
		arr_time_run = getTimeRun(mysql_cli, schedule_id)
		arr_time_run.each do | arr_time |
			if current_time == time_recall && 
				Time.parse(arr_time[0]).to_i < time_recall && 
				time_recall < Time.parse(arr_time[1]).to_i
				data = data + Array.new(1, row)
			end
		end
	end
	return data
end

def update_status_schedule(mysql_cli, schedule_id, status, time_now)
	query = <<EOS
		UPDATE t20_out_schedules t20 
		SET 
			t20.status = '#{status}',
			t20.modified = '#{time_now}'
		WHERE
			t20.id = '#{schedule_id}'
EOS
	mysql_cli.query(query)
end

def update_redial_flag(mysql_cli, schedule_id, time_now)
	query = <<EOS
		UPDATE t20_out_schedules t20 
		SET 
			t20.recall_flag = t20.recall_flag + 1,
			t20.modified = '#{time_now}'
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
retried = 0
limit = 5
begin
	#exit 9
	program_name = "[クーロン実行]"
	#DB接続情報
	db_ip = config[:database_ip]
	db_id = config[:database_id]
	db_pass = config[:database_pass]
	db_schema = config[:database_schema]
	mysql_cli = Mysql.connect(db_ip, db_id, db_pass, db_schema)
	mysql_cli.charset="utf8"
	
	localPathSchedule = config[:local_schedule]
	#メール
	to = getListMail()
	from = "astar_report@ascend-corp.co.jp"
	time_now = Time.now.strftime("%Y-%m-%d %H:%M:%S")
	current_time = Time.now.strftime("%Y-%m-%d %H:%M")
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
		#スケジュールを取る
		arr_schedule_redial = getScheduleRedial(mysql_cli, server_id, current_time)
		#リダイヤル
		if arr_schedule_redial.length > 0
			arr_schedule_redial.each do | arr_schedule |
				schedule_id = arr_schedule[0]
				list_id = arr_schedule[1]
				redial_flag = arr_schedule[4]
				list_ng_id = arr_schedule[5]
				schedule_no = "000000".slice(1..6-schedule_id.to_s.length) + schedule_id.to_s
				localPathScheduleId = config[:local_schedule] + schedule_no
				#dial再作成
				localPathIndata = localPathScheduleId + '/indata/'
				localPathDial = localPathIndata + 'dial/'
				fileDial = '1_dial.txt'
				fileLoadData = 'load_redial.txt'
				system("mv " + localPathDial + fileDial + " " + localPathDial + '1_dial_backup.txt')
				createBlankCSV(localPathDial, fileDial)
				createBlankCSV(localPathDial, fileLoadData)
				system("chmod 777 " + localPathDial + fileDial)
				create_file_config_path = config[:local_path] + "/create_file_config.rb"
				system("/usr/local/bin/ruby " + create_file_config_path + " " + schedule_no + " " + schedule_id)
				csvFile = File.open(localPathDial + fileDial, 'a:UTF-8')
				num_item = getNumAuthItemByScheduleId(mysql_cli, schedule_id)
				str_item = getAllColumn(mysql_cli, schedule_id, list_id, 't11')
				tel_item = getColumnByItemCode(mysql_cli, "tel_no", list_id)
				sms_items = getSmsItemName(mysql_cli, schedule_id)
				sms_arr_item = Array.new()
				sms_num_item = 0
				sms_items.each do | row |
					column = getColumnByItemName(mysql_cli, row, list_id)
					sms_arr_item.push(column)
					sms_num_item += 1
				end
				query_sms_item = ""
				sms_arr_item.each do | item |
					query_sms_item += ",t11.#{item}"
				end
				if list_ng_id.blank?
					query_list_ng = ""
				else
					date_run = Time.now.strftime("%Y-%m-%d")
					query_list_ng = "and t11.#{tel_item} not in (SELECT 
																	tel_no
																FROM
																	t15_outgoing_ng_tels t15
																WHERE
																	t15.list_ng_id = '#{list_ng_id}'
																	and t15.del_flag = 'N'
																)
									"
				end
				#接続以外取る
				queryGetDial = <<EOS
							SELECT
								'1',
								t20.call_type,
								m07.external_prefix,
								#{str_item}
								#{query_sms_item}
							FROM
								t11_tel_lists t11 
									inner join 
								t20_out_schedules t20 on t20.list_id = t11.list_id 
									and t20.id = '#{schedule_id}'
									inner join
								m07_server_externals m07 on t20.external_number = m07.external_number
									and m07.del_flag = 'N'
									inner join
								m01_servers m01 on m01.server_id = m07.server_id
									and m01.server_type = '1'
									and m01.del_flag = 'N'
							WHERE
								t11.list_id = '#{list_id}' 
								and t11.#{tel_item} not in (SELECT 
																t80.tel_no
															FROM
																t80_outgoing_results t80
															WHERE
																t80.schedule_id = '#{schedule_id}'
																and t80.status not in ('timeout', 'reject')
														   ) 
								and t11.muko_flag = 'N'
								and t11.del_flag = 'N'
								#{query_list_ng}
							ORDER BY RAND()
EOS
				mysql_cli.query(queryGetDial).each do | row_dial |
					# num_item=ユニークな認証項目の数。
					#    例：電話番号、生年月日=2  電話番号、電話番号=1
					# sms_num_item=ユニークなSMS挿入項目の数。
					#    例：電話番号、生年月日=2  電話番号、電話番号=1
					tmp = num_item + sms_num_item + 3
					str = ""
					#ダイアルリストはまずグループ番号が先頭に入る。半角スペースを開けて、下記を登録していく。
					#<prefix付き電話番号>,<認証項目1>,<認証項目2>・・・・,<SMS挿入項目1>,<SMS挿入項目2>・・・・
					# （例）認証項目やSMS挿入項目がない場合→1 00190209097859705,
					for i in 3..tmp
						## 電話番号
						if i == 3
							# t20.call_type = row_dial[1] = <通知(0)・非通知(1)>
							if row_dial[1] == "1"
								# 184を電話番号に付与して非通知とする。
								str = row_dial[2].to_s + "184" + row_dial[i].to_s
							else
								str = row_dial[2].to_s + row_dial[i].to_s
							end
						## 認証項目
						elsif i <= num_item + 3
							str = str + "," + row_dial[i].to_s.gsub(/[^\d]/, '')
						## SMS挿入項目
						else
							str = str + "," + row_dial[i].to_s.gsub(/ /, '')
						end
					end
					# row_dial[0]＝グループ番号。
					csvFile.puts(NKF::nkf('-Wsm0', row_dial[0].to_s + " " + str))
				end
				csvFile.close
				#ファイル転送
				localPathScheduleId = config[:local_schedule] + schedule_no			
				remotePathScheduleId = config[:remote_path] + schedule_no
				remotePathBackup = config[:remote_path] + schedule_no + "_redial_backup"
				Net::SSH.start( server_ip, server_user, options) do |ssh|
					ssh.exec!("cp -R " + remotePathScheduleId + " " + remotePathBackup)
					writeLog(program_name + schedule_no + "フォルダバックアップ ： OK")
					begin
						writeLog(program_name + schedule_no + "フォルダ転送 ： START")
						ssh.sftp.connect do |sftp|
							sftp.upload!(localPathScheduleId + "/indata/dial/" + fileDial, remotePathScheduleId + "/indata/dial/" + fileDial)
							sftp.upload!(localPathScheduleId + "/autopoll.conf", remotePathScheduleId + "/autopoll.conf")
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
					end
				end
				#コマンド実行
				command(server_ip, schedule_no, "addschedule", "/home/robo/var/"+schedule_no+"/autopoll.conf")
				writeLog(program_name + schedule_no + " スケジュール割り当て　：　OK")
				command(server_ip, schedule_no, "checkdata", "")
				writeLog(program_name + schedule_no + " データチェック　：　OK")
				command(server_ip, schedule_no, "autocall", "run")
				writeLog(program_name + schedule_no + " コール開始　：　OK")
				insert_run_log(mysql_cli, schedule_id)
				writeLog(schedule_no + " 実行ログ追加　：　OK")
				update_status_schedule(mysql_cli, schedule_id, "1", time_now)
				writeLog(program_name + schedule_no + " 実行中ステータス更新　：　OK")		
				update_redial_flag(mysql_cli, schedule_id, time_now)	
				writeLog(program_name + schedule_no + " リダイヤルフラグ更新　：　OK")

				redial_num = redial_flag.to_i + 1
				queryInsertT52 = <<EOS
					insert into t52_tel_redials(schedule_id, redial_flag, customize1, customize2, customize3, customize4,
					 customize5, customize6, customize7, customize8, customize9, customize10, customize11)
					select 
						t20.id,
						#{redial_num},
						t11.customize1,
						t11.customize2,
						t11.customize3,
						t11.customize4,
						t11.customize5,
						t11.customize6,
						t11.customize7,
						t11.customize8,
						t11.customize9,
						t11.customize10,
						t11.customize11
					from t20_out_schedules t20 inner join t11_tel_lists t11 on t20.list_id = t11.list_id and t11.del_flag = "N"
					where 
						t20.id = '#{schedule_id}'
						and t11.#{tel_item} not in (SELECT 
														t80.tel_no
													FROM
														t80_outgoing_results t80
													WHERE
														t80.schedule_id = '#{schedule_id}'
														and t80.status not in ('timeout', 'reject')
												   ) 
						#{query_list_ng}
						and t11.muko_flag = 'N'
						and t11.del_flag = 'N';
EOS
				mysql_cli.query(queryInsertT52)
				writeLog("T52にリダイアル電話番号を追加　：　OK")


			end	
		end
	end
	mysql_cli.close()
rescue Net::SMTPAuthenticationError, Net::SMTPServerBusy, Net::SMTPSyntaxError, Net::SMTPFatalError, Net::SMTPUnknownError => e
	writeLog("[SendMailError]メール通知エラー")
	exit 0
rescue Timeout::Error =>e
	if retried < limit
		retried+=1
		sleep(1)
		retry
	else
		puts "err_mega_crontab_redial"
		writeLog(program_name + "err_mega_crontab_redial : " + e.message)
		writeLog(program_name + "コールクライアントでのコマンド呼び出しエラーが発生")
		writeLog(e.backtrace.join("\n"))
		sendMailError("")
	end
	exit 9
rescue Exception, StandardError =>e
	puts "err_mega_crontab_redial"
	writeLog(program_name + "err_mega_crontab_redial : " + e.message)
	writeLog(e.backtrace.join("\n"))
	sendMailError("")
	exit 9
end