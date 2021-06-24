# encoding: UTF-8
#=============================================================================
# Contents   : 実行結果検証
#              夜間バッチで発生した緊急でないエラーを検出し、メールで通知する
#              アウトバウンド／インバウンド／SMSの全てを当バッチで検出する
# Author     : Ascend Corp
# Since      : 2020/01/23        1.0
#=============================================================================
load File.join(File.dirname(__FILE__),'common.rb')
load File.join(File.dirname(__FILE__),'config.rb')

#=============================================================================
# 前処理
#=============================================================================
def preProcess
	# エラー抽出文字列
	# エラーを検出したい文字列が増えた場合、このオブジェクトに格納する
	# アウトバウンド
	@searchKeyOutbound = []
	@searchKeyOutbound.push("[SMSステータス更新]エラー：SMSステータス更新バッチ実行：失敗")
	# インバウンド
	@searchKeyInbound = []
	# SMS
	@searchKeySms = []

	# logディレクトリ
	@logDirOutbound = "/log/"
	@logDirInbound = "/inbound/log/"
	@logDirSms = "/sms/log/"
end

#=============================================================================
# ログファイル存在チェック
# @param [String] logDir ログファイルディレクトリ
# @return ファイルが存在する場合：true／それ以外：false
#=============================================================================
def existLogFile(logDir)
	return File.exist?(getLogFile(logDir))
end

#=============================================================================
# ログファイル名取得
# @param [String] logDir ログファイルディレクトリ
# @return ログファイル名
#=============================================================================
def getLogFile(logDir)
	localPathLog = File.dirname(__FILE__) + logDir
	if logDir.include?("sms") then
		# smsの場合
		localPathLog + "sms_log_"
	end
	# アウトバウンド／インバウンドの場合
	return localPathLog + Time.now.strftime("%Y%m%d") + ".log"
end

#=============================================================================
# ログファイル検証
# @param [String] logDir ログファイルディレクトリ
# @param [Array] searchKey エラー抽出文字列
#=============================================================================
def verifyLogFile(logDir, searchKey)
	File.open(getLogFile(logDir), 'r:UTF-8') do |file|
		searchKey.each do |key|
			if file.read.include?(key) then
				# エラー検証文字列に一致したログがあった場合
				writeLog("[実行結果検証]夜間バッチにて右記のエラーが発生しています - " + "【" + key + "】")
				sendMailError("")
			end
		end
	end
end

#=============================================================================
# メイン処理
#=============================================================================
begin
	writeLog("[実行結果検証]処理開始")

	# 前処理
	preProcess()

	# アウトバウンド
	if existLogFile(@logDirOutbound) then
		verifyLogFile(@logDirOutbound, @searchKeyOutbound)
	end
	# インバウンド
	if existLogFile(@logDirInbound) then
		verifyLogFile(@logDirInbound, @searchKeyInbound)
	end
	# SMS
	if existLogFile(@logDirSms) then
		verifyLogFile(@logDirSms, @searchKeySms)
	end

	writeLog("[実行結果検証]処理完了")
rescue Exception => e
	writeLog("[実行結果検証]エラー：実行結果検証バッチ：失敗 - " + e.message)
	writeLog(e.backtrace.join("\n"))
	sendMailError("")
	exit 9
end
