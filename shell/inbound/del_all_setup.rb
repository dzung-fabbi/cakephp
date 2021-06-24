# encoding: UTF-8
#=============================================================================
# Contents   : 再設定
# Author     : Ascend Corp
# Since      : 2016/04/15        1.0
#=============================================================================
load File.join(File.dirname(__FILE__),'config/AscCommon.rb')
load File.join(File.dirname(__FILE__),'model/AscM01Server.rb')
load File.join(File.dirname(__FILE__),'model/AscT25Inbound.rb')
load File.join(File.dirname(__FILE__),'controller/In_AscInboundSetup.rb')
load File.join(File.dirname(__FILE__),'controller/In_AscGetCsvResult.rb')

begin
	ConfigCommon = AscCommon.new
	ModelM01Server = AscM01Server.new
	ModelT25Inbound = AscT25Inbound.new
	ClassInboundSetup = AscInboundSetup.new
	ClassGetCsvResult = AscGetCsvResult.new
	ConfigCommon.writeLog("全インバウンド解放　：　開始")
	server_inbound_type = ConfigCommon.getServerInboundType
	arr_servers = ModelM01Server.getInfoServerByServerType(server_inbound_type)
	arr_servers.each do | arr_server | 
		server_id = arr_server[0]
		server_ip = arr_server[1]
		call_module_port = arr_server[5]
		arr_inbounds = ModelT25Inbound.getInfoInboundMessageByServerId(server_id)
		arr_inbounds.each do | arr_inbound |
			inbound_id = arr_inbound[0]
			count = 0
			ClassInboundSetup.execStopSchedule(server_ip, call_module_port, inbound_id)
			result = ""
			until result.strip == "RET_TERM"
				count = count + 1
				result = ClassInboundSetup.execGetStatusSchedule(server_ip, call_module_port, inbound_id)
				if (result.strip != "RET_TERM" && result.strip != "RET_ALIVE")  || count > 12
					#raise result
					#send_mail
					result = "RET_TERM"
          ConfigCommon.sendMailError(inbound_id.to_i)
					break
				end
				sleep(5)
			end
			if result.strip == "RET_TERM"
				result = ClassInboundSetup.execKillallSchedule(server_ip, call_module_port, inbound_id)
				if result.strip != "RET_OK"
					#send_mail
          ConfigCommon.sendMailError(inbound_id.to_i)
				end
				result = ClassInboundSetup.execDelSchedule(server_ip, call_module_port, inbound_id)
				if result.strip != "RET_OK"
					#send_mail
          ConfigCommon.sendMailError(inbound_id.to_i)
				end
				result = ClassGetCsvResult.getCsvResultByServerIdInboundId(server_id, inbound_id)
				if result.strip != "RET_OK"
					#send_mail
          ConfigCommon.sendMailError(inbound_id.to_i)
				end
			end
		end
	end
	ConfigCommon.writeLog("全インバウンド解放　：　終了")
rescue Exception => e
	puts "error"
	ConfigCommon.writeLog(e.backtrace.join("\n"))
ConfigCommon.sendMailError(inbound_id.to_i)
end
