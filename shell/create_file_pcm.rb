# encoding: UTF-8
#=============================================================================
# Contents   : 設定フォルダ、ファイル作成
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
begin
	schedule_no = ARGV[0]
	template_id = ARGV[1]
	#DB接続情報
	db_ip = config[:database_ip]
	db_id = config[:database_id]
	db_pass = config[:database_pass]
	db_schema = config[:database_schema]
	localPathSchedule = config[:local_schedule]
	localPathScheduleId = config[:local_schedule] + schedule_no
	localPathIndata = localPathScheduleId + '/indata/'
	localPathPcm = localPathIndata + 'pcm_q/'
	FileUtils.cp(localPathSchedule + "space.pcm", localPathPcm)
	system("chmod 777 " + localPathPcm + "space.pcm")
	#pcm_q作成
	mysql_cli=Mysql.connect(db_ip, db_id, db_pass, db_schema)
	mysql_cli.charset="utf8"
	data=Array.new()
	#質問情報を取る
	queryGetQues = queryGetQues(template_id)
	mysql_cli.query(queryGetQues).each do | row |
		question_no = row[0]
		question_type = row[1]
		audio_id = row[2]
		audio_type = row[3]
		audio_content = row[4]
		trans_timeout_audio_id = row[5]
		trans_timeout_audio_type = row[6]
		trans_timeout_audio_content = row[7]
		recheck_flag = row[8]
		recheck_audio_id = row[9]
		recheck_audio_type = row[10]
		recheck_audio_content = row[11]
		sms_error_audio_type = row[12]
		sms_error_audio_id = row[13]
		sms_error_audio_content = row[14]
		if audio_type == "0"
			unless audio_id.blank?
				if question_type.to_s == "9"
					pcm_filename = "timeout_end_ul.pcm"
				else
					pcm_filename = '1_q'+question_no.to_s+'_ul.pcm'
				end
				path = localPathPcm + pcm_filename
				processGetFilePcm(mysql_cli, audio_id, path)
			end
		elsif (audio_type == "1" || audio_type == "2")
			unless audio_content.blank?			
				arr_text = getArrAudioContent(audio_content)
				i = 1
				arr_text.each do | text |
					if text[0] != "{" && !text.blank?
						if (question_type == "9")
							pcm_filename = "timeout_end_ul.pcm"
						else
							if arr_text.length == 1
								pcm_filename = "1_q"+question_no+"_ul.pcm"
							else
								pcm_filename = "1_q"+question_no+"_ul_"+i.to_s+".pcm"
							end
						end
						processGetFilePcmMix(mysql_cli, text, localPathPcm, pcm_filename, audio_type)
					end
					i = i + 1
				end
			end
		end
		#数値認証・番号入力・文字列認証
		if recheck_flag.to_s == "1" && (question_type.to_s == "3" || question_type.to_s == "4" || question_type.to_s == "10" || question_type.to_s == "19")
			if recheck_audio_type.to_s == "0"
				pcm_filename = '1_q'+question_no.to_s+'_ul_r.pcm'
				path = localPathPcm + pcm_filename
				processGetFilePcm(mysql_cli, recheck_audio_id, path)
			else
				arr_text = recheck_audio_content.split(/{.*?}/u).reject { |c| c.empty? }
				i = 1
				arr_text.each do | text |
					if arr_text.length == 1
						pcm_filename = "1_q"+question_no+"_ul_r.pcm"
					else
						pcm_filename = "1_q"+question_no+"_ul_r_"+i.to_s+".pcm"
					end
					processGetFilePcmMix(mysql_cli, text, localPathPcm, pcm_filename, recheck_audio_type.to_s)
					i = i + 1
				end
			end
		end
		#セクションが「SMS」もしくは「番号指定SMS」の場合、送信不可音声作成
		if (question_type.to_s == "13" || question_type.to_s == "19")
			pcm_filename = 'sms_error_message.pcm'
			path = localPathPcm + pcm_filename
			#音声ファイルの場合
			if sms_error_audio_type.to_s == "0"
				processGetFilePcm(mysql_cli, sms_error_audio_id, path)
			#音声合成の場合
			else
				processGetFilePcmMix(mysql_cli, sms_error_audio_content, localPathPcm, pcm_filename, sms_error_audio_type.to_s)
			end
		end
	end
	mysql_cli.close()
rescue Exception => e
	puts "err_create_file_pcm"
	writeLog("err_create_file_pcm : " + e.message)
	writeLog("エラー：pcm_qファイルを作成失敗")
	writeLog(e.backtrace.join("\n"))
	sendMailError(schedule_no.to_i)
	exit 9
end