# encoding: UTF-8
#=============================================================================
# Contents   : 再設定
# Author     : Ascend Corp
# Since      : 2016/04/15        1.0
# Step 1 : インバウンドサーバー情報取得
# Step 2 : メッセージインバウンド情報取得
# Step 3 : 拒否リスト再作成・転送（リアルタイム設定ため）
# Step 4 : 再実行
#=============================================================================
load File.join(File.dirname(__FILE__),'config/AscCommon.rb')
load File.join(File.dirname(__FILE__),'model/AscM01Server.rb')
load File.join(File.dirname(__FILE__),'model/AscT25Inbound.rb')
load File.join(File.dirname(__FILE__),'controller/In_AscInboundSetup.rb')
load File.join(File.dirname(__FILE__),'controller/In_AscCreateRejectList.rb')
load File.join(File.dirname(__FILE__),'controller/In_AscSendFolder.rb')

begin
	ConfigCommon = AscCommon.new
	ModelM01Server = AscM01Server.new
	ModelT25Inbound = AscT25Inbound.new
	ClassInboundSetup = AscInboundSetup.new
	ClassCreateRejectList = AscCreateRejectList.new
	ClassSendFolder = AscSendFolder.new
	server_inbound_type = ConfigCommon.getServerInboundType
	ConfigCommon.writeLog("全インバウンド再設定　：　開始")
	#インバウンドサーバー情報取得
	arr_servers = ModelM01Server.getInfoServerByServerType(server_inbound_type)
	arr_servers.each do | arr_server | 
		server_id = arr_server[0]
		server_ip = arr_server[1]
		call_module_port = arr_server[5]
		#メッセージインバウンド情報取得
		arr_inbounds = ModelT25Inbound.getInfoInboundMessageByServerId(server_id)
		arr_inbounds.each do | arr_inbound |
			inbound_id = arr_inbound[0]
			template_id = arr_inbound[1]
			list_id = arr_inbound[2]
			list_ng_id = arr_inbound[3]
			inbound_no = "000000".slice(1..6-inbound_id.to_s.length) + inbound_id.to_s
			#拒否リスト再作成・転送
			file_reject = ConfigCommon.localPathInbound + "/" + inbound_no.to_s + "/inbound_reject_list.txt"
			FileUtils.rm(file_reject)
			ClassCreateRejectList.createRejectList(file_reject, list_ng_id, list_id)
			ClassSendFolder.execSendFile(server_id, inbound_id, "inbound_reject_list.txt")
			#再実行
			ClassInboundSetup.execSetupCallModule(server_ip, call_module_port, inbound_id)
		end
	end
	ConfigCommon.writeLog("全インバウンド再設定　：　終了")
rescue Exception => e
	puts "error"
	ConfigCommon.writeLog(e.backtrace.join("\n"))
	#writeLog(e.backtrace.join("\n"))
	ConfigCommon.sendMailError(inbound_id.to_i)
end
