# encoding: UTF-8
#=============================================================================
# Contents   : テンプレート質問履歴モデール
# Author     : Ascend Corp
# Since      : 2016/05/19        1.0
#=============================================================================
load File.join(File.dirname(__FILE__),'../config/AscCommon.rb')
class AscT64InboundQuestionHistory
	#=============================================================================
	#　初期設定
	#=============================================================================
	def initialize
		@common = AscCommon.new
		@mysql_cli = @common.connectDB
	end

	#=============================================================================
	#　テンプレート質問履歴追加
	# param : inbound_id
	# 
	#=============================================================================
	def insertInboundQuestionHistory(inbound_id)
		query = <<EOS
			insert into t64_inbound_question_histories(
				inbound_id, question_no, question_type, question_yuko, question_title, 
				audio_type, audio_id, audio_name, audio_content, 
				question_repeat, auth_match_flag, auth_item, second_record, yuko_button_record, digit, 
				trans_tel, trans_seat_num, trans_empty_seat_flag, 
				trans_timeout_audio_type, trans_timeout_audio_id, trans_timeout_audio_name, trans_timeout_audio_content, trans_timeout, 
				recheck_flag, recheck_audio_type, recheck_audio_id, recheck_audio_name, recheck_audio_content, 
				recheck_button_next, recheck_button_prev,bukken_audio_type, bukken_audio_id, bukken_audio_content, bukken_answer_no,
				bukken_diagram_audio_type, bukken_diagram_audio_id, bukken_diagram_audio_content, bukken_diagram_answer_no,
				bukken_cont_audio_type, bukken_cont_audio_id, bukken_cont_audio_content, sms_display_number, sms_content,
				sms_error_audio_type, sms_error_audio_id, sms_error_audio_name, sms_error_audio_content
			)
			select 
				t25.id,
				t31.question_no,
				t31.question_type,
				t31.question_yuko,
				t31.question_title,
				t31.audio_type,
				t31.audio_id,
				t31.audio_name,
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
				t31.trans_timeout_audio_name,
				t31.trans_timeout_audio_content,
				t31.trans_timeout,
				t31.recheck_flag,
				t31.recheck_audio_type,
				t31.recheck_audio_id,
				t31.recheck_audio_name,
				t31.recheck_audio_content,
				t31.recheck_button_next,
				t31.recheck_button_prev,
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
				t31.sms_display_number,
				t31.sms_content,
				t31.sms_error_audio_type,
				t31.sms_error_audio_id,
				t31.sms_error_audio_name,
				t31.sms_error_audio_content
			from t25_inbounds t25 inner join t31_template_questions t31 on t25.template_id = t31.template_id and t31.del_flag = "N"
			where t25.id = '#{inbound_id}';
EOS
		@mysql_cli.query(query)
	end

	#=============================================================================
	#　テンプレートの全質問を取得
	# @param	: inbound_id
	# @return	: Mixed array|NULL
	# @author 	: Hungnv
	#=============================================================================
	def getQuesByScheduleId(inbound_id)
		data = Array.new()
		query = <<EOS
			select  question_title,
					question_no,
					question_type,
					recheck_flag,
					recheck_button_next,
					auth_item,
					auth_match_flag,
					sms_display_number
			from t64_inbound_question_histories
			where inbound_id = '#{inbound_id}'
			and del_flag = 'N'
			group by question_no;
EOS
		@mysql_cli.query(query).each do | row |
			data = data + Array.new(1, row)
		end
		return data
	end
end
