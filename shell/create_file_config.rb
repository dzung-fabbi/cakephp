# encoding: UTF-8
#=============================================================================
# Contents   : autopollファイル作成
# Author     : Ascend Corp
# Since      : 2015/09/07        1.0
#=============================================================================

load File.join(File.dirname(__FILE__),'common.rb')
load File.join(File.dirname(__FILE__),'config.rb')

instance =  AscConfig.new
instance.instance_eval File.read File.join(File.dirname(__FILE__),'config.ini')
config = instance.getData

###########################################
#
# コンフィグ情報を取る
#
###########################################
def getInfoConfig(mysql_cli, schedule_id)
	data=Array.new()
	query = <<EOS
		select 
			t20.proc_num,
			t20.dial_wait_time,
			t20.ans_timeout,
			t20.term_valid_count,
			t20.term_connect_count,
			t31.trans_tel,
			t31.trans_seat_num,
			t31.trans_empty_seat_flag,
			t31.trans_timeout,
			t31.trans_timeout_audio_id,
			t31.trans_timeout_audio_type,
			t31.trans_timeout_audio_content,
			m07.external_prefix,
			m02.dial_interval,
			t20.template_id,
			t20.company_id,
			t31_sms.sms_display_number,
			t31_sms.yuko_button_record,
			t31.yuko_button_record
		from
			t20_out_schedules t20 
				left join 
			t31_template_questions t31 on t20.template_id = t31.template_id 
				and t31.question_type = '5' 
				and t31.del_flag = 'N'
				left join 
			t31_template_questions t31_sms on t20.template_id = t31_sms.template_id 
				and t31_sms.question_type in ('13','19')
				and t31_sms.del_flag = 'N'
				inner join
			m07_server_externals m07 on t20.external_number = m07.external_number
				and m07.del_flag = 'N'
				inner join
			m02_companies m02 on m02.company_id = t20.company_id
				and m02.del_flag = 'N'
		where
			t20.id = #{schedule_id} 
			and t20.del_flag = 'N'
			limit 1;
EOS
	mysql_cli.query(query).each do | row |
		data = data + Array.new(1, row)
	end
	return data
end

def getConnectNum(mysql_cli, schedule_id)
	count = 0
	query = <<EOS
		select 
			count(*)
		from
			t80_outgoing_results t80
		where
			t80.status not in ('timeout', 'reject') and
			t80.schedule_id = #{schedule_id}
EOS
	mysql_cli.query(query).each do | row |
		count = row[0]
	end
	return count
end

############################################
#
# バッチのメイン処理
#
############################################
begin
	schedule_no = ARGV[0]
	schedule_id = ARGV[1]
	#DB接続情報
	db_ip = config[:database_ip]
	db_id = config[:database_id]
	db_pass = config[:database_pass]
	db_schema = config[:database_schema]
	mysql_cli=Mysql.connect(db_ip, db_id, db_pass, db_schema)
	mysql_cli.charset="utf8"
	localPathSchedule = config[:local_schedule]
	localPathScheduleId = config[:local_schedule] + schedule_no
	localPathAutopoll = localPathScheduleId + '/'
	localPathIndata = localPathScheduleId + '/indata/'
	localPathDial = localPathIndata + 'dial/'
	localPathPcm = localPathIndata + 'pcm_q/'
	remotePathSchedule = config[:remote_path]
	remotePathScheduleId = remotePathSchedule + schedule_no
	remotePathIndata = remotePathScheduleId + '/indata/'
	remotePathPcm = remotePathIndata + 'pcm_q/'

	fileAutopoll = 'autopoll.conf'
	# 今回発信設定をするテンプレートの情報を全て取得
	arr_config = getInfoConfig(mysql_cli, schedule_id)
	is_first_call = true
	if File.exists?(localPathAutopoll + fileAutopoll)
		is_first_call = false
	end
	arr_config.each do | row |
		proc_num = row[0]
		dial_wait_time = row[1]
		ans_timeout = row[2]
		if row[4].to_i > 0
			connect_num = getConnectNum(mysql_cli, schedule_id)
			term_connect_count = row[4].to_i - connect_num.to_i
			str_connect = "TERM_CONNECT_COUNT			"+term_connect_count.to_s+"		# group -> 1:600,2:700,3:800\n" 
		else str_connect = ""
		end
		str_trans = "TRANS_TIME_ALWAYS_OUTPUT    TRUE  #転送時間出力\n"
		unless row[5].blank?
			trans_tel = row[5]
			trans_seat_num = row[6]
			if row[7].to_s == "1"
				trans_empty_seat_flag = "TRUE"
			else
				trans_empty_seat_flag = "FALSE"
			end
			trans_timeout = row[8]
			trans_timeout_audio_id = row[9]
			trans_timeout_audio_type = row[10]
			trans_timeout_audio_content = row[11]
			external_prefix = row[12]

			if row[18].to_s == "1"
				trans_phone_number_play_flag = "TRUE"
			else
				trans_phone_number_play_flag = "FALSE"
			end


			#転送リスト作成
			file_trans_dial = "trans_list.txt"
			createBlankCSV(localPathDial, file_trans_dial)
			if is_first_call
				system("chmod 777 " + localPathDial + file_trans_dial)
			end
			csvFileTransDial = File.open(localPathDial + file_trans_dial, 'a:UTF-8')
			for i in 1..trans_seat_num.to_i
				csvFileTransDial.puts(NKF::nkf('-Wsm0', external_prefix.to_s + trans_tel))
			end
			if trans_seat_num.to_i > 1
				trans_limiting_thre = trans_seat_num.to_i - 1
			else
				trans_limiting_thre = 1
			end
			csvFileTransDial.close
			#転送タイムアウト
			pcm_timeout = "timeout_trans_ul.pcm"
			if trans_timeout_audio_type.to_s == "0"
				path_timeout = localPathPcm + pcm_timeout
				processGetFilePcm(mysql_cli, trans_timeout_audio_id, path_timeout)
			else
				processGetFilePcmMix(mysql_cli, trans_timeout_audio_content, localPathPcm, pcm_timeout, trans_timeout_audio_type.to_s)
			end
			# copy from cpm files "/home/ftpuser/robo/schedule"
			FileUtils.cp(localPathSchedule + "trans_disconnect.pcm", localPathPcm)
			FileUtils.cp(localPathSchedule + "trans_notify_mess_head_outbound.pcm", localPathPcm)
			FileUtils.cp(localPathSchedule + "trans_notify_mess_non.pcm", localPathPcm)
			FileUtils.cp(localPathSchedule + "trans_notify_mess_tail.pcm", localPathPcm)

			system("chmod 777 " + localPathPcm + "trans_disconnect.pcm")
			system("chmod 777 " + localPathPcm + "trans_notify_mess_head_outbound.pcm")
			system("chmod 777 " + localPathPcm + "trans_notify_mess_non.pcm")
			system("chmod 777 " + localPathPcm + "trans_notify_mess_tail.pcm")

			str_trans = "TRANS					TRUE	# 転送する・しない\n" +
						"TRANS_REGARDLESS		TRUE	# 番号にかかわらず無条件で転送する\n" +
						"TRANS_LIST				trans_list.txt	# 転送先電話番号リスト(DIR_DIAL/)\n" +
						"TRANS_PORT_NUM			"+trans_seat_num.to_s+"		# 転送先ポート数\n" +
						"TRANS_LIMITING			"+trans_empty_seat_flag.to_s+"	# チャンネル数を絞る/絞らない\n" +
						"TRANS_LIMITING_THRE		"+trans_limiting_thre.to_s+"		# 発呼を止める転送ビジー数（第一段階）\n" +
						"TRANS_CANCEL_TIME		"+trans_timeout+"		# 転送キャンセル時間\n" +
						"TRANS_TIMEOUT_MESSAGE			TRUE					# 転送タイムアウト時メッセージ出力\n" +
						"TRANS_TIMEOUT_MESSAGE_FILE		timeout_trans_ul.pcm	# メッセージファイル\n" +
						"TRANS_DISCONNECT_MESSAGE		TRUE					# 転送中に切断されたメッセージ出力（転送先へ）\n" +
						"TRANS_DISCONNECT_MESSAGE_FILE	trans_disconnect.pcm	# メッセージファイル\n\n" +

						"TRANS_LOG				TRUE			# 転送ログ出力\n" +
						"DIR_TRANS_LOG			trans_log		# 転送ログ出力先\n" +
						"TRANS_DISCONNECT_DELAY	10				# 転送切断後切断にするまでの遅延時間（秒）\n" +
						"TRANS_TIME_ALWAYS_OUTPUT    TRUE  #転送時間出力\n" +


						"TRANS_NOTIFY_NUMBER		" + trans_phone_number_play_flag + " #FALSE(default)/TRUE		# 通知する・しない\n" +
						"TRANS_NOTIFY_NUMBER_TIMEOUT_COUNT	3					# 通知メッセージの再生回数\n" +
						"TRANS_NOTIFY_NUMBER_TIMEOUT_TIME	1					# メッセージ終了からの入力タイムアウト時間\n" +
						"TRANS_PREFIX			TRUE							# プレフィックス付加(TRUE/FALSE)\n" +
						"TRANS_NOTIFY_MESS_HEAD			trans_notify_mess_head_outbound.pcm	# 通知メッセージ先頭（番号前）\n" +
						"TRANS_NOTIFY_MESS_TAIL			trans_notify_mess_tail.pcm	# 通知メッセージ後尾（番号後）\n" +
						"TRANS_NOTIFY_MESS_NON				trans_notify_mess_non.pcm	# 非通知メッセージ\n" +
						"TRANS_NOTIFY_CONFIRM_NUMBER		all					# 有効とする確認入力番号（一桁固定 or all）\n" +
						"TRANS_NOTIFY_SP_NUM_DIR			pcm_num					# 番号音声ファイルディレクトリ\n" +
						"TRANS_NOTIFY_SP_NUM_WAIT			250						# 番号再生時番号間のウェイト時間（ms）\n" +
						"TRANS_NOTIFY_SP_NUM_PAUSE_LEN		300						# '#*-'\n"

		end
		dial_interval = row[13]
		template_id = row[14]
		smsFlag = hasSmsQues(mysql_cli, template_id)
		smsConfig = ""
		if smsFlag
			company_id = row[15]
			sms_display_number = row[16]
			smsUseShortURL = row[17]
			smsAccount = getSmsAccountInfo(mysql_cli, company_id, sms_display_number)
			sms_service_id = ""
			sms_url = ""
			sms_group_id = ""
			sms_user = ""
			sms_pass = ""
			sms_api_id = ""
			sms_error_message_path = remotePathPcm + 'sms_error_message.pcm'
			smsAccount.each do | row |
				sms_service_id = row[0]
				sms_group_id = row[2]
				sms_url = row[1]
				sms_user = row[3]
				sms_pass = row[4]
				sms_api_id = row[6]
			end
			if sms_api_id == $SMS_API_V2_VALUE
				sms_short_flg = smsUseShortURL == '1' ? "TRUE" : "FALSE"
				sms_kaisen_name = $SMS_API_V2_KAISEN_NAME_NTT
				### https://push.karaden.jp/v2/karadenqueue.json
				### https://push.karaden.jp/v2/
				sms_url = "#{sms_url}karadenqueue.json"
				smsConfig = "\nSMS_VENDER			"+ sms_kaisen_name +"			# SMS送信APIのバージョン(現状は固定)\n" +
							"SMS_TOKEN			"+ sms_service_id +"			# SMSトークン（m08.service_id\n" +
							"SMS_SECURITY_CODE			"+ sms_pass +"			# SMSセキュリティコード（m08.pass）\n" +
							"SMS_PREFIX_ADD			TRUE			# プレフィックス有無（Outは有りなので、TRUEを付与）\n" +
							"SMS_SHORT_URL_FLG			" + sms_short_flg + "			# 短縮URLを使うか（t31.yuko_button_record）\n"+
							"SMS_URL			" + sms_url + "			#SMS送信API URL（m08.url）\n" +
							"SMS_ERROR_MESSAGE    " + sms_error_message_path + "	#SMS送信不可音声\n"
			else
				sms_url = sms_url + "/" + sms_group_id + "/req_entry.php"
				if sms_service_id.blank?
					smsConfig = ""
				else
					smsConfig = "\nSMS_VENDER			"+ $SMS_API_V1_KAISEN_NAME_NTT +"			# 企画ID\n" +
							"SMS_SERVICE_ID			"+ sms_service_id +"			# 企画ID\n" +
							"SMS_SND_INPUT_NUMBER	FALSE			# FALSE(default)/TRUE\n" + 
							"SMS_DIR\n" +
							"SMS_URL			" + sms_url + "			#SMS送信API URL\n" +
							"SMS_USER			" + sms_user + "			#SMS送信API 認証ユーザーID\n" +
							"SMS_PASSWORD		" + sms_pass + "			#SMS送信API 認証パスワード\n" + 
							"SMS_PREFIX_ADD		TRUE\n" +
							"SMS_ERROR_MESSAGE    " + sms_error_message_path + "	#SMS送信不可音声\n"
				end
			end
		else
		end
		#autopoll作成
		createBlankCSV(localPathAutopoll, fileAutopoll)
		if is_first_call
			system("chmod 777 " + localPathAutopoll + fileAutopoll)
		end
		csvFile = File.open(localPathAutopoll + fileAutopoll, 'a:UTF-8')
		line = "#------------------------------\n" +
				"# autopoll configfile\n" +
				"# \n" +
				"#------------------------------\n" +
				"PROC_NUM		" + proc_num.to_s + "			# 起動プロセス数\n"+
				"DIAL_INTERVAL	" + dial_interval.to_s + "			# 発呼インターバル(ms)\n" +
				"GROUP_NO		1			# ターゲットグループ番号\n\n" +
				"TIME_KEEPER_SYS			FALSE\n" +
				"DIR_VAR_VOICE			/home/robo/var/"+schedule_no.to_s+"/indata/pcm_var\n" +
				"DIR_RECORDING			/home/robo/var/"+schedule_no.to_s+"/rec\n" +
				"RECORDING_START_SYNC	TRUE\n" +
				"RECORDING_MAX_TIME		30\n" +
				"VOICE_COMBINED_PAUSE	500\n" +
				"SPEECH_NUM_WAIT					150\n" +
				"SPEECH_NUM_PAUSE_LEN				200\n" +
				"PREFIX_ADD				FALSE\n" +
				"PREFIX_DIGIT			6\n" +
				"PREFIX_NOTICE			184,186\n\n" +
				"TERM_VALID_COUNT_CONDITION  ALL\n" +
				str_connect + "\n" +
				"CH_GET_ASSIGN_MNG			TRUE\n\n" +
				"LOG_PCM_PROC				1		# 音声ログをとるプロセス番号（n ns-ne n1,n2,n3..）\n\n" + 
				"DIR_DIAL		/home/robo/var/"+schedule_no.to_s+"/indata/dial		# 発呼リスト\n" + 
				"DIR_Q_PCM		/home/robo/var/"+schedule_no.to_s+"/indata/pcm_q		# 質問音声ファイル\n" + 
				"DIR_ANS			/home/robo/var/"+schedule_no.to_s+"/indata/ans_list	# 回答リスト\n" + 
				"DIR_SPLIST		/home/robo/var/"+schedule_no.to_s+"/indata/splist		# 発声リスト\n\n" + 
				"DIR_CSV			/home/robo/var/"+schedule_no.to_s+"/csv				# 結果出力ディレクトリ（csv）\n" +
				"DIR_LOG_PCM		/home/robo/var/"+schedule_no.to_s+"/pcm_log			# 音声ログ出力ディレクトリ（pcm_log）\n" +
				"DIR_LOG			/home/robo/var/"+schedule_no.to_s+"/log				# 制御ログ出力ディレクトリ（log）\n\n" +
				"#DMACH_DETECT	TRUE			# 留守電・FAX検出\n\n" + 
				"ANA_DELAY		2000			# 分析開始遅延時間（1000ms）\n" +
				"DIAL_WAIT_TIME	"+dial_wait_time.to_s+"				# 着信応答待ち時間（22）\n" +
				"ANS_TIMEOUT		"+ans_timeout.to_s+"			# 回答までの待ち時間\n" + 
				"ANS_TIMEOUT_COUNT 0				# タイムアウト時繰り返す時間\n" +
				"ANS_TIMEOUT_MESSAGE	timeout_end_ul.pcm	# タイムアウト時出力するメッセージ\n\n" +
				"ENO_CLIENT_HOST		localhost	# ソフトフォン　ホスト\n" +
				"ENO_CLIENT_PORT_CTL	18000		# ソフトフォン　制御ポート\n" + 
				"ENO_CLIENT_PORT_MED	18500		# ソフトフォン　メディアポート\n"+ 
				"ENO_CLIENT_KILL_MOD /home/robo/get_process_extension_number.sh   # ソフトフォンをキルするシェル\n" +
				str_trans + "\n" +
				"RECORDING_OUT_FORM	LINEAR	# LINEAR/ULAW\n" +
				"LOG_LEVEL			3\n" +
				"LOG_LEVEL_CONSOLE	2\n" + smsConfig
		csvFile.puts(NKF::nkf('-Wsm0',line))
		csvFile.close
		mysql_cli.close
	end
rescue Exception => e
	puts "err_create_file_autopoll"
	writeLog("err_create_file_autopoll : " + e.message)
	writeLog("エラー：autopollファイルを作成失敗")
	writeLog(e.backtrace.join("\n"))
	sendMailError(schedule_id)
	exit 9
end