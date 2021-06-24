<?php
/** Get list schedule to send SMS
 * @param resource $db_con
 * @param int $schedule_id
 * @param $abort_condition_time　true：再送でない　false:再送
 * @return False|Array schedule
 */
function get_schedule_to_send($db_con, $schedule_id=null, $abort_condition_time=false) {
	$now = date("Y-m-d H:i:00");
	if (isset($schedule_id)) {
		$where = "  WHERE T200.id = '" . $schedule_id . "'";
	} else {
		$where = " WHERE (T200.status IN (" . STATUS_NO_SEND . ", " . STATUS_TEMP_FINISH . ") OR".
			" (T200.status IN (" . STATUS_STOP_SEND . ") AND resend_flag = 'Y'))"
			. " AND T200.del_flag = 'N'";
	}

	if ($abort_condition_time) {
		$condition_time_send = "";
	} else {
		$condition_time_send = " AND T201.time_end >= '" . $now . "'"
			. " AND T201.time_start = '" . $now . "'";
	}

	$str_query = "SELECT T200.id as schedule_id, T200.schedule_name, T200.status, T200.resend_flag, T200.service_id, T200.list_id, T100.list_name, T100.list_test_flag,"
		. " T100.tel_total, T100.muko_tel_total, T200.template_id, T300.template_name, T300.description, T300.content, T201.time_start, T201.time_end, M02.company_name, T200.display_number, T200.consent_flag,"
		. " T300.sms_use_short_url"
		. " FROM t200_sms_send_schedules AS T200"
		. " INNER JOIN t201_sms_send_times AS T201"
		. " ON T201.schedule_id = T200.id"
		. " AND T201.del_flag = 'N'"
		. $condition_time_send
		. " INNER JOIN t100_sms_send_lists AS T100"
		. " ON T100.id = T200.list_id"
		. " AND T100.del_flag = 'N'"
		. " INNER JOIN t300_sms_templates AS T300"
		. " ON T300.id = T200.template_id"
		. " AND T300.del_flag = 'N'"
		. " INNER JOIN m02_companies AS M02"
		. " ON M02.id = T200.company_id"
		. " AND M02.del_flag = 'N'"
		. $where
		. " GROUP BY T201.schedule_id"
		. " ORDER BY T201.time_start, T201.time_end";
	$result_query = query($db_con, $str_query);
	if ($result_query === false) {
		Logger::writeLog("Error while query get schedule to execute!");
		Logger::writeLog($str_query);
		return false;
	}
	$fields = array("schedule_id", "schedule_name", "status", "resend_flag", "service_id", "list_id", "list_name", "list_test_flag", "tel_total",
		"muko_tel_total", "template_id", "template_name", "description", "content", "time_start", "time_end", "company_name", "display_number", "consent_flag", "sms_use_short_url");
	$row = getRows($result_query, $fields);
	return $row;
}

/** Get list schedule to get status send SMS
 * @param resource $db_con
 * @param int $schedule_id
 * @return False|Array schedule
 */
function get_schedule_to_get_status($db_con, $schedule_id=null) {
	if (isset($schedule_id)) {
		$where = "  WHERE T200.id = '" . $schedule_id . "'";
	} else {
		$where = " WHERE T200.status IN (" . STATUS_SENDING . ", " . STATUS_FINISHING . ", " . STATUS_STOP_SEND . ", " . STATUS_STOPING . ")";
	}

	$str_query = "SELECT T200.id as schedule_id, T200.schedule_name, T200.status, T200.service_id, T200.list_id, T100.list_name, T100.tel_total,"
		. " T100.muko_tel_total, T201.time_start, M02.company_name, T200.template_id, T300.template_name, T200.stop_time, T200.display_number"
		. " FROM t200_sms_send_schedules AS T200"
		. " INNER JOIN t201_sms_send_times AS T201"
		. " ON T201.schedule_id = T200.id"
		. " AND T201.del_flag = 'N'"
		. " INNER JOIN t100_sms_send_lists AS T100"
		. " ON T100.id = T200.list_id"
		. " AND T100.del_flag = 'N'"
		. " INNER JOIN t300_sms_templates AS T300"
		. " ON T300.id = T200.template_id"
		. " AND T300.del_flag = 'N'"
		. " INNER JOIN m02_companies AS M02"
		. " ON M02.id = T200.company_id"
		. " AND M02.del_flag = 'N'"
		. $where
		. " AND T200.del_flag = 'N'"
		. " GROUP BY T201.schedule_id"
		. " ORDER BY T201.time_start, T201.time_end";
	$result_query = query($db_con, $str_query);
	if ($result_query === false) {
		Logger::writeLog("Error while query get schedule to execute!");
		return false;
	}
	$fields = array("schedule_id", "schedule_name", "status", "service_id", "list_id", "list_name", "tel_total", "muko_tel_total", "time_start", "company_name", "template_id", "template_name", "stop_time", "display_number");
	$row = getRows($result_query, $fields);
	return $row;
}

/** Get arrray param to connect API
 * @param resource $db_con
 * @param string $service_id
 * @return False|Array param
 */
function get_configSmsApi($db_con, $service_id, $role_code = "30") {
	$arr_params = array(
		"url",
		"service_id",
		"group_id",
		"user",
		"pass",
		"max_parallel_session",
		"max_send_in_minute",
		"proxy_host",
		"proxy_port",
		"proxy_user",
		"proxy_pass",
		"batch_sleep_time",
		"api_id"
	);
	$configSmsApi = array();
	if($role_code != "10" && $role_code != "20")
		$role_code  = "30";
	$api_v2_str = SMS_API_V2_VALUE;

	$str_query = "SELECT * FROM m08_sms_api_infos WHERE service_id = '$service_id' AND ((role_code='$role_code' AND api_id != '$api_v2_str') OR api_id = '$api_v2_str') AND del_flag = 'N' LIMIT 1";

	$result_query = query($db_con, $str_query);
	if ($result_query !== false) {
		$row = getRows($result_query, $arr_params);
		if (sizeof($row) > 0) {
			foreach ($arr_params as $param) {
				$configSmsApi[strtoupper($param)] = $row[0][$param];
			}
		} else {
			Logger::writeLog("Error missing param to connect to API!");
			return false;
		}
	} else {
		Logger::writeLog("Error while query get param to connect to API!");
		return false;
	}

	return $configSmsApi;
}
/** Set status of schedule
 * @param resource $db_con
 * @param int $schedule_id
 * @param int $status
 * @return boolean
 */
function set_status_schedule($db_con, $schedule_id, $status) {
	$str_query = "UPDATE t200_sms_send_schedules SET status=$status, modified=NOW(), update_program='sms_api(set_status_schedule)'  WHERE id=$schedule_id";
	$result_query = query($db_con, $str_query);
	if ($result_query === false) {
		Logger::writeLog("Error while update status schedule!");
		return false;
	}
	$flag = true;
	if($status == STATUS_STOPING || $status == STATUS_FINISHING){
		$flag = update_stop_time($db_con, $schedule_id);
	}
	return $flag;
}
/** Get status of schedule
 * @param resource $db_con
 * @param int $schedule_id
 * @return False|status of schedule
 */
function get_status_schedule($db_con, $schedule_id) {
	$str_query = "SELECT status, stop_time FROM t200_sms_send_schedules WHERE id=$schedule_id";
	$result_query = query($db_con, $str_query);
	if ($result_query === false) {
		Logger::writeLog("Error while get status schedule!");
		return false;
	}
	$row = getRows($result_query, array('status', 'stop_time'));
	$schedule_info = array();
	if (sizeof($row) > 0) {
		$schedule_info["status"] = $row[0]["status"];
		$schedule_info["stop_time"] = $row[0]["stop_time"];
	} else {
		Logger::writeLog("Error not exist schedule: ".$schedule_id);
		return false;
	}
	return $schedule_info;
}
/** Create data t500_sms_list_histories
 * @param resource $db_con
 * @param int $schedule_id
 * @param int $list_id
 * @param string $list_name
 * @param boolean $list_test_flag
 * @param int $muko_tel_total
 * @return boolean
 */
function create_list_history($db_con, $schedule_id, $list_id, $list_name, $list_test_flag, $tel_total, $muko_tel_total) {
	$str_query = "INSERT INTO t500_sms_list_histories" 
		. " (schedule_id, list_id, list_name, list_test_flag, tel_total, muko_tel_total, del_flag, created, entry_program)" 
		. " VALUES('$schedule_id', '$list_id', '$list_name', '$list_test_flag', '$tel_total', '$muko_tel_total', 'N', NOW(), 'sms_api')";
	$result_query = query($db_con, $str_query);
	if ($result_query === false) {
		Logger::writeLog("Error while create t500_sms_list_histories!");
		return false;
	}
	return true;
}
/** Create data t501_sms_tel_histories
 * @param resource $db_con
 * @param int $schedule_id
 * @param int $list_id
 * @return boolean
 */
function create_tel_history($db_con, $schedule_id, $list_id) {
	$str_query = "INSERT INTO t501_sms_tel_histories" 
		. " (schedule_id, customize1, customize2, customize3, customize4, customize5, customize6, customize7, customize8, customize9, customize10, customize11, muko_flag, muko_modified, del_flag, created, entry_program, consentday)" 
		. " SELECT '$schedule_id', customize1, customize2, customize3, customize4, customize5, customize6, customize7, customize8, customize9, customize10, customize11, muko_flag, muko_modified, 'N', NOW(), 'sms_api', consentday FROM t101_sms_tel_lists WHERE list_id = '$list_id' and del_flag='N'";
	$result_query = query($db_con, $str_query);
	if ($result_query === false) {
		Logger::writeLog("Error while create t501_sms_tel_histories!");
		return false;
	}
	return true;
}
/** Create data t600_sms_template_histories
 * @param resource $db_con
 * @param int $schedule_id
 * @param int $template_id
 * @param string $template_name
 * @param string $description
 * @return boolean
 */
function create_template_history($db_con, $schedule_id, $template_id, $template_name, $description, $content, $sms_use_short_url) {
	$content = str_replace('"','\"',str_replace("'","\'", str_replace("\\","\\\\",$content)));
	$template_name = str_replace('"','\"',str_replace("'","\'", str_replace("\\","\\\\",$template_name)));
	$description = str_replace('"','\"',str_replace("'","\'", str_replace("\\","\\\\",$description)));
	$str_query = "INSERT INTO t600_sms_template_histories" 
		. " (schedule_id, template_id, template_name, description, content, use_short_url, del_flag, created, entry_program)"
		. " VALUES('$schedule_id', '$template_id', '$template_name', '$description', '$content', '$sms_use_short_url', 'N', NOW(), 'sms_api')";
	$result_query = query($db_con, $str_query);
	if ($result_query === false) {
		Logger::writeLog("Error while create t600_sms_template_histories!");
		return false;
	}
	return true;
}
function get_list_items($db_con, $list_id){
	$str_query = "SELECT t102_sms_list_items.column as item_column, item_code, item_name FROM t102_sms_list_items WHERE list_id=$list_id AND del_flag='N'";
	$result_query = query($db_con, $str_query);
	if ($result_query === false) {
		echo "Error while query get item_column!\n";
		return false;
	}
	$row = getRows($result_query, array("item_column", "item_code", "item_name"));
	return $row;
}
/** Get list tel number not send
 * @param resource $db_con
 * @param int $schedule_id
 * @param int $list_id
 * @return array tel number,consentday, customize1,...
 */
function get_list_tel_not_send($db_con, $schedule_id, $list_id) {
	
	$row = get_list_items($db_con, $list_id);
	if($row === false) return array();

	$arr_items = array();
	foreach ($row as $key => $rec) {
		if($rec["item_code"] == "tel_no"){
			$tel_column = $rec["item_column"];
		}
		array_push($arr_items, $rec["item_column"]);
	}
	$str_col = "";
	$fields = array("tel_column", "consentday"); // #8298 add consentday
	if(!empty($arr_items)){
		foreach ($arr_items as $item_column) {
			Logger::writeLog("item_column: ". $item_column);
			if(!empty($item_column)){
				$str_col .= "," . $item_column;
				array_push($fields, $item_column);
			}
		}
	}
	$str_query = "SELECT $tel_column as tel_column,consentday $str_col FROM t501_sms_tel_histories"
		. " LEFT JOIN t800_sms_send_results"
		. " ON t501_sms_tel_histories.$tel_column=t800_sms_send_results.tel_no"
		. " AND t501_sms_tel_histories.schedule_id=t800_sms_send_results.schedule_id"
		. " WHERE t501_sms_tel_histories.schedule_id=$schedule_id"
		. " AND t800_sms_send_results.tel_no IS NULL"
		. " AND t501_sms_tel_histories.muko_flag='N'"
		. " AND t501_sms_tel_histories.del_flag = 'N'"
		. " ORDER BY rand()";
	$result_query = query($db_con, $str_query);
	if ($result_query === false) {
		Logger::writeLog("Error while query get tel_lists to send SMS!");
		return false;
	}
	$row = getRows($result_query, $fields);

	return $row;
}
/** Create data t800_sms_send_results
 * @param resource $db_con
 * @param int $schedule_id
 * @param string $tel_no
 * @param string $send_datetime
 * @param string $entry_id
 * @return boolean
 */
function create_sms_send_result($db_con, $schedule_id, $tel_no, $send_datetime, $entry_id, $call_from) {
	$str_query = "INSERT INTO t800_sms_send_results" 
		. " (schedule_id, tel_no, send_datetime, entry_id, created, entry_program)" 
		. " VALUES('$schedule_id', '$tel_no', '$send_datetime', '$entry_id', NOW(), '$call_from')";
	$result_query = query($db_con, $str_query);
	if ($result_query === false) {
		Logger::writeLog("Error while create t800_sms_send_results!");
		return false;
	}
	return true;
}

/** Create data t800_sms_send_results when fail case
 * @param resource $db_con
 * @param int $schedule_id
 * @param string $tel_no
 * @param string $send_datetime
 * @param string $entry_id
 * @param string $status
 * @return boolean
 */
function create_sms_send_result_fail($db_con, $schedule_id, $tel_no, $send_datetime, $entry_id, $status, $message, $call_from) {
	$str_query = "INSERT INTO t800_sms_send_results"
			. " (schedule_id, tel_no, send_datetime, entry_id, end_datetime, status, warning_msg, created, entry_program)"
					. " VALUES('$schedule_id', '$tel_no', '$send_datetime', '$entry_id', NOW(), '$status', '$message', NOW(), '$call_from')";
	$result_query = query($db_con, $str_query);
	if ($result_query === false) {
		Logger::writeLog("Error while create t800_sms_send_results! create_sms_send_result_fail");
		return false;
	}
	return true;
}
/** Create data t202_sms_send_logs
 * @param resource $db_con
 * @param int $schedule_id
 * @return boolean
 */
function create_sms_send_log($db_con, $schedule_id) {
	$str_query = "INSERT INTO t202_sms_send_logs" 
		. " (schedule_id, time_start, del_flag, created, entry_program)" 
		. " VALUES('$schedule_id', NOW(), 'N', NOW(), 'sms_api')";
	$result_query = query($db_con, $str_query);
	if ($result_query === false) {
		Logger::writeLog("Error while create t202_sms_send_logs!");
		return false;
	}
	return true;
}
/** Update time_end for t800_sms_send_results
 * @param resource $db_con
 * @param int $schedule_id
 * @return boolean
 */
function update_time_end_send_log($db_con, $schedule_id) {
	$str_query = "UPDATE t202_sms_send_logs" 
		. " SET time_end=NOW(), modified=NOW(), update_program='sms_api'" 
		. " WHERE schedule_id=$schedule_id"
		. " ORDER BY time_start DESC"
		. " LIMIT 1";
	$result_query = query($db_con, $str_query);
	if ($result_query === false) {
		Logger::writeLog("Error while update time_end of t202_sms_send_logs!");
		return false;
	}
	return true;
}
/** Get tel_column of list
 * @param resource $db_con
 * @param int $list_id
 * @return boolean|string is name of column in table t102_sms_list_items contain tel number
 */
function get_tel_column($db_con, $list_id) {
	$str_query = "SELECT t102_sms_list_items.column as tel_column FROM t102_sms_list_items WHERE list_id=$list_id AND item_code='tel_no' AND del_flag='N'";
	$result_query = query($db_con, $str_query);
	if ($result_query === false) {
		Logger::writeLog("Error while query get tel_column!");
		return false;
	}
	$row = getRows($result_query, array("tel_column"));
	$tel_column = $row[0]["tel_column"];
	return $tel_column;
}
/** Update send result to table t800_sms_send_results
 * @param resource $db_con
 * @param int $schedule_id
 * @param string $tel_no
 * @param string $end_datetime
 * @param string $status
 * @return boolean
 */
function update_send_result($db_con, $schedule_id, $tel_no, $end_datetime, $status, $entry_id ,$warning_msg, $sms_short_url_key, $call_from) {
	$str_query = "UPDATE t800_sms_send_results" 
		. " SET end_datetime='$end_datetime', status='$status', warning_msg='$warning_msg', sms_short_url_key='$sms_short_url_key', modified=NOW(), update_program='$call_from'" 
		. " WHERE schedule_id=$schedule_id"
		. " AND tel_no='$tel_no'"
		. " AND entry_id='$entry_id'";
	$result_query = query($db_con, $str_query);
	if ($result_query === false) {
		Logger::writeLog("Error while update end_datetime of t800_sms_send_results!");
		return false;
	}
	return true;
}
/** Update carrier table t501_sms_tel_histories
 * @param resource $db_con
 * @param int $schedule_id
 * @param string $tel_column
 * @param string $tel_no
 * @param int $carrier_id
 * @return boolean
 */
function update_carrier($db_con, $schedule_id, $tel_column, $tel_no, $carrier_id) {
	if ($carrier_id == 1) {
		$carrier = "docomo";
	} elseif ($carrier_id == 2) {
		$carrier = "softbank";
	} elseif ($carrier_id == 3) {
		$carrier = "au";
	} else {
		$carrier = "その他";
	}
	$str_query = "UPDATE t501_sms_tel_histories" 
		. " SET carrier='$carrier', modified=NOW(), update_program='sms_api'" 
		. " WHERE schedule_id=$schedule_id"
		. " AND $tel_column='$tel_no'";
	$result_query = query($db_con, $str_query);
	if ($result_query === false) {
		Logger::writeLog("Error while update carrier of t501_sms_tel_histories!");
		return false;
	}
	return true;
}
/** Get list entry_id with status is not SUCCESS in t800_sms_send_results by schedule_id
 * @param resource $db_con
 * @param int $schedule_id
 * @return boolean|array contain tel_no with entry_id
 */
function get_list_entry_ids($db_con, $schedule_id) {
	$str_query = "SELECT tel_no, entry_id FROM t800_sms_send_results WHERE schedule_id=$schedule_id AND status IS NULL";
	$result_query = query($db_con, $str_query);
	if ($result_query === false) {
		Logger::writeLog("Error while query get list entry_id!");
		return false;
	}
	$row = getRows($result_query, array("tel_no", "entry_id"));
	return $row;
}
/** Count total tel number send and have result
 * @param resource $db_con
 * @param int $schedule_id
 * @return boolean|int
 */
function count_total_send($db_con, $schedule_id) {
	$str_query = "SELECT COUNT(*) as total_send FROM t800_sms_send_results  WHERE schedule_id=$schedule_id AND status IS NOT NULL";
	$result_query = query($db_con, $str_query);
	if ($result_query === false) {
		Logger::writeLog("Error while query count total_send!");
		return false;
	}
	$row = getRows($result_query, array("total_send"));
	$total_send = $row[0]["total_send"];
	return $total_send;
}
/** Count result in t800_sms_send_results by schedule_id
 * @param resource $db_con
 * @param int $schedule_id
 * @return boolean|count result in t800
 */
function get_send_total_by_schedule($db_con, $schedule_id) {
	$str_query = "SELECT COUNT(*) as count_result FROM t800_sms_send_results WHERE schedule_id=$schedule_id";
	$result_query = query($db_con, $str_query);
	if ($result_query === false) {
		Logger::writeLog("Error while query get count_result from t800_sms_send_results!");
		return false;
	}
	$row = getRows($result_query, array("count_result"));
	return $row[0]["count_result"];
}
/** Update send total to table t200_sms_send_schedules
 * @param resource $db_con
 * @param int $schedule_id
 * @param int $send_total
 * @return boolean
 */
function update_send_total($db_con, $schedule_id, $send_total) {
	$str_query = "UPDATE t200_sms_send_schedules SET send_total=$send_total, modified=NOW(), update_program='sms_api(update_send_total)'  WHERE id=$schedule_id";
	$result_query = query($db_con, $str_query);
	if ($result_query === false) {
		Logger::writeLog("Error while update send_total of t200_sms_send_schedules!");
		return false;
	}
	return true;
}

/** Update stop time to table t200_sms_send_schedules
 * @param resource $db_con
 * @param int $schedule_id
 * @param int $send_total
 * @return boolean
 */
function update_stop_time($db_con, $schedule_id) {
	$str_query = "UPDATE t200_sms_send_schedules SET stop_time=NOW(), modified=NOW(), update_program='sms_api(update_stop_time)'  WHERE id=$schedule_id";
	$result_query = query($db_con, $str_query);
	if ($result_query === false) {
		Logger::writeLog("Error while update stop_time of t200_sms_send_schedules!");
		return false;
	}
	return true;
}
/** Get parameter from m99_system_parameters
 * @param string $function_id
 * @param string $parameter_id
 * @return boolean
 */
function getSystemParameter($db_con, $function_id = null, $parameter_id = null){
	if($function_id == null || $parameter_id == null) 
		return null;
	$str_query = "SELECT parameter_value as paramerter FROM m99_system_parameters WHERE function_id='$function_id' AND parameter_id='$parameter_id' AND del_flag='N'";
	$result_query = query($db_con, $str_query);
	if ($result_query === false) {
		Logger::writeLog("Error while query get parameter from m99_system_parameters!");
		return null;
	}
	$row = getRows($result_query, array("paramerter"));
	return $row[0]["paramerter"];
}

/** Insert getstatus from SMS API to t93_sms_getstatus_log
 * @param object $db_con
 * @param array $result
 * @return boolean
 */
function createSmsGetStatusLog($db_con, $result = array()){
	if (sizeof($result) == 0)return false;
	$rs = $result["Result"];
	if(!isset($rs["Status"])) $rs["Status"] = "";
	if(!isset($rs["Count"])) $rs["Count"] = "";
	if(!isset($rs["ErrorCode"])) $rs["ErrorCode"] = "";
	if(!isset($rs["Records"][0]["create_date"])) $rs["Records"][0]["create_date"] = "";
	if(!isset($rs["Records"][0]["entry_id"])) $rs["Records"][0]["entry_id"] = "";
	if(!isset($rs["Records"][0]["req_stat"])) $rs["Records"][0]["req_stat"] = "";
	if(!isset($rs["Records"][0]["group_id"])) $rs["Records"][0]["group_id"] = "";
	if(!isset($rs["Records"][0]["service_id"])) $rs["Records"][0]["service_id"] = "";
	if(!isset($rs["Records"][0]["user"])) $rs["Records"][0]["user"] = "";
	if(!isset($rs["Records"][0]["to_address"])) $rs["Records"][0]["to_address"] = "";
	if(!isset($rs["Records"][0]["use_cr_find"])) $rs["Records"][0]["use_cr_find"] = "";
	if(!isset($rs["Records"][0]["carrier_id"])) $rs["Records"][0]["carrier_id"] = "";
	if(!isset($rs["Records"][0]["message_no"])) $rs["Records"][0]["message_no"] = "";
	if(!isset($rs["Records"][0]["message"])) $rs["Records"][0]["message"] = "";
	if(!isset($rs["Records"][0]["encode"])) $rs["Records"][0]["encode"] = "";
	if(!isset($rs["Records"][0]["permit_time"])) $rs["Records"][0]["permit_time"] = "";
	if(!isset($rs["Records"][0]["sent_date"])) $rs["Records"][0]["sent_date"] = "";
	if(!isset($rs["Records"][0]["status"])) $rs["Records"][0]["status"] = "";
	if(!isset($rs["Records"][0]["send_result"])) $rs["Records"][0]["send_result"] = "";
	if(!isset($rs["Records"][0]["result_status"])) $rs["Records"][0]["result_status"] = "";
	if(!isset($rs["Records"][0]["command_status"])) $rs["Records"][0]["command_status"] = "";
	if(!isset($rs["Records"][0]["network_error_code"])) $rs["Records"][0]["network_error_code"] = "";
	if(!isset($rs["Records"][0]["tracking_code"])) $rs["Records"][0]["tracking_code"] = "";
	if(!isset($rs["Records"][0]["partition_size"])) $rs["Records"][0]["partition_size"] = "";
	if(!isset($rs["Records"][0]["use_jdg_find"])) $rs["Records"][0]["use_jdg_find"] = "";
	$v = " VALUES('".$rs["Records"][0]["entry_id"]."','".$rs["Status"]."','".			
			$rs["Count"]."','".
			$rs["Records"][0]["create_date"]."','".$rs["Records"][0]["req_stat"]."','".
			$rs["Records"][0]["group_id"]."','".$rs["Records"][0]["service_id"]."','".
			$rs["Records"][0]["user"]."','".$rs["Records"][0]["to_address"]."','".
			$rs["Records"][0]["use_cr_find"]."','".$rs["Records"][0]["carrier_id"]."','".
			$rs["Records"][0]["message_no"]."','".$rs["Records"][0]["message"]."','".
			$rs["Records"][0]["encode"]."','".$rs["Records"][0]["permit_time"]."','".
			$rs["Records"][0]["sent_date"]."','".$rs["Records"][0]["status"]."','".
			$rs["Records"][0]["send_result"]."','".$rs["Records"][0]["result_status"]."','".
			$rs["Records"][0]["command_status"]."','".$rs["Records"][0]["network_error_code"]."','".
			$rs["Records"][0]["tracking_code"]."','".$rs["Records"][0]["partition_size"]."','".
			$rs["Records"][0]["use_jdg_find"]."','".$rs["ErrorCode"]."', NOW(),'sms_batch')";
	
	$str_query = "INSERT INTO t93_sms_getstatus_log"
			. " (entry_id, ResStatus, ResCount, create_date, req_stat, group_id, service_id, user,to_address,use_cr_find,carrier_id,message_no,message,encode,permit_time,"
			."sent_date,status,send_result,result_status,command_status,network_error_code,tracking_code,partition_size,use_jdg_find,ResErrorCode,created,entry_user)"
			. $v;
	$result_query = query($db_con, $str_query);
	if ($result_query === false) {
		Logger::writeLog("Error while create t93_sms_getstatus_log!");
		return false;
	}
	return true;
}

/** Insert getstatus from SMS API to t93_sms_getstatus_log
 * @param object $db_con
 * @param array $result
 * @return boolean
 */
function createSmsGetStatusLog_V2($db_con, $result = array(), $entry_id, $tel_no){
	if (sizeof($result) == 0)return false;

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
    #### network_error_codeはApiV2では設定がありません。（NULLとします。）
    #### tracking_codeはApiV2では設定がありません。（NULLとします。）
    #### partition_sizeはApiV2では設定がありません。（NULLとします。）
    #### use_jdg_findはApiV2では設定がありません。（NULLとします。）
    #### resErrorCodeはApiV2では設定がありません。（NULLとします。）


    #### send_resultはApiV2では設定がありません。（NULLとします。）

	$v = " VALUES('".$entry_id."','".
			getApiValue_V2($result, "status")."','".
			getApiValue_V2($result, "senddate")."','".
			$tel_no."','".
			getApiValue_V2($result, "carrier")."','".
			mysql_real_escape_string(getCareerMsg_V2($result))."','".
			getApiValue_V2($result, "messagestatus")."','".
			getApiValue_V2($result, "resultstatus")."',".
			"NOW(),'sms_batch_v2')";


	$str_query = "INSERT INTO t93_sms_getstatus_log"
			. " (entry_id, ResStatus, create_date, to_address,carrier_id,message,"
			."status,result_status,created,entry_user)"
			. $v;

	$result_query = query($db_con, $str_query);
	if ($result_query === false) {
		Logger::writeLog("Error while create t93_sms_getstatus_log!");
		Logger::writeLog($str_query);
		return false;
	}
	return true;
}


function getCareerMsg_V2($result){
	$message = "";
	if(isset($result["carrier"])){
		if($result["carrier"] == "1"){
			$message = getApiValue_V2($result, "docomoMessage");
		}
		elseif($result["carrier"] == "2"){
			$message = getApiValue_V2($result, "softbankMessage");
		}
		elseif($result["carrier"] == "3"){
			$message = getApiValue_V2($result, "auMessage");
		}
		else{
			$message = getApiValue_V2($result, "optionMessage");
		}

	}
	return $message;
}

function getApiValue_V2($result, $access_key){
	if(isset($result[$access_key])){
		return $result[$access_key];
	}
	return "";
}



/** Update carrier table t501_sms_tel_histories
 * @param resource $db_con
 * @param int $schedule_id
 * @param string $tel_column
 * @param string $tel_no
 * @param int $carrier_id
 * @return boolean
 */
function update_carrier_V2($db_con, $schedule_id, $tel_column, $tel_no, $carrier_id) {
	if ($carrier_id == 1) {
		$carrier = "docomo";
	} elseif ($carrier_id == 2) {
		$carrier = "softbank";
	} elseif ($carrier_id == 3) {
		$carrier = "au";
	} else {
		$carrier = "その他";
	}
	$str_query = "UPDATE t501_sms_tel_histories" 
		. " SET carrier='$carrier', modified=NOW(), update_program='sms_api'" 
		. " WHERE schedule_id=$schedule_id"
		. " AND $tel_column='$tel_no'";
	$result_query = query($db_con, $str_query);
	if ($result_query === false) {
		Logger::writeLog("Error while update carrier of t501_sms_tel_histories!");
		return false;
	}
	return true;
}




/** Get list time send sms of schedule
 * @param resource $db_con
 * @param int $schedule_id
 * @return boolean|array time send sms
 */
function getAllTimeSendSms($db_con, $schedule_id) {
	$str_query = "SELECT time_start, time_end FROM t201_sms_send_times"
		. " WHERE schedule_id=$schedule_id"
		. " AND del_flag = 'N'"
		. " ORDER BY time_start ASC";
	$result_query = query($db_con, $str_query);
	if ($result_query === false) {
		Logger::writeLog("Error while query get list time send sms of schedule!");
		return false;
	}
	$row = getRows($result_query, array('time_start', 'time_end'));
	return $row;
}

/** Check have next schedule
 * @param resource $db_con
 * @param int $schedule_id
 * @return boolean
 */
function check_has_next_schedule($db_con, $schedule_id) {
	$str_query = "SELECT COUNT(*) as total_schedule FROM t201_sms_send_times  WHERE schedule_id=$schedule_id AND del_flag = 'N' and time_start > NOW();";
	$result_query = query($db_con, $str_query);
	if ($result_query === false) {
		Logger::writeLog("Error while query count total_schedule from t201!");
		return false;
	}
	$row = getRows($result_query, array("total_schedule"));
	$total_schedule = $row[0]["total_schedule"];
	if($total_schedule > 0)
		return true;
	else 
		return false;
}
?>