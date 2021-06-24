<?php
	require_once('Common.php');
	require('Logger.php');
	require('DB.php');
	require('DbProcess.php');
	require_once('SendSmsScheduleMail.php');

	try {
		if (!isset($argv[1])){
			Logger::writeLog("ERROR: Not exist schedule id parameter in Send sms mail when create or finish schedule");
			exit;
		}
		// Connect to DB
		$config = parse_ini_file('config.ini');
		$db_con = connectDB($config["db_host"], $config["db_port"], $config["db_user"], $config["db_pass"], $config["db_schema"]);
		if ($db_con !== false) {
			$scheduleId = $argv[1];
			// Get schedules to process
			$schedules = get_schedule_to_send($db_con, $scheduleId, true);
			if ($schedules === false) {
				Logger::writeLog("ERROR: Get schedule id: ".$scheduleId);
				if (!sendError())
					Logger::writeLog("ERROR: Send mail");
				exit;
			}
	
			if (!empty($schedules)) {
				$schedule_data = $schedules[0];
				$company_name = $schedule_data["company_name"];
	
				$schedule_id = $schedule_data["schedule_id"];
				$schedule_name = $schedule_data["schedule_name"];
				$service_id = $schedule_data["service_id"];
				$display_number = $schedule_data["display_number"];
				$status = $schedule_data["status"];
	
				$list_name = $schedule_data["list_name"];
				$muko_tel_total = $schedule_data["muko_tel_total"];
	
				$time_start = $schedule_data["time_start"];
				
				$template_id = $schedule_data["template_id"];
				$template_name = $schedule_data["template_name"];

				$str_time_send = '';
				$time_sends = getAllTimeSendSms($db_con, $schedule_id);
				if ($time_sends === false || sizeof($time_sends) == 0) {
					Logger::writeLog("ERROR: Get all run time of schedule_id: ".$schedule_id. ".(Send email Create or Finish)");
					if (!sendError())
						Logger::writeLog("ERROR: Send mail.(Send email Create or Finish)");
					exit(1);
				}
				foreach ($time_sends as $time_send) {
					$str_time_send .= $time_send["time_start"] . " ~ " . $time_send["time_end"] . ", ";
					$last_time_end = $time_send["time_end"];
				}
				$str_time_send = substr($str_time_send, 0, -2);
				
				$send_flag = false;				
				if ($status == STATUS_NO_SEND) {
					// create schedule
					$subject = '【はやぶさ】SMS送信予約';
					$send_flag = true;
				} elseif($status == STATUS_FINISH) {
					// manual finish schedule
					$subject = '【はやぶさ】SMS送信終了';
					$send_flag = true;
				}
			}
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
	}catch (Exception $e) {		
		Logger::writeLog($e->getMessage());
		if (!sendError())
			Logger::writeLog("ERROR: Send mail");
		exit;
	}
?>
