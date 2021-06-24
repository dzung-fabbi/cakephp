# encoding: UTF-8
#=============================================================================
# Contents   : コンフィグファイル作成
# Author     : Ascend Corp
# Since      : 2016/04/18        1.0
#=============================================================================

load File.join(File.dirname(__FILE__),'../config/AscCommon.rb')
load File.join(File.dirname(__FILE__),'../model/AscM07ServerExternal.rb')
load File.join(File.dirname(__FILE__),'../model/AscM02Company.rb')
load File.join(File.dirname(__FILE__),'../model/AscT25Inbound.rb')
load File.join(File.dirname(__FILE__),'../model/AscT31TemplateQuestion.rb')
load File.join(File.dirname(__FILE__),'../model/AscM08SmsApiInfo.rb')
load File.join(File.dirname(__FILE__),'../model/AscT86InboundSmsStatus.rb')

class AscCreateConfig

	#=============================================================================
	#　初期設定
	#=============================================================================
	def initialize
		@ConfigCommon = AscCommon.new
		@ModelM02Company = AscM02Company.new
		@ModelM07ServerExternal = AscM07ServerExternal.new
		@ModelT25Inbound = AscT25Inbound.new
		@ModelT31TemplateQuestion = AscT31TemplateQuestion.new
		@ModelT08SmsApiInfo = AscM08SmsApiInfo.new
		@ModelT86InboundSmsStatus = AscT86InboundSmsStatus.new
	end
	#=============================================================================
	#　コンフィグファイルを作成
	# param : file_path, inbound_id
	# 
	#=============================================================================
	def createConfig(file_path, company_id, inbound_id, template_id, external_number, file_config_rental2)
		#/home/robo/var_in
		remote_path_inbound = @ConfigCommon.remotePathInbound
		#/home/robo
		remote_path = @ConfigCommon.remotePath
		inbound_no = "000000".slice(1..6-inbound_id.to_s.length) + inbound_id.to_s
		csvFile = File.open(file_path, 'a:UTF-8')
		in_proc_num = @ModelM07ServerExternal.getInProcNumByExternal(external_number)
		dial_interval = @ModelM02Company.getDialIntervalByInboundId(company_id)
		bukken_flag = @ModelT31TemplateQuestion.checkBukkenByTemplateId(template_id)
		bukken_conf = ""

		ques_property_flag = @ModelT31TemplateQuestion.checkQuesProPertyByTemplateId(template_id)
		ques_property_conf = ""
		if(bukken_flag)
			#company_code = @ModelM02Company.getCompanyCode(company_id)
			company_code = "sumirin_residential"
			bukken_conf = "OBJECT_DIR                         " + remote_path + "/objects/" + company_code + "                                     # rental（共有ライブラリ）\n" +
						  "OBJECT_CONFIG_RENTAL               " + remote_path + "/objects/" + company_code + "/rental.txt                          # rental（管理アカウント情報）\n"		
		end
		# bukken_flag==true の場合は、考慮しないでよい仕様。(redmine 9458#note-3)
		if(ques_property_flag)
			# rental2.confを作成する
			ques_property_conf = "OBJECT_DIR                         " + remote_path + "/objects/sumirin_residential                               # rental2（共有ライブラリ）\n" +
						 		 "OBJECT_CONFIG_RENTAL2                " + remote_path_inbound + "/" + inbound_no.to_s + "/rental2.conf"                                                # rental2（管理アカウント情報）\n"
			# confファイルを作成する関数
			createQuesPropertyConfig(file_config_rental2, inbound_no, remote_path, external_number)
		end

		smsFlag = @ModelT31TemplateQuestion.hasSmsQues(template_id)
		smsConfig = ""
		if smsFlag
			sms_display_number,sms_use_short_url  = @ModelT31TemplateQuestion.getSmsDisplayNumber(template_id)
			smsAccount = @ModelT08SmsApiInfo.getSmsAccountInfo(company_id, sms_display_number)
			sms_service_id = ""
			sms_url = ""
			sms_group_id = ""
			sms_user = ""
			sms_pass = ""
			sms_api_id = ""
			sms_error_message_path = remote_path_inbound + "/" + inbound_no.to_s + "/indata/pcm_q/sms_error_message.pcm"
			smsAccount.each do | row |
				sms_service_id = row[0]				
				sms_group_id = row[2]
				sms_url = row[1]
				sms_user = row[3]
				sms_pass = row[4]
				sms_api_id = row[6]
			end
			if sms_api_id == $SMS_API_V2_VALUE
				sms_short_flg = sms_use_short_url == '1' ? "TRUE" : "FALSE"
				sms_kaisen_name = $SMS_API_V2_KAISEN_NAME_NTT
				### https://push.karaden.jp/v2/karadenqueue.json
				### https://push.karaden.jp/v2/
				sms_url = "#{sms_url}karadenqueue.json"
				smsConfig = "\nSMS_VENDER            "+ sms_kaisen_name +"            # SMS送信APIのバージョン(現状は固定)\n" +
							"SMS_TOKEN            "+ sms_service_id +"            # SMSトークン（m08.service_id\n" +
							"SMS_SECURITY_CODE            "+ sms_pass +"            # SMSセキュリティコード（m08.pass）\n" +
							"SMS_PREFIX_ADD            FALSE            # プレフィックス有無（Inはなしなので、FALSEを付与）\n" +
							"SMS_SHORT_URL_FLG            " + sms_short_flg + "            # 短縮URLを使うか（t31.yuko_button_record）\n"+
							"SMS_URL            " + sms_url + "            #SMS送信API URL（m08.url）\n" + 
							"SMS_ERROR_MESSAGE    " + sms_error_message_path + "	#SMS送信不可音声\n"
			else
				sms_url = sms_url + "/" + sms_group_id + "/req_entry.php"
				if sms_service_id.blank?
					smsConfig = ""
				else
					smsConfig = "\nSMS_SERVICE_ID			"+ sms_service_id +"			# 企画ID\n" +
								"SMS_SND_INPUT_NUMBER	FALSE			# FALSE(default)/TRUE\n" + 
								"SMS_DIR\n" +
								"SMS_URL			" + sms_url + "			#SMS送信API URL\n" +
								"SMS_USER			" + sms_user + "			#SMS送信API 認証ユーザーID\n" +
								"SMS_PASSWORD		" + sms_pass + "			#SMS送信API 認証パスワード\n" + 
								"SMS_PREFIX_ADD		FALSE\n" +
								"SMS_ERROR_MESSAGE	" + sms_error_message_path + "	#SMS送信不可音声\n"
				end
			end
		end
		arr_info_trans = @ModelT31TemplateQuestion.getQuestionTransByTemplateId(template_id)
		trans_flag = "FALSE"
		trans_seat_num = "0"
		trans_timeout = "120"
		trans_phone_number_play_flag = "FALSE"
		arr_info_trans.each do | arr |
			trans_flag = "TRUE"
			trans_seat_num = arr[1]
			trans_timeout = arr[3]
			trans_phone_number_play_flag = arr[7].to_s == "1" ? "TRUE" : trans_phone_number_play_flag

		end
		proc_num = in_proc_num.to_i - trans_seat_num.to_i
		line =  "#------------------------------\n" +
				"# コンフィグ\n" +
				"# インバウンド	                        " + inbound_no.to_s + "\n" +
				"# 日付	                            " + Time.now.strftime("%Y%m%d") + " - " + external_number.to_s + "\n" + 
				"#------------------------------\n" +
				"INBOUND_CALL                       TRUE                                                                          # 現行INCOMING_CALL\n" +
				"INBOUND_INFO_LIST                  " + remote_path_inbound + "/" + inbound_no.to_s + "/inbound_info_list.txt     # 情報リスト\n" +
				"INBOUND_REJECT_LIST                " + remote_path_inbound + "/" + inbound_no.to_s + "/inbound_reject_list.txt   # 着信拒否リスト\n" +
				"INBOUND_PORT_LIST                  " + remote_path_inbound + "/" + inbound_no.to_s + "/inbound_port.txt          # 着信ポートリスト\n" +
				"INBOUND_ADD_NO                     TRUE \n" +
				"INBOUND_NO_FILE                    /home/robo/inbound_no.txt \n" +
				"GROUP_NO                           1                                                                             # ターゲットグループ番号\n" +
				"PROC_NUM                           " + proc_num.to_s + "                                                         # 起動プロセス数\n" +
  				"DIAL_INTERVAL                      " + dial_interval.to_s + "                                                    # 発呼インターバル(ms)\n" +
				"TIME_KEEPER_SYS                    FALSE\n" +
				"DIR_VAR_VOICE                      " + remote_path_inbound + "/" + inbound_no.to_s + "/indata/pcm_var\n" +
				"DIR_RECORDING                      " + remote_path_inbound + "/" + inbound_no.to_s + "/rec\n" +
				"RECORDING_START_SYNC               TRUE\n" +
				"RECORDING_MAX_TIME                 30\n" +
				"VOICE_COMBINED_PAUSE               500\n" +
				"SPEECH_NUM_WAIT					150\n" +
				"SPEECH_NUM_PAUSE_LEN				200\n" +
				"PREFIX_ADD                         FALSE\n" +
				"PREFIX_DIGIT                       6\n" +
				"PREFIX_NOTICE                      184,186\n" +
				"CH_GET_ASSIGN_MNG                  TRUE\n" +
				"LOG_PCM_PROC                       1                                                                            # 音声ログをとるプロセス番号（n ns-ne n1,n2,n3..）\n" +
				"DIR_DIAL                           " + remote_path_inbound + "/" + inbound_no.to_s + "/indata/dial              # 発呼リスト\n" +
				"DIR_Q_PCM                          " + remote_path_inbound + "/" + inbound_no.to_s + "/indata/pcm_q             # 質問音声ファイル\n" +
				"DIR_ANS                            " + remote_path_inbound + "/" + inbound_no.to_s + "/indata/ans_list          # 回答リスト\n" +
				"DIR_SPLIST                         " + remote_path_inbound + "/" + inbound_no.to_s + "/indata/splist            # 発声リスト	\n" +	
				"DIR_CSV                            " + remote_path_inbound + "/" + inbound_no.to_s + "/csv                      # 結果出力ディレクトリ（csv）\n" +
				"DIR_LOG_PCM                        " + remote_path_inbound + "/" + inbound_no.to_s + "/pcm_log                  # 音声ログ出力ディレクトリ（pcm_log）\n" +
				"DIR_LOG                            " + remote_path_inbound + "/" + inbound_no.to_s + "/log                      # 制御ログ出力ディレクトリ（log）\n" +
				"ANA_DELAY                          2000                                                                         # 分析開始遅延時間（1000ms）\n" +
				"DIAL_WAIT_TIME                     22                                                                           # 着信応答待ち時間（22）\n" +
				"ANS_TIMEOUT                        10000                                                                        # 回答までの待ち時間\n" +
				"ANS_TIMEOUT_COUNT                  0                                                                            # タイムアウト時繰り返す時間\n" +
				"ANS_TIMEOUT_MESSAGE                timeout_end_ul.pcm                                                           # タイムアウト時出力するメッセージ\n" +
				"ENO_CLIENT_HOST                    localhost                                                                    # ソフトフォン　ホスト\n" +
				"ENO_CLIENT_PORT_CTL                18000                                                                        # ソフトフォン　制御ポート\n" +
				"ENO_CLIENT_PORT_MED                18500                                                                        # ソフトフォン　メディアポート\n" +
				"TRANS                              " + trans_flag + "                                                           # 転送する・しない\n" +
				"TRANS_REGARDLESS                   TRUE                                                                         # 番号にかかわらず無条件で転送する\n" +
				"TRANS_LIST                         trans_list.txt	                                                             # 転送先電話番号リスト(DIR_DIAL/)\n" +
				"TRANS_PORT_NUM                     " + trans_seat_num.to_s + "                                                  # 転送先ポート数\n" +
				"TRANS_CANCEL_TIME                  " + trans_timeout + "                                                        # 転送キャンセル時間\n" +
				"TRANS_TIMEOUT_MESSAGE              TRUE                                                                         # 転送タイムアウト時メッセージ出力\n" +
				"TRANS_TIMEOUT_MESSAGE_FILE         timeout_trans_ul.pcm                                                         # メッセージファイル\n" +
				"TRANS_DISCONNECT_MESSAGE           TRUE                                                                         # 転送中に切断されたメッセージ出力（転送先へ）\n" +
				"TRANS_DISCONNECT_MESSAGE_FILE      trans_disconnect.pcm                                                         # メッセージファイル\n" +
				"TRANS_LOG                          TRUE                                                                         # 転送ログ出力\n" +
				"TRANS_TIME_ALWAYS_OUTPUT	        TRUE                                                                         # 転送時間カラム出力\n" +
				"TRANS_NOTIFY_NUMBER	" + trans_phone_number_play_flag + " #FALSE(default)/TRUE	# 通知する・しない\n" +
				"TRANS_NOTIFY_NUMBER_TIMEOUT_COUNT	3					# 通知メッセージの再生回数\n" +
				"TRANS_NOTIFY_NUMBER_TIMEOUT_TIME	1					# メッセージ終了からの入力タイムアウト時間\n" +
				"TRANS_PREFIX				FALSE						# プレフィックス付加(TRUE/FALSE)\n" +
				"TRANS_NOTIFY_MESS_HEAD				trans_notify_mess_head_inbound.pcm	# 通知メッセージ先頭（番号前）\n" +
				"TRANS_NOTIFY_MESS_TAIL				trans_notify_mess_tail.pcm	# 通知メッセージ後尾（番号後）\n" +
				"TRANS_NOTIFY_MESS_NON				trans_notify_mess_non.pcm    # 非通知メッセージ\n" +
				"TRANS_NOTIFY_CONFIRM_NUMBER		all							# 有効とする確認入力番号（一桁固定 or all）\n" +
				"TRANS_NOTIFY_SP_NUM_DIR			pcm_num						# 番号音声ファイルディレクトリ\n" +
				"TRANS_NOTIFY_SP_NUM_WAIT			250							# 番号再生時番号間のウェイト時間（ms）\n" +
				"TRANS_NOTIFY_SP_NUM_PAUSE_LEN		300							# '#*-'\n" + 
				"DIR_TRANS_LOG                      trans_log                                                                    # 転送ログ出力先\n" +
				"TRANS_DISCONNECT_DELAY             10                                                                           # 転送切断後切断にするまでの遅延時間（秒）\n" +		
				"RECORDING_OUT_FORM                 LINEAR                                                                       # LINEAR/ULAW\n" +
				"LOG_LEVEL                          3\n" +
				"LOG_LEVEL_CONSOLE                  2\n" + bukken_conf + ques_property_conf +
				smsConfig
		csvFile.puts(NKF::nkf('-Wsm0',line))
		csvFile.close
	end

	def createQuesPropertyConfig(file_config_rental2, inbound_no, remote_path, external_number)
		# autopoll.conf と同じ階層で作成
		csvFile = File.open(file_config_rental2, 'a:UTF-8')
		bukken_infos = @ModelM07ServerExternal.getBukkenInfoByExternal(external_number)

		corp_id = 0
		store_id = 0
		bukken_infos.each do | arr |
			corp_id = arr[0]
			store_id = arr[1]
			break
		end

		line =  "####################################\n" +
				"# object rental config\n" +
				"####################################\n" +
				"\n" +
				"CORP_ID              "+ corp_id.to_s + "   #管理会社ID\n"+
				"STORE_ID             "+ store_id.to_s + "   #管理店舗ID\n"+
				"QUERY_MAX_SYNTH      "+ @ConfigCommon.getPropertySearchMax.to_s + "   #発声する物件数の上限	\n"+
				"SYNTH_URL            "+ @ConfigCommon.getPropertySynthUrl.to_s + "   #APIのURL\n"+
				"SYNTH_CUSTOMER_ID    "+ @ConfigCommon.getPropertySynthCustomerId.to_s + "   #APIのアカウント\n"+
				"SYNTH_USER_ID        "+ @ConfigCommon.getPropertySynthUserId.to_s + "   #APIのID\n"+
				"SYNTH_USER_PASSWORD  "+ @ConfigCommon.getPropertySynthUserPassword.to_s + "   #APIのPASS\n"+
				"SYNTH_SPEAKER_ID     000-00-0-113        # 話者モデル:めぐみ（ナレーター・女性標準）\n" +
				"SYNTH_STYLE_ID       113                    # 口調モデル:めぐみ（ナレーター・女性標準）\n" +
				"SYNTH_VOICE_TYPE     1.2                    # 声質\n" +
				"SYNTH_SPEECH_RATE    0.95                # 話速\n" +
				"SYNTH_DIR            /dev/shm/rental        # 音声ファイルディレクトリ\n" +
				"LOG_DIR              " + remote_path + "/var/" + inbound_no  + "/obj_log   #ログのパス\n"

		csvFile.puts(NKF::nkf('-Wsm0',line))
		csvFile.close
	end
end