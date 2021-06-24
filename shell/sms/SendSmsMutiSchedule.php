<?php
	require('Common.php');
	require('Logger.php');
	require('DB.php');
	require('DbProcess.php');
	require('SendSmsScheduleMail.php');
	
	try {
		// Connect to DB
		$config = parse_ini_file('config.ini');
		$db_con = connectDB($config["db_host"], $config["db_port"], $config["db_user"], $config["db_pass"], $config["db_schema"]);
	
		if ($db_con !== false) {
			// Get list schedules to process
			$schedules = get_schedule_to_send($db_con);
			if ($schedules === false){			
				Logger::writeLog("ERROR[SendSmsMutiSchedule]: Get all the schedule");
				if (!sendError())
					Logger::writeLog("ERROR: Send mail");
				exit;
			}		
			if (sizeof($schedules) > 0) {
				
				$local_path = getSystemParameter($db_con, "SMS_BATCH","LOCAL_PATH");			
				foreach ($schedules as $key => $schedule_data) {
					if ($schedule_data["status"] == STATUS_STOP_SEND && $schedule_data["resend_flag"] != "Y") {
						continue;
					}
					Logger::writeLog("Run.... schedule_id: " . $schedule_data["schedule_id"]);
					$schedule_id = $schedule_data["schedule_id"];
					$cmd = "php " . $local_path . "SendSms.php ".$schedule_id." > /dev/null 2> /dev/null &";
					exec($cmd, $shell_result, $shell_result_status);
					if($shell_result_status != 0){
						Logger::writeLog("ERROR: Run command: ".$cmd);
						Logger::writeLog(implode(",",$shell_result));
						if (!sendError())
							Logger::writeLog("ERROR: Send mail");
					}
				}			
			}
		} else {
			Logger::writeLog("ERROR: Send Sms Multi Schedule connect DB!");
			Logger::writeLog("db_host: ".$config["db_host"]);
			Logger::writeLog("db_port: ".$config["db_port"]);
			Logger::writeLog("db_user: ".$config["db_user"]);
			Logger::writeLog("db_pass: ".$config["db_pass"]);
			Logger::writeLog("db_schema: ".$config["db_schema"]);
			if (!sendError())
				Logger::writeLog("ERROR: Send mail");
			exit;
		}
	} catch (Exception $e) {		
		Logger::writeLog($e->getMessage());
		if (!sendError())
			Logger::writeLog("ERROR: Send mail");
		exit;
	}
?>
