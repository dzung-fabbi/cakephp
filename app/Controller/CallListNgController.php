<?php
App::uses('AppController', 'Controller');

class CallListNgController extends AppController {
	var $uses = array('M01Server', 'T11TelList', 'T12ListItem', 'T14OutgoingNgList', 'T15OutgoingNgTel', 'M99SystemParameter', 'T20OutSchedule', 'M90PulldownCode', 'T92Lock', 'M05User');

	function index($mode=null, $del_count=null) {
		if ($mode == 'systemerror') {
			$this->set('msg_error', 'System error, please try again!');
		} else if($mode == "delete" || $mode == "save"){
			$sortColumn = $this->ESession->getSortColumn($this);
			$sortType = $this->ESession->getSortType($this);
			$page = $this->ESession->getPage($this);
			$this->set("sortColumn", $sortColumn);
			$this->set("sortType", $sortType);
			$this->set("page", $page);
			$this->set('del_count', $del_count);
		}

		$max_tel_param = $this->M99SystemParameter->getByFunctionIdAndParameterId('LIST', 'MAX_TEL_NG');
		$this->set('max_tel_param', $max_tel_param);

		$enable_download = $this->M04ControllerAction->check_permission($this->post_code, 'CallListNg', 'download');
		$enable_create = $this->M04ControllerAction->check_permission($this->post_code, 'CallListNg', 'create');
		$enable_delete = $this->M04ControllerAction->check_permission($this->post_code, 'CallListNg', 'delete');
		$enable_download_or_delete = $enable_download || $enable_delete;

		$this->set('enable_download', $enable_download);
		$this->set('enable_create', $enable_create);
		$this->set('enable_delete', $enable_delete);
		$this->set('enable_download_or_delete', $enable_download_or_delete);
		$this->set('mode', $mode); /* 20160311 Add by Giang : #6538 - refactor code */
	}

	function arr_ng_list($js_page, $limit, $column) {
		$this->layout = 'ajax';
		$filter = $_GET["filter"];
		$page = $js_page + 1;
		$json_data = Array();
		$json_data["headers"] = Array("NO","リスト名","件数","有効期間","作成日時","作成者","アクション",);
		$json_data["rows"] = Array();
		$company_id = $this->ESession->getUserCompanyId($this);

		$enable_download = $this->M04ControllerAction->check_permission($this->post_code, 'CallListNg', 'download');
		$enable_create = $this->M04ControllerAction->check_permission($this->post_code, 'CallListNg', 'create');
		$enable_delete = $this->M04ControllerAction->check_permission($this->post_code, 'CallListNg', 'delete');

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
			$sort_order = $this->Util->getListNgSortOrder($column,$enable_delete || $enable_download ? 1 : 0);
		}

		$sort_order_col = isset($sort_order[0]) ? $sort_order[0] : null;
		$arr_lists = $this->T14OutgoingNgList->getListNgByCompanyId($company_id, $limit, $page, $sort_order_col, $filter);

		$json_data["total_rows"] = $this->T14OutgoingNgList->getListByCompanyIdCount($company_id, $filter);
		foreach ($arr_lists as $arr_list) {
			$json_row = array();
			$entry_user = $this->M05User->getUserByUserId($arr_list['T14OutgoingNgList']['entry_user']);
			$entry_user_name = isset($entry_user["M05User"]['user_name']) ? $entry_user["M05User"]['user_name'] : '';
			$expired_date = ($arr_list['T14OutgoingNgList']['expired_date_from'] && $arr_list['T14OutgoingNgList']['expired_date_to']) ?
				date('Y-m-d', strtotime($arr_list['T14OutgoingNgList']['expired_date_from'])) . ' ～ ' . date('Y-m-d', strtotime($arr_list['T14OutgoingNgList']['expired_date_to'])) : '';
			if ($enable_delete || $enable_download) {
				$json_row['checkbox'] = '<input type="checkbox" name="call_list_ids[' . $arr_list['T14OutgoingNgList']['id'] . ']" id="cbSelect[' . $arr_list['T14OutgoingNgList']['id'] . ']" value="' . $arr_list['T14OutgoingNgList']['id'] . '" onclick="updateCheckStatus(\'bundleCheckbox\');">'
					. '<label for="cbSelect[' . $arr_list['T14OutgoingNgList']['id'] . ']" style="margin-top: 2px;"></label>';
			}
			$json_row['NO'] = str_replace($company_id, '', $arr_list['T14OutgoingNgList']['list_ng_no']);
			$json_row['リスト名'] = $arr_list['T14OutgoingNgList']['list_name'];
			$json_row['件数'] = $arr_list['T14OutgoingNgList']['total'].'件';
			$json_row['有効期間'] = $expired_date;
			$json_row['作成日時'] = date('Y-m-d H:i', strtotime($arr_list['T14OutgoingNgList']['created']));
			$json_row['作成者'] = $entry_user_name;
			$json_row['アクション'] = '<a href="javascript:void(0);" title="編集" data-toggle="tooltip" class="iconCenterFormat ajax-link lnkDetail" call_list_id="'.$arr_list['T14OutgoingNgList']['id'].'"><i class="glyphicon glyphicon-edit icon-white" ></i></a>';
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

	function buffer_csv_data() {
		$data = $this->data;
		if (empty($data)) {
			$this->redirect(array('controller' => 'CallListNg', 'action' => 'index'));
		}

		$data_csv = $this->ESession->getDataCsvDownload($this);
		if(isset($data_csv)){
			$this->Session->delete('data_csv_download');
		}

		$call_list_ids = $data['call_list_ids'];
		$data_csv_tmp = Array();

		foreach ($call_list_ids as $call_list_id) {
			$tel_lists = $this->T15OutgoingNgTel->getAllTelByCallListNgId($call_list_id);

			if (!empty($tel_lists)) {
				// $headers = Array('電話番号', 'メモ');
				// $data_csv_tmp[$call_list_id][] = $headers;

				foreach ($tel_lists as $tel_list) {
					$row =  Array($tel_list['T15OutgoingNgTel']['tel_no'], $tel_list['T15OutgoingNgTel']['memo']);
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
			$this->redirect(array('controller' => 'CallListNg', 'action' => 'index'));
		}

		$file_out_name = date('Ymdhis', time()) . '_発信NGリスト.zip';
		$file_out_name = mb_convert_encoding($file_out_name, "SJIS-win", "UTF-8");
		$this->Csv->createZip($file_out_name);

		foreach ($data_csv as $key => $data) {

			$call_list = $this->T14OutgoingNgList->getListNgInfoById($key);
			if ($call_list) {
				foreach ($data as $row) {
					$this->Csv->addRow($row);
				}

				$title_csv = $call_list['T14OutgoingNgList']['list_name'] . '.csv';
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
			$this->redirect(array('controller' => 'CallListNg', 'action' => 'index'));
		}

		$dsT14OutgoingNgList = $this->T14OutgoingNgList->getDataSource();
		$dsT15OutgoingNgTel = $this->T15OutgoingNgTel->getDataSource();
		$dsT14OutgoingNgList->begin($this);
		$dsT15OutgoingNgTel->begin($this);

		$update_user = $this->ESession->getUserId($this);
		$update_program = $this->name.'_'.__FUNCTION__;
		$time = date('Y-m-d H:i:s a', time());

		$call_list_ids = $data['call_list_ids'];

		$query1 = "UPDATE t14_outgoing_ng_lists ".
			"SET del_flag='Y', update_user='$update_user', update_program='$update_program' ".
			"WHERE id IN (".implode(',', $call_list_ids).");";
		if ($this->T14OutgoingNgList->query($query1)) {
			$dsT14OutgoingNgList->rollback($this);
			// redirect to error page
			$this->redirect(array('controller' => 'Login', 'action' => 'index'));
			exit;
		}

		$query2 = "UPDATE t15_outgoing_ng_tels ".
			"SET del_flag='Y', update_user='$update_user', update_program='$update_program', modified='$time' ".
			"WHERE del_flag = 'N' AND list_ng_id IN (".implode(',', $call_list_ids).");";
		if ($this->T15OutgoingNgTel->query($query2)) {
			$dsT14OutgoingNgList->rollback($this);
			$dsT15OutgoingNgTel->rollback($this);
			// redirect to error page
			$this->redirect(array('controller' => 'Login', 'action' => 'index'));
			exit;
		}

		$dsT14OutgoingNgList->commit($this);
		$dsT15OutgoingNgTel->commit($this);
		$this->redirect(array('controller' => 'CallListNg', 'action' => 'index/delete/' . count($call_list_ids)));
	}

	function upload_file() {
		setlocale(LC_ALL, 'ja_JP.UTF-8');
		if (empty($this->data) || empty($this->data['listName']) || empty($this->data['uploadData'])) {
			echo 'systemerror';
			exit;
		}

		$company_id = $this->ESession->getUserCompanyId($this);
		$max_list_ng_no = $this->T14OutgoingNgList->getMaxListNgNoByCompanyId($company_id);

		if ($max_list_ng_no['0']['max_list_ng_no']) {
			$list_ng_no_new = $max_list_ng_no['0']['max_list_ng_no'] + 1;
		} else {
			$list_ng_no_new = '1';
		}

		$list_name = $this->data['listName'];
		$expired_date_from = $this->data['expiredDateFrom'];
		$expired_date_to = $this->data['expiredDateTo'];
		$uploadData = json_decode($this->data['uploadData']);

		//Save data to DB
		$dsT14OutgoingNgList = $this->T14OutgoingNgList->getDataSource();
		$dsT15OutgoingNgTel = $this->T15OutgoingNgTel->getDataSource();
		$dsT14OutgoingNgList->begin($this);
		$dsT15OutgoingNgTel->begin($this);

		$this->T14OutgoingNgList->create();
		$data_call_list_ng['T14OutgoingNgList']['company_id'] = $company_id;
		$data_call_list_ng['T14OutgoingNgList']['list_ng_no'] = $list_ng_no_new;
		$data_call_list_ng['T14OutgoingNgList']['list_name'] = $list_name;
		$data_call_list_ng['T14OutgoingNgList']['total'] = count($uploadData);
		if ($expired_date_from && $expired_date_to) {
			$data_call_list_ng['T14OutgoingNgList']['expired_date_from'] = $expired_date_from;
			$data_call_list_ng['T14OutgoingNgList']['expired_date_to'] = $expired_date_to;
		}
		$data_call_list_ng['T14OutgoingNgList']['entry_user'] = $this->ESession->getUserId($this);
		$data_call_list_ng['T14OutgoingNgList']['entry_program'] = $this->name.'_'.__FUNCTION__;
		$call_list_ng = $this->T14OutgoingNgList->save($data_call_list_ng);

		if(!$call_list_ng){
			$dsT14OutgoingNgList->rollback($this);
			$dsT15OutgoingNgTel->rollback($this);
			echo 'systemerror';
			exit;
		}

		$call_list_ng_id = $call_list_ng['T14OutgoingNgList']['id'];
		$entry_user = $this->ESession->getUserId($this);
		$entry_program = $this->name.'_'.__FUNCTION__;
		$created = date('Y-m-d H:i:s a', time());

		$query_base = "INSERT INTO t15_outgoing_ng_tels ".
			"(list_ng_id, no, tel_no, memo, entry_user, entry_program, created) " .
			"VALUES ";
		$query = $query_base;
		$count = 0;

		for ($i = 0; $i < count($uploadData); $i++) {
			$count ++;
			$tel_number = $uploadData[$i][0];
			$memo = isset($uploadData[$i][1]) ? $uploadData[$i][1] : null;

			if($count % 10000 == 0 || $count == count($uploadData)){
				$query = $query."('".$call_list_ng_id."','".$count."','".$tel_number."','".$memo."','".$entry_user."','".$entry_program."','".$created."');";
				if ($this->T15OutgoingNgTel->query($query)) {
					$dsT14OutgoingNgList->rollback($this);
					$dsT15OutgoingNgTel->rollback($this);
					echo 'systemerror';
					exit;
				}
				$query = $query_base;
			}else{
				$query = $query."('".$call_list_ng_id."','".$count."','".$tel_number."','".$memo."','".$entry_user."','".$entry_program."','".$created."'), ";
			}
		}

		$dsT14OutgoingNgList->commit($this);
		$dsT15OutgoingNgTel->commit($this);
		echo 'save';
		exit;
	}

	function detail() {
		$data = $this->data;
		if (!empty($data['edit_call_list_id'])) {
			//set session list_id
			$this->ESession->setCallListId($data['edit_call_list_id'],$this);
			$list = $this->T14OutgoingNgList->getListNgInfoById($data['edit_call_list_id']);

			$schedule = $this->T20OutSchedule->getScheduleByListNgId($data['edit_call_list_id'], Array(STATUS_CALLING, STATUS_STOP_CALL, STATUS_TEMP_FINISH, STATUS_STOPING, STATUS_FINISHING, STATUS_REDIAL_WAIT));
			$enable_create_edit_delete = empty($schedule) ? true : false;
			if (!$enable_create_edit_delete) {
				$this->Session->setFlash('対象発信NGリストは実行中スケジュールに存在するため新規登録・削除・編集できません。', 'default', array('class' => 'flash_msg error'));
			}

			$enable_edit_call_list = $this->M04ControllerAction->check_permission($this->post_code, 'CallListNg', 'edit') && $enable_create_edit_delete;
			$enable_create = $this->M04ControllerAction->check_permission($this->post_code, 'DetailCallListNg', 'add');
			$enable_delete = $this->M04ControllerAction->check_permission($this->post_code, 'DetailCallListNg', 'delete') && $enable_create_edit_delete;

			$this->set("list", $list);
			$this->set('enable_edit_call_list', $enable_edit_call_list);
			$this->set('enable_create', $enable_create);
			$this->set('enable_delete', $enable_delete);

			$max_tel_param = $this->M99SystemParameter->getByFunctionIdAndParameterId('LIST', 'MAX_TEL_NG');
			$this->set('max_tel_param', $max_tel_param);
		}else{
			$this->redirect(array('controller' => 'CallListNg', 'action' => 'index'));
		}
	}

	function tel_list_ng($js_page, $limit, $column) {
		$this->layout = 'ajax';
		$filter = $_GET["filter"];
		$page = $js_page + 1;
		$json_data = Array();

		$call_list_id = $this->ESession->getCallListId($this);

		$headers = Array("NO","電話番号","メモ");

		$json_data["rows"] = Array();

		$schedule = $this->T20OutSchedule->getScheduleByListNgId($call_list_id, Array(STATUS_CALLING, STATUS_STOP_CALL, STATUS_TEMP_FINISH, STATUS_STOPING, STATUS_FINISHING, STATUS_REDIAL_WAIT));
		$enable_create_edit_delete = empty($schedule) ? true : false;

		$enable_delete = $this->M04ControllerAction->check_permission($this->post_code, 'DetailCallListNg', 'delete') && $enable_create_edit_delete;

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
			$sort_order = $this->Util->getTelListNgSortOrder($column, $enable_delete ? 1 : 0);
		}

		$sort_order_col = isset($sort_order[0]) ? $sort_order[0] : null;
		$tel_lists = $this->T15OutgoingNgTel->getTelByCallListNgId($call_list_id, $limit, $page, $sort_order_col, $filter);
		$json_data["total_rows"] = $this->T15OutgoingNgTel->getListByCallListNgIdCount($call_list_id, $filter);

		foreach ($tel_lists as $arr_list) {
			$json_row = array();
			if ($enable_delete) {
				$json_row['selectItem'] = '<input class="select_item" type="checkbox" name="cbSelect[' . $arr_list['T15OutgoingNgTel']['id'] . ']" id="cbSelect[' . $arr_list['T15OutgoingNgTel']['id'] . ']" value="' . $arr_list['T15OutgoingNgTel']['id'] . '" onclick="updateCheckStatus(\'bundleCheckbox\');">'
					. '<label class="label_select_item" for="cbSelect[' . $arr_list['T15OutgoingNgTel']['id'] . ']" style="margin-top: 2px;"></label>';
			}
			$json_row['NO'] = $arr_list['T15OutgoingNgTel']['no'];
			$json_row['電話番号'] = $arr_list['T15OutgoingNgTel']['tel_no'];
			$json_row['メモ'] = empty($arr_list['T15OutgoingNgTel']['memo']) ? '' : $arr_list['T15OutgoingNgTel']['memo'];

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

	function update_call_list_ng() {
		if (empty($this->data) || empty($this->data['callListId']) || empty($this->data['listName'])) {
			echo 'systemerror';
			exit;
		}

		$list_name = $this->data['listName'];
		$call_list_id = $this->data['callListId'];
		$expired_date_from = $this->data['expired_date_from'];
		$expired_date_to = $this->data['expired_date_to'];

		//Save data to DB
		$dsT14OutgoingNgList = $this->T14OutgoingNgList->getDataSource();
		$dsT14OutgoingNgList->begin($this);

		$data_call_list['T14OutgoingNgList']['id'] = $call_list_id;
		$data_call_list['T14OutgoingNgList']['list_name'] = $list_name;
		$data_call_list['T14OutgoingNgList']['expired_date_from'] = $expired_date_from;
		$data_call_list['T14OutgoingNgList']['expired_date_to'] = $expired_date_to;
		$data_call_list['T14OutgoingNgList']['update_user'] = $this->ESession->getUserId($this);
		$data_call_list['T14OutgoingNgList']['update_program'] = $this->name.'_'.__FUNCTION__;

		$call_list = $this->T14OutgoingNgList->save($data_call_list['T14OutgoingNgList']);
		if(!$call_list){
			$dsT14OutgoingNgList->rollback($this);
			echo 'systemerror';
			exit;
		}

		$dsT14OutgoingNgList->commit($this);
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

		//T14件数更新
		$current_tel_total = $this->T15OutgoingNgTel->getTelTotalByCallListNgId($call_list_id);
		$tel_total = $current_tel_total - count($tel_list_ids);
		$dsT14OutgoingNgList = $this->T14OutgoingNgList->getDataSource();
		$dsT14OutgoingNgList->begin($this);

		$call_list['T14OutgoingNgList']['id'] = $call_list_id;
		$call_list['T14OutgoingNgList']['total'] = $tel_total;
		$call_list['T14OutgoingNgList']['update_user'] = $this->ESession->getUserId($this);
		$call_list['T14OutgoingNgList']['update_program'] = $this->name.'_'.__FUNCTION__;

		if (!$this->T14OutgoingNgList->save($call_list)) {
			$dsT14OutgoingNgList->rollback($this);
			$this->log("T14リスト件数更新：失敗");
			echo 'systemerror';
			exit;
		}

		$dsT15OutgoingNgTel = $this->T15OutgoingNgTel->getDataSource();
		$dsT15OutgoingNgTel->begin($this);
		$update_user = $this->ESession->getUserId($this);
		$update_program = $this->name.'_'.__FUNCTION__;
		$query = "UPDATE t15_outgoing_ng_tels ".
			"SET del_flag='Y', update_user='$update_user', update_program='$update_program'".
			"WHERE id IN (".implode(',', $tel_list_ids).");";
		if ($this->T15OutgoingNgTel->query($query)) {
			$dsT14OutgoingNgList->rollback($this);
			$dsT15OutgoingNgTel->rollback($this);
			$this->log("T15削除：失敗");
			echo 'systemerror';
			exit;
		}
		$dsT14OutgoingNgList->commit($this);
		$dsT15OutgoingNgTel->commit($this);

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

	function add_file() {
		setlocale(LC_ALL, 'ja_JP.UTF-8');
		if (empty($this->data) || empty($this->data['uploadData'])) {
			echo 'systemerror';
			exit;
		}
		$call_list_ng_id = $this->ESession->getCallListId($this);
		$uploadData = json_decode($this->data['uploadData']);
		$results = Array();

		//T14件数更新
		$current_tel_total = $this->T15OutgoingNgTel->getTelTotalByCallListNgId($call_list_ng_id);
		$tel_total = $current_tel_total + count($uploadData);
		$dsT14OutgoingNgList = $this->T14OutgoingNgList->getDataSource();
		$dsT14OutgoingNgList->begin($this);

		$call_list['T14OutgoingNgList']['id'] = $call_list_ng_id;
		$call_list['T14OutgoingNgList']['total'] = $tel_total;
		$call_list['T14OutgoingNgList']['update_user'] = $this->ESession->getUserId($this);
		$call_list['T14OutgoingNgList']['update_program'] = $this->name.'_'.__FUNCTION__;

		if (!$this->T14OutgoingNgList->save($call_list)) {
			$dsT14OutgoingNgList->rollback($this);
			$this->log("T14リスト件数更新：失敗");
			echo 'systemerror';
			exit;
		}

		//T15電話番号追加
		$dsT15OutgoingNgTel = $this->T15OutgoingNgTel->getDataSource();
		$dsT15OutgoingNgTel->begin($this);
		$created = date('Y-m-d H:i:s a', time());
		$entry_user = $this->ESession->getUserId($this);
		$entry_program = $this->name.'_'.__FUNCTION__;
		$max_tel_no = $this->T15OutgoingNgTel->getMaxTelNoByCallListNgId($call_list_ng_id);
		$max_tel_no = $max_tel_no[0]['max_tel_no'];
		$query_base = "INSERT INTO t15_outgoing_ng_tels ".
			"(list_ng_id, no, tel_no, memo, entry_user, entry_program, created) " .
			"VALUES ";
		$query = $query_base;
		$count = 0;
		$arr_tel_ng = array();
		for ($i = 0; $i < count($uploadData); $i++) {
			$max_tel_no = $max_tel_no + 1;
			$count ++;
			$tel_number = $uploadData[$i][0];
			$memo = isset($uploadData[$i][1]) ? $uploadData[$i][1] : null;

			if($count % 10000 == 0 || $count == count($uploadData)){
				$query = $query."('".$call_list_ng_id."','".$max_tel_no."','".$tel_number."','".$memo."','".$entry_user."','".$entry_program."','".$created."');";
				if ($this->T15OutgoingNgTel->query($query)) {
					$dsT14OutgoingNgList->rollback($this);
					$dsT15OutgoingNgTel->rollback($this);
					$this->log("T15番号追加：失敗");
					echo 'systemerror';
					exit;
				}
				$query = $query_base;
			}else{
				$query = $query."('".$call_list_ng_id."','".$max_tel_no."','".$tel_number."','".$memo."','".$entry_user."','".$entry_program."','".$created."'), ";
			}
			array_push($arr_tel_ng, $tel_number);
		}

		//コールモジュールにリアルタイム反映
		$arr_schedule = $this->T20OutSchedule->getScheduleByListNg($call_list_ng_id, STATUS_CALLING);
		$batch_result = "success";
		foreach ($arr_schedule as $arr){
			$tel_str = "";
			$schedule_id = $arr["T20OutSchedule"]["id"];
			$template_id = $arr["T20OutSchedule"]["template_id"];
			$list_id = $arr["T20OutSchedule"]["list_id"];
			$external_number = $arr["T20OutSchedule"]["external_number"];
			$arr_server_info = $this->M01Server->getServerByExternalNumber($external_number, SERVER_OUTBOUND);
			$server_id = $arr_server_info["M01Server"]["server_id"];
			$server_ip = $arr_server_info["M01Server"]["server_ip"];
			$local_path  = $arr_server_info["M01Server"]["local_path"];
			$arr_column = $this->T12ListItem->getTelNumColumn($list_id);
			$tel_col = $arr_column["T12ListItem"]["column"];
			$arr_tel = $this->T11TelList->getTelYukoByListIdArrTel($list_id, $arr_tel_ng, $tel_col);
			foreach ($arr_tel as $arr){
				if(empty($tel_str)){
					$tel_str = $arr["T11TelList"][$tel_col];
				}else{
					$tel_str = $tel_str.",".$arr["T11TelList"][$tel_col];
				}
			}
			if(count($arr_tel) > 0){
				$cmd = "/usr/local/bin/ruby ".$local_path."mega_prohibit.rb ".$server_id." ".$schedule_id." ".$tel_str;
				exec($cmd, $shell_result, $shell_result_status);
				if($shell_result_status != 0){
					$batch_result = $shell_result[0];
					$this->log($shell_result);
					$this->log("BATCHでリアルタイムNG反映：失敗");
					break;
				}
			}
		}

		if($batch_result != "success"){
			$results['status'] = 'err_mega_prohibit';
		}else{
			$dsT14OutgoingNgList->commit($this);
			$dsT15OutgoingNgTel->commit($this);
			$results['status'] = 'save';
		}
		$results['sortColumn'] = $this->ESession->getSortColumn($this);
		$results['sortType'] = $this->ESession->getSortType($this);
		$results['page'] = $this->ESession->getPage($this);
		echo json_encode($results);
		exit;
	}

	function check_exist_listname() {
		$data = $this->data;
		$company_id = $this->ESession->getUserCompanyId($this);
		$info_list = $this->T14OutgoingNgList->getByListName($data['list_name'], $company_id);
		if(isset($info_list["T14OutgoingNgList"]["id"]) && !empty($info_list["T14OutgoingNgList"]["id"])){
			if (isset($data['list_name_old']) && $data['list_name_old'] == $info_list['T14OutgoingNgList']['list_name']) {
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
			$this->redirect(array('controller' => 'CallListNg', 'action' => 'index'));
		}

		$results = Array();
		$call_list_id = $this->ESession->getCallListId($this);
		$info_list = $this->T14OutgoingNgList->getListNgInfoById($call_list_id);
		if (!isset($info_list["T14OutgoingNgList"]["id"]) || empty($info_list["T14OutgoingNgList"]["id"])) {
			//リスト存在しない
			$results['status'] = 'err_list_not_exist';
			echo json_encode($results);
			exit;
		}

		if (isset($this->data['action']) && isset($this->data['uploadData']) && ($this->data['action'] == 'add')) {
			$uploadData = json_decode($this->data['uploadData']);
			$max_tel_param = $this->M99SystemParameter->getByFunctionIdAndParameterId('LIST', 'MAX_TEL_NG');
			$max_tel_param = $max_tel_param['M99SystemParameter']['parameter_value'];
			$current_tel_total = $this->T15OutgoingNgTel->getTelTotalByCallListNgId($call_list_id);
			$new_tel_total = $current_tel_total + count($uploadData);
			$tel_total_over = $new_tel_total - $max_tel_param;

			if ($tel_total_over > 0) {
				$results['status'] = 'tel_total_over';
				$results['err_msg'] = Array('20000件を超える為追加できません。');
				echo json_encode($results);
				exit;
			}

			$tel_no_tmp = Array();
			$error_tmp = Array();
			$current_tel_no_lists = $this->T15OutgoingNgTel->getTelListByCallListNgId($call_list_id);
			foreach ($current_tel_no_lists as $tel_no) {
				$tel_no_tmp[] = $tel_no['T15OutgoingNgTel']['tel_no'];
			}
			for ($i = 0; $i < count($uploadData); $i++) {
				$tel_number = $uploadData[$i][0];
				if (in_array($tel_number, $tel_no_tmp)) {
					$error_tmp[] = ($i + 1) . '行の電話番号は既に利用されています。';
				}
			}

			if (!empty($error_tmp)) {
				$results['status'] = 'err_used';
				$results['err_msg'] = $error_tmp;
				echo json_encode($results);
				exit;
			}

			$results['status'] = 'success';
			echo json_encode($results);
			exit;
		}

		$tel_list_ids = $this->data['tel_list_ids'];

		if (!is_array($tel_list_ids)) {
			$tel_list_ids = explode(' ', $tel_list_ids);
		}
		foreach ($tel_list_ids as $id) {
			$info_tel = $this->T15OutgoingNgTel->getTelInfoById($id);
			if(empty($info_tel)){
				$results['status'] = 'err_tel_not_exist';
				echo json_encode($results);
				exit;
			}
		}

		$results['status'] = 'success';
		echo json_encode($results);
		exit;
	}

	function check_info_list() {
		$data = $this->data;
		if (empty($data)) {
			$this->redirect(array('controller' => 'CallListNg', 'action' => 'index'));
		}

		$call_list_ids = $data['call_list_ids'];
		if (!is_array($call_list_ids)) {
			$call_list_ids = explode(' ', $call_list_ids);
		}

		foreach ($call_list_ids as $id) {
			$info_list = $this->T14OutgoingNgList->getListNgInfoById($id);
			if (!isset($info_list["T14OutgoingNgList"]["id"]) || empty($info_list["T14OutgoingNgList"]["id"])) {
				//リスト存在しない
				echo "err_not_exist";
				exit;
			}

			$info_schedule = $this->T20OutSchedule->getScheduleByListNgId($id);
			foreach ($info_schedule as $schedule) {
				if (isset($schedule["T20OutSchedule"]["id"]) && $schedule["T20OutSchedule"]["status"] != STATUS_FINISH) {
					echo "err_used";
					exit;
				}
			}
		}
		echo 'success';
		exit;
	}
}
