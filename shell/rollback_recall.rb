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
	program_name = "[RollbackReCall]"
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
			remotePathScheduleId = config[:remote_path] + schedule_no
			remotePathBackup = config[:remote_path] + schedule_no + "_recall_backup"
			ssh.exec!("rm -rf " + remotePathScheduleId)
			writeLog(program_name + schedule_no + "エラーフォルダ削除 ： OK")
			ssh.exec!("mv " + remotePathBackup + " " + remotePathScheduleId)
			writeLog(program_name + schedule_no + "ロールバックフォルダ ： OK")
		end
	end
rescue Exception, StandardError =>e
	puts "err_rollback_recall"
	writeLog(program_name + "err_rollback_recall : " + e.message)
	writeLog(program_name + "フォルダをロールバックのエラーを発生")
	exit 9
end