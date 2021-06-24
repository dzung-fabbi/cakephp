# encoding: UTF-8
#=============================================================================
# Contents   : 着信ログファイル取得
# Author     : Ascend Corp
# Since      : 2016/04/14        1.0
#=============================================================================

load File.join(File.dirname(__FILE__),'../config/AscCommon.rb')
load File.join(File.dirname(__FILE__),'../model/AscM01Server.rb')
load File.join(File.dirname(__FILE__),'../model/AscT25Inbound.rb')
load File.join(File.dirname(__FILE__),'../model/AscT82BukkenFaxStatus.rb')
load File.join(File.dirname(__FILE__),'../model/AscT64InboundQuestionHistory.rb')
load File.join(File.dirname(__FILE__),'../model/AscT31TemplateQuestion.rb')
load File.join(File.dirname(__FILE__),'../model/AscT86InboundSmsStatus.rb')

class AscGetCsvResult
	#=============================================================================
	#　初期設定
	#
	#=============================================================================
	def initialize
		@ConfigCommon = AscCommon.new
		@ModelM01Server = AscM01Server.new
		@ModelT25Inbound = AscT25Inbound.new
		@ModelT64Ques = AscT64InboundQuestionHistory.new
		@ModelT82BukkenFax = AscT82BukkenFaxStatus.new
		@ModeT31 = AscT31TemplateQuestion.new
		@ModeT86 = AscT86InboundSmsStatus.new
		@local_path = @ConfigCommon.localPathInbound
		@remote_path = @ConfigCommon.remotePathInbound
		@db_id = @ConfigCommon.getDatabaseId
		@db_pass = @ConfigCommon.getDatabasePass
		@db_schema = @ConfigCommon.getDatabaseSchema
		@retried = 0
		@limit = 5
		@date_now = Time.now.strftime("%Y%m%d")
		@QUESTION_VOICE = @ConfigCommon.getQuesVoiceCode
		@QUESTION_BASIC = @ConfigCommon.getQuesBasicCode
		@QUESTION_AUTH = @ConfigCommon.getQuesAuthCode
		@QUESTION_TEL = @ConfigCommon.getQuesTelCode
		@QUESTION_TRANS = @ConfigCommon.getQuesTransCode
		@QUESTION_RECORD = @ConfigCommon.getQuesRecordCode
		@QUESTION_COUNT = @ConfigCommon.getQuesCountCode
		@QUESTION_END = @ConfigCommon.getQuesEndCode
		@QUESTION_TIMEOUT = @ConfigCommon.getQuesTimeoutCode
		@QUESTION_AUTH_CHAR = @ConfigCommon.getQuesAuthCharacterCode
		@QUESTION_PROPERTY = @ConfigCommon.getQuesPropertyCode
		@QUESTION_FAX = @ConfigCommon.getQuesFaxCode
		@QUESTION_INBOUND_SMS = @ConfigCommon.getQuesInboundSmsCode
		@QUESTION_INBOUND_SMS_INPUT = @ConfigCommon.getQuesInboundSmsInputCode
	end

	###########################################
	# 着信ログファイル取得
	# filename csv format : xxx_YYYYMMDD.csv
	#
	###########################################
	def getCsvResult()
		server_inbound_type = @ConfigCommon.getServerInboundType
		arr_servers = @ModelM01Server.getInfoServerByServerType(server_inbound_type)
		arr_servers.each do | arr_server |
			server_id = arr_server[0]
			server_ip = arr_server[1]
			server_port = arr_server[2]
			arr_inbounds = @ModelT25Inbound.getInfoInboundMessageByServerId(server_id)
			arr_inbounds.each do | arr_inbound |
				inbound_id = arr_inbound[0]
				inbound_no = "000000".slice(1..6-inbound_id.to_s.length) + inbound_id.to_s
				local_inbound_path = @local_path + "/" + inbound_no
				remote_inbound_path = @remote_path + "/" + inbound_no
				#ファイルをダウンロード
				if server_port.blank?
					#scp -r 10.1.1.131:/home/robo/var_in/000001/csv/ /home/ftpuser/shell/inbound/schedule/000001/
					system("scp " + server_ip + ":" + remote_inbound_path + "/csv/*" + @date_now +".csv" + " " + local_inbound_path + "/csv/")
				else
					#scp -r -P xxx 10.1.1.131:/home/robo/var_in/000001/csv/ /home/ftpuser/shell/inbound/schedule/000001/
					system("scp -P " + server_port + " " + server_ip + ":" + remote_inbound_path + "/csv/*" + @date_now +".csv" + " " + local_inbound_path + "/csv/")
				end
				system("cat " + local_inbound_path + "/csv/*" + @date_now +".csv > " + local_inbound_path + "/csv/all" + @date_now +".csv")
				#DBにインポートする
				system("sh " + File.dirname(__FILE__) + "/load_data.sh " + @db_id + " " + @db_pass + " " + @db_schema + " " + local_inbound_path + "/csv/all" + @date_now + ".csv " + inbound_id)
				#ファイル削除
				system("rm -rf " + local_inbound_path + "/csv/*.csv")
				insertFaxInfo(inbound_id)
				insertSmsInfo(inbound_id)
			end
		end
	end

	###########################################
	# 着信ログファイル取得
	# param : server_id, inbound_id
	#
	###########################################
	def getCsvResultByServerIdInboundId(server_id, inbound_id)
		inbound_no = "000000".slice(1..6-inbound_id.to_s.length) + inbound_id.to_s
		local_inbound_path = @local_path + "/" + inbound_no
		remote_inbound_path = @remote_path + "/" + inbound_no
		arr_servers = @ModelM01Server.getInfoServerByServerId(server_id)
		arr_servers.each do | arr_server |
			server_id = arr_server[0]
			server_ip = arr_server[1]
			server_port = arr_server[2]
			server_user = arr_server[3]
			#ファイルをダウンロード
			if server_port.blank?
				#scp -r 10.1.1.131:/home/robo/var_in/000001/csv/ /home/ftpuser/shell/inbound/schedule/000001/
				system("scp " + server_ip + ":" + remote_inbound_path + "/csv/*" + @date_now +".csv" + " " + local_inbound_path + "/csv/")
				#@ConfigCommon.writeLog("scp " + server_user + "@" + server_ip + ":" + remote_inbound_path + "/csv/*" + @date_now +".csv" + " " + local_inbound_path + "/csv/")
			else
				#scp -r -P xxx 10.1.1.131:/home/robo/var_in/000001/csv/ /home/ftpuser/shell/inbound/schedule/000001/
				system("scp -P " + server_port + " " + server_ip + ":" + remote_inbound_path + "/csv/*" + @date_now +".csv" + " " + local_inbound_path + "/csv/")
				#@ConfigCommon.writeLog("scp -P " + server_port + " " + server_user + "@" + server_ip + ":" + remote_inbound_path + "/csv/*" + @date_now +".csv" + " " + local_inbound_path + "/csv/")
			end
			@ConfigCommon.writeLog("【" + inbound_id + "】csvファイル取得 ： OK")
			system("cat " + local_inbound_path + "/csv/*" + @date_now +".csv > " + local_inbound_path + "/csv/all" + @date_now +".csv")
			#DBにインポートする
			system("sh " + File.dirname(__FILE__) + "/load_data.sh " + @db_id + " " + @db_pass + " " + @db_schema + " " + local_inbound_path + "/csv/all" + @date_now + ".csv " + inbound_id)
			@ConfigCommon.writeLog("【" + inbound_id + "】csvファイルロードデータ ： OK")
			#ファイル削除
			system("rm -rf " + local_inbound_path + "/csv/*.csv")
			insertFaxInfo(inbound_id)
			insertSmsInfo(inbound_id)
			updateFaxFlag(inbound_id)
		end
	end

	###########################################
	# 着信ログファイル取得
	# @param : inbound_id
	#
	###########################################
	def insertFaxInfo(inbound_id)
		template_id = '0'
		question_no = '0'
		answer_pos = '0'
		existed_fax_ques = false
	    arr_answer_pos = getAnswerPos(inbound_id)
	    inbounds = @ModelT25Inbound.getInfoByInboundId(inbound_id)
	    inbounds.each do | row |
	    	template_id = row[2]	    	
	    end
	    questions = @ModelT64Ques.getQuesByScheduleId(inbound_id)
		questions.each do | row |
			question_no = row[1]
			question_type = row[2]
			if(question_type == @QUESTION_FAX)
				existed_fax_ques = true
				answer_pos = arr_answer_pos[question_no]
				if(template_id != '0')
					@ModelT82BukkenFax.insertFaxInfoFromLog(inbound_id, template_id, question_no, answer_pos)
				end
			end
		end
	rescue Exception => e
		puts "error"
		@ConfigCommon.writeLog(e.backtrace.join("\n"))
		#exit 9
	end

	###########################################
	# 発信ログファイル取得
	# @param : inbound_id
	#
	###########################################
	def insertSmsInfo(inbound_id)
		template_id = '0'
		company_id = '0'
		question_no = '0'
		answer_pos = '0'
	    inbounds = @ModelT25Inbound.getInboundById(inbound_id)
	    inbounds.each do | row |
	    	template_id = row[2]
	    	company_id = row[1]
	    end
		if(template_id != '0')
			if @ModeT31.hasSmsQues(template_id)
				arr_answer_pos = getAnswerPos(inbound_id)
				questions = @ModelT64Ques.getQuesByScheduleId(inbound_id)
				questions.each do | row |
					question_no = row[1]
					question_type = row[2]
					if(question_type == @QUESTION_INBOUND_SMS || question_type == @QUESTION_INBOUND_SMS_INPUT)
						sms_display_number = row[7]
						answer_pos = arr_answer_pos[question_no]
						@ModeT86.insertSmsInfoFromLog(inbound_id, company_id, sms_display_number, template_id, question_no, answer_pos)
					end
				end
	    	end
	    end
	rescue Exception => e
		puts "error"
		@ConfigCommon.writeLog("insertInboundSmsInfo: " + e.message)
		@ConfigCommon.writeLog(e.backtrace.join("\n"))
		#exit 9
	end
	###########################################
	# 着信ログファイル取得
	# @param : inbound_id
	#
	###########################################
	def getAnswerPos(inbound_id)
		# Define answer of offset for each question type
		# QuesVoice 			Have no answer
		# QuesBasic 			Answer have one column (answer number)
		# QuesAuth 				If repeat flag is false, answer have one column (input value)
		#  						If repeat flag is true, answer have four columns (input value, > of repeat number, = of repeat number, < of repeat number)
		# QuesTel 				If repeat flag is false, answer have two column (input value)
		#  						If repeat flag is true, answer have two columns (input value, repeat number)
		# QuesTrans 			Have no answer
		# QuesRecord 			Have no answer
		# QuesCount				Answer have one column (count)
		# QuesEnd 				Have no answer
		# QuesTimeout 			Have no answer
		# QuesAuthChar 			If repeat flag is false, answer have one column (input value)
		#  						If repeat flag is true, answer have three columns (input value, = of repeat number, # of repeat number)
		# QuesProperty 			Answer have seven column
		# QuesFax 				Answer have five collumn
		# QuesInboundSms		Answer have one collumn
		# QuesInboundSmsInput	Answer have three collumn
		arr_answer_offset = {
			@ConfigCommon.getQuesVoiceCode => 0,
			@ConfigCommon.getQuesBasicCode => 1,
			@ConfigCommon.getQuesAuthCode => {'0' => 1, '1' => 4},
			@ConfigCommon.getQuesTelCode => {'0' => 1, '1' => 2},
			@ConfigCommon.getQuesTransCode => 0,
			@ConfigCommon.getQuesRecordCode => 0,
			@ConfigCommon.getQuesCountCode => 1,
			@ConfigCommon.getQuesEndCode => 0,
			@ConfigCommon.getQuesTimeoutCode => 0,
			@ConfigCommon.getQuesAuthCharacterCode => {'0' => 1, '1' => 3},
			@ConfigCommon.getQuesPropertyCode => 7,
			@ConfigCommon.getQuesFaxCode => 5,
			@ConfigCommon.getQuesInboundSmsCode => 1,
			@ConfigCommon.getQuesInboundCollationCode => 1,
			@ConfigCommon.getQuesInboundSmsInputCode => 3
		}
		# The first question
		current_pos = 0
		# array of answer position for earch question
		arr_answer_pos = {}
		# Get all the question of schedule
		questions = @ModelT64Ques.getQuesByScheduleId(inbound_id)

		questions.each do | row |
			question_no = row[1]
			question_type = row[2]
			recheck_flag = row[3]
			if [@QUESTION_AUTH, @QUESTION_TEL, @QUESTION_AUTH_CHAR].include? question_type
				count_column = arr_answer_offset[question_type][recheck_flag]
			else
				count_column = arr_answer_offset[question_type]
			end

			if count_column.to_i > 0
				current_pos += count_column.to_i
				arr_answer_pos[question_no] = current_pos
			elsif question_type == @QUESTION_TRANS
				arr_answer_pos[question_no] = 'trans_call_time'
			else
				arr_answer_pos[question_no] = ''
			end

		end
		return arr_answer_pos
	end
	###########################################
	# 着信設定を切り替えるとき、T25のbukken_fax_flagを更新する
	# @param : inbound_id
	#
	###########################################
	def updateFaxFlag(inbound_id)
		existed_fax_ques = false
		questions = @ModelT64Ques.getQuesByScheduleId(inbound_id)
		questions.each do | row |
			question_no = row[1]
			question_type = row[2]
			if(question_type == @QUESTION_FAX)
				existed_fax_ques = true				
			end
		end
		if existed_fax_ques
			arr = @ModelT25Inbound.countFaxSendingByInboundId(inbound_id)
			count = "0"
			arr.each do | row |
				count = row[0]
			end
			if count == "0"
				@ModelT25Inbound.updateFaxStatus(inbound_id)
			end
		end
	end
end