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
	program_name = "[ログインフラグ更新]"
	#DB接続情報
	db_ip = config[:database_ip]
	db_id = config[:database_id]
	db_pass = config[:database_pass]
	db_schema = config[:database_schema]
	mysql_cli = Mysql.connect(db_ip, db_id, db_pass, db_schema)
	mysql_cli.charset="utf8"
	#停止スケジュールが終了ステータスを更新
	time_now = Time.now.strftime("%Y-%m-%d %H:%M")
	query = <<EOS
		UPDATE 
			m05_users m05 
		SET 
			m05.login_flag = 'N',
			m05.modified = '#{time_now}'
		WHERE 
			m05.del_flag = 'N'
			and m05.login_flag = 'Y'
EOS
	mysql_cli.query(query)
	writeLog(program_name + " : OK")
	mysql_cli.close()
rescue Exception, StandardError =>e
	puts "err_update_login_flag"
	writeLog(program_name + "err_update_login_flag : " + e.message)
	exit 9
end