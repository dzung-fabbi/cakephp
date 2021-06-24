# encoding: UTF-8
#=============================================================================
# Contents   : 転送ファイル
# Author     : Ascend Corp
# Since      : 2016/04/14        1.0
#=============================================================================

load File.join(File.dirname(__FILE__),'../config/AscCommon.rb')
load File.join(File.dirname(__FILE__),'../model/AscM01Server.rb')

class AscSendFolder
	#=============================================================================
	#　初期設定
	#
	#=============================================================================
	def initialize
		@ConfigCommon = AscCommon.new
		@ModelM01Server = AscM01Server.new
		@retried = 0
		@limit = 5
	end

	###########################################
	# フォルダ転送
	# param : server_id, inbound_id
	#
	###########################################
	def execSendFolder(server_id, inbound_id)
		inbound_no = "000000".slice(1..6-inbound_id.to_s.length) + inbound_id.to_s
		local_path_inbound = @ConfigCommon.localPathInbound + "/" + inbound_no
		remote_path_inbound = @ConfigCommon.remotePathInbound + "/" + inbound_no
		arr_server_info = @ModelM01Server.getInfoServerByServerId(server_id)
		arr_server_info.each do | row | 
			server_ip = row[1]
			server_port = row[2]
			server_user = row[3]
			server_pass = row[4]

			options = {}
			options[:password] = server_pass
			unless server_port.blank?
				options[:port] = server_port
			end
			Net::SSH.start( server_ip, server_user, options) do | ssh |
				begin
					ssh.sftp.connect do |sftp|
						sftp.mkdir! remote_path_inbound
						sftp.upload!(local_path_inbound, remote_path_inbound)
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
		end
	end

	###########################################
	# ファイル転送
	# param : server_id, inbound_id, file_name
	#
	###########################################
	def execSendFile(server_id, inbound_id, file_name)
		inbound_no = "000000".slice(1..6-inbound_id.to_s.length) + inbound_id.to_s
		local_path_file = @ConfigCommon.localPathInbound + "/" + inbound_no + "/" + file_name
		remote_path_file = @ConfigCommon.remotePathInbound + "/" + inbound_no + "/" + file_name
		arr_server_info = @ModelM01Server.getInfoServerByServerId(server_id)
		arr_server_info.each do | row | 
			server_ip = row[1]
			server_port = row[2]
			server_user = row[3]
			server_pass = row[4]

			options = {}
			options[:password] = server_pass
			unless server_port.blank?
				options[:port] = server_port
			end
			Net::SSH.start( server_ip, server_user, options) do | ssh |
				begin
					ssh.sftp.connect do |sftp|
						sftp.upload!(local_path_file, remote_path_file)
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
		end
	end
end