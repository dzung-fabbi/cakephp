# encoding: UTF-8
#=============================================================================
# Contents   : サーバーモデール
# Author     : Ascend Corp
# Since      : 2016/04/15        1.0
#=============================================================================
load File.join(File.dirname(__FILE__),'../config/AscCommon.rb')
class AscM02Company
	#=============================================================================
	#　初期設定
	#=============================================================================
	def initialize
		@ConfigCommon = AscCommon.new
		@mysql_cli = @ConfigCommon.connectDB
	end

	#=============================================================================
	#　サーバー情報を取る
	# param : company_id
	# return : dial_interval
	#=============================================================================
	def getDialIntervalByInboundId(company_id)
		dial_interval = "510"
		query = <<EOS
			select
				dial_interval
			from
				m02_companies
			where
				company_id = '#{company_id}' and
				del_flag = 'N';
EOS
		@mysql_cli.query(query).each do | row |
			dial_interval = row[0]
		end
		return dial_interval
	end
	#=============================================================================
	#　サーバー情報を取る
	# param : company_id
	# return : dial_interval
	#=============================================================================
	def getCompanyCode(company_id)
		company_code = ""
		query = <<EOS
			select
				m02.company_code
			from
				m02_companies m02
			join m92_limit_functions m92
			on m02.company_id = m92.company_id
			where
				m02.company_id = '#{company_id}' and
				m02.del_flag = 'N' and 
				m92.del_flag = 'N';
EOS
		@mysql_cli.query(query).each do | row |
			company_code = row[0]
		end
		return company_code
	end
end
