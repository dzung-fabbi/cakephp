# encoding: UTF-8
#=============================================================================
# Contents   : FAXステータス取得
# Author     : Ascend Corp
# Since      : 2016/10/14        1.0
#=============================================================================

load File.join(File.dirname(__FILE__),'../config/AscCommon.rb')
load File.join(File.dirname(__FILE__),'../model/AscM01Server.rb')
load File.join(File.dirname(__FILE__),'../model/AscT25Inbound.rb')
load File.join(File.dirname(__FILE__),'../model/AscT82BukkenFaxStatus.rb')

class AscGetFaxStatus
	#=============================================================================
	# 初期設定
	#
	#=============================================================================
	def initialize
		@ConfigCommon = AscCommon.new
		@ModelM01Server = AscM01Server.new
		@ModelT25Inbound = AscT25Inbound.new		
		@ModelT82BukkenFax = AscT82BukkenFaxStatus.new
		@date_now = Time.now.strftime("%Y%m%d")
	end

	###########################################
	# FAX送信ステータス取得
	###########################################
	def getFaxStatus()
		arr_faxs = @ModelT25Inbound.getFaxSending
		base_url = @ConfigCommon.getFaxApiUrl
		token = @ConfigCommon.getFaxApiToken
		inbound_status = "0"
		finished_flag = true
		prev_inbound_id = "0"
		i = 0
		arr_faxs.each do | row |
			log_id = row[1]
			inbound_id = row[2]
			fax_id = row[5]			
			inbound_status = row[6]
			faxResult = faxGetResult(fax_id, base_url, token)
			if(faxResult["status"] != "送信中")
				@ModelT82BukkenFax.updateStatus(log_id, fax_id, faxResult["status"], faxResult["message"])
			else
				finished_flag = false
			end
			if(prev_inbound_id != inbound_id)
				prev_inbound_id = inbound_id
				# Update fax_flag in t25 when schedule end and all the fax status be updated
				if(i > 0 && finished_flag && inbound_status == @ConfigCommon.getStatusInboundEnd)
					@ModelT25Inbound.updateFaxStatus(prev_inbound_id)
				end
				finished_flag = true
				i = i + 1
			end
		end
		# Update fax_flag in t25 when schedule end and all the fax status be updated
		if(finished_flag && inbound_status == @ConfigCommon.getStatusInboundEnd)
			@ModelT25Inbound.updateFaxStatus(prev_inbound_id)
		end
	rescue Exception => e
		@ConfigCommon.writeLog(e.backtrace.join("\n"))
		exit 9
	end

	###########################################
	# 着信ログファイル取得
	# param : fax_id, base_url, token
	#
	###########################################
	def faxGetResult(fax_id, base_url, token)
	    url = base_url + "/api/v1/facsimiles/" + fax_id + "/transmission"
	    headers={}
	    headers['Content-Type'] = 'application/json'
	    headers['Accept'] = 'text/csv'
	    headers['Authorization'] = 'token ' + token
		http = Curl.get(url) do | http |
		    http.headers['Content-Type'] = 'application/json',
		    http.headers['Accept'] = 'text/csv',
		    http.headers['Authorization'] = 'token ' + token
		end
	    str = http.body_str
	    str = str.encode("UTF-8", "Shift_JIS")
	    status = '送信中'
	    warning_msg = ''
	    if str.include?'application_error_code'
	    	status = 'エラー'
	    	warning_msg = 'Facsimileが存在しません'
	    elsif str.include?'ステータス'
	    	rows = str.split("\n")
	    	if !rows[1].nil?
	    		r = rows[1].split(",")
	    		#送信中の場合
	    		if r.length == 2
	    			status = "送信中"
	    		else
	    			status = r[1]
	    			warning_msg = r[5]
	    		end
	    	end
	    end
		result = {
			"status" => status,
			"message" => warning_msg
		}
		return result
	rescue Exception => e
		puts "get fax from API error"
		@ConfigCommon.writeLog(e.backtrace.join("\n"))
		exit 9
	end
end