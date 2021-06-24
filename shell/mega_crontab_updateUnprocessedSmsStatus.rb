# encoding: UTF-8
#=============================================================================
# Contents   : 設定フォルダ転送
# Author     : Ascend Corp
# Since      : 2020/01/21        1.0
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
# SMS送信ステータスが一ヶ月以上「sending(送信中)」に
# なっているデータを「unknown(不明)」に更新する
# @param [Client] mysql_cli DB接続クライアント
# @param [String] subtractDate 一ヶ月前の日付
#=============================================================================
def updateOutGoingSmsStatuses(mysql_cli, subtractDate)
	writeLog("[SMSステータス更新]開始：アウトバウンドSMSステータス")
	query = <<-EOS
		update t83_outgoing_sms_statuses
		set
	  	sms_status = 'unknown'
		, modified = now()
		, update_program = 'mega_crontab_updateUnprocessedSmsStatus'
		where
	  	sms_status ='sending'
		and created < '#{subtractDate}'
	EOS
	mysql_cli.query(query)
	writeLog("[SMSステータス更新]終了：アウトバウンドSMSステータス")
end

#=============================================================================
# SMS送信ステータスが一ヶ月以上「sending(送信中)」に
# なっているデータを「unknown(不明)」に更新する
# @param [Client] mysql_cli DB接続クライアント
# @param [String] subtractDate 一ヶ月前の日付
#=============================================================================
def updateInboundSmsStatuses(mysql_cli, subtractDate)
	writeLog("[SMSステータス更新]開始：インバウンドSMSステータス")
	query = <<-EOS
		update t86_inbound_sms_statuses
		set
	  	sms_status = 'unknown'
		, modified = now()
		, update_program = 'mega_crontab_updateUnprocessedSmsStatus'
		where
	  	sms_status ='sending'
		and created < '#{subtractDate}'
	EOS
	mysql_cli.query(query)
	writeLog("[SMSステータス更新]終了：インバウンドSMSステータス")
end

#=============================================================================
# SMS送信ステータスが一ヶ月以上「sending(送信中)」に
# なっているデータを「unknown(不明)」に更新する
# @param [Client] mysql_cli DB接続クライアント
# @param [String] subtractDate 一ヶ月前の日付
#=============================================================================
def updateSmsSendResults(mysql_cli, subtractDate)
	writeLog("[SMSステータス更新]開始：一括送信SMSステータス")
	query = <<-EOS
		update t800_sms_send_results
		set
		status = 'unknown'
		, modified = now()
		, update_program = 'mega_crontab_updateUnprocessedSmsStatus'
		where
		status ='sending'
		and send_datetime < '#{subtractDate}'
	EOS
	mysql_cli.query(query)
	writeLog("[SMSステータス更新]終了：一括送信SMSステータス")
end

#=============================================================================
# メイン処理
#=============================================================================
begin
	# 前処理
	preProcess()
	# DB接続クライアント
	mysql_cli = setDbconectInfo()
	# 一ヶ月前の日付取得
	subtractDate = Date.today << 1
	subtractDate = subtractDate.strftime("%Y-%m-%d %H:%M:%S")
	# アウトバウンド／インバウンド／SMSの送信ステータス更新
	updateOutGoingSmsStatuses(mysql_cli, subtractDate)
	updateInboundSmsStatuses(mysql_cli, subtractDate)
	updateSmsSendResults(mysql_cli, subtractDate)
	mysql_cli.close()
rescue Exception => e
	# ここでエラー通知はしない
	# check_invoke_result.rbにてエラーを検知させる
	writeLog("[SMSステータス更新]エラー：SMSステータス更新バッチ実行：失敗 - " + e.message)
	writeLog(e.backtrace.join("\n"))
	exit 9
end