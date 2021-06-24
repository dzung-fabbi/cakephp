# encoding: UTF-8
#=============================================================================
# Contents   : ログファイル取得
# Author     : Ascend Corp
# Since      : 2016/04/15        1.0
#=============================================================================
load File.join(File.dirname(__FILE__),'config/AscCommon.rb')
load File.join(File.dirname(__FILE__),'controller/In_AscGetFaxStatus.rb')
begin
    ConfigCommon = AscCommon.new
	ClassGetFaxStatus = AscGetFaxStatus.new
	ClassGetFaxStatus.getFaxStatus()
rescue Exception => e
	puts "fax get error"
	ConfigCommon.writeLog(e.backtrace.join("\n"))
	ConfigCommon.sendMailError('')
	exit 9
end
