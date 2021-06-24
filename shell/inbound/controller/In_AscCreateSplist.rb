# encoding: UTF-8
#=============================================================================
# Contents   : splistファイル作成
# Author     : Ascend Corp
# Since      : 2016/04/14        1.0
#=============================================================================

load File.join(File.dirname(__FILE__),'../config/AscCommon.rb')
load File.join(File.dirname(__FILE__),'../model/AscT13InboundListItem.rb')
load File.join(File.dirname(__FILE__),'../model/AscT31TemplateQuestion.rb')
load File.join(File.dirname(__FILE__),'../model/AscT32TemplateButton.rb')

class AscCreateSplist
	#=============================================================================
	# 初期設定
	#=============================================================================
	def initialize
		@ConfigCommon = AscCommon.new
		@ModelT13InboundListItem = AscT13InboundListItem.new
		@ModelT31TemplateQuestion = AscT31TemplateQuestion.new
		@ModelT32TemplateButton = AscT32TemplateButton.new
	end

	#=============================================================================
	# pcm文字を作成 : 1_q1_ul.pcm or customize1/$1.pcm&1_q2_ul_1.pcm
	# param : question_no, audio_type, audio_content, prefix
	# return : str
	#
	# 例 : audio_content - ｛名前｝でよろしいですか？
	#=============================================================================
	def createStrPcm(list_id, question_no, audio_type, audio_content, prefix)
		#音声ファイル
		if(audio_type == "0")
			if prefix.blank?
				str = '1_q'+question_no.to_s+'_ul.pcm'
			else
				str = '1_q'+question_no.to_s+'_ul_'+prefix+'.pcm'
			end
		#音声合成
		else
			i = 1
			str = ""
			arr_text = @ConfigCommon.getArrAudioContent(audio_content)
			arr_text.each do | row |
				if row[0] == "{"
					item_name = row[1..row.length-2]
					item_code = @ModelT13InboundListItem.getColumnByItemName(list_id, item_name)
					#### 仕様変更。$00、$01・・・$09、$10・・・$99と2桁になる。
					doll_str = "$01"
					pcm = item_code + "/" + doll_str + ".pcm"
				else
					if row.blank?
						for space_num in 1..row.length
							if space_num == 1
								pcm = "space.pcm"
							else
								pcm = pcm + "&space.pcm"
							end
						end
					else
						if prefix.blank?
							if arr_text.length == 1
								pcm = "1_q"+question_no+"_ul.pcm"
							else
								pcm = "1_q"+question_no+"_ul_"+i.to_s+".pcm"
							end
						else
							if arr_text.length == 1
								pcm = "1_q"+question_no+"_ul_"+prefix+".pcm"
							else
								pcm = "1_q"+question_no+"_ul_"+prefix+"_"+i.to_s+".pcm"
							end
						end
					end
				end
				if str.blank?
					str = pcm
				else
					str = str + "&" + pcm
				end
				i = i + 1
			end
		end
		return str
	end

	#=====================================================
	# infoListの項目の中にSMSを取得する。
	# 例 : 08011115555,000001,19800,19660208 - 電話番号あり
	#      ,000002,19800,20000320            - 電話番号無し
	#      (電話番号,照合項目,認証項目,SMS挿入項目)
	#=====================================================
	def getSmsItemIndex(list_id, template_id)
		#電話番号と照合項目は固定で次の項目のidxは2から始まる
		idx = 2
		#各認証カラムを取る
		arr_auth_item = @ModelT31TemplateQuestion.getAuthItemByTemplateId(template_id)
		idx += arr_auth_item.length
		#SMS挿入項目を取る
		arr_sms_item = @ModelT31TemplateQuestion.getSmsItemNameByTemplateId(template_id)
		arr_item = Array.new()
		if arr_sms_item.length > 0
			#SMS挿入項目の始めてのindexをarray_item[0]に保存する
			#例：
			#array_item[0]: 2
			#array_item[1]: 電話番号
			#array_item[2]: 名前
			arr_item.push(idx)
			arr_sms_item.each do | row |
				#sms挿入項目をarr_itemに入れる
				arr_item.push(row)
			end
		end
		return arr_item
	end
	#=============================================================================
	# splistファイルを作成
	# 例 : Q1 1_q1_ul.pcm
	#      Q2 customize1/$1.pcm&1_q2_ul_1.pcm
	#=============================================================================
	def createSplist(file_path, template_id, list_id, inbound_id)
		#指定時間ポーズ変数
		time_sleep = "1000" #1秒
		csvFile = File.open(file_path, 'a:UTF-8')
		arr_info = @ModelT31TemplateQuestion.getQuestionByTemplateId(template_id)
		arr_info.each do | row |
			question_no = row[0]
			question_type = row[1]
			jump_question_next = row[4]
			audio_type = row[5]
			audio_content = row[7] 
			question_repeat = row[8]
			auth_match_flag = row[9]
			auth_item = row[10]
			second_record = row[11]
			yuko_button_record = row[12]
			digit = row[13]
			recheck_flag = row[21]
			recheck_audio_type = row[22]
			recheck_audio_content = row[24]
			recheck_button_next = row[25]
			# セクション毎にラベルを作成
			csvFile.puts(NKF::nkf('-Wsm0', ':label'+question_no.to_s))

			#　以下、質問毎に処理をSPリスト作成処理を行う。
			#再生
			if(question_type.to_s == @ConfigCommon.getQuesVoiceCode)
				csvFile.puts(NKF::nkf('-Wsm0', 'p ' + time_sleep.to_s))
				ques_pcm = createStrPcm(list_id, question_no, audio_type, audio_content, "")
				csvFile.puts(NKF::nkf('-Wsm0', 'm '+ ques_pcm))
				csvFile.puts(NKF::nkf('-Wsm0', 'g label'+ jump_question_next))
			#質問
			elsif(question_type.to_s == @ConfigCommon.getQuesBasicCode)
				#タイムアウト飛び先
				timeout_term = false
				arr_answer = @ModelT32TemplateButton.getAnswerNoByTemplateIdQuestionNo(template_id, question_no)
				arr_answer.each do | row |
					answer_no = row[0]
					jump_question = row[1]
					if(answer_no == "99")
						unless jump_question.blank?
							timeout_term = true
						end
					end
				end
				if timeout_term == true
					csvFile.puts(NKF::nkf('-Wsm0', 'f timeout_term:off'))
				else
					csvFile.puts(NKF::nkf('-Wsm0', 'f timeout_term:on'))
				end
				#音声
				csvFile.puts(NKF::nkf('-Wsm0', 'p ' + time_sleep.to_s))
				ques_pcm = createStrPcm(list_id, question_no, audio_type, audio_content, "")
				csvFile.puts(NKF::nkf('-Wsm0', 'q '+ques_pcm+' 2 1 ' + question_repeat.to_s))
				#回答番号飛び先
				if timeout_term == true
					arr_answer.each do | row |
						answer_no = row[0]
						jump_question = row[1]
						#タイムアウト飛ぶ
						if(answer_no == "99")
							unless jump_question.blank?
								csvFile.puts(NKF::nkf('-Wsm0', 'gt label'+jump_question))
							end
						end
					end
				end
				arr_answer.each do | row |
					answer_no = row[0]
					jump_question = row[1]
					if(answer_no == "51")
						answer_no = "*"
					elsif(answer_no == "52")
						answer_no = "\\#"
					end
					unless jump_question.blank?
						if(answer_no != "99")
							csvFile.puts(NKF::nkf('-Wsm0', 'ge '+answer_no+' label'+jump_question))
						end
					end
				end
				unless jump_question_next.blank?
					csvFile.puts(NKF::nkf('-Wsm0', 'g label'+jump_question_next))
				end
			#認証
			elsif(question_type.to_s == @ConfigCommon.getQuesAuthCode)
				#タイムアウト飛び先
				timeout_term = false
				auth_item_no = @ModelT31TemplateQuestion.getAuthItemNoByTemplateIdAuthItem(template_id, auth_item)
				arr_answer = @ModelT32TemplateButton.getAnswerNoByTemplateIdQuestionNo(template_id, question_no)
				arr_answer.each do | row |
					answer_no = row[0]
					jump_question = row[1]
					if(answer_no == "99")
						unless jump_question.blank?
							timeout_term = true
						end
					end
				end
				if timeout_term == true
					csvFile.puts(NKF::nkf('-Wsm0', 'f timeout_term:off'))
				else
					csvFile.puts(NKF::nkf('-Wsm0', 'f timeout_term:on'))
				end
				#音声
				csvFile.puts(NKF::nkf('-Wsm0', 'p ' + time_sleep.to_s))
				ques_pcm = createStrPcm(list_id, question_no, audio_type, audio_content, "")
				csvFile.puts(NKF::nkf('-Wsm0', 'q '+ques_pcm+' 2 ' + digit.to_s))
				#タイムアウト飛び先
				if timeout_term == true
					arr_answer.each do | row |
						answer_no = row[0]
						jump_question = row[1]
						#タイムアウト飛ぶ
						if(answer_no == "99")
							unless jump_question.blank?
								csvFile.puts(NKF::nkf('-Wsm0', 'gt label'+jump_question))
							end
						end
					end
				end
				#回答飛び先
				arr_answer.each do | row |
					answer_no = row[0]
					jump_question = row[1]

					#### 仕様変更。$00、$01・・・$09、$10・・・$99と2桁になる。
					doll_str = auth_item_no < 10 ? "$0" + auth_item_no.to_s : "$" + auth_item_no.to_s
					#<
					if(answer_no == "1")
						csvFile.puts(NKF::nkf('-Wsm0', 'g< '+doll_str+' label'+question_no.to_s+'_1'))
					#=
					elsif(answer_no == "2")
						csvFile.puts(NKF::nkf('-Wsm0', 'g= '+doll_str+' label'+question_no.to_s+'_2'))
					#>
					elsif(answer_no == "3")
						csvFile.puts(NKF::nkf('-Wsm0', 'g> '+doll_str+' label'+question_no.to_s+'_3'))
					end
				end
				#繰返確認
				arr_answer.each do | row |
					answer_no = row[0]
					jump_question = row[1]
					if answer_no != "99"
						csvFile.puts(NKF::nkf('-Wsm0', ':label'+question_no.to_s+'_'+answer_no.to_s))
						#再確認
						if(recheck_flag == "1")
							csvFile.puts(NKF::nkf('-Wsm0', 'p ' + time_sleep.to_s))
							csvFile.puts(NKF::nkf('-Wsm0', 'n'))
							csvFile.puts(NKF::nkf('-Wsm0', 'p ' + time_sleep.to_s))
							recheck_pcm = createStrPcm(list_id, question_no, recheck_audio_type, recheck_audio_content, "r")
							csvFile.puts(NKF::nkf('-Wsm0', 'q '+recheck_pcm+' 2'))
							if(recheck_button_next == "51")
								recheck_button_next = "*"
							elsif(recheck_button_next == "52")
								recheck_button_next = "\\#"
							end
							if jump_question.blank?
								csvFile.puts(NKF::nkf('-Wsm0', 'ge '+recheck_button_next.to_s+' label'+jump_question_next.to_s))
								csvFile.puts(NKF::nkf('-Wsm0', 'g label'+question_no.to_s))
							else
								csvFile.puts(NKF::nkf('-Wsm0', 'ge '+recheck_button_next.to_s+' label'+jump_question.to_s))
								csvFile.puts(NKF::nkf('-Wsm0', 'g label'+question_no.to_s))
							end	
						else
							if jump_question.blank?
								csvFile.puts(NKF::nkf('-Wsm0', 'g label'+jump_question_next.to_s))
							else
								csvFile.puts(NKF::nkf('-Wsm0', 'g label'+jump_question.to_s))
							end
						end
					end
				end
			#文字列認証
			elsif(question_type.to_s == @ConfigCommon.getQuesAuthCharacterCode)
				#タイムアウト飛び先
				timeout_term = false
				auth_item_no = @ModelT31TemplateQuestion.getAuthItemNoByTemplateIdAuthItem(template_id, auth_item)
				arr_answer = @ModelT32TemplateButton.getAnswerNoByTemplateIdQuestionNo(template_id, question_no)
				arr_answer.each do | row |
					answer_no = row[0]
					jump_question = row[1]
					if(answer_no == "99")
						unless jump_question.blank?
							timeout_term = true
						end
					end
				end
				if timeout_term == true
					csvFile.puts(NKF::nkf('-Wsm0', 'f timeout_term:off'))
				else
					csvFile.puts(NKF::nkf('-Wsm0', 'f timeout_term:on'))
				end

				#音声
				csvFile.puts(NKF::nkf('-Wsm0', 'p ' + time_sleep.to_s))
				ques_pcm = createStrPcm(list_id, question_no, audio_type, audio_content, "")
				csvFile.puts(NKF::nkf('-Wsm0', 'q '+ques_pcm+' 2 ' + digit.to_s))
				#照合認証の場合
				if auth_match_flag == "1" 
					#### 仕様変更。$00、$01・・・$09、$10・・・$99と2桁になる。
					doll_str = "$01"
					csvFile.puts(NKF::nkf('-Wsm0', 'incmpinfo ' + doll_str))
				end
				#タイムアウト飛び先
				if timeout_term == true
					arr_answer.each do | row |
						answer_no = row[0]
						jump_question = row[1]
						#タイムアウト飛ぶ
						if(answer_no == "99")
							unless jump_question.blank?
								csvFile.puts(NKF::nkf('-Wsm0', 'gt label'+jump_question))
							end
						end
					end
				end
				#回答飛び先
				arr_answer.each do | row |
					answer_no = row[0]
					jump_question = row[1]
					if auth_match_flag == "0" 
						#普通認証の場合
						#=
						if(answer_no == "1")
							doll_str = auth_item_no < 10 ? "$0" + auth_item_no.to_s : "$" + auth_item_no.to_s
							csvFile.puts(NKF::nkf('-Wsm0', 'g= \''+doll_str+' label'+question_no.to_s+'_1'))
						#≠
						elsif(answer_no == "2")
							csvFile.puts(NKF::nkf('-Wsm0', 'g label'+question_no.to_s+'_2'))
						end
					else
						#照合認証の場合
						#=
						if(answer_no == "1")
							csvFile.puts(NKF::nkf('-Wsm0', 'jt label'+question_no.to_s+'_1'))
						#≠
						elsif(answer_no == "2")
							csvFile.puts(NKF::nkf('-Wsm0', 'jnt label'+question_no.to_s+'_2'))
						end
					end
				end
				#繰返確認
				arr_answer.each do | row |
					answer_no = row[0]
					jump_question = row[1]
					if answer_no != "99"
						csvFile.puts(NKF::nkf('-Wsm0', ':label'+question_no.to_s+'_'+answer_no.to_s))
						#再確認
						if(recheck_flag == "1")
							csvFile.puts(NKF::nkf('-Wsm0', 'p ' + time_sleep.to_s))
							csvFile.puts(NKF::nkf('-Wsm0', 'n'))
							csvFile.puts(NKF::nkf('-Wsm0', 'p ' + time_sleep.to_s))
							recheck_pcm = createStrPcm(list_id, question_no, recheck_audio_type, recheck_audio_content, "r")
							csvFile.puts(NKF::nkf('-Wsm0', 'q '+recheck_pcm+' 2'))
							if(recheck_button_next == "51")
								recheck_button_next = "*"
							elsif(recheck_button_next == "52")
								recheck_button_next = "\\#"
							end
							if jump_question.blank?
								csvFile.puts(NKF::nkf('-Wsm0', 'ge '+recheck_button_next.to_s+' label'+jump_question_next.to_s))
								csvFile.puts(NKF::nkf('-Wsm0', 'g label'+question_no.to_s))
							else
								csvFile.puts(NKF::nkf('-Wsm0', 'ge '+recheck_button_next.to_s+' label'+jump_question.to_s))
								csvFile.puts(NKF::nkf('-Wsm0', 'g label'+question_no.to_s))
							end	
						else
							if jump_question.blank?
								csvFile.puts(NKF::nkf('-Wsm0', 'g label'+jump_question_next.to_s))
							else
								csvFile.puts(NKF::nkf('-Wsm0', 'g label'+jump_question.to_s))
							end
						end
					end
				end
			#番号入力
			elsif(question_type.to_s == @ConfigCommon.getQuesTelCode)
				#タイムアウト飛び先
				timeout_term = false
				arr_answer = @ModelT32TemplateButton.getAnswerNoByTemplateIdQuestionNo(template_id, question_no)
				arr_answer.each do | row |
					answer_no = row[0]
					jump_question = row[1]
					if(answer_no == "99")
						unless jump_question.blank?
							timeout_term = true
						end
					end
				end
				if timeout_term == true
					csvFile.puts(NKF::nkf('-Wsm0', 'f timeout_term:off'))
				else
					csvFile.puts(NKF::nkf('-Wsm0', 'f timeout_term:on'))
				end
				#音声
				csvFile.puts(NKF::nkf('-Wsm0', 'p ' + time_sleep.to_s))
				ques_pcm = createStrPcm(list_id, question_no, audio_type, audio_content, "")
				csvFile.puts(NKF::nkf('-Wsm0', 'q '+ques_pcm+' 2 ' + digit.to_s))
				#回答飛び先
				arr_answer.each do | row |
					answer_no = row[0]
					jump_question = row[1]
					#タイムアウト飛ぶ
					if(answer_no == "99")
						unless jump_question.blank?
							csvFile.puts(NKF::nkf('-Wsm0', 'gt label'+jump_question))
						end
					end
				end
				#繰返確認
				if(recheck_flag == "1")
					csvFile.puts(NKF::nkf('-Wsm0', 'p ' + time_sleep.to_s))
					csvFile.puts(NKF::nkf('-Wsm0', 'n'))
					csvFile.puts(NKF::nkf('-Wsm0', 'p ' + time_sleep.to_s))
					#recheck_pcm = processAudio(mysql_cli, question_no, recheck_audio_type, recheck_audio_content, "r", list_id)
					recheck_pcm = createStrPcm(list_id, question_no, recheck_audio_type, recheck_audio_content, "r")
					if(recheck_button_next == "51")
						recheck_button_next = "*"
					elsif(recheck_button_next == "52")
						recheck_button_next = "\\#"
					end
					csvFile.puts(NKF::nkf('-Wsm0', 'q ' + recheck_pcm + ' 2 '))
					csvFile.puts(NKF::nkf('-Wsm0', 'ge ' + recheck_button_next + ' label' + jump_question_next.to_s))
					csvFile.puts(NKF::nkf('-Wsm0', 'g label' + question_no.to_s))
				else
					csvFile.puts(NKF::nkf('-Wsm0', 'g label' + jump_question_next.to_s))
				end
			#転送
			elsif(question_type.to_s == @ConfigCommon.getQuesTransCode)
				arr_answer = @ModelT32TemplateButton.getAnswerNoByTemplateIdQuestionNo(template_id, question_no)
				csvFile.puts(NKF::nkf('-Wsm0', 'p ' + time_sleep.to_s))
				ques_pcm = createStrPcm(list_id, question_no, audio_type, audio_content, "")
				csvFile.puts(NKF::nkf('-Wsm0', 't '+ ques_pcm))
			#録音
			elsif(question_type.to_s == @ConfigCommon.getQuesRecordCode)
				csvFile.puts(NKF::nkf('-Wsm0', 'p ' + time_sleep.to_s))
				ques_pcm = createStrPcm(list_id, question_no, audio_type, audio_content, "")
				if yuko_button_record.to_s == "1"
					button = " \\# "
				else
					button = " - "
				end
				csvFile.puts(NKF::nkf('-Wsm0', 'r '+ques_pcm+' 1'+button+'0 '+second_record.to_s))
				csvFile.puts(NKF::nkf('-Wsm0', 'g label'+jump_question_next.to_s))
			#カウント
			elsif(question_type.to_s == @ConfigCommon.getQuesCountCode)
				csvFile.puts(NKF::nkf('-Wsm0', 'p ' + time_sleep.to_s))
				csvFile.puts(NKF::nkf('-Wsm0', 'c'))
				csvFile.puts(NKF::nkf('-Wsm0', 'g label'+jump_question_next))
			#切断
			elsif(question_type.to_s == @ConfigCommon.getQuesEndCode)
				csvFile.puts(NKF::nkf('-Wsm0', 'e'))			
			#FAX番号入力 (例：)
			# :label3			 
			# object rental.faxqry				#FAX送信エントリーあるか
			# g= 0 label4						#FAX送信エントリー無い場合、次質問に行く

			# :label3_1
			# f timeout_term:on 				#タイムアウト設定
			# p 1000							#読み上げ待ち時間 1s
			# q q3_ul.pcm 2 10 					#音声再生
			# p sleep 1000 						#
			# object rental.faxnumber			# FAX番号を入力
			# q q3_ul_r.pcm 2					# 繰返し確認
			# g=1 label3_2 						# 正番号の場合、FAX送信へ行く
			# g label3_1 						# 再入力

			# :label3_2
			# object rental.faxsnd	 			# FAX送信
			# g label4 							# 次質問に行く		
			elsif(question_type.to_s == @ConfigCommon.getQuesFaxCode)				
				csvFile.puts(NKF::nkf('-Wsm0', 'object rental.faxqry'))
				#図面希望がない場合
				csvFile.puts(NKF::nkf('-Wsm0', 'g= 0' + ' label' + jump_question_next.to_s))

				csvFile.puts(NKF::nkf('-Wsm0', ':label' + question_no.to_s + '_1'))
				#タイムアウト飛び先
				timeout_term = false
				arr_answer = @ModelT32TemplateButton.getAnswerNoByTemplateIdQuestionNo(template_id, question_no)
				arr_answer.each do | row |
					answer_no = row[0]
					jump_question = row[1]
					if(answer_no == "99")
						unless jump_question.blank?
							timeout_term = true
						end
					end
				end
				if timeout_term == true
					csvFile.puts(NKF::nkf('-Wsm0', 'f timeout_term:off'))
				else
					csvFile.puts(NKF::nkf('-Wsm0', 'f timeout_term:on'))
				end
				#音声
				csvFile.puts(NKF::nkf('-Wsm0', 'p ' + time_sleep.to_s))
				ques_pcm = createStrPcm(list_id, question_no, audio_type, audio_content, "")
				csvFile.puts(NKF::nkf('-Wsm0', 'q ' + ques_pcm + ' 2 ' + digit.to_s))
				# FAX objectに保存
				csvFile.puts(NKF::nkf('-Wsm0', 'object rental.faxnumber'))
				#回答飛び先
				arr_answer.each do | row |
					answer_no = row[0]
					jump_question = row[1]
					#タイムアウト飛ぶ
					if(answer_no == "99")
						unless jump_question.blank?
							csvFile.puts(NKF::nkf('-Wsm0', 'gt label' + jump_question))
						end
					end
				end
				#繰返確認
				if(recheck_flag == "1")
					if timeout_term == true
						csvFile.puts(NKF::nkf('-Wsm0', 'f timeout_term:off'))
					else
						csvFile.puts(NKF::nkf('-Wsm0', 'f timeout_term:on'))
					end
					csvFile.puts(NKF::nkf('-Wsm0', 'p ' + time_sleep.to_s))
					csvFile.puts(NKF::nkf('-Wsm0', 'n'))					
					recheck_pcm = createStrPcm(list_id, question_no, recheck_audio_type, recheck_audio_content, "r")
					csvFile.puts(NKF::nkf('-Wsm0', 'q ' + recheck_pcm + ' 2 '))
					#回答飛び先
					arr_answer.each do | row |
						answer_no = row[0]
						jump_question = row[1]
						#タイムアウト飛ぶ
						if(answer_no == "99")
							unless jump_question.blank?
								csvFile.puts(NKF::nkf('-Wsm0', 'gt label'+jump_question))
							end
						end
					end
					if(recheck_button_next == "51")
						recheck_button_next = "*"
					elsif(recheck_button_next == "52")
						recheck_button_next = "\\#"
					end
					csvFile.puts(NKF::nkf('-Wsm0', 'g= ' + recheck_button_next + ' label' + question_no.to_s + '_2'))
					csvFile.puts(NKF::nkf('-Wsm0', 'g label' + question_no.to_s + '_1'))

					csvFile.puts(NKF::nkf('-Wsm0', ':label'+question_no.to_s + '_2'))
					csvFile.puts(NKF::nkf('-Wsm0', 'object rental.faxsnd'))
					csvFile.puts(NKF::nkf('-Wsm0', 'g label' + jump_question_next.to_s))
				else
					csvFile.puts(NKF::nkf('-Wsm0', 'g label' + jump_question_next.to_s))
				end
			
			# 物件番号入力 (例：質問4)
			# :label4
			# f timeout_term:off 							# タイムアウト設定
			# p 1000
			# q 1_q4_ul.pcm 2 10
			# gt   label5									# タイムアウト
			# object rental.rentqry							# 存在する: 1が返る 存在しない：0が返る
			# g= 1 label4_1									# 1: 物件番号が確認できて部屋が空いていること
			# g= 2 label4_3									# 2: 物件番号が確認できたが、部屋が空いていないこと
			# m bukken_invalid.pcm 							# 確認できませんでした。再度入力してください。
			# g label4

			# :label4_1
			# f timeout_term:off 							# タイムアウト設定
			# q 1_q4_ul_r_bukken.pcm						# ですね？よろしければ１を、訂正する場合は３をダイヤルしてください。
			# gt   label5									# タイムアウト
			# g= 1 label4_2
			# g label4

			# :label4_2
			# m bukken_exist.pcm 							# お問い合わせの物件は「あります」
			# g label4_5

			# :label4_3
			# f timeout_term:off 							# タイムアウト設定
			# q 1_q4_ul_r_bukken.pcm						# ですね？よろしければ１を、訂正する場合は３をダイヤルしてください。
			# gt   label5									# タイムアウト
			# g= 1 label4_4
			# g label4

			# :label4_4
			# m bukken_no_exist.pcm							# お問い合わせの物件は「ありません」
			# g label4_7

			# :label4_5
			# f timeout_term:off 							# タイムアウト設定
			# q 1_q4_ul_r_bukken_diagram.pcm				# 図面希望？
			# gt   label5									# タイムアウト
			# g= 1 label4_6									# 希望する
			# g label4_7

			# :label4_6
			# object rental.faxent							# 図面エントリ

			# :label4_7
			# f timeout_term:off 							# タイムアウト設定
			# q 1_q4_ul_r_bukken_cont.pcm					# 続ける？				
			# gt   label5									# タイムアウト
			# g= 1 label5									# 次のブロック			
			# g FAX
			elsif(question_type.to_s == @ConfigCommon.getQuesPropertyCode)
				bukken_audio_type = row[26]
				bukken_audio_content = row[28]
				bukken_answer_no = row[29]

				bukken_diagram_audio_type = row[30]
				bukken_diagram_audio_content = row[32]
				bukken_diagram_answer_no = row[33]

				bukken_cont_audio_type = row[34]
				bukken_cont_audio_content = row[36]				
				#タイムアウト飛び先
				timeout_term = false
				arr_answer = @ModelT32TemplateButton.getAnswerNoByTemplateIdQuestionNo(template_id, question_no)
				arr_answer.each do | row |
					answer_no = row[0]
					jump_question = row[1]
					if(answer_no == "99")
						unless jump_question.blank?
							timeout_term = true
						end
					end
				end
				if timeout_term == true
					csvFile.puts(NKF::nkf('-Wsm0', 'f timeout_term:off'))
				else
					csvFile.puts(NKF::nkf('-Wsm0', 'f timeout_term:on'))
				end
				#音声
				csvFile.puts(NKF::nkf('-Wsm0', 'p ' + time_sleep.to_s))
				ques_pcm = createStrPcm(list_id, question_no, audio_type, audio_content, "")
				csvFile.puts(NKF::nkf('-Wsm0', 'q '+ ques_pcm +' 2 ' + digit.to_s))
				#回答飛び先
				arr_answer.each do | row |
					answer_no = row[0]
					jump_question = row[1]
					#タイムアウト
					if(answer_no == "99")
						csvFile.puts(NKF::nkf('-Wsm0', 'gt label' + jump_question.to_s))					
					end
				end				

				#物件有無確認
				csvFile.puts(NKF::nkf('-Wsm0', 'object rental.rentqry'))
				csvFile.puts(NKF::nkf('-Wsm0', 'g= 1 label' + question_no.to_s + '_1'))
				csvFile.puts(NKF::nkf('-Wsm0', 'g= 2 label' + question_no.to_s + '_3'))
				csvFile.puts(NKF::nkf('-Wsm0', 'm bukken_invalid.pcm'))
				csvFile.puts(NKF::nkf('-Wsm0', 'g label' + question_no.to_s))

				#物件繰返し確認
				csvFile.puts(NKF::nkf('-Wsm0', ':label'+question_no.to_s + '_1'))
				ques_pcm = createStrPcm(list_id, question_no, bukken_audio_type, bukken_audio_content, "r_bukken")
				if timeout_term == true
					csvFile.puts(NKF::nkf('-Wsm0', 'f timeout_term:off'))
				else
					csvFile.puts(NKF::nkf('-Wsm0', 'f timeout_term:on'))
				end
				csvFile.puts(NKF::nkf('-Wsm0', 'p ' + time_sleep.to_s))
				csvFile.puts(NKF::nkf('-Wsm0', 'q ' + ques_pcm))
				#回答飛び先
				arr_answer.each do | row |
					answer_no = row[0]
					jump_question = row[1]
					#タイムアウト
					if(answer_no == "99")
						csvFile.puts(NKF::nkf('-Wsm0', 'gt label' + jump_question.to_s))
					end
				end
				if(bukken_answer_no == "51")
					bukken_answer_no = "*"
				elsif(bukken_answer_no == "52")
					bukken_answer_no = "\\#"
				end
				csvFile.puts(NKF::nkf('-Wsm0', 'g= ' + bukken_answer_no.to_s + ' label' + question_no.to_s + '_2'))
				csvFile.puts(NKF::nkf('-Wsm0', 'g label' + question_no.to_s))

				# お問い合わせの物件は「あります」
				csvFile.puts(NKF::nkf('-Wsm0', ':label' + question_no.to_s + '_2'))
				csvFile.puts(NKF::nkf('-Wsm0', 'p ' + time_sleep.to_s))
				csvFile.puts(NKF::nkf('-Wsm0', 'm bukken_exist.pcm'))
				csvFile.puts(NKF::nkf('-Wsm0', 'g label' + question_no.to_s + '_5'))

				#物件繰返し確認
				csvFile.puts(NKF::nkf('-Wsm0', ':label' + question_no.to_s + '_3'))
				if timeout_term == true
					csvFile.puts(NKF::nkf('-Wsm0', 'f timeout_term:off'))
				else
					csvFile.puts(NKF::nkf('-Wsm0', 'f timeout_term:on'))
				end
				csvFile.puts(NKF::nkf('-Wsm0', 'p ' + time_sleep.to_s))
				csvFile.puts(NKF::nkf('-Wsm0', 'q ' + ques_pcm))
				#回答飛び先
				arr_answer.each do | row |
					answer_no = row[0]
					jump_question = row[1]
					#タイムアウト
					if(answer_no == "99")
						csvFile.puts(NKF::nkf('-Wsm0', 'gt label' + jump_question.to_s))
					end
				end				
				csvFile.puts(NKF::nkf('-Wsm0', 'g= ' + bukken_answer_no.to_s + ' label' + question_no.to_s + '_4'))
				csvFile.puts(NKF::nkf('-Wsm0', 'g label' + question_no.to_s))

				# お問い合わせの物件は「ありません」
				csvFile.puts(NKF::nkf('-Wsm0', ':label' + question_no.to_s + '_4'))
				csvFile.puts(NKF::nkf('-Wsm0', 'p ' + time_sleep.to_s))
				csvFile.puts(NKF::nkf('-Wsm0', 'm bukken_no_exist.pcm'))
				csvFile.puts(NKF::nkf('-Wsm0', 'g label' + question_no.to_s + '_7'))

				#物件あり、図面希望確認
				csvFile.puts(NKF::nkf('-Wsm0', ':label' + question_no.to_s + '_5'))				
				ques_pcm = createStrPcm(list_id, question_no, bukken_diagram_audio_type, bukken_diagram_audio_content, "r_bukken_diagram")
				if timeout_term == true
					csvFile.puts(NKF::nkf('-Wsm0', 'f timeout_term:off'))
				else
					csvFile.puts(NKF::nkf('-Wsm0', 'f timeout_term:on'))
				end
				csvFile.puts(NKF::nkf('-Wsm0', 'p ' + time_sleep.to_s))
				csvFile.puts(NKF::nkf('-Wsm0', 'q ' + ques_pcm))
				#回答飛び先
				arr_answer.each do | row |
					answer_no = row[0]
					jump_question = row[1]
					#タイムアウト
					if(answer_no == "99")
						csvFile.puts(NKF::nkf('-Wsm0', 'gt label' + jump_question.to_s))
					end
				end
				if(bukken_diagram_answer_no == "51")
					bukken_diagram_answer_no = "*"
				elsif(bukken_diagram_answer_no == "52")
					bukken_diagram_answer_no = "\\#"
				end
				csvFile.puts(NKF::nkf('-Wsm0', 'g= ' + bukken_diagram_answer_no.to_s + ' label' + question_no.to_s + '_6'))
				csvFile.puts(NKF::nkf('-Wsm0', 'g label' + question_no.to_s + '_7'))

				#物件保存
				csvFile.puts(NKF::nkf('-Wsm0', ':label' + question_no.to_s + '_6'))
				csvFile.puts(NKF::nkf('-Wsm0', 'object rental.faxent'))

				#継続確認
				csvFile.puts(NKF::nkf('-Wsm0', ':label' + question_no.to_s + '_7'))
				ques_pcm = createStrPcm(list_id, question_no, bukken_cont_audio_type, bukken_cont_audio_content, "r_bukken_cont")
				if timeout_term == true
					csvFile.puts(NKF::nkf('-Wsm0', 'f timeout_term:off'))
				else
					csvFile.puts(NKF::nkf('-Wsm0', 'f timeout_term:on'))
				end
				csvFile.puts(NKF::nkf('-Wsm0', 'p ' + time_sleep.to_s))
				csvFile.puts(NKF::nkf('-Wsm0', 'q ' + ques_pcm))

				#回答飛び先
				arr_answer.each do | row |
					answer_no = row[0]
					jump_question = row[1]
					#タイムアウト
					if(answer_no == "99")
						csvFile.puts(NKF::nkf('-Wsm0', 'gt label' + jump_question.to_s))
					else #続く
						if(answer_no == "51")
							answer_no = "*"
						elsif(answer_no == "52")
							answer_no = "\\#"
						end
						csvFile.puts(NKF::nkf('-Wsm0', 'g= ' + answer_no.to_s+' label' + jump_question.to_s))
					end
				end
				#続かない。※その他
				csvFile.puts(NKF::nkf('-Wsm0', 'g label' + jump_question_next.to_s))


			elsif(question_type.to_s == @ConfigCommon.getQuesPropertySearchCode)
				# ループの頭で、本セクションのラベルは作成済み。
				# ':label'+question_no.to_s
				# :label<質問番号>
				# :label2
				bukken_audio_type = row[26]
				bukken_audio_content = row[28]
				bukken_answer_no = row[29]


				bukken_cont_audio_type = row[34]
				bukken_cont_audio_content = row[36]

				square_audio_type = row[37]
				square_audio_id = row[38]
				square_audio_name = row[39]
				square_audio_content = row[40]
				square_digit = row[41]


				# タイムアウト飛び先
				# timeout_term=true　ならば、共通タイムアウトあり
				# なお、本質問は共通タイムアウト設定は必須であるが、念のために判定を行う。
				# 万が一ない場合は、共通タイムアウト設定なしで動作する。
				# ※1質問に複数の共通タイムアウトはない想定。あったら、最初のを使う。
				timeout_term = false
				jump_question = ""
				arr_answer = @ModelT32TemplateButton.getAnswerNoByTemplateIdQuestionNo(template_id, question_no)
				arr_answer.each do | row |
					answer_no = row[0]
					jump_question = row[1]
					# 共通タイムアウトのレコードか?
					if(answer_no == "99")
						unless jump_question.blank?
							timeout_term = true
							break
						end
					end
				end

				# 共通タイムアウト。
				if timeout_term == true
					timeout_string = 'f timeout_term:off'
				else
					timeout_string = 'f timeout_term:on'
				end

			######### 賃料 ####
				# q <音声ファイル名> <分析開始時間> <分析桁数> <タイムアウト回数>
				# q 1_q2_ul.pcm 2 1
				ques_pcm = createStrPcm(list_id, question_no, audio_type, audio_content, "")
				csvFile.puts(NKF::nkf('-Wsm0', timeout_string))
				# スリープ作成(聞き取りにくくなる事を防ぐため、qやmの前に配置する)
				csvFile.puts(NKF::nkf('-Wsm0', 'p ' + time_sleep.to_s))
				csvFile.puts(NKF::nkf('-Wsm0', 'q '+ ques_pcm +' 2 ' + digit.to_s))
				# 共通タイムアウト
				if timeout_term == true
					csvFile.puts(NKF::nkf('-Wsm0', 'gt label' + jump_question.to_s))
				end

				# 賃料入力値の保存
				# rent		賃料設定
				#	in:		カレント入力値（賃料）
				#	out:	入力と同じ値
				#	func:	カレントの入力値（賃料）をオブジェクト内に保存
				#			新たなsplist実行（発信）か本オブジェクトが呼ばれるまで保持
				csvFile.puts(NKF::nkf('-Wsm0', 'object rental2.Rent'))

			######## 平米 ####
				# q <音声ファイル名> <分析開始時間> <分析桁数> <タイムアウト回数>
				# q 1_q2_ul_r_bukken_square.pcm 2 1
				# 第四引数のプレフィックスは、下記で指定した音声ファイル名（拡張子より前の部分）を指定すること。
				# shell/inbound/controller/In_AscCreateOutPcm.rb
				# def createFilePcm
				ques_pcm = createStrPcm(list_id, question_no, square_audio_type, square_audio_content, "r_bukken_square")
				csvFile.puts(NKF::nkf('-Wsm0', timeout_string))
				csvFile.puts(NKF::nkf('-Wsm0', 'p ' + time_sleep.to_s))
				csvFile.puts(NKF::nkf('-Wsm0', 'q '+ ques_pcm +' 2 ' + square_digit.to_s))
				# 共通タイムアウト
				if timeout_term == true
					csvFile.puts(NKF::nkf('-Wsm0', 'gt label' + jump_question.to_s))
				end
				# 平米入力値の保存
				#	Square		平米数設定
				#		in:		カレント入力値（平米数）
				#		out:	入力と同じ値
				#		func:	カレントの入力値（平米数）をオブジェクト内に保存
				#				新たなsplist実行（発信）か本オブジェクトが呼ばれるまで保持
				csvFile.puts(NKF::nkf('-Wsm0', 'object rental2.Square'))

			######## # 問い合わせ実行
				#	Query		物件問い合わせ・検索物件読み上げ用音声ファイル出力
				#	in:		カレント入力値（未使用）
				#	out:	物件数
				#	func:	レンターズへ問い合わせ，ヒットした物件数を返す
				#			QUERY_MAX_SYNTHで指定された件数以下であれば，物件名を全て音声合成でファイルへ出力
				#			1件の場合splistでselectを呼び出す（ファイル出力なし）
				#			2件以上の場合，splistで物件選択質問（出力ファイル指定）を呼び出す
				#			出力ファイル名は"$P_query.pcm"（$P:ポート番号変数）
				#			出力先はDIR_Q_PCMで指定されるディレクトリ
				#			出力ファイルには「を押してください。それではどうぞ」が含まれる
				csvFile.puts(NKF::nkf('-Wsm0', 'object rental2.Query'))
				# 問い合わせの結果、0件ならば物件0件HITへ遷移、1件ならば物件1件HITへ遷移
				csvFile.puts(NKF::nkf('-Wsm0', 'g= 0' + ' label' + question_no.to_s + '_RES_0'))
				csvFile.puts(NKF::nkf('-Wsm0', 'g= 1' + ' label' + question_no.to_s + '_RUN_SELECT'))
				# 問い合わせの結果、リミットを超えた場合は、件ならば物件1件HITへ遷移
				csvFile.puts(NKF::nkf('-Wsm0', 'g> ' + @ConfigCommon.getPropertySearchMax + ' label' + question_no.to_s + '_RES_MAX'))
				# それ以外（複数件）は選択する問い合わせへ遷移。
				csvFile.puts(NKF::nkf('-Wsm0', 'g' + ' label' + question_no.to_s + '_RUN_CHOICE_VOICE'))


			######## #　物件0件HIT
				# 問い合わせの結果、0件ならば固定メッセージ「bukken_invalid.pcm」を再生し、
				# 本セクションの先頭へ遷移
				csvFile.puts(NKF::nkf('-Wsm0', ':label'+question_no.to_s + '_RES_0'))
				csvFile.puts(NKF::nkf('-Wsm0', 'm bukken_invalid.pcm'))
				csvFile.puts(NKF::nkf('-Wsm0', 'g label' + question_no.to_s))

				#　物件数リミット以上HIT
				# 問い合わせの結果、1件ならば固定メッセージ「bukken_max.pcm」を再生し、
				# 本セクションの先頭へ遷移
				csvFile.puts(NKF::nkf('-Wsm0', ':label'+question_no.to_s + '_RES_MAX'))
				csvFile.puts(NKF::nkf('-Wsm0', 'm bukken_max.pcm'))
				csvFile.puts(NKF::nkf('-Wsm0', 'g label' + question_no.to_s))


			######## #　物件1件HIT
				csvFile.puts(NKF::nkf('-Wsm0', ':label'+question_no.to_s + '_RUN_SELECT'))
				#	Select		物件選択・選択物件読み上げ
				#		in:		カレント入力値（物件番号）
				#		out:	0:入力番号ミスマッチ　0以外:該当番号（入力番号）
				#		func:	複数物件のうち該当する物件を選択
				#				入力した該当物件名を読み上げる
				#				入力番号の物件がない場合0を返す
				# HITした物件名読み上げ
				#（音声：めぞん國吉）
				csvFile.puts(NKF::nkf('-Wsm0', 'p ' + time_sleep.to_s))
				csvFile.puts(NKF::nkf('-Wsm0', 'object rental2.Select'))
				#（音声：ですね。よろしければ<bukken_answer_no>を、違うならそれ以外を押してください。）
				ques_pcm = createStrPcm(list_id, question_no, bukken_audio_type, bukken_audio_content, "r_bukken_answer")
				csvFile.puts(NKF::nkf('-Wsm0', timeout_string))
				csvFile.puts(NKF::nkf('-Wsm0', 'q '+ ques_pcm +' 2'))
				# 共通タイムアウト
				if timeout_term == true
					csvFile.puts(NKF::nkf('-Wsm0', 'gt label' + jump_question.to_s))
				end

				# 物件名が正しい場合は、CONFIRMを実行し、空きかどうかの判断を行ない、物件名が正しくない場合は、最初に戻る
				csvFile.puts(NKF::nkf('-Wsm0', 'g= ' + bukken_answer_no.to_s + ' label' + question_no.to_s + '_RUN_CONFIRM'))
				csvFile.puts(NKF::nkf('-Wsm0', 'g label' + question_no.to_s))


			######## #　物件複数件HIT
				csvFile.puts(NKF::nkf('-Wsm0', ':label'+question_no.to_s + '_RUN_CHOICE_VOICE'))
				csvFile.puts(NKF::nkf('-Wsm0', timeout_string))
				# 問い合わせの結果、複数件HITした場合は、固定メッセージ「$P_query.pcm」を再生し、
				# 1つを選んでもらうよう入力を促す。※$Pはポート番号。福島さん側でポート番号に置き換える。
				csvFile.puts(NKF::nkf('-Wsm0', 'p ' + time_sleep.to_s))
				# 物件一覧読み上げ
				#（音声：めぞん國吉は1、コーポ國吉は2　を押してください。それではどうぞ」）
				csvFile.puts(NKF::nkf('-Wsm0', 'q $P_query.pcm 2 2'))
				# 共通タイムアウト
				if timeout_term == true
					csvFile.puts(NKF::nkf('-Wsm0', 'gt label' + jump_question.to_s))
				end
				#	Select		物件選択・選択物件読み上げ
				#		in:		カレント入力値（物件番号）
				#		out:	0:入力番号ミスマッチ　0以外:該当番号（入力番号）
				#		func:	複数物件のうち該当する物件を選択
				#				入力した該当物件名を読み上げる
				#				入力番号の物件がない場合0を返す
				# q $P_query.pcm で選択した物件名読み上げ
				#（音声：1を押した場合の音声：めぞん國吉）
				#（音声：3を押した場合の音声：音声発生なし）
				csvFile.puts(NKF::nkf('-Wsm0', 'p ' + time_sleep.to_s))
				csvFile.puts(NKF::nkf('-Wsm0', 'object rental2.Select'))
				# 入力の値がsearchの範囲外（正しくない値）の場合はエラーメッセージを出力。正しい場合は、CONFIRMを実行し、空きの確認をする。
				csvFile.puts(NKF::nkf('-Wsm0', 'g= 0' + ' label' + question_no.to_s + '_SELECT_ERROR'))
				#（音声：ですね。よろしければ<bukken_answer_no>を、違うならそれ以外を押してください。）
				ques_pcm = createStrPcm(list_id, question_no, bukken_audio_type, bukken_audio_content, "r_bukken_answer")
				csvFile.puts(NKF::nkf('-Wsm0', timeout_string))
				csvFile.puts(NKF::nkf('-Wsm0', 'p ' + time_sleep.to_s))
				csvFile.puts(NKF::nkf('-Wsm0', 'q '+ ques_pcm +' 2'))
				# 共通タイムアウト
				if timeout_term == true
					csvFile.puts(NKF::nkf('-Wsm0', 'gt label' + jump_question.to_s))
				end
				# 物件名が正しい場合は、CONFIRMを実行し、空きかどうかの判断を行ない、物件名が正しくない場合は、物件名の再選択
				csvFile.puts(NKF::nkf('-Wsm0', 'g= ' + bukken_answer_no.to_s + ' label' + question_no.to_s + '_RUN_CONFIRM'))
				csvFile.puts(NKF::nkf('-Wsm0', 'g label' + question_no.to_s + '_RUN_CHOICE_VOICE'))

			######## #　SELECT_ERROR
				# 入力の値がsearchの範囲外（正しくない値）の場合はエラーメッセージを出力し、再度物件全てを読み上げる。
				csvFile.puts(NKF::nkf('-Wsm0', ':label'+question_no.to_s + '_SELECT_ERROR'))
				csvFile.puts(NKF::nkf('-Wsm0', 'm bukken_invalid.pcm'))
				csvFile.puts(NKF::nkf('-Wsm0', 'g label' + question_no.to_s + '_RUN_CHOICE_VOICE'))


			######## #　CONFIRM実行
				csvFile.puts(NKF::nkf('-Wsm0', ':label'+question_no.to_s + '_RUN_CONFIRM'))
				#	Confirm		選択物件確定（物件名出力）
				#		in:		カレント入力値（未使用）
				#		out:	該当物件名
				#				例）平河町レジデンス1103号
				#		func:	選択されている物件があれば物件名を出力
				csvFile.puts(NKF::nkf('-Wsm0', 'object rental2.Confirm'))

				#	Decide		物件空き判断
				#		in:		カレント入力値（未使用）
				#		out:	1:空きあり　0:空きなし
				#		func:	選択されている物件の空き条件を判断し空きあり・なしを返す
				csvFile.puts(NKF::nkf('-Wsm0', 'object rental2.Decide'))

				# Decideで0が戻ると、物件に空きがないため、「空いておりません」の固定音声を出力
				# それ以外は、物件に空きのめ、「空いています」の固定音声を出力
				csvFile.puts(NKF::nkf('-Wsm0', 'g= 1 label' + question_no.to_s + '_EXIST'))
				csvFile.puts(NKF::nkf('-Wsm0', 'g label' + question_no.to_s + '_NO_EXIST'))

			######## #　NO_EXIST(その物件は空いていない)
				# 問い合わせの結果、その物件が空いていなければ、固定メッセージ「bukken_no_exist.pcm」を再生し、
				# 続けて検索するかの入力を促す
				csvFile.puts(NKF::nkf('-Wsm0', ':label'+question_no.to_s + '_NO_EXIST'))
				csvFile.puts(NKF::nkf('-Wsm0', 'm bukken_no_exist.pcm'))
				csvFile.puts(NKF::nkf('-Wsm0', 'g label' + question_no.to_s + '_CONTINUE'))

			######## #　EXIST(その物件はあいている)
				# 問い合わせの結果、その物件が空いていなければ、固定メッセージ「bukken_exist.pcm」を再生し、
				# 続けて検索するかの入力を促す
				csvFile.puts(NKF::nkf('-Wsm0', ':label'+question_no.to_s + '_EXIST'))
				csvFile.puts(NKF::nkf('-Wsm0', 'm bukken_exist.pcm'))
				csvFile.puts(NKF::nkf('-Wsm0', 'g label' + question_no.to_s + '_CONTINUE'))

			######## #　CONTINUE(NO_EXIST または EXISTの後に呼ばれる想定)
				#継続確認
				csvFile.puts(NKF::nkf('-Wsm0', ':label' + question_no.to_s + '_CONTINUE'))
				ques_pcm = createStrPcm(list_id, question_no, bukken_cont_audio_type, bukken_cont_audio_content, "r_bukken_cont")
				csvFile.puts(NKF::nkf('-Wsm0', 'p ' + time_sleep.to_s))
				csvFile.puts(NKF::nkf('-Wsm0', timeout_string))
				csvFile.puts(NKF::nkf('-Wsm0', 'q ' + ques_pcm))
				# 共通タイムアウト
				if timeout_term == true
					csvFile.puts(NKF::nkf('-Wsm0', 'gt label' + jump_question.to_s))
				end

				#回答飛び先
				arr_answer.each do | row |
					answer_no = row[0]
					jump_question = row[1]
					if(!(answer_no == "99"))
						if(answer_no == "51")
							answer_no = "*"
						elsif(answer_no == "52")
							answer_no = "\\#"
						end
						csvFile.puts(NKF::nkf('-Wsm0', 'g= ' + answer_no.to_s+' label' + jump_question.to_s))
					end
				end
				#続かない。※その他
				csvFile.puts(NKF::nkf('-Wsm0', 'g label' + jump_question_next.to_s))
			elsif(question_type.to_s == @ConfigCommon.getQuesInboundSmsCode)
				sms_content = row[43]

				arr_answer = @ModelT32TemplateButton.getAnswerNoByTemplateIdQuestionNo(template_id, question_no)				

				remote_path_inbound = @ConfigCommon.remotePathInbound
				local_path_inbound =  @ConfigCommon.localPathInbound
				inbound_no = "000000".slice(1..6-inbound_id.to_s.length) + inbound_id.to_s

				sms_localPath = local_path_inbound + "/" + inbound_no.to_s + '/indata/sms/' + question_no + '.txt'
				sms_remote_path = remote_path_inbound + "/" + inbound_no.to_s + '/indata/sms/' + question_no + '.txt'
				smsItemIndex = getSmsItemIndex(list_id, template_id)
				@ConfigCommon.smsContentToFile(sms_localPath, sms_content, smsItemIndex)

				csvFile.puts(NKF::nkf('-Wsm0', 'p 1000'))
				#### 仕様変更。$00、$01・・・$09、$10・・・$99と2桁になる。
				doll_str = "$00"
				csvFile.puts(NKF::nkf('-Wsm0', 'sms ' + doll_str + " " + sms_remote_path))
				#回答飛び先
				arr_answer.each do | row |
					answer_no = row[0]
					jump_question = row[1]
					#タイムアウト
					if(answer_no == "99")
						csvFile.puts(NKF::nkf('-Wsm0', 'g= 2 label' + jump_question.to_s))
					end
				end
				csvFile.puts(NKF::nkf('-Wsm0', 'g label' + jump_question_next.to_s))
			#着信番号照合
			elsif(question_type.to_s == @ConfigCommon.getQuesInboundCollationCode)
				arr_answer = @ModelT32TemplateButton.getAnswerNoByTemplateIdQuestionNo(template_id, question_no)
				arr_answer.each do | row |
					answer_no = row[0]
					jump_question = row[1]
				end
				#着信番号照合コマンド(固定)
				csvFile.puts(NKF::nkf('-Wsm0', 'setincomnum'))
				csvFile.puts(NKF::nkf('-Wsm0', 'incmpinfo $00'))
				#回答飛び先
				arr_answer.each do | row |
					answer_no = row[0]
					jump_question = row[1]
					#=
					if(answer_no == "1")
						csvFile.puts(NKF::nkf('-Wsm0', 'jt label'+question_no.to_s+'_1'))
					#≠
					elsif(answer_no == "2")
						csvFile.puts(NKF::nkf('-Wsm0', 'jnt label'+question_no.to_s+'_2'))
					end
				end
				
				#ラベル移行先
				arr_answer.each do | row |
					answer_no = row[0]
					jump_question = row[1]
					#ラベル定義
					if answer_no != "99"
						csvFile.puts(NKF::nkf('-Wsm0', ':label'+question_no.to_s+'_'+answer_no.to_s))
					end
					csvFile.puts(NKF::nkf('-Wsm0', 'g label'+jump_question.to_s))
				end
			#番号指定SMS
			elsif(question_type.to_s == @ConfigCommon.getQuesInboundSmsInputCode)
				sms_content = row[43]

				arr_answer = @ModelT32TemplateButton.getAnswerNoByTemplateIdQuestionNo(template_id, question_no)

				remote_path_inbound = @ConfigCommon.remotePathInbound
				local_path_inbound =  @ConfigCommon.localPathInbound
				inbound_no = "000000".slice(1..6-inbound_id.to_s.length) + inbound_id.to_s

				sms_localPath = local_path_inbound + "/" + inbound_no.to_s + '/indata/sms/' + question_no + '.txt'
				sms_remote_path = remote_path_inbound + "/" + inbound_no.to_s + '/indata/sms/' + question_no + '.txt'
				smsItemIndex = getSmsItemIndex(list_id, template_id)
				@ConfigCommon.smsContentToFile(sms_localPath, sms_content, smsItemIndex)

				#タイムアウト時のセクションを設定
				timeout_term = false
				arr_answer = @ModelT32TemplateButton.getAnswerNoByTemplateIdQuestionNo(template_id, question_no)
				arr_answer.each do | row |
					answer_no = row[0]
					jump_question = row[1]
					if(answer_no == "98")
						unless jump_question.blank?
							timeout_term = true
						end
					end
				end

				if timeout_term == true
					csvFile.puts(NKF::nkf('-Wsm0', 'f timeout_term:off'))
				else
					csvFile.puts(NKF::nkf('-Wsm0', 'f timeout_term:on'))
				end

				#音声
				csvFile.puts(NKF::nkf('-Wsm0', 'p ' + time_sleep.to_s))
				ques_pcm = createStrPcm(list_id, question_no, audio_type, audio_content, "")
				#SMSのため入力桁数は「11」固定
				csvFile.puts(NKF::nkf('-Wsm0', 'q '+ques_pcm+' 2 11'))
				csvFile.puts(NKF::nkf('-Wsm0', 'setsmsnumber'))
				#タイムアウト時の飛び先を設定
				arr_answer.each do | row |
					answer_no = row[0]
					jump_question = row[1]
					if(answer_no == "98")
						unless jump_question.blank?
							csvFile.puts(NKF::nkf('-Wsm0', 'gt label'+jump_question))
						end
					end
				end
				#繰返確認
				csvFile.puts(NKF::nkf('-Wsm0', 'p ' + time_sleep.to_s))
				csvFile.puts(NKF::nkf('-Wsm0', 'n'))
				csvFile.puts(NKF::nkf('-Wsm0', 'p ' + time_sleep.to_s))
				recheck_pcm = createStrPcm(list_id, question_no, recheck_audio_type, recheck_audio_content, "r")
				if(recheck_button_next == "51")
					recheck_button_next = "*"
				elsif(recheck_button_next == "52")
					recheck_button_next = "\\#"
				end
				csvFile.puts(NKF::nkf('-Wsm0', 'q ' + recheck_pcm + ' 2 '))
				csvFile.puts(NKF::nkf('-Wsm0', 'ge ' + recheck_button_next + ' ' + 'label' + question_no.to_s + '_sms'))
				csvFile.puts(NKF::nkf('-Wsm0', 'g label' + question_no.to_s))
				#番号指定SMS送信用のラベルを作成
				csvFile.puts(NKF::nkf('-Wsm0', ':label' + question_no.to_s+'_sms'))
				csvFile.puts(NKF::nkf('-Wsm0', 'sms ' + sms_remote_path))

				#送信失敗時のセクションを設定
				arr_answer.each do | row |
					answer_no = row[0]
					jump_question = row[1]
					if(answer_no == "99")
						csvFile.puts(NKF::nkf('-Wsm0', 'g= 2 label' + jump_question.to_s))
					end
				end
				csvFile.puts(NKF::nkf('-Wsm0', 'g label' + jump_question_next.to_s))

			end

		end
		csvFile.close
	end
end