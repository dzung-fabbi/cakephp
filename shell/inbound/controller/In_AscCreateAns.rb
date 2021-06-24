# encoding: UTF-8
#=============================================================================
# Contents   : ansファイル作成
# Author     : Ascend Corp
# Since      : 2016/04/15        1.0
#=============================================================================

load File.join(File.dirname(__FILE__),'../config/AscCommon.rb')
load File.join(File.dirname(__FILE__),'../model/AscT31TemplateQuestion.rb')

class AscCreateAns
	#=============================================================================
	#　初期設定
	#=============================================================================
	def initialize
		@ConfigCommon = AscCommon.new
		@ModelT31TemplateQuestion = AscT31TemplateQuestion.new
	end

	#=============================================================================
	#　Ansファイルを作成
	# params 
	# 	file_path : ファイルのパス 
	# 	template_id : テンプレートID
	# 例　：　Q1 1,2,3
	#=============================================================================
	def createFileAns(file_path, template_id)
		csvFile = File.open(file_path, 'a:UTF-8')
		arr_info = @ModelT31TemplateQuestion.getDataAns(template_id)
		arr_info.each do | row |
			question_no = row[0]
			question_type = row[1]
			str_ans = row[2]
			recheck_flag = row[3]
			recheck_button_next = row[4]
			if str_ans.blank?
				ans_list = 9999
			else
				ans_list = str_ans
			end
			#カウント場合
			if(question_type == @ConfigCommon.getQuesCountCode)
				csvFile.puts(NKF::nkf('-Wsm0', 'C 1'))
			#FAXの場合
			elsif(question_type == @ConfigCommon.getQuesFaxCode)
				csvFile.puts(NKF::nkf('-Wsm0', 'OBJECT 1'))
				csvFile.puts(NKF::nkf('-Wsm0', 'Q' + question_no + ' 1'))
				csvFile.puts(NKF::nkf('-Wsm0', 'OBJECT 1'))
				csvFile.puts(NKF::nkf('-Wsm0', 'Q' + question_no + '-1 1'))
				csvFile.puts(NKF::nkf('-Wsm0', 'OBJECT 1'))
			#物件番号
			elsif(question_type == @ConfigCommon.getQuesPropertyCode)
				csvFile.puts(NKF::nkf('-Wsm0', 'Q' + question_no + ' 1'))
				csvFile.puts(NKF::nkf('-Wsm0', 'OBJECT 1'))
				csvFile.puts(NKF::nkf('-Wsm0', 'Q' + question_no + '-1 1'))
				csvFile.puts(NKF::nkf('-Wsm0', 'Q' + question_no + '-2 1'))
				csvFile.puts(NKF::nkf('-Wsm0', 'Q' + question_no + '-3 1'))
				csvFile.puts(NKF::nkf('-Wsm0', 'OBJECT 1'))
				csvFile.puts(NKF::nkf('-Wsm0', 'Q' + question_no + '-4 1'))
			#物件
			elsif(question_type == @ConfigCommon.getQuesPropertySearchCode)
				####:label3
				# 賃料入力(1_qX_ul.pcm)
				csvFile.puts(NKF::nkf('-Wsm0', 'Q' + question_no + ' 1'))
				# object rental2.Rent
				csvFile.puts(NKF::nkf('-Wsm0', 'OBJECT 1'))
				# 平米入力(1_qX_ul_r_bukken_square.pcm)
				csvFile.puts(NKF::nkf('-Wsm0', 'Q' + question_no + '-1 1'))
				# object rental2.Square
				csvFile.puts(NKF::nkf('-Wsm0', 'OBJECT 1'))
				# object rental2.Query
				csvFile.puts(NKF::nkf('-Wsm0', 'OBJECT 1'))

				####:label3_RES_0、:label3_RES_MAX
				# 0件HITやMAX件以上HITはqやobjectなし

				####:label3_RUN_SELECT
				###### queryで1件HITを想定
				# obj2.select
				csvFile.puts(NKF::nkf('-Wsm0', 'OBJECT 1'))
				# よろしければ1(1_q3_ul_r_bukken_answer.pcm)
				# これは　複数件HITでも流れるメッセージだから、それに番号をあわせる。
				csvFile.puts(NKF::nkf('-Wsm0', 'Q' + question_no + '-2-2 1'))

				####:label3__RUN_CHOICE_VOICE
				###### queryで2件以上MAX未満HITを想定
				#  obj2.Queryが作った音声($P_query.pcm)
				csvFile.puts(NKF::nkf('-Wsm0', 'Q' + question_no + '-2-1 1'))
				# object rental2.select
				csvFile.puts(NKF::nkf('-Wsm0', 'OBJECT 1'))
				# よろしければ1(1_q3_ul_r_bukken_answer.pcm)
				csvFile.puts(NKF::nkf('-Wsm0', 'Q' + question_no + '-2-2 1'))

				####:label3_SELECT_ERROR
				# 複数件HIT時に存在しない番号を入力した場合はqやobjectなし

				####:label3_RUN_CONFIRM
				# object rental2.Confirm
				csvFile.puts(NKF::nkf('-Wsm0', 'OBJECT 1'))
				# object rental2.Decide
				csvFile.puts(NKF::nkf('-Wsm0', 'OBJECT 1'))

				####:label3_NO_EXIST
				# 物件の開き確認結果（開いていません）はqやobjectなし

				####:label3_EXIST
				# 物件の開き確認結果（開いています）はqやobjectなし

				####::label3_CONTINUE
				# 続けるか
				csvFile.puts(NKF::nkf('-Wsm0', 'Q' + question_no + '-3 1'))
			#SMS
			elsif(question_type == @ConfigCommon.getQuesInboundSmsCode)
				csvFile.puts(NKF::nkf('-Wsm0', 'SMS 1'))
			#番号指定SMS
			elsif(question_type == @ConfigCommon.getQuesInboundSmsInputCode)
				csvFile.puts(NKF::nkf('-Wsm0', 'Q' + question_no + ' ' + ans_list.to_s))
				csvFile.puts(NKF::nkf('-Wsm0', 'Q' + question_no + '-1 ' + recheck_button_next.to_s))
				csvFile.puts(NKF::nkf('-Wsm0', 'SMS 1'))
			#着信照合
			elsif(question_type == @ConfigCommon.getQuesInboundCollationCode)
				csvFile.puts(NKF::nkf('-Wsm0', 'SETINCOMNUM'))
			#他場合
			else
				#質問・認証・番号入力場合
				if(question_type == @ConfigCommon.getQuesBasicCode || 
				    question_type == @ConfigCommon.getQuesAuthCode || 
				    question_type == @ConfigCommon.getQuesAuthCharacterCode || 
				    question_type == @ConfigCommon.getQuesTelCode
				   )
					csvFile.puts(NKF::nkf('-Wsm0', 'Q' + question_no + ' ' + ans_list.to_s))
					if(recheck_flag.to_s == "1" && question_type == @ConfigCommon.getQuesAuthCode)
						csvFile.puts(NKF::nkf('-Wsm0', 'Q' + question_no + '-1 ' + recheck_button_next.to_s))
						csvFile.puts(NKF::nkf('-Wsm0', 'Q' + question_no + '-2 ' + recheck_button_next.to_s))
						csvFile.puts(NKF::nkf('-Wsm0', 'Q' + question_no + '-3 ' + recheck_button_next.to_s))
					end
					if(recheck_flag.to_s == "1" && question_type == @ConfigCommon.getQuesAuthCharacterCode)
						csvFile.puts(NKF::nkf('-Wsm0', 'Q' + question_no + '-1 ' + recheck_button_next.to_s))
						csvFile.puts(NKF::nkf('-Wsm0', 'Q' + question_no + '-2 ' + recheck_button_next.to_s))
					end
					if(recheck_flag.to_s == "1" && question_type == @ConfigCommon.getQuesTelCode)
						csvFile.puts(NKF::nkf('-Wsm0', 'Q' + question_no + '-1 ' + recheck_button_next.to_s))
					end
				end
			end
		end
		csvFile.close
	end
end