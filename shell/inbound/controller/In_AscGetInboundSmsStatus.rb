# encoding: UTF-8
#=============================================================================
# Contents   : FAXステータス取得
# Author     : Ascend Corp
# Since      : 2016/10/14        1.0
#=============================================================================

load File.join(File.dirname(__FILE__),'../config/AscCommon.rb')
load File.join(File.dirname(__FILE__),'../model/AscM01Server.rb')
load File.join(File.dirname(__FILE__),'../model/AscT25Inbound.rb')
load File.join(File.dirname(__FILE__),'../model/AscT86InboundSmsStatus.rb')

class AscGetInboundSmsStatus
	#=============================================================================
	# 初期設定
	#
	#=============================================================================
	def initialize
		@ConfigCommon = AscCommon.new		
		@ModelT86InboundSmsStatus = AscT86InboundSmsStatus.new
		@date_now = Time.now.strftime("%Y%m%d")
	end

	###########################################
	# FAX送信ステータス取得
	###########################################
	def getInboundSmsStatus()
		program_name = "[Inbound SMSステータス取得]"
		smsSendingData = @ModelT86InboundSmsStatus.getSendingInfo
		if smsSendingData.length > 0
			smsSendingData.each do | row |
				sms_api_config = {}
				log_id = row[0]
				inbound_id = row[1]
				template_id = row[2]
				sms_question_no = row[4]
				sms_entry_id = row[5]
				sms_api_config["service_id"] = row[7]
				sms_api_config["url"] = row[8]
				sms_api_config["group_id"] = row[9]
				sms_api_config["user"] = row[10]
				sms_api_config["pass"] = row[11]
				sms_api_config["api_id"] = row[13]

				inbound_no = "000000".slice(1..6-inbound_id.to_s.length) + inbound_id.to_s
				if(sms_api_config["api_id"] == $SMS_API_V2_VALUE)
					send_result = @ModelT86InboundSmsStatus.getSmsStatusFromApi_V2(sms_api_config, sms_entry_id)
					@ConfigCommon.writeLog(program_name + inbound_no + " SMS-APIv2ステータス取得 ：　OK")
					@ModelT86InboundSmsStatus.insertGetSmsStatusHistories_V2(send_result, row)
					@ConfigCommon.writeLog(program_name + inbound_no + " SMS-APIv2ステータス取得ログをインサート ：　OK")
					@ModelT86InboundSmsStatus.updateSmsStatus_V2(send_result, log_id, inbound_id, template_id, sms_question_no, sms_entry_id)
					@ConfigCommon.writeLog(program_name + inbound_no + " SMS-APIv2ステータス更新 ：　OK")
				# 2019-12-25 V1ステータス更新停止
				#else
				#send_result = @ModelT86InboundSmsStatus.getSmsStatusFromApi(sms_api_config, sms_entry_id)
				#@ConfigCommon.writeLog(program_name + inbound_no + " SMSステータス取得 ：　OK")
				#@ModelT86InboundSmsStatus.insertGetSmsStatusHistories(send_result)
				#@ConfigCommon.writeLog(program_name + inbound_no + " SMSステータス取得ログをインサート ：　OK")
				#@ModelT86InboundSmsStatus.updateSmsStatus(send_result, log_id, inbound_id, template_id, sms_question_no, sms_entry_id)
				#@ConfigCommon.writeLog(program_name + inbound_no + " SMSステータス更新 ：　OK")
				end
			end
		end
	rescue Exception => e
		@ConfigCommon.writeLog(program_name + "エラー： Inbound SMSステータス取得バッチ実行：失敗 - " + e.message)
		@ConfigCommon.writeLog(e.backtrace.join("\n"))
		#@ConfigCommon.sendMailError('')
		exit 9
	end
end