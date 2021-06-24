# encoding: UTF-8
#=============================================================================
# Contents   : pcmファイル作成
# Author     : Ascend Corp
# Since      : 2016/04/14        1.0
#=============================================================================

load File.join(File.dirname(__FILE__),'../config/AscCommon.rb')
load File.join(File.dirname(__FILE__),'../model/AscT13InboundListItem.rb')
load File.join(File.dirname(__FILE__),'../model/AscT17InboundTelList.rb')
load File.join(File.dirname(__FILE__),'../model/AscT31TemplateQuestion.rb')

class AscCreateOutPcm
	#=============================================================================
	#　初期設定
	#=============================================================================
	def initialize
		@ConfigCommon = AscCommon.new
		@ModelT13InboundListItem = AscT13InboundListItem.new
		@ModelT17InboundTelList = AscT17InboundTelList.new
		@ModelT31TemplateQuestion = AscT31TemplateQuestion.new
	end

	#=============================================================================
	#　質問音声ファイルを作成
	# param : pcm_path, template_id
	#=============================================================================
	def createFilePcm(pcm_path, template_id)
		FileUtils.cp(@ConfigCommon.localPathInbound + "/space.pcm", pcm_path)
		arr_info = @ModelT31TemplateQuestion.getQuestionByTemplateId(template_id)
		arr_info.each do | arr |
			question_no = arr[0]
			question_type = arr[1]
			audio_type = arr[5]
			audio_id = arr[6]
			audio_content = arr[7]
			recheck_flag = arr[21]
			recheck_audio_type = arr[22]
			recheck_audio_id = arr[23]
			recheck_audio_content = arr[24]
			sms_error_audio_type = arr[44]
			sms_error_audio_id = arr[45]
			sms_error_audio_content = arr[46]

			#通知番号SMSの送信不可音声の作成
			if question_type.to_s == @ConfigCommon.getQuesInboundSmsCode
				pcm_filename = "sms_error_message.pcm"

				if sms_error_audio_type == "0"
					@ConfigCommon.createFilePcmByAudioId(pcm_path, pcm_filename, sms_error_audio_id)
				else
					@ConfigCommon.createFilePcmByText(pcm_path, pcm_filename, sms_error_audio_content, sms_error_audio_type)
				end
				next
			#番号指定SMSの送信不可音声の作成
			elsif question_type.to_s == @ConfigCommon.getQuesInboundSmsInputCode
				pcm_filename = "sms_error_message.pcm"
				if sms_error_audio_type == "0"
					@ConfigCommon.createFilePcmByAudioId(pcm_path, pcm_filename, sms_error_audio_id)
				else
					@ConfigCommon.createFilePcmByText(pcm_path, pcm_filename, sms_error_audio_content, sms_error_audio_type)
				end
			end
			#セクションの音声
			if audio_type == "0"
				unless audio_id.blank?
					if question_type == @ConfigCommon.getQuesTimeoutCode
						pcm_filename = "timeout_end_ul.pcm"
					else
						pcm_filename = '1_q'+question_no.to_s+'_ul.pcm'
					end
					@ConfigCommon.createFilePcmByAudioId(pcm_path, pcm_filename, audio_id)
				end
			else
				#arr_text = audio_content.split(/{.*?}/u).reject { | c | c.empty? }
				arr_text = @ConfigCommon.getArrAudioContent(audio_content)
				i = 1
				arr_text.each do | text |
					if text[0] != "{" && !text.blank?
						if (question_type.to_s == @ConfigCommon.getQuesTimeoutCode)
							pcm_filename = "timeout_end_ul.pcm"
						else
							if arr_text.length == 1
								pcm_filename = "1_q"+question_no+"_ul.pcm"
							else
								pcm_filename = "1_q"+question_no+"_ul_"+i.to_s+".pcm"
							end
						end
						@ConfigCommon.createFilePcmByText(pcm_path, pcm_filename, text, audio_type)
					end
					i = i + 1
				end
			end

			#繰返の音声(認証・番号入力の場合)
			if recheck_flag.to_s == "1" && (question_type.to_s == @ConfigCommon.getQuesAuthCode || question_type == @ConfigCommon.getQuesAuthCharacterCode || question_type.to_s == @ConfigCommon.getQuesTelCode || question_type.to_s == @ConfigCommon.getQuesFaxCode || question_type.to_s == @ConfigCommon.getQuesInboundSmsInputCode)
				if recheck_audio_type.to_s == "0"
					pcm_filename = '1_q'+question_no.to_s+'_ul_r.pcm'
					@ConfigCommon.createFilePcmByAudioId(pcm_path, pcm_filename, recheck_audio_id)
				else
					arr_text = recheck_audio_content.split(/{.*?}/u).reject { |c| c.empty? }
					i = 1
					arr_text.each do | text |
						if arr_text.length == 1
							pcm_filename = "1_q"+question_no+"_ul_r.pcm"
						else
							pcm_filename = "1_q"+question_no+"_ul_r_"+i.to_s+".pcm"
						end
						@ConfigCommon.createFilePcmByText(pcm_path, pcm_filename, text, recheck_audio_type.to_s)
						i = i + 1
					end
				end
			end
			if question_type.to_s == @ConfigCommon.getQuesPropertyCode
				FileUtils.cp(@ConfigCommon.localPathInbound + "/bukken_invalid.pcm", pcm_path)
				FileUtils.cp(@ConfigCommon.localPathInbound + "/bukken_no_exist.pcm", pcm_path)
				FileUtils.cp(@ConfigCommon.localPathInbound + "/bukken_exist.pcm", pcm_path)
				bukken_audio_type = arr[26]
				bukken_audio_id = arr[27]
				bukken_audio_content = arr[28]

				bukken_diagram_audio_type = arr[30]
				bukken_diagram_audio_id = arr[31]
				bukken_diagram_audio_content = arr[32]

				bukken_cont_audio_type = arr[34]
				bukken_cont_audio_id = arr[35]
				bukken_cont_audio_content = arr[36]
				#物件名確認
				if bukken_audio_type == "0"
					unless bukken_audio_id.blank?
						pcm_filename = '1_q'+question_no.to_s+'_ul_r_bukken.pcm'
						@ConfigCommon.createFilePcmByAudioId(pcm_path, pcm_filename, bukken_audio_id)
					end
				else
					#arr_text = audio_content.split(/{.*?}/u).reject { | c | c.empty? }
					arr_text = @ConfigCommon.getArrAudioContent(bukken_audio_content)
					i = 1
					arr_text.each do | text |
						if text[0] != "{" && !text.blank?
							if arr_text.length == 1
								pcm_filename = "1_q"+question_no+"_ul_r_bukken.pcm"
							else
								pcm_filename = "1_q"+question_no+"_ul_r_bukken_"+i.to_s+".pcm"
							end
							@ConfigCommon.createFilePcmByText(pcm_path, pcm_filename, text, bukken_audio_type)
						end
						i = i + 1
					end
				end
				#図面希望確認
				if bukken_diagram_audio_type == "0"
					unless bukken_diagram_audio_id.blank?
						pcm_filename = '1_q'+question_no.to_s+'_ul_r_bukken_diagram.pcm'
						@ConfigCommon.createFilePcmByAudioId(pcm_path, pcm_filename, bukken_diagram_audio_id)
					end
				else
					#arr_text = audio_content.split(/{.*?}/u).reject { | c | c.empty? }
					arr_text = @ConfigCommon.getArrAudioContent(bukken_diagram_audio_content)
					i = 1
					arr_text.each do | text |
						if text[0] != "{" && !text.blank?
							if arr_text.length == 1
								pcm_filename = "1_q"+question_no+"_ul_r_bukken_diagram.pcm"
							else
								pcm_filename = "1_q"+question_no+"_ul_r_bukken_diagram_"+i.to_s+".pcm"
							end
							@ConfigCommon.createFilePcmByText(pcm_path, pcm_filename, text, bukken_diagram_audio_type)
						end
						i = i + 1
					end
				end
				#継続確認
				if bukken_cont_audio_type == "0"
					unless bukken_cont_audio_id.blank?
						pcm_filename = '1_q'+question_no.to_s+'_ul_r_bukken_cont.pcm'
						@ConfigCommon.createFilePcmByAudioId(pcm_path, pcm_filename, bukken_cont_audio_id)
					end
				else
					#arr_text = audio_content.split(/{.*?}/u).reject { | c | c.empty? }
					arr_text = @ConfigCommon.getArrAudioContent(bukken_cont_audio_content)
					i = 1
					arr_text.each do | text |
						if text[0] != "{" && !text.blank?
							if arr_text.length == 1
								pcm_filename = "1_q"+question_no+"_ul_r_bukken_cont.pcm"
							else
								pcm_filename = "1_q"+question_no+"_ul_r_bukken_cont_"+i.to_s+".pcm"
							end
							@ConfigCommon.createFilePcmByText(pcm_path, pcm_filename, text, bukken_cont_audio_type)
						end
						i = i + 1
					end
				end
			end
			if question_type.to_s == @ConfigCommon.getQuesPropertySearchCode
				# 「確認できません」の音声
				FileUtils.cp(@ConfigCommon.localPathInbound + "/bukken_invalid.pcm", pcm_path)
				# 「空きがありません」の音声
				FileUtils.cp(@ConfigCommon.localPathInbound + "/bukken_no_exist.pcm", pcm_path)
				# 「空きがあります」の音声
				FileUtils.cp(@ConfigCommon.localPathInbound + "/bukken_exist.pcm", pcm_path)
				# 「該当する物件がありません」の音声
				FileUtils.cp(@ConfigCommon.localPathInbound + "/bukken_not_found.pcm", pcm_path)
				# 「検索件数が上限を超えました。」の音声
				FileUtils.cp(@ConfigCommon.localPathInbound + "/bukken_max.pcm", pcm_path)

				bukken_audio_type = arr[26]
				bukken_audio_id = arr[27]
				bukken_audio_content = arr[28]

				bukken_diagram_audio_type = arr[30]
				bukken_diagram_audio_id = arr[31]
				bukken_diagram_audio_content = arr[32]

				bukken_cont_audio_type = arr[34]
				bukken_cont_audio_id = arr[35]
				bukken_cont_audio_content = arr[36]

				square_audio_type = arr[37]
				square_audio_id = arr[38]
				square_audio_name = arr[39]
				square_audio_content = arr[40]
				square_digit = arr[41]
				# 賃料音声は「audio_type」を利用しているため、共通部分で作成ずみ。#

				# 平米
				if square_audio_type == "0"
					unless square_audio_id.blank?
						pcm_filename = '1_q'+question_no.to_s+'_ul_r_bukken_square.pcm'
						@ConfigCommon.createFilePcmByAudioId(pcm_path, pcm_filename, square_audio_id)
					end
				else
					#arr_text = audio_content.split(/{.*?}/u).reject { | c | c.empty? }
					arr_text = @ConfigCommon.getArrAudioContent(square_audio_content)
					i = 1
					arr_text.each do | text |
						if text[0] != "{" && !text.blank?
							if arr_text.length == 1
								pcm_filename = "1_q"+question_no+"_ul_r_bukken_square.pcm"
							else
								pcm_filename = "1_q"+question_no+"_ul_r_bukken_"+i.to_s+"_square.pcm"
							end
							@ConfigCommon.createFilePcmByText(pcm_path, pcm_filename, text, square_audio_type)
						end
						i = i + 1
					end
				end

				#物件名確認音声確認
				if bukken_audio_type == "0"
					unless bukken_audio_id.blank?
						pcm_filename = '1_q'+question_no.to_s+'_ul_r_bukken_answer.pcm'
						@ConfigCommon.createFilePcmByAudioId(pcm_path, pcm_filename, bukken_audio_id)
					end
				else
					#arr_text = audio_content.split(/{.*?}/u).reject { | c | c.empty? }
					arr_text = @ConfigCommon.getArrAudioContent(bukken_audio_content)
					i = 1
					arr_text.each do | text |
						if text[0] != "{" && !text.blank?
							if arr_text.length == 1
								pcm_filename = "1_q"+question_no+"_ul_r_bukken_answer.pcm"
							else
								pcm_filename = "1_q"+question_no+"_ul_r_bukken_answer_"+i.to_s+".pcm"
							end
							@ConfigCommon.createFilePcmByText(pcm_path, pcm_filename, text, bukken_audio_type)
						end
						i = i + 1
					end
				end


				#継続確認
				if bukken_cont_audio_type == "0"
					unless bukken_cont_audio_id.blank?
						pcm_filename = '1_q'+question_no.to_s+'_ul_r_bukken_cont.pcm'
						@ConfigCommon.createFilePcmByAudioId(pcm_path, pcm_filename, bukken_cont_audio_id)
					end
				else
					#arr_text = audio_content.split(/{.*?}/u).reject { | c | c.empty? }
					arr_text = @ConfigCommon.getArrAudioContent(bukken_cont_audio_content)
					i = 1
					arr_text.each do | text |
						if text[0] != "{" && !text.blank?
							if arr_text.length == 1
								pcm_filename = "1_q"+question_no+"_ul_r_bukken_cont.pcm"
							else
								pcm_filename = "1_q"+question_no+"_ul_r_bukken_cont_"+i.to_s+".pcm"
							end
							@ConfigCommon.createFilePcmByText(pcm_path, pcm_filename, text, bukken_cont_audio_type)
						end
						i = i + 1
					end
				end
			end

		end
	end

	#=============================================================================
	#　読上げ音声ファイルを作成
	# param : pcm_var_path, template_id, list_id
	#=============================================================================
	def createFilePcmVar(pcm_var_path, template_id, list_id)
		arr_info = @ModelT31TemplateQuestion.getQuestionByTemplateId(template_id)
		arr_item = Array.new()
		speaker = ""
		arr_info.each do | arr |
			question_no = arr[0]
			question_type = arr[1]
			audio_type = arr[5]
			audio_id = arr[6]
			audio_content = arr[7]
			recheck_flag = arr[21]
			recheck_audio_id = arr[23]
			recheck_audio_type = arr[24]
			recheck_audio_content = arr[25]
			#質問に読上げ項目がある場合
			if (audio_type == "1" || audio_type == "2")
				arr_item_tmp = Array.new()
				speaker = audio_type
				arr_item_tmp = audio_content.scan(/{(.*?)}/u)
				arr_item_tmp.each do | row |
					unless arr_item.include? row
						arr_item.push(row)
					end
				end
			end
			#繰返確認音声に読上げ項目がある場合
			if ((question_type.to_s == @ConfigCommon.getQuesAuthCode || question_type.to_s == @ConfigCommon.getQuesAuthCharacterCode || question_type.to_s == @ConfigCommon.getQuesTelCode) && recheck_flag.to_s == "1" && (recheck_audio_type.to_s == "1" || recheck_audio_type.to_s == "2"))
				arr_item_recheck_tmp = Array.new()
				speaker = recheck_audio_type.to_s
				arr_item_recheck_tmp = recheck_audio_content.scan(/{(.*?)}/u)
				arr_item_recheck_tmp.each do | row |
					unless arr_item.include? row
						arr_item.push(row)
					end
				end
			end
		end
		#照合項目を取る
		auth_match_item = @ModelT31TemplateQuestion.getAuthMatchItemByTemplateId(template_id)
		match_item_col = @ModelT13InboundListItem.getColumnByItemName(list_id, auth_match_item)
		#照合項目が取れなかった場合（照合項目の設定がない場合
		if match_item_col.blank?
				tel_no = "電話番号"
				match_item_col = @ModelT13InboundListItem.getColumnByItemName(list_id, tel_no)
		end
		#ファイル作成
		arr_item.each do | row |
			mix_item = row[0]
			mix_item_col = @ModelT13InboundListItem.getColumnByItemName(list_id, mix_item)
			path = pcm_var_path + "/" + mix_item_col.to_s + "/"
			FileUtils.mkdir_p(path) unless File.exists?(path)
			system("chmod 777 #{path}")
			arr_info = @ModelT17InboundTelList.getInfoItemMix(list_id, match_item_col, mix_item_col)
			arr_info.each do | row1 |
				pcm_filename = row1[0].to_s + ".pcm"
				text = row1[1]
				@ConfigCommon.createFilePcmByText(path, pcm_filename, text, speaker, "read_list")
			end
		end
	end

	#=============================================================================
	#　タイムアウト・未接続転送音声ファイルを作成
	# param : local_path, pcm_path, schedule_id, template_id
	#=============================================================================
	def createFilePcmTrans(local_path, pcm_path, template_id)
		arr_info = @ModelT31TemplateQuestion.getQuestionTransByTemplateId(template_id)
		arr_info.each do | arr |
			trans_timeout = arr[3]
			trans_timeout_audio_id = arr[4]
			trans_timeout_audio_type = arr[5]
			trans_timeout_audio_content = arr[6]
			#転送タイムアウト
			pcm_timeout_name = "timeout_trans_ul.pcm"
			if trans_timeout_audio_type.to_s == "0"
				path_timeout = pcm_path + pcm_timeout_name
				@ConfigCommon.createFilePcmByAudioId(pcm_path, pcm_timeout_name, trans_timeout_audio_id)
			else
				@ConfigCommon.createFilePcmByText(pcm_path, pcm_timeout_name, trans_timeout_audio_content, trans_timeout_audio_type.to_s)
			end
		end
		#転送未接続
		# copy from /home/ftpuser/robo/inbound/schedule
		FileUtils.cp(local_path + "/trans_disconnect.pcm", pcm_path)
		FileUtils.cp(local_path + "/trans_notify_mess_head_inbound.pcm", pcm_path)
		FileUtils.cp(local_path + "/trans_notify_mess_non.pcm", pcm_path)
		FileUtils.cp(local_path + "/trans_notify_mess_tail.pcm", pcm_path)

	end
end