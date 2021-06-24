# encoding: UTF-8
#=============================================================================
# Contents   : splistファイル作成
# Author     : Ascend Corp
# Since      : 2015/09/07        1.0
#=============================================================================

load File.join(File.dirname(__FILE__),'common.rb')
load File.join(File.dirname(__FILE__),'config.rb')

instance =  AscConfig.new
instance.instance_eval File.read File.join(File.dirname(__FILE__),'config.ini')
config = instance.getData

############################################
#
# バッチのメイン処理
#
############################################
def queryGetAnsw(mysql_cli, template_id, question_no)
	arr = Array.new()
	query = <<EOS
		select 
			t32.answer_no,
			t32.jump_question
		from
			t32_template_buttons t32 
		where
			t32.template_id = '#{template_id}' and
			t32.question_no = '#{question_no}' and
			t32.del_flag = 'N'
		order by t32.answer_no;
EOS
	mysql_cli.query(query).each do | row |
		arr = arr + Array.new(1, row)
	end
	return arr
end

def processAudio(mysql_cli, question_no, audio_type, audio_content, prefix, list_id)
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
		arr_text = getArrAudioContent(audio_content)
		arr_text.each do | row |
			if row[0] == "{"
				#### 仕様変更。$00、$01・・・$09、$10・・・$99と2桁になる。
				doll_str = "$00"
				pcm = getColumnByItemName(mysql_cli, row[1..row.length-2], list_id) + "/" + doll_str + ".pcm"
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
				str = str + "&" +pcm
			end
			i = i + 1
		end
	end
	return str
end

def processAuthItemNo(mysql_cli, template_id, auth_item)
	item_no = 1
	i = 1
	query = <<EOS
		select 
			distinct auth_item
		from
			t31_template_questions 
		where
			template_id = '#{template_id}'
			and question_type in("3", "10")
			and del_flag = "N"
		order by question_no
EOS
	mysql_cli.query(query).each do | row |
		if auth_item == row[0]
			item_no = i
		end
		i = i + 1
	end
	return item_no
end

begin
	schedule_no = ARGV[0]
	template_id = ARGV[1]
	list_id = ARGV[2]
	#DB接続情報
	db_ip = config[:database_ip]
	db_id = config[:database_id]
	db_pass = config[:database_pass]
	db_schema = config[:database_schema]
	mysql_cli=Mysql.connect(db_ip, db_id, db_pass, db_schema)
	mysql_cli.charset="utf8"
	localPathSchedule = config[:local_schedule]
	localPathScheduleId = config[:local_schedule] + schedule_no
	localPathIndata = localPathScheduleId + '/indata/'
	localPathSplist = localPathIndata + 'splist/'
	fileSplist = '1_splist.txt'
	createBlankCSV(localPathSplist, fileSplist)
	csvFile = File.open(localPathSplist + fileSplist, 'a:UTF-8')
	#質問情報を取る
	queryGetQues = <<EOS
		select 
			t31.question_no,
			t31.question_type,
			t31.question_repeat,
			t31.audio_type,
			t31.audio_content,
			t31.digit,
			t31.second_record,
			t31.recheck_audio_type,
			t31.recheck_audio_content,
			t31.recheck_button_next,
			t31.recheck_button_prev,
			t31.auth_item,
			t31.recheck_flag,
			t31.yuko_button_record,
			t31.jump_question,
			t31.sms_content
		from
			t31_template_questions t31 
		where
			t31.template_id = '#{template_id}' and
			t31.del_flag = 'N'
		order by t31.question_no;
EOS
	mysql_cli.query(queryGetQues).each do | row |
		question_no = row[0]
		question_type = row[1]
		question_repeat = row[2]
		audio_type = row[3]
		audio_content = row[4] 
		digit = row[5]
		second_record = row[6]
		recheck_audio_type = row[7]
		recheck_audio_content = row[8]
		recheck_button_next = row[9]
		recheck_button_prev = row[10]
		auth_item = row[11]
		recheck_flag = row[12]
		yuko_button_record = row[13]
		jump_question_next = row[14]
		sms_content = row[15]
		question_next = question_no.to_i + 1
		csvFile.puts(NKF::nkf('-Wsm0', ':label'+question_no.to_s))
		#再生
		if(question_type == "1")
			csvFile.puts(NKF::nkf('-Wsm0', 'p 1000'))
			ques_pcm = processAudio(mysql_cli, question_no, audio_type, audio_content, "", list_id)
			csvFile.puts(NKF::nkf('-Wsm0', 'm '+ques_pcm))
			csvFile.puts(NKF::nkf('-Wsm0', 'g label'+jump_question_next))
		#質問
		elsif(question_type == "2")
			#タイムアウト飛び先
			timeout_term = false
			answInfo = queryGetAnsw(mysql_cli, template_id, question_no)
			answInfo.each do | row |
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
			csvFile.puts(NKF::nkf('-Wsm0', 'p 1000'))
			ques_pcm = processAudio(mysql_cli, question_no, audio_type, audio_content, "", list_id)
			csvFile.puts(NKF::nkf('-Wsm0', 'q '+ques_pcm+' 2 1 ' + question_repeat.to_s))
			#回答番号飛び先
			if timeout_term == true
				answInfo.each do | row |
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
			answInfo.each do | row |
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
		#数値認証
		elsif(question_type == "3")
			#タイムアウト飛び先
			timeout_term = false
			auth_item_no = processAuthItemNo(mysql_cli, template_id, auth_item)
			answInfo = queryGetAnsw(mysql_cli, template_id, question_no)
			answInfo.each do | row |
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
			csvFile.puts(NKF::nkf('-Wsm0', 'p 1000'))
			ques_pcm = processAudio(mysql_cli, question_no, audio_type, audio_content, "", list_id)
			csvFile.puts(NKF::nkf('-Wsm0', 'q '+ques_pcm+' 2 ' + digit.to_s))
			#回答飛び先
			if timeout_term == true
				answInfo.each do | row |
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
			answInfo.each do | row |
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
			answInfo.each do | row |
				answer_no = row[0]
				jump_question = row[1]
				if answer_no != "99"
					csvFile.puts(NKF::nkf('-Wsm0', ':label'+question_no.to_s+'_'+answer_no.to_s))
					#再確認
					if(recheck_flag == "1")
						csvFile.puts(NKF::nkf('-Wsm0', 'p 1000'))
						csvFile.puts(NKF::nkf('-Wsm0', 'n'))
						csvFile.puts(NKF::nkf('-Wsm0', 'p 1000'))
						recheck_pcm = processAudio(mysql_cli, question_no, recheck_audio_type, recheck_audio_content, "r", list_id)
						csvFile.puts(NKF::nkf('-Wsm0', 'q '+recheck_pcm+' 2'))
						#csvFile.puts(NKF::nkf('-Wsm0', 'p 1000'))
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
		elsif(question_type == "4")
			#タイムアウト飛び先
			timeout_term = false
			answInfo = queryGetAnsw(mysql_cli, template_id, question_no)
			answInfo.each do | row |
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
			csvFile.puts(NKF::nkf('-Wsm0', 'p 1000'))
			ques_pcm = processAudio(mysql_cli, question_no, audio_type, audio_content, "", list_id)
			csvFile.puts(NKF::nkf('-Wsm0', 'q '+ques_pcm+' 2 ' + digit.to_s))
			#回答飛び先
			answInfo.each do | row |
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
				csvFile.puts(NKF::nkf('-Wsm0', 'p 1000'))
				csvFile.puts(NKF::nkf('-Wsm0', 'n'))
				csvFile.puts(NKF::nkf('-Wsm0', 'p 1000'))
				recheck_pcm = processAudio(mysql_cli, question_no, recheck_audio_type, recheck_audio_content, "r", list_id)
				if(recheck_button_next == "51")
					recheck_button_next = "*"
				elsif(recheck_button_next == "52")
					recheck_button_next = "\\#"
				end
				csvFile.puts(NKF::nkf('-Wsm0', 'q '+recheck_pcm+' 2 '))
				csvFile.puts(NKF::nkf('-Wsm0', 'ge '+recheck_button_next+' label'+jump_question_next.to_s))
				csvFile.puts(NKF::nkf('-Wsm0', 'g label'+question_no.to_s))
			else
				csvFile.puts(NKF::nkf('-Wsm0', 'g label'+jump_question_next.to_s))
			end
		#転送
		elsif(question_type == "5")
			answInfo = queryGetAnsw(mysql_cli, template_id, question_no)
			answer_no = ""
			answInfo.each do | row |
				answer_no = row[0]
				if(answer_no == "51")
					answer_no = "*"
				elsif(answer_no == "52")
					answer_no = "\\#"
				end
			end
			csvFile.puts(NKF::nkf('-Wsm0', 'p 1000'))
			ques_pcm = processAudio(mysql_cli, question_no, audio_type, audio_content, "", list_id)
			csvFile.puts(NKF::nkf('-Wsm0', 't '+ ques_pcm))
		#録音
		elsif(question_type == "6")
			csvFile.puts(NKF::nkf('-Wsm0', 'p 1000'))
			ques_pcm = processAudio(mysql_cli, question_no, audio_type, audio_content, "", list_id)
			if yuko_button_record.to_s == "1"
				button = " \\# "
			else
				button = " - "
			end
			csvFile.puts(NKF::nkf('-Wsm0', 'r '+ques_pcm+' 1'+button+'0 '+second_record.to_s))
			csvFile.puts(NKF::nkf('-Wsm0', 'g label'+jump_question_next.to_s))
		#カウント
		elsif(question_type == "7")
			csvFile.puts(NKF::nkf('-Wsm0', 'p 1000'))
			csvFile.puts(NKF::nkf('-Wsm0', 'c'))
			csvFile.puts(NKF::nkf('-Wsm0', 'g label'+jump_question_next))
		#文字列認証
		elsif(question_type == "10")
				#タイムアウト飛び先
				timeout_term = false
				auth_item_no = processAuthItemNo(mysql_cli, template_id, auth_item)
				answInfo = queryGetAnsw(mysql_cli, template_id, question_no)
				answInfo.each do | row |
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
				csvFile.puts(NKF::nkf('-Wsm0', 'p 1000'))
				ques_pcm = processAudio(mysql_cli, question_no, audio_type, audio_content, "", list_id)
				csvFile.puts(NKF::nkf('-Wsm0', 'q '+ques_pcm+' 2 ' + digit.to_s))
				#回答飛び先
				if timeout_term == true
					answInfo.each do | row |
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
				answInfo.each do | row |
					answer_no = row[0]
					jump_question = row[1]
					#### 仕様変更。$00、$01・・・$09、$10・・・$99と2桁になる。
					doll_str = auth_item_no < 10 ? "$0" + auth_item_no.to_s : "$" + auth_item_no.to_s
					#=
					if(answer_no == "1")
						csvFile.puts(NKF::nkf('-Wsm0', 'g= \''+doll_str+' label'+question_no.to_s+'_1'))
					#≠
					elsif(answer_no == "2")
						csvFile.puts(NKF::nkf('-Wsm0', 'g label'+question_no.to_s+'_2'))
					end
				end
				#繰返確認
				answInfo.each do | row |
					answer_no = row[0]
					jump_question = row[1]
					if answer_no != "99"
						csvFile.puts(NKF::nkf('-Wsm0', ':label'+question_no.to_s+'_'+answer_no.to_s))
						#再確認
						if(recheck_flag == "1")
							csvFile.puts(NKF::nkf('-Wsm0', 'p 1000'))
							csvFile.puts(NKF::nkf('-Wsm0', 'n'))
							csvFile.puts(NKF::nkf('-Wsm0', 'p 1000'))
							recheck_pcm = processAudio(mysql_cli, question_no, recheck_audio_type, recheck_audio_content, "r", list_id)
							csvFile.puts(NKF::nkf('-Wsm0', 'q '+recheck_pcm+' 2'))
							#csvFile.puts(NKF::nkf('-Wsm0', 'p 1000'))
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
		#SMS
		elsif(question_type == "13")
			sms_localPath = localPathScheduleId + '/indata/sms/' + question_no + '.txt'
			schedule_id = schedule_no.to_i
			authItems = getAllAuthItem(mysql_cli, schedule_id)
			allSmsItems = getSmsItemName(mysql_cli, schedule_id)
			smsContentToFile(sms_localPath, sms_content, authItems, allSmsItems)
			csvFile.puts(NKF::nkf('-Wsm0', 'p 1000'))

			#### 仕様変更。$00、$01・・・$09、$10・・・$99と2桁になる。
			doll_str = "$00"
			csvFile.puts(NKF::nkf('-Wsm0', 'sms ' + doll_str + " " + '/home/robo/var/' + schedule_no.to_s + '/indata/sms/' + question_no + '.txt'))

			#送信失敗時の飛び先を設定
			arr_answer = queryGetAnsw(mysql_cli, template_id, question_no)
			arr_answer.each do | row |
				answer_no = row[0]
				jump_question = row[1]
				if(answer_no == "99")
					csvFile.puts(NKF::nkf('-Wsm0', 'g= 2 label' + jump_question.to_s))
				end
			end

			csvFile.puts(NKF::nkf('-Wsm0', 'g label'+jump_question_next))
		#番号指定SMS
		elsif(question_type == "19")

			arr_answer = queryGetAnsw(mysql_cli, template_id, question_no)
			sms_localPath = localPathScheduleId + '/indata/sms/' + question_no + '.txt'
			schedule_id = schedule_no.to_i
			allSmsItems = getSmsItemName(mysql_cli, schedule_id)
			authItems = getAllAuthItem(mysql_cli, schedule_id)
			smsContentToFile(sms_localPath, sms_content, authItems, allSmsItems)

			#タイムアウト時のセクションを設定
			timeout_term = false
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
			csvFile.puts(NKF::nkf('-Wsm0', 'p 1000'))
			ques_pcm = processAudio(mysql_cli, question_no, audio_type, audio_content, "", list_id)
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
			csvFile.puts(NKF::nkf('-Wsm0', 'p 1000'))
			csvFile.puts(NKF::nkf('-Wsm0', 'n'))
			csvFile.puts(NKF::nkf('-Wsm0', 'p 1000'))
			recheck_pcm = processAudio(mysql_cli, question_no, recheck_audio_type, recheck_audio_content, "r", list_id)
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
			csvFile.puts(NKF::nkf('-Wsm0', 'sms ' + '/home/robo/var/' + schedule_no.to_s + '/indata/sms/' + question_no + '.txt'))

			#送信失敗時のセクションを設定
			arr_answer.each do | row |
				answer_no = row[0]
				jump_question = row[1]
				if(answer_no == "99")
					csvFile.puts(NKF::nkf('-Wsm0', 'g= 2 label' + jump_question.to_s))
				end
			end
			csvFile.puts(NKF::nkf('-Wsm0', 'g label' + jump_question_next.to_s))
		#切断
		elsif(question_type == "8")
			csvFile.puts(NKF::nkf('-Wsm0', 'e'))
		end
	end
	mysql_cli.close()
	csvFile.close
rescue Exception => e
	puts "err_create_file_splist"
	writeLog("err_create_file_splist : " + e.message)
	writeLog("エラー：splistファイルを作成失敗")
	writeLog(e.backtrace.join("\n"))
	sendMailError(schedule_no.to_i)
	exit 9
end