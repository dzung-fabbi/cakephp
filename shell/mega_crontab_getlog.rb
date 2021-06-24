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
# DBのT20で処理件数を更新
#
############################################
def updateScheduleCalledNum(mysql_cli, schedule_id)
	query = <<EOS
		UPDATE t20_out_schedules t20 
		SET 
			t20.called_total = (select 
					count(*)
				from
					t80_outgoing_results
				where
					schedule_id = '#{schedule_id}')
		WHERE
			t20.id = '#{schedule_id}'
EOS
	mysql_cli.query(query)
end
############################################
#
# スケジュールを取得
#
############################################
def queryGetSchedule(server_id)
	query = <<EOS
		select 
			t20.id,
			t20.status,
			t20.call_type,
			t20.list_id,
			t20.term_valid_count,
			t20.recall,
			t20.recall_flag,
			t20.term_connect_count,
			t20.recall_time,
			t20.modified,
			t20.update_program,
			t20.update_user
		from
			t20_out_schedules t20
				inner join
			m07_server_externals m07 ON t20.external_number = m07.external_number
				and m07.del_flag = 'N'
				and m07.server_id = '#{server_id}'
		where
			t20.status in ('1' , '5', '6')
				and t20.del_flag = 'N'
EOS
	return query
end
############################################
#
# リダイヤル待ち判断
#
############################################
def checkWaitRedial(mysql_cli, schedule_id, time_redial_start)
	arrScheduleTime = getScheduleTimeByScheduleId(mysql_cli, schedule_id)
	flagRedial = false
	arrScheduleTime.each do | row |
		time_start = Time.parse(row[0]).to_i
		time_end = Time.parse(row[1]).to_i
		if time_start <= time_redial_start && time_redial_start < time_end
			flagRedial = true
		end
	end
	return flagRedial
end
############################################
#
# ステータス更新
#
############################################
def updateStatusSchedule(mysql_cli, schedule_id, status, recall, recall_flag, yuko_finish_flag, server_ip, recall_time)
	time_start = ""
	time_end = ""
	time_now = Time.now.to_i
	#停止中場合
	if status == "5"
		#一時停止
		status_update = "2"
		subject = "【はやぶさ】発信手動停止"
	#実行中
	elsif status == "1"
		if recall.to_i > recall_flag.to_i && !yuko_finish_flag
      #自動停止有効回答数が達成されない場合
			status_update = "7"
			subject = "【はやぶさ】発信リダイヤル待ち"
			#時間帯チェック
			time_redial_start = time_now + recall_time.to_i*60
			flagRedial = checkWaitRedial(mysql_cli, schedule_id, time_redial_start)
			if !flagRedial
				status_update = "4"
				subject = "【はやぶさ】発信終了"
			else
				#全てconnectチェック
				num_connect = 0
				query = <<EOS
					SELECT 
						count(*)
					FROM
						t80_outgoing_results t80
					WHERE
						t80.schedule_id = '#{schedule_id}'
						and t80.status not in ('timeout', 'reject')
EOS
				mysql_cli.query(query).each do | row |
					num_connect = row[0]
				end
				num_list = 0
				query = <<EOS
					SELECT 
						count(*)
					FROM
						t11_tel_lists t11 inner join t20_out_schedules t20 on t11.list_id = t20.list_id
					WHERE
						t20.id = '#{schedule_id}'
						and t11.del_flag = 'N'
						and t11.muko_flag = 'N'
EOS
				mysql_cli.query(query).each do | row |
					num_list = row[0]
				end
				if num_connect.to_i > num_list.to_i || num_connect.to_i == num_list.to_i
					status_update = "4"
					subject = "【はやぶさ】発信終了"
				end
			end
		else
			status_update = "4"
			subject = "【はやぶさ】発信終了"
		end
	#終了中場合
	elsif status == "6"
		finish_flag = false
		queryGetTimeEnd = <<EOS
			select 
				t21.time_start,
				t21.time_end
			from 
				t21_out_times t21
			where
				t21.schedule_id = '#{schedule_id}'
				and t21.del_flag = 'N'
			order by time_end desc
EOS
		i = 1
		mysql_cli.query(queryGetTimeEnd).each do | row |
			time_start = row[0]
			time_end = row[1]
			time_start = Time.parse(time_start).to_i
			time_end = Time.parse(time_end).to_i
			if(time_start < time_now && time_now <= time_end)
				#終了
				finish_flag = true
			end
			if i == 1 && time_now > time_end
				#終了
				finish_flag = true
			end
			i = 2
		end
		if finish_flag == true 
			if recall.to_i > recall_flag.to_i && !yuko_finish_flag
				#時間帯チェック
				time_redial_start = time_now + recall_time.to_i*60
				flagRedial = checkWaitRedial(mysql_cli, schedule_id, time_redial_start)
				if flagRedial
					status_update = "7"
					subject = "【はやぶさ】発信リダイヤル待ち"
				else
					status_update = "4"
					subject = "【はやぶさ】発信終了"
				end
			else
				status_update = "4"
				subject = "【はやぶさ】発信終了"
			end
		else
			status_update = '3'
			subject = "【はやぶさ】発信自動停止"
		end
	end

	query = <<EOS
		UPDATE t20_out_schedules t20 
		SET 
			t20.status = '#{status_update}'
		WHERE
			t20.id = '#{schedule_id}'
EOS
	mysql_cli.query(query)

end

############################################
#
# 実行ログ追加
#
############################################
def update_run_log(mysql_cli, schedule_id)
	time_now = Time.now.strftime("%Y-%m-%d %H:%M")
	queryGetIdUpdate = <<EOS 
						select id
						from t22_out_logs
						where schedule_id = '#{schedule_id}'
						order by id desc
						limit 1
EOS
	mysql_cli.query(queryGetIdUpdate).each do | row |
		id = row[0]
		query = <<EOS
		UPDATE t22_out_logs t22 
		SET 
			t22.time_end = '#{time_now}'
		WHERE
			t22.id = '#{id}'
EOS
		mysql_cli.query(query)
	end
end
#=============================================================================
#　SMS送信ステータステーブルにインサート
# param : schedule_id
# param : template_id
# param : question_no
# param : answer_pos
# return : array
#=============================================================================
def insertSmsInfoFromLog(mysql_cli, schedule_id, company_id, sms_display_number, template_id, question_no, answer_pos)
	sms_answer_pos = "answer" + answer_pos.to_s
	query = <<EOS
	insert into t83_outgoing_sms_statuses (log_id, schedule_id, company_id, display_number, template_id, tel_no, sms_question_no, sms_entry_id, sms_status, created)
	select 
		t80.id,
		t80.schedule_id,
		'#{company_id}',
		'#{sms_display_number}',
		'#{template_id}',
		t80.tel_no,
		'#{question_no}',
		t80.#{sms_answer_pos},
		IF(t80.#{sms_answer_pos} IS NULL, 'no_send', if(t80.#{sms_answer_pos} = '', 'no_send', if(t80.#{sms_answer_pos} = '0','fail','sending'))),
		now()
	from
		t80_outgoing_results t80
	left join
		t83_outgoing_sms_statuses t83
	on
		t80.id = t83.log_id and
		t80.schedule_id = t83.schedule_id and
		t83.sms_question_no = '#{question_no}' and
		t83.del_flag = 'N'
	where
		t80.schedule_id = '#{schedule_id}' and		
		t83.sms_question_no is null and
		(t80.#{sms_answer_pos} <> '' or t80.#{sms_answer_pos} is not null)
EOS
	mysql_cli.query(query)
end

###########################################
#
# スケジュールの停止実行
#
###########################################
def stopSchedule(server_ip, schedule_id, program_name, schedule_no)
	command(server_ip, schedule_no, "autocall", "term")
	writeLog(program_name + schedule_no + " autocall停止 ：　OK")
	command(server_ip, schedule_no, "killall", "")
	writeLog(program_name + schedule_no + " killall ：　OK")
	command(server_ip, schedule_no, "delschedule", "")
	writeLog(program_name + schedule_no + " ascallcliスケジュール解放　：　OK")
end

###########################################
# 発信ログファイル取得
# @param : schedule_id
#
###########################################
def insertSmsInfo(mysql_cli, schedule_id)
	template_id = '0'
	company_id = '0'
	question_no = '0'
	answer_pos = '0'
	quesSmsCode = '13'
	quesSmsInputCode = '19'
    schedules = getScheduleById(mysql_cli, schedule_id)
    schedules.each do | row |
    	template_id = row[2]
    	company_id = row[1]
    end
    if(template_id != '0')
    	if hasSmsQues(mysql_cli, template_id)
    		arr_answer_pos = getAnswerPos(mysql_cli, schedule_id)
    		questions = getQuesByScheduleId(mysql_cli, schedule_id)
    		questions.each do | row |
				question_no = row[1]
				question_type = row[2]
				if(question_type == quesSmsCode || question_type == quesSmsInputCode)
					sms_display_number = row[7]
					#「SMS」(13)「番号指定SMS送信」(19)ごとに、sms_entry_idの位置を指定
					if(question_type == quesSmsInputCode)
						answer_pos = arr_answer_pos[question_no] + 2
					else
						answer_pos = arr_answer_pos[question_no]
					end
					insertSmsInfoFromLog(mysql_cli, schedule_id, company_id, sms_display_number, template_id, question_no, answer_pos)
				end
			end
    	end
    end
rescue Exception => e
	puts "error"
	writeLog("insertSmsInfo")
	writeLog(e.backtrace.join("\n"))
	#exit 9
end
############################################
#
# バッチのメイン処理
#
############################################
begin
	#メール
	#DB接続情報
	program_name = "[ログ取得]"
	db_ip = config[:database_ip]
	db_id = config[:database_id]
	db_pass = config[:database_pass]
	db_schema = config[:database_schema]
	server_name = config[:aserver_name]
	mysql_cli = Mysql.connect(db_ip, db_id, db_pass, db_schema)
	mysql_cli.charset = "utf8"
	#ローカルパス
	localSchedule = config[:local_schedule]
	remotePath = config[:remote_path]
	time_update = Time.now.strftime("%Y-%m-%d %H:%M:%S")
	
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
			status = arr[1]
			call_type = arr[2]
			list_id = arr[3]
			term_valid_count = arr[4]
			recall = arr[5]
			recall_flag = arr[6]
			term_connect_count = arr[7]
			recall_time = arr[8]
			modified = arr[9]
			update_program = arr[10]
			update_user = arr[11]
			schedule_no = "000000".slice(1..6-schedule_id.to_s.length) + schedule_id.to_s
			localPathSchedule = localSchedule + schedule_no
			remotePathSchedule = remotePath + schedule_no
			remoteFolderCsv = remotePathSchedule + "/csv/"
			localPathFileCsv = localPathSchedule + "/csv/"
			localFileCSV = localPathFileCsv + "all.csv"
			#ファイルをダウンロード
			if server_port.blank?
				system("scp -r " + server_ip + ":" + remoteFolderCsv + " " + localPathSchedule)
			else
				system("scp -r -P " + server_port + " " + server_ip + ":" + remoteFolderCsv + " " + localPathSchedule)
			end
			writeLog(program_name + schedule_no + " ファイルをダウンロード　：　OK")
			#ロードデータ	
			system("cat " + localPathFileCsv + "*.csv > " + localFileCSV)
			system("sh /home/ftpuser/robo/load_data.sh #{db_id} #{db_pass} #{db_schema} #{localFileCSV} #{schedule_id} #{call_type} #{recall_flag}")
			system("rm -rf " + localFileCSV)
			writeLog(program_name + schedule_no + " T80ロードデータ	：　OK")
			#スケジュールログを追加
			insert_log_schedule(mysql_cli, schedule_id)
			writeLog(program_name + schedule_no + " スケジュールログを追加 ：　OK")

			insertSmsInfo(mysql_cli, schedule_id)
			writeLog(program_name + schedule_no + " T83SMSログを追加	：　OK")
			#処理件数更新
			updateScheduleCalledNum(mysql_cli, schedule_id)
			writeLog(program_name + schedule_no + " T20処理件数更新 ：　OK")
			#MEGAサーバでステータスを取る
			result = commandGetStatus(server_ip, schedule_no)
			writeLog(program_name + schedule_no + " ascallcli実行状態取得　：　" + result.strip.to_s)
			#result = "RET_TERM"
			if result.strip == "RET_TERM" && !hasSmsSending(mysql_cli, schedule_id)
				command(server_ip, schedule_no, "delschedule", "")
				writeLog(program_name + schedule_no + " ascallcliスケジュール解放　：　OK")
				update_run_log(mysql_cli, schedule_id)
				writeLog(program_name + schedule_no + " T22実行ログ追加 ：　OK")
				yuko_finish_flag = false;
		        if !term_valid_count.nil? && !term_valid_count.empty?
		        	yuko_num = getYukoNum(mysql_cli, schedule_id, list_id);
		    	    if yuko_num.to_i >= term_valid_count.to_i
			        	yuko_finish_flag = true;
			        end
		        end
		        if !term_connect_count.nil? && !term_connect_count.empty?
		        	connect_num = getConnectedNum(mysql_cli, schedule_id);
		    	    if connect_num.to_i >= term_connect_count.to_i
			        	yuko_finish_flag = true;
			        end
		        end
				updateStatusSchedule(mysql_cli, schedule_id, status, recall, recall_flag, yuko_finish_flag, server_ip, recall_time)
				writeLog(program_name + schedule_no + " T20ステータス更新 ：　OK")
			end
			if result.strip != "RET_ALIVE" && result.strip != "RET_TERM"
				sendMailError(schedule_id)
			end
			#手動停止の捕捉の処理
			if status == STATUS_STOPING \
				&& (Time.parse(time_update) - Time.parse(modified)) > KILL_FAILURE_TIME \
				&& update_program == 'OutSchedule_StopSchedule'
				#停止中からステータスが変わってない場合
				begin
					process_count = 0
					Net::SSH.start(server_ip, server_user, options) do |ssh|
						process_count = ssh.exec!("ps -ef | grep apdlg | grep #{schedule_id} | wc -l")
						writeLog(program_name + schedule_no + " プロセス数 ：　" + process_count)
						if process_count.to_i > 0
							stopSchedule(server_ip, schedule_id, program_name, schedule_no)
							process_count = ssh.exec!("ps -ef | grep apdlg | grep #{schedule_id} | wc -l")
							writeLog(program_name + schedule_no + " プロセス数 ：　" + process_count)
							sendMailInfo(schedule_id, "停止コマンドが実行されました。")
						end
					end
					#プロセスが「停止」になったら、ステータス「２（手動停止）」に更新する
					query = <<-EOS
						UPDATE t20_out_schedules t20
						SET
							t20.status = '#{STATUS_STOP_CALL}',
							t20.modified = '#{time_update}',
							t20.update_user = 'exec_cron',
							t20.update_program = 'mega_crontab_getlog'
						WHERE
							t20.id = '#{schedule_id}'
					EOS
					mysql_cli.query(query)
					writeLog(program_name + schedule_no + " T20ステータス変更 ：　OK")
				rescue Exception => e
					writeLog(program_name + schedule_no + " スケジュールの実行停止 ：　FAIL")
					writeLog("停止のコマンドのエラー ：　" + e.message)
					sendMailError(schedule_id)
				end
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
		puts "err_connect_getlog_1min"
		writeLog(program_name + "err_connect_getlog_1min : " + e.message)
		writeLog(program_name + "コールクライアントでのコマンド呼び出しエラーが発生")
		writeLog(e.backtrace.join("\n"))
		sendMailError("")
	end
	exit 9
rescue Exception => e
	puts "err_getlog_1min"
	writeLog(program_name + "エラー：1分毎バッチ実行：失敗 - " + e.message)
	writeLog(e.backtrace.join("\n"))
	sendMailError("")
	exit 9
end
