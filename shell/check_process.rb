# encoding: UTF-8
#=============================================================================
# Contents   : プロセス監視
# Author     : Ascend Corp
# Since      : 2016/07/20        1.0
#=============================================================================
load File.join(File.dirname(__FILE__),'common.rb')
load File.join(File.dirname(__FILE__),'config.rb')

instance =  AscConfig.new
instance.instance_eval File.read File.join(File.dirname(__FILE__),'config.ini')
config = instance.getData


def getInfoServerByUserId(db_ip, db_id, db_pass, db_schema)  
	mysql_cli = Mysql.connect(db_ip, db_id, db_pass, db_schema)
	mysql_cli.charset = "utf8"
	data = Array.new()
	query = <<EOS
        select 
            m01.server_ip,
            m01.username,
            m01.password,
            m01.server_port,
            m01.server_type
        from
        m01_servers m01
        where
        m01.del_flag = 'N'          
EOS
	mysql_cli.query(query).each do | row |
        data = data + Array.new(1, row)
    end
    return data
end 

#===========================================
# ログファイル名を取得
#===========================================
def getProcessLogFileName()
	localPathLog = getLocalPathLogBatch()
	FileUtils.mkdir_p(localPathLog)
	return localPathLog + "checkprocess.log"
end

#===========================================
# ログファイルに書き込む
#===========================================
def writeProcessLog(str) 
	unless File.file?(getProcessLogFileName())
		logCreate = File.new(getProcessLogFileName(), "w")
		logCreate.chmod(0777)
	end
	logFile = File.open(getProcessLogFileName(),'a:UTF-8')
	logFile.puts "["+Time.now.strftime("%Y/%m/%d %H:%M:%S")+"] "+str
	logFile.close
end

#===========================================
# ログファイルを読み込んでカウント
#===========================================
def readProcessLog()
	logFile = File.open(getProcessLogFileName(),'r:UTF-8')
	error_count = logFile.read.scan("チェックプロセスエラー").length
	logFile.close
	return error_count
end

#===========================================
# ログファイルを削除
#===========================================
def clearProcessLog ()
	if File.exist?(getProcessLogFileName())
		FileUtils.rm_f(getProcessLogFileName())
	end
end

############################################
#
# バッチのメイン処理
#
############################################
retried = 0
limit = 5
begin
	program_name = "[CheckProcess]"

	#DB接続情報
	db_ip = config[:database_ip]
	db_id = config[:database_id]
	db_pass = config[:database_pass]
	db_schema = config[:database_schema]

	dataServer = getInfoServerByUserId(db_ip, db_id, db_pass, db_schema)
	if dataServer.length > 0
		dataServer.each do | row |
			server_ip = row[0]
			server_user = row[1]
			server_pass = row[2]
			server_port = row[3]
			server_type = row[4]
			options = {}
			options[:password] = server_pass
			unless server_port.blank?
				options[:port] = server_port
			end

			ascallsrv_result = 0
			enosipctrl_result = 0
			Net::SSH.start( server_ip, server_user, options) do |ssh|
				ascallsrv_result = ssh.exec!("ps -el | grep ascallsrv | wc -l")
				enosipctrl_result = ssh.exec!("ps -el | grep enosipctrl | wc -l")
			end

			if ascallsrv_result.to_i > 0
				if (enosipctrl_result.to_i >= 150) || (enosipctrl_result.to_i >= 100 && server_type.to_i == 0) 
					clearProcessLog()
				else
					writeProcessLog("チェックプロセスエラー")
					checkProcessErrorCount = readProcessLog()
					if checkProcessErrorCount >= 5
						raise program_name + " enosipctrlチェックエラー: 現在 " + enosipctrl_result.strip + " Process " + "サーバーIP：" + server_ip
					elsif checkProcessErrorCount <= 2
						writeLog("NoSendMail" + program_name + " enosipctrlチェックエラー: 現在 " + enosipctrl_result.strip + " Process " + "サーバーIP：" + server_ip + "\n1回目:連続しなければ問題ないです")
					else
						writeLog("NoSendMail" + program_name + " enosipctrlチェックエラー: 現在 " + enosipctrl_result.strip + " Process " + "サーバーIP：" + server_ip + "\n2回目:連続しなければ問題ないです")
					end
				end
			else
				raise program_name + " ascallsrvチェックエラー: 現在 " + ascallsrv_result.strip + " Process " + "サーバーIP：" + server_ip
			end
		end
	else
		raise program_name + "エラー：サーバ情報がない"
	end
rescue Timeout::Error =>e
	if retried < limit
		retried+=1
		sleep(5)
		retry
	else
		p e
		writeLog(program_name + "TimeoutError : " + e.message)
		writeLog(e.backtrace.join("\n"))
		sendMailError("")
	end
	exit 9
rescue Exception, StandardError =>e
	p e
	writeLog(program_name + "StandardError : " + e.message)
	writeLog(e.backtrace.join("\n"))
	sendMailError("")
	exit 9
end
