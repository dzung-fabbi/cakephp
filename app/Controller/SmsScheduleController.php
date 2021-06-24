<?php
App::uses('AppController', 'Controller');

class SmsScheduleController extends AppController {
	var $uses = array(
		'M01Server', 'M02Company', 'M04ControllerAction', 'M90PulldownCode', 'M99SystemParameter', 'T92Lock',
		'T200SmsSendSchedule', 'T201SmsSendTime', 'T202SmsSendLog', 'T800SmsSendResult',
		'T100SmsSendList', 'T101SmsTelList', 'T102SmsListItem', 'T501SmsTelHistory', 'M08SmsApiInfo', 'T300SmsTemplate'
	);
	const ITEM_REGEX = '/{.*?}/';
	const LEFT_BRACE_REGEX = '/{/';
	const RIGHT_BRACE_REGEX = '/}/';

	function index($mode = null, $del_count=null) {
		$this->ESession->setDataCreateSchedule(null, $this);

		if($mode == "delete"){
			$sortColumn = $this->ESession->getSortColumn($this);
			$sortType = $this->ESession->getSortType($this);
			$page = $this->ESession->getPage($this);
			$this->set("sortColumn", $sortColumn);
			$this->set("sortType", $sortType);
			$this->set("page", $page);
			$this->set('del_count', $del_count);
		}

		$schedule_time_reload = $this->M90PulldownCode->getSelectOption('schedule_time_reload');

		$this->set('mode', $mode);
		$this->set('schedule_time_reload', $schedule_time_reload);
		$this->set('time_reload', $this->ESession->getTimeReloadSms($this));

		$post_code = $this->ESession->getUserPostCode($this);

        $create_flag = $this->M04ControllerAction->check_permission($post_code, 'SmsSchedule', 'create');
        $delete_flag = $this->M04ControllerAction->check_permission($post_code, 'SmsSchedule', 'delete');
        $download_flag = $this->M04ControllerAction->check_permission($post_code, 'SmsSchedule', 'download');

		$min_distance_send_time = $this->M99SystemParameter->getByFunctionIdAndParameterId('SMS_SCHEDULE', 'MIN_TIME_SEND');
		if (sizeof($min_distance_send_time) > 0) {
			$min_distance_send_time = $min_distance_send_time['M99SystemParameter']['parameter_value'];
		} else {
			$min_distance_send_time = 0;
		}
		$this->set('min_distance_send_time', $min_distance_send_time);

        $this->set('create_flag', $create_flag);
        $this->set('delete_flag', $delete_flag);
        $this->set('download_flag', $download_flag);

		$status_infos = $this->get_status_info();
		unset($status_infos[STATUS_NO_SEND]);
		unset($status_infos[STATUS_FINISHING]);
		$this->set('status_infos', $status_infos);
	}

	// 20160511 Add by Giang - #7108 - create and edit sms_schedule - Begin
	function create() {
		if (!empty($this->data)) {
			$this->layout = false;
			$this->view = 'ajax_form_create';

			$edit_flag = 0;
			$disable_input_flag = 0;
			$call_right_away_flag = 1;
			$msg_edit = '';

			if (isset($this->data['id']) && $this->data['id']) {
				$data_schedule = $this->T200SmsSendSchedule->getScheduleById($this->data["id"]);

				if (isset($this->data['action']) && $this->data['action'] == 'edit') {
					$edit_flag = 1;

					$status = $data_schedule['T200SmsSendSchedule']['status'];
					$post_code = $this->ESession->getUserPostCode($this);
					$edit_permission = $this->M04ControllerAction->check_permission($post_code, 'SmsSchedule', 'edit');
					$call_right_away_permission = $this->M04ControllerAction->check_permission($post_code, 'SmsSchedule', 'resend');

					if ($edit_permission) {
						if ($status != STATUS_NO_SEND) {
							$disable_input_flag = 1;
							$msg_edit = SCHEDULE_ERROR_EDIT_1 . $this->get_status_info($status, 'text') . SCHEDULE_ERROR_EDIT_2;
						}
					} else {
						$disable_input_flag = 1;
					}

					if (!$call_right_away_permission || ($status != STATUS_NO_SEND)) {
						$call_right_away_flag = 0;
					}
				}

				$data_out_times = $this->T201SmsSendTime->getByScheduleId($data_schedule['T200SmsSendSchedule']['id']);
				if (isset($data_out_times[0])) {
					$data_schedule["T200SmsSendSchedule"]["create_date"] = $data_out_times[0]["T201SmsSendTime"]["time_start"];
				}

				$arr_call_times = array();
				foreach ($data_out_times as $key => $data_out_time) {
					$arr_call_times[] = array(
						'start_date' => $data_out_time['T201SmsSendTime']['time_start'],
						'end_date' => $data_out_time['T201SmsSendTime']['time_end'],
						'section_id' => 1,
						'text' => 'call_times_' . $key
					);
				}
				$data_schedule['T200SmsSendSchedule']['call_times'] = json_encode($arr_call_times);

				$this->set('id', $this->data["id"]);
				$this->set('data', $data_schedule);
			}

			$outgoing_time = $this->M90PulldownCode->getSelectOption('outgoing_time');
			$this->set('outgoing_time', $outgoing_time);

			$this->set('disable_input_flag', $disable_input_flag);
			$this->set('call_right_away_flag', $call_right_away_flag);
			$this->set('msg_edit', $msg_edit);
			$this->set('edit_flag', $edit_flag);

			$display_number = $this->M08SmsApiInfo->getServiceIdByCompanyId($this->ESession->getUserCompanyId($this));

			$this->set('display_number', $display_number);

			$company_id = $this->ESession->getUserCompanyId($this);
			$templates = $this->T300SmsTemplate->getListByCompanyId($company_id);
			$this->set('templates', $templates);

			$lists = $this->T100SmsSendList->getListByCompanyId($company_id);
			$this->set('lists', $lists);
			
			//$checkFlag = $this->M02Company->getAcceptConsentFlag($company_id);
			//if(isset($checkFlag[0])){
				//$accept_consent_flag = $checkFlag[0]["M02Company"]["accept_consent_flag"];
			//}
			$accept_consent_flag = $this->M02Company->getAcceptConsentFlag($company_id);
			$this->set('accept_consent_flag', $accept_consent_flag);
			$this->set('cID', $company_id);
		}
	}

	function check_exist_template($data){
		$arr_template_info = $this->T300SmsTemplate->getSmsTemplateById($data['template_id']);
		if (count($arr_template_info) < 1) {
			return false;
		}
		return true;
	}
	function check_exist_item($data) {
		$template_info = $this->T300SmsTemplate->getSmsTemplateById($data['template_id']);
		if(!empty($template_info)){
			$content = $template_info["T300SmsTemplate"]["content"];
			preg_match_all($this::ITEM_REGEX, $content, $items);
			if(!empty($items[0])){
				$list_id = $data['list_id'];
				$list_items = $this->T102SmsListItem->getTitleByListId($list_id);
				$list_columns = array();
				foreach ($list_items as $list_item) {
					$list_columns[$list_item['T102SmsListItem']['item_name']] = $list_item['T102SmsListItem']['column'];
				}
				foreach ($items[0] as $item) {
					$item_name = preg_replace($this::LEFT_BRACE_REGEX, "",preg_replace($this::RIGHT_BRACE_REGEX, "", $item,1),1);
					if (!isset($list_columns[$item_name])) {
						return false;
					}
				}
			}
		}
		return true;
	}

	function check_sms_content($data){
		$template_info = $this->T300SmsTemplate->getSmsTemplateById($data['template_id']);
		if(!empty($template_info)){
			// SMS本文
			$content = $template_info["T300SmsTemplate"]["content"];
			$sms_use_short_url = $template_info["T300SmsTemplate"]["sms_use_short_url"];
			$M08SmsApiInfo = $this->M08SmsApiInfo->getApiInfoByDisplayNumber($data["display_number"]);
			$api_id = $M08SmsApiInfo['M08SmsApiInfo']['api_id'];
			$sms_short_url_allow_flag = $M08SmsApiInfo['M08SmsApiInfo']['sms_short_url_allow_flag'];
			$arr_items = array();

			// SMS一括送信特別（テンプレート作成で表示電話番号が無いため、ここで判断する。）
			if ($sms_use_short_url && $api_id != SMS_API_V2_VALUE) {
				return "err_sms_illegal_use_short_url";
			}

			if ($sms_use_short_url && $sms_short_url_allow_flag != SMS_SHORT_URL_ALLOW_FLAG) {
				return "err_sms_invalid_use_short_url";
			}

			// SMS本文より挿入項目を取得※$itemsに入れる。
			preg_match_all($this::ITEM_REGEX, $content, $items);


			//挿入項目あり　または　APIV2を使うなら文字数の再確認が必要
			// 短縮URL有効・無効は$api_id == SMS_API_V2_VALUEの時にOnになる。（画面で制御）
			if(!empty($items[0]) || $api_id == SMS_API_V2_VALUE){
				$list_id = $data['list_id'];
				$list_items = $this->T102SmsListItem->getTitleByListId($list_id);
				$list_columns = array();
				foreach ($list_items as $list_item) {
					$list_columns[$list_item['T102SmsListItem']['item_name']] = $list_item['T102SmsListItem']['column'];
				}
				foreach ($items[0] as $item) {
					$item_name = preg_replace($this::LEFT_BRACE_REGEX, "",preg_replace($this::RIGHT_BRACE_REGEX, "", $item,1),1);
					if(!in_array($item_name, $arr_items))
						array_push($arr_items, $item_name);
				}
				$telList = $this->T101SmsTelList->getAllTelByListId($list_id);

				// ダイアルリスト毎に判定。１つでもNGがあったら、SMS送信できないため即リターンする。
				foreach ($telList as $tel) {
					$tmp_sms_content = $content;
					foreach ($arr_items as $item_name) {
						$tmp_item = "{".$item_name."}";
						//挿入項目を実際値を入れ替えて長さをチェックする
						$tmp_sms_content = str_replace($tmp_item, $tel["T101SmsTelList"][$list_columns[$item_name]], $tmp_sms_content);
					}

					// API_v2の場合は、改行を2文字とカウントする
					if($api_id == SMS_API_V2_VALUE){
						$error_message = "";
						list($error_message, $tmp_sms_content) = $this->Util->checkSmsBodyValueForApiV2($sms_use_short_url, $tmp_sms_content);
						if($error_message){
							return $error_message;
						}
					}

					if(mb_strlen($tmp_sms_content) > MAX_LEN_SMS_CONTENT)
						return "err_sms_over_length";
				}
			}else{
				if(mb_strlen($content) > MAX_LEN_SMS_CONTENT)
					return "err_sms_over_length";
			}
		}
		return "";
	}

	/**
	 * 開始時間チェック処理の呼び出し
	 * @param string $schedule_id スケジュールID
	 * @param string $action 押下されたボタンの種類
	 * @return boolean true：チェックOK／false：NG
	 */
	function call_check_start_time($schedule_id, $action)
	{
		$t201SmsSendTime = $this->T201SmsSendTime->getTimeStartByScheduleId($schedule_id);
		return $this->Util->check_start_time($t201SmsSendTime[0]['time_start'], $action);
	}

	function check_exist_list($data){
		$arr_list_info = $this->T100SmsSendList->getListInfoById($data['list_id']);
		if (count($arr_list_info) < 1) {
			return false;
		}
		return true;
	}

	function check_unlock_call_list($data) {
		$user_id = $this->ESession->getUserId($this);
		$session_id = $this->Session->id();

		$info_lock = $this->T92Lock->getInfoLock('sms_send_list', $data['list_id']);
		if (count($info_lock) > 0 && ($info_lock['T92Lock']['use_user_id'] != $user_id || $info_lock['T92Lock']['session_id'] != $session_id)){
			return false;
		}
		return true;
	}

	function check_unlock_template($data) {
		$user_id = $this->ESession->getUserId($this);
		$session_id = $this->Session->id();

		$info_lock = $this->T92Lock->getInfoLock('sms_template_list', $data['template_id']);
		if (count($info_lock) > 0 && ($info_lock['T92Lock']['use_user_id'] != $user_id || $info_lock['T92Lock']['session_id'] != $session_id)){
			return false;
		}
		return true;
	}

	function check_list_and_template_by_time_data($data) {
		$sms_schedule = $this->T200SmsSendSchedule->getCountSmsScheduleByTimeStart($data['schedule_id'], $data['create_date'], $data['template_id'], $data['list_id']);
		if (!empty($sms_schedule)) {
			return false;
		}
		return true;
	}

	function check_display_number_by_time_data($data) {
		foreach ($data['list_call_times'] as $time) {
			$start_date = $data['create_date'] . ' ' . $time['start_date'] . ':00';
			$end_date = $data['create_date'] . ' ' . $time['end_date'] . ':00';
			$sms_schedule = $this->T200SmsSendSchedule->getSmsScheduleByDisplayNumber($data['schedule_id'], $start_date, $end_date, $data['display_number']);
			if (!empty($sms_schedule)) {
				return $sms_schedule;
			}
		}
		return 'true';
	}

	function check_display_number_by_time_data_resend($data) {
		$schedule = $this->T200SmsSendSchedule->getDisplayNumberById($data['schedule_id']);
		$display_number = $schedule['T200SmsSendSchedule']['display_number'];
		foreach ($data['list_send_times'] as $time) {
			$sms_schedule = $this->T200SmsSendSchedule->getSmsScheduleByDisplayNumber($data['schedule_id'], $time['start_date'], $time['end_date'], $display_number);
			if (!empty($sms_schedule)) {
				return $sms_schedule;
			}
		}
		return 'true';
	}

	function check_run_schedule($data){
		$arr_schedule_info = $this->T200SmsSendSchedule->getScheduleById($data['schedule_id']);
		$status = $arr_schedule_info["T200SmsSendSchedule"]["status"];
		if ($status == STATUS_SENDING && $data["action"] == "update") {//実行中
			return false;
		}
		return true;
	}

	function check_exist_schedule_name() {
		$data = $this->data;
		$schedule_name = $data['schedule_name'];
		$company_id = $this->ESession->getUserCompanyId($this);

		$info_schedule = $this->T200SmsSendSchedule->getByScheduleName($company_id, $schedule_name);
		if (isset($info_schedule["T200SmsSendSchedule"]["id"]) && !empty($info_schedule["T200SmsSendSchedule"]["id"])) {
			if (!isset($data['schedule_id'])
				|| empty($data['schedule_id'])
				|| (!empty($data['schedule_id']) && $data['schedule_id'] != $info_schedule["T200SmsSendSchedule"]["id"])) {
				echo "false";
				exit;
			}
		}
		echo "true";
		exit;
	}

	function check_info_schedule(){
		$data = $this->data;
		$result = Array();
		if(isset($data['schedule_id']) && !empty($data['schedule_id'])){
			$arr_schedule_info = $this->T200SmsSendSchedule->getScheduleById($data['schedule_id']);
			if (count($arr_schedule_info) < 1) {
				$result['result'] = 'err_exist_schedule';
				echo json_encode($result);
				exit;
			}
		}

		if(!$this->check_exist_template($data)){
			$result['result'] = 'err_exist_template';
			echo json_encode($result);
			exit;
		}
		if(!$this->check_exist_list($data)){
			$result['result'] = 'err_exist_list';
			echo json_encode($result);
			exit;
		}
		if(!$this->check_unlock_call_list($data)){
			$result['result'] = 'err_lock_call_list';
			echo json_encode($result);
			exit;
		}
		if(!$this->check_unlock_template($data)){
			$result['result'] = 'err_lock_template';
			echo json_encode($result);
			exit;
		}
		if ($data['action'] == 'update' && !$this->call_check_start_time($data['schedule_id'], $data['action'])) {
			$result = array(
				'result' => 'error_start_time'
			);
			echo json_encode($result);
			exit;
		}
		if(!$this->check_exist_item($data)){
			$result['result'] = 'err_not_exit_item';
			echo json_encode($result);
			exit;
		}
		$check_message = $this->check_sms_content($data);
		if($check_message) {
			$result = array(
				"result" => $check_message,
			);
			echo json_encode($result);
			exit;
		}
		$check_display_number = $this->check_display_number_by_time_data($data);
		if ($check_display_number != 'true') {
			$result['result'] = 'err_service_id_used';
			$result['time_start'] = $check_display_number['T201SmsSendTime']['time_start'];
			$result['time_end'] = $check_display_number['T201SmsSendTime']['time_end'];
			echo json_encode($result);
			exit;
		}

		//check over_schedule
		$arr_limit_schedule = $this->M99SystemParameter->getByFunctionIdAndParameterId('SMS_SCHEDULE', 'MAX_SCHEDULE');
		$limit_schedule = $arr_limit_schedule['M99SystemParameter']['parameter_value'];

		foreach ($data['list_call_times'] as $key => $list_call_time) {
			$data_call_time = array(
				'schedule_id' => $data['schedule_id'],
				'start_time' => $data['create_date'] . ' ' . $list_call_time['start_date'] . ':00',
				'end_time' => $data['create_date'] . ' ' . $list_call_time['end_date'] . ':00',
				'action' => $data['action']
			);

			if (!$this->check_over_schedule($data_call_time, $limit_schedule)){
				$result = array(
					"result" => "err_over_schedule",
					"limit_schedule" => $limit_schedule
				);
				echo json_encode($result);
				exit;
			}
		};

		if (isset($data['schedule_id']) && !empty($data['schedule_id'])){
			if ($data['action'] == "update") {
				if (!$this->check_run_schedule($data)) {
					$result = array(
						"result" => "err_update_run",
					);
					echo json_encode($result);
					exit;
				}
			}

			if ($data['action'] == 'call') {
				$arr_schedule_info = $this->T200SmsSendSchedule->getScheduleById($data['schedule_id']);
				$status = $arr_schedule_info['T200SmsSendSchedule']['status'];

				if ($status != STATUS_NO_SEND) {
					$result = array(
						'result' => 'error_status',
						'msg' => SMS_SCHEDULE_ERROR_CALL_RIGHT_AWAY1 . $this->get_status_info($status, 'text') . SMS_SCHEDULE_ERROR_CALL_RIGHT_AWAY2
					);
					echo json_encode($result);
					exit;
				}
			}

			if ($data['action'] == "call" || $data['action'] == "update") {
				if(!$this->check_unlock_schedule($data['schedule_id'])){
					$result = array(
						"result" => "err_editing",
					);
					echo json_encode($result);
					exit;
				}
			}
		}
		
		// #8298 add consentday
		if($data['consent_flag']=='true'){
			if(!$this->consentday_check($data['list_id'])){
				$result = array(
						"result" => "err_consentday",
				);
				echo json_encode($result);
				exit;
			}
		}

		if (!$this->check_list_and_template_by_time_data($data)) {
			$result['result'] = 'err_list_and_template_used';
			echo json_encode($result);
			exit;
		}


		echo "true";
		exit;
	}
	// 20160511 Add by Giang - #7108 - create and edit sms_schedule - End

	/**
	 * 「即時送信」ボタン押下時チェック処理
	 * チェック実行後、呼び出し元へ結果を返却する。
	 */
	function check_popup()
	{
		$data = $this->data;
		if ($data['edit_mode'] == "update" && !$this->call_check_start_time($data['schedule_id'], $data['action'])) {
			$result = array(
				'result' => 'error_start_time'
			);
			echo json_encode($result);
			exit;
		}

		echo "true";
		exit;
	}

	function delete() {
		$data = $this->data;
		if (empty($data)) {
			$this->redirect(array('controller' => 'SmsSchedule', 'action' => 'index'));
		}

		$dsT200SmsSendSchedule = $this->T200SmsSendSchedule->getDataSource();
		$dsT201SmsSendTime = $this->T201SmsSendTime->getDataSource();
		$dsT200SmsSendSchedule->begin($this);
		$dsT201SmsSendTime->begin($this);

		$schedule_ids = $data['schedule_ids'];
		$update_user = $this->ESession->getUserId($this);
		$update_program = $this->name.'_'.__FUNCTION__;
		$time = date('Y-m-d H:i:s a', time());

		foreach ($schedule_ids as $id) {
			$arr_schedule_info = $this->T200SmsSendSchedule->getScheduleById($id);

			$arr_schedule_info['T200SmsSendSchedule']['del_flag'] = "Y";
			$arr_schedule_info["T200SmsSendSchedule"]["update_user"] = $update_user;
			$arr_schedule_info["T200SmsSendSchedule"]["update_program"] = $update_program;
			$arr_schedule_info["T200SmsSendSchedule"]["modified"] = $time;

			if (!$this->T200SmsSendSchedule->save($arr_schedule_info)) {
				$dsT200SmsSendSchedule->rollback($this);
				$dsT201SmsSendTime->rollback($this);
				$this->log("スケジュール削除：失敗");
				$this->redirect(array('controller' => 'Login', 'action' => 'index/systemerror'));
			}

			$schedule_id = $arr_schedule_info["T200SmsSendSchedule"]["id"];
			$query = "UPDATE t201_sms_send_times SET del_flag='Y', update_user='"
				. $update_user . "',update_program='" . $update_program
				. "', modified='" . $time . "' WHERE del_flag = 'N' AND schedule_id='" . $schedule_id . "';";

			if ($this->T201SmsSendTime->query($query)) {
				$dsT200SmsSendSchedule->rollback($this);
				$dsT201SmsSendTime->rollback($this);
				$this->log("スケジュール削除：失敗");
				$this->redirect(array('controller' => 'Login', 'action' => 'index/systemerror'));
			}
		}

		$dsT200SmsSendSchedule->commit($this);
		$dsT201SmsSendTime->commit($this);
		$this->redirect(array('controller' => 'SmsSchedule', 'action' => 'index/delete/' . count($schedule_ids)));
	}
	function status() {
		$data = $this->data;
		if (!empty($data)) {
			if (isset($this->data['request_type']) && $this->data['request_type'] == 'ajax') {
				$this->layout = "ajax";
			}

			$schedule_id = $data['schedule_id'];
			$schedule = $this->T200SmsSendSchedule->getHistoryInfoById($schedule_id);
			//get tel_column from t102
			$list_item = $this->T102SmsListItem->getTelNumColumn($schedule["T500SmsListHistory"]["list_id"]);
			$tel_column = isset($list_item['T102SmsListItem']['column']) ? $list_item['T102SmsListItem']['column'] : NULL;

			$status = $schedule['T200SmsSendSchedule']['status'];
			$show_btn = $status == STATUS_FINISH ? true : false;
			$show_btn_stop = $status == STATUS_SENDING ? true : false;
			$show_btn_stoping = $status == STATUS_STOPING ? true : false;
			$show_btn_resend = $this->check_status_can_resend($status) ? true : false;
			$show_reload = ($status == STATUS_SENDING || $status == STATUS_STOPING) ? true : false;
			$show_btn_finish = ($status == STATUS_STOP_SEND) || ($status == STATUS_TEMP_FINISH) || ($status == STATUS_STOPING) || ($status == STATUS_FINISHING) ? true : false;
			$show_btn_send_now = $this->check_status_can_send_now($status) ? true : false;


			$post_code = $this->ESession->getUserPostCode($this);
			$stop_flag = $this->M04ControllerAction->check_permission($post_code, 'StatusSmsSchedule', 'stop_send');
			$resend_flag = $this->M04ControllerAction->check_permission($post_code, 'StatusSmsSchedule', 'resend');
			$download_flag = $this->M04ControllerAction->check_permission($post_code, 'StatusSmsSchedule', 'download');
			$finish_flag = $this->M04ControllerAction->check_permission($post_code, 'StatusSmsSchedule', 'finish');
			$send_now_flag = $this->M04ControllerAction->check_permission($post_code, 'StatusSmsSchedule', 'resend');


			$statistic = $this->T800SmsSendResult->getStatisticByScheduleId($schedule_id);
			$tel_total = $schedule['T500SmsListHistory']['muko_tel_total'];
			$num_send = $statistic[0]['num_send'];
			$num_send_success = $statistic[0]['num_send_success'];
			$num_send_not_success = $statistic[0]['num_send_not_success'];
			$num_send_unknown = $statistic[0]['num_send_unknown'];
			$num_send_fail = $statistic[0]['num_send_fail'];
			$num_send_outside = $statistic[0]['num_send_outside'];
			$num_send_history_judgement_ng = $statistic[0]['num_send_history_judgement_ng']; // #8298 add consentday

			$num_send_dcm = 0;
			$num_send_au = 0;
			$num_send_sb = 0;
			$num_send_other = 0;

			if (isset($tel_column)) {
				$statistic_by_carrier = $this->T800SmsSendResult->getStatisticGroupByCarrier($schedule_id, $tel_column);
				foreach ($statistic_by_carrier as $statistic) {
					if ($statistic['T501SmsTelHistory']['carrier'] == 'docomo') {
						$num_send_dcm = $statistic[0]['count_by_carrier'];
					} else if ($statistic['T501SmsTelHistory']['carrier'] == 'au') {
						$num_send_au = $statistic[0]['count_by_carrier'];
					} else if ($statistic['T501SmsTelHistory']['carrier'] == 'softbank') {
						$num_send_sb = $statistic[0]['count_by_carrier'];
					} else if ($statistic['T501SmsTelHistory']['carrier'] == 'その他') {
						$num_send_other = $statistic[0]['count_by_carrier'];
					}
				}
				//echo '<pre>'; var_dump($statistic_by_carrier); die();
			}


			$schedule_time_reload = $this->M90PulldownCode->getSelectOption('schedule_time_reload');
			$send_times = $this->T201SmsSendTime->getByScheduleId($schedule_id);
			$time_end_expect = 0;
			if ($schedule['T200SmsSendSchedule']['status'] == STATUS_SENDING) {
				$log_send_times = $this->T202SmsSendLog->getByScheduleId($schedule_id);

				$seconds = 0;
				foreach ($log_send_times as $log_send_time) {
					if (strtotime($log_send_time['T202SmsSendLog']['time_end'])) {
						$seconds += strtotime($log_send_time['T202SmsSendLog']['time_end']) - strtotime($log_send_time['T202SmsSendLog']['time_start']);
					} else {
						$seconds += time() - strtotime($log_send_time['T202SmsSendLog']['time_start']);
					}
				}

				$minute = $seconds / 60;

				if ($num_send != 0 && $minute != 0) {
					$time_end_expect = date('Y-m-d H:i:s', time() + ceil(($tel_total - $num_send) / ($num_send / $minute)) * 60);
				}

				$data_send_times = $this->T201SmsSendTime->getAllNextSendTimeByScheduleId($data['schedule_id']);
				foreach ($data_send_times as $key => $data_send_time) {
					if ($time_end_expect > $data_send_time['T201SmsSendTime']['time_end'] && isset($data_send_times[$key + 1])) {
						$time_end_expect = date('Y-m-d H:i:s', strtotime($time_end_expect) + strtotime($data_send_times[$key + 1]['T201SmsSendTime']['time_start']) - strtotime($data_send_time['T201SmsSendTime']['time_end']));
					}
				}
			}

			$min_distance_send_time = $this->M99SystemParameter->getByFunctionIdAndParameterId('SMS_SCHEDULE', 'MIN_TIME_SEND');
			if (!empty($min_distance_send_time)) {
				$min_distance_send_time = $min_distance_send_time['M99SystemParameter']['parameter_value'];
			} else {
				$min_distance_send_time = 0;
			}


			$this->set("show_btn", $show_btn);
			$this->set("show_btn_stop", $show_btn_stop);
			$this->set("show_btn_stoping", $show_btn_stoping);
			$this->set("show_btn_resend", $show_btn_resend);
			$this->set("show_reload", $show_reload);
			$this->set("show_btn_finish", $show_btn_finish);
			$this->set("show_btn_send_now", $show_btn_send_now);


			$this->set('stop_flag', $stop_flag);
			$this->set('resend_flag', $resend_flag);
			$this->set('download_flag', $download_flag);
			$this->set('finish_flag', $finish_flag);
			$this->set('send_now_flag', $send_now_flag);


			$this->set('schedule_time_reload', $schedule_time_reload);
			$this->set('time_reload', $this->ESession->getTimeReloadSmsStatus($this));
			$this->set('schedule', $schedule);
			$this->set("send_times", $send_times);
			$this->set("time_end_expect", $time_end_expect);
			$this->set('min_distance_send_time', $min_distance_send_time);

			$this->set('tel_total', $tel_total);
			$this->set('num_send', $num_send);
			$this->set('num_send_success', $num_send_success);
			$this->set('num_send_not_success', $num_send_not_success);
			$this->set('num_send_unknown', $num_send_unknown);
			$this->set('num_send_fail', $num_send_fail);
			$this->set('num_send_outside', $num_send_outside);
			$this->set('num_send_dcm', $num_send_dcm);
			$this->set('num_send_au', $num_send_au);
			$this->set('num_send_sb', $num_send_sb);
			$this->set('num_send_other', $num_send_other);
			$this->set('num_send_history_judgement_ng', $num_send_history_judgement_ng); // #8298 add consentday

			if ($show_btn_finish) {
				$btn_finish_name = '終了';
				$msg_confirm_finish = SCHEDULE_CONFIRM_FINISH_2;

				$this->set('btn_finish_name', $btn_finish_name);
				$this->set('msg_confirm_finish', $msg_confirm_finish);
			}

			if($status == STATUS_FINISH || $status == STATUS_TEMP_FINISH || $status == STATUS_NO_SEND){
				$info_logs = $this->T202SmsSendLog->getTimeEndByScheduleId($schedule_id);
				$time_end = $info_logs["T202SmsSendLog"]["time_end"];
				$this->set("time_end", $time_end);
				$this->set("show_time_end", true);
			}
		} else {
			$this->redirect(array('controller' => 'SmsSchedule', 'action' => 'index'));
		}
	}
	function download_schedule() {
		$schedule_data = $this->ESession->getSmsScheduleDataDownload($this);
		if(!isset($schedule_data)){
			$this->redirect(array('controller' => 'SmsSchedule', 'action' => 'index'));
		}

		if ($schedule_data['download_multi']) {
			$file_out_name = date('YmdHis', time()) . '_' . $schedule_data['action_name'] . '.zip';
			$file_out_name = mb_convert_encoding($file_out_name, "SJIS-win", "UTF-8");
			$this->Csv->createZip($file_out_name);
		}

		foreach ($schedule_data['schedule_data'] as $schedule_id => $data) {

			$schedule = $this->T200SmsSendSchedule->getScheduleById($schedule_id);
			if (!empty($schedule)) {
				$schedule_info = $this->T200SmsSendSchedule->getHistoryInfoById($schedule_id);

				foreach ($data as $row) {
					$this->Csv->addRow($row);
				}

				$systemTitle = date('YmdHis', time()) . '_' . $schedule_data['action_name'] . '_' . $schedule_info["T200SmsSendSchedule"]["schedule_name"] . '.csv';
				$title = mb_convert_encoding($systemTitle, "SJIS-win", "UTF-8");

				if ($schedule_data['download_multi']) {
					$this->Csv->addToZip($title, 'SJIS-win');
					$this->Csv->clear();
				} else {
					echo $this->Csv->render($title,'SJIS-win');
					$this->Session->delete('sms_schedule_data_download');
					exit;
				}
			}
		}
		echo $this->Csv->renderZip('SJIS-win');
		$this->Session->delete('sms_schedule_data_download');
		exit;
	}
	function stop_send(){
		$this->layout = "ajax";
		$data = $this->data;
		if (!empty($data)) {
			//T92Lock登録
			$dsT92Lock = $this->T92Lock->getDataSource();
			$dsT92Lock->begin($this);
			$T92Lock = array();
			$T92Lock["lock_flag"] = 'sms_schedule';
			$T92Lock["lock_id"] = $data["schedule_id"];
			$T92Lock["use_user_id"] = $this->ESession->getUserId($this);
			$T92Lock['session_id'] = $this->Session->id();
			$T92Lock["entry_user"] = $this->ESession->getUserId($this);
			$T92Lock["entry_program"] = $this->name.'_Index_Stop_SMSSchedule';
			$T92Lock["created"] = date('Y-m-d H:i:s a', time());
			$flag = $this->T92Lock->save($T92Lock);
			if($flag){
				$dsT92Lock->commit($this);
				$t92lock_id = $this->T92Lock->getLastInsertId();
			}else{
				$dsT92Lock->rollback($this);
				$this->log("停止処理がステータス画面でDBの操作：失敗");
				echo 'err_db';
				exit;
			}

			$schedule_backup = $this->T200SmsSendSchedule->getScheduleById($data['schedule_id']);

			//ステータス更新
			$dsSchedule = $this->T200SmsSendSchedule->getDataSource();
			$dsSchedule->begin($this);
			$T200SmsSendSchedule = array();
			$T200SmsSendSchedule['id'] = $data['schedule_id'];
			$T200SmsSendSchedule['status'] = STATUS_STOPING;
			$T200SmsSendSchedule['stop_time'] = date('Y-m-d H:i:s a', time());
			$T200SmsSendSchedule['update_user'] = $this->ESession->getUserId($this);
			$T200SmsSendSchedule['update_program'] = $this->name.'_Index_Stop_SMSSchedule';
			$flag = $this->T200SmsSendSchedule->save($T200SmsSendSchedule);
			if($flag) {
				$dsSchedule->commit($this);
			}else{
				//DBに更新失敗の場合
				$dsSchedule->rollback($this);
				$this->log("停止処理がステータス画面でDBの操作：失敗");
				$batch_result = "err_db";
				echo $batch_result;
				exit;
			}
			//停止コマンド実行
			$batch_result = $this->batch_sms('stop_send', $data['schedule_id']);
			if ($batch_result != 'success') {
				//rollback
				$dsSchedule = $this->T200SmsSendSchedule->getDataSource();
				$dsSchedule->begin($this);
				$flag = $this->T200SmsSendSchedule->save($schedule_backup);
				$dsSchedule->commit($this);
			}			
			//T92Lock解除
			if (isset($t92lock_id) && !empty($t92lock_id)) {
				$T92Lock = array();
				$T92Lock["id"] = $t92lock_id;
				$T92Lock["del_flag"] = "Y";
				$T92Lock["update_user"] = $this->ESession->getUserId($this);
				$T92Lock["update_program"] = $this->name.'_Index_Stop_SMSSchedule';
				$T92Lock["modified"] = date('Y-m-d H:i:s a', time());
				$flag = $this->T92Lock->save($T92Lock);
				if ($flag) {
					$dsT92Lock->commit($this);
				} else {
					$dsT92Lock->rollback($this);
					$this->log("停止処理がステータス画面でDBの操作：失敗");
					echo 'err_db';
					exit;
				}
			}			
			echo $batch_result;
		}
		exit;
	}
	function re_send() {
		$this->layout = "ajax";
		$data = $this->data;
		if (!empty($data)) {
			$userId = $this->ESession->getUserId($this);
			if ($data['action'] == 'resend') {
				$program = $this->name . '_Index_ResendSchedule';
			} else {
				$program = $this->name . '_Index_SendNowSchedule';
			}

			//T92Lock登録
			$dsT92Lock = $this->T92Lock->getDataSource();
			$dsT92Lock->begin($this);
			$T92Lock = array();
			$T92Lock["lock_flag"] = 'sms_schedule';
			$T92Lock["lock_id"] = $data["schedule_id"];
			$T92Lock["use_user_id"] = $userId;
			$T92Lock['session_id'] = $this->Session->id();
			$T92Lock["entry_user"] = $userId;
			$T92Lock["entry_program"] = $program;
			$T92Lock["created"] = date('Y-m-d H:i:s a', time());
			$flag = $this->T92Lock->save($T92Lock);
			if ($flag) {
				$dsT92Lock->commit($this);
				$t92lock_id = $this->T92Lock->getLastInsertId();
			} else {
				$dsT92Lock->rollback($this);
				$this->log("停止処理がステータス画面でDBの操作：失敗");
				$result = array(
					"result" => "err_db",
				);
				echo json_encode($result);
				exit;
			}

			//DBでステータス更新
			$arr_schedule_info = $this->T200SmsSendSchedule->getScheduleById($data['schedule_id']);
			$data['list_id'] = $arr_schedule_info['T200SmsSendSchedule']['list_id'];

			$dsSchedule = $this->T200SmsSendSchedule->getDataSource();
			$dsSchedule->begin($this);
			$T200SmsSendSchedule = array();
			$T200SmsSendSchedule['id'] = $data['schedule_id'];
			$T200SmsSendSchedule['del_flag'] = 'Y';
			$T200SmsSendSchedule['update_user'] = $userId;
			$T200SmsSendSchedule['update_program'] = $program;
			$T200SmsSendSchedule['resend_flag'] = 'Y';
			$flag = $this->T200SmsSendSchedule->save($T200SmsSendSchedule);
			if ($flag) {
				//update T201SmsSendTime
				$dsSendTime = $this->T201SmsSendTime->getDataSource();
				$dsSendTime->begin($this);

				$query = "UPDATE t201_sms_send_times
							  SET
								del_flag='Y',
								update_user='" . $userId . "',
								update_program='" . $program. "'
							  WHERE
								schedule_id='" . $data['schedule_id'] . "' AND
								del_flag='N'
							  ";

				$send_times = $this->T201SmsSendTime->getByScheduleId($data['schedule_id']);
				$id_send_times = array();
				foreach ($send_times as $send_time) {
					$id_send_times[] = $send_time['T201SmsSendTime']['id'];
				}

				$send_time = $this->T201SmsSendTime->query($query);
				if ($send_time) {
					$dsSchedule->rollback($this);
					$dsSendTime->rollback($this);
					$this->log("再開処理がステータス画面でDBのステータス更新：失敗");
					$result = array(
						"result" => "err_db",
					);
				} else {
					$commit_flag = true;
					$T201SmsSendTimes = $data["list_send_times"];
					$t201_records = array();
					foreach ($T201SmsSendTimes as $arr) {
						$this->T201SmsSendTime->create();
						$T201SmsSendTime = array();
						$T201SmsSendTime['schedule_id'] = $data['schedule_id'];
						$T201SmsSendTime['time_start'] = $arr['start_date'];
						$T201SmsSendTime['time_end'] = $arr['end_date'];
						$T201SmsSendTime['entry_user'] = $userId;
						$T201SmsSendTime['entry_program'] =  $program;

						$t201_record = $this->T201SmsSendTime->save($T201SmsSendTime);
						if (!$t201_record) {
							$commit_flag = false;
							break;
						} else {
							$t201_records[] = $t201_record;
						}
					}
					if ($commit_flag) {
						$dsSchedule->commit($this);
						$dsSendTime->commit($this);

						$batch_result = $this->batch_sms('re_send', $data['schedule_id']);
						if ($batch_result != "success") {
							//rollback
							$dsSchedule = $this->T200SmsSendSchedule->getDataSource();
							$dsSchedule->begin($this);
							$this->T200SmsSendSchedule->save($arr_schedule_info);
							$dsSchedule->commit($this);

							$dsSendTime = $this->T201SmsSendTime->getDataSource();
							$dsSendTime->begin($this);

							$query = "UPDATE t201_sms_send_times
							  SET
								del_flag='N',
								update_user='" . $userId . "',
								update_program='" . $program. "'
							  WHERE
								id IN ('" . implode("', '", $id_send_times) .  "')
							  ";
							$send_time = $this->T201SmsSendTime->query($query);

							foreach ($t201_records as $t201_record) {
								$t201_record['T201SmsSendTime']['del_flag'] = 'Y';
								$this->T201SmsSendTime->save($t201_record);
							}
							$dsSendTime->commit($this);
						} else {
							$dsSchedule = $this->T200SmsSendSchedule->getDataSource();
							$dsSchedule->begin($this);
							$T200SmsSendSchedule = array();
							$T200SmsSendSchedule['id'] = $data['schedule_id'];
							$T200SmsSendSchedule['status'] = STATUS_SENDING;
							$T200SmsSendSchedule['update_user'] = $userId;
							$T200SmsSendSchedule['update_program'] = $program;
							$flag = $this->T200SmsSendSchedule->save($T200SmsSendSchedule);
							$dsSchedule->commit($this);
						}
						$result = array(
							"result" => $batch_result,
						);
					} else {
						//DBに更新失敗の場合
						$dsSchedule->rollback($this);
						$dsSendTime->rollback($this);
						$this->log("再開処理がステータス画面でDBのステータス更新：失敗");
						$result = array(
							"result" => "err_db",
						);
					}
				}
				//update del_flag = N
				$dsSchedule = $this->T200SmsSendSchedule->getDataSource();
				$dsSchedule->begin($this);
				$T200SmsSendSchedule = array();
				$T200SmsSendSchedule['id'] = $data['schedule_id'];
				$T200SmsSendSchedule['del_flag'] = 'N';
				$T200SmsSendSchedule['update_user'] = $userId;
				$T200SmsSendSchedule['update_program'] = $program;
				$flag = $this->T200SmsSendSchedule->save($T200SmsSendSchedule);
				$dsSchedule->commit($this);
			} else {
				//DBに更新失敗の場合
				$dsSchedule->rollback($this);
				$this->log("再開処理がステータス画面でDBのステータス更新：失敗");
				$result = array(
					"result" => "err_db",
				);
			}

			//T92Lock解除
			if (isset($t92lock_id) && !empty($t92lock_id)) {
				$T92Lock = array();
				$T92Lock["id"] = $t92lock_id;
				$T92Lock["del_flag"] = "Y";
				$T92Lock["update_user"] = $userId;
				$T92Lock["update_program"] = $program;
				$T92Lock["modified"] = date('Y-m-d H:i:s a', time());
				$dsT92Lock = $this->T92Lock->getDataSource();
				$dsT92Lock->begin($this);
				$flag = $this->T92Lock->save($T92Lock);
				if ($flag) {
					$dsT92Lock->commit($this);
				} else {
					$dsT92Lock->rollback($this);
					$this->log("再開処理がステータス画面でDBの操作：失敗");
					$result = array(
						"result" => "err_db",
					);
					echo json_encode($result);
					exit;
				}
			}
			echo json_encode($result);			
			exit;
		}
		exit;
	}
	function finish_schedule() {
		$this->layout = "ajax";
		$data = $this->data;
		if (empty($data)) {
			echo 'systemerror';
			exit;
		}

		//T92Lock登録
		$dsT92Lock = $this->T92Lock->getDataSource();
		$dsT92Lock->begin($this);
		$T92Lock = array();
		$T92Lock["lock_flag"] = 'sms_schedule';
		$T92Lock["lock_id"] = $data["schedule_id"];
		$T92Lock["use_user_id"] = $this->ESession->getUserId($this);
		$T92Lock['session_id'] = $this->Session->id();
		$T92Lock["entry_user"] = $this->ESession->getUserId($this);
		$T92Lock["entry_program"] = $this->name.'_Index_Finish_SMSSchedule';
		$flag = $this->T92Lock->save($T92Lock);
		if ($flag){
			$dsT92Lock->commit($this);
			$t92lock_id = $this->T92Lock->getLastInsertId();
		} else {
			$dsT92Lock->rollback($this);
			$this->log("停止処理がステータス画面でDBの操作：失敗");
			echo 'err_db';
			exit;
		}

		$dsSchedule = $this->T200SmsSendSchedule->getDataSource();
		$dsSchedule->begin($this);
		$T200SmsSendSchedule = array();
		$T200SmsSendSchedule['id'] = $data['schedule_id'];
		$T200SmsSendSchedule['status'] = STATUS_FINISH;
		$T200SmsSendSchedule['update_user'] = $this->ESession->getUserId($this);
		$T200SmsSendSchedule['update_program'] = $this->name.'_Index_Finish_SMSSchedule';
		$schedule = $this->T200SmsSendSchedule->save($T200SmsSendSchedule);
		if ($schedule) {
			$dsSchedule->commit($this);
		} else {
			//DBに更新失敗の場合
			$dsSchedule->rollback($this);
			$this->log("再開処理がステータス画面でDBのステータス更新：失敗");
		}
		//T92Lock解除
		if (isset($t92lock_id) && !empty($t92lock_id)) {
			$T92Lock = array();
			$T92Lock["id"] = $t92lock_id;
			$T92Lock["del_flag"] = "Y";
			$T92Lock["update_user"] = $this->ESession->getUserId($this);
			$T92Lock["update_program"] = $this->name.'_Index_Finish_SMSSchedule';
			$dsT92Lock = $this->T92Lock->getDataSource();
			$dsT92Lock->begin($this);
			$flag = $this->T92Lock->save($T92Lock);
			if ($flag) {
				$dsT92Lock->commit($this);
			} else {
				$dsSchedule->rollback($this);
				$dsT92Lock->rollback($this);
				$this->log("再開処理がステータス画面でDBの操作：失敗");
				echo 'err_db';
				exit;
			}
		}
		if ($schedule) {
			$this->batch_sms('finish', $data['schedule_id']);
			echo 'success';
			exit;
		} else {
			echo 'err_db';
			exit;
		}
	}
	function sessionTimeReload(){
		$time_reload = $this->data["time_reload"];
		$this->ESession->setTimeReloadSms($time_reload, $this);
		exit;
	}
	function sessionTimeReloadStatus(){
		$time_reload = $this->data["time_reload"];
		$this->ESession->setTimeReloadSmsStatus($time_reload, $this);
		exit;
	}


	function arr_schedule($js_page, $limit, $column) {
		if (isset($this->viewVars['error_login']) && $this->viewVars['error_login']) {
			$res = array('status' => 'error_login');
			echo json_encode($res);
			exit;
		}

		$this->layout = 'ajax';
		if(isset($_GET["filter"]) && !empty($_GET["filter"])){
			$filter = $_GET["filter"];
		}else $filter = null;
		$post_code = $this->ESession->getUserPostCode($this);
        $delete_flag = $this->M04ControllerAction->check_permission($post_code, 'SmsSchedule', 'delete');
        $download_flag = $this->M04ControllerAction->check_permission($post_code, 'SmsSchedule', 'download');
		$page = $js_page + 1;
		$json_data = Array();
		$json_data["headers"] = Array("NO","スケジュール名","送信日","送信時間","テンプレート","送信リスト","リスト数","送信件数", "作成日時", "作成者", "アクション");
		$json_data["rows"] = Array();
		$company_id = $this->ESession->getUserCompanyId($this);
		$sort_order = $this->Util->getSmsScheduleSortOrder($column, ($delete_flag || $download_flag) ? 1 : 0);
		if ($delete_flag || $download_flag) {
			array_unshift($json_data["headers"], "cb");
			$time_send_position = 4;
		} else {
			$keyArr = array();
			if ($filter != null) {
				while (current($filter)) {
					$keyArr[] = key($filter) + 1;
					next($filter);
				}
				$filter = array_combine($keyArr, array_values($filter));
			}
			$time_send_position = 3;
		}

		$arr_schedules = $this->T200SmsSendSchedule->getScheduleByCompanyId($company_id, $limit, $page, $sort_order[0], $filter);
		$schedule_count = $this->T200SmsSendSchedule->getScheduleByCompanyIdCount($company_id, $filter);
		$total_row = $schedule_count[0]["total"];
		$json_data["total_rows"] = (int)$total_row;

		$schedule_ids = array();
		foreach ($arr_schedules as $arr_schedule) {
			$schedule_ids[] = $arr_schedule['T200SmsSendSchedule']['id'];
		}

		if ($column == 'column[' . $time_send_position . ']=0' || $column == 'column[' . $time_send_position . ']=1') {
			$sort_order_out_time = $this->Util->getSendTimeSortOrder($column, $time_send_position);
			$arr_out_time_tmps = $this->T201SmsSendTime->getByScheduleIds($schedule_ids, $sort_order_out_time[0]);
		} else {
			$arr_out_time_tmps = $this->T201SmsSendTime->getByScheduleIds($schedule_ids);
		}

		$arr_send_times = array();
		foreach ($arr_out_time_tmps as $arr_out_time) {
			$arr_send_times[$arr_out_time['T201SmsSendTime']['schedule_id']][] = $arr_out_time;
		}

		foreach ($arr_schedules as $key => $arr_schedule) {
			$i = 0;

			$json_row = array();
			$status = $arr_schedule['T200SmsSendSchedule']['status'];

			$color = $this->get_status_info($status, 'color');
			if (in_array($status, array(STATUS_SENDING, STATUS_TEMP_FINISH, STATUS_STOPING, STATUS_FINISHING))) {
				$class = "elereload";
			} else {
				$class = "";
			}

			if ($delete_flag || $download_flag)
			$json_row[$json_data["headers"][$i++]] = '<td style="background-color: '.$color.'">'
				. '<input type="checkbox" name="cbSelect['
				. $arr_schedule['T200SmsSendSchedule']['id'] . ']" id="cbSelect['
				. $arr_schedule['T200SmsSendSchedule']['id'] . ']" schedule_id="'
				. $arr_schedule['T200SmsSendSchedule']['id'] . '" onclick="updateCheckStatus(\'bundleCheckbox\');">'
				. '<label for="cbSelect[' . $arr_schedule['T200SmsSendSchedule']['id'] . ']" style="margin-top: 2px;"></label>'
				. '</td>';

			$json_row[$json_data["headers"][$i++]] = '<td style="background-color: '.$color.'">'.$arr_schedule['T200SmsSendSchedule']['schedule_no'].'</td>';
			$json_row[$json_data["headers"][$i++]] = '<td style="background-color: '.$color.'" class="break_word">'.$arr_schedule['T200SmsSendSchedule']['schedule_name'].'</td>';

			$str_send_date = date('Y-m-d', strtotime($arr_schedule['T201SmsSendTime']['time_start']));
			$str_send_time = '';
			if (isset($arr_send_times[$arr_schedule['T200SmsSendSchedule']['id']])) {
				foreach ($arr_send_times[$arr_schedule['T200SmsSendSchedule']['id']] as $send_time) {
					$time_start = date('H:i', strtotime($send_time['T201SmsSendTime']['time_start']));
					$time_end = date('H:i', strtotime($send_time['T201SmsSendTime']['time_end']));
					$str_send_time .= $time_start.'～'.$time_end.'<br>';
				}
			}

			$json_row[$json_data["headers"][$i++]] = '<td style="background-color: '.$color.'">'.$str_send_date.'</td>';
			$json_row[$json_data["headers"][$i++]] = '<td style="background-color: '.$color.'">'.$str_send_time.'</td>';
			$json_row[$json_data["headers"][$i++]] = '<td style="background-color: '.$color.'" class="break_word">'.$arr_schedule[0]['template_name'].'</td>';
			$json_row[$json_data["headers"][$i++]] = '<td style="background-color: '.$color.'" class="break_word">'.$arr_schedule[0]['list_name'].'</td>';

			$json_row[$json_data["headers"][$i++]] = '<td style="background-color: '.$color.'">'.$arr_schedule[0]['tel_total'].'</td>';
			$json_row[$json_data["headers"][$i++]] = '<td style="background-color: '.$color.'" class="send_total '.$class.'">'.$arr_schedule['T200SmsSendSchedule']['send_total'].'</td>';
			$json_row[$json_data["headers"][$i++]] = '<td style="background-color: '.$color.'">'.date('Y-m-d H:i', strtotime($arr_schedule['T200SmsSendSchedule']['created'])).'</td>';
			$json_row[$json_data["headers"][$i++]] = '<td style="background-color: '.$color.'" class="break_word">'.$arr_schedule['M05User']['user_name'].'</td>';

			$post_code = $this->ESession->getUserPostCode($this);
			$create_flag = $this->M04ControllerAction->check_permission($post_code, 'SmsSchedule', 'create');
			$status_flag = $this->M04ControllerAction->check_permission($post_code, 'SmsSchedule', 'status');
			$stop_send_flag = $this->M04ControllerAction->check_permission($post_code, 'SmsSchedule', 'stop_send');
			$resend_flag = $this->M04ControllerAction->check_permission($post_code, 'SmsSchedule', 'resend');

			$str_btn_edit = '<div class="iconFormat"><a href="javascript:void(0);" class="lnkEdit" schedule_id="'.$arr_schedule['T200SmsSendSchedule']['id'].'"><i title="編集" data-toggle="tooltip" class="glyphicon glyphicon-edit icon-white" ></i></a></div>';
			$str_btn_duplicate = '<div class="iconFormat"></div>';
			$str_btn_statistic = '<div class="iconFormat"></div>';
			$str_btn_stop = '<div class="iconFormat btnStopContainer"></div>';
			$str_btn_resend = '<div class="iconFormat btnRestartContainer"></div>';

			if ($create_flag) {
				$str_btn_duplicate = '<div class="iconFormat"><a href="javascript:void(0);" class="lnkDuplicate" schedule_id="'.$arr_schedule['T200SmsSendSchedule']['id'].'"><i title="複製" data-toggle="tooltip" class="glyphicon glyphicon-duplicate icon-white" ></i></a></div>';
			}
			if ($status != STATUS_NO_SEND && $status_flag) {
				$str_btn_statistic = '<div class="iconFormat"><a href="javascript:void(0);" class="lnkStatistic" schedule_id="'.$arr_schedule['T200SmsSendSchedule']['id'].'"><i title="状況をみる" data-toggle="tooltip" class="glyphicon glyphicon-stats icon-white" ></i></a></div>';
			}
			if ($status == STATUS_SENDING && $stop_send_flag) {
				$str_btn_stop = '<div class="iconFormat btnStopContainer"><a href="javascript:void(0);" class="lnkStop" schedule_id="'.$arr_schedule['T200SmsSendSchedule']['id'].'"><i title="停止" data-toggle="tooltip" class="glyphicon glyphicon-pause icon-white" ></i></a></div>';
			}
			if ($status == STATUS_STOP_SEND && $resend_flag) {
				$str_btn_resend = '<div class="iconFormat btnRestartContainer"><a href="javascript:void(0);" screen="index" action="resend" title_btn="再開" class="lnkRestart" schedule_id="'.$arr_schedule['T200SmsSendSchedule']['id'].'"><i title="再開" data-toggle="tooltip" class="glyphicon glyphicon-repeat icon-white" ></i></a></div>';
			}
			if ($status == STATUS_TEMP_FINISH && $resend_flag) {
				$str_btn_resend = '<div class="iconFormat btnRestartContainer"><a href="javascript:void(0);" screen="index" action="send_now" title_btn="即時送信" class="lnkRestart" schedule_id="'.$arr_schedule['T200SmsSendSchedule']['id'].'"><i title="再開" data-toggle="tooltip" class="glyphicon glyphicon-repeat icon-white" ></i></a></div>';
			}

			$str_btn_func = $str_btn_edit . $str_btn_duplicate . $str_btn_statistic . $str_btn_stop . $str_btn_resend;

			$json_row[$json_data["headers"][$i++]] = '<td style="background-color: '.$color.'">'.$str_btn_func.'</td>';
			$json_data["rows"][] = (object) $json_row;
		}
		$json_data['sortColumn'] = $sort_order[1];
		$json_data['sortType'] = $sort_order[2];
		$json_data['page'] = $js_page;

		$json_string = json_encode($json_data);
		echo $json_string;
		$this->ESession->setSortColumn($sort_order[1], $this);
		$this->ESession->setSortType($sort_order[2], $this);
		$this->ESession->setPage($js_page, $this);
		exit;
	}
	function arr_schedule_detail($js_page, $limit, $schedule_id, $column) {
		if (isset($this->viewVars['error_login']) && $this->viewVars['error_login']) {
			$res = array('status' => 'error_login');
			echo json_encode($res);
			exit;
		}

		$this->layout = 'ajax';
		if (isset($_GET["filter"]) && !empty($_GET["filter"])){
			$filter = $_GET["filter"];
		} else {
			$filter = null;
		}

		$schedule = $this->T200SmsSendSchedule->getHistoryInfoById($schedule_id);

		$page = $js_page + 1;
		$json_data = array();
		$json_data['headers'] = Array(
			'送信日時',
			'電話番号',
			'携帯キャリア',
			'到達結果'
		);

		//get tel_column from t102
		$list_item = $this->T102SmsListItem->getTelNumColumn($schedule["T200SmsSendSchedule"]["list_id"]);
		$tel_column = isset($list_item['T102SmsListItem']['column']) ? $list_item['T102SmsListItem']['column'] : NULL;

		if(isset($column) && !empty($column) && $column != "column") {
			$sort_order = $this->Util->getSmsScheduleDetailSortOrder($column);
		}

		//get data to result
		$logs = $this->T800SmsSendResult->getAllByScheduleId($schedule_id, $tel_column, $limit, $page, $sort_order[0], $filter);
		$json_data['total_rows'] = $this->T800SmsSendResult->getCountByScheduleId($schedule_id, $tel_column, $filter);
		$json_data['rows'] = Array();

		foreach ($logs as $log) {
			$i = 0;
			$json_row[$json_data['headers'][$i++]] = '<td>' . $log['T800SmsSendResult']['send_datetime'] . '</td>';
			$json_row[$json_data['headers'][$i++]] = '<td>' . $log['T800SmsSendResult']['tel_no'] . '</td>';
			$json_row[$json_data['headers'][$i++]] = '<td>' . $log['T501SmsTelHistory']['carrier'] . '</td>';
			if (isset($log['T800SmsSendResult']['status'])) {
				if ($log['T800SmsSendResult']['status'] == 'success') {
					$result = '着信済み';
				} else if ($log['T800SmsSendResult']['status'] == 'unknown') {
					$result = '不明';
				} else if ($log['T800SmsSendResult']['status'] == 'outside') {
					$result = '圏外';
				} else if ($log['T800SmsSendResult']['status'] == 'history_judgement_ng') { // #8298 add consentday
					$result = '履歴判定NG';
				} else {
					$result = 'エラー';
				}
			} else {
				$result = '';
			}
			$json_row[$json_data['headers'][$i++]] = '<td>' . $result . '</td>';

			$json_data['rows'][] = (object) $json_row;
		}

		$json_data['sortColumn'] = $sort_order[1];
		$json_data['sortType'] = $sort_order[2];
		$json_data['page'] = $js_page;

		$this->ESession->setSortColumn($sort_order[1], $this);
		$this->ESession->setSortType($sort_order[2], $this);
		$this->ESession->setPage($js_page, $this);
		echo json_encode($json_data);
		exit;
	}

	// 20160511 Add by Giang - #7108 - create and edit sms_schedule - Begin
	function save($type = null) {
		$this->layout = "ajax";
		$data = $this->data;
		if (empty($data)) {
			$this->redirect(array('controller' => 'SmsSchedule', 'action' => 'index'));
		}
		$create_flag = false;

		$user_id = $this->ESession->getUserId($this);
		$company_id = $this->ESession->getUserCompanyId($this);
		$dsSchedule = $this->T200SmsSendSchedule->getDataSource();
		$dsSchedule->begin($this);

		$action_update = false;

		$T200SmsSendSchedule = $data["T200SmsSendSchedule"];
		$T200SmsSendSchedule["company_id"] = $company_id;
		$update_time = date('Y-m-d H:i:s', time());

		// #8298 add consentday
		if (isset($data["T200SmsSendSchedule"]["consent_flag"])) {
			$T200SmsSendSchedule["consent_flag"] = "1";
		} else {
			$T200SmsSendSchedule["consent_flag"] = "0";
		}

		$run_date = $T200SmsSendSchedule["create_date"];
		if ($type == "call") {
			$T200SmsSendSchedule["entry_user"] = $user_id;
			$T200SmsSendSchedule["entry_program"] =  $this->name.'_Call_Schedule';
			$T201SmsSendTimes = json_decode($T200SmsSendSchedule["call_times2"], true);
		} else {
			$T201SmsSendTimes = json_decode($T200SmsSendSchedule["call_times"], true);
		}
		//追加処理
		if($type == "create" || $type == "duplicate"
			|| (($type == "call") && (!isset($T200SmsSendSchedule["id"]) || empty($T200SmsSendSchedule["id"])))){
			$create_flag = true;
			$max_schedule = $this->T200SmsSendSchedule->getMaxScheduleNoByCompanyId($company_id);
			if ($max_schedule["0"]["max_schedule_no"]) {
				$schedule_no = $max_schedule["0"]["max_schedule_no"] + 1;
			} else {
				$schedule_no = 1;
			}
			$T200SmsSendSchedule["schedule_no"] = $schedule_no;
			$T200SmsSendSchedule["entry_user"] = $user_id;
			$T200SmsSendSchedule["entry_program"] =  $this->name . '_' . ucfirst($type) . '_Schedule';

			if ($type == "call") {
				$T200SmsSendSchedule['del_flag'] = 'Y';
			}
		}

		//更新処理
		if ($type == "update" || ($type == "call" && isset($T200SmsSendSchedule["id"]) && !empty($T200SmsSendSchedule["id"]))) {
			$action_update = true;
			$T200SmsSendScheduleBackup = $this->T200SmsSendSchedule->getScheduleById($T200SmsSendSchedule["id"]);
			$T201SmsSendTimeBackups = $this->T201SmsSendTime->getByScheduleId($T200SmsSendSchedule["id"]);

			$T200SmsSendSchedule["update_user"] = $user_id;
			$T200SmsSendSchedule["update_program"] =  $this->name.'_Update_Schedule';
			//T92Lock登録
			$T92Lock = array();
			$T92Lock["lock_flag"] = 'sms_schedule';
			$T92Lock["lock_id"] = $T200SmsSendSchedule["id"];
			$T92Lock["use_user_id"] = $user_id;
			$T92Lock['session_id'] = $this->Session->id();
			$T92Lock["entry_user"] = $user_id;
			$T92Lock["entry_program"] = $this->name.'_Update_Schedule';
			$T92Lock["created"] = date('Y-m-d H:i:s a', time());

			$dsT92Lock = $this->T92Lock->getDataSource();
			$dsT92Lock->begin($this);
			$flag = $this->T92Lock->save($T92Lock);
			if($flag){
				$dsT92Lock->commit($this);
				$t92lock_id = $this->T92Lock->getLastInsertId();
			}else{
				$dsT92Lock->rollback($this);
				$dsSchedule->rollback($this);
				$this->log("スケジュール画面でDBの操作：失敗");
				$result = array("result" => "err_db", "schedule_id" => "",);
				echo json_encode($result);
				exit;
			}
		}

		// スケジュール2重登録確認(2重リクエスト対策)
		$check_same_data = array(
			"schedule_id" => $T200SmsSendSchedule["id"],
			"create_date" => $T200SmsSendSchedule["create_date"],
			"template_id" => $T200SmsSendSchedule["template_id"],
			"list_id" => $T200SmsSendSchedule["list_id"],
			"action" => $type
		);
		if ($type == "call") {
			// 即時送信処理の場合、create_dateに現在の日付を設定
			$check_same_data["create_date"] = Date('Y-m-d');
		}
		if (!$this->check_list_and_template_by_time_data($check_same_data)) {
			// スケジュール2重登録が確認された場合、2重リクエスト発生とし、メールを送信
			$dsSchedule->rollback($this);
			$this->log("スケジュール登録時、2重リクエスト発生(SMS)");

			$m02Company = $this->M02Company->getCompanyByCompanyId($company_id);
			$this->SendMail->sendErrorMail(
				"【はやぶさ】スケジュール登録時、2重リクエスト発生(SMS)",
				$company_id,
				$m02Company["M02Company"]["company_name"],
				$T200SmsSendSchedule["display_number"]
			);

			echo json_encode(
				array(
					"result" => "err_list_and_template_used",
					"schedule_id" => ""
				)
			);

			exit;
		}

		$M08SmsApiInfo = $this->M08SmsApiInfo->getApiInfoByDisplayNumber($T200SmsSendSchedule["display_number"]);
		if(isset($M08SmsApiInfo["M08SmsApiInfo"]["service_id"])){
			$T200SmsSendSchedule["service_id"] = $M08SmsApiInfo["M08SmsApiInfo"]["service_id"];
		}
		//保存
		$flag = $this->T200SmsSendSchedule->save($T200SmsSendSchedule);
		if ($action_update) {
			$schedule_id = $T200SmsSendSchedule["id"];
		} else {
			$schedule_id = $flag['T200SmsSendSchedule']['id'];
		}
		if ($flag) {
			$dsSchedule->commit($this);
		} else {
			//DBに更新失敗の場合
			$dsSchedule->rollback($this);
			$this->log("スケジュール画面でDBの操作：失敗");
			$result = array("result" => "err_db", "schedule_id" => "",);
			echo json_encode($result);
			exit;
		}
		//実行時間追加
		$dsOutTime = $this->T201SmsSendTime->getDataSource();
		$dsOutTime->begin($this);
		if ($type == 'update' || ($type == "call" && isset($T200SmsSendSchedule["id"]) && !empty($T200SmsSendSchedule["id"]))) {
			$update_program = $this->name . '_Update_Schedule';
			$condition_time_start = '';
			if ($type == "call" && isset($T200SmsSendSchedule["id"]) && !empty($T200SmsSendSchedule["id"])) {
				$condition_time_start = " AND time_start > '" . date('Y-m-d H:i:s') . "'";
			}
			$query = "UPDATE t201_sms_send_times
					SET
						del_flag='Y',
						update_user='" . $user_id . "',
						update_program='" . $update_program. "',
						modified='" . $update_time . "'
					WHERE
					    del_flag = 'N' AND
						schedule_id='" . $schedule_id . "'" . $condition_time_start . ";";

			$flag = $this->T201SmsSendTime->query($query);
			if ($flag) {
				$dsSchedule->rollback($this);
				$dsOutTime->rollback($this);
				$this->log("スケジュール画面で実行時間削除の操作：失敗");
				$result = array("result" => "err_db", "schedule_id" => "",);
				echo json_encode($result);
				exit;
			}
		}
		foreach ($T201SmsSendTimes as $arr) {
			$this->T201SmsSendTime->create();
			$T201SmsSendTime = array();
			$T201SmsSendTime['schedule_id'] = $schedule_id;
			$T201SmsSendTime['time_start'] = $run_date . " " . $arr['start_date'];
			$T201SmsSendTime['time_end'] = $run_date . " " . $arr['end_date'];
			$T201SmsSendTime['entry_user'] = $user_id;

			if ($type == 'duplicate') {
				$T201SmsSendTime['entry_program'] =  $this->name . '_Duplicate_Schedule';
			} else if ($type == 'update') {
				$T201SmsSendTime['entry_program'] =  $update_program;
			} else {
				$T201SmsSendTime['entry_program'] =  $this->name . '_Create_Schedule';
			}
			$flag = $this->T201SmsSendTime->save($T201SmsSendTime);
			if (!$flag) {
				//DBに更新失敗の場合
				$dsSchedule->rollback($this);
				$dsOutTime->rollback($this);
				$this->log("スケジュール画面で実行時間追加の操作：失敗");
				$result = array("result" => "err_db", "schedule_id" => "",);
				echo json_encode($result);
				exit;
			}
		}
		$dsOutTime->commit($this);

		$batch_result = 'success';
		if ($type == 'call') {
			// update del_flag = Y for schedule
			$dsSchedule = $this->T200SmsSendSchedule->getDataSource();
			$dsSchedule->begin($this);
			$T200SmsSendSchedule = array();
			$T200SmsSendSchedule['id'] = $schedule_id;
			$T200SmsSendSchedule['del_flag'] = 'Y';
			$T200SmsSendSchedule['update_user'] = $user_id;
			$T200SmsSendSchedule['update_program'] = $this->name . '_Call_Schedule';
			$flag = $this->T200SmsSendSchedule->save($T200SmsSendSchedule);
			$dsSchedule->commit($this);

			$batch_result = $this->batch_sms('send_now', $schedule_id);
		}

		if ($batch_result == "success") {
			$T200SmsSendSchedule["id"] = $schedule_id;
			if($type == "call") {
				$dsSchedule = $this->T200SmsSendSchedule->getDataSource();
				$dsSchedule->begin($this);
				$T200SmsSendSchedule = array();
				$T200SmsSendSchedule['id'] = $schedule_id;
				$T200SmsSendSchedule['del_flag'] = 'N';
				$T200SmsSendSchedule['status'] = STATUS_SENDING;
				$T200SmsSendSchedule['update_user'] = $user_id;
				$T200SmsSendSchedule['update_program'] = $this->name . '_Call_Schedule';
				$flag = $this->T200SmsSendSchedule->save($T200SmsSendSchedule);
				$dsSchedule->commit($this);
			}
			//T92Lock解除
			if (isset($t92lock_id) && !empty($t92lock_id)) {
				$T92Lock = array();
				$T92Lock["id"] = $t92lock_id;
				$T92Lock["del_flag"] = "Y";
				$T92Lock["update_user"] = $user_id;
				$T92Lock["update_program"] = $update_program;
				$T92Lock["modified"] = $update_time;

				$dsT92Lock = $this->T92Lock->getDataSource();
				$dsT92Lock->begin($this);
				$flag = $this->T92Lock->save($T92Lock);
				if ($flag) {
					$dsT92Lock->commit($this);
				} else {
					$dsT92Lock->rollback($this);
					$dsSchedule->rollback($this);
					$dsOutTime->rollback($this);

					$this->log("スケジュール画面でDBの操作：失敗");
					$result = array(
							"result" => "err_db",
							"schedule_id" => "",
					);
					echo json_encode($result);
					exit;
				}
			}
		} else {
			if ($action_update) {
				$T200SmsSendSchedule = $T200SmsSendScheduleBackup;
			} else {
				$T200SmsSendSchedule["id"] = $schedule_id;
				$T200SmsSendSchedule["del_flag"] = "Y";
			}
			$query = "UPDATE t201_sms_send_times
					  SET
						  del_flag='Y',
						  update_user='". $user_id . "',
						  update_program='" . $update_program. "',
						  modified='" . $update_time . "'
					  WHERE
					      del_flag = 'N' AND
						  schedule_id='" . $schedule_id . "';
					  ";
			$flag = $this->T201SmsSendTime->query($query);
			if ($flag) {
				$dsOutTime->rollback($this);
				$this->log("スケジュール画面で実行時間追加の操作：失敗");
				$result = array("result" => "err_db", "schedule_id" => "",);
				echo json_encode($result);
				exit;
			}
			if (isset($T201SmsSendTimeBackups)) {
				foreach ($T201SmsSendTimeBackups as $T201SmsSendTimeBackup) {
					$this->T201SmsSendTime->create();
					$T201SmsSendTime = array();
					$flag = $this->T201SmsSendTime->save($T201SmsSendTimeBackup);
					if (!$flag) {
						//DBに更新失敗の場合
						$dsOutTime->rollback($this);
						$this->log("スケジュール画面で実行時間追加の操作：失敗");
						$result = array("result" => "err_db", "schedule_id" => "",);
						echo json_encode($result);
						exit;
					}
				}
			}
		}
		$flag = $this->T200SmsSendSchedule->save($T200SmsSendSchedule);
		if ($flag) {
			$dsSchedule->commit($this);
		} else {
			//DBに更新失敗の場合
			$dsSchedule->rollback($this);
			$this->log("スケジュール画面でDBの操作：失敗");
			$result = array("result" => "err_db", "schedule_id" => "",);
			echo json_encode($result);
			exit;
		}
		$result = array("result" => $batch_result, "schedule_id" => $schedule_id);
		echo json_encode($result);
		if ($type == "call") {
			$this->ESession->setTimeReloadSmsStatus(1, $this);
			sleep(10);
		}
		if ($create_flag) {
			$this->batch_sms('create', $schedule_id);
		}		
		exit;
	}
	// 20160511 Add by Giang - #7108 - create and edit sms_schedule - End

	function status_autoupdate() {
		if (isset($this->viewVars['error_login']) && $this->viewVars['error_login']) {
			echo 'error_login';
			exit;
		}
		$this->status();
	}

	function check_delete_schedule() {
		$data = $this->data;
		if (empty($data)) {
			$this->redirect(array('controller' => 'SmsSchedule', 'action' => 'index'));
		}

		$schedule_ids = $data['schedule_ids'];
		foreach ($schedule_ids as $id) {
			$arr_schedule_info = $this->T200SmsSendSchedule->getScheduleById($id);
			if (count($arr_schedule_info) < 1) {
				$result = array(
					'status' => 'err_not_exist',
					'schedule_id' => $id
				);
				echo json_encode($result);
				exit;
			}

			if (!in_array($arr_schedule_info['T200SmsSendSchedule']['status'], array(STATUS_NO_SEND, STATUS_FINISH))) {
				$result = array(
					'status' => 'err_status',
					'schedule_id' => $id,
					'msg' => $this->get_status_info($arr_schedule_info['T200SmsSendSchedule']['status'], 'text') . SMS_SCHEDULE_ERROR_DELETE
				);
				echo json_encode($result);
				exit;
			} else if (!$this->check_unlock_schedule($arr_schedule_info['T200SmsSendSchedule']['id'])) {
				$result = array(
					'status' => 'error_locking',
					'schedule_id' => $id
				);
				echo json_encode($result);
				exit;
			} else if ($arr_schedule_info['T200SmsSendSchedule']['status'] == STATUS_NO_SEND && !$this->call_check_start_time($id, 'delete')) {
				$result = array(
					'status' => 'error_start_time'
				);
				echo json_encode($result);
				exit;
			}
		}
		$result = array(
			'status' => 'can_delete',
		);
		echo json_encode($result);
		exit;
	}
	function check_download_schedule() {
		$data = $this->data;
		if (empty($data)) {
			$this->redirect(array('controller' => 'SmsSchedule', 'action' => 'index'));
		}

		$schedule_ids = $data['schedule_ids'];
		if (!is_array($schedule_ids)) {
			$schedule_ids = explode(' ', $schedule_ids);
		}
		foreach ($schedule_ids as $id) {
			$arr_schedule_info = $this->T200SmsSendSchedule->getScheduleById($id);
			if (count($arr_schedule_info) < 1) {
				$result = array(
					'status' => 'err_not_exist',
					'schedule_id' => $id
				);
				echo json_encode($result);
				exit;
			}

			if ($arr_schedule_info['T200SmsSendSchedule']['status'] == STATUS_NO_SEND) {
				$result = array(
					'status' => 'err_status',
					'schedule_id' => $id,
					'msg' => $this->get_status_info($arr_schedule_info['T200SmsSendSchedule']['status'], 'text') . SMS_SCHEDULE_ERROR_DOWNLOAD
				);
				echo json_encode($result);
				exit;
			}
		}
		$result = array(
			'status' => 'can_download',
		);
		echo json_encode($result);
		exit;
	}
	function check_stop_schedule(){
		$data = $this->data;
		if (!empty($data)) {
			$arr_schedule_info = $this->T200SmsSendSchedule->getScheduleById($data['schedule_id']);
			if (count($arr_schedule_info) < 1) {
				$result = array(
					'status' => 'err_not_exist',
					'schedule_id' => $data['schedule_id']
				);
				echo json_encode($result);
				exit;
			}

			//ステータス停止じゃない場合
			$status = $arr_schedule_info['T200SmsSendSchedule']['status'];
			if ($status != STATUS_SENDING) {
				$result = array(
					'result' => 'err_status',
					'msg' => SMS_SCHEDULE_ERROR_STOP_SEND_1 . $this->get_status_info($status, 'text') . SMS_SCHEDULE_ERROR_STOP_SEND_2
				);
				echo json_encode($result);
				exit;
			}

			//スケジュールロック場合
			if ($this->check_unlock_schedule($data['schedule_id']) == false) {
				$result = array(
					'result' => 'error_locking',
				);
				echo json_encode($result);
				exit;
			}

			//通常場合
			$result = array(
				'result' => 'success',
			);
			echo json_encode($result);
			exit;
		}
		exit;
	}
	function check_resend_schedule() {
		$data = $this->data;
		if (empty($data)) {
			$this->redirect(array('controller' => 'SmsSchedule', 'action' => 'index'));
		}

		$arr_schedule_info = $this->T200SmsSendSchedule->getScheduleById($data['schedule_id']);
		if (count($arr_schedule_info) < 1) {
			$result = array(
				'result' => 'err_exist_schedule',
				'schedule_id' => $data['schedule_id']
			);
			echo json_encode($result);
			exit;
		}
		//ステータス停止じゃない場合
		$status = $arr_schedule_info['T200SmsSendSchedule']['status'];
		if ($data['action'] == "resend") {
			if (!$this->check_status_can_resend($status)) {
				$result = array(
					'result' => 'err_status',
					'msg' => SMS_SCHEDULE_ERROR_RE_SEND_1 . $this->get_status_info($status, 'text') . SMS_SCHEDULE_ERROR_RE_SEND_2
				);
				echo json_encode($result);
				exit;
			}
		} else if ($data['action'] == 'send_now') {
			if (!$this->check_status_can_send_now($status)) {
				$result = array(
					'result' => 'err_status',
					'msg' => SMS_SCHEDULE_ERROR_SEND_NOW_1 . $this->get_status_info($status, 'text') . SMS_SCHEDULE_ERROR_SEND_NOW_2
				);
				echo json_encode($result);
				exit;
			}
		}

		//check over_schedule
		$arr_limit_schedule = $this->M99SystemParameter->getByFunctionIdAndParameterId('SMS_SCHEDULE', 'MAX_SCHEDULE');
		$limit_schedule = $arr_limit_schedule['M99SystemParameter']['parameter_value'];

		foreach ($data['list_send_times'] as $key => $send_time) {
			$data_send_time = array(
				'schedule_id' => $data['schedule_id'],
				'start_time' => date('Y-m-d H:i:s', strtotime($send_time['start_date'])),
				'end_time' => date('Y-m-d H:i:s', strtotime($send_time['end_date'])),
				'action' => $data['action']
			);

			if (!$this->check_over_schedule($data_send_time, $limit_schedule)) {
				$result = array(
					"result" => "err_over_schedule",
					"limit_schedule" => $limit_schedule
				);
				echo json_encode($result);
				exit;
			}
		}

		//スケジュールロック場合
		if ($this->check_unlock_schedule($data['schedule_id']) == false) {
			$result = array(
				'result' => 'error_locking',
			);
			echo json_encode($result);
			exit;
		}

		$check_display_number = $this->check_display_number_by_time_data_resend($data);
		if ($check_display_number != 'true') {
			$result['result'] = 'err_service_id_used';
			$result['time_start'] = $check_display_number['T201SmsSendTime']['time_start'];
			$result['time_end'] = $check_display_number['T201SmsSendTime']['time_end'];
			echo json_encode($result);
			exit;
		}
		//通常場合
		$result = array(
			'result' => 'success',
		);
		echo json_encode($result);
		exit;
	}
	function check_finish_schedule() {
		$data = $this->data;
		if (empty($data)) {
			echo 'systemerror';
			exit;
		}

		$arr_schedule_info = $this->T200SmsSendSchedule->getScheduleById($data['schedule_id']);
		if (count($arr_schedule_info) < 1) {
			echo 'err_not_exist';
			exit;
		}

		$status = $arr_schedule_info['T200SmsSendSchedule']['status'];
		if ($status != STATUS_STOP_SEND && $status != STATUS_TEMP_FINISH && $status != STATUS_STOPING && $status != STATUS_FINISHING) {
			echo 'err_status',
			exit;
		}

		echo 'success';
		exit;
	}

	function buffer_schedule_data($action) {
		$data = $this->data;
		if (empty($data)) {
			echo 'systemerror';
			exit;
		}

		$schedule_ids = $data['schedule_ids'];
		$download_multi = true;
		if (!is_array($schedule_ids)) {
			$schedule_ids = explode(' ', $schedule_ids);
			$download_multi = false;
		}

		$schedule_data = Array();
		if ($action == 'download_unsend') {
			$schedule_data['schedule_data'] = $this->download_unsend($schedule_ids);
			$schedule_data['action_name'] = '未送信';
		} else if ($action == 'download_all_log') {
			$schedule_data['schedule_data'] = $this->download_all_log($schedule_ids);
			$schedule_data['action_name'] = '送信済み';
		}

		$schedule_data['download_multi'] = $download_multi;
		$this->ESession->setSmsScheduleDataDownload($schedule_data, $this);
		echo 'success';
		exit;
	}
	function download_unsend($schedule_ids) {
		$schedule_data = Array();
		foreach ($schedule_ids as $schedule_id) {
			$schedule = $this->T200SmsSendSchedule->getScheduleById($schedule_id);
			if (!empty($schedule)) {
				$schedule_info = $this->T200SmsSendSchedule->getHistoryInfoById($schedule_id);

				//get format csv from t102
				$list_id = $schedule_info["T500SmsListHistory"]["list_id"];
				$list_items = $this->T102SmsListItem->getTitleByListId($list_id);

				//add header for csv file
				$header_arr = array();
				$list_columns = array();
				foreach ($list_items as $list_item) {
					$list_columns[] = $list_item['T102SmsListItem']['column'];
					$header_arr[] = $list_item['T102SmsListItem']['item_name'];

					if ($list_item['T102SmsListItem']['item_code'] == 'tel_no') {
						$tel_column = $list_item['T102SmsListItem']['column'];
					}
				}
				// $this->Csv->addRow($header_arr);
				$schedule_data[$schedule_id][] = $header_arr;

				//get data from db to create csv file
				$tel_no_not_sends = $this->T501SmsTelHistory->getTelNotSends($schedule_id, $tel_column);
				if (sizeof($tel_no_not_sends) > 0) {
					foreach ($tel_no_not_sends as $tel_no) {
						$r = array();
						foreach ($list_columns as $column) {
							array_push($r, $tel_no['T501SmsTelHistory'][$column]);
						}
						// $this->Csv->addRow($r);
						$schedule_data[$schedule_id][] = $r;
					}
				} else {
					// $this->Csv->addRow(array());
					$schedule_data[$schedule_id][] = Array();
				}
			}
		}

		return $schedule_data;
	}
	function download_all_log($schedule_ids){
		$schedule_data = Array();
		$arr_all_listitem = $this->M90PulldownCode->getSelectOption("list_item");
		$num_all_listitem = count($arr_all_listitem);
		foreach ($schedule_ids as $schedule_id) {
			$schedule = $this->T200SmsSendSchedule->getScheduleById($schedule_id);
			if (!empty($schedule)) {
				$schedule_info = $this->T200SmsSendSchedule->getHistoryInfoById($schedule_id);
				$list_id = $schedule_info['T200SmsSendSchedule']['list_id'];

				//get tel_column from t102
				$list_items = $this->T102SmsListItem->getTitleByListId($list_id);

				//add header for csv file
				$header_lists = array();
				foreach ($list_items as $list_item) {
					if ($list_item['T102SmsListItem']['item_code'] == 'tel_no') {
						$tel_column = $list_item['T102SmsListItem']['column'];
					}
					$header_lists[$list_item['T102SmsListItem']['column']] = $list_item['T102SmsListItem']['item_name'];
				}
				/* $count_header_lists = count($header_lists);
				for($i = 1; $i <= ($num_all_listitem-$count_header_lists); $i++){
					array_push($header_lists, "備考".$i);
				} */

				/* $header_lists['carrier'] = '携帯キャリア';
				$header_lists['result'] = '到達結果'; */

				 /* $header_csv_files = array(
					'send_datetime' => '送信日時',
				); */
				$header_csv_files = array(
						'status' => '送達状態',
						'warning_msg' => '送達警告情報',
						'sms_short_url_key' => '短縮URLキー',
				);

				$header_csv_files = array_merge(
						$header_lists,
						$header_csv_files
				);

				//add header for csv file
				$header_arr = array();
				foreach ($header_csv_files as $header_csv_file) {
					$header_arr[] = $header_csv_file;
				}
				$schedule_data[$schedule_id][] = $header_arr;

				//get data from db to create csv file
				$logs = $this->T800SmsSendResult->getAllByScheduleId($schedule_id, $tel_column);

				if (sizeof($logs) > 0) {
					foreach ($logs as $log) {
						$r = array();
						//$r[] = $log['T800SmsSendResult']['send_datetime'];

						foreach ($header_lists as $key => $header_list) {
							if (isset($log['T501SmsTelHistory'][$key]) && !empty($log['T501SmsTelHistory'][$key])) {
								$r[] = $log['T501SmsTelHistory'][$key];
							} else {
								$r[] = '';
							}
						}

						if (!empty($log['T800SmsSendResult']['status'])) {
							if ($log['T800SmsSendResult']['status'] == 'success') {
								$result = '着信済み';
							} else if ($log['T800SmsSendResult']['status'] == 'unknown') {
								$result = '不明';
							} else if ($log['T800SmsSendResult']['status'] == 'outside') {
								$result = '圏外';
							} else if ($log['T800SmsSendResult']['status'] == 'history_judgement_ng') { // #8298 add consentday
								$result = '履歴判定NG';
							}  else {
								$result = 'エラー';
							}
							$r[] = $result;
						} else {
							$r[] = '';
						}
						if(!empty($log['T800SmsSendResult']['warning_msg'])){
							$r[] = $log['T800SmsSendResult']['warning_msg'];
						}else{
							$r[] = '';
						}

						if(!empty($log['T800SmsSendResult']['sms_short_url_key'])){
							$r[] = $log['T800SmsSendResult']['sms_short_url_key'];
						}else{
							$r[] = '';
						}
						// $this->Csv->addRow($r);
						$schedule_data[$schedule_id][] = $r;
					}
				}
			}
		}

		return $schedule_data;
	}


	function check_unlock_schedule($schedule_id) {
		$user_id = $this->ESession->getUserId($this);
		$session_id = $this->Session->id();
		$info_lock = $this->T92Lock->getInfoLock('sms_schedule', $schedule_id);
		if (count($info_lock) > 0 && ($info_lock['T92Lock']['use_user_id'] != $user_id || $info_lock['T92Lock']['session_id'] != $session_id)){
			return false;
		} else {
			return true;
		}
	}
	function check_over_schedule($data, $limit_schedule){
		$company_id = $this->ESession->getUserCompanyId($this);
		$schedule_id = $data['schedule_id'];
		$time_start = $data['start_time'];
		$time_end = $data['end_time'];
		$action = $data['action'];

		$arr_infos = $this->T200SmsSendSchedule->getScheduleNotFinishByOperationTime($company_id, $schedule_id, $time_start, $time_end, $action);

		if (sizeof($arr_infos) >= $limit_schedule) {
			return false;
		}
		return true;
	}
	function check_exist_schedule(){
		$data = $this->data;
		$arr_schedule_info = $this->T200SmsSendSchedule->getScheduleById($data['id']);
		if (count($arr_schedule_info) < 1) {
			echo "false";
			exit;
		}
		echo "true";
		exit;
	}


	function check_status_can_resend($status){
		$status_resend = Array(STATUS_STOP_SEND);
		if (in_array($status, $status_resend)) {
			return true;
		} else {
			return false;
		}
	}
	function check_status_can_send_now($status){
		$status_send_now = Array(STATUS_TEMP_FINISH);
		if (in_array($status, $status_send_now)) {
			return true;
		} else {
			return false;
		}
	}


	function get_status_info($status=null, $attr=null) {
		$status_infos = array(
			STATUS_NO_SEND => array(
				'text' => '未送信',
				'color' => 'white'
			),
			STATUS_SENDING => array(
				'text' => '実行中',
				'color' => '#b4e3f2'
			),
			STATUS_STOPING => array(
					'text' => '停止中',
					'color' => '#f2d6b1'
			),
			STATUS_FINISHING => array(
					'text' => '終了中',
					'color' => '#f2d6b1'
			),
			STATUS_STOP_SEND => array(
				'text' => '手動停止',
				'color' => '#ed9191'
			),
			STATUS_TEMP_FINISH => array(
				'text' => '停止',
				'color' => '#FBF483'
			),
			STATUS_FINISH => array(
				'text' => '終了',
				'color' => '#c3c3c3'
			),
		);

		if (isset($status)) {
			if (isset($attr) && isset($status_infos[$status][$attr]))
				return $status_infos[$status][$attr];
			else
				return '';
		} else {
			return $status_infos;
		}
	}
	function show_popup_resend() {
		$this->layout = false;
		$this->view = 'popup_resend';

		$data = $this->data;
		$outgoing_time = $this->M90PulldownCode->getSelectOption('outgoing_time');

		$this->set('outgoing_time', $outgoing_time);
		$this->set("schedule_id", $data['schedule_id']);
		$this->set("title_btn", $data['title_btn']);
		$this->set("action", $data['action']);
		$this->set("screen", $data['screen']);
	}
	function get_send_time() {
		$data = $this->data;
		if (empty($data) || !isset($data['schedule_id']) || (!isset($data['limit_datetime']))) {
			echo 'systemerror';
			exit;
		}
		$schedule_id = $data['schedule_id'];
		$limit_datetime = $data['limit_datetime'];

		$data_send_times = $this->T201SmsSendTime->getByScheduleId($schedule_id, false, $limit_datetime);
		$data_send_logs = $this->T202SmsSendLog->getByScheduleId($schedule_id);

		$arr_send_times = array();
		$index = 0;
		foreach ($data_send_logs as $data_send_log) {
			$arr_send_times[] = array(
				'start_date' => $data_send_log['T202SmsSendLog']['time_start'],
				'end_date' => $data_send_log['T202SmsSendLog']['time_end'],
				'section_id' => 1,
				'text' => 'send_times_' . $index,
				'color' => '#A5A5A5',
				'disable_edit' => 1
			);
			$index++;
		}
		foreach ($data_send_times as $data_send_time) {
			$arr_send_times[] = array(
				'start_date' => $data_send_time['T201SmsSendTime']['time_start'],
				'end_date' => $data_send_time['T201SmsSendTime']['time_end'],
				'section_id' => 1,
				'text' => 'send_times_' . $index
			);
			$index++;
		}

		echo json_encode($arr_send_times);
		exit;
	}


	function batch_sms($batch_type = 'stop_send' ,$schedule_id = null) {
		$result = 'success';
		$m99_sys_para = $this->M99SystemParameter->getByFunctionIdAndParameterId('SMS_BATCH', 'LOCAL_PATH');
		$local_path  = $m99_sys_para["M99SystemParameter"]["parameter_value"];

		if (($batch_type == 'create') || ($batch_type == 'finish')) {
			$cmd = "php " . $local_path . "SendCreateOrFinishSmsScheduleMail.php ".$schedule_id." > /dev/null 2> /dev/null &";
		} elseif ($batch_type == 'stop_send') {
			$cmd = "php " . $local_path . "GetSendStatus.php ".$schedule_id." > /dev/null 2> /dev/null &";
		} elseif ($batch_type == 'send_now') {
			$cmd = "php " . $local_path . "SendNow.php ".$schedule_id." > /dev/null 2> /dev/null &";
		} elseif ($batch_type == 're_send') {
			$resend_flag = 1;
			$cmd = "php " . $local_path . "SendNow.php ".$schedule_id." ".$resend_flag." > /dev/null 2> /dev/null &";
		}
		exec($cmd, $shell_result, $shell_result_status);
		if ($shell_result_status != 0) {
			$result = $shell_result[0];
			$this->log($batch_type);
			$this->log($cmd);
			$this->log($shell_result);
			$this->log($shell_result_status);
			$this->log("BATCH_SMS_ERROR");
		}

		return $result;
	}

	// #8298 add consentday
	function consentday_check($list_id){
		$result = $this->T101SmsTelList->getConsentday($list_id);
		if ($result>0){
			$result = false;
		} else {
			$result = true;
		}

		return $result;
	}
}
