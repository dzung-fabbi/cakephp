# encoding: UTF-8
#=============================================================================
# Contents   : テンプレート質問モデール
# Author     : Ascend Corp
# Since      : 2016/04/15        1.0
#=============================================================================
load File.join(File.dirname(__FILE__),'../config/AscCommon.rb')
class AscT31TemplateQuestion
	#=============================================================================
	#　初期設定
	#=============================================================================
	def initialize
		@common = AscCommon.new
		@mysql_cli = @common.connectDB
	end

	#=============================================================================
	#　質問NO・回答番号を取る
	# param : template_id
	# return : array
	#=============================================================================
	def getDataAns(template_id)
		data = Array.new()
		query = <<EOS
		select 
			t31.question_no, 
			t31.question_type, 
			GROUP_CONCAT(
				CASE
					WHEN t32.answer_no = '51' THEN '\\\\#'
					WHEN t32.answer_no = '52' THEN '*'
					ELSE t32.answer_no
				END
				order by t32.answer_no asc
			),
			t31.recheck_flag,
			t31.recheck_button_next
		from
			t31_template_questions t31
				left join
			t32_template_buttons t32 ON t31.template_id = t32.template_id
				and t31.question_no = t32.question_no
				and t32.yuko_flag = '1'
				and t32.del_flag = 'N'
		where
			t31.template_id = '#{template_id}'
				and t31.del_flag = 'N'
		group by t31.question_no
		order by t31.question_no asc
EOS
		@mysql_cli.query(query).each do | row |
			data = data + Array.new(1, row)
		end
		return data
	end

	#=============================================================================
	#　テンプレートの認証項目を取る（認証セクションが複数ある可能性）
	# param : template_id
	# return : array
	# 例 :   ユーザーコード,金額,生年月日
	#
	# auth_match_flag : 認証照合フラグ - 0 : なし, 1 : あり
	#=============================================================================
	def getAuthItemByTemplateId(template_id)
		data = Array.new()
		ques_auth_code = @common.getQuesAuthCode
		ques_auth_character_code = @common.getQuesAuthCharacterCode
		query = <<EOS
			select 
    			t31.auth_item
			from
			    t31_template_questions t31
			where
			    t31.template_id = '#{template_id}'
			        and t31.question_type in ('#{ques_auth_code}', '#{ques_auth_character_code}')
			        and t31.auth_match_flag = 0
			        and t31.del_flag = 'N'
			order by 
				t31.question_no
EOS
		@mysql_cli.query(query).each do | row |
			data = data + Array.new(1, row)
		end
		return data
	end

	#=============================================================================
	#　テンプレートの認証照合項目を取る(認証照合セクションが最大1個のみあります)
	# param : template_id
	# return : string
	#
	# auth_match_flag : 認証照合フラグ - 0 : なし, 1 : あり
	#=============================================================================
	def getAuthMatchItemByTemplateId(template_id)
		ques_auth_character_code = @common.getQuesAuthCharacterCode
		match_item = ""
		query = <<EOS
			select 
    			t31.auth_item
			from
			    t31_template_questions t31
			where
			    t31.template_id = '#{template_id}'
			        and t31.question_type = '#{ques_auth_character_code}'
			        and t31.auth_match_flag = 1
			        and t31.del_flag = 'N'
			order by 
				t31.question_no
EOS
		@mysql_cli.query(query).each do | row |
			match_item = row[0]
		end
		return match_item
	end

	#=============================================================================
	#　質問情報を取る
	# param : template_id
	# return : array
	#=============================================================================
	def getQuestionByTemplateId(template_id)
		data = Array.new()
		query = <<EOS
					select 
						t31.question_no,
						t31.question_type,
						t31.question_title,
						t31.question_yuko,
						t31.jump_question,
						t31.audio_type,
						t31.audio_id,
						t31.audio_content,
						t31.question_repeat,
						t31.auth_match_flag,
						t31.auth_item,
						t31.second_record,
						t31.yuko_button_record,
						t31.digit,
						t31.trans_tel,
						t31.trans_seat_num,
						t31.trans_empty_seat_flag,
						t31.trans_timeout_audio_type,
						t31.trans_timeout_audio_id,
						t31.trans_timeout_audio_content,
						t31.trans_timeout,
						t31.recheck_flag,
						t31.recheck_audio_type,
						t31.recheck_audio_id,
						t31.recheck_audio_content,
						t31.recheck_button_next,
						t31.bukken_audio_type,
						t31.bukken_audio_id,
						t31.bukken_audio_content,
						t31.bukken_answer_no,
						t31.bukken_diagram_audio_type,
						t31.bukken_diagram_audio_id,
						t31.bukken_diagram_audio_content,
						t31.bukken_diagram_answer_no,
						t31.bukken_cont_audio_type,
						t31.bukken_cont_audio_id,
						t31.bukken_cont_audio_content,
						t31.square_audio_type,
						t31.square_audio_id,
						t31.square_audio_name,
						t31.square_audio_content,
						t31.square_digit,
						t31.sms_display_number,
						t31.sms_content,
						t31.sms_error_audio_type,
						t31.sms_error_audio_id,
						t31.sms_error_audio_content
					from
						t31_template_questions t31 
					where
						t31.template_id = '#{template_id}' and
						t31.del_flag = 'N'
					order by t31.question_no;
EOS
		@mysql_cli.query(query).each do | row |
			data = data + Array.new(1, row)
		end
		return data
	end

	#=============================================================================
	#　テンプレートの認証項目を取る（認証セクションが複数ある可能性）
	# param : template_id
	# return : int
	#
	# auth_match_flag : 認証照合フラグ - 0 : なし, 1 : あり
	# no : 0 - 電話番号, 1 - 認証照合項目, 2から - 認証項目
	#=============================================================================
	def getAuthItemNoByTemplateIdAuthItem(template_id, item)
		no = 2
		ques_auth_code = @common.getQuesAuthCode
		ques_auth_character_code = @common.getQuesAuthCharacterCode
		query = <<EOS
			select 
    			t31.auth_item
			from
			    t31_template_questions t31
			where
			    t31.template_id = '#{template_id}'
			        and t31.question_type in ('#{ques_auth_code}', '#{ques_auth_character_code}')
			        and t31.auth_match_flag = 0
			        and t31.del_flag = 'N'
			order by 
				t31.question_no
EOS
		@mysql_cli.query(query).each do | row |
			auth_item = row[0]
			if item == auth_item
				break
			else
				no = no + 1
			end
		end
		return no
	end

	#=============================================================================
	#　転送質問情報を取る
	# param : template_id
	# return : array
	#=============================================================================
	def getQuestionTransByTemplateId(template_id)
		ques_trans_code = @common.getQuesTransCode
		data=Array.new()
		query = <<EOS
			select 
				t31.trans_tel,
				t31.trans_seat_num,
				t31.trans_empty_seat_flag,
				t31.trans_timeout,
				t31.trans_timeout_audio_id,
				t31.trans_timeout_audio_type,
				t31.trans_timeout_audio_content,
				t31.yuko_button_record
			from
				t31_template_questions t31
			where
				t31.template_id = '#{template_id}'
				and t31.question_type = '#{ques_trans_code}'
				and t31.del_flag = 'N'
EOS
		@mysql_cli.query(query).each do | row |
			data = data + Array.new(1, row)
		end
		return data
	end
	#=============================================================================
	#　物件番号入力・FAX送信セクション存在チェック
	# param : template_id
	# return : array
	#=============================================================================
	def checkBukkenByTemplateId(template_id)
		ques_fax = @common.getQuesFaxCode
		ques_property = @common.getQuesPropertyCode
		bukken_flag = false
		data=Array.new()
		query = <<EOS
			select 
				t31.question_no
			from
				t31_template_questions t31
			where
				t31.template_id = '#{template_id}'
				and (t31.question_type = '#{ques_fax}' or
					t31.question_type = '#{ques_property}' )
				and t31.del_flag = 'N'
EOS
		@mysql_cli.query(query).each do | row |
			bukken_flag = true
		end
		return bukken_flag
	end

	#=============================================================================
	#　物件入力（賃料、平米）セクション存在チェック
	# param : template_id
	# return : array
	#=============================================================================
	def checkQuesProPertyByTemplateId(template_id)
		ques_property = @common.getQuesPropertySearchCode
		bukken_flag = false
		data=Array.new()
		query = <<EOS
			select 
				t31.question_no
			from
				t31_template_questions t31
			where
				t31.template_id = '#{template_id}'
				and t31.question_type = '#{ques_property}'
				and t31.del_flag = 'N'
EOS
		@mysql_cli.query(query).each do | row |
			bukken_flag = true
			break
		end
		return bukken_flag
	end

	def hasSmsQues(template_id)
		ques_inbound_sms = @common.getQuesInboundSmsCode
		ques_inbound_sms_input = @common.getQuesInboundSmsInputCode
		data = Array.new()
		query = <<EOS
		select
			count(t31.id)
		from
			t31_template_questions t31
	    where
	    	t31.template_id = '#{template_id}' and
			t31.question_type in('#{ques_inbound_sms}', '#{ques_inbound_sms_input}') and
	    	t31.del_flag = 'N'
EOS
		@mysql_cli.query(query).each do | row |
			data = data + Array.new(1, row)
		end
		count = "0"
		data.each do | row |
			count = row[0]
		end
		if count == "0"
			return false
		else
			return true
		end
	end
	#=============================================================================
	#　SMS質問情報を取る
	# param : template_id
	# return : array
	#=============================================================================
	def getSmsDisplayNumber(template_id)
		ques_inbound_sms = @common.getQuesInboundSmsCode
		ques_inbound_sms_input = @common.getQuesInboundSmsInputCode
		query = <<EOS
					select
						t31.sms_display_number,
						t31.yuko_button_record
					from
						t31_template_questions t31
					where
						t31.template_id = '#{template_id}'
					and
						t31.question_type in('#{ques_inbound_sms}', '#{ques_inbound_sms_input}')
					and
						t31.del_flag = 'N';
EOS
		sms_display_number = ""
		yuko_button_record = ""
		@mysql_cli.query(query).each do | row |
			sms_display_number = row[0]
			yuko_button_record = row[1]
		end
		return sms_display_number.to_s, yuko_button_record.to_s
	end

	#=============================================================================
	#　SMS挿入項目を取る
	# param : template_id
	# return : array
	#=============================================================================
	def getSmsItemNameByTemplateId(template_id)
		data = Array.new()
		ques_inbound_sms = @common.getQuesInboundSmsCode
		ques_inbound_input_sms = @common.getQuesInboundSmsInputCode
		query = <<EOS
		select
			t31.sms_content
		from
			t31_template_questions t31
		where
			t31.template_id = '#{template_id}' and
			t31.question_type in('#{ques_inbound_sms}', '#{ques_inbound_input_sms}') and
			t31.del_flag = 'N'
		order by t31.question_no;
EOS
		@mysql_cli.query(query).each do | row |
			data = data + Array.new(1, row)
		end
		arr_item = Array.new()
		data.each do | row |
			items = row[0].scan(/{(.*?)}/u)
			items.each do | row |
				unless arr_item.include? row[0]
					arr_item.push(row[0])
				end
			end
		end
		return arr_item
	end
end
