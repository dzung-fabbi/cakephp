# encoding: UTF-8
#=============================================================================
# Contents   : サーバーモデール
# Author     : Ascend Corp
# Since      : 2016/04/15        1.0
#=============================================================================
load File.join(File.dirname(__FILE__),'../config/AscCommon.rb')
class AscM07ServerExternal
	#=============================================================================
	#　初期設定
	#=============================================================================
	def initialize
		@ConfigCommon = AscCommon.new
		@mysql_cli = @ConfigCommon.connectDB
	end

	#=============================================================================
	#　サーバー情報を取る
	# param : external
	# return : array
	#=============================================================================
	def getInProcNumByExternal(external)
		in_proc_num = "0"
		query = <<EOS
			select
				in_proc_num
			from
				m07_server_externals
			where
				external_number = '#{external}' and
				del_flag = 'N';
EOS
		@mysql_cli.query(query).each do | row |
			in_proc_num = row[0]
		end
		return in_proc_num
	end
	#=============================================================================
	#　port情報を取る
	# param : external
	# return : array
	#=============================================================================
	def getPortByExternal(external)
		enosip_port = ""
		query = <<EOS
			select
				enosip_port
			from
				m07_server_externals
			where
				external_number = '#{external}' and
				del_flag = 'N';
EOS
		@mysql_cli.query(query).each do | row |
			enosip_port = row[0]
		end
		return enosip_port
	end

	#=============================================================================
	#　電話番号より管理会社IDと管理店舗IDを紐づける
	# param : external
	# return : array
	#=============================================================================
	def getBukkenInfoByExternal(external)
		data=Array.new()
		enosip_port = ""
		query = <<EOS
			select
				bukken_company_id,
				bukken_shop_id
			from
				m07_server_externals
			where
				external_number = '#{external}' and
				del_flag = 'N';
EOS
		@mysql_cli.query(query).each do | row |
			data = data + Array.new(1, row)
		end
		return data
	end
end
