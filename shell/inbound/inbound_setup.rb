# encoding: UTF-8
#=============================================================================
# Contents   : 設定
# Author     : Ascend Corp
# Param      : server_id             サーバーID
#              inbound_id            インバウンドID   
#              inbound_id_prev       元々インバウンドID
#              prefix                外線番号のプレフィクス
#              status                ステータス設定
#              inbound_prev_status   元々インバウンドステータス
# Since      : 2016/04/15        1.0
#=============================================================================
load File.join(File.dirname(__FILE__),'config/AscCommon.rb')
load File.join(File.dirname(__FILE__),'model/AscM01Server.rb')
load File.join(File.dirname(__FILE__),'model/AscT25Inbound.rb')
load File.join(File.dirname(__FILE__),'controller/In_AscInboundSetup.rb')
load File.join(File.dirname(__FILE__),'controller/In_AscGetCsvResult.rb')
load File.join(File.dirname(__FILE__),'controller/In_AscGetTransPort.rb')

begin
	server_id = ARGV[0]
	inbound_id = ARGV[1]
	inbound_prev_id = ARGV[2]
	prefix = ARGV[3]
	status = ARGV[4] 
	inbound_prev_status = ARGV[5]
	ConfigCommon = AscCommon.new
	ModelM01Server = AscM01Server.new
	ModelT25Inbound = AscT25Inbound.new
	ClassInboundSetup = AscInboundSetup.new
	ClassGetCsvResult = AscGetCsvResult.new
	ClassAscGetTransPort = AscGetTransPort.new
	#メール
  to = ConfigCommon.getListMail()
  from = "astar_report@ascend-corp.co.jp"
  	
	ConfigCommon.writeLog("[#{inbound_id}]コールモジュール設定　：　開始")
	arr_servers = ModelM01Server.getInfoServerByServerId(server_id)
	arr_servers.each do | arr |
		server_ip = arr[1]
		server_port = arr[2]
		server_user = arr[3]
		server_pass = arr[4]
		call_module_port = arr[5]
		root_user = arr[6]
		root_pass = arr[7]
		status_flag = FALSE
		#元々設定解放・最後ログファイル取得
		if !(inbound_prev_id.blank?) && inbound_prev_status == ConfigCommon.getStatusInboundMessage
			#停止
			#result = ClassInboundSetup.execStopSchedule(server_ip, call_module_port, inbound_prev_id)
			#if result.strip != "RET_OK"
			#	raise result
			#end
			#ステータスチェック
			#result = ""
			#until result.strip == "RET_TERM"
			#	result = ClassInboundSetup.execGetStatusSchedule(server_ip, call_module_port, inbound_prev_id)
			#	if result.strip != "RET_TERM" and result.strip != "RET_ALIVE"
			#		raise result
			#		break
			#	end
			#	sleep(5)
			#end
			#終了までに解放
			result = ClassInboundSetup.execKillallSchedule(server_ip, call_module_port, inbound_prev_id)     
			if result.strip != "RET_OK"
				#元々スケジュール複製
				if !(inbound_prev_id.blank?) && inbound_prev_status == ConfigCommon.getStatusInboundMessage
					ClassInboundSetup.execSetupCallModule(server_ip, call_module_port, inbound_prev_id)
				end
				raise result
			end
			
			result = ClassInboundSetup.execDelSchedule(server_ip, call_module_port, inbound_prev_id)
			if result.strip != "RET_OK"
				#元々スケジュール複製
				if !(inbound_prev_id.blank?) && inbound_prev_status == ConfigCommon.getStatusInboundMessage
					ClassInboundSetup.execSetupCallModule(server_ip, call_module_port, inbound_prev_id)
				end
				raise result
			end      
			#最後CSVログファイル取得
			ClassGetCsvResult.getCsvResultByServerIdInboundId(server_id, inbound_prev_id)
		end

		#コールモジュール設定
		if status == ConfigCommon.getStatusInboundMessage
			result = ClassInboundSetup.execSetupCallModule(server_ip, call_module_port, inbound_id)
			#エラー発生の場合
			if result.strip != "RET_OK"
				#エラースケジュール解放
				ClassInboundSetup.execDelSchedule(server_ip, call_module_port, inbound_id)
				#元々スケジュール複製
				if !(inbound_prev_id.blank?) && inbound_prev_status == ConfigCommon.getStatusInboundMessage
					ClassInboundSetup.execSetupCallModule(server_ip, call_module_port, inbound_prev_id)
				end
				raise result
			end
		end

		#busyからメッセージに設定またはメッセージからbusyに設定の場合Asteriskのextension.cnf変更必要
		if !(inbound_prev_id.blank?) && status != inbound_prev_status
			status_flag = TRUE
		end
		arr_internal_prev = ClassAscGetTransPort.getTransPort(inbound_prev_id)
		arr_internal = ClassAscGetTransPort.getTransPort(inbound_id)
		ClassInboundSetup.execSetupAsterisk(server_ip, root_user, root_pass, server_port, prefix, status_flag, status, arr_internal_prev, arr_internal)
		
	end
	ConfigCommon.writeLog("[#{inbound_id}]コールモジュール設定　：　終了")
rescue Exception => e
	puts "error"
	ConfigCommon.writeLog(e.backtrace.join("\n"))
	#writeLog(e.backtrace.join("\n"))
	ConfigCommon.sendMailError(inbound_id.to_i)
	exit 9
end
