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
	program_name = "[再開]"
	server_id = ARGV[0]
	schedule_no = ARGV[1]
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
	remotePathScheduleId = config[:remote_path] + schedule_no
	remotePathBackup = config[:remote_path] + schedule_no + "_recall_backup"
	
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
					sftp.upload!(localPathScheduleId + "/autopoll.conf", remotePathScheduleId + "/autopoll.conf")
				end
				writeLog(program_name + schedule_no + "フォルダ転送 ： END")
			rescue Exception, Timeout::Error, StandardError =>e
				writeLog(program_name + "サーバにフォルダ転送のエラーを発生")
				ssh.exec!("rm -rf " + remotePathScheduleId)
				writeLog(program_name + schedule_no + "エラーフォルダ削除 ： OK")
				ssh.exec!("mv " + remotePathBackup + " " + remotePathScheduleId)
				writeLog(program_name + schedule_no + "ロールバックフォルダ ： OK")
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
		puts "err_send_recall_folder"
		writeLog(program_name + "err_send_recall_folder : " + e.message)
		writeLog(program_name + "再開フォルダを転送のエラーを発生")
		writeLog(e.backtrace.join("\n"))
		sendMailError(schedule_no.to_i)
	end
	exit 9
rescue Exception, StandardError =>e
	puts "err_send_recall_folder"
	writeLog(program_name + "err_send_recall_folder : " + e.message)
	writeLog(program_name + "再開フォルダを転送のエラーを発生")
	writeLog(e.backtrace.join("\n"))
	sendMailError(schedule_no.to_i)
	exit 9
end