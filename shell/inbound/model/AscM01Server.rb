# encoding: UTF-8
#=============================================================================
# Contents   : サーバーモデール
# Author     : Ascend Corp
# Since      : 2016/04/15        1.0
#=============================================================================
load File.join(File.dirname(__FILE__),'../config/AscCommon.rb')
class AscM01Server
	#=============================================================================
	#　初期設定
	#=============================================================================
	def initialize
		@ConfigCommon = AscCommon.new
		@mysql_cli = @ConfigCommon.connectDB
	end

	#=============================================================================
	#　サーバー情報を取る
	# param : server_id
	# return : array
	#=============================================================================
	def getInfoServerByServerId(server_id)
		data = Array.new()
		query = <<EOS
			select
				server_id,
				server_ip,
				server_port,
				username,
				password,
				call_module_port,
				root_user,
				root_pass
			from
				m01_servers
			where
				server_id = '#{server_id}' and
				del_flag = 'N';
EOS
		@mysql_cli.query(query).each do | row |
			data = data + Array.new(1, row)
		end
		return data
	end

	#=============================================================================
	#　サーバー情報を取る
	# param : server_type
	# return : array
	#=============================================================================
	def getInfoServerByServerType(server_type)
		data = Array.new()
		query = <<EOS
			select 
				server_id,
				server_ip,
				server_port,
				username,
				password,
				call_module_port
			from
				m01_servers
			where
				server_type = '#{server_type}' and
				del_flag = 'N';
EOS
		@mysql_cli.query(query).each do | row |
			data = data + Array.new(1, row)
		end
		return data
	end
end
