# encoding: UTF-8
#=============================================================================
# Contents   : 転送ファイル
# Author     : Ascend Corp
# Since      : 2016/04/14        1.0
#=============================================================================

load File.join(File.dirname(__FILE__),'../config/AscCommon.rb')
load File.join(File.dirname(__FILE__),'../model/AscM01Server.rb')
load File.join(File.dirname(__FILE__),'../model/AscT25Inbound.rb')

class AscGetRecordFile
	#=============================================================================
	#　初期設定
	#
	#=============================================================================
	def initialize
		@ConfigCommon = AscCommon.new
		@ModelM01Server = AscM01Server.new
		@ModelT25Inbound = AscT25Inbound.new
		@date_now = Time.now.strftime("%Y%m%d")
		@retried = 0
		@limit = 5
	end

	###########################################
	# 録音ファイル取得
	# 
	#
	###########################################
	def getRecordFile()
		server_inbound_type = @ConfigCommon.getServerInboundType
		arr_servers = @ModelM01Server.getInfoServerByServerType(server_inbound_type)
		arr_servers.each do | arr_server |
			server_id = arr_server[0]
			server_ip = arr_server[1]
			server_port = arr_server[2]
			server_user = arr_server[3]
			server_pass = arr_server[4]

			options = {}
			options[:password] = server_pass
			unless server_port.blank?
				options[:port] = server_port
			end
			arr_inbounds = @ModelT25Inbound.getInfoInboundRecordByServerId(server_id)
			if arr_inbounds.length > 0
				Net::SSH.start( server_ip, server_user, options) do |ssh|
					arr_inbounds.each do | arr_inbound |
						inbound_id = arr_inbound[0]
						inbound_no = "000000".slice(1..6-inbound_id.to_s.length) + inbound_id.to_s
						local_inbound_path_rec = @ConfigCommon.localPathInbound + "/" + inbound_no + "/rec"
						remote_inbound_path_rec = @ConfigCommon.remotePathInbound + "/" + inbound_no + "/rec"
						@ConfigCommon.writeLog("【" + inbound_id + "】録音ファイル取得　：　開始")
						#backupフォルダ作成
						ssh.exec!("mkdir " + remote_inbound_path_rec + "/rec" + @date_now)
						#ファイルをダウンロード
						if server_port.blank?
							system("rsync -avz -e " + server_user + "@" + server_ip + ":" + remote_inbound_path_rec + "/*.pcm" + " " + local_inbound_path_rec)
						else
							system("rsync -avz -e 'ssh -p " + server_port + "' " + server_user + "@" + server_ip + ":" + remote_inbound_path_rec + "/*" + " " + local_inbound_path_rec)
						end
						#全録音ファイルがbackupフォルダに移行
						ssh.exec!("mv " + remote_inbound_path_rec + "/*.pcm " + remote_inbound_path_rec + "/rec" + @date_now + "/")
						@ConfigCommon.writeLog("【" + inbound_id + "】録音ファイル取得　：　終了")
						@ConfigCommon.writeLog("【" + inbound_id + "】録音ファイル変換　：　開始")
						Dir.entries(local_inbound_path_rec).each do | e |
							if e != "." && e != ".."
								pcm_record_file = local_inbound_path_rec + "/" + e
								filetype = File.extname(e)
								if filetype == ".pcm"
									filename = File.basename(e, ".*")									
									wav_record_file = local_inbound_path_rec + "/" + filename + ".wav"
									system("ffmpeg -f s16le -ar 8000 -ac 1 -i " + pcm_record_file + " -ar 8000 -ac 1 " + wav_record_file)
									FileUtils.rm_rf(pcm_record_file)
								end
							end
						end
						@ConfigCommon.writeLog("【" + inbound_id + "】録音ファイル変換　：　終了")
						@ModelT25Inbound.updateCronRecordFlag(inbound_id)
					end
				end
			end
		end
	end
end