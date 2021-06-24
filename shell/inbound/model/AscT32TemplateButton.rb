# encoding: UTF-8
#=============================================================================
# Contents   : テンプレート回答モデール
# Author     : Ascend Corp
# Since      : 2016/04/15        1.0
#=============================================================================
load File.join(File.dirname(__FILE__),'../config/AscCommon.rb')
class AscT32TemplateButton
	#=============================================================================
	#　初期設定
	#=============================================================================
	def initialize
		@common = AscCommon.new
		@mysql_cli = @common.connectDB
	end

	#=============================================================================
	#　回答番号を取る
	# param : template_id, question_no
	# return : array
	#=============================================================================
	def getAnswerNoByTemplateIdQuestionNo(template_id, question_no)
		data = Array.new()
		query = <<EOS
		select 
			t32.answer_no,
			t32.jump_question
		from
			t32_template_buttons t32
		where
			t32.template_id = '#{template_id}'
				and t32.question_no = '#{question_no}'
				and t32.del_flag = 'N'
		order by t32.question_no asc
EOS
		@mysql_cli.query(query).each do | row |
			data = data + Array.new(1, row)
		end
		return data
	end
end
