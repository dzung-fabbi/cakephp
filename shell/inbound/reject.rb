# encoding: UTF-8
#=============================================================================
# Contents   : 着信拒否設定
# Author     : Ascend Corp
# Param      : server_id     サーバーID
#              inbound_id    インバウンドID   
#              tel_str       電話番号(080A,080B,080C...)
#              flag          着信拒否追加(add)・解放(del)
# Since      : 2016/04/15        1.0
#=============================================================================
load File.join(File.dirname(__FILE__),'config/AscCommon.rb')
load File.join(File.dirname(__FILE__),'model/AscM01Server.rb')
load File.join(File.dirname(__FILE__),'controller/In_AscInboundSetup.rb')

begin
	server_id = ARGV[0]
	inbound_id = ARGV[1]
	tel_str = ARGV[2]
	flag = ARGV[3]
	ConfigCommon = AscCommon.new
	ClassInboundSetup = AscInboundSetup.new
	ModelM01Server = AscM01Server.new
	inbound_no = "000000".slice(1..6-inbound_id.to_s.length) + inbound_id.to_s
	remote_path_inbound = ConfigCommon.remotePathInbound + "/" + inbound_no
	if flag == "add"
		cmd = "reject_add"
		reject_file_name = 'reject_add_'+Time.now.strftime("%Y%m%d%H%M%S")+'.txt'
	elsif flag == "del"
		cmd = "reject_del"
		reject_file_name = 'reject_del_'+Time.now.strftime("%Y%m%d%H%M%S")+'.txt'
	end
	reject_file_path = ConfigCommon.localPathInbound + "/" + inbound_no + "/" + reject_file_name
	remote_file_path = ConfigCommon.remotePathInbound + "/" + inbound_no + "/" + reject_file_name
	ConfigCommon.createFile(reject_file_path)
	reject_file = File.open(reject_file_path, 'a:UTF-8')
	tel_str.split(",").each do | row_dial |
		reject_file.puts(NKF::nkf('-Wsm0', row_dial.to_s))
	end
	reject_file.close
	arr_servers = ModelM01Server.getInfoServerByServerId(server_id)
	arr_servers.each do | arr |
		server_ip = arr[1]
		server_port = arr[2]
		server_user = arr[3]
		server_pass = arr[4]
		call_module_port = arr[5]

		options = {}
		options[:password] = server_pass
		unless server_port.blank?
			options[:port] = server_port
		end
		
		Net::SSH.start( server_ip, server_user, options) do | ssh |
			begin
				ssh.sftp.connect do |sftp|
					sftp.upload!(reject_file_path, remote_file_path)
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
		ClassInboundSetup.execReject(server_ip, call_module_port, inbound_id, cmd, remote_file_path)
	end
rescue Exception => e
	puts "error"
	ConfigCommon.writeLog(e.backtrace.join("\n"))
	#writeLog(e.backtrace.join("\n"))
	ConfigCommon.sendMailError('')
	exit 9
end
