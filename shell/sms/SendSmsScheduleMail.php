<?php
require('SendMail.php');


/** Send mail when create SmsSchedule
 * @param string $subject
 * @param string $companyName
 * @param int $scheduleId
 * @param string $scheduleName
 * @param string $listName
 * @param int $listTotal
 * @param datetime $sendTime
 * @param datetime $endTime
 * @param int $serviceId
 * @return boolean
 */

/** Send mail when SmsSchedule error
 * @param string $companyName
 * @param int $scheduleId
 * @param string $scheduleName
 * @param string $listName
 * @param int $listTotal
 * @param datetime $sendTime
 * @param datetime $endTime
 * @param int $serviceId
 * @param string $filePath
 * @return boolean
 */
function sendErrorSmsScheduleMail($companyName, $scheduleId, $scheduleName, $template_id, $template_name, $listName, $listTotal, $strSendTime, $serviceId, $display_number, $filePath){
	$config = parse_ini_file('config.ini', true);
	if ($config['stop_send_mail'] != '0') {
		return true;
	}
	
	$configSender = $config['sendMail'];

	$mail = new SendMail();
	$mail->config($configSender);
	$subject = '【はやぶさ】SMS送信エラー';
	$content = "お疲れ様です。<br/><br/>"
		. "詳細情報は下記になります。<br/>"
		."・会社名		: $companyName<br/>"
		. "・スケジュールNO	: $scheduleId<br/>"
		. "・スケジュール名	: $scheduleName<br/>"
		. "・サービスID		: $serviceId<br/>"
		. "・通知番号		: $display_number<br/>"
		. "・テンプレート名	: $template_name<br/>"
		. "・リスト名		: $listName<br/>"
		. "・リスト件数		: $listTotal<br/>"
		. "・送信時間		: $strSendTime<br/><br/>"
		. "エラーの内容を添付ファイルになります。<br/><br/>"
		. "以上、宜しくお願いします。";
	if ($config['env'] != 'HONBAN') {
		$subject = $subject. "(開発環境)";
	}
	return $mail->sendTo($content, $subject, $filePath, true);
}

function sendError(){
	$config = parse_ini_file('config.ini', true);
	if ($config['stop_send_mail'] != '0') {
		return true;
	}
	$configSender = $config['sendMail'];
	$subject = "【はやぶさ】SMS送信バッチ障害";
	$filePath = $config['system']['sms_batch_path'].'log/sms_log_' . date("Ymd").".log";
	$mail = new SendMail();
	$mail->config($configSender);	
	$content = "お疲れ様です。<br/><br/>"
			."バッチ実行中に障害が発生しました。<br/>"
			. "エラーの内容を添付ファイルになります。<br/><br/>"
			. "以上、宜しくお願いします。";
	if ($config['env'] != 'HONBAN') {
		$subject = $subject. "(開発環境)";
	}
	return $mail->sendTo($content, $subject, $filePath, true);
}