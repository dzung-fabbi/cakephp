<?php
App::uses('AppController', 'Controller');

class SmsTemplateController extends AppController {
	var $uses = array('M01Server', 'M99SystemParameter', 'M90PulldownCode', 'T92Lock', 'M05User', 'T300SmsTemplate', 'T200SmsSendSchedule', 'T102SmsListItem');

	function index() {
		$enable_create = $this->M04ControllerAction->check_permission($this->post_code, 'SmsTemplate', 'create');
		$enable_delete = $this->M04ControllerAction->check_permission($this->post_code, 'SmsTemplate', 'delete');
		$enable_edit = $this->M04ControllerAction->check_permission($this->post_code, 'SmsTemplate', 'edit');

		$insert_item = $this->T102SmsListItem->getListItemNameByCompany($this->ESession->getUserCompanyId($this));
		$this->set('insert_item', $insert_item);

		$this->set('enable_create', $enable_create);
		$this->set('enable_delete', $enable_delete);
		$this->set('enable_edit', $enable_edit);
	}

	function arr_sms_template_list($js_page, $limit, $column) {
		$this->layout = 'ajax';
		$filter = $_GET["filter"];
		$page = $js_page + 1;
		$json_data = Array();
		$json_data["headers"] = Array('NO', '名称', '説明', '作成日時', '作成者', 'アクション');
		$json_data["rows"] = Array();
		$company_id = $this->ESession->getUserCompanyId($this);

		$enable_create = $this->M04ControllerAction->check_permission($this->post_code, 'SmsTemplate', 'create');
		$enable_delete = $this->M04ControllerAction->check_permission($this->post_code, 'SmsTemplate', 'delete');
		$enable_edit = $this->M04ControllerAction->check_permission($this->post_code, 'SmsTemplate', 'edit');

		if ($enable_delete) {
			array_unshift($json_data["headers"], "checkbox");
		} else {
			$keyArr = array();
			if ($filter != null) {
				while (current($filter)) {
					$keyArr[] = key($filter) + 1;
					next($filter);
				}
				$filter = array_combine($keyArr, array_values($filter));
			}
		}

		if(isset($column) && !empty($column) && $column != "column"){
			$sort_order = $this->Util->getSmsTemplateSortOrder($column, $enable_delete ? 1 : 0);
		}

		$sort_order_col = isset($sort_order[0]) ? $sort_order[0] : null;
		$arr_lists = $this->T300SmsTemplate->getListByCompanyId($company_id, $limit, $page, $sort_order_col, $filter);

		$json_data["total_rows"] = $this->T300SmsTemplate->getListByCompanyIdCount($company_id, $filter);
		foreach ($arr_lists as $arr_list) {
			$json_row = array();
			if ($enable_delete) {
				$json_row['checkbox'] = '<input type="checkbox" name="sms_template_ids[' . $arr_list['T300SmsTemplate']['id'] . ']" id="cbSelect[' . $arr_list['T300SmsTemplate']['id'] . ']" value="' . $arr_list['T300SmsTemplate']['id'] . '">'
					. '<label for="cbSelect[' . $arr_list['T300SmsTemplate']['id'] . ']" style="margin-top: 2px;"></label>';
			}
			$json_row['NO'] = $arr_list['T300SmsTemplate']['template_no'];
			$json_row['名称'] = $arr_list['T300SmsTemplate']['template_name'];
			$json_row['説明'] = empty($arr_list['T300SmsTemplate']['description']) ? '' : $arr_list['T300SmsTemplate']['description'];
			$json_row['作成日時'] = date('Y-m-d H:i', strtotime($arr_list['T300SmsTemplate']['created']));
			$json_row['作成者'] = $arr_list['M05User']['user_name'];
			$str_btn_func = '<div class="iconFormat"><a href="javascript:void(0);" class="lnkEdit btnEdit" sms_template_id="' . $arr_list['T300SmsTemplate']['id'] . '">'
					. '<i title="編集" data-toggle="tooltip" class="glyphicon glyphicon-edit icon-white" ></i></a></div>';
			if ($enable_create) {
				$str_btn_func .= '<div class="iconFormat"><a href="javascript:void(0);" class="btnDuplicate" sms_template_id="' . $arr_list['T300SmsTemplate']['id'] . '">'
					. '<i title="複製" data-toggle="tooltip" class="glyphicon glyphicon-duplicate icon-white" ></i></a></div>';
			}
			$json_row['アクション'] = $str_btn_func;
			$json_data["rows"][] = (object) $json_row;
		}
		$json_string = json_encode($json_data);
		echo $json_string;
		if(isset($sort_order)){
			$this->ESession->setSortColumn($sort_order[1], $this);
			$this->ESession->setSortType($sort_order[2], $this);
		}else{
			$this->ESession->setSortColumn(null, $this);
			$this->ESession->setSortType(null, $this);
		}
		$this->ESession->setPage($js_page, $this);
		exit;
	}

	function add_sms_template() {
		if (empty($this->data) || empty($this->data['templateName']) || empty($this->data['content'])) {
			echo 'systemerror';
			exit;
		}

		$entry_user = $this->ESession->getUserId($this);
		$entry_program = $this->name.'_'.__FUNCTION__;
		$company_id = $this->ESession->getUserCompanyId($this);
		$max_template_no = $this->T300SmsTemplate->getMaxTemplateNoByCompanyId($company_id);

		if ($max_template_no['0']['max_template_no']) {
			$template_no_new = $max_template_no['0']['max_template_no'] + 1;
		} else {
			$template_no_new = '1';
		}

		$check_lock = $this->T92Lock->getInfoLock('sms_template_list', $template_no_new);
		if (!empty($check_lock)) {
			echo 'systemerror';
			exit;
		}

		$lock_new = $this->create_lock('sms_template_list', $template_no_new, __FUNCTION__);
		if (!$lock_new) {
			echo 'systemerror';
			exit;
		}

		$template_name = $this->data['templateName'];
		$description = $this->data['description'];
		$content = $this->data['content'];
		$sms_use_short_url = $this->data['sms_use_short_url'];

		//Save data to DB
		$dsT300SmsTemplate = $this->T300SmsTemplate->getDataSource();
		$dsT300SmsTemplate->begin($this);

		$this->T300SmsTemplate->create();
		$data_call_list['T300SmsTemplate']['company_id'] = $company_id;
		$data_call_list['T300SmsTemplate']['template_no'] = $template_no_new;
		$data_call_list['T300SmsTemplate']['template_name'] = $template_name;
		$data_call_list['T300SmsTemplate']['description'] = $description;
		$data_call_list['T300SmsTemplate']['content'] = $content;
		$data_call_list['T300SmsTemplate']['sms_use_short_url'] = $sms_use_short_url;
		$data_call_list['T300SmsTemplate']['template_type'] = 1;
		$data_call_list['T300SmsTemplate']['entry_user'] = $entry_user;
		$data_call_list['T300SmsTemplate']['entry_program'] = $entry_program;
		$sms_template = $this->T300SmsTemplate->save($data_call_list);

		if(!$sms_template || (isset($lock_new) && !empty($lock_new) && !$this->update_lock($lock_new, __FUNCTION__))){
			$dsT300SmsTemplate->rollback($this);
			echo 'systemerror';
			exit;
		}
		$dsT300SmsTemplate->commit($this);

		$results = Array();
		$results['status'] = 'save';
		$results['sortColumn'] = $this->ESession->getSortColumn($this);
		$results['sortType'] = $this->ESession->getSortType($this);
		$results['page'] = $this->ESession->getPage($this);
		echo json_encode($results);
		exit;
	}

	function update_sms_template() {
		if (empty($this->data) || empty($this->data['templateId']) || empty($this->data['templateName']) || empty($this->data['content'])) {
			echo 'systemerror';
			exit;
		}

		$update_user = $this->ESession->getUserId($this);
		$update_program = $this->name.'_'.__FUNCTION__;
		$company_id = $this->ESession->getUserCompanyId($this);

		$template_id = $this->data['templateId'];
		$template_name = $this->data['templateName'];
		$description = $this->data['description'];
		$content = $this->data['content'];
		$sms_use_short_url = $this->data['sms_use_short_url'];

		//Save data to DB
		$dsT300SmsTemplate = $this->T300SmsTemplate->getDataSource();
		$dsT300SmsTemplate->begin($this);

		$data_sms_tem['T300SmsTemplate']['id'] = $template_id;
		$data_sms_tem['T300SmsTemplate']['template_name'] = $template_name;
		$data_sms_tem['T300SmsTemplate']['description'] = $description;
		$data_sms_tem['T300SmsTemplate']['content'] = $content;
		$data_sms_tem['T300SmsTemplate']['update_user'] = $update_user;
		$data_sms_tem['T300SmsTemplate']['update_program'] = $update_program;
		$data_sms_tem['T300SmsTemplate']['sms_use_short_url'] = $sms_use_short_url;
		$sms_template = $this->T300SmsTemplate->save($data_sms_tem['T300SmsTemplate']);

		if (!$sms_template) {
			$dsT300SmsTemplate->rollback($this);
			echo 'systemerror';
			exit;
		}
		$dsT300SmsTemplate->commit($this);

		$results = Array();
		$results['status'] = 'save';
		$results['sortColumn'] = $this->ESession->getSortColumn($this);
		$results['sortType'] = $this->ESession->getSortType($this);
		$results['page'] = $this->ESession->getPage($this);
		echo json_encode($results);
		exit;
	}

	function check_edit_sms_template() {
		if (empty($this->data) || empty($this->data['templateId'])) {
			echo 'systemerror';
			exit;
		}

		$info_list = $this->T300SmsTemplate->getSmsTemplateById($this->data['templateId']);
		if (!isset($info_list["T300SmsTemplate"]["id"]) || empty($info_list["T300SmsTemplate"]["id"])) {
			echo "err_not_exist";
			exit;
		}
		$action = $this->data['action'];
		$enable_edit = true;
		$msg_edit = "";
		if($action == "edit"){
			$schedule = $this->T200SmsSendSchedule->getScheduleByTemplateIdAndStatus($this->data['templateId'], Array(STATUS_SENDING, STATUS_STOPING, STATUS_STOP_SEND, STATUS_TEMP_FINISH));
			$enable_edit = empty($schedule) ? true : false;
		}		
		if(!$enable_edit){
			$status_text = $this->get_status_schedule($schedule['T200SmsSendSchedule']['status']);
			$msg_edit = '対象リストは' . $status_text . 'のスケジュールに存在する為編集できません。';
		}
		$results = Array(
			'status' => 'can_edit',
			'template_id' => $this->data['templateId'],
			'template_name' => $info_list['T300SmsTemplate']['template_name'],
			'description' => $info_list['T300SmsTemplate']['description'],
			'content' => $info_list['T300SmsTemplate']['content'],
			'sms_use_short_url' => $info_list['T300SmsTemplate']['sms_use_short_url'],
			'enable_edit' => $enable_edit,
			'msg_edit' => $msg_edit,
		);
		echo json_encode($results);
		exit;
	}

	function check_exist_template_name() {
		$data = $this->data;
		$company_id = $this->ESession->getUserCompanyId($this);
		$sms_template = $this->T300SmsTemplate->getSmsTemplateByTemplateName($data['templateName'], $company_id);
		if(isset($sms_template["T300SmsTemplate"]["id"]) && !empty($sms_template["T300SmsTemplate"]["id"])){
			if (isset($data['templateId']) && $data['templateId'] == $sms_template['T300SmsTemplate']['id']) {
				echo "true";
				exit;
			}
			echo "false";
		}else{
			echo "true";
		}
		exit;
	}

	function delete() {
		$data = $this->data;
		if (empty($data)) {
			echo 'systemerror';
			exit;
		}

		$dsT300SmsTemplate = $this->T300SmsTemplate->getDataSource();
		$dsT300SmsTemplate->begin($this);

		$update_user = $this->ESession->getUserId($this);
		$update_program = $this->name.'_'.__FUNCTION__;
		$time = date('Y-m-d H:i:s a', time());

		$sms_template_ids = $data['sms_template_ids'];

		$query1 = "UPDATE t300_sms_templates ".
			"SET del_flag='Y', update_user='$update_user', update_program='$update_program' ".
			"WHERE id IN (".implode(',', $sms_template_ids).");";
		if ($this->T300SmsTemplate->query($query1)) {
			$dsT300SmsTemplate->rollback($this);
			echo 'systemerror';
			exit;
		}

		$dsT300SmsTemplate->commit($this);

		$results = Array();
		$results['status'] = 'can_del';
		$results['sortColumn'] = $this->ESession->getSortColumn($this);
		$results['sortType'] = $this->ESession->getSortType($this);

		$company_id = $this->ESession->getUserCompanyId($this);
		$sms_template_count = $this->T300SmsTemplate->getListByCompanyIdCount($company_id);
		$max_page = round($sms_template_count / PAGE_LENGTH);
		$current_page = $this->ESession->getPage($this);
		if (($current_page == $max_page) && (count($sms_template_ids) == ($sms_template_count % PAGE_LENGTH)) && ($current_page > 0)) {
			$current_page--;
		}
		$results['page'] = $current_page;

		echo json_encode($results);
		exit;
	}

	function check_info_smstemplate() {
		$data = $this->data;
		if (empty($data)) {
			echo 'systemerror';
			exit;
		}

		$sms_template_ids = $data['sms_template_ids'];
		if (!is_array($sms_template_ids)) {
			$sms_template_ids = explode(' ', $sms_template_ids);
		}

		foreach ($sms_template_ids as $id) {
			$info_list = $this->T300SmsTemplate->getSmsTemplateById($id);
			if (!isset($info_list["T300SmsTemplate"]["id"]) || empty($info_list["T300SmsTemplate"]["id"])) {
				echo "err_not_exist";
				exit;
			}

			$schedule = $this->T200SmsSendSchedule->getScheduleNotFinishByTemplateId($id);
			if (isset($schedule["T200SmsSendSchedule"]["id"]) && !empty($schedule["T200SmsSendSchedule"]["id"])) {
				echo "err_used";
				exit;
			}
		}
		echo 'success';
		exit;
	}

	function create_lock($lock_flag = null, $lock_id = null, $function = null) {
		//T92Lock登録
		$T92Lock = array();
		$T92Lock["lock_flag"] = $lock_flag;
		$T92Lock["lock_id"] = $lock_id;
		$T92Lock["use_user_id"] = $this->ESession->getUserId($this);
		$T92Lock['session_id'] = $this->Session->id();
		$T92Lock["entry_user"] = $this->ESession->getUserId($this);
		$T92Lock["entry_program"] = $this->name.'_'.$function.'_start';

		$dsT92Lock = $this->T92Lock->getDataSource();
		$dsT92Lock->begin($this);
		$lock_new = $this->T92Lock->save($T92Lock);

		if(!$lock_new){
			$dsT92Lock->rollback($this);
			return false;
		}
		$dsT92Lock->commit($this);
		return $lock_new;
	}

	function update_lock($lock = null, $function = null) {
		//T92Lock解除
		$lock['T92Lock']["del_flag"] = "Y";
		$lock['T92Lock']["update_user"] = $this->ESession->getUserId($this);
		$lock['T92Lock']["update_program"] = $this->name.'_'.$function.'_end';

		$dsT92Lock = $this->T92Lock->getDataSource();
		$dsT92Lock->begin($this);
		if (!$this->T92Lock->save($lock)) {
			$dsT92Lock->rollback($this);
			return false;
		}
		$dsT92Lock->commit($this);
		return true;
	}
	/** Get status text of Schedule by status
	 * @param int $status
	 * @return string status text
	 * @author Hungnv
	 * @since 2016/06/08
	 */
	function get_status_schedule($status = null) {
		$status_infos = array(
				STATUS_NO_SEND => '未送信',
				STATUS_SENDING => '実行中',
				STATUS_STOP_SEND => '手動停止',
				STATUS_TEMP_FINISH => '停止',
				STATUS_FINISH => '終了',
				STATUS_STOPING => '停止中',
				STATUS_FINISHING => '終了中',
		);
	
		return $status_infos[$status];
	}
}