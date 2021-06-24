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
# バッチのメイン処理
#
############################################
retried = 0
limit = 5
begin
	program_name = "[無効反映]"
	server_id = ARGV[0]
	schedule_id = ARGV[1]
	schedule_no = "000000".slice(1..6-schedule_id.to_s.length) + schedule_id.to_s
	list_id = ARGV[2]
	tel_column = ARGV[3]
	db_ip = config[:database_ip]
	db_id = config[:database_id]
	db_pass = config[:database_pass]
	db_schema = config[:database_schema]
	mysql_cli=Mysql.connect(db_ip, db_id, db_pass, db_schema)
	mysql_cli.charset="utf8"
	localPathSchedule = config[:local_schedule]
	localPathScheduleId = config[:local_schedule] + schedule_no
	remotePathScheduleId = config[:remote_path] + schedule_no
	fileName = 'prohibit_'+Time.now.strftime("%Y%m%d%H%M%S")+'.txt'
	createBlankCSV(localPathScheduleId+"/", fileName)
	system("chmod 777 " + localPathScheduleId + "/" + fileName)
	csvFile = File.open(localPathScheduleId +"/" + fileName, 'a:UTF-8')
	#実行中スケジュールを取る
	external_prefix = ""
	queryGetPrefix = <<EOS
		select 
		    m07.external_prefix
		from
		    t20_out_schedules t20
		    	inner join
		    m07_server_externals m07 ON t20.external_number = m07.external_number
		        and m07.del_flag = 'N'
		where
		    t20.id = '#{schedule_id}'
		        and t20.del_flag = 'N'
		        and t20.cron_flag = 'N'
EOS
	mysql_cli.query(queryGetPrefix).each do | row_prefix |
		external_prefix = row_prefix[0]
	end
	queryGetDialMuko = <<EOS
			select
				t11.#{tel_column}
			from
				t11_tel_lists t11 
			where
				t11.list_id = '#{list_id}'
				and t11.muko_flag = 'Y'
			order by t11.muko_modified desc
			limit 20
EOS
	mysql_cli.query(queryGetDialMuko).each do | row_dial |
		csvFile.puts(NKF::nkf('-Wsm0', external_prefix.to_s + row_dial[0].to_s))
	end
	csvFile.close
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
			writeLog(program_name + schedule_no + "ファイル転送 ： START")
			ssh.sftp.connect do |sftp|
				sftp.upload!(localPathScheduleId + "/" + fileName, remotePathScheduleId + "/" + fileName)
			end
			writeLog(program_name + schedule_no + "ファイル転送 ： END")
		end
		writeLog(program_name + schedule_no + "prohibitコマンド ： START")
		command = "/home/robo/as-call/bin/ascallcli -h " + server_ip + " -p 17119 -s " + schedule_no + " -c prohibit /home/robo/var/" + schedule_no + "/" + fileName
		result = `#{command}`
		writeLog(program_name + schedule_no + "prohibitコマンド ： END")
	end
rescue Timeout::Error =>e
	if retried < limit
		puts "retry : " + retried.to_s
		retried+=1
		sleep(5)
		retry
	else
		puts "err_muko"
		writeLog(program_name + "err_muko : " + e.message)
		writeLog(program_name + "無効反映のエラーを発生")
		writeLog(e.backtrace.join("\n"))
		sendMailError(schedule_id)
	end
	exit 9
rescue Exception, StandardError =>e
	puts "err_muko"
	writeLog(program_name + "err_muko : " + e.message)
	writeLog(program_name + "無効反映のエラーを発生")
	writeLog(e.backtrace.join("\n"))
	sendMailError(schedule_id)
	exit 9
end