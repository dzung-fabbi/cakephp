# encoding: UTF-8
#=============================================================================
# Contents   : SmsStatusモデル
# Author     : Ascend Corp
# Since      : 2017/10/03        1.0
#=============================================================================
load File.join(File.dirname(__FILE__),'../config/AscCommon.rb')
class AscT86InboundSmsStatus
	#=============================================================================
	#　初期設定
	#=============================================================================
	def initialize
		@common = AscCommon.new
		@mysql_cli = @common.connectDB
	end

	#=============================================================================
	#　着信設定情報を取る
	# param : inbound_id
	# return : array
	#=============================================================================
	def hasSmsSending(inbound_id)
		data = Array.new()
		query = <<EOS
		select
			count(t86.id)
		from
			t86_inbound_sms_statuses t86
	    where
	    	t86.inbound_id = '#{inbound_id}' and
	    	t86.sms_status = 'sending' and
	    	t86.del_flag = 'N'
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
	#　スケジュールの情報を取得
	# @param	: inbound_id
	# @return	: array|NULL
	# @author 	: Hungnv
	#=============================================================================
	def getSendingInfo()
		data = Array.new()
		query = <<EOS
			select  t86.log_id,
					t86.inbound_id,
					t86.template_id,
					t86.tel_no,
					t86.sms_question_no,
					t86.sms_entry_id,
					t86.sms_status,
					m08.service_id,
					m08.url,
					m08.group_id,
					m08.user,
					m08.pass,
					m08.batch_sleep_time,
					m08.api_id
			from t86_inbound_sms_statuses t86
			join m08_sms_api_infos m08
			on t86.company_id = m08.company_id
			and t86.display_number = m08.display_number
			and ((m08.role_code = '20' and m08.api_id != '2') or m08.api_id = '2')
			where t86.sms_status = 'sending'
			and t86.del_flag = 'N'
			and m08.del_flag = 'N'
			and m08.api_id = '2';
EOS
		@mysql_cli.query(query).each do | row |
			data = data + Array.new(1, row)
		end
		return data
	end

	#=============================================================================
	#　v2向けSMSステータスを取得(API_V2用)
	# @param	: array sms_api_config
	# @return	: json
	# @author 	: kuniyoshi
	#=============================================================================
	def getSmsStatusFromApi_V2(sms_api_config, entry_id)
		#### user="Token"  pass="SecurityCode"  
    	url = "#{sms_api_config['url']}karadeninquiry.json?Token=#{sms_api_config['service_id']}&messageId=#{entry_id}&SecurityCode=#{sms_api_config['pass']}&format=json"
		@common.writeLog("getSmsStatusFromApi_V2::#{url}")
		ch = Curl::Easy.new(url)
		ch.follow_location = true
		ch.ftp_response_timeout = 60
		# tls_v1.2で動くように細工する
		ch.use_ssl = 1
		ch.ssl_version = 1.2
		ch.perform
		result = JSON.parse(ch.body_str)
		@common.writeLog("getSmsStatusFromApi_V2::#{entry_id}::#{result}")
		return result
	end

	#=============================================================================
	#　SMSステータスを取得
	# @param	: array sms_api_config
	# @return	: json
	# @author 	: Hungnv
	#=============================================================================
	def getSmsStatusFromApi(sms_api_config, entry_id)
		url = sms_api_config['url'] + "/" + sms_api_config['group_id'] + "/getSendResult2.php?entry_id=" + entry_id
		ch = Curl::Easy.new(url)
		ch.headers['Authorization'] =  'Basic ' + Base64.encode64(sms_api_config['user'] + ':' + sms_api_config['pass'])
		ch.follow_location = true
		ch.ftp_response_timeout = 60
		# tls_v1.2で動くように細工する
		ch.use_ssl = 1
		ch.ssl_version = 1.2
		ch.perform
		result = JSON.parse(ch.body_str)	
		return result
	end

	#=============================================================================
	#　SMS送信ステータス取得APIから返ってくる値を処理してDBにステータスを更新(API_V2用)
	# @param	: mysql_cli
	# @param	: send_result		APIから返ってくるJsonデータ
	# @param	: log_id
	# @param	: schedule_id
	# @param	: template_id
	# @param	: sms_question_no
	# @param	: sms_entry_id
	# @author 	: kuniyoshi
	#=============================================================================
	def updateSmsStatus_V2(send_result, log_id, schedule_id, template_id, sms_question_no, sms_entry_id)
		warning_msg = '不明'
		status = 'fail'
		sms_short_url_key = ''
		# 結果取得APIのステータスが100以外は失敗とみなす。
		if !(defined? send_result["status"])
			status = 'fail'
		elsif send_result["status"].to_s == "100"
			# メッセージの状態がない場合は、失敗とみなす。
			if defined?send_result["messagestatus"]
				status_code = send_result["messagestatus"].to_s
				# 待ち状態は、再度APIを叩く。
				if (status_code == "0")
					return false
				else
					# メッセージの状態が「SMS送信サービスと各キャリア間」でエラーとなっている場合は、失敗とみなす。
					# 2→SMS送信エラー　　　　　	　　　　　　　　　→APIがキャリアへの送信失敗。（ユーザーに届いていない状態確定。）
					# 3→履歴判定結果によるSMS送信エラー  →携帯番号履歴判定でAPIがキャリアへの送信失敗。（ユーザーに届いていない状態確定。）
					# 9→不明　　　　　　　　　　　　　　　　　　　  →携帯番号履歴判定でAPIがキャリアへの送信失敗。（ユーザーに届いたか、不明な状態。）
					if (status_code != "1") 
						status = "fail"
						if(status_code == "2")
							warning_msg = "SMS送信エラー"
						elsif(status_code == "3")
							warning_msg = "履歴判定結果によるSMS送信エラー"
						elsif(status_code == "9")
							warning_msg = "不明"
						else
							warning_msg = "不明messagestatusコード(#{status_code})"
						end
					# 送信結果が存在しない場合は、失敗とみなす。
					elsif defined?send_result["resultstatus"]
		                send_status = send_result["resultstatus"].to_s
						# 送信結果コード0（送信結果なし。まだ送信中なので、待つ。）
						if(send_status == "0")
							return false
						elsif(send_status == "1")
							status = "success"
							warning_msg = ""
						elsif(send_status == "2")
							status = "outside"
							warning_msg = "圏外"
						elsif(send_status == "3")
							status = "fail"
							warning_msg = "エラー"
						elsif(send_status == "99")
							status = "unknown"
							warning_msg = "不明"
						else
							status = "unknown"
							warning_msg = "不明resultstatusコード(#{send_status})"
						end
					elsif status_code == "1" && send_result["carrier"] == "5"
						# キャリアコード5（判別中）が追加されたため、ステータスを「unknown」にする。
						# ※不明にすることを顧客確認済み。
						status = "unknown"
						warning_msg = "不明"
					end
					# 短縮URLの文字列を抜き出す（配列が戻る。）
					sms_messages = getCareerMsg_V2(send_result).scan(/https:\/\/kps.ms\/[A-Za-z0-9]{7}/)
					sms_messages.each do |sms_message|
						sms_message = sms_message.gsub(/https:\/\/kps.ms\//, "")
						if sms_short_url_key == ""
							sms_short_url_key = sms_message
						else
							sms_short_url_key = sms_short_url_key + ":" + sms_message
						end
					end
				end
			end
		end

		query = <<EOS
		UPDATE t86_inbound_sms_statuses
		SET 
			sms_status = '#{status}',
			message = '#{warning_msg}',
			sms_short_url_key = '#{sms_short_url_key}',
			modified = now(),
			update_program = 'mega_crontab_getSmsStatus'
		WHERE
			log_id = '#{log_id}' and 
			inbound_id = '#{schedule_id}' and 
			template_id = '#{template_id}' and 
			sms_question_no = '#{sms_question_no}' and 
			sms_entry_id = '#{sms_entry_id}' and
			del_flag = 'N'
EOS
			@mysql_cli.query(query)
	end

	#=============================================================================
	#　SMS送信ステータス取得APIから返ってくる値を処理してDBにステータスを更新
	# @param	: mysql_cli
	# @param	: send_result		APIから返ってくるJsonデータ
	# @param	: log_id
	# @param	: inbound_id
	# @param	: template_id
	# @param	: sms_question_no
	# @param	: sms_entry_id
	# @author 	: Hungnv
	#=============================================================================
	def updateSmsStatus(send_result, log_id, inbound_id, template_id, sms_question_no, sms_entry_id)
		warning_msg = '不明'
		status = 'fail'
		if send_result["Result"]["Status"].upcase == "SUCCESS"
			# 処理に成功したが、条件該当するレコードなかっ場合
			# Send request to getstatus OK but no records be returned.Ex: Invalid entry_id case
			if send_result["Result"]["Count"] == "0"
				status = 'fail'
			else
				# Check record of status code
				if defined?send_result["Result"]["Records"][0]["status"]
					status_code = send_result["Result"]["Records"][0]["status"]
					status_code = status_code.to_s
					# 5: au再送待ち. 6: 処理中. 15: ドコモ再送待ち. 25:ソフトバンク再送待ち. 35: その他キャリア再送待ち
					# 5: au wait to resend. 6: sending. 15: docomo wait to resend. 25: softbank wait to resend. 35: other wait to resend  
					if (status_code == "5" || status_code == "6" || status_code == "15" || status_code == "25" || status_code == "35")
						return false
					else
						send_status = send_result["Result"]["Records"][0]["send_result"]
						carrier_id = send_result["Result"]["Records"][0]["carrier_id"]
						carrier_id = carrier_id.to_s
						if(send_status == "着信済み")
							status = "success"
						elsif((carrier_id == "4" || carrier_id == "9") && send_status == "")# Other carrier: Can't know success or fail
							status = "unknown"
						elsif(send_status == "圏外")  # sent fail
							status = "outside"
						else 
							status = "fail"
						end
						send_rs = nil
						rs_status = nil
						cmd_status = nil
						network_code = nil
						if defined?send_result["Result"]["Records"][0]["send_result"]
							send_rs = send_result["Result"]["Records"][0]["send_result"]
						end
						if defined?send_result["Result"]["Records"][0]["result_status"]
							rs_status = send_result["Result"]["Records"][0]["result_status"]
						end
						if defined?send_result["Result"]["Records"][0]["command_status"]
							cmd_status = send_result["Result"]["Records"][0]["command_status"]
						end
						if defined?send_result["Result"]["Records"][0]["network_error_code"]
							network_code = send_result["Result"]["Records"][0]["network_error_code"]
						end
						warning_msg = getWarningMsg(carrier_id, send_rs, rs_status, cmd_status, network_code)					
					end
				end
			end
		elsif send_result["Result"]["Status"].upcase == "FAIL"
			status = "fail"
		end

		query = <<EOS
		UPDATE t86_inbound_sms_statuses
		SET 
			sms_status = '#{status}',
			message = '#{warning_msg}',
			modified = now(),
			update_program = 'get_inbound_sms_status'
		WHERE
			log_id = '#{log_id}' and 
			inbound_id = '#{inbound_id}' and 
			template_id = '#{template_id}' and 
			sms_question_no = '#{sms_question_no}' and 
			sms_entry_id = '#{sms_entry_id}' and
			del_flag = 'N'
EOS
			@mysql_cli.query(query)
	end

	#=============================================================================
	#　SMS送信ステータス取得の履歴をDBにインサートする(API_V2用)
	# @param	: result		APIから返ってくるJsonデータ
	# @param	: sending_info_row		getSendingInfoの戻り値
	# @author 	: kuniyoshi
	#=============================================================================
	def insertGetSmsStatusHistories_V2(result, sending_info_row)
		if result.nil?
			return false
		else
			#{"auMessage"=>"<SMSメッセージ>", "carrier"=>"2", "click"=>"0", "docomoMessage"=>"<SMSメッセージ>", 
			# "messagestatus"=>"1", "optionMessage"=>"<SMSメッセージ>", 
			# "resultstatus"=>"1", "senddate"=>"2018/03/13 22:04:48", "softbankMessage"=>"<SMSメッセージ>, "status"=>"100"}

			#### API-V1との違い
			#### ResCountはApiV2では設定がありません。（NULLとします。）
			#### group_idはApiV2では設定がありません。（NULLとします。）
			#### service_idはApiV2では設定がありません。（NULLとします。）
			#### userはApiV2では設定がありません。（NULLとします。）
			#### use_cr_findはApiV2では設定がありません。（NULLとします。）
			#### message_noはApiV2では設定がありません。（NULLとします。）
			#### encodeはApiV2では設定がありません。（NULLとします。）
			#### req_statはApiV2では設定がありません。（NULLとします。）
			#### permit_timeはApiV2では設定がありません。（NULLとします。）
			#### sent_dateはApiV2では設定がありません。（NULLとします。）
			#### command_statusはApiV2では設定がありません。（NULLとします。）
			#### network_error_codeはApiV2では設定がありません。（NULLとします。）
			#### tracking_codeはApiV2では設定がありません。（NULLとします。）
			#### partition_sizeはApiV2では設定がありません。（NULLとします。）
			#### use_jdg_findはApiV2では設定がありません。（NULLとします。）
			#### resErrorCodeはApiV2では設定がありません。（NULLとします。）
			#### send_resultはApiV2では設定がありません。（NULLとします。）

			#### API_V2 のclickは、クリック回数なので保存しません。

			# 送信要求受付ID
			# V2：該当パラメータなし。→本API（結果取得）実行時のGetパラメータ「messageId」の値を設定する。
			# t83.sms_entry_idをコピーする。
			entry_id = sending_info_row[5]

			# ステータスコード(APIそのもののステータス)
			# V2：status：ステータスコード API の処理結果を返却
			# コードを保持する(201など。)
			resStatus = getApiValue_V2(result, "status")

			# 送信要求受付日時 = SMSを送信した日時
			# 2018-02-20 19:06:29
			# V2：「senddate」の値を設定する。
			create_date = getApiValue_V2(result, "senddate")

			# 宛先電話番号
			# t83.tel_noをコピーする。
			to_address = sending_info_row[3]

			# 送信された携帯キャリア ID
			# 送信要求時に指定した SMS 本文（送信したキャリアの値を設定する）
			carrier_id = getApiValue_V2(result, "carrier")
			
			if carrier_id == "5"
				message = "不明 キャリアID（" + carrier_id + ")"
			else
				message = @common.escape_str(getCareerMsg_V2(result))
			end

			# メッセージ状態コード
			# APIから各キャリアへの転送ステータス
			# 0→SMS受付完了(但し、未送信)　　　　　→0の場合はまだSMSは送られていないので、待つ。（次の周期で再度チェックする。）
			# 1→SMS送信完了　　　　　　　　　　　　　　　→キャリアからの送信結果待ち。resultstatusを参照する。
			# 2→SMS送信エラー　　　　　	　　　　　　　　　→APIがキャリアへの送信失敗。（ユーザーに届いていない状態確定。）
			# 3→履歴判定結果に寄るSMS送信エラー  →携帯番号履歴判定でAPIがキャリアへの送信失敗。（ユーザーに届いていない状態確定。）
			# 9→不明　　　　　　　　　　　　　　　　　　　  →携帯番号履歴判定でAPIがキャリアへの送信失敗。（ユーザーに届いたか、不明な状態。）
			status = getApiValue_V2(result, "messagestatus")

			# 詳細なステータス()
			result_status = getApiValue_V2(result, "resultstatus")

			query = <<EOS
				insert into t87_inbound_getsmsstatus_histories(entry_id, ResStatus, create_date, 
					to_address,carrier_id,message,
					status,result_status,
					created,entry_user
				)
				values(
					'#{entry_id}',
					'#{resStatus}',
					'#{create_date}',
					'#{to_address}',
					'#{carrier_id}',
					'#{message}',
					'#{status}',
					'#{result_status}',
					NOW(),
					'mega_crontab_getSmsStatus_API_V2'
				);
EOS
			@mysql_cli.query(query)
		end	
	end

	 #============================================================================================
	 # APIからの戻り値、キーが有るかを判定しあればその値を戻す。無ければ空欄を戻す。
	 #
	 # @param：result　APIからの戻り値
	 # @param：result　欲しい情報のキー
	 #============================================================================================
	def getApiValue_V2(result, access_key)
		if defined? result[access_key]
			return result[access_key]
		end
		return ""
	end


	#=============================================================================
	#　SMS送信ステータス取得の履歴をDBにインサートする
	# @param	: mysql_cli
	# @param	: result		APIから返ってくるJsonデータ
	# @author 	: Hungnv
	#=============================================================================
	def insertGetSmsStatusHistories(result)
		if result.nil?
			return false
		else
			rs = result["Result"]
			unless defined? rs["Status"]
				resStatus = ""
			else
				resStatus = rs["Status"]
			end
			unless defined? rs["Count"]
				resCount = ""
			else
				resCount = rs["Count"]
			end
			unless defined? rs["ErrorCode"]
				resErrorCode = ""
			else
				resErrorCode = rs["ErrorCode"]
			end
			unless defined? rs["Records"][0]["create_date"]
				create_date = ""
			else
				create_date = rs["Records"][0]["create_date"]
			end

			unless defined? rs["Records"][0]["entry_id"]
				entry_id = ""
			else
				entry_id = rs["Records"][0]["entry_id"]
			end
			unless defined? rs["Records"][0]["req_stat"]
				req_stat = ""
			else
				req_stat = rs["Records"][0]["req_stat"]
			end
			unless defined? rs["Records"][0]["group_id"]
				group_id = ""
			else
				group_id = rs["Records"][0]["group_id"]
			end
			unless defined? rs["Records"][0]["service_id"]
				service_id = ""
			else
				service_id = rs["Records"][0]["service_id"]
			end
			unless defined? rs["Records"][0]["user"]
				user = ""
			else
				user = rs["Records"][0]["user"]
			end
			unless defined? rs["Records"][0]["to_address"]
				to_address = ""
			else
				to_address = rs["Records"][0]["to_address"]
			end
			unless defined? rs["Records"][0]["use_cr_find"]
				use_cr_find = ""
			else
				use_cr_find = rs["Records"][0]["use_cr_find"]
			end
			unless defined? rs["Records"][0]["carrier_id"]
				carrier_id = ""
			else
				carrier_id = rs["Records"][0]["carrier_id"]
			end
			unless defined? rs["Records"][0]["message_no"]
				message_no = ""
			else
				message_no = rs["Records"][0]["message_no"]
			end
			unless defined? rs["Records"][0]["message"]
				message = ""
			else
				message = rs["Records"][0]["message"]
			end
			unless defined? rs["Records"][0]["encode"]
				encode = ""
			else
				encode = rs["Records"][0]["encode"]
			end
			unless defined? rs["Records"][0]["permit_time"]
				permit_time = ""
			else
				permit_time = rs["Records"][0]["permit_time"]
			end
			unless defined? rs["Records"][0]["sent_date"]
				 sent_date = ""
			else
				sent_date = rs["Records"][0]["sent_date"]
			end
			unless defined? rs["Records"][0]["status"]
				status = ""
			else
				status = rs["Records"][0]["status"]
			end
			unless defined? rs["Records"][0]["send_result"]
				send_result = ""
			else
				send_result = rs["Records"][0]["send_result"]
			end
			unless defined? rs["Records"][0]["result_status"]
				result_status = ""
			else
				result_status = rs["Records"][0]["result_status"]
			end
			unless defined? rs["Records"][0]["command_status"]
				command_status = ""
			else
				command_status = rs["Records"][0]["command_status"]
			end
			unless defined? rs["Records"][0]["network_error_code"]
				network_error_code = ""
			else
				network_error_code = rs["Records"][0]["network_error_code"]
			end
			unless defined? rs["Records"][0]["tracking_code"]
				tracking_code = ""
			else
				tracking_code = rs["Records"][0]["tracking_code"]
			end
			unless defined? rs["Records"][0]["partition_size"]
				partition_size = ""
			else
				partition_size = rs["Records"][0]["partition_size"]
			end
			unless defined? rs["Records"][0]["use_jdg_find"]
				use_jdg_find = ""
			else
				use_jdg_find = rs["Records"][0]["use_jdg_find"]
			end		
			query = <<EOS
				insert into t87_inbound_getsmsstatus_histories(entry_id, ResStatus, ResCount,create_date, req_stat,
					group_id, service_id, user,to_address,use_cr_find,carrier_id,message_no,message,encode,permit_time,
					sent_date,status,send_result,result_status,command_status,network_error_code,tracking_code,
					partition_size,use_jdg_find,ResErrorCode,created,entry_user
				)
				values(
					'#{entry_id}',
					'#{resStatus}',
					'#{resCount}',
					'#{create_date}',
					'#{req_stat}',
					'#{group_id}',
					'#{service_id}',
					'#{user}',
					'#{to_address}',
					'#{use_cr_find}',
					'#{carrier_id}',
					'#{message_no}',
					'#{message}',
					'#{encode}',
					'#{permit_time}',
					'#{sent_date}',
					'#{status}',
					'#{send_result}',
					'#{result_status}',
					'#{command_status}',
					'#{network_error_code}',
					'#{tracking_code}',
					'#{partition_size}',
					'#{use_jdg_find}',
					'#{resErrorCode}',
					NOW(),
					'mega_crontab_getSmsStatus'
				);
EOS
			@mysql_cli.query(query)
		end	
	end

	 #============================================================================================
	 # キャリアに応じて、取るべきメッセージを決定する
	 #
	 # 1 Docomo、2 Softbank
	 # 3 KDDI au、4 オプション携帯キャリア Ymobile!
	 # 5 判別中 ※判別中はステータスを不明にするため、この処理は通らない
	 #============================================================================================
	def getCareerMsg_V2(result)
		message = ""
		if defined? result["carrier"]
			if result["carrier"].to_s == "1"
				message = getApiValue_V2(result, "docomoMessage")
			elsif result["carrier"].to_s == "2"
				message = getApiValue_V2(result, "softbankMessage")
			elsif result["carrier"].to_s == "3"
				message = getApiValue_V2(result, "auMessage")
			elsif result["carrier"].to_s == "4"
				message = getApiValue_V2(result, "optionMessage")
			end
		end
		return message
	end

	 #============================================================================================
	 # Get warning message from result status. Reference document: 空電プッシュAPI仕様書2.2.1版.pdf P37
	 #
	 # @param string carrier provider of carrier
	 # @param string send_result is sms sent result
	 # @param string result_status is result status code
	 # @param string command_status is command status code
	 # @param string network_error_code is network error code
	 #
	 # @return string is warning message
	 #============================================================================================
	def getWarningMsg(carrier, send_result, result_status, command_status, network_error_code)
		warning_msg = {
			"1" => {
					"00" => "",
					"21" => "圏外（docomo）",
					"22" => "携帯キャリア側障害（docomo）",
					"20" => "空電側障害（docomo）",
					"23" => "携帯電話端末障害 、SMS拒否設定、携帯キャリア違い等（docomo）"
			},
			"2" => {
					"DELIVRD" => "",
					"EXPIRED" => "圏外（softbank）",
					"DELETED" => "携帯キャリア側障害（softbank）",
					"UNDELIV" => "携帯キャリア側障害（softbank）",
					"REJECTD" => "携帯電話端末障害 、SMS拒否設定等（softbank）"
			},
			"3" => {
					"0x00000000_0xFFFFFF" => "",
					"0x000000FE_0x020124" => "圏外（au）",
					"0x0000000B_0xFFFFFF" => "携帯キャリア違い等（au）",
					"0x000000FE_0x020001" => "SMS（Cメール）配信拒否（au）",
					"0x000000FE_0x020002" => "SMS（Cメール）配信拒否（au）"
			}
		}
		msg = "不明"
		if !carrier.nil?
			if carrier.to_s == "1"
				if defined?warning_msg["1"][result_status]
					msg = warning_msg["1"][result_status]
				end
			elsif carrier.to_s == "2"
				if defined?warning_msg["2"][result_status]
					msg = warning_msg["2"][result_status]
				end
			elsif carrier.to_s == "3"
				if !send_result.nil?
					if send_result.to_s == "その他"
						if defined?warning_msg["3"][command_status + "_" + network_error_code]
							msg = warning_msg["3"][command_status + "_" + network_error_code]
						else
							msg = "その他障害（au）"
						end
					else
						if defined?warning_msg["3"][command_status + "_" + network_error_code]
							msg = warning_msg["3"][command_status + "_" + network_error_code]
						end
					end
				end
			end
		end
		return msg
	end

	#=============================================================================
	#　SMS送信ステータステーブルにインサート
	# param : inbound_id
	# param : template_id
	# param : question_no
	# param : answer_pos
	# return : array
	#=============================================================================
	def insertSmsInfoFromLog(inbound_id, company_id, sms_display_number, template_id, question_no, answer_pos)
		sms_answer_pos = "answer" + answer_pos.to_s
		query = <<EOS
		insert into t86_inbound_sms_statuses (log_id, inbound_id, company_id, display_number, template_id, tel_no, sms_question_no, sms_entry_id, sms_status, created)
		select 
			t81.id,
			t81.inbound_id,
			'#{company_id}',
			'#{sms_display_number}',
			'#{template_id}',
			t81.tel_no,
			'#{question_no}',
			t81.#{sms_answer_pos},
			IF(t81.#{sms_answer_pos} IS NULL, 'no_send', if(t81.#{sms_answer_pos} = '' or t81.#{sms_answer_pos} = '2', 'no_send', if(t81.#{sms_answer_pos} = '0','fail','sending'))),
			now()
		from
			t81_incoming_results t81
		left join
			t86_inbound_sms_statuses t86
		on
			t81.id = t86.log_id and
			t81.inbound_id = t86.inbound_id and
			t86.sms_question_no = '#{question_no}' and
			t86.del_flag = 'N'
		where
			t81.inbound_id = '#{inbound_id}' and		
			t86.sms_question_no is null and
			(t81.#{sms_answer_pos} <> '' or t81.#{sms_answer_pos} is not null)
EOS
		@mysql_cli.query(query)
	end
end
