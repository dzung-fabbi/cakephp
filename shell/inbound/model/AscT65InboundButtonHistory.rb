# encoding: UTF-8
#=============================================================================
# Contents   : テンプレート回答履歴モデール
# Author     : Ascend Corp
# Since      : 2016/05/19       1.0
#=============================================================================
load File.join(File.dirname(__FILE__),'../config/AscCommon.rb')
class AscT65InboundButtonHistory
	#=============================================================================
	#　初期設定
	#=============================================================================
	def initialize
		@common = AscCommon.new
		@mysql_cli = @common.connectDB
	end

	#=============================================================================
	#　テンプレート回答履歴追加
	# param : inbound_id
	# 
	#=============================================================================
	def insertInboundButtonHistory(inbound_id)
		query = <<EOS
			insert into t65_inbound_button_histories(inbound_id, question_no, answer_no, yuko_flag, jump_question, answer_content)
			select 
				t25.id,
				t32.question_no,
				t32.answer_no,
				t32.yuko_flag,
				t32.jump_question,
				t32.answer_content
			from t25_inbounds t25 inner join t32_template_buttons t32 on t25.template_id = t32.template_id and t32.del_flag = "N"
			where t25.id = '#{inbound_id}';
EOS
		@mysql_cli.query(query)
	end
end
