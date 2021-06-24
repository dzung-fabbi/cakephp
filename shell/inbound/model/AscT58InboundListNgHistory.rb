# encoding: UTF-8
#=============================================================================
# Contents   : 着信拒否履歴モデール
# Author     : Ascend Corp
# Since      : 2016/04/15        1.0
#=============================================================================
load File.join(File.dirname(__FILE__),'../config/AscCommon.rb')
class AscT58InboundListNgHistory
	#=============================================================================
	#　初期設定
	#=============================================================================
	def initialize
		@common = AscCommon.new
		@mysql_cli = @common.connectDB
	end

	#=============================================================================
	#　着信拒否履歴追加
	# param : inbound_id
	# 
	#=============================================================================
	def insertInboundListNgHistory(inbound_id)
		query = <<EOS
			insert into t58_inbound_list_ng_histories(inbound_id, list_ng_id, list_name, total)
			select 
				t25.id,
				t18.id,
				t18.list_name,
				t18.total
			from t25_inbounds t25 inner join t18_incoming_ng_lists t18 on t25.list_ng_id = t18.id
			where t25.id = '#{inbound_id}';
EOS
		@mysql_cli.query(query)
	end
end
