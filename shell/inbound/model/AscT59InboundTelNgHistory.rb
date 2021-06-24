# encoding: UTF-8
#=============================================================================
# Contents   : テンプレート回答モデール
# Author     : Ascend Corp
# Since      : 2016/04/15        1.0
#=============================================================================
load File.join(File.dirname(__FILE__),'../config/AscCommon.rb')
class AscT59InboundTelNgHistory
	#=============================================================================
	#　初期設定
	#=============================================================================
	def initialize
		@common = AscCommon.new
		@mysql_cli = @common.connectDB
	end

	#=============================================================================
	#　着信拒否番号履歴追加
	# param : inbound_id
	# 
	#=============================================================================
	def insertInboundTelNgHistory(inbound_id)
		query = <<EOS
			insert into t59_inbound_tel_ng_histories(inbound_id, tel_no, memo)
			select 
				t25.id,
				t19.tel_no,
				t19.memo
			from t25_inbounds t25 inner join t19_incoming_ng_tels t19 on t25.list_ng_id = t19.list_ng_id and t19.del_flag = "N"
			where t25.id = '#{inbound_id}';
EOS
		@mysql_cli.query(query)
	end
end
