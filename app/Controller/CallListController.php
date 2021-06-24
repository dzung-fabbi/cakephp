<?php
App::uses('AppController', 'Controller');

class CallListController extends AppController {
	var $uses = array('M01Server', 'T10CallList', 'T11TelList', 'M99SystemParameter', 'T20OutSchedule', 'M90PulldownCode', 'T92Lock', 'T12ListItem', 'M05User', 'M08SmsApiInfo',
		'T31TemplateQuestion', 'T15OutgoingNgTel');

	const ITEM_REGEX = '/{.*?}/';
	const LEFT_BRACE_REGEX = '/{/';
	const RIGHT_BRACE_REGEX = '/}/';
	const BRACE_REGEX = '/{|}/';

	function index($mode=null, $del_count=null) {
		if ($mode != null && $mode != '') {
			$this->set('mode', $mode);
		}
		if ($mode == 'systemerror') {
			$this->set('msg_error', 'System error, please try again!');
		} else if($mode == "delete"){
			$sortColumn = $this->ESession->getSortColumn($this);
			$sortType = $this->ESession->getSortType($this);
			$page = $this->ESession->getPage($this);
			$this->set("sortColumn", $sortColumn);
			$this->set("sortType", $sortType);
			$this->set("page", $page);
			$this->set('del_count', $del_count);
		}

		//20160225 Edit by Giang : #6532 - refactor code - begin
		$max_tel_param = $this->M99SystemParameter->getByFunctionIdAndParameterId('LIST', 'MAX_TEL');
		$this->set('max_tel_param', $max_tel_param);

		$list_item_fields = $this->M90PulldownCode->getSelectOption('list_item');
		$this->set('list_item_fields', json_encode($list_item_fields));
		$headers = Array();
		foreach ($list_item_fields as $list_item) {
			$headers[$list_item['M90PulldownCode']['item_code']] = $list_item['M90PulldownCode']['item_name'];
		}
		$this->set('headers', $headers);
		//20160225 Edit by Giang : #6532 - refactor code - begin

		$enable_download = $this->M04ControllerAction->check_permission($this->post_code, 'CallList', 'download');
		$enable_create = $this->M04ControllerAction->check_permission($this->post_code, 'CallList', 'create');
		$enable_delete = $this->M04ControllerAction->check_permission($this->post_code, 'CallList', 'delete');
		$this->set('enable_download', $enable_download);
		$this->set('enable_create', $enable_create);
		$this->set('enable_delete', $enable_delete);
	}

	function buffer_csv_data() {
		$data = $this->data;
		if (empty($data)) {
			$this->redirect(array('controller' => 'CallList', 'action' => 'index'));
		}

		$data_csv = $this->ESession->getDataCsvDownload($this);
		if(isset($data_csv)){
			$this->Session->delete('data_csv_download');
		}

		$call_list_ids = $data['call_list_ids'];
		$data_csv_tmp = Array();

		foreach ($call_list_ids as $call_list_id) {
			$tel_lists = $this->T11TelList->getAllTelByCallListId($call_list_id);
			$t12_list_items = $this->T12ListItem->getTitleByListId($call_list_id);

			if ($tel_lists && !empty($t12_list_items)) {
				$headers = Array();
				foreach ($t12_list_items as $t12_list_item) {
					$headers[] = $t12_list_item['T12ListItem']['item_name'];
				}
				$data_csv_tmp[$call_list_id][] = $headers;

				foreach ($tel_lists as $tel_list) {
					$row =  Array();
					foreach ($t12_list_items as $t12_list_item) {
						$column = $t12_list_item['T12ListItem']['column'];
						array_push($row, $tel_list['T11TelList'][$column]);
					}
					$data_csv_tmp[$call_list_id][] = $row;
				}
			}
		}
		$this->ESession->setDataCsvDownload($data_csv_tmp,$this);

		echo 'success';
		exit;
	}

	function download_csv_file() {
		$data_csv = $this->ESession->getDataCsvDownload($this);
		if(!isset($data_csv)){
			$this->redirect(array('controller' => 'CallList', 'action' => 'index'));
		}

		$file_out_name = date('Ymdhis', time()) . '_発信リスト.zip';
		$file_out_name = mb_convert_encoding($file_out_name, "SJIS-win", "UTF-8");
		$this->Csv->createZip($file_out_name);

		foreach ($data_csv as $key => $data) {

			$call_list = $this->T10CallList->getListInfoById($key);
			if ($call_list) {
				foreach ($data as $row) {
					$this->Csv->addRow($row);
				}

				$title_csv = $call_list['T10CallList']['list_name'] . '.csv';
				$title_csv = mb_convert_encoding($title_csv, "SJIS-win", "UTF-8");
				$this->Csv->addToZip($title_csv, 'SJIS-win');
				$this->Csv->clear();
			}
		}
		$this->Session->delete('data_csv_download');
		echo $this->Csv->renderZip('SJIS-win');
		exit;
	}

	function delete() {
		$data = $this->data;
		if (empty($data)) {
			$this->redirect(array('controller' => 'CallList', 'action' => 'index'));
		}

		$dsT10CallList = $this->T10CallList->getDataSource();
		$dsT11TelList = $this->T11TelList->getDataSource();
		$dsT12ListItem = $this->T12ListItem->getDataSource();
		$dsT10CallList->begin($this);
		$dsT11TelList->begin($this);
		$dsT12ListItem->begin($this);

		$update_user = $this->ESession->getUserId($this);
		$update_program = $this->name.'_'.__FUNCTION__;
		$time = date('Y-m-d H:i:s a', time());

		$call_list_ids = $data['call_list_ids'];

		$query1 = "UPDATE t10_call_lists ".
			"SET del_flag='Y', update_user='$update_user', update_program='$update_program', modified='$time' ".
			"WHERE id IN (".implode(',', $call_list_ids).");";
		if ($this->T10CallList->query($query1)) {
			$dsT10CallList->rollback($this);
			$this->log("T10削除：失敗");
			$this->redirect(array('controller' => 'Login', 'action' => 'index'));
			exit;
		}

		$count_tel = $this->T11TelList->getTelByListIdsCount($call_list_ids);
		if ($count_tel > 0) {
			$query2 = "UPDATE t11_tel_lists ".
				"SET del_flag='Y', update_user='$update_user', update_program='$update_program', modified='$time' ".
				"WHERE del_flag = 'N' AND list_id IN (".implode(',', $call_list_ids).");";
			if ($this->T11TelList->query($query2)) {
				$dsT10CallList->rollback($this);
				$dsT11TelList->rollback($this);
				$this->log("T11削除：失敗");
				$this->redirect(array('controller' => 'Login', 'action' => 'index'));
				exit;
			}
		}

		$query3 = "UPDATE t12_list_items ".
			"SET del_flag='Y' ".
			"WHERE del_flag = 'N' AND list_id IN (".implode(',', $call_list_ids).");";
		if ($this->T12ListItem->query($query3)) {
			$dsT10CallList->rollback($this);
			$dsT11TelList->rollback($this);
			$dsT12ListItem->rollback($this);
			$this->log("T12削除：失敗");
			$this->redirect(array('controller' => 'Login', 'action' => 'index'));
			exit;
		}

		$dsT10CallList->commit($this);
		$dsT11TelList->commit($this);
		$dsT12ListItem->commit($this);
		$this->redirect(array('controller' => 'CallList', 'action' => 'index/delete/' . count($call_list_ids)));
	}

	function check_info_list() {
		$data = $this->data;
		if (empty($data)) {
			$this->redirect(array('controller' => 'CallList', 'action' => 'index'));
		}

		$call_list_ids = $data['call_list_ids'];
		if (!is_array($call_list_ids)) {
			$call_list_ids = explode(' ', $call_list_ids);
		}

		foreach ($call_list_ids as $id) {
			$info_list = $this->T10CallList->getListInfoById($id);
			if (!isset($info_list["T10CallList"]["id"]) || empty($info_list["T10CallList"]["id"])) {
				//リスト存在しない
				echo "err_not_exist";
				exit;
			}

			$info_schedule = $this->T20OutSchedule->getScheduleByListNo($info_list["T10CallList"]["id"]);
			foreach ($info_schedule as $schedule) {
				if (isset($schedule["T20OutSchedule"]["id"]) && $schedule["T20OutSchedule"]["status"] != STATUS_FINISH) {
					//予定されているスケジュールに存在するスクリプトの為削除できません
					echo "err_used";
					exit;
				}
			}
		}
		exit;
	}
	function check_exist_listname() {
		$data = $this->data;
		$company_id = $this->ESession->getUserCompanyId($this);
		$info_list = $this->T10CallList->getByListName($data['list_name'], $company_id);
		if(isset($info_list["T10CallList"]["id"]) && !empty($info_list["T10CallList"]["id"])){
			if (isset($data['list_name_old']) && $data['list_name_old'] == $info_list['T10CallList']['list_name']) {
				echo "true";
				exit;
			}
			echo "false";
		}else{
			echo "true";
		}
		exit;
	}

	function check_info_tel() {
		if (empty($this->data)) {
			$this->redirect(array('controller' => 'CallList', 'action' => 'index'));
		}

		$call_list_id = $this->ESession->getCallListId($this);
		$info_list = $this->T10CallList->getListInfoById($call_list_id);
		if (!isset($info_list["T10CallList"]["id"]) || empty($info_list["T10CallList"]["id"])) {
			//リスト存在しない
			echo "err_list_not_exist";
			exit;
		}
		$info_schedule = $this->T20OutSchedule->getScheduleByListNo($info_list["T10CallList"]["id"]);
		foreach ($info_schedule as $schedule) {
			if (isset($schedule["T20OutSchedule"]["id"]) && $schedule["T20OutSchedule"]["status"] == STATUS_CALLING) {
				echo "err_calling";
				exit;
			} else if (isset($schedule["T20OutSchedule"]["id"]) && ($schedule["T20OutSchedule"]["status"] != STATUS_FINISH) && ($schedule["T20OutSchedule"]["status"] != STATUS_NO_CALL)) {
				//予定されているスケジュールに存在するスクリプトの為削除できません
				echo "err_used";
				exit;
			}
		}

		if (isset($this->data['action']) && ($this->data['action'] == 'add')) {
			$max_tel_param = $this->M99SystemParameter->getByFunctionIdAndParameterId('LIST', 'MAX_TEL');
			if ($info_list['T10CallList']['tel_total'] >= $max_tel_param['M99SystemParameter']['parameter_value']) {
				echo "err_limit_max_tel";
				exit;
			}
			echo 'success';
			exit;
		}

		$tel_list_ids = $this->data['tel_list_ids'];

		if (!is_array($tel_list_ids)) {
			$tel_list_ids = explode(' ', $tel_list_ids);
		}
		foreach ($tel_list_ids as $id) {
			$info_tel = $this->T11TelList->getTelInfoById($id);
			if(empty($info_tel)){
				echo "err_tel_not_exist";
				exit;
			}
		}
		echo 'success';
		exit;
	}

	function arr_list($js_page, $limit, $column) {
		$this->layout = 'ajax';
		$filter = $_GET["filter"];
		$page = $js_page + 1;
		$json_data = Array();
		$json_data["headers"] = Array("NO","リスト名","件数","作成日時","作成者","アクション",);
		$json_data["rows"] = Array();
		$company_id = $this->ESession->getUserCompanyId($this);

		$enable_download = $this->M04ControllerAction->check_permission($this->post_code, 'CallList', 'download');
		$enable_create = $this->M04ControllerAction->check_permission($this->post_code, 'CallList', 'create');
		$enable_delete = $this->M04ControllerAction->check_permission($this->post_code, 'CallList', 'delete');

		if ($enable_delete || $enable_download) {
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
			$sort_order = $this->Util->getListSortOrder($column,$enable_delete || $enable_download ? 1 : 0);
		}

		$sort_order_col = isset($sort_order[0]) ? $sort_order[0] : null;
		$arr_lists = $this->T10CallList->getListByCompanyId($company_id, $limit, $page, $sort_order_col, $filter);

		$json_data["total_rows"] = $this->T10CallList->getListByCompanyIdCount($company_id, $filter);
		foreach ($arr_lists as $arr_list) {
			$json_row = array();
			$entry_user = $this->M05User->getUserByUserId($arr_list['T10CallList']['entry_user']);
			$entry_user_name = isset($entry_user["M05User"]['user_name']) ? $entry_user["M05User"]['user_name'] : ''; //20160224 Add by Giang : #6531 - show list create by the user deleted
			if ($enable_delete || $enable_download) {
				$json_row['checkbox'] = '<input type="checkbox" name="call_list_ids[' . $arr_list['T10CallList']['id'] . ']" id="cbSelect[' . $arr_list['T10CallList']['id'] . ']" value="' . $arr_list['T10CallList']['id'] . '" onclick="updateCheckStatus(\'bundleCheckbox\');">'
					. '<label for="cbSelect[' . $arr_list['T10CallList']['id'] . ']" style="margin-top: 2px;"></label>';
			}
			$json_row['NO'] = str_replace($company_id, '', $arr_list['T10CallList']['list_no']);
			$json_row['リスト名'] = $arr_list['T10CallList']['list_test_flag'] == 1 ? "<font color='red'>(テスト)".$arr_list['T10CallList']['list_name']."</font>" : $arr_list['T10CallList']['list_name'];
			$json_row['件数'] = $arr_list['T10CallList']['tel_total'].'件';
			$json_row['作成日時'] = date('Y-m-d H:i', strtotime($arr_list['T10CallList']['created']));
			$json_row['作成者'] = $entry_user_name;
			$json_row['アクション'] = '<a href="javascript:void(0);" title="編集" data-toggle="tooltip" class="iconCenterFormat ajax-link lnkDetail" call_list_id="'.$arr_list['T10CallList']['id'].'"><i class="glyphicon glyphicon-edit icon-white" ></i></a>';
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

	function upload_file() {
		setlocale(LC_ALL, 'ja_JP.UTF-8');
		if (empty($this->data) || empty($this->data['listName']) || empty($this->data['uploadData']) || empty($this->data['fieldImport']) || empty($this->data['listItemData'])) {
			echo 'systemerror';
			exit;
		}

		$company_id = $this->ESession->getUserCompanyId($this);
		$max_list_no = $this->T10CallList->getMaxListNoByCompanyId($company_id);

		if ($max_list_no['0']['max_list_no']) {
			$list_no_new = $max_list_no['0']['max_list_no'] + 1;
		} else {
			$list_no_new = '1';
		}

		$check_lock = $this->T92Lock->getInfoLock('call_list', $list_no_new);
		if (!empty($check_lock)) {
			echo 'systemerror';
			exit;
		}

		$lock_new = $this->create_lock('call_list', $list_no_new, __FUNCTION__);
		if (!$lock_new) {
			echo 'systemerror';
			exit;
		}

		$list_name = $this->data['listName'];
		$uploadData = json_decode($this->data['uploadData']);
		$fieldImport = $this->data['fieldImport'];
		if ($this->data['listTestFlag'] == 'true') {
			$list_test_flag = 1;
		} else {
			$list_test_flag = 0;
		}

		//Save data to DB
		$dsT10CallList = $this->T10CallList->getDataSource();
		$dsT11TelList = $this->T11TelList->getDataSource();
		$dsT12ListItem = $this->T12ListItem->getDataSource();

		$dsT10CallList->begin($this);
		$dsT11TelList->begin($this);
		$dsT12ListItem->begin($this);

		$time = date('Y-m-d H:i:s a', time());

		$this->T10CallList->create();
		$data_call_list['T10CallList']['company_id'] = $company_id;
		$data_call_list['T10CallList']['list_no'] = $list_no_new;
		$data_call_list['T10CallList']['list_name'] = $list_name;
		$data_call_list['T10CallList']['list_test_flag'] = $list_test_flag;
		$data_call_list['T10CallList']['tel_total'] = count($uploadData);
		$data_call_list['T10CallList']['entry_user'] = $this->ESession->getUserId($this);
		$data_call_list['T10CallList']['entry_program'] = $this->name.'_'.__FUNCTION__;
		$call_list = $this->T10CallList->save($data_call_list);

		if(!$call_list){
			$this->update_lock($lock_new, __FUNCTION__);
			$dsT10CallList->rollback($this);
			$dsT11TelList->rollback($this);
			$this->log("発信規制番号登録：失敗");
			echo 'systemerror';
			exit;
		}

		$call_list_id = $call_list['T10CallList']['id'];
		$entry_user = $this->ESession->getUserId($this);
		$entry_program = $this->name.'_'.__FUNCTION__;

		$query_base = "INSERT INTO t11_tel_lists ".
			"(list_id, tel_no, entry_user, entry_program, created, customize1, customize2, customize3, customize4, customize5, customize6, customize7, customize8, customize9, customize10, customize11) " .
			"VALUES ";
		$query = $query_base;
		$count = 0;

		for ($i = 0; $i < count($uploadData); $i++) {
			$count ++;
			$cus1 = (isset($fieldImport[0]) && isset($uploadData[$i][$fieldImport[0]])) ? $uploadData[$i][$fieldImport[0]] : NULL;
			$cus2 = (isset($fieldImport[1]) && isset($uploadData[$i][$fieldImport[1]])) ? $uploadData[$i][$fieldImport[1]] : NULL;
			$cus3 = (isset($fieldImport[2]) && isset($uploadData[$i][$fieldImport[2]])) ? $uploadData[$i][$fieldImport[2]] : NULL;
			$cus4 = (isset($fieldImport[3]) && isset($uploadData[$i][$fieldImport[3]])) ? $uploadData[$i][$fieldImport[3]] : NULL;
			$cus5 = (isset($fieldImport[4]) && isset($uploadData[$i][$fieldImport[4]])) ? $uploadData[$i][$fieldImport[4]] : NULL;
			$cus6 = (isset($fieldImport[5]) && isset($uploadData[$i][$fieldImport[5]])) ? $uploadData[$i][$fieldImport[5]] : NULL;
			$cus7 = (isset($fieldImport[6]) && isset($uploadData[$i][$fieldImport[6]])) ? $uploadData[$i][$fieldImport[6]] : NULL;
			$cus8 = (isset($fieldImport[7]) && isset($uploadData[$i][$fieldImport[7]])) ? $uploadData[$i][$fieldImport[7]] : NULL;
			$cus9 = (isset($fieldImport[8]) && isset($uploadData[$i][$fieldImport[8]])) ? $uploadData[$i][$fieldImport[8]] : NULL;
			$cus10 = (isset($fieldImport[9]) && isset($uploadData[$i][$fieldImport[9]])) ? $uploadData[$i][$fieldImport[9]] : NULL;
			$cus11 = (isset($fieldImport[10]) && isset($uploadData[$i][$fieldImport[10]])) ? $uploadData[$i][$fieldImport[10]] : NULL;

			if($count % 10000 == 0 || $count == count($uploadData)){
				$query = $query."('".$call_list_id."','".$count."','".$entry_user."','".$entry_program."','".$time."','".
					$cus1."','".$cus2."','".$cus3."','".$cus4."','".$cus5."','".$cus6."','".$cus7."','".$cus8."','".$cus9."','".$cus10."','".$cus11."');";
				if ($this->T11TelList->query($query)) {
					$this->update_lock($lock_new, __FUNCTION__);
					$dsT10CallList->rollback($this);
					$dsT11TelList->rollback($this);
					$this->log("T11削除：失敗");
					echo 'systemerror';
					exit;
				}
				$query = $query_base;
			}else{
				$query = $query."('".$call_list_id."','".$count."','".$entry_user."','".$entry_program."','".$time."','".
					$cus1."','".$cus2."','".$cus3."','".$cus4."','".$cus5."','".$cus6."','".$cus7."','".$cus8."','".$cus9."','".$cus10."','".$cus11."'), ";
			}
		}

		$listItemData = $this->data['listItemData'];
		$t12_query_base = "INSERT INTO t12_list_items ".
			"(company_id, list_id, order_num, item_name, item_code, `column`, del_flag, entry_user, entry_program, created) " .
			"VALUES ";
		$t12_query = $t12_query_base;
		$order_num = 0;


		$item_codes = array();
		$list_item_tmps = $this->M90PulldownCode->getSelectOption('list_item');
		foreach ($list_item_tmps as $item) {
			$item_codes[$item['M90PulldownCode']['item_name']] = $item['M90PulldownCode']['item_code'];
		}
		foreach ($listItemData as $column => $item_name) {
			$order_num ++;
			$item_code = isset($item_codes[$item_name]) ? $item_codes[$item_name] : '';

			if($order_num == count($listItemData)){
				$t12_query = $t12_query."('".$company_id."','".$call_list_id."','".$order_num."','".$item_name."','".$item_code."','customize".$column."','N','".$entry_user."','".$entry_program."','".date('Y-m-d H:i:s a', time())."');";
				if ($this->T12ListItem->query($t12_query)) {
					$this->update_lock($lock_new, __FUNCTION__);
					$dsT10CallList->rollback($this);
					$dsT11TelList->rollback($this);
					$dsT12ListItem->rollback($this);
					$this->log("T12削除：失敗");
					echo 'systemerror';
					exit;
				}
				$t12_query = $t12_query_base;
			}else{
				$t12_query = $t12_query."('".$company_id."','".$call_list_id."','".$order_num."','".$item_name."','".$item_code."','customize".$column."','N','".$entry_user."','".$entry_program."','".date('Y-m-d H:i:s a', time())."'), ";
			}
		}
		if (isset($lock_new) && !empty($lock_new) && !$this->update_lock($lock_new, __FUNCTION__)) {
			$dsT10CallList->rollback($this);
			$dsT11TelList->rollback($this);
			$dsT12ListItem->rollback($this);
			echo 'systemerror';
			exit;
		}

		$dsT10CallList->commit($this);
		$dsT11TelList->commit($this);
		$dsT12ListItem->commit($this);
		echo 'save';
		exit;
	}

	function detail() {
		$data = $this->data;
		if (!empty($data['edit_call_list_id'])) {
			//set session list_id
			$this->ESession->setCallListId($data['edit_call_list_id'],$this);
			$list = $this->T10CallList->getListInfoById($data['edit_call_list_id']);
			$t12_list_items = $this->T12ListItem->getTitleByListId($data['edit_call_list_id']);
			$headers = Array();
			foreach ($t12_list_items as $t12_list_item) {
				$headers[$t12_list_item['T12ListItem']['column']] = $t12_list_item['T12ListItem']['item_name'];
			}

			$schedule = $this->T20OutSchedule->getScheduleByListNo($data['edit_call_list_id'], Array(STATUS_CALLING, STATUS_STOPING, STATUS_FINISHING, STATUS_STOP_CALL, STATUS_TEMP_FINISH, STATUS_REDIAL_WAIT));
			$enable_create_edit_delete = empty($schedule) ? true : false;
			if (!$enable_create_edit_delete) {
				$this->Session->setFlash('対象リストは実行中のスケジュールに存在する為新規登録・削除・編集できません。', 'default', array('class' => 'flash_msg error'));
			}

			$enable_edit_call_list = $this->M04ControllerAction->check_permission($this->post_code, 'CallList', 'edit') && $enable_create_edit_delete;
			$enable_create = $this->M04ControllerAction->check_permission($this->post_code, 'DetailCallList', 'create') && $enable_create_edit_delete;
			$enable_delete = $this->M04ControllerAction->check_permission($this->post_code, 'DetailCallList', 'delete') && $enable_create_edit_delete;
			$enable_edit = $this->M04ControllerAction->check_permission($this->post_code, 'DetailCallList', 'edit') && $enable_create_edit_delete;
			$enable_report_not_effective = $this->M04ControllerAction->check_permission($this->post_code, 'DetailCallList', 'report_not_effective');

			$this->set("list", $list);
			$this->set("t12_list_items", $t12_list_items);
			$this->set("headers", $headers);
			$this->set('enable_edit_call_list', $enable_edit_call_list);
			$this->set('enable_create', $enable_create);
			$this->set('enable_delete', $enable_delete);
			$this->set('enable_edit', $enable_edit);
			$this->set('enable_report_not_effective', $enable_report_not_effective);
		}else{
			$this->redirect(array('controller' => 'CallList', 'action' => 'index'));
		}
	}

	function tel_list($js_page, $limit, $column) {
		$this->layout = 'ajax';
		$filter = $_GET["filter"];
		$page = $js_page + 1;
		$json_data = Array();

		$call_list_id = $this->ESession->getCallListId($this);
		$t12_list_items = $this->T12ListItem->getTitleByListId($call_list_id);

		$headers = Array("dummy_gs_id_string");
		foreach ($t12_list_items as $t12_list_item) {
			$headers[] = $t12_list_item['T12ListItem']['item_name'];
		}
		$headers[] = '無効';
		$json_data["rows"] = Array();

		//$schedule = $this->T20OutSchedule->getScheduleByListNo($call_list_id, Array(STATUS_CALLING, STATUS_STOPING, STATUS_FINISHING));
		$schedule = $this->T20OutSchedule->getScheduleByListNo($call_list_id, Array(STATUS_CALLING, STATUS_STOPING, STATUS_FINISHING, STATUS_STOP_CALL, STATUS_TEMP_FINISH, STATUS_REDIAL_WAIT));
		$enable_create_edit_delete = empty($schedule) ? true : false;

		$enable_edit = $this->M04ControllerAction->check_permission($this->post_code, 'DetailCallList', 'edit') && $enable_create_edit_delete;
		$enable_delete = $this->M04ControllerAction->check_permission($this->post_code, 'DetailCallList', 'delete') && $enable_create_edit_delete;
		$enable_report_not_effective = $this->M04ControllerAction->check_permission($this->post_code, 'DetailCallList', 'report_not_effective');

		if ($enable_delete) {
			array_unshift($headers, 'selectItem');
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
			$sort_order = $this->Util->getTelListSortOrder($column, $t12_list_items, $enable_delete ? 1 : 0);
		}

		$sort_order_col = isset($sort_order[0]) ? $sort_order[0] : null;
		$tel_lists = $this->T11TelList->getTelByCallListId($call_list_id, $limit, $page, $sort_order_col, $filter, $t12_list_items);
		$json_data["total_rows"] = $this->T11TelList->getListByCallListIdCount($call_list_id, $filter, $t12_list_items);

		if ($enable_edit) {
			$headers[] = 'アクション';
		}

		//$is_disable = $enable_report_not_effective ? '' : 'disabled';

		foreach ($tel_lists as $arr_list) {
			if (!$enable_report_not_effective || (!$enable_create_edit_delete && $arr_list['T11TelList']['muko_flag'] == 'Y')) {
				$is_disable = 'disabled';
			} else {
				$is_disable = '';
			}

			$muko_flag = ($arr_list['T11TelList']['muko_flag'] == 'Y')?'checked':'';
			$json_row = array();
			if ($enable_delete) {
				$json_row['selectItem'] = '<input class="select_item" type="checkbox" name="cbSelect[' . $arr_list['T11TelList']['id'] . ']" id="cbSelect[' . $arr_list['T11TelList']['id'] . ']" value="' . $arr_list['T11TelList']['id'] . '" onclick="updateCheckStatus(\'bundleCheckbox\');">'
					. '<label class="label_select_item" for="cbSelect[' . $arr_list['T11TelList']['id'] . ']" style="margin-top: 2px;"></label>';
			}
			$json_row['dummy_gs_id_string'] = $arr_list['T11TelList']['tel_no'];
			foreach ($t12_list_items as $t12_list_item) {
				$key = $t12_list_item['T12ListItem']['item_name'];

				if (isset($t12_list_item['T12ListItem']['item_code']) && ($t12_list_item['T12ListItem']['item_code'] == 'birthday')) {
					$json_row[$key] = $this->displayDate($arr_list['T11TelList'][$t12_list_item['T12ListItem']['column']]);
				} else {
					$json_row[$key] = isset($arr_list['T11TelList'][$t12_list_item['T12ListItem']['column']]) ? $arr_list['T11TelList'][$t12_list_item['T12ListItem']['column']] : '';
				}
			}

			$json_row['無効'] = '<input class="inefficient '.$is_disable.'" type="checkbox" name="noEffect[' . $arr_list['T11TelList']['id'] . ']" id="noEffect[' . $arr_list['T11TelList']['id'] . ']" tel_list_id="' . $arr_list['T11TelList']['id'] . '"' . $muko_flag . ' ' . $is_disable . '>'
				. '<label for="noEffect[' . $arr_list['T11TelList']['id'] . ']" style="margin-top: 2px;"></label>';
			if ($enable_edit) {
				$json_row['アクション'] = '<a href="javascript:void(0);" class="iconCenterFormat ajax-link lnkEdit" tel_list_id="'.$arr_list['T11TelList']['id'].'"><i title="編集" data-toggle="tooltip" class="glyphicon glyphicon-edit icon-white" ></i></a>';

			}
			$json_data["rows"][] = (object) $json_row;
		}
		$json_data["headers"] = $headers;
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

	function displayDate($date = null) {
		$date = preg_replace("/\D/", "", $date);
		if (strlen($date) != 8) {
			$this->log($date);
			return '';
		}

		$date_tmp = substr($date, 0, 4) . '-' . substr($date, 4, 2) . '-' . substr($date, 6, 2);
		return $date_tmp;
	}

	function update_tel_list_name() {
		$enable_edit_call_list = $this->M04ControllerAction->check_permission($this->post_code, 'CallList', 'edit');
		if (empty($this->data) || empty($this->data['callListId']) || empty($this->data['listName']) || !$enable_edit_call_list) {
			echo 'systemerror';
			exit;
		}

		$check_lock = $this->T92Lock->getInfoLock('call_list', $this->ESession->getCallListId($this));
		if (!empty($check_lock)) {
			echo 'systemerror';
			exit;
		}

		$lock_new = $this->create_lock('call_list', $this->ESession->getCallListId($this), __FUNCTION__);
		if (!$lock_new) {
			echo 'systemerror';
			exit;
		}

		$list_name = $this->data['listName'];
		$call_list_id = $this->data['callListId'];
		if ($this->data['listTestFlag'] == 'true') {
			$list_test_flag = 1;
		} else {
			$list_test_flag = 0;
		}

		//Save data to DB
		$dsT10CallList = $this->T10CallList->getDataSource();
		$dsT10CallList->begin($this);

		$data_call_list['T10CallList']['id'] = $call_list_id;
		$data_call_list['T10CallList']['list_name'] = $list_name;
		$data_call_list['T10CallList']['list_test_flag'] = $list_test_flag;
		$data_call_list['T10CallList']['update_user'] = $this->ESession->getUserId($this);
		$data_call_list['T10CallList']['update_program'] = $this->name.'_'.__FUNCTION__;

		$call_list = $this->T10CallList->save($data_call_list['T10CallList']);

		if(!$call_list || (isset($lock_new) && !empty($lock_new) && !$this->update_lock($lock_new, __FUNCTION__))){
			$dsT10CallList->rollback($this);
			$this->log("発信規制番号登録：失敗");
			echo 'systemerror';
			exit;
		}

		$dsT10CallList->commit($this);
		echo 'save';
		exit;
	}

	function delete_tel() {
		if (empty($this->data) || empty($this->data['tel_list_ids']) || empty($this->data['call_list_id'])) {
			echo 'systemerror';
			exit;
		}
		$tel_list_ids = $this->data['tel_list_ids'];
		$call_list_id = $this->data['call_list_id'];

		$dsT11TelList = $this->T11TelList->getDataSource();
		$dsT11TelList->begin($this);

		$update_user = $this->ESession->getUserId($this);
		$update_program = $this->name.'_'.__FUNCTION__;

		$query = "UPDATE t11_tel_lists ".
			"SET del_flag='Y', update_user='$update_user', update_program='$update_program'".
			"WHERE id IN (".implode(',', $tel_list_ids).");";
		if ($this->T11TelList->query($query)) {
			$dsT11TelList->rollback($this);
			$this->log("T11削除：失敗");
			echo 'systemerror';
			exit;
		}

		$dsT11TelList->commit($this);

		// $batch_result = $this->batch_edit_calllist();
		$arr_schedule = $this->T20OutSchedule->getScheduleByListNo($call_list_id, STATUS_NO_CALL);
		$batch_result = 'success';
		foreach ($arr_schedule as $arr){
			$schedule_id = $arr["T20OutSchedule"]["id"];
			$template_id = $arr["T20OutSchedule"]["template_id"];
			$external_number = $arr["T20OutSchedule"]["external_number"];
			$arr_server_info = $this->M01Server->getServerByExternalNumber($external_number, "1");
			$server_id = $arr_server_info["M01Server"]["server_id"];
			$server_ip = $arr_server_info["M01Server"]["server_ip"];
			$local_path  = $arr_server_info["M01Server"]["local_path"];
			$batch_result = $this->batch_edit_calllist($server_id, $server_ip, $local_path, $schedule_id, $template_id, $call_list_id, "");
		}
		if ($batch_result != 'success') {
			$this->recover_del_flag_tel($tel_list_ids, 'N');
			echo 'systemerror';
			exit;
		} else {
			$call_list = $this->T10CallList->getListInfoById($call_list_id);
			$tel_total = $call_list['T10CallList']['tel_total'];
			$tel_total_new = (int)$tel_total - count($tel_list_ids);
			if (!$this->update_tel_total_call_list($call_list_id, $tel_total_new, $update_program)) {
				echo 'systemerror';
				exit;
			}
		}

		$results = Array();
		$results['status'] = 'del_tel_list_only';
		$results['sortColumn'] = $this->ESession->getSortColumn($this);
		$results['sortType'] = $this->ESession->getSortType($this);

		$max_page = round($tel_total / PAGE_LENGTH);
		$current_page = $this->ESession->getPage($this);
		if (($current_page == $max_page) && (count($tel_list_ids) == ($tel_total % PAGE_LENGTH))) {
			$current_page--;
		}
		$results['page'] = $current_page;

		echo json_encode($results);
		exit;
	}

	function add_and_edit_tel() {
		if (empty($this->data)) {
			echo 'systemerror';
			exit;
		}
		$data = $this->data['data_tel'];
		$call_list_id = $this->ESession->getCallListId($this);
		$tel_id = $data['id'];
		$results = Array();
		$arr_schedule = $this->T20OutSchedule->getScheduleByListNo($call_list_id, STATUS_NO_CALL);

		foreach ($arr_schedule as $arr){
			$tel_info = array();
			foreach ($data as $field => $value) {
				if (!empty($field)) {
					$tel_info['T11TelList'][$field] = $value;
				}
			}
			$check_message = $this->check_sms_content_length($arr["T20OutSchedule"], $tel_info);
			if($check_message){
				echo $check_message;
				exit;
			}
		}
		//Save data to DB
		$dsT11TelList = $this->T11TelList->getDataSource();
		$dsT11TelList->begin($this);

		$function_name = $this->name.'_'.__FUNCTION__;
		if (empty($tel_id)) {

			$max_tel_no = $this->T11TelList->getMaxTelNoByCallListId($call_list_id);
			$data_tel['T11TelList']['tel_no'] = $max_tel_no[0]['max_tel_no'] + 1;
			$data_tel['T11TelList']['entry_user'] = $this->ESession->getUserId($this);
			$data_tel['T11TelList']['entry_program'] = $this->name.'_'.__FUNCTION__;

			foreach ($data as $field => $value) {
				if (!empty($field)) {
					$data_tel['T11TelList'][$field] = $value;
				}
			}
			$data_tel['T11TelList']['list_id'] = $call_list_id;
			$tel_list = $this->T11TelList->save($data_tel);
			if(!$tel_list){
				$dsT11TelList->rollback($this);
				$this->log("発信規制番号登録：失敗");
				echo 'systemerror';
				exit;
			}
			$dsT11TelList->commit($this);
			$results['status'] = 'insert';
		} else {
			$check_lock = $this->T92Lock->getInfoLock('t11_tel_list', $tel_id);
			if (!empty($check_lock)) {
				echo 'systemerror';
				exit;
			}
			$lock_new = $this->create_lock('t11_tel_list', $tel_id, __FUNCTION__);
			if (!$lock_new) {
				echo 'systemerror';
				exit;
			}
			$tel_list_backup = $this->T11TelList->getTelInfoById($tel_id);
			$data_tel['T11TelList']['update_user'] = $this->ESession->getUserId($this);
			$data_tel['T11TelList']['update_program'] = $function_name;
			foreach ($data as $field => $value) {
				if (!empty($field)) {
					$data_tel['T11TelList'][$field] = $value;
				}
			}
			$data_tel['T11TelList']['list_id'] = $call_list_id;
			$tel_list = $this->T11TelList->save($data_tel);
			if(!$tel_list || (isset($lock_new) && !empty($lock_new) && !$this->update_lock($lock_new, __FUNCTION__))){
				$dsT11TelList->rollback($this);
				$this->log("発信規制番号登録：失敗");
				echo 'systemerror';
				exit;
			}
			$dsT11TelList->commit($this);
			$results['status'] = 'update';
		}

		// $batch_result = $this->batch_edit_calllist();
		
		$batch_result = 'success';
		foreach ($arr_schedule as $arr){
			$info_column = $this->T12ListItem->getTelNumColumn($call_list_id);
			$tel_column = $info_column["T12ListItem"]["column"];
			$tel_no = $data[$tel_column];
			$schedule_id = $arr["T20OutSchedule"]["id"];
			$template_id = $arr["T20OutSchedule"]["template_id"];
			$external_number = $arr["T20OutSchedule"]["external_number"];
			$arr_server_info = $this->M01Server->getServerByExternalNumber($external_number, "1");
			$server_id = $arr_server_info["M01Server"]["server_id"];
			$server_ip = $arr_server_info["M01Server"]["server_ip"];
			$local_path  = $arr_server_info["M01Server"]["local_path"];
			$batch_result = $this->batch_edit_calllist($server_id, $server_ip, $local_path, $schedule_id, $template_id, $call_list_id, $tel_no);
		}
		if ($batch_result != 'success') {
			if($results['status'] == 'insert'){
				$tel_list_ids = Array($tel_list['T11TelList']['id']);
				$this->recover_del_flag_tel($tel_list_ids, 'Y');
				echo 'systemerror';
				exit;
			}
			if($results['status'] == 'update'){
				//$tel_list_backup
				$this->recover_tel_info($tel_list_backup);
				echo 'systemerror';
				exit;
			}
		} else {
			if($results['status'] == 'insert'){
				$call_list = $this->T10CallList->getListInfoById($call_list_id);
				$tel_total = $call_list['T10CallList']['tel_total'] + 1;
				if (!$this->update_tel_total_call_list($call_list_id, $tel_total, $function_name)) {
					echo 'systemerror';
					exit;
				}
			}
		}

		$results['sortColumn'] = $this->ESession->getSortColumn($this);
		$results['sortType'] = $this->ESession->getSortType($this);
		$results['page'] = $this->ESession->getPage($this);
		echo json_encode($results);
		exit;
	}

	function inefficient_tel() {
		$enable_report_not_effective = $this->M04ControllerAction->check_permission($this->post_code, 'DetailCallList', 'report_not_effective');
		if (empty($this->data) || empty($this->data['tel_list_ids']) || !$enable_report_not_effective) {
			$results = array(
				'status' => 'systemerror'
			);
			echo json_encode($results);
			exit;
		}
		$arr_list_backup = array();
		$arr_tel_muko = array();
		$tel_str = "";
		$tel_list_ids = $this->data['tel_list_ids'];
		$list_id = $this->data['list_id'];
		$info_column = $this->T12ListItem->getTelNumColumn($list_id);
		$tel_column = $info_column["T12ListItem"]["column"];
		$dsT11TelList = $this->T11TelList->getDataSource();
		$dsT11TelList->begin($this);

		$time = date('Y-m-d H:i:s', time());
		foreach ($tel_list_ids as $tel_list_id => $muko_flag) {
			$arr_list = $this->T11TelList->findById($tel_list_id);
			$tel_no = $arr_list["T11TelList"][$tel_column];
			if($muko_flag == "Y"){
				array_push($arr_tel_muko, $tel_no);
			}
			array_push($arr_list_backup, $arr_list);
			$arr_list['T11TelList']['muko_flag'] = $muko_flag;
			$arr_list['T11TelList']['muko_modified'] = $time;
			$arr_list['T11TelList']['modified'] = $time;
			$arr_list['T11TelList']['update_user'] = $this->ESession->getUserId($this);
			$arr_list['T11TelList']['update_program'] = $this->name.'_'.__FUNCTION__;
			$this->T11TelList->create();
			if (!$this->T11TelList->save($arr_list)) {
				$dsT11TelList->rollback($this);
				$this->log("T11削除：失敗");
				$results = array(
					'status' => 'systemerror'
				);
				echo json_encode($results);
				exit;
			}
		}
		$arr_schedule = $this->T20OutSchedule->getScheduleByListNo($list_id, STATUS_CALLING);
		$batch_result = 'success';
		foreach ($arr_tel_muko as $tel){
			if(empty($tel_str)){
				$tel_str = $tel;
			}else{
				$tel_str = $tel_str.",".$tel;
			}
		}
		if(count($arr_tel_muko) > 0){
			foreach ($arr_schedule as $arr){
				$schedule_id = $arr["T20OutSchedule"]["id"];
				$template_id = $arr["T20OutSchedule"]["template_id"];
				$external_number = $arr["T20OutSchedule"]["external_number"];
				$arr_server_info = $this->M01Server->getServerByExternalNumber($external_number, SERVER_OUTBOUND);
				$server_id = $arr_server_info["M01Server"]["server_id"];
				$server_ip = $arr_server_info["M01Server"]["server_ip"];
				$local_path  = $arr_server_info["M01Server"]["local_path"];
				$cmd = "/usr/local/bin/ruby ".$local_path."mega_prohibit.rb ".$server_id." ".$schedule_id." ".$tel_str;
				exec($cmd, $shell_result, $shell_result_status);
				if($shell_result_status != 0){
					$batch_result = $shell_result[0];
					$this->log($shell_result);
					$this->log("BATCHでリアルタイム無効反映：失敗");
					break;
				}
			}
		}

		/* if ($batch_result != 'success') {
			$results = array(
				'status' => 'systemerror'
			);
			echo json_encode($results);
			exit;
		}else{
			$dsT11TelList->commit($this);
			$schedule = $this->T20OutSchedule->getScheduleByListNo($list_id, Array(STATUS_CALLING, STATUS_STOPING, STATUS_FINISHING, STATUS_STOP_CALL, STATUS_TEMP_FINISH, STATUS_REDIAL_WAIT));
			$using_flag = empty($schedule) ? 0 : 1;
			$results = array(
				'status' => 'update_muko',
				'using_flag' => $using_flag
			);
			echo json_encode($results);
			exit;
		} */
		$rs_status  = "update_muko";
		if ($batch_result != 'success') {
			$rs_status  = "existed_ch_stopped";
		}
		$dsT11TelList->commit($this);
		$schedule = $this->T20OutSchedule->getScheduleByListNo($list_id, Array(STATUS_CALLING, STATUS_STOPING, STATUS_FINISHING, STATUS_STOP_CALL, STATUS_TEMP_FINISH, STATUS_REDIAL_WAIT));
		$using_flag = empty($schedule) ? 0 : 1;
		$results = array(
				'status' => $rs_status,
				'using_flag' => $using_flag
		);
		echo json_encode($results);
		exit;
	}

	function check_exist_tel_no() {
		$data = $this->data;
		$call_list_id = $this->ESession->getCallListId($this);
		$tel_number = preg_replace("/\D/", "", $data['tel_number']); //20160224 Add by Giang : #6473 - remove the sign isn't number before insert tel number
		$tel_list = $this->T11TelList->getByTelNoAndCallListId($tel_number, $data['tel_number_col'], $call_list_id); //20160224 Edit by Giang : #6473 - remove the sign isn't number before insert tel number

		if(isset($tel_list['T11TelList'])){
			if (!empty($data['tel_list_id']) && $data['tel_list_id'] == $tel_list['T11TelList']['id']) {
				echo "true";
				exit;
			}
			echo "false";
		} else {
			echo "true";
		}
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
		$lock['T92Lock']["update_program"] = $this->name.'_'.$function.'_done';

		$dsT92Lock = $this->T92Lock->getDataSource();
		$dsT92Lock->begin($this);
		if (!$this->T92Lock->save($lock)) {
			$dsT92Lock->rollback($this);
			return false;
		}
		$dsT92Lock->commit($this);
		return true;
	}

	function batch_edit_calllist($server_id, $server_ip, $local_path, $schedule_id, $template_id, $list_id, $tel_no){
		$schedule_no = substr("000000", strlen($schedule_id)) . $schedule_id;
		//バッチ実行
		$message = "success";
		//dialファイル作成
		if($shell_result_status == 0){
			$cmd = "/usr/local/bin/ruby ".$local_path."create_file_dial.rb ".$schedule_no." ".$schedule_id." ".$list_id;
			$this->log($cmd);
			exec($cmd, $shell_result, $shell_result_status);
			//dialファイル作成失敗場合
			if($shell_result_status != 0){
				$message = $shell_result[0];
				$this->log($shell_result);
				$this->log("BATCHでdialファイル作成：失敗");
			}
		}
		//dialファイル転送
		if($shell_result_status == 0){
			$cmd = "/usr/local/bin/ruby ".$local_path."send_folder_edit_calllist.rb ".$server_id." ".$schedule_no." ".$schedule_id." ".$template_id." ".$list_id." ".$tel_no;
			exec($cmd, $shell_result, $shell_result_status);
			$this->log($cmd);
			//dialファイル転送失敗場合
			if($shell_result_status != 0){
				$message = $shell_result[0];
				$this->log($shell_result);
				$this->log("BATCHでファイル転送：失敗");
			}
		}
		//実行コマンド
		if($shell_result_status == 0){
			$cmd = "/usr/local/bin/ruby ".$local_path."mega_command.rb ".$server_ip." ".$schedule_no." edit_calllist";
			exec($cmd, $shell_result, $shell_result_status);
			if($shell_result_status != 0){
				$cmd = "/usr/local/bin/ruby ".$local_path."rollback_edit_calllist.rb ".$server_id." ".$schedule_no;
				exec($cmd, $shell_result, $shell_result_status);
				$message = $shell_result[0];
				$this->log($shell_result);
				$this->log("BATCHですぐ発信：失敗");
			}
		}
		if($shell_result_status == 0){
			$cmd = "/usr/local/bin/ruby ".$local_path."del_edit_calllist_backup.rb ".$external_number." ".$schedule_id;
			exec($cmd, $shell_result, $shell_result_status);
		}
		return $message;
	}

	function update_tel_total_call_list($call_list_id = null, $tel_total = null, $function = null) {
		$dsT10CallList = $this->T10CallList->getDataSource();
		$dsT10CallList->begin($this);

		$call_list['T10CallList']['id'] = $call_list_id;
		$call_list['T10CallList']['update_user'] = $this->ESession->getUserId($this);
		$call_list['T10CallList']['update_program'] = $function;
		$call_list['T10CallList']['tel_total'] = $tel_total;

		if (!$this->T10CallList->save($call_list)) {
			$dsT10CallList->rollback($this);
			$this->log("T10削除：失敗");
			return false;
		}

		$dsT10CallList->commit($this);
		return true;
	}

	function recover_del_flag_tel($tel_list_ids = null, $del_flag = null) {
		$dsT11TelList = $this->T11TelList->getDataSource();
		$dsT11TelList->begin($this);

		$update_user = $this->ESession->getUserId($this);
		$update_program = $this->name.'_'.__FUNCTION__;

		$t11_query_batch = "UPDATE t11_tel_lists ".
			"SET del_flag='".$del_flag."', update_user='$update_user', update_program='$update_program'".
			"WHERE id IN (".implode(',', $tel_list_ids).");";

		if ($this->T11TelList->query($t11_query_batch)) {
			$dsT11TelList->rollback($this);
			$this->log("T11削除：失敗");
			return 'systemerror';
		}

		$dsT11TelList->commit($this);
		return 'done';
	}

	function recover_tel_info($data = null) {
		$dsT11TelList = $this->T11TelList->getDataSource();
		$dsT11TelList->begin($this);

		$data['T11TelList']['update_user'] = $this->ESession->getUserId($this);
		$data['T11TelList']['update_program'] = $this->name.'_'.__FUNCTION__;

		if (!$this->T11TelList->save($data)) {
			$dsT11TelList->rollback($this);
			$this->log("T11削除：失敗");
			return 'systemerror';
		}

		$dsT11TelList->commit($this);
		return 'done';
	}
	/*
	* やり直す　SMS内容は70文字をチェックする
	*/
	function check_sms_content_length($data,$tel){
		$arr_ques = $this->T31TemplateQuestion->getQuesByTemplateId($data['template_id']);
		$list_id = $data['list_id'];
		$ng_list_id = $data['list_ng_id'];
		$list_items = array();
		$existed_list_items = false;
		$ngTelList = array();
		$existed_ngTelList = false;
		$telList = array();
		$existed_telList = false;
		foreach ($arr_ques as $question) {
			if ($question['T31TemplateQuestion']['question_type'] == QUESTION_SMS || $question['T31TemplateQuestion']['question_type'] == QUESTION_SMS_INPUT) {
				$sms_content = $question['T31TemplateQuestion']['sms_content'];
				$sms_use_short_url = $question['T31TemplateQuestion']['yuko_button_record'];
				$M08SmsApiInfo = $this->M08SmsApiInfo->getApiInfoByDisplayNumber($question['T31TemplateQuestion']['sms_display_number']);
				$api_id = $M08SmsApiInfo['M08SmsApiInfo']['api_id'];

				$had_item = false;

				$arr_items = array();
				preg_match_all($this::ITEM_REGEX, $sms_content, $items);
				foreach ($items[0] as $item) {
					$item_name = preg_replace($this::LEFT_BRACE_REGEX, "",preg_replace($this::RIGHT_BRACE_REGEX, "", $item,1),1);
					if (!empty($item_name)) {
						$had_item = true;
						//SMS本文の中に挿入項目を洗い出してarrayに入れる
						if(!in_array($item_name, $arr_items))
							array_push($arr_items, $item_name);
					}
				}

				//挿入項目あり　または　APIV2を使うなら文字数の再確認が必要
				// 短縮URL有効・無効は$api_id == SMS_API_V2_VALUEの時にOnになる。（画面で制御）
				if($had_item || $api_id == SMS_API_V2_VALUE){ //挿入項目があった場合、挿入項目値を含めて本文の長さをチェックする
					$tel_column = "";
					if(!$existed_list_items){
						$list_items = $this->T12ListItem->getTitleByListId($list_id);
						$existed_list_items = true;
					}
					$list_columns = array();
					//リストの付加項目を取得する
					foreach ($list_items as $list_item) {
						$list_columns[$list_item['T12ListItem']['item_name']] = $list_item['T12ListItem']['column'];
						if($list_item['T12ListItem']["item_code"] == 'tel_no')
							$tel_column = $list_item['T12ListItem']['column'];
					}
					$tmp_sms_content = $sms_content;
					foreach ($arr_items as $item_name) {
						$tmp_item = "{".$item_name."}";
						//挿入項目を実際値を入れ替えて長さをチェックする
						$tmp_sms_content = str_replace($tmp_item, $tel["T11TelList"][$list_columns[$item_name]], $tmp_sms_content);
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
			}
		}
		return "";
	}
}