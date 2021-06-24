# encoding: UTF-8
#=============================================================================
# Contents   : スケジュールファイルの削除
# Author     : Ascend Corp
# Since      : 2020/02/18        1.0
#=============================================================================
load File.join(File.dirname(__FILE__),'common.rb')
load File.join(File.dirname(__FILE__),'config.rb')


#=============================================================================
# 前処理
#=============================================================================
def preProcess
	instance =  AscConfig.new
	instance.instance_eval File.read File.join(File.dirname(__FILE__),'config.ini')
	@config = instance.getData
end

#=============================================================================
# DB接続クライアント生成
# @return [mysql_cli] DB接続クライアント
#=============================================================================
def setDbconectInfo()
	db_ip = @config[:database_ip]
	db_id = @config[:database_id]
	db_pass = @config[:database_pass]
	db_schema = @config[:database_schema]
	mysql_cli = Mysql.connect(db_ip, db_id, db_pass, db_schema)
	mysql_cli.charset = "utf8"
	return mysql_cli
end

#=============================================================================
# 終了ステータスのスケジュールを取得(アウトバウンド)
#=============================================================================
def getDelOutSchedules(mysql_cli, from_del_date, to_del_date, server_type)
	data = Array.new()
	query = <<EOS
		select
			lpad(t20.id, 6, '0'),
			m01.server_id
		from t20_out_schedules t20
		inner join t21_out_times t21
			on t20.id = t21.schedule_id
		inner join  m07_server_externals m07
			on t20.external_number = m07.external_number
		inner join m01_servers m01
			on m07.server_id = m01.server_id
		where (t20.status = '4' or t20.del_flag = 'Y')
			and t21.time_end between '#{from_del_date}' and '#{to_del_date}'
			and m01.server_type = '#{server_type}';
EOS
	mysql_cli.query(query).each do | row |
		data = data + Array.new(1, row)
	end
	return data
end

#=============================================================================
# 終了ステータスのスケジュールを取得(インバウンド)
#=============================================================================
def getDelInSchedules(mysql_cli, from_del_date, to_del_date, server_type)
	data = Array.new()
	query = <<EOS
		select
			lpad(t25.id, 6, '0'),
			m01.server_id
		from t25_inbounds t25
		inner join  m07_server_externals m07
			on t25.external_number = m07.external_number
		inner join m01_servers m01
			on m07.in_server_id = m01.server_id
		where 
			((t25.status = 2 and t25.time_end between '#{from_del_date}' and '#{to_del_date}')
			or (t25.del_flag = 'Y' and t25.time_start between '#{from_del_date}' and '#{to_del_date}'))
			and m01.server_type = '#{server_type}';
EOS
	mysql_cli.query(query).each do | row |
		data = data + Array.new(1, row)
	end
	return data
end

#=============================================================================
# 接続先サーバーIP取得
#=============================================================================
def getInfoServerByUserId(mysql_cli, server_type)
  data = Array.new()
  query = <<EOS
        select 
            m01.server_ip,
            m01.username,
            m01.password,
            m01.server_port,
            m01.server_type,
			m01.server_id
        from
        m01_servers m01
        where
        	m01.del_flag = 'N'
			and m01.server_type = '#{server_type}';
EOS
  mysql_cli.query(query).each do | row |
        data = data + Array.new(1, row)
    end
    return data
end 

#=============================================================================
#コールサーバーへのSSH接続
#接続先のスケジュールデータをバックアップディレクトリへ移動
#=============================================================================
def sshAndMoveScheduleData(data_Server, del_data, remote_path, remote_backup_path)
	recall_dir = "_recall_backup"
	data_Server.each do | row |
		server_ip = row[0]
		server_user = row[1]
		server_pass = row[2]
		server_port = row[3]
		server_type = row[4]
		server_id = row[5]
		options = {}
		options[:password] = server_pass
		unless server_port.blank?
			options[:port] = server_port
		end

		if remote_backup_path.blank?
			writeLog_DeleteSchedules("バックアップディレクトリのパスが空です。削除処理を実行しませんでした。")
			return
		end

		Net::SSH.start( server_ip, server_user, options) do |ssh|

			#バックアップディレクトリの削除
			cmd = "rm -rf #{remote_backup_path}"
			writeLog_DeleteSchedules("実行コマンド： #{cmd}")
			#実行コマンド
			ssh.exec!(cmd)

			#バックアップディレクトリの作成
			cmd = "mkdir #{remote_backup_path}"
			writeLog_DeleteSchedules("実行コマンド： #{cmd}")
			#実行コマンド
			ssh.exec!(cmd)

			del_data.each do | schedule |
				if schedule[1] != server_id
					#対象のコールサーバーのファイルのみを移動
					next
				end

				
				#ディレクトリが存在する場合、ログ残して移動
				direxist = ssh.exec!("if [ -e #{remote_path}#{schedule[0]} ]; then echo OK; fi")
				if !direxist.blank?
					cmd = "mv -f #{remote_path}#{schedule[0]} #{remote_backup_path}"
					writeLog_DeleteSchedules("実行コマンド： #{cmd}")
					#実行コマンド
					ssh.exec!(cmd)
				end
				
				#recallディレクトリはアウトにのみ存在するため、インはここで処理終了
				if server_type == 0
					next
				end

				#recallディレクトリがある場合は移動する。
				recall_dir_exist = ssh.exec!("if [ -e #{remote_path}#{schedule[0]}#{recall_dir} ]; then echo OK; fi")
				if !recall_dir_exist.blank?
					cmd = "mv -f #{remote_path}#{schedule[0]}#{recall_dir} #{remote_backup_path}"
					writeLog_DeleteSchedules("実行コマンド： #{cmd}")
					#実行コマンド
					ssh.exec!(cmd)
				end
			end
		end
	end
end
#=============================================================================
#ローカルのスケジュールデータをバックアップディレクトリへ移動
#=============================================================================
def moveLocalScheduleData(del_data, local_path, local_backup_path)
	if del_data.length < 1
		return
	end
	#WEBサーバーのデータ移動
	del_data.each do | local_schedule |
		#ディレクトリが存在する場合、ログ残して移動
		if Dir.exist?("#{local_path}#{local_schedule[0]}")
			cmd = "mv -f #{local_path}#{local_schedule[0]} #{local_backup_path}"
			writeLog_DeleteSchedules("実行コマンド： #{cmd}")
			#実行コマンド
			system(cmd)
		end
	end
end

#=============================================================================
# バックアップディレクトリを削除&作成
#=============================================================================
def remove_Backup_Data(local_del_path)
	if local_del_path.blank?
		writeLog_DeleteSchedules("パスが空白です。削除処理を実行しませんでした。")
		return
	end

	#バックアップディレクトリ削除
	FileUtils.rm_rf(local_del_path)

	#新規バックアップディレクトリの作成
	FileUtils.mkdir(local_del_path)
end

#=============================================================================
# ログファイル名を取得
#=============================================================================
def getLogFileName_DeleteSchedules()
	localPathLog = getLocalPathLogBatch()
	FileUtils.mkdir_p(localPathLog) unless File.exists?(localPathLog)
	return localPathLog+"deleteschedules"+Time.now.strftime("%Y%m%d")+".log"
end

#=============================================================================
# ログ記録用
#=============================================================================
def writeLog_DeleteSchedules(str)
	unless File.file?(getLogFileName_DeleteSchedules())
		logCreate = File.new(getLogFileName_DeleteSchedules(), "w")
		logCreate.chmod(0777)
	end
	logFile = File.open(getLogFileName_DeleteSchedules(),'a:UTF-8')
	logFile.puts "["+Time.now.strftime("%Y/%m/%d %H:%M:%S")+"] "+str
	logFile.close
end

#=============================================================================
#
# バッチのメイン処理
# スケジュールデータの削除処理は6ヶ月前から1ヶ月前が対象
#=============================================================================
begin

	# 前処理
	preProcess()


	# 変数定義
	#過去2ヶ月前から9ヶ月前のデータを削除
	fromDelDate = Date.today << 9
	toDelDate = Date.today << 2
	fromDelDate = fromDelDate.strftime("%Y-%m-%d %H:%M:%S")
	toDelDate = toDelDate.strftime("%Y-%m-%d %H:%M:%S")
	program_name = "[スケジュールデータ削除]"

	writeLog_DeleteSchedules(program_name + "処理開始")

	#ローカルバックアップディレクトリを空にする
	remove_Backup_Data(@config[:local_out_schedule_backup_path])
	remove_Backup_Data(@config[:local_in_schedule_backup_path])
	writeLog_DeleteSchedules(program_name + "バックアップディレクトリ削除完了")

	# DB接続クライアント
	mysql_cli = setDbconectInfo()
##################################アウト削除start
	# 削除対象データの取得
	del_out_data = getDelOutSchedules(mysql_cli, fromDelDate, toDelDate, "1")
	writeLog_DeleteSchedules(program_name + "削除対象データの取得")

	# ローカルデータ(WEBサーバー)移動
	moveLocalScheduleData(del_out_data, @config[:local_out_schedule_path], @config[:local_out_schedule_backup_path])
	writeLog_DeleteSchedules(program_name + "ローカルデータの移動完了")

	# アウトバウンドサーバーの接続情報取得
	outServer = getInfoServerByUserId(mysql_cli, 1)
	writeLog_DeleteSchedules(program_name + "アウトバウンドサーバーの接続情報取得完了")
	if outServer.length == 0
		writeLog_DeleteSchedules(program_name + "アウトバウンドサーバの情報が取得できません。処理を終了します。")
		exit
	end

	# コールサーバーのスケジュールデータを移動
	sshAndMoveScheduleData(outServer, del_out_data, @config[:remote_out_schedule_path], @config[:remote_out_schedule_backup_path])
	writeLog_DeleteSchedules(program_name + "アウトバウンドサーバーのスケジュールデータを削除完了")
##################################アウト削除end

##################################イン削除start
	# 削除対象データの取得
	del_in_data = getDelInSchedules(mysql_cli, fromDelDate, toDelDate, "0")
	writeLog_DeleteSchedules(program_name + "削除対象データの取得")

	# ローカルデータ(WEBサーバー)移動
	moveLocalScheduleData(del_in_data, @config[:local_in_schedule_path], @config[:local_in_schedule_backup_path])

	writeLog_DeleteSchedules(program_name + "ローカルデータ移動完了")

	# インバウンドサーバーの接続情報取得
	inServer = getInfoServerByUserId(mysql_cli, 0)
	writeLog_DeleteSchedules(program_name + "インバウンドサーバーの接続情報取得完了")
	if inServer.length == 0
		writeLog_DeleteSchedules(program_name + "インバウンドサーバの情報が取得できません。処理を終了します。")
		exit
	end

	# コールサーバーのスケジュールデータを移動
	sshAndMoveScheduleData(inServer, del_in_data, @config[:remote_in_schedule_path], @config[:remote_in_schedule_backup_path])
	writeLog_DeleteSchedules(program_name + "インバウンドサーバーのスケジュールデータを削除完了")

##################################イン削除end
	mysql_cli.close()

	writeLog_DeleteSchedules(program_name + "処理完了")
rescue Exception => e
	writeLog_DeleteSchedules(program_name + "エラー：スケジュールファイル削除：失敗 - " + e.message)
	writeLog_DeleteSchedules(e.backtrace.join("\n"))
	exit 9
end
