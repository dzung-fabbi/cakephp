# encoding: UTF-8
#=============================================================================
# Contents   : smsステータス取得
# Author     : Ascend Corp
# Since      : 2017/10/03        1.0
#=============================================================================
load File.join(File.dirname(__FILE__),'config/AscCommon.rb')
load File.join(File.dirname(__FILE__),'controller/In_AscGetInboundSmsStatus.rb')
begin
    ConfigCommon = AscCommon.new
	ClassGetSmsStatus = AscGetInboundSmsStatus.new
	ClassGetSmsStatus.getInboundSmsStatus()
rescue Exception => e
	puts "sms get status error"
	ConfigCommon.writeLog(e.backtrace.join("\n"))
	ConfigCommon.writeLog(e.message)
	ConfigCommon.sendMailError('')
	exit 9
end
