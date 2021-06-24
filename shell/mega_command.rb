# encoding: UTF-8
#=============================================================================
# Contents   : スケジュール割り当て
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
# バッチのメイン処理
#
############################################
begin
	server_ip = ARGV[0]
	schedule_no = ARGV[1]
	action = ARGV[2]
	#DB接続情報
	db_ip = config[:database_ip]
	db_id = config[:database_id]
	db_pass = config[:database_pass]
	db_schema = config[:database_schema]
	mysql_cli = Mysql.connect(db_ip, db_id, db_pass, db_schema)
	mysql_cli.charset = "utf8"
	#メール
	to = getListMail()
	from = "astar_report@ascend-corp.co.jp"
	#スケジュール作成
	if action == "create"
		command(server_ip, schedule_no, "addschedule", "/home/robo/var/"+schedule_no+"/autopoll.conf")
		writeLog(schedule_no + " スケジュール割り当て　：　OK")
		command(server_ip, schedule_no, "checkdata", "")
		writeLog(schedule_no + " データチェック　：　OK")
		command(server_ip, schedule_no, "delschedule", "")
		writeLog(schedule_no + " スケジュール解放　：　OK")
	end
	#コール開始
	if action == "call" || action == "recall"
		command(server_ip, schedule_no, "addschedule", "/home/robo/var/"+schedule_no+"/autopoll.conf")
		writeLog(schedule_no + " スケジュール割り当て　：　OK")
		command(server_ip, schedule_no, "checkdata", "")
		writeLog(schedule_no + " データチェック　：　OK")
		command(server_ip, schedule_no, "autocall", "run")
		writeLog(schedule_no + " コール開始　：　OK")
		insert_run_log(mysql_cli, schedule_no.to_i)
		writeLog(schedule_no + " 実行ログ追加　：　OK")
		insert_log_schedule(mysql_cli, schedule_no.to_i)
		writeLog(schedule_no + " スケジュールログを追加　：　OK")
		#リダイヤルの場合
		queryUpdateRecallFlag = <<EOS
					update t20_out_schedules t20 
					set 
					    t20.recall_flag = t20.recall_flag + 1
					where
					    t20.id = '#{schedule_no.to_i}' and t20.status = '7'
EOS
		mysql_cli.query(queryUpdateRecallFlag)
		#
		queryGetInfoSchedule = <<EOS
					select 
						list_id,
						recall_flag,
						list_ng_id
					from 
						t20_out_schedules t20 
					where
						t20.id = '#{schedule_no.to_i}' and t20.status = '7'
EOS
		mysql_cli.query(queryGetInfoSchedule).each do | row |
			date_run = Time.now.strftime("%Y-%m-%d %H:%M:%S")
			tel_item = getColumnByItemCode(mysql_cli, "tel_no", row[0])
			redial_num = row[1]
			if row[2].blank?
				query_list_ng = ""
			else
				query_list_ng = "and t11.#{tel_item} not in (SELECT 
																tel_no
															FROM
																t15_outgoing_ng_tels t15
															WHERE
																t15.list_ng_id = '#{row[2]}'
																and t15.del_flag = 'N'
															)
								"
			end
			queryInsertT52 = <<EOS
				insert into t52_tel_redials(schedule_id, redial_flag, customize1, customize2, customize3, customize4,
					customize5, customize6, customize7, customize8, customize9, customize10, customize11, created)
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
					t11.customize11,
					"#{date_run}"
				from t20_out_schedules t20 inner join t11_tel_lists t11 on t20.list_id = t11.list_id and t11.del_flag = "N"
				where 
					t20.id = '#{schedule_no.to_i}'
					and t11.#{tel_item} not in (SELECT 
													t80.tel_no
												FROM
													t80_outgoing_results t80
												WHERE
													t80.schedule_id = '#{schedule_no.to_i}'
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
	#コール停止
	if action == "stop"
		command(server_ip, schedule_no, "autocall", "term")
		writeLog(schedule_no + " コール停止　：　OK")
	end
	mysql_cli.close()
rescue Exception, StandardError =>e
	puts "err_mega_command"
	writeLog("err_mega_command : " + e.message)
	writeLog(e.backtrace.join("\n"))
	sendMailError(schedule_no.to_i)
	exit 9
end