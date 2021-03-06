<?php
	require_once('Common.php');
	require('Logger.php');
	require('DB.php');
	require('SmsApi.php');
	require('DbProcess.php');
	require_once('SendSmsScheduleMail.php');
	
	try {		
		if (!isset($argv[1])){
			Logger::writeLog("ERROR: Not exist schedule id parameter! (Send now)");
			exit(1);
		}
		Logger::writeLog("Starting...send sms! (Send now)");
		// Connect to DB
		$config = parse_ini_file('config.ini');	
		$db_con = connectDB($config["db_host"], $config["db_port"], $config["db_user"], $config["db_pass"], $config["db_schema"]);
		if ($db_con !== false) {
			$scheduleId = $argv[1];
			if (isset($argv[2]) && !empty($argv[2]) && $argv[2] == 1) {
				// 再送（Restart）ボタンを押したとき
				$re_send_flag = true;
			} else {
				$re_send_flag = false;
			}

			// Get list schedules to process
			// スケジュールを取得する。（第3引数は、現在時刻で絞り込むか）
			if ($re_send_flag) {
				$schedules = get_schedule_to_send($db_con, $scheduleId);
			} else {
				$schedules = get_schedule_to_send($db_con, $scheduleId, true);
			}
			if ($schedules === false){
				Logger::writeLog("ERROR: Get schedule id: ".$scheduleId);
				if (!sendError())
					Logger::writeLog("ERROR: Send mail. (Send now)");
				exit(1);
			}
			if (sizeof($schedules) == 1) {
				// Get log file path to send mail error
				
				$local_path = getSystemParameter($db_con, "SMS_BATCH","LOCAL_PATH");			
				$log_file_path = $local_path . 'log/sms_log_' . date("Ymd").".log";
				$schedule_data = $schedules[0];
				Logger::writeLog("Schedule_id: " . $schedule_data["schedule_id"].". (Send now)");

				// スケジュールの情報をローカル変数にセット
				$company_name = $schedule_data["company_name"];
	
				$schedule_id = $schedule_data["schedule_id"];
				$schedule_name = $schedule_data["schedule_name"];
				$status = $schedule_data["status"];
				$service_id = $schedule_data["service_id"];
				$display_number = $schedule_data["display_number"];
				$consent_flag = $schedule_data["consent_flag"]; // #8298 add consentday

				$list_id = $schedule_data["list_id"];
				$list_name = $schedule_data["list_name"];
				$list_test_flag = $schedule_data["list_test_flag"];
				$tel_total = $schedule_data["tel_total"];
				$muko_tel_total = $schedule_data["muko_tel_total"];
	
				$template_id = $schedule_data["template_id"];
				$template_name = $schedule_data["template_name"];
				$description = $schedule_data["description"];
				$template_content = $schedule_data["content"];
	
				$time_start = $schedule_data["time_start"];
				$time_end = $schedule_data["time_end"];

				$sms_use_short_url = $schedule_data["sms_use_short_url"] ? $schedule_data["sms_use_short_url"] : "0";
				// スケジュールの情報をローカル変数にセット_ここまで

				$str_time_send = '';
				$time_sends = getAllTimeSendSms($db_con, $schedule_id);
				if ($time_sends === false || sizeof($time_sends) == 0) {
					Logger::writeLog("ERROR: Get all run time of schedule_id: ".$schedule_id);
					if (!sendError())
						Logger::writeLog("ERROR: Send mail. (Send now)");
					exit(1);
				}
				foreach ($time_sends as $time_send) {
					$str_time_send .= $time_send["time_start"] . " ~ " . $time_send["time_end"] . ", ";
					$last_time_end = $time_send["time_end"];
				}
				$str_time_send = substr($str_time_send, 0, -2);

				// Get param connect to API
				// APIの情報を取得
				Logger::writeLog("Get param to connect SMS API!. Service id: ".$service_id);
				$configSmsApi = get_configSmsApi($db_con, $service_id);

				if ($configSmsApi === false){
					Logger::writeLog("ERROR: Get sms api config: ".$schedule_id.". (Send now)");
					if (!sendError())
						Logger::writeLog("ERROR: Send mail. (Send now)");
					exit(1);
				}
			
				if (isset($configSmsApi["BATCH_SLEEP_TIME"]))
					$batch_sleep_time = $configSmsApi["BATCH_SLEEP_TIME"];
				else{
					$batch_sleep_time = 500;
				}
					// Create log run
				Logger::writeLog("Insert schedule: ".$schedule_id." run time history! Insert t202. (Send now)");
				begin_transaction($db_con);

				//// 各種必要な情報（テンプレートやダイアルリスト）を残す
				//　ｔ202を作成。
				if (!create_sms_send_log($db_con, $schedule_id)) {
					rollback($db_con);
					if (!sendErrorSmsScheduleMail($company_name, $schedule_id, $schedule_name, $template_id, $template_name, $list_name, $muko_tel_total, $str_time_send, $service_id, $display_number, $log_file_path))
						Logger::writeLog("ERROR: Send mail error schedule: " . $schedule_id.". (Send now)");
					exit(1);
				} else {
					commit($db_con);
				}			

				// Create data history
				if (!$re_send_flag) {
					// Create data list history
					begin_transaction($db_con);
					Logger::writeLog("Insert sms list history! Insert t500. schedule_id: ".$schedule_id.". list_id: ".$list_id. ". list_name: ".$list_name. ". yuko_tel_total: ".$muko_tel_total.". (Send now)");
					if (!create_list_history($db_con, $schedule_id, $list_id, $list_name, $list_test_flag, $tel_total, $muko_tel_total)) {
						rollback($db_con);
						if (!sendErrorSmsScheduleMail($company_name, $schedule_id, $schedule_name, $template_id, $template_name, $list_name, $muko_tel_total, $str_time_send, $service_id, $display_number, $log_file_path))
							Logger::writeLog("ERROR: Send mail error schedule: " . $schedule_id.". (Send now)");
						exit(1);
					}				
					// Create data tel history
					Logger::writeLog("Insert tel history of list! Insert t501. schedule_id: ".$schedule_id.". list_id: ".$list_id.". (Send now)");
					if (!create_tel_history($db_con, $schedule_id, $list_id)) {
						rollback($db_con);
						if (!sendErrorSmsScheduleMail($company_name, $schedule_id, $schedule_name, $template_id, $template_name, $list_name, $muko_tel_total, $str_time_send, $service_id, $display_number, $log_file_path))
							Logger::writeLog("ERROR: Send mail error schedule: " . $schedule_id.". (Send now)");
						exit(1);
					}				
					// Create data template history
					Logger::writeLog("Insert template history! Insert t600. schedule_id: ".$schedule_id." template_id: ".$template_id.". template_name: ".$template_name.". (Send now)");
					if (!create_template_history($db_con, $schedule_id, $template_id, $template_name, $description, $template_content, $sms_use_short_url)) {
						rollback($db_con);
						if (!sendErrorSmsScheduleMail($company_name, $schedule_id, $schedule_name, $template_id, $template_name, $list_name, $muko_tel_total, $str_time_send, $service_id, $display_number, $log_file_path))
							Logger::writeLog("ERROR: Send mail error schedule: " . $schedule_id.". (Send now)");
						exit(1);
					}
					commit($db_con);				
				}
				//// 未送信リストを取得
				// Get list tel not send
				Logger::writeLog("Get no sent tel list! Get diff from t501 and t800. Schedule: ".$schedule_id.". (Send now)");
				$row = get_list_tel_not_send($db_con, $schedule_id, $list_id);
				Logger::writeLog("Schedule_id: ".$schedule_id.". List_id: ".$list_id.". Count: ".sizeof($row)." items! (Send now)");			
				if ($row === false) {
					if (!sendErrorSmsScheduleMail($company_name, $schedule_id, $schedule_name, $template_id, $template_name, $list_name, $muko_tel_total, $str_time_send, $service_id, $display_number, $log_file_path))
						Logger::writeLog("ERROR: Send mail error schedule: " . $schedule_id.". (Send now)");
					exit(1);
				}
				//// 未送信リストを取得_END

				/// SMS本文の挿入項目を収集する
				$arr_items = array();
				$hasInsertItem = false;
				preg_match_all('/{.*?}/', $template_content, $items);
				if(!empty($items[0])){
					$hasInsertItem =  true;

					foreach ($items[0] as $item) {
						$item_name = preg_replace('/{/', "",preg_replace('/}/', "", $item,1),1);
						if(!in_array($item_name, $arr_items))
							array_push($arr_items, $item_name);
					}

					$list_items = get_list_items($db_con, $list_id);
					if ($list_items === false) {
						if (!sendErrorSmsScheduleMail($company_name, $schedule_id, $schedule_name, $template_id, $template_name, $list_name, $muko_tel_total, $str_time_send, $service_id, $display_number, $log_file_path))
							Logger::writeLog("ERROR: Send mail error schedule: " . $schedule_id.". (Send now)");
						exit(1);
					}
					$list_columns = array();
					foreach ($list_items as $list_item) {
						$list_columns[$list_item['item_name']] = $list_item['item_column'];
					}
				}
				/// SMS本文の挿入項目を収集する_END

				$exit_flag = false;

				//// 発信リストの行数、SMSを送信し、結果を取得する
				foreach ($row as $key => $rec) {
				
					$tel_no = $rec["tel_column"];
					$consentday = $rec["consentday"]; // #8298 add consentday
					$tmp_sms_content = $template_content;
					if($hasInsertItem){
						foreach ($arr_items as $item_name) {
							$tmp_item = "{".$item_name."}";
							$tmp_sms_content = str_replace($tmp_item, $rec[$list_columns[$item_name]], $tmp_sms_content);
						}
					}
					// Check if schedule be stop or finish by hand
					Logger::writeLog("Get status of schedule before send sms. Schedule_id: ".$schedule_id."! Get from t200. (Send now)");

					//// スケジュールの開始時刻と終了時刻を監視する
					$cur_schedule_info = get_status_schedule($db_con, $schedule_id);
					$tmp_status = $cur_schedule_info["status"];
					Logger::writeLog("Status of schedule: ".$schedule_id." : ".statusToString($tmp_status).". (Send now)");

					if ($tmp_status == STATUS_STOPING || $tmp_status == STATUS_FINISH) {
						Logger::writeLog("Update schedule run end time history! Update t202. Schedule_id: ".$schedule_id.". (Send now)");
						begin_transaction($db_con);
						if (!update_time_end_send_log($db_con, $schedule_id)) {
							rollback($db_con);
							if (!sendErrorSmsScheduleMail($company_name, $schedule_id, $schedule_name, $template_id, $template_name, $list_name, $muko_tel_total, $str_time_send, $service_id, $display_number, $log_file_path))
								Logger::writeLog("ERROR: Send mail error schedule: " . $schedule_id.". (Send now)");
						} else {
							commit($db_con);
							 if ($tmp_status == STATUS_STOPING) {
								$subject_manual_stop = '【はやぶさ】SMS送信停止中';
							}
						}
						$exit_flag = true;
						break;
					}
					//// スケジュールの開始時刻と終了時刻を監視する_END

					// Check if time now greater than time end of schedule
					if (time() > strtotime($time_end)) {
						if($status == STATUS_SENDING){
							$status = STATUS_FINISHING;
							Logger::writeLog("Set Schedule: ".$schedule_id." to ".statusToString($status).". (Send now)");
							$subject_finish = '【はやぶさ】SMS送信終了中';
							// Change status of schedule
							begin_transaction($db_con);
							if (!set_status_schedule($db_con, $schedule_id, $status)) {
								$exit_flag = true;
								rollback($db_con);
								if (!sendErrorSmsScheduleMail($company_name, $schedule_id, $schedule_name, $template_id, $template_name, $list_name, $muko_tel_total, $str_time_send, $service_id, $display_number, $log_file_path))
									Logger::writeLog("ERROR: Send mail error schedule: " . $schedule_id.". (Send now)");
								break;
							} else {
								commit($db_con);
							}
		
							// Update time_end for log
							begin_transaction($db_con);
							if (!update_time_end_send_log($db_con, $schedule_id)) {
								rollback($db_con);
								if (!sendErrorSmsScheduleMail($company_name, $schedule_id, $schedule_name, $template_id, $template_name, $list_name, $muko_tel_total, $str_time_send, $service_id, $display_number, $log_file_path))
									Logger::writeLog("ERROR: Send mail error schedule: " . $schedule_id.". (Send now)");
							} else {
								commit($db_con);
							}
						}
						$exit_flag = true;
						break;
					}

					//// 恐らく、SendSmsで今動かしているスケジュールが動いた場合の対応
					if ($tmp_status != STATUS_SENDING){
						break;
					}
					$send_datetime = date("Y-m-d H:i:s");
					// Send SMS by API
					Logger::writeLog("Start.... Send sms [Send Now]: ".$tel_no.". (Send now)");
					Logger::writeLog("[consentday]".$consentday."[consent_flag]".$consent_flag); // #8298 add consentday
					//$tmp_sms_content = str_replace("\\","￥", $tmp_sms_content);

					///// API実行と結果取得
					if($configSmsApi["API_ID"] == SMS_API_V2_VALUE){
						// Connect to API
						$sms_api = new SmsApi_V2();
						$sms_api->config_v2($configSmsApi, $sms_use_short_url);
						$send_result = json_decode($sms_api->sendSms($tel_no, $consentday, $consent_flag, $tmp_sms_content), true);
						if ($send_result["status"] == "100") {
							//create t800 data
							$entry_id = $send_result["messageId"];
							begin_transaction($db_con);
							// t800を作成。
							if (!create_sms_send_result($db_con, $schedule_id, $tel_no, $send_datetime, $entry_id, "Send_now_V2")) {
								$exit_flag = true;
								rollback($db_con);
								if (!sendErrorSmsScheduleMail($company_name, $schedule_id, $schedule_name, $template_id, $template_name, $list_name, $muko_tel_total, $str_time_send, $service_id, $display_number, $log_file_path))
									Logger::writeLog("ERROR: Send mail error schedule: " . $schedule_id.". (Send now_V2)");
								break;
							} else {
								commit($db_con);
							}
						}else{
							Logger::writeLog( $tel_no . ":error_V2 " . $send_result["status"]);
							Logger::writeLog( print_r($sms_api->getSmsPostData(), 1));

							begin_transaction($db_con);
							$fail_status = "fail";
							$warning_msg = $send_result["status"];
							
							if (!create_sms_send_result_fail($db_con, $schedule_id, $tel_no, $send_datetime, "", $fail_status, $warning_msg, "Send_now_V2")) {
								$exit_flag = true;
								rollback($db_con);
								if (!sendErrorSmsScheduleMail($company_name, $schedule_id, $schedule_name, $template_id, $template_name, $list_name, $muko_tel_total, $str_time_send, $service_id, $display_number, $log_file_path))
									Logger::writeLog("ERROR: Send mail error schedule: " . $schedule_id.". (Send now_V2)");
								break;
							} else {
								commit($db_con);
							}
						}
					}
					else{
						// Connect to API
						$sms_api = new SmsApi();
						$sms_api->config1($configSmsApi);
						$send_result = json_decode($sms_api->sendSms($tel_no, $consentday, $consent_flag, $tmp_sms_content), true);
						if ($send_result["Result"]["Status"] == "SUCCESS") {
							//create t800 data
							$entry_id = $send_result["Result"]["EntryID"];
							begin_transaction($db_con);
							if (!create_sms_send_result($db_con, $schedule_id, $tel_no, $send_datetime, $entry_id, "Send_now")) {
								$exit_flag = true;
								rollback($db_con);
								if (!sendErrorSmsScheduleMail($company_name, $schedule_id, $schedule_name, $template_id, $template_name, $list_name, $muko_tel_total, $str_time_send, $service_id, $display_number, $log_file_path))
									Logger::writeLog("ERROR: Send mail error schedule: " . $schedule_id.". (Send now)");
								break;
							} else {
								commit($db_con);
							}
						} else if ($send_result["Result"]["Status"] == "FAIL") {
							Logger::writeLog( $tel_no . ":error " . $send_result["Result"]["ErrorCode"]);
							begin_transaction($db_con);
							
							if ($send_result["Result"]["ErrorCode"] == "-321"){ // #8298 add consentday
								$fail_status = "history_judgement_ng";
								$warning_msg = "履歴判定NG";
							} else {
								$fail_status = "fail";
								$warning_msg = "送信対象外";
							}
							
							if (!create_sms_send_result_fail($db_con, $schedule_id, $tel_no, $send_datetime, "", $fail_status, $warning_msg, "Send_now")) {
								$exit_flag = true;
								rollback($db_con);
								if (!sendErrorSmsScheduleMail($company_name, $schedule_id, $schedule_name, $template_id, $template_name, $list_name, $muko_tel_total, $str_time_send, $service_id, $display_number, $log_file_path))
									Logger::writeLog("ERROR: Send mail error schedule: " . $schedule_id.". (Send now)");
								break;
							} else {
								commit($db_con);
							}
						}
					}
					///// API実行と結果取得_ここまで

					$send_total = get_send_total_by_schedule($db_con, $schedule_id);
					if ($send_total === false) {
						$exit_flag = true;
						if (!sendErrorSmsScheduleMail($company_name, $schedule_id, $schedule_name, $template_id, $template_name, $list_name, $muko_tel_total, $str_time_send, $service_id, $display_number, $log_file_path))
							Logger::writeLog("ERROR: Send mail error schedule: " . $schedule_id.". (Send now)");
						break;
					}
	
					begin_transaction($db_con);
					if (!update_send_total($db_con, $schedule_id, $send_total)) {
						$exit_flag = true;
						rollback($db_con);
						if (!sendErrorSmsScheduleMail($company_name, $schedule_id, $schedule_name, $template_id, $template_name, $list_name, $muko_tel_total, $str_time_send, $service_id, $display_number, $log_file_path))
							Logger::writeLog("ERROR: Send mail error schedule: " . $schedule_id.". (Send now)");
						break;
					} else {
						commit($db_con);
					}
					usleep($batch_sleep_time*1000);
				}
				//// 発信リストの行数、SMSを送信し、結果を取得する_END(row loop_end)

				//// なんらかのエラーによる強制終了。
				if ($exit_flag) {
					exit(1);
				}


				$cur_schedule_info = get_status_schedule($db_con, $schedule_id);
				$tmp_status = $cur_schedule_info["status"];
				if ($tmp_status != STATUS_STOP_SEND && $tmp_status != STATUS_TEMP_FINISH && $tmp_status != STATUS_FINISH) {
					// Change status of schedule
					Logger::writeLog("Set status of schedule: " . $schedule_id . " to ".statusToString(STATUS_FINISHING)." (End of list: $list_id). (Send now)");
					begin_transaction($db_con);
					if (!set_status_schedule($db_con, $schedule_id, STATUS_FINISHING)) {
						rollback($db_con);
						if (!sendErrorSmsScheduleMail($company_name, $schedule_id, $schedule_name, $template_id, $template_name, $list_name, $muko_tel_total, $str_time_send, $service_id, $display_number, $log_file_path))
							Logger::writeLog("ERROR: Send mail error schedule: " . $schedule_id.". (Send now)");
						exit;
					} else {
						commit($db_con);
	
					}				
				}
				// Update time_end for log when send all list
				Logger::writeLog(" Update schedule run end time history (End of list　$list_id)! Update t202. Schedule: ".$schedule_id.". (Send now)");
				begin_transaction($db_con);
				if (!update_time_end_send_log($db_con, $schedule_id)) {
					rollback($db_con);
					if (!sendErrorSmsScheduleMail($company_name, $schedule_id, $schedule_name, $template_id, $template_name, $list_name, $muko_tel_total, $str_time_send, $service_id, $display_number, $log_file_path))
						Logger::writeLog("ERROR: Send mail auto stop schedule: " . $schedule_id.". (Send now)");
					exit(1);
				} else {
					commit($db_con);
				}				
			}else{
				Logger::writeLog("ERROR: Not exist schedule! Count schedule: ".sizeof($schedules). ". (Send now)");
			}
			Logger::writeLog("End Send sms.... (Send now)");
		} else {
			Logger::writeLog("ERROR: Send Sms connect DB!");
			Logger::writeLog("db_host: ".$config["db_host"]);
			Logger::writeLog("db_port: ".$config["db_port"]);
			Logger::writeLog("db_user: ".$config["db_user"]);
			Logger::writeLog("db_pass: ".$config["db_pass"]);
			Logger::writeLog("db_schema: ".$config["db_schema"]);
			if (!sendError())
				Logger::writeLog("ERROR: Send mail.. (Send now)");
		}
	} catch (Exception $e) {		
		Logger::writeLog($e->getMessage());
		if (!sendError())
			Logger::writeLog("ERROR: Send mail. (Send now)");
		exit(9);
	}
?>
