# encoding: UTF-8
#=============================================================================
# Contents   : テンプレート履歴モデール
# Author     : Ascend Corp
# Since      : 2016/05/19        1.0
#=============================================================================
load File.join(File.dirname(__FILE__),'../config/AscCommon.rb')
class AscT63InboundTemplateHistory
	#=============================================================================
	#　初期設定
	#=============================================================================
	def initialize
		@common = AscCommon.new
		@mysql_cli = @common.connectDB
	end

	#=============================================================================
	#　テンプレート履歴追加
	# param : inbound_id
	#
	#=============================================================================
	def insertInboundTemplateHistory(inbound_id)
		query = <<EOS
			insert into t63_inbound_template_histories(inbound_id, template_id, template_name, question_total, description)
			select 
				t25.id,
				t30.id,
				t30.template_name,
				t30.question_total,
				t30.description				
			from t25_inbounds t25 inner join t30_templates t30 on t25.template_id = t30.id and t30.del_flag = "N"
			where t25.id = '#{inbound_id}';
EOS
		@mysql_cli.query(query)
	end
end
