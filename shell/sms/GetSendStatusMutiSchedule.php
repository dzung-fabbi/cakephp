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
			$schedules = get_schedule_to_get_status($db_con);
			if ($schedules === false){
				Logger::writeLog("ERROR[GetSendStatusMutiSchedule]: Get all the schedule");
				if (!sendError())
					Logger::writeLog("ERROR: Send mail");
				exit(1);
			}
			if (sizeof($schedules) > 0) {
				$local_path = getSystemParameter($db_con, "SMS_BATCH","LOCAL_PATH");			
				foreach ($schedules as $key => $schedule_data) {
					Logger::writeLog("Get status schedule_id: " . $schedule_data["schedule_id"]);
					$schedule_id = $schedule_data["schedule_id"];
					$cmd = "php " . $local_path . "GetSendStatus.php ".$schedule_id." > /dev/null 2> /dev/null &";
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
			Logger::writeLog("ERROR: Get Sms Status Multi Schedule connect DB!");
			Logger::writeLog("db_host: ".$config["db_host"]);
			Logger::writeLog("db_port: ".$config["db_port"]);
			Logger::writeLog("db_user: ".$config["db_user"]);
			Logger::writeLog("db_pass: ".$config["db_pass"]);
			Logger::writeLog("db_schema: ".$config["db_schema"]);
			if (!sendError())
				Logger::writeLog("ERROR: Send mail");
			exit(1);
		}
	}catch (Exception $e) {		
		Logger::writeLog($e->getMessage());
		if (!sendError())
			Logger::writeLog("ERROR: Send mail");
		exit(9);
	}
?>
