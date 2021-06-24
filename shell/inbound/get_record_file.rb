# encoding: UTF-8
#=============================================================================
# Contents   : ログファイル取得
# Author     : Ascend Corp
# Since      : 2016/04/15        1.0
#=============================================================================
load File.join(File.dirname(__FILE__),'config/AscCommon.rb')
load File.join(File.dirname(__FILE__),'controller/In_AscGetRecordFile.rb')

begin
	ConfigCommon = AscCommon.new
	ClassGetRecordFile = AscGetRecordFile.new
	ConfigCommon.writeLog("【録音ファイル取得】開始")
	ClassGetRecordFile.getRecordFile()
	ConfigCommon.writeLog("【録音ファイル取得】終了")
rescue Exception => e
	puts "error"
	ConfigCommon.writeLog(e.backtrace.join("\n"))
  ConfigCommon.sendMailError('')
	exit 9
end
