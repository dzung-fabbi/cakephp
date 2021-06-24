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
def getScheduleCalling(mysql_cli, server_id)
	time_now = Time.now.strftime("%Y-%m-%d %H:%M")
	query = <<EOS
		select 
			t20.id,
			t20.list_id,
			t20.term_valid_count
		from
			t20_out_schedules t20
				inner join
			m07_server_externals m07 ON t20.external_number = m07.external_number
				and m07.del_flag = 'N'
				and m07.server_id = '#{server_id}'
		where
			t20.status in ('1')
				and t20.del_flag = 'N'
				and t20.cron_flag = 'N'
				and t20.term_valid_count > 0
EOS
	data=Array.new()
	mysql_cli.query(query).each do | row |
		data = data + Array.new(1, row)
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

############################################
#
# バッチのメイン処理
#
############################################
retried = 0
limit = 5
begin
	#exit 9
	program_name = "[自動停止有効回答実行]"
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
		arr_schedule_calling = getScheduleCalling(mysql_cli, server_id)
		#コール終了
		if arr_schedule_calling.length > 0
			arr_schedule_calling.each do | arr_schedule |
				schedule_id = arr_schedule[0]
				list_id = arr_schedule[1]
				term_valid_count = arr_schedule[2]
				yuko_num = getYukoNum(mysql_cli, schedule_id, list_id);
				if yuko_num.to_i >= term_valid_count.to_i
					schedule_no = "000000".slice(1..6-schedule_id.to_s.length) + schedule_id.to_s
					command(server_ip, schedule_no, "autocall", "term")
					writeLog(program_name + schedule_no + " コール停止　：　OK")
					update_status_schedule(mysql_cli, schedule_id, "6", time_now)
					writeLog(program_name + schedule_no + " 終了中ステータス更新　：　OK")
				end
			end
		end
	end
	mysql_cli.close()
rescue Timeout::Error =>e
	if retried < limit
		retried+=1
		sleep(1)
		retry
	else
		puts "err_mega_crontab_stop_valid_count"
		writeLog(program_name + "err_mega_crontab_stop_valid_count : " + e.message)
		writeLog(program_name + "コールクライアントでのコマンド呼び出しエラーが発生")
		writeLog(e.backtrace.join("\n"))
		sendMailError("")
	end
	exit 9
rescue Exception, StandardError =>e
	puts "err_mega_crontab_stop_valid_count"
	writeLog(program_name + "err_mega_crontab_stop_valid_count : " + e.message)
	writeLog(e.backtrace.join("\n"))
	sendMailError("")
	exit 9
end