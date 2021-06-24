# encoding: UTF-8
#=============================================================================
# Contents   : ログファイル取得
# Author     : Ascend Corp
# Since      : 2016/04/15        1.0
#=============================================================================
load File.join(File.dirname(__FILE__),'config/AscCommon.rb')
load File.join(File.dirname(__FILE__),'controller/In_AscGetCsvResult.rb')

begin
	ConfigCommon = AscCommon.new
	ClassGetCsvResult = AscGetCsvResult.new
	ClassGetCsvResult.getCsvResult()
rescue Exception => e
	puts "error"
	ConfigCommon.writeLog(e.backtrace.join("\n"))
  ConfigCommon.sendMailError('')
	exit 9
end
