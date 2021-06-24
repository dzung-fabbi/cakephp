# encoding: UTF-8
#=============================================================================
# Contents   : 着信番号履歴モデール
# Author     : Ascend Corp
# Since      : 2016/05/19       1.0
#=============================================================================
load File.join(File.dirname(__FILE__),'../config/AscCommon.rb')
class AscT57InboundTelHistory
	#=============================================================================
	#　初期設定
	#=============================================================================
	def initialize
		@common = AscCommon.new
		@mysql_cli = @common.connectDB
	end

	#=============================================================================
	#　着信番号履歴追加
	# param : inbound_id
	# 
	#=============================================================================
	def insertInboundTelHistory(inbound_id)
		query = <<EOS
			insert into t57_inbound_tel_histories(
				inbound_id, 
				customize1, 
				customize2, 
				customize3, 
				customize4,	
				customize5, 
				customize6, 
				customize7, 
				customize8, 
				customize9, 
				customize10, 
				customize11, 
				muko_flag, 
				muko_modified
			)
			select 
				t25.id,
				t17.customize1,
				t17.customize2,
				t17.customize3,
				t17.customize4,
				t17.customize5,
				t17.customize6,
				t17.customize7,
				t17.customize8,
				t17.customize9,
				t17.customize10,
				t17.customize11,
				t17.muko_flag,
				t17.muko_modified
			from t25_inbounds t25 inner join t17_inbound_tel_lists t17 on t25.list_id = t17.list_id and t17.del_flag = "N"
			where t25.id = '#{inbound_id}';
EOS
		@mysql_cli.query(query)
	end
end
