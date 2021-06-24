# encoding: UTF-8
#=============================================================================
# Contents   : Sms API情報
# Author     : Ascend Corp
# Since      : 2017/10/03        1.0
#=============================================================================
load File.join(File.dirname(__FILE__),'../config/AscCommon.rb')
class AscM08SmsApiInfo
	#=============================================================================
	#　初期設定
	#=============================================================================
	def initialize
		@ConfigCommon = AscCommon.new
		@mysql_cli = @ConfigCommon.connectDB
	end

	#=============================================================================
	#　Smsアカウント情報を取る
	# param : company_id
	# return : array
	#=============================================================================
	def getSmsAccountInfo(company_id, sms_display_number)
		data = Array.new()
		data = Array.new()
	query = <<EOS
	select
		service_id,
		url,
		group_id,
		user,
		pass,
		display_number,
		api_id
	from
		m08_sms_api_infos
    where
    	company_id = '#{company_id}'
    and
    	display_number = '#{sms_display_number}'
    and
		((role_code = '30' and api_id != '#{$SMS_API_V2_VALUE}')
			or api_id = '#{$SMS_API_V2_VALUE}'
		)
    and
    	del_flag = 'N';
EOS
		@mysql_cli.query(query).each do | row |
			data = data + Array.new(1, row)
		end
		return data
	end
end
