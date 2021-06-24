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
# バッチのメイン処理
#
############################################
begin
	program_name = "[終了ステータス更新]"
	#DB接続情報
	db_ip = config[:database_ip]
	db_id = config[:database_id]
	db_pass = config[:database_pass]
	db_schema = config[:database_schema]
	mysql_cli = Mysql.connect(db_ip, db_id, db_pass, db_schema)
	mysql_cli.charset="utf8"
	#停止スケジュールが終了ステータスを更新
	time_now = Time.now.strftime("%Y-%m-%d %H:%M")
	queryGetSchedule = <<EOS
							select 
								t21.schedule_id, DATE_FORMAT(MAX(t21.time_end),'%Y-%m-%d %k:%i')
							from
								t21_out_times t21
									inner join
								t20_out_schedules t20 ON t21.schedule_id = t20.id
									and t20.status in('2', '7')
									and t20.del_flag = 'N'
									and t21.del_flag = 'N'
							group by t21.schedule_id
EOS
	mysql_cli.query(queryGetSchedule).each do |row|
		schedule_id = row[0]
		time_end = row[1]
		if time_end == time_now
			queryUpdateStatusEnd = <<EOS
			UPDATE 
				t20_out_schedules t20 
			SET 
				t20.status = '4'
			WHERE
				t20.id = '#{schedule_id}'
EOS
			mysql_cli.query(queryUpdateStatusEnd)
			writeLog(program_name + schedule_id + " : OK")
		end
	end
	mysql_cli.close()
rescue Exception, StandardError =>e
	puts "err_mega_crontab_finish_update"
	writeLog(program_name + "err_mega_crontab_finish_update : " + e.message)
	exit 9
end