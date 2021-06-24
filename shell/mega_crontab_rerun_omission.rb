# encoding: UTF-8
#=============================================================================
# Contents   : スケジュール登録中に発信時間を過ぎてしまったスケジュールを
#              捕捉して発信処理を実行する
#              停止処理は既存処理に委譲する
# Author     : Ascend Corp
# Since      : 2020/09/10        1.0
#=============================================================================
load File.join(File.dirname(__FILE__), "common.rb")
load File.join(File.dirname(__FILE__), "config.rb")

instance =  AscConfig.new
instance.instance_eval File.read File.join(File.dirname(__FILE__), "config.ini")
config = instance.getData

# コールサーバ情報取得クエリを作成する
# @return [String] クエリ文字列
def create_query_get_server_info
	return <<-EOS
		select
			server_ip,
			username,
			password,
			server_port,
			server_id
		from
			m01_servers
		where
			server_type = '1'
			and del_flag = 'N';
	EOS
end

# 捕捉対象スケジュール情報を取得する
# @return [Array] スケジュールリスト
def getInfoSchedule(mysql_cli, server_id, start_from, start_to)
	query = <<-EOS
		select
			t20.id,
			t20.list_id,
			t20.recall_flag,
			t20.list_ng_id
		from
			t20_out_schedules t20
			inner join m07_server_externals m07
				on t20.external_number = m07.external_number
				and m07.del_flag = 'N'
				and m07.server_id = '#{server_id}'
			inner join
			(
				select
					t21.schedule_id,
					t21.time_start,
					t21.time_end
				from
					t21_out_times t21
					inner join
					(
						select
							schedule_id,
							max(time_start) as time_start
						from
							t21_out_times
						where
							del_flag = 'N'
						group by
							schedule_id
					) t21_max
					on t21.schedule_id = t21_max.schedule_id
					and t21.time_start = t21_max.time_start
			) t21
				on t21.schedule_id = t20.id
				and t21.time_start between '#{start_from}' and '#{start_to}'
				and timestampdiff(minute, now(), t21.time_end) >= #{$RERUN_END_TIME_THRESHOLD}
		where
			t20.status in ('0')
			and t20.del_flag = 'N'
			and t20.cron_flag = 'N'
			and t20.called_total is null
	EOS

	data = Array.new()
	mysql_cli.query(query).each do |row|
		data = data + Array.new(1, row)
	end

	return data
end

# 発信リスト取得クエリの一部分(NGListに関する部分)を作成する
# @param [list_ng_id] NGリストID
# @param [tel_item] 電話番号のカラム名
# @return [String] クエリ文字列
def create_query_list_ng(list_ng_id, tel_item)
	if list_ng_id.blank?
		return ""
	end

	return <<-EOS
		and t11.#{tel_item} not in
		(
			select
				tel_no
			from
				t15_outgoing_ng_tels t15
			where
				t15.list_ng_id = '#{list_ng_id}'
				and t15.del_flag = 'N'
		)
	EOS
end

# スケジュールのステータスを更新する
# @param [Mysql] mysql_cli MySQLクライアント
# @param [String] schedule_id スケジュールID
# @param [String] status 更新ステータス
# @param [String] time_now 処理実行日時(YYYY-mm-dd HH:MM:SS)
def update_status_schedule(mysql_cli, schedule_id, status, time_now)
	query = <<-EOS
		update t20_out_schedules t20
		set
			t20.status = '#{status}',
			t20.modified = '#{time_now}'
		where
			t20.id = '#{schedule_id}'
	EOS

	mysql_cli.query(query)
end

# プロセスが存在するかチェックする
# @param [String] server_ip OUTサーバIP
# @param [String] server_port OUTサーバポート
# @param [String] server_user OUTサーバユーザ
# @param [String] server_pass OUTサーバパスワード
# @param [String] schedule_id スケジュールID
# @return [boolean] true：プロセスあり／false：プロセスなし
def process_exists?(server_ip, server_port, server_user, server_pass, schedule_id)
	options = {}
	options[:password] = server_pass
	unless server_port.blank?
		options[:port] = server_port
	end

	process_count = ''

	Net::SSH.start(server_ip, server_user, options) do |ssh|
		process_count = ssh.exec!("ps -ef | grep apdlg | grep #{schedule_id} | wc -l")
	end

	return process_count.to_i > 1
end

############################################
#
# バッチのメイン処理
#
############################################
retried = 0
limit = 5

begin
	program_name = "[発信時間超過スケジュール実行]"

	#DB接続情報
	mysql_cli = Mysql.connect(config[:database_ip], config[:database_id], config[:database_pass], config[:database_schema])
	mysql_cli.charset = "utf8"

	time_now = Time.now.strftime("%Y-%m-%d %H:%M:%S")
	start_from = Time.now.strftime("%Y-%m-%d 00:00")
	start_to = (Time.now - $RERUN_THRESHOLD).strftime("%Y-%m-%d %H:%M")

	mysql_cli.query(create_query_get_server_info).each do |row|
		#コールサーバ接続情報
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

		# 対象スケジュール取得
		arr_schedule_start = getInfoSchedule(mysql_cli, server_id, start_from, start_to)

		if arr_schedule_start.length == 0
			# 対象スケジュールなし
			next
		end

		arr_schedule_start.each do |arr_schedule|
			schedule_id = arr_schedule[0]
			list_id = arr_schedule[1]
			redial_flag = arr_schedule[2]
			list_ng_id = arr_schedule[3]
			schedule_no = "000000".slice(1..6 - schedule_id.to_s.length) + schedule_id.to_s
			localPathScheduleId = config[:local_schedule] + schedule_no

			writeLog(program_name + schedule_no + " 発信処理 : START")

			status = commandGetStatus(server_ip, schedule_no)
			if status.strip == "RET_ALIVE" || process_exists?(server_ip, server_port, server_user, server_pass, schedule_id)
				# プロセスが存在する場合
				# 発信処理を実行しない
				writeLog(program_name + schedule_no + " コールサーバステータス : " + status)
				writeLog(program_name + schedule_no + " 対象スケジュールのプロセスが存在するため発信処理中止")
				writeLog(program_name + schedule_no + " 発信処理 : END")
				next
			end

			# dial再作成
			localPathDial = localPathScheduleId + "/indata/dial/"
			fileDial = "1_dial.txt"
			system("mv " + localPathDial + fileDial + " " + localPathDial + "1_dial_backup.txt")
			createBlankCSV(localPathDial, fileDial)
			system("chmod 777 " + localPathDial + fileDial)
			csvFile = File.open(localPathDial + fileDial, "a:UTF-8")

			num_item = getNumAuthItemByScheduleId(mysql_cli, schedule_id)
			tel_item = getColumnByItemCode(mysql_cli, "tel_no", list_id)

			sms_items = getSmsItemName(mysql_cli, schedule_id)
			sms_arr_item = Array.new()
			sms_num_item = 0
			sms_items.each do |row|
				column = getColumnByItemName(mysql_cli, row, list_id)
				sms_arr_item.push(column)
				sms_num_item += 1
			end

			query_sms_item = ""
			str_item = getAllColumn(mysql_cli, schedule_id, list_id, "t11")
			sms_arr_item.each do |item|
				query_sms_item += ", t11.#{item}"
			end

			query_list_ng = create_query_list_ng(list_ng_id, tel_item)

			queryGetDial = <<-EOS
				select
					'1',
					t20.call_type,
					m07.external_prefix,
					#{str_item}
					#{query_sms_item}
				from
					t11_tel_lists t11
					inner join t20_out_schedules t20
						on t20.list_id = t11.list_id
						and t20.id = '#{schedule_id}'
					inner join m07_server_externals m07
						on t20.external_number = m07.external_number
						and m07.del_flag = 'N'
					inner join m01_servers m01
						on m01.server_id = m07.server_id
						and m01.server_type = '1'
						and m01.del_flag = 'N'
				where
					t11.list_id = '#{list_id}'
					and t11.#{tel_item} not in
					(
						select
							t80.tel_no
						from
							t80_outgoing_results t80
						where
							t80.schedule_id = '#{schedule_id}'
					)
					and t11.muko_flag = 'N'
					and t11.del_flag = 'N'
					#{query_list_ng}
				order by
					rand()
			EOS

			writeLog(program_name + schedule_no + " ダイヤル再作成 ： START")

			mysql_cli.query(queryGetDial).each do |row_dial|
				# t20.call_type = row_dial[1] = <通知(0)・非通知(1)>
				if row_dial[1] == "1"
					# 184を電話番号に付与して非通知とする。
					row_dial[3] = "184" + row_dial[3].to_s
				end
				# num_item = ユニークな認証項目の数。
				#    例：電話番号、生年月日=2  電話番号、電話番号=1
				# sms_num_item=ユニークなSMS挿入項目の数。
				#    例：電話番号、生年月日=2  電話番号、電話番号=1
				tmp = num_item + sms_num_item + 3
				str = ""

				# ダイヤルリストはまずグループ番号が先頭に入る。半角スペースを開けて、下記を登録していく。
				# <prefix付き電話番号>,<認証項目1>,<認証項目2>・・・・,<SMS挿入項目1>,<SMS挿入項目2>・・・・
				# （例）認証項目やSMS挿入項目がない場合→1 00190209097859705,
				for i in 3..tmp
					if i == 3
						# 電話番号
						str = row_dial[2].to_s + row_dial[i].to_s
					elsif i <= num_item + 3
						# 認証項目
						str = str + ',' + row_dial[i].to_s.gsub(/[^\d]/, "")
					else
						# SMS挿入項目
						str = str + ',' + row_dial[i].to_s.gsub(/ /, "")
					end
				end

				# row_dial[0]＝グループ番号。
				csvFile.puts(NKF::nkf("-Wsm0", row_dial[0].to_s + " " + str))
			end

			csvFile.close
			writeLog(program_name + schedule_no + " ダイヤル再作成 ： END")

			#ファイル転送
			remotePathScheduleId = config[:remote_path] + schedule_no
			remotePathBackup = remotePathScheduleId + "_backup"

			Net::SSH.start(server_ip, server_user, options) do |ssh|
				ssh.exec!("cp -R " + remotePathScheduleId + " " + remotePathBackup)
				writeLog(program_name + schedule_no + " フォルダバックアップ ： OK")
				begin
					writeLog(program_name + schedule_no + " フォルダ転送 ： START")
					ssh.sftp.connect do |sftp|
						sftp.upload!(localPathDial, remotePathScheduleId + "/indata/dial")
					end
					writeLog(program_name + schedule_no + " フォルダ転送 ： END")
					ssh.exec!("rm -rf " + remotePathBackup)
					writeLog(program_name + schedule_no + " フォルダバックアップを削除 : OK")
				rescue Exception, Timeout::Error, StandardError =>e
					writeLog(program_name + " サーバにフォルダ転送中にエラーが発生しました")
					ssh.exec!("rm -rf " + remotePathScheduleId)
					writeLog(program_name + schedule_no + " エラーフォルダ削除 ： OK")
					ssh.exec!("mv " + remotePathBackup + " " + remotePathScheduleId)
					writeLog(program_name + schedule_no + " ロールバックフォルダ ： OK")
				end
			end

			#実行コマンド
			command(server_ip, schedule_no, "addschedule", remotePathScheduleId + "/autopoll.conf")
			writeLog(program_name + schedule_no + " スケジュール割り当て ： OK")
			command(server_ip, schedule_no, "checkdata", "")
			writeLog(program_name + schedule_no + ' データチェック ： OK')
			command(server_ip, schedule_no, "autocall", "run")
			writeLog(program_name + schedule_no + " コール開始 ： OK")
			insert_run_log(mysql_cli, schedule_id)
			writeLog(program_name + schedule_no + " 実行ログ追加 ： OK")
			insert_log_schedule(mysql_cli, schedule_id)
			writeLog(program_name + schedule_no + " スケジュールログを追加 ： OK")
			update_status_schedule(mysql_cli, schedule_id, "1", time_now)
			writeLog(program_name + schedule_no + " 実行中ステータス更新 ： OK")
			writeLog(program_name + schedule_no + " 発信処理 : END")
			
			#通知メールを送信する
			sendMailInfo(schedule_no, program_name)
		end
	end
	mysql_cli.close()
rescue Timeout::Error => e
	if retried < limit
		retried += 1
		sleep(1)
		retry
	else
		puts "err_mega_crontab_run"
		writeLog(program_name + "err_mega_crontab_run : " + e.message)
		writeLog(program_name + "コールクライアントでのコマンド呼び出しエラーが発生")
		writeLog(e.backtrace.join("\n"))
		sendMailError("")
	end
	exit 9
rescue Exception, StandardError => e
	puts "err_mega_crontab_run"
	writeLog(program_name + "err_mega_crontab_run : " + e.message)
	writeLog(e.backtrace.join("\n"))
	sendMailError("")
	exit 9
end
