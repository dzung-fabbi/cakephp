# encoding: UTF-8
#=============================================================================
# Contents   : 着信リスト履歴モデール
# Author     : Ascend Corp
# Since      : 2016/05/19       1.0
#=============================================================================
load File.join(File.dirname(__FILE__),'../config/AscCommon.rb')
class AscT56InboundListHistory
	#=============================================================================
	#　初期設定
	#=============================================================================
	def initialize
		@common = AscCommon.new
		@mysql_cli = @common.connectDB
	end

	#=============================================================================
	#　着信リスト履歴追加
	# param : inbound_id
	#
	#=============================================================================
	def insertInboundListHistory(inbound_id)
		query = <<EOS
			insert into t56_inbound_list_histories(inbound_id, list_id, list_name, list_test_flag, tel_total, item_main)
			select 
				t25.id,
				t16.id,
				t16.list_name,
				t16.list_test_flag,
				t16.tel_total,
				t16.item_main
			from t25_inbounds t25 inner join t16_inbound_call_lists t16 on t25.list_id = t16.id
			where t25.id = '#{inbound_id}';
EOS
		@mysql_cli.query(query)
	end
end
