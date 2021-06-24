<?php
	require_once('Common.php');
	require('Logger.php');
	require('DB.php');
	require('SmsApi.php');
	require('DbProcess.php');
	require_once('SendSmsScheduleMail.php');
	try {
		if (!isset($argv[1])){
			Logger::writeLog("ERROR: Not exist schedule id parameter in get status sms");
			echo "ERROR: Not exist schedule id parameter in get status sms";
			exit(0);
		}
		Logger::writeLog("Starting...get status sms!");
		// Connect to DB
		$config = parse_ini_file('config.ini');
		$db_con = connectDB($config["db_host"], $config["db_port"], $config["db_user"], $config["db_pass"], $config["db_schema"]);
	
		if ($db_con !== false) {
			$scheduleId = $argv[1];
			// Get list schedules to process
			$schedules = get_schedule_to_get_status($db_con, $scheduleId);
			if ($schedules === false)
				exit;
			
			if (sizeof($schedules) > 0) {
				// Get log file path to send mail error			
				$local_path = getSystemParameter($db_con, "SMS_BATCH","LOCAL_PATH");
				$log_file_path = $local_path . 'log/sms_log_' . date("Ymd").".log";
				$schedule_data = $schedules[0];			
				Logger::writeLog("Schedule_id: " . $schedule_data["schedule_id"]. ".(Get status)");
	
				$company_name = $schedule_data["company_name"];	
				$schedule_id = $schedule_data["schedule_id"];
				$schedule_name = $schedule_data["schedule_name"];
				$service_id = $schedule_data["service_id"];
				$display_number = $schedule_data["display_number"];
				$stop_time = $schedule_data["stop_time"];
				
				$list_name = $schedule_data["list_name"];
				$tel_total = $schedule_data["tel_total"];
				$time_start = $schedule_data["time_start"];
				$status = $schedule_data["status"];
				$list_id = $schedule_data["list_id"];
				$muko_tel_total = $schedule_data["muko_tel_total"];

				$template_id = $schedule_data["template_id"];
				$template_name = $schedule_data["template_name"];
				
				$str_time_send = '';
				$time_sends = getAllTimeSendSms($db_con, $schedule_id);
				if ($time_sends === false || sizeof($time_sends) == 0) {
					Logger::writeLog("ERROR: Get all run time of schedule_id: ".$schedule_id. ".(Get status)");
					if (!sendError())
						Logger::writeLog("ERROR: Send mail.(Get status)");
					exit(1);
				}
				foreach ($time_sends as $time_send) {
					$str_time_send .= $time_send["time_start"] . " ~ " . $time_send["time_end"] . ", ";
					$last_time_end = $time_send["time_end"];
				}
				$str_time_send = substr($str_time_send, 0, -2);
	
				// Get param connect to API
				Logger::writeLog("Get param to connect SMS API!. Service id: ".$service_id. ".(Get status)");
				$configSmsApi = get_configSmsApi($db_con, $service_id, "20");
				if ($configSmsApi === false) {
					Logger::writeLog("ERROR: Get sms api config: ".$schedule_id. ".(Get status)");
					if (!sendError())
						Logger::writeLog("ERROR: Send mail.(Get status)");
					exit(1);;
				}			
	
	
				// Get column contain tel number
				$tel_column = get_tel_column($db_con, $list_id);
				if ($tel_column === false) {
					if (!sendErrorSmsScheduleMail($company_name, $schedule_id, $schedule_name, $template_id, $template_name, $list_name, $muko_tel_total, $str_time_send, $service_id, $display_number, $log_file_path))
						Logger::writeLog("ERROR: Send mail error schedule: " . $schedule_id. ".(Get status)");
					exit(1);;
				}
	
				// Get list entry_id to get status
				Logger::writeLog("Get entry_id list! Get from t800. Schedule: ".$schedule_id. ".(Get status)");
				$row = get_list_entry_ids($db_con, $schedule_id);
				if ($row === false) {
					if (!sendErrorSmsScheduleMail($company_name, $schedule_id, $schedule_name, $template_id, $template_name, $list_name, $muko_tel_total, $str_time_send, $service_id, $display_number, $log_file_path))
						Logger::writeLog("ERROR: Send mail error schedule: " . $schedule_id. ".(Get status)");
					exit(1);;
				}
				Logger::writeLog("Schedule: ".$schedule_id.". Count update items: ".sizeof($row)."items. (Get status)");
	
				// Set status is STATUS_FINISHING if time now greater than last time end of schedule
				if (time() > strtotime($last_time_end)) {
					Logger::writeLog("Set status of schedule: " . $schedule_id . " to ".statusToString(STATUS_FINISHING).". Time end:". $last_time_end.  ".(Get status)");
					begin_transaction($db_con);
					if (!set_status_schedule($db_con, $schedule_id, STATUS_FINISHING)) {
						rollback($db_con);
						if (!sendErrorSmsScheduleMail($company_name, $schedule_id, $schedule_name, $template_id, $template_name, $list_name, $muko_tel_total, $str_time_send, $service_id, $display_number, $log_file_path))
							Logger::writeLog("ERROR: Send mail error schedule: " . $schedule_id. ".(Get status)");
						exit(1);
					} else {
						commit($db_con);
						$status = STATUS_FINISHING;
					}
				}
				// Check all tel number had result
				if (sizeof($row) == 0) {
					if ($status == STATUS_STOPING) {
						// Set status is STATUS_STOP_SEND if schedule is STATUS_STOPING					
						Logger::writeLog("Set status of schedule: " . $schedule_id . " to ".statusToString(STATUS_STOP_SEND).".(Get status)");
						begin_transaction($db_con);
						if (!set_status_schedule($db_con, $schedule_id, STATUS_STOP_SEND)) {
							rollback($db_con);
							if (!sendErrorSmsScheduleMail($company_name, $schedule_id, $schedule_name, $template_id, $template_name, $list_name, $muko_tel_total, $str_time_send, $service_id, $display_number, $log_file_path))
								Logger::writeLog("ERROR: Send mail error schedule: " . $schedule_id. ".(Get status)");
						} else {
							commit($db_con);
						}
	
					} elseif ($status == STATUS_FINISHING) {
						$has_next_schedule = check_has_next_schedule($db_con, $schedule_id);
						if(!$has_next_schedule){
							// Set status is STATUS_FINISH if schedule is STATUS_FINISHING
							Logger::writeLog("Set status of schedule: " . $schedule_id . " to ".statusToString(STATUS_FINISH).".(Get status)");
							if (!set_status_schedule($db_con, $schedule_id, STATUS_FINISH)) {
								rollback($db_con);
								if (!sendErrorSmsScheduleMail($company_name, $schedule_id, $schedule_name, $template_id, $template_name, $list_name, $muko_tel_total, $str_time_send, $service_id, $display_number, $log_file_path))
									Logger::writeLog("ERROR: Send mail error schedule: " . $schedule_id. ".(Get status)");
							} else {
								commit($db_con);
							}
						}else {
							// Set status is STATUS_FINISH if schedule is STATUS_FINISHING
							Logger::writeLog("Set status of schedule: " . $schedule_id . " to ".statusToString(STATUS_TEMP_FINISH).".(Get status)");
							if (!set_status_schedule($db_con, $schedule_id, STATUS_TEMP_FINISH)) {
								rollback($db_con);
								if (!sendErrorSmsScheduleMail($company_name, $schedule_id, $schedule_name, $template_id, $template_name, $list_name, $muko_tel_total, $str_time_send, $service_id, $display_number, $log_file_path))
									Logger::writeLog("ERROR: Send mail error schedule: " . $schedule_id. ".(Get status)");
							} else {
								commit($db_con);
							}
						}
					}
					exit(0);
				}
	
				$status_finishing = $status == STATUS_FINISHING ? true : false;
				$exit_flag = false;
				foreach ($row as $key => $data) {
					$tel_no = $data["tel_no"];
					$entry_id = $data["entry_id"];
	
					// Set status is STATUS_FINISHING if time now greater than last time end of schedule
					if (!$status_finishing && time() > strtotime($last_time_end)) {					
						Logger::writeLog("Set status of schedule: " . $schedule_id . " to ".statusToString(STATUS_FINISHING).". Time end:". $last_time_end.  ".(Get status)");
						begin_transaction($db_con);
						if (!set_status_schedule($db_con, $schedule_id, STATUS_FINISHING)) {
							$exit_flag = true;
							rollback($db_con);
							if (!sendErrorSmsScheduleMail($company_name, $schedule_id, $schedule_name, $template_id, $template_name, $list_name, $muko_tel_total, $str_time_send, $service_id, $display_number, $log_file_path))
								Logger::writeLog("ERROR: Send mail error schedule: " . $schedule_id. ".(Get status)");
							break;
						} else {
							$status_finishing = true;
							commit($db_con);
						}
					}
					// Check if schedule be finish by hand
					$cur_schedule_info = get_status_schedule($db_con, $schedule_id);
					$tmp_status = $cur_schedule_info["status"];
					if ($tmp_status == STATUS_FINISH) {
						$exit_flag = true;
						break;
					}

					// Get status send of entry_id
					Logger::writeLog("Get status send sms. Tel num: ".$tel_no. ".(Get status)");

					///// API実行と結果取得
					if($configSmsApi["API_ID"] == SMS_API_V2_VALUE){
						// Connect to API
						$sms_api = new SmsApi_V2();
						$sms_api->config_v2($configSmsApi);
						$send_result = json_decode($sms_api->getSendSmsStatus($entry_id), true);
						// t93にAPIの問い合わせを追加。(レコード追加に失敗したら、スキップ)
						if(createSmsGetStatusLog_V2($db_con, $send_result, $entry_id, $tel_no) === false){
							continue;
						}
						if(getApiValue_V2($send_result, "status") == "999"){
							Logger::writeLog(print_r("GetSendStatus.php_V2_Wait(status is [" . getApiValue_V2($send_result, "status") . "]. API Error occured.",1));
							continue;
						}

						$warning_msg = '不明';
						$status = 'fail';
						$sms_short_url_key = "";
						// 結果取得APIのステータスが100以外は失敗とみなす。
						if(getApiValue_V2($send_result, "status") == "100"){
							// メッセージの状態がない場合は、失敗とみなす。
							if (getApiValue_V2($send_result, "messagestatus") != ""){
								$status_code = getApiValue_V2($send_result, "messagestatus");
								// 待ち状態は、再度APIを叩く。
								if ($status_code == "0"){
									Logger::writeLog(print_r("GetSendStatus.php_V2_Wait(status_code == $status_code",1));
									continue;
								}
								else{
									// メッセージの状態が「SMS送信サービスと各キャリア間」でエラーとなっている場合は、失敗とみなす。
									// 現状は2：SMS送信エラー、3：履歴判定によるSMS送信エラー、9：不明　を想定。
									if ($status_code != "1") {
										if ($status_code == "3") {
											$status = "history_judgement_ng";
										}else{
											$status = "fail";
										}
										$warning_msg = "不明(ステータスコード：$status_code)";
									}
									// 送信結果が存在しない場合は、失敗とみなす。
									elseif(getApiValue_V2($send_result, "resultstatus") != ""){
										// まれにキャリアが入っていないことがあるので、その行は処理を中止。
										if(!getApiValue_V2($send_result, "carrier")){
											Logger::writeLog(print_r("GetSendStatus.php_V2_Wait(carrier is blank[" . getApiValue_V2($send_result, "carrier") . "]",1));
											continue;
										}

										$send_status = getApiValue_V2($send_result, "resultstatus");
										// 送信結果コード0（送信結果なし。まだ送信中なので、待つ。）
										// ※ソフトバンクの機内モードではここに来た。
										if($send_status == "0"){
											Logger::writeLog(print_r("GetSendStatus.php_V2_Wait(send_status == $send_status",1));
											continue;
										}elseif($send_status == "1"){
											$status = "success";
											$warning_msg = "";
										}
										elseif($send_status == "2"){
											$status = "outside";
											$warning_msg = "圏外";
										}
										elseif($send_status == "3"){
											$status = "fail";
											$warning_msg = "エラー";
										}
										elseif($send_status == "99"){
											$status = "unknown";
											$warning_msg = "不明(ステータスコード：$send_status)";
										}
										else{
											$status = "unknown";
											$warning_msg = "不明(ステータスコード：$send_status)";
										}
									}else{
										Logger::writeLog(print_r("GetSendStatus.php_V2_Wait(resultstatus is blank[" . getApiValue_V2($send_result, "resultstatus") . "]",1));
										continue;
									}
									// 短縮URLの文字列を抜き出す（配列が戻る。）
									preg_match_all('/https:\/\/kps.ms\/[A-Za-z0-9]{7}/', getCareerMsg_V2($send_result), $sms_messages);

									$sms_messages = $sms_messages[0];
									foreach ($sms_messages as $index => $sms_message) {
										// SMS本文中から短縮URLのURLパターンを空欄に変更し、キーだけを抜き出す。
										// https://kps.ms/PPb0BaG -> PPb0BaG
										$sms_message = str_replace("https://kps.ms/", "", $sms_message);
										if($sms_short_url_key == ""){
											$sms_short_url_key = $sms_message;
										}
										else{
											$sms_short_url_key = $sms_short_url_key . ":" . $sms_message;
										}
									}
								}
							}else{
								Logger::writeLog(print_r("GetSendStatus.php_V2_failed(messagestatus is blank[" . getApiValue_V2($send_result, "messagestatus") . "]",1));
							}
						}else{
							Logger::writeLog(print_r("GetSendStatus.php_V2_failed(status is blank[" . getApiValue_V2($status, "status") . "]",1));
						}
						// Update carrier info for tel number
						begin_transaction($db_con);
						if (!update_carrier_V2($db_con, $schedule_id, $tel_column, $tel_no, getApiValue_V2($send_result, "carrier"))) {
							$exit_flag = true;
							rollback($db_con);
							if (!sendErrorSmsScheduleMail($company_name, $schedule_id, $schedule_name, $template_id, $template_name, $list_name, $muko_tel_total, $str_time_send, $service_id, $display_number, $log_file_path)){
								Logger::writeLog("ERROR: Send mail error schedule: " . $schedule_id. ".(Get status)");
							}
							break;
						} else {
							commit($db_con);
						}
					}else{
						// Connect to API
						$sms_api = new SmsApi();
						$sms_api->config1($configSmsApi);

						$send_result = json_decode($sms_api->getSendSmsStatus($entry_id), true);
						//  Insert getstatus from SMS API to t93_sms_getstatus_log
						createSmsGetStatusLog($db_con, $send_result);
						$end_datetime = date("Y-m-d H:i:s");
						// warning_msg
						$warning_msg = "不明";
						if ($send_result["Result"]["Status"] == "SUCCESS") {						
							// 処理に成功したが、条件該当するレコードなかっ場合
							// Send request to getstatus OK but no records be returned.Ex: Invalid entry_id case
							if($send_result["Result"]["Count"] == 0){
								$status = "fail";
							}else{
								// Check record of status code
								if(isset($send_result["Result"]["Records"][0]["status"])){
									$status_code = $send_result["Result"]["Records"][0]["status"];
									// 5: au再送待ち. 6: 処理中. 15: ドコモ再送待ち. 25:ソフトバンク再送待ち. 35: その他キャリア再送待ち
									// 5: au wait to resend. 6: sending. 15: docomo wait to resend. 25: softbank wait to resend. 35: other wait to resend  
									if($status_code == "5" || $status_code == "6" || $status_code == "15" || $status_code == "25" || $status_code == "35"){
										continue;
									}else{
										$send_status = $send_result["Result"]["Records"][0]["send_result"];
										$carrier_id = $send_result["Result"]["Records"][0]["carrier_id"];
										if($send_status == "着信済み"){ // Sent successful
											$status = "success";
										} else if(($carrier_id == "4" || $carrier_id == "9") && $send_status == ""){ // Other carrier: Can't know success or fail
											$status = "unknown";
										} else if($send_status == "圏外") { // sent fail
											$status = "outside";
										} else {
											$status = "fail";
										}
										$end_datetime = $send_result["Result"]["Records"][0]["sent_date"];
										
										if(isset($send_result["Result"]["Records"][0]["send_result"])) $send_rs = $send_result["Result"]["Records"][0]["send_result"];
										if(isset($send_result["Result"]["Records"][0]["result_status"])) $rs_status = $send_result["Result"]["Records"][0]["result_status"];
										if(isset($send_result["Result"]["Records"][0]["command_status"])) $cmd_status = $send_result["Result"]["Records"][0]["command_status"];
										if(isset($send_result["Result"]["Records"][0]["network_error_code"])) $network_code = $send_result["Result"]["Records"][0]["network_error_code"];
										$warning_msg = getWarningMsg($carrier_id, $send_rs, $rs_status, $cmd_status, $network_code);
									}
								}
							}
							$carrier_id = $send_result["Result"]["Records"][0]["carrier_id"];
							// Update carrier info for tel number
							begin_transaction($db_con);
							if (!update_carrier($db_con, $schedule_id, $tel_column, $tel_no, $carrier_id)) {
								$exit_flag = true;
								rollback($db_con);
								if (!sendErrorSmsScheduleMail($company_name, $schedule_id, $schedule_name, $template_id, $template_name, $list_name, $muko_tel_total, $str_time_send, $service_id, $display_number, $log_file_path))
									Logger::writeLog("ERROR: Send mail error schedule: " . $schedule_id. ".(Get status)");
								break;
							} else {
								commit($db_con);
							}
						} else if ($send_result["Result"]["Status"] == "FAIL") {
							$end_datetime = date("Y-m-d H:i:s", time());
							$status = "fail";						
						}
					}
					///// API実行と結果取得_END

					////送信結果の更新
					// Update send result for tel number
					begin_transaction($db_con);

					if (!update_send_result($db_con, $schedule_id, $tel_no, $end_datetime, $status, $entry_id, $warning_msg, $sms_short_url_key, "GetSendStatus")) {
						$exit_flag = true;
						rollback($db_con);
						if (!sendErrorSmsScheduleMail($company_name, $schedule_id, $schedule_name, $template_id, $template_name, $list_name, $muko_tel_total, $str_time_send, $service_id, $display_number, $log_file_path))
							Logger::writeLog("ERROR: Send mail error schedule: " . $schedule_id. ".(Get status)");
						break;
					} else {
						commit($db_con);
					}				
				}

				if ($exit_flag) {
					break;
				}
	
				// Count total tel number had send result
				$total_send = count_total_send($db_con, $schedule_id);
				if ($total_send === false)
					break;					
				// Set status is STATUS_FINISH if all tel number of schedule is had result
				if ($total_send == $muko_tel_total) {
					Logger::writeLog("Set status of schedule: " . $schedule_id . " to ".statusToString(STATUS_FINISH).". Total send:". $total_send.  ".(Get status)");
					begin_transaction($db_con);
					if (!set_status_schedule($db_con, $schedule_id, STATUS_FINISH)) {
						rollback($db_con);
						if (!sendErrorSmsScheduleMail($company_name, $schedule_id, $schedule_name, $template_id, $template_name, $list_name, $muko_tel_total, $str_time_send, $service_id, $display_number, $log_file_path))
							Logger::writeLog("ERROR: Send mail error schedule: " . $schedule_id. ".(Get status)");
						break;
					} else {
						commit($db_con);
					}
				}
				// 5分を経って終了にならないスケジュールを強制的に終了する
				$force_stop_time = getSystemParameter($db_con, "SMS_BATCH","FORCE_STOP_TIME");
				$cur_schedule_info = get_status_schedule($db_con, $schedule_id);
				$tmp_status = $cur_schedule_info["status"];
				$stop_time = $cur_schedule_info["stop_time"];
				if(!empty($stop_time) && time() > (strtotime($stop_time) + $force_stop_time)){
					if($tmp_status == STATUS_STOPING){
						// Set status is STATUS_STOP_SEND if schedule is STATUS_STOPING
						Logger::writeLog("Force Set status of schedule: " . $schedule_id . " to ".statusToString(STATUS_STOP_SEND).".(Get status)");
						begin_transaction($db_con);
						if (!set_status_schedule($db_con, $schedule_id, STATUS_STOP_SEND)) {
							rollback($db_con);
							if (!sendErrorSmsScheduleMail($company_name, $schedule_id, $schedule_name, $template_id, $template_name, $list_name, $muko_tel_total, $str_time_send, $service_id, $display_number, $log_file_path))
								Logger::writeLog("ERROR: Send mail error schedule: " . $schedule_id. ".(Get status)");
						} else {
							commit($db_con);
						
						}
					}else if($tmp_status == STATUS_FINISHING){
						$has_next_schedule = check_has_next_schedule($db_con, $schedule_id);
						if(!$has_next_schedule){
							// Set status is STATUS_FINISH if schedule is STATUS_FINISHING
							Logger::writeLog("Force Set status of schedule: " . $schedule_id . " to ".statusToString(STATUS_FINISH).".(Get status)");
							if (!set_status_schedule($db_con, $schedule_id, STATUS_FINISH)) {
								rollback($db_con);
								if (!sendErrorSmsScheduleMail($company_name, $schedule_id, $schedule_name, $template_id, $template_name, $list_name, $muko_tel_total, $str_time_send, $service_id, $display_number, $log_file_path))
									Logger::writeLog("ERROR: Send mail error schedule: " . $schedule_id. ".(Get status)");
							} else {
								commit($db_con);
							}
						}else {
							// Set status is STATUS_FINISH if schedule is STATUS_FINISHING
							Logger::writeLog("Force Set status of schedule: " . $schedule_id . " to ".statusToString(STATUS_TEMP_FINISH).".(Get status)");
							if (!set_status_schedule($db_con, $schedule_id, STATUS_TEMP_FINISH)) {
								rollback($db_con);
								if (!sendErrorSmsScheduleMail($company_name, $schedule_id, $schedule_name, $template_id, $template_name, $list_name, $muko_tel_total, $str_time_send, $service_id, $display_number, $log_file_path))
									Logger::writeLog("ERROR: Send mail error schedule: " . $schedule_id. ".(Get status)");
							} else {
								commit($db_con);
							}
						}
					}
				}
			}
			Logger::writeLog("End get status sms!");
		} else {
			Logger::writeLog("ERROR: Send Sms connect DB!");
			Logger::writeLog("db_host: ".$config["db_host"]);
			Logger::writeLog("db_port: ".$config["db_port"]);
			Logger::writeLog("db_user: ".$config["db_user"]);
			Logger::writeLog("db_pass: ".$config["db_pass"]);
			Logger::writeLog("db_schema: ".$config["db_schema"]);
			if (!sendError())
				Logger::writeLog("ERROR: Send mail");
		}
	} catch (Exception $e) {		
		Logger::writeLog($e->getMessage());
		if (!sendError())
			Logger::writeLog("ERROR: Send mail");
		exit(9);
	}
?>
