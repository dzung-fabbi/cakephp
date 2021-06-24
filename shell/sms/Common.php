<?php
	define('STATUS_NO_SEND', 0);
	define('STATUS_SENDING', 1);
	define('STATUS_STOP_SEND', 2);
	define('STATUS_TEMP_FINISH', 3);
	define('STATUS_FINISH', 4);
	define('STATUS_STOPING', 5);
	define('STATUS_FINISHING', 6);

	define('SMS_API_V2_VALUE', 2);

	/** Convert sms schedule status to String
	 * @param int $status sms schedule status
	 * @return string is status of sms schedule or empty string if is invalid $status
	 */
	function statusToString($status){
		if(!isset($status)) return "";
		$arr = array(
			STATUS_NO_SEND =>	"STATUS_NO_SEND",
			STATUS_SENDING =>	"STATUS_SENDING",
			STATUS_STOP_SEND =>	"STATUS_STOP_SEND",
			STATUS_TEMP_FINISH =>	"STATUS_TEMP_FINISH",
			STATUS_FINISH =>	"STATUS_FINISH",
			STATUS_FINISHING =>	"STATUS_FINISHING"
		);
		if (isset($arr[$status]))
			return $arr[$status];
		else return "";
	}
	/** Get warning message from result status. Reference document: 空電プッシュAPI仕様書2.2.1版.pdf P37
	 * @param string $carrier provider of carrier
	 * @param string $send_result is sms sent result
	 * @param string $result_status is result status code
	 * @param string $command_status is command status code
	 * @param string $network_error_code is network error code
	 * @return string is warning message
	 */
	function getWarningMsg($carrier, $send_result, $result_status, $command_status, $network_error_code){
		$warning_msg["1"] = array(
				"00" => "",
				"21" => "圏外（docomo）",
				"22" => "携帯キャリア側障害（docomo）",
				"20" => "空電側障害（docomo）",
				"23" => "携帯電話端末障害 、SMS拒否設定、携帯キャリア違い等（docomo）"
		);
		$warning_msg["2"] = array(
				"DELIVRD" => "",
				"EXPIRED" => "圏外（softbank）",
				"DELETED" => "携帯キャリア側障害（softbank）",
				"UNDELIV" => "携帯キャリア側障害（softbank）",
				"REJECTD" => "携帯電話端末障害 、SMS拒否設定等（softbank）"
		);
		$warning_msg["3"] = array(
				"0x00000000_0xFFFFFF" => "",
				"0x000000FE_0x020124" => "圏外（au）",
				"0x0000000B_0xFFFFFF" => "携帯キャリア違い等（au）",
				"0x000000FE_0x020001" => "SMS（Cメール）配信拒否（au）",
				"0x000000FE_0x020002" => "SMS（Cメール）配信拒否（au）"
		);
		$msg = "不明";
		if(isset($carrier)){
			if($carrier == "1"){
				if (isset($warning_msg["1"][$result_status]))
					$msg = $warning_msg["1"][$result_status];
			}else if($carrier == "2"){
				if (isset($warning_msg["2"][$result_status]))
					$msg = $warning_msg["2"][$result_status];
			}else if($carrier == "3"){
				if(isset($send_result)){
					if($send_result == "その他"){
						if (isset($warning_msg["3"][$command_status."_".$network_error_code])){
							$msg = $warning_msg["3"][$command_status."_".$network_error_code];
						}else{
							$msg = "その他障害（au）";
						}
					}else{
						if (isset($warning_msg["3"][$command_status."_".$network_error_code])){
							$msg = $warning_msg["3"][$command_status."_".$network_error_code];
						}
					}
				}
			}
		}
		return $msg;
	}
?>
