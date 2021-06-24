# encoding: UTF-8
#=============================================================================
# Contents   : 転送ファイル
# Author     : Ascend Corp
# Since      : 2016/04/14        1.0
#=============================================================================

load File.join(File.dirname(__FILE__),'../config/AscCommon.rb')
load File.join(File.dirname(__FILE__),'../model/AscM01Server.rb')

class AscInboundSetup
	#=============================================================================
	#　初期設定
	#=============================================================================
	def initialize
		@ConfigCommon = AscCommon.new
		@ModelM01Server = AscM01Server.new
		@call_module_path = @ConfigCommon.callModulePathInbound
		@remote_path = @ConfigCommon.remotePathInbound
		@retried = 0
		@limit = 5
	end

	###########################################
	# コールモジュール側設定
	# param : server_ip, call_module_port, inbound_id
	#
	###########################################
	def execSetupCallModule(server_ip, call_module_port, inbound_id)
		inbound_no = "000000".slice(1..6-inbound_id.to_s.length) + inbound_id.to_s
		#割り当て
		command = @call_module_path + " -h " + server_ip + " -p "+ call_module_port +" -s " + inbound_no + " -c addschedule " + @remote_path + "/" + inbound_no.to_s + "/autopoll.conf"
		result = `#{command}` 
		@ConfigCommon.writeLog("実行コマンド : " + command)
		@ConfigCommon.writeLog("結果コード : " + result)
		if result.strip != "RET_OK"
			return result
		end
		#チェックデータ
		command = @call_module_path + " -h " + server_ip + " -p "+ call_module_port +" -s " + inbound_no + " -c checkdata"
		result = `#{command}` 
		@ConfigCommon.writeLog("実行コマンド : " + command)
		@ConfigCommon.writeLog("結果コード : " + result)
		if result.strip != "RET_OK"
			return result
		end
		sleep(5)
		#実行
		command = @call_module_path + " -h " + server_ip + " -p "+ call_module_port +" -s " + inbound_no + " -c autocall run"
		result = `#{command}` 
		@ConfigCommon.writeLog("実行コマンド : " + command)
		@ConfigCommon.writeLog("結果コード : " + result)
		return result
	end

	###########################################
	# Asterisk側設定
	# param : server_ip, 
	#         root_user, 
	#         root_pass, 
	#         server_port, 
	#         prefix : 外線番号のprefix, 
	#         status_flag : TRUE or FALSE busyからメッセージに設定またはメッセージからbusyに設定の場合Asteriskのextension.cnf変更必要
	#         status : busyまたはinbound
	#         arr_internal_prev : 前転送ポート
	#         arr_internal : 転送ポート
	# step 1 : connect asterisk server
	# step 2 : edit extension config file 
	# step 3 : reload asterisk
	###########################################
	def execSetupAsterisk(server_ip, root_user, root_pass, server_port, prefix, status_flag, status, arr_internal_prev, arr_internal)
		#extensions.confのファイルパース
		extensions_conf_path = @ConfigCommon.getExtensionsConfPath
		options = {}
		options[:password] = root_pass
		unless server_port.blank?
			options[:port] = server_port
		end
		begin
			Net::SSH.start( server_ip, root_user, options) do | ssh |
				if status_flag
					if status == @ConfigCommon.getStatusInboundMessage
						ssh.exec!('sed -i "s/INCOMING_MODE' + prefix + '=busy/INCOMING_MODE' + prefix + '=inbounds/g" ' + extensions_conf_path)
						@ConfigCommon.writeLog('実行コマンド　：　sed -i "s/INCOMING_MODE' + prefix + '=busy/INCOMING_MODE' + prefix + '=inbounds/g" ' + extensions_conf_path)
					elsif status == @ConfigCommon.getStatusInboundBusy
						ssh.exec!('sed -i "s/INCOMING_MODE' + prefix + '=inbounds/INCOMING_MODE' + prefix + '=busy/g" ' + extensions_conf_path)
						@ConfigCommon.writeLog('実行コマンド　：　sed -i "s/INCOMING_MODE' + prefix + '=inbounds/INCOMING_MODE' + prefix + '=busy/g" ' + extensions_conf_path)
					end
				end

				arr_internal_prev.each do | internal_number |
					ssh.exec!('sed -i "s/;same => n,Dial(SIP\/' + internal_number.to_s + ',\${CALLINGWAIT},t)/same => n,Dial(SIP\/' + internal_number.to_s + ',\${CALLINGWAIT},t)/g" ' + extensions_conf_path)
					@ConfigCommon.writeLog('実行コマンド　： sed -i "s/;same => n,Dial(SIP\/' + internal_number.to_s + ',\${CALLINGWAIT},t)/same => n,Dial(SIP\/' + internal_number.to_s + ',\${CALLINGWAIT},t)/g" ' + extensions_conf_path)
				end

				arr_internal.each do | internal_number |
					ssh.exec!('sed -i "s/same => n,Dial(SIP\/' + internal_number.to_s + ',\${CALLINGWAIT},t)/;same => n,Dial(SIP\/' + internal_number.to_s + ',\${CALLINGWAIT},t)/g" ' + extensions_conf_path)
					@ConfigCommon.writeLog('実行コマンド　： sed -i "s/same => n,Dial(SIP\/' + internal_number.to_s + ',\${CALLINGWAIT},t)/;same => n,Dial(SIP\/' + internal_number.to_s + ',\${CALLINGWAIT},t)/g" ' + extensions_conf_path)
				end

				if status_flag || arr_internal_prev.length > 0 || arr_internal.length > 0
					@ConfigCommon.writeLog("extensions変更 : OK")
					ssh.exec!("asterisk -rx 'dialplan reload'")
					@ConfigCommon.writeLog("asteriskリロード : OK")
				end
			end
		rescue Timeout::Error =>e
			if @retried < @limit
				@retried = @retried + 1
				sleep(30)
				retry
			else
				raise e.message
			end
		end
	end

	###########################################
	# スケジュール停止
	# param : server_ip, call_module_port, inbound_id
	# exec command autocall term
	#
	###########################################
	def execStopSchedule(server_ip, call_module_port, inbound_id)
		inbound_no = "000000".slice(1..6-inbound_id.to_s.length) + inbound_id.to_s
		command = @call_module_path + " -h " + server_ip + " -p "+ call_module_port +" -s " + inbound_no + " -c autocall term"
		result = `#{command}` 
		@ConfigCommon.writeLog("実行コマンド : " + command)
		@ConfigCommon.writeLog("結果コード : " + result)
		return result	
	end

	###########################################
	# ステータス取得
	# param : server_ip, call_module_port, inbound_id
	# exec command getstatus
	#
	###########################################

	def execGetStatusSchedule(server_ip, call_module_port, inbound_id)
		inbound_no = "000000".slice(1..6-inbound_id.to_s.length) + inbound_id.to_s
		command = @call_module_path + " -h " + server_ip + " -p "+ call_module_port +" -s " + inbound_no + " -c getstatus"
		result = `#{command}` 
		@ConfigCommon.writeLog("実行コマンド : " + command)
		@ConfigCommon.writeLog("結果コード : " + result)
		return result
	end

	###########################################
	# スケジュールkillall
	# param : server_ip, call_module_port, inbound_id
	# exec command killall schedule
	#
	###########################################
	def execKillallSchedule(server_ip, call_module_port, inbound_id)
		inbound_no = "000000".slice(1..6-inbound_id.to_s.length) + inbound_id.to_s
		command = @call_module_path + " -h " + server_ip + " -p "+ call_module_port +" -s " + inbound_no + " -c killall"
		result = `#{command}` 
		@ConfigCommon.writeLog("実行コマンド : " + command)
		@ConfigCommon.writeLog("結果コード : " + result)
		return result
	end

	###########################################
	# スケジュール解放
	# param : server_ip, call_module_port, inbound_id
	# exec command delschedule
	#
	###########################################
	def execDelSchedule(server_ip, call_module_port, inbound_id)
		inbound_no = "000000".slice(1..6-inbound_id.to_s.length) + inbound_id.to_s
		command = @call_module_path + " -h " + server_ip + " -p "+ call_module_port +" -s " + inbound_no + " -c delschedule"
		result = `#{command}` 
		@ConfigCommon.writeLog("実行コマンド : " + command)
		@ConfigCommon.writeLog("結果コード : " + result)
		return result
	end

	###########################################
	# 着信拒否リアルタイム反映
	# param : server_ip, call_module_port, inbound_id, cmd, file_path
	# cmd - reject add or reject del
	#
	###########################################
	def execReject(server_ip, call_module_port, inbound_id, cmd, file_path)
		inbound_no = "000000".slice(1..6-inbound_id.to_s.length) + inbound_id.to_s
		command = @call_module_path + " -h " + server_ip + " -p "+ call_module_port +" -s " + inbound_no + " -c " + cmd + " " + file_path
		result = `#{command}` 
		@ConfigCommon.writeLog("実行コマンド : " + command)
		@ConfigCommon.writeLog("結果コード : " + result)
		return result
	end

end