<?php
App::uses('AppController', 'Controller');

class InboundCallListController extends AppController {
	var $uses = array(
		'M01Server',
		'T16InboundCallList',
		'T17InboundTelList',
		'M99SystemParameter',
		'T25Inbound',
		'M90PulldownCode',
		'T92Lock',
		'T13InboundListItem',
		'M05User',
		'M07ServerExternal'
	);

	function index($mode=null, $del_count=null) {
		if ($mode == 'systemerror') {
			$this->set('msg_error', 'System error, please try again!');
		}

		$max_tel_param = $this->M99SystemParameter->getByFunctionIdAndParameterId('LIST', 'MAX_INBOUND_TEL');
		$this->set('max_tel_param', $max_tel_param);

		$list_item_fields = $this->M90PulldownCode->getSelectOption('list_item');
		$this->set('list_item_fields', json_encode($list_item_fields));
		$headers = Array();
		foreach ($list_item_fields as $list_item) {
			$headers[$list_item['M90PulldownCode']['item_code']] = $list_item['M90PulldownCode']['item_name'];
		}
		$this->set('headers', $headers);

		$enable_download = $this->M04ControllerAction->check_permission($this->post_code, 'InboundCallList', 'download');
		$enable_create = $this->M04ControllerAction->check_permission($this->post_code, 'InboundCallList', 'create');
		$enable_delete = $this->M04ControllerAction->check_permission($this->post_code, 'InboundCallList', 'delete');
		$this->set('enable_download', $enable_download);
		$this->set('enable_create', $enable_create);
		$this->set('enable_delete', $enable_delete);

		//照合項目非表示リストを取得
		$TempHiddenCallList = $this->M99SystemParameter->getByFunctionIdAndParameterIdALL('HIDDEN_CALL_LIST', 'HIDDEN_CALL_LIST');

		//必要な項目のみを渡すためにデータ整理
		$HiddenCallList = array();
		for($i=0; $i<count($TempHiddenCallList); $i++){
			array_push($HiddenCallList,$TempHiddenCallList[$i]['M99SystemParameter']['parameter_value']);
		}
		$JSON_HiddenCallList = json_encode($HiddenCallList);
		$this->set('JSON_HiddenCallList',$JSON_HiddenCallList);
	}

	function arr_inbound_call_list($js_page, $limit, $column) {
		$this->layout = 'ajax';
		$filter = $_GET["filter"];
		$page = $js_page + 1;
		$json_data = Array();
		$json_data["headers"] = Array("NO","リスト名","件数","作成日時","作成者","アクション",);
		$json_data["rows"] = Array();
		$company_id = $this->ESession->getUserCompanyId($this);

		$enable_download = $this->M04ControllerAction->check_permission($this->post_code, 'InboundCallList', 'download');
		$enable_create = $this->M04ControllerAction->check_permission($this->post_code, 'InboundCallList', 'create');
		$enable_delete = $this->M04ControllerAction->check_permission($this->post_code, 'InboundCallList', 'delete');

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
			$sort_order = $this->Util->getInboundListSortOrder($column,$enable_delete || $enable_download ? 1 : 0);
		}

		$sort_order_col = isset($sort_order[0]) ? $sort_order[0] : null;
		$arr_lists = $this->T16InboundCallList->getListByCompanyId($company_id, $limit, $page, $sort_order_col, $filter);

		$json_data["total_rows"] = $this->T16InboundCallList->getListByCompanyIdCount($company_id, $filter);
		foreach ($arr_lists as $arr_list) {
			$json_row = array();
			$entry_user = $this->M05User->getUserByUserId($arr_list['T16InboundCallList']['entry_user']);
			$entry_user_name = isset($entry_user["M05User"]['user_name']) ? $entry_user["M05User"]['user_name'] : '';
			if ($enable_delete || $enable_download) {
				$json_row['checkbox'] = '<input type="checkbox" name="call_list_ids[' . $arr_list['T16InboundCallList']['id'] . ']" id="cbSelect[' . $arr_list['T16InboundCallList']['id'] . ']" value="' . $arr_list['T16InboundCallList']['id'] . '" onclick="updateCheckStatus(\'bundleCheckbox\');">'
					. '<label for="cbSelect[' . $arr_list['T16InboundCallList']['id'] . ']" style="margin-top: 2px;"></label>';
			}
			$json_row['NO'] = str_replace($company_id, '', $arr_list['T16InboundCallList']['list_no']);
			$json_row['リスト名'] = $arr_list['T16InboundCallList']['list_test_flag'] == 1 ? "<font color='red'>(テスト)".$arr_list['T16InboundCallList']['list_name']."</font>" : $arr_list['T16InboundCallList']['list_name'];
			$json_row['件数'] = $arr_list['T16InboundCallList']['tel_total'].'件';
			$json_row['作成日時'] = date('Y-m-d H:i', strtotime($arr_list['T16InboundCallList']['created']));
			$json_row['作成者'] = $entry_user_name;
			$json_row['アクション'] = '<a href="javascript:void(0);" title="編集" data-toggle="tooltip" class="iconCenterFormat ajax-link lnkDetail" call_list_id="'.$arr_list['T16InboundCallList']['id'].'"><i class="glyphicon glyphicon-edit icon-white" ></i></a>';
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
		if (empty($this->data) || empty($this->data['listName']) || empty($this->data['uploadData']) || empty($this->data['fieldImport']) || empty($this->data['listItemData']) || empty($this->data['item_main'])) {
			$this->log("[upload_file][failed][" . __LINE__ . "]" . print_r($this->data, 1));
			echo 'systemerror';
			exit;
		}

		$entry_user = $this->ESession->getUserId($this);
		$entry_program = $this->name.'_'.__FUNCTION__;
		$company_id = $this->ESession->getUserCompanyId($this);
		$max_list_no = $this->T16InboundCallList->getMaxListNoByCompanyId($company_id);

		if ($max_list_no['0']['max_list_no']) {
			$list_no_new = $max_list_no['0']['max_list_no'] + 1;
		} else {
			$list_no_new = '1';
		}
		$check_lock = $this->T92Lock->getInfoLock('inbound_call_list', $list_no_new);
		if (!empty($check_lock)) {
			$this->log("[upload_file][failed][" . __LINE__ . "]" . print_r($check_lock, 1));
			$failed_msg = $this->_getErrorMsg();
			$this->log($failed_msg);

			echo 'systemerror';
			exit;
		}

		$lock_new = $this->create_lock('inbound_call_list', $list_no_new, __FUNCTION__);
		if (!$lock_new) {
			$this->log("[upload_file][failed][" . __LINE__ . "]" . print_r($lock_new, 1));
			$failed_msg = $this->_getErrorMsg();
			$this->log($failed_msg);

			echo 'systemerror';
			exit;
		}

		$list_name = $this->data['listName'];
		$uploadData = json_decode($this->data['uploadData']);
		$fieldImport = $this->data['fieldImport'];
		$item_main = $this->data['item_main'];
		if ($this->data['listTestFlag'] == 'true') {
			$list_test_flag = 1;
		} else {
			$list_test_flag = 0;
		}

		//Save data to DB
		$dsT16InboundCallList = $this->T16InboundCallList->getDataSource();
		$dsT17InboundTelList = $this->T17InboundTelList->getDataSource();
		$dsT13InboundListItem = $this->T13InboundListItem->getDataSource();

		$dsT16InboundCallList->begin($this);
		$dsT17InboundTelList->begin($this);
		$dsT13InboundListItem->begin($this);

		$time = date('Y-m-d H:i:s a', time());

		$this->T16InboundCallList->create();
		$data_call_list['T16InboundCallList']['company_id'] = $company_id;
		$data_call_list['T16InboundCallList']['list_no'] = $list_no_new;
		$data_call_list['T16InboundCallList']['list_name'] = $list_name;
		$data_call_list['T16InboundCallList']['item_main'] = $item_main;
		$data_call_list['T16InboundCallList']['list_test_flag'] = $list_test_flag;
		$data_call_list['T16InboundCallList']['tel_total'] = count($uploadData);
		$data_call_list['T16InboundCallList']['entry_user'] = $entry_user;
		$data_call_list['T16InboundCallList']['entry_program'] = $entry_program;
		$call_list = $this->T16InboundCallList->save($data_call_list);

		if(!$call_list){
			$this->log("[upload_file][failed][" . __LINE__ . "]" . print_r($call_list, 1));
			$failed_msg = $this->_getErrorMsg();
			$this->log($failed_msg);

			$this->update_lock($lock_new, __FUNCTION__);
			$dsT16InboundCallList->rollback($this);
			$dsT17InboundTelList->rollback($this);
			echo 'systemerror';
			exit;
		}

		$call_list_id = $call_list['T16InboundCallList']['id'];

		$query_base = "INSERT INTO t17_inbound_tel_lists ".
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
				$my_result = $this->T17InboundTelList->query($query);
				if ($my_result) {
					$this->log("[upload_file][failed][" . __LINE__ . "]" . print_r($my_result, 1));
					$failed_msg = $this->_getErrorMsg();
					$this->log($failed_msg);

					$this->update_lock($lock_new, __FUNCTION__);
					$dsT16InboundCallList->rollback($this);
					$dsT17InboundTelList->rollback($this);
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
		$t13_query_base = "INSERT INTO t13_inbound_list_items ".
			"(company_id, list_id, order_num, item_name, item_code, `column`, del_flag, entry_user, entry_program, created) " .
			"VALUES ";
		$t13_query = $t13_query_base;
		$order_num = 0;

		$item_codes = array();
		$list_item_tmps = $this->M90PulldownCode->getSelectOption('list_item');
		foreach ($list_item_tmps as $item) {
			$item_codes[$item['M90PulldownCode']['item_name']] = $item['M90PulldownCode']['item_code'];
		}

		foreach ($listItemData as $column => $item_name) {
			$order_num ++;
			$item_code = isset($item_codes[$item_name]) ? $item_codes[$item_name] : $item_name;

			if($order_num == count($listItemData)){
				$t13_query = $t13_query."('".$company_id."','".$call_list_id."','".$order_num."','".$item_name."','".$item_code."','customize".$column."','N','".$entry_user."','".$entry_program."','".date('Y-m-d H:i:s a', time())."');";

				$my_result = $this->T13InboundListItem->query($t13_query);
				if ($my_result) {
					$this->log("[upload_file][failed][" . __LINE__ . "]" . print_r($my_result, 1));
					$failed_msg = $this->_getErrorMsg();
					$this->log($failed_msg);

					$this->update_lock($lock_new, __FUNCTION__);
					$dsT16InboundCallList->rollback($this);
					$dsT17InboundTelList->rollback($this);
					$dsT13InboundListItem->rollback($this);
					echo 'systemerror';
					exit;
				}
				$t13_query = $t13_query_base;
			}else{
				$t13_query = $t13_query."('".$company_id."','".$call_list_id."','".$order_num."','".$item_name."','".$item_code."','customize".$column."','N','".$entry_user."','".$entry_program."','".date('Y-m-d H:i:s a', time())."'), ";
			}
		}
		if (isset($lock_new) && !empty($lock_new) && !$this->update_lock($lock_new, __FUNCTION__)) {
			$dsT16InboundCallList->rollback($this);
			$dsT17InboundTelList->rollback($this);
			$dsT13InboundListItem->rollback($this);
			echo 'systemerror';
			exit;
		}

		$dsT16InboundCallList->commit($this);
		$dsT17InboundTelList->commit($this);
		$dsT13InboundListItem->commit($this);

		$results = Array();
		$results['status'] = 'save';
		$results['sortColumn'] = $this->ESession->getSortColumn($this);
		$results['sortType'] = $this->ESession->getSortType($this);
		$results['page'] = $this->ESession->getPage($this);
		echo json_encode($results);
		exit;
	}

	function check_exist_listname() {
		$data = $this->data;
		$company_id = $this->ESession->getUserCompanyId($this);
		$info_list = $this->T16InboundCallList->getByListName($data['list_name'], $company_id);
		if(isset($info_list["T16InboundCallList"]["id"]) && !empty($info_list["T16InboundCallList"]["id"])){
			if (isset($data['list_name_old']) && $data['list_name_old'] == $info_list['T16InboundCallList']['list_name']) {
				echo "true";
				exit;
			}
			echo "false";
		}else{
			echo "true";
		}
		exit;
	}

	function buffer_csv_data() {
		$data = $this->data;
		if (empty($data)) {
			echo 'systemerror';
			exit;
		}

		$data_csv = $this->ESession->getDataCsvDownload($this);
		if(isset($data_csv)){
			$this->Session->delete('data_csv_download');
		}

		$call_list_ids = $data['call_list_ids'];
		$data_csv_tmp = Array();

		foreach ($call_list_ids as $call_list_id) {
			$tel_lists = $this->T17InboundTelList->getAllTelByCallListId($call_list_id);
			$t13_list_items = $this->T13InboundListItem->getTitleByListId($call_list_id);

			if ($tel_lists && !empty($t13_list_items)) {
				$headers = Array();
				foreach ($t13_list_items as $t13_list_item) {
					$headers[] = $t13_list_item['T13InboundListItem']['item_name'];
				}
				$data_csv_tmp[$call_list_id][] = $headers;

				foreach ($tel_lists as $tel_list) {
					$row =  Array();
					foreach ($t13_list_items as $t13_list_item) {
						$column = $t13_list_item['T13InboundListItem']['column'];
						array_push($row, $tel_list['T17InboundTelList'][$column]);
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
			$this->redirect(array('controller' => 'InboundCallList', 'action' => 'index'));
		}

		$file_out_name = date('Ymdhis', time()) . '_着信リスト.zip';
		$file_out_name = mb_convert_encoding($file_out_name, "SJIS-win", "UTF-8");
		$this->Csv->createZip($file_out_name);

		foreach ($data_csv as $key => $data) {

			$call_list = $this->T16InboundCallList->getListInfoById($key);
			if ($call_list) {
				foreach ($data as $row) {
					$this->Csv->addRow($row);
				}

				$title_csv = $call_list['T16InboundCallList']['list_name'] . '.csv';
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
			echo 'systemerror';
			exit;
		}

		$dsT16InboundCallList = $this->T16InboundCallList->getDataSource();
		$dsT17InboundTelList = $this->T17InboundTelList->getDataSource();
		$dsT13InboundListItem = $this->T13InboundListItem->getDataSource();
		$dsT16InboundCallList->begin($this);
		$dsT17InboundTelList->begin($this);
		$dsT13InboundListItem->begin($this);

		$update_user = $this->ESession->getUserId($this);
		$update_program = $this->name.'_'.__FUNCTION__;
		$time = date('Y-m-d H:i:s a', time());

		$call_list_ids = $data['call_list_ids'];

		$query1 = "UPDATE t16_inbound_call_lists ".
			"SET del_flag='Y', update_user='$update_user', update_program='$update_program' ".
			"WHERE id IN (".implode(',', $call_list_ids).");";
		if ($this->T16InboundCallList->query($query1)) {
			$dsT16InboundCallList->rollback($this);
			echo 'systemerror';
			exit;
		}

		$count_tel = $this->T17InboundTelList->getTelByListIdsCount($call_list_ids);
		if ($count_tel > 0) {
			$query2 = "UPDATE t17_inbound_tel_lists ".
				"SET del_flag='Y', update_user='$update_user', update_program='$update_program', modified='$time' ".
				"WHERE del_flag = 'N' AND list_id IN (".implode(',', $call_list_ids).");";
			if ($this->T17InboundTelList->query($query2)) {
				$dsT16InboundCallList->rollback($this);
				$dsT17InboundTelList->rollback($this);
				echo 'systemerror';
				exit;
			}
		}

		$query3 = "UPDATE t13_inbound_list_items ".
			"SET del_flag='Y' ".
			"WHERE del_flag = 'N' AND list_id IN (".implode(',', $call_list_ids).");";
		if ($this->T13InboundListItem->query($query3)) {
			$dsT16InboundCallList->rollback($this);
			$dsT17InboundTelList->rollback($this);
			$dsT13InboundListItem->rollback($this);
			$this->log("T13削除：失敗");
			echo 'systemerror';
			exit;
		}

		$dsT16InboundCallList->commit($this);
		$dsT17InboundTelList->commit($this);
		$dsT13InboundListItem->commit($this);

		$results = Array();
		$results['status'] = 'deleted';
		$results['sortColumn'] = $this->ESession->getSortColumn($this);
		$results['sortType'] = $this->ESession->getSortType($this);

		$company_id = $this->ESession->getUserCompanyId($this);
		$inbound_call_list_count = $this->T16InboundCallList->getListByCompanyIdCount($company_id);
		$max_page = round($inbound_call_list_count / PAGE_LENGTH);
		$current_page = $this->ESession->getPage($this);
		if (($current_page == $max_page) && (count($call_list_ids) == ($inbound_call_list_count % PAGE_LENGTH)) && ($current_page > 0)) {
			$current_page--;
		}
		$results['page'] = $current_page;

		echo json_encode($results);
		exit;
	}

	function check_info_list() {
		$data = $this->data;
		if (empty($data)) {
			echo 'systemerror';
			exit;
		}

		$call_list_ids = $data['call_list_ids'];
		if (!is_array($call_list_ids)) {
			$call_list_ids = explode(' ', $call_list_ids);
		}

		foreach ($call_list_ids as $id) {
			$info_list = $this->T16InboundCallList->getListInfoById($id);
			if (!isset($info_list["T16InboundCallList"]["id"]) || empty($info_list["T16InboundCallList"]["id"])) {
				//リスト存在しない
				echo "err_not_exist";
				exit;
			}

			$info_schedule = $this->T25Inbound->getScheduleByListId($id);
			foreach ($info_schedule as $schedule) {
				if (isset($schedule["T25Inbound"]["id"]) && $schedule["T25Inbound"]["status"] != STATUS_INBOUND_END) {
					echo "err_used";
					exit;
				}
			}
		}
		echo 'success';
		exit;
	}

	function detail() {
		$data = $this->data;
		if (!empty($data['edit_call_list_id'])) {
			//set session list_id
			$this->ESession->setCallListId($data['edit_call_list_id'],$this);
			$list = $this->T16InboundCallList->getListInfoById($data['edit_call_list_id']);
			$t13_list_items = $this->T13InboundListItem->getTitleByListId($data['edit_call_list_id']);
			$headers = Array();
			foreach ($t13_list_items as $t13_list_item) {
				$headers[$t13_list_item['T13InboundListItem']['column']] = $t13_list_item['T13InboundListItem']['item_name'];
			}

			//非表示項目を取得
			$M99_hiddenlist_items = $this->M99SystemParameter->getByFunctionIdAndParameterIdAll('HIDDEN_CALL_LIST', 'HIDDEN_CALL_LIST');

			//必要な項目のみを渡すためにデータ整理
			$HiddenCallList = array();
			for($i=0; $i<count($M99_hiddenlist_items); $i++){
				array_push($HiddenCallList,$M99_hiddenlist_items[$i]['M99SystemParameter']['parameter_value']);
			}

			//表示項目の作成処理
			//ヘッダ項目をサーバ側で取得しているため、表示項目の作成も同様にサーバ側で行っています。
			$ShowCallList = array();
			foreach($t13_list_items as $t13_list_item){
					if(array_search($t13_list_item['T13InboundListItem']['item_name'],$HiddenCallList) === false){
						array_push($ShowCallList,$t13_list_item['T13InboundListItem']['item_name']);
					}
			}

			$this->set('ShowCallList',$ShowCallList);

			$schedule = $this->T25Inbound->getScheduleByListId($data['edit_call_list_id'], Array(STATUS_INBOUND_MESSAGE, STATUS_INBOUND_BUSY));
			$enable_create_edit_delete = empty($schedule) ? true : false;
			if (!$enable_create_edit_delete) {
				$this->Session->setFlash('着信設定に存在着信リストの為編集できません。', 'default', array('class' => 'flash_msg error'));
			}

			$enable_edit_call_list = $this->M04ControllerAction->check_permission($this->post_code, 'InboundCallList', 'edit') && $enable_create_edit_delete;
			$enable_create = $this->M04ControllerAction->check_permission($this->post_code, 'DetailInboundCallList', 'create') && $enable_create_edit_delete;
			$enable_delete = $this->M04ControllerAction->check_permission($this->post_code, 'DetailInboundCallList', 'delete') && $enable_create_edit_delete;
			$enable_edit = $this->M04ControllerAction->check_permission($this->post_code, 'DetailInboundCallList', 'edit') && $enable_create_edit_delete;
			// 20160530 Edit by Giang - Comment out muko
			// $enable_report_not_effective = $this->M04ControllerAction->check_permission($this->post_code, 'DetailInboundCallList', 'report_not_effective');

			$t17_item_main = $this->T16InboundCallList->getItemMainById($data['edit_call_list_id']);
			$item_main = $t17_item_main['T16InboundCallList']['item_main'];
			$this->set("item_main", $item_main);

			$item_column = $this->T13InboundListItem->getColumnListByItemName($data['edit_call_list_id'], $item_main);
			$item_column = $item_column['T13InboundListItem']['column'];
			$this->set("item_column", $item_column);

			$this->set("list", $list);
			$this->set("t13_list_items", $t13_list_items);
			$this->set("headers", $headers);
			$this->set('enable_edit_call_list', $enable_edit_call_list);
			$this->set('enable_create', $enable_create);
			$this->set('enable_delete', $enable_delete);
			$this->set('enable_edit', $enable_edit);
			// 20160530 Edit by Giang - Comment out muko
			// $this->set('enable_report_not_effective', $enable_report_not_effective);
		}else{
			$this->redirect(array('controller' => 'InboundCallList', 'action' => 'index'));
		}
	}

	function tel_list($js_page, $limit, $column) {
		$this->layout = 'ajax';
		$filter = $_GET["filter"];
		$page = $js_page + 1;
		$json_data = Array();

		$call_list_id = $this->ESession->getCallListId($this);
		$t13_list_items = $this->T13InboundListItem->getTitleByListId($call_list_id);

		$headers = Array("dummy_gs_id_string");
		foreach ($t13_list_items as $t13_list_item) {
			$headers[] = $t13_list_item['T13InboundListItem']['item_name'];
		}
		// 20160530 Edit by Giang - Comment out muko
		// $headers[] = '無効';
		$json_data["rows"] = Array();

		$schedule = $this->T25Inbound->getScheduleByListId($call_list_id, Array(STATUS_INBOUND_MESSAGE, STATUS_INBOUND_BUSY));
		$enable_create_edit_delete = empty($schedule) ? true : false;

		$enable_edit = $this->M04ControllerAction->check_permission($this->post_code, 'DetailInboundCallList', 'edit') && $enable_create_edit_delete;
		$enable_delete = $this->M04ControllerAction->check_permission($this->post_code, 'DetailInboundCallList', 'delete') && $enable_create_edit_delete;
		$enable_report_not_effective = $this->M04ControllerAction->check_permission($this->post_code, 'DetailInboundCallList', 'report_not_effective');

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
			$sort_order = $this->Util->getInboundTelListSortOrder($column, $t13_list_items, $enable_delete ? 1 : 0);
		}

		$sort_order_col = isset($sort_order[0]) ? $sort_order[0] : null;
		$tel_lists = $this->T17InboundTelList->getTelByCallListId($call_list_id, $limit, $page, $sort_order_col, $filter, $t13_list_items);
		$json_data["total_rows"] = $this->T17InboundTelList->getListByCallListIdCount($call_list_id, $filter, $t13_list_items);

		if ($enable_edit) {
			$headers[] = 'アクション';
		}

		$is_disable = $enable_report_not_effective ? '' : 'disabled'; /*Edit by Giang - #6740 - enable udpate muko anytime*/

		foreach ($tel_lists as $arr_list) {
			// 20160530 Edit by Giang - Comment out muko
			// $muko_flag = ($arr_list['T17InboundTelList']['muko_flag'] == 'Y')?'checked':'';
			$json_row = array();
			if ($enable_delete) {
				$json_row['selectItem'] = '<input class="select_item" type="checkbox" name="cbSelect[' . $arr_list['T17InboundTelList']['id'] . ']" id="cbSelect[' . $arr_list['T17InboundTelList']['id'] . ']" value="' . $arr_list['T17InboundTelList']['id'] . '" onclick="updateCheckStatus(\'bundleCheckbox\');">'
					. '<label class="label_select_item" for="cbSelect[' . $arr_list['T17InboundTelList']['id'] . ']" style="margin-top: 2px;"></label>';
			}
			$json_row['dummy_gs_id_string'] = $arr_list['T17InboundTelList']['tel_no'];
			foreach ($t13_list_items as $t13_list_item) {
				$key = $t13_list_item['T13InboundListItem']['item_name'];

				if (isset($t13_list_item['T13InboundListItem']['item_code']) && ($t13_list_item['T13InboundListItem']['item_code'] == 'birthday')) {
					$json_row[$key] = $this->displayDate($arr_list['T17InboundTelList'][$t13_list_item['T13InboundListItem']['column']]);
				} else {
					// 20160404 Edit by Giang - #6740: check item main unique
					$json_row[$key] = isset($arr_list['T17InboundTelList'][$t13_list_item['T13InboundListItem']['column']]) ? $arr_list['T17InboundTelList'][$t13_list_item['T13InboundListItem']['column']] : '';
				}
			}
			// 20160530 Edit by Giang - Comment out muko
			// $json_row['無効'] = '<input class="inefficient '.$is_disable.'" type="checkbox" name="noEffect[' . $arr_list['T17InboundTelList']['id'] . ']" id="noEffect[' . $arr_list['T17InboundTelList']['id'] . ']" tel_list_id="' . $arr_list['T17InboundTelList']['id'] . '"' . $muko_flag . ' ' . $is_disable . '>'
			// 	. '<label for="noEffect[' . $arr_list['T17InboundTelList']['id'] . ']" style="margin-top: 2px;"></label>';
			if ($enable_edit) {
				$json_row['アクション'] = '<a href="javascript:void(0);" class="iconCenterFormat ajax-link lnkEdit" tel_list_id="'.$arr_list['T17InboundTelList']['id'].'"><i title="編集" data-toggle="tooltip" class="glyphicon glyphicon-edit icon-white" ></i></a>';

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

	// 20160404 Add by Giang - #6740: check item main unique - Begin
	function check_item_main_valid() {
		$item_main = $this->data['item_main'];
		$call_list_id = $this->ESession->getCallListId($this);
		$t13_list_item = $this->T13InboundListItem->getColumnListByItemName($call_list_id, $item_main);
		$item_main_col = $t13_list_item['T13InboundListItem']['column'];

		$arr_item_main = $this->T17InboundTelList->getDataItemMainByIdAndItemMain($call_list_id, $item_main_col);
		$arr_item_main_diff = array_diff($arr_item_main, array(''));
		$arr_item_main_unique = array_unique($arr_item_main_diff);
		if (count($arr_item_main) == count($arr_item_main_unique)) {
			echo 'true';
			exit;
		}
		echo 'false';
		exit;
	}

	function check_insert_update_item_main() {
		$data = $this->data;
		$call_list_id = $this->ESession->getCallListId($this);
		$t13_list_item = $this->T13InboundListItem->getColumnListByListId($call_list_id); // 20160406 Edit by Giang - #6740: check item main unique
		$item_main_col = $t13_list_item['T13InboundListItem']['column'];
		$item_main_val = $data[$item_main_col];

		$tel_info = $this->T17InboundTelList->getTelByIdAndItemMain($call_list_id, $item_main_col, $item_main_val); // 20160406 Edit by Giang - #6740: check item main unique

		if(isset($tel_info["T17InboundTelList"]['id'])){ // 20160406 Edit by Giang - #6740: check item main unique
			if (!empty($data['t17_tel_id']) && ($data['t17_tel_id'] == $tel_info['T17InboundTelList']['id'])) { // 20160406 Edit by Giang - #6740: check item main unique
				echo "true";
				exit;
			}
			echo "false";
		}else{
			echo "true";
		}
		exit;
	}
	// 20160404 Add by Giang - #6740: check item main unique - End

	function update_tel_list_name() {
		if (empty($this->data) || empty($this->data['callListId']) || empty($this->data['listName'])) {
			echo 'systemerror';
			exit;
		}
		$list_name = $this->data['listName'];
		$call_list_id = $this->data['callListId'];
		$item_main = $this->data['item_main'];

		$info_list = $this->T16InboundCallList->getListInfoById($call_list_id);
		if (!isset($info_list["T16InboundCallList"]["id"]) || empty($info_list["T16InboundCallList"]["id"])) {
			echo "err_not_exist";
			exit;
		}
		$check_lock = $this->T92Lock->getInfoLock('inbound_call_list', $this->ESession->getCallListId($this));
		if (!empty($check_lock)) {
			echo 'systemerror';
			exit;
		}

		$lock_new = $this->create_lock('inbound_call_list', $this->ESession->getCallListId($this), __FUNCTION__);
		if (!$lock_new) {
			echo 'systemerror';
			exit;
		}

		if ($this->data['listTestFlag'] == 'true') {
			$list_test_flag = 1;
		} else {
			$list_test_flag = 0;
		}

		//Save data to DB
		$dsT16InboundCallList = $this->T16InboundCallList->getDataSource();
		$dsT16InboundCallList->begin($this);

		$data_call_list['T16InboundCallList']['id'] = $call_list_id;
		$data_call_list['T16InboundCallList']['list_name'] = $list_name;
		$data_call_list['T16InboundCallList']['item_main'] = $item_main;
		$data_call_list['T16InboundCallList']['list_test_flag'] = $list_test_flag;
		$data_call_list['T16InboundCallList']['update_user'] = $this->ESession->getUserId($this);
		$data_call_list['T16InboundCallList']['update_program'] = $this->name.'_'.__FUNCTION__;

		$call_list = $this->T16InboundCallList->save($data_call_list['T16InboundCallList']);

		if(!$call_list || (isset($lock_new) && !empty($lock_new) && !$this->update_lock($lock_new, __FUNCTION__))){
			$dsT16InboundCallList->rollback($this);
			$this->log("発信規制番号登録：失敗");
			echo 'systemerror';
			exit;
		}

		$dsT16InboundCallList->commit($this);
		$results = Array();
		$results['status'] = 'save';
		$item_column = $this->T13InboundListItem->getColumnListByItemName($call_list_id, $item_main);
		$item_column = $item_column['T13InboundListItem']['column'];
		$results['item_column'] = $item_column;
		echo json_encode($results);
		exit;
	}

	function check_info_tel() {
		if (empty($this->data)) {
			echo 'systemerror';
			exit;
		}

		$call_list_id = $this->ESession->getCallListId($this);
		$info_list = $this->T16InboundCallList->getListInfoById($call_list_id);
		if (!isset($info_list["T16InboundCallList"]["id"]) || empty($info_list["T16InboundCallList"]["id"])) {
			//リスト存在しない
			echo "err_list_not_exist";
			exit;
		}

		$info_schedule = $this->T25Inbound->getScheduleByListId($call_list_id);
		foreach ($info_schedule as $schedule) {
			if (isset($schedule["T25Inbound"]["id"]) && $schedule["T25Inbound"]["status"] != STATUS_INBOUND_END) {
				echo "err_used";
				exit;
			}
		}

		if (isset($this->data['action']) && ($this->data['action'] == 'add')) {
			$max_tel_param = $this->M99SystemParameter->getByFunctionIdAndParameterId('LIST', 'MAX_INBOUND_TEL');
			if ($info_list['T16InboundCallList']['tel_total'] >= $max_tel_param['M99SystemParameter']['parameter_value']) {
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
			$info_tel = $this->T17InboundTelList->getTelInfoById($id);
			if(empty($info_tel)){
				echo "err_tel_not_exist";
				exit;
			}
		}
		echo 'success';
		exit;
	}

	function delete_tel() {
		if (empty($this->data) || empty($this->data['tel_list_ids'])) {
			echo 'systemerror';
			exit;
		}
		$tel_list_ids = $this->data['tel_list_ids'];
		$call_list_id = $this->ESession->getCallListId($this);

		$dsT17InboundTelList = $this->T17InboundTelList->getDataSource();
		$dsT17InboundTelList->begin($this);

		$update_user = $this->ESession->getUserId($this);
		$update_program = $this->name.'_'.__FUNCTION__;

		$query = "UPDATE t17_inbound_tel_lists ".
			"SET del_flag='Y', update_user='$update_user', update_program='$update_program'".
			"WHERE id IN (".implode(',', $tel_list_ids).");";
		if ($this->T17InboundTelList->query($query)) {
			$dsT17InboundTelList->rollback($this);
			echo 'systemerror';
			exit;
		}

		$dsT17InboundTelList->commit($this);

		// $batch_result = $this->batch_edit_calllist();
		/*$arr_schedule = $this->T20OutSchedule->getScheduleByListNo($call_list_id, STATUS_NO_CALL);
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
			$call_list = $this->T16InboundCallList->getListInfoById($call_list_id);
			$tel_total = $call_list['T16InboundCallList']['tel_total'];
			$tel_total_new = (int)$tel_total - count($tel_list_ids);
			if (!$this->update_tel_total_call_list($call_list_id, $tel_total_new, $update_program)) {
				echo 'systemerror';
				exit;
			}
		}*/
		$call_list = $this->T16InboundCallList->getListInfoById($call_list_id);
		$tel_total = $call_list['T16InboundCallList']['tel_total'];
		$tel_total_new = (int)$tel_total - count($tel_list_ids);
		if (!$this->update_tel_total_call_list($call_list_id, $tel_total_new, $update_program)) {
			echo 'systemerror';
			exit;
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

	function update_tel_total_call_list($call_list_id = null, $tel_total = null, $function = null) {
		$dsT16InboundCallList = $this->T16InboundCallList->getDataSource();
		$dsT16InboundCallList->begin($this);

		$call_list['T16InboundCallList']['id'] = $call_list_id;
		$call_list['T16InboundCallList']['update_user'] = $this->ESession->getUserId($this);
		$call_list['T16InboundCallList']['update_program'] = $function;
		$call_list['T16InboundCallList']['tel_total'] = $tel_total;

		if (!$this->T16InboundCallList->save($call_list)) {
			$dsT16InboundCallList->rollback($this);
			return false;
		}

		$dsT16InboundCallList->commit($this);
		return true;
	}

	// 20160530 Edit by Giang - Comment out muko - Begin
	/*function inefficient_tel() {
		$enable_report_not_effective = $this->M04ControllerAction->check_permission($this->post_code, 'DetailInboundCallList', 'report_not_effective');
		if (empty($this->data) || empty($this->data['tel_list_ids']) || !$enable_report_not_effective) {
			$results = array(
				'status' => 'systemerror'
			);
			echo json_encode($results);
			exit;
		}
		$arr_tel_muko = array();
		$arr_tel_unmuko = array();
		$str_tel_num_muko = "";
		$str_tel_num_unmuko = "";
		$tel_list_ids = $this->data['tel_list_ids'];
		$list_id = $this->ESession->getCallListId($this);
		$info_column = $this->T13InboundListItem->getTelNumColumn($list_id);
		$tel_column = $info_column["T13InboundListItem"]["column"];
		$dsT17InboundTelList = $this->T17InboundTelList->getDataSource();
		$dsT17InboundTelList->begin($this);

		$time = date('Y-m-d H:i:s', time());
		foreach ($tel_list_ids as $tel_list_id => $muko_flag) {
			$arr_list = $this->T17InboundTelList->findById($tel_list_id);
			$tel_no = $arr_list["T17InboundTelList"][$tel_column];
			if ($muko_flag == "Y") {
				array_push($arr_tel_muko, $tel_no);
			} else {
				array_push($arr_tel_unmuko, $tel_no);
			}
			$arr_list['T17InboundTelList']['muko_flag'] = $muko_flag;
			$arr_list['T17InboundTelList']['muko_modified'] = $time;
			$arr_list['T17InboundTelList']['update_user'] = $this->ESession->getUserId($this);
			$arr_list['T17InboundTelList']['update_program'] = $this->name.'_'.__FUNCTION__;

			if (!$this->T17InboundTelList->save($arr_list)) {
				$dsT17InboundTelList->rollback($this);
				$results = array(
					'status' => 'systemerror'
				);
				echo json_encode($results);
				exit;
			}
		}

		// Add by Giang - #6740 - Run batch update muko - Begin

		$arr_schedule = $this->T25Inbound->getScheduleByListId($list_id, STATUS_INBOUND_MESSAGE);
		$batch_result = 'success';
		if (count($arr_tel_muko) > 0){
			$str_tel_num_muko = implode(',', $arr_tel_muko);
			foreach ($arr_schedule as $arr){
				$inbound_id = $arr["T25Inbound"]["id"];
				$external_number = $arr["T25Inbound"]["external_number"];
				$external_info = $this->M07ServerExternal->getServerExternalByTel($external_number);
				$server_id = $external_info['M07ServerExternal']['in_server_id'];
				$batch_result = $this->batch_update_muko($server_id, $inbound_id, $str_tel_num_muko, 'add');

				if ($batch_result != 'success') {
					$dsT17InboundTelList->rollback($this);
					$results = array('status' => 'systemerror');
					echo json_encode($results);
					exit;
				}
			}
		}
		if (count($arr_tel_unmuko) > 0) {
			$str_tel_num_unmuko = implode(',', $arr_tel_unmuko);
			foreach ($arr_schedule as $arr){
				$inbound_id = $arr["T25Inbound"]["id"];
				$external_number = $arr["T25Inbound"]["external_number"];
				$external_info = $this->M07ServerExternal->getServerExternalByTel($external_number);
				$server_id = $external_info['M07ServerExternal']['in_server_id'];
				$batch_result = $this->batch_update_muko($server_id, $inbound_id, $str_tel_num_unmuko, 'del');

				if ($batch_result != 'success') {
					$dsT17InboundTelList->rollback($this);
					$results = array('status' => 'systemerror');
					echo json_encode($results);
					exit;
				}
			}
		}

		// Add by Giang - #6740 - Run batch update muko - End

		$dsT17InboundTelList->commit($this);
		$using_flag = 0;
		$results = array(
			'status' => 'update_muko',
			'using_flag' => $using_flag
		);
		echo json_encode($results);
		exit;
	}*/
	// 20160530 Edit by Giang - Comment out muko - End

	function check_exist_tel_no() {
		$data = $this->data;
		$call_list_id = $this->ESession->getCallListId($this);
		$tel_number = preg_replace("/\D/", "", $data['tel_number']);
		$tel_list = $this->T17InboundTelList->getByTelNoAndCallListId($tel_number, $data['tel_number_col'], $call_list_id);

		if(isset($tel_list['T17InboundTelList'])){
			if (!empty($data['tel_list_id']) && $data['tel_list_id'] == $tel_list['T17InboundTelList']['id']) {
				echo "true";
				exit;
			}
			echo "false";
		} else {
			echo "true";
		}
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

		//Save data to DB
		$dsT17InboundTelList = $this->T17InboundTelList->getDataSource();
		$dsT17InboundTelList->begin($this);

		$user_id = $this->ESession->getUserId($this);
		$program = $this->name.'_'.__FUNCTION__;
		if (empty($tel_id)) {

			$max_tel_no = $this->T17InboundTelList->getMaxTelNoByCallListId($call_list_id);
			$data_tel['T17InboundTelList']['tel_no'] = $max_tel_no[0]['max_tel_no'] + 1;
			$data_tel['T17InboundTelList']['entry_user'] = $user_id;
			$data_tel['T17InboundTelList']['entry_program'] = $program;

			foreach ($data as $field => $value) {
				if (!empty($field)) {
					$data_tel['T17InboundTelList'][$field] = $value;
				}
			}
			$data_tel['T17InboundTelList']['list_id'] = $call_list_id;
			$tel_list = $this->T17InboundTelList->save($data_tel);
			if(!$tel_list){
				$dsT17InboundTelList->rollback($this);
				$this->log("発信規制番号登録：失敗");
				echo 'systemerror';
				exit;
			}
			$dsT17InboundTelList->commit($this);
			$results['status'] = 'insert';
		} else {
			$check_lock = $this->T92Lock->getInfoLock('t17_inbound_tel_list', $tel_id);
			if (!empty($check_lock)) {
				echo 'systemerror';
				exit;
			}
			$lock_new = $this->create_lock('t17_inbound_tel_list', $tel_id, __FUNCTION__);
			if (!$lock_new) {
				echo 'systemerror';
				exit;
			}
			$tel_list_backup = $this->T17InboundTelList->getTelInfoById($tel_id);
			$data_tel['T17InboundTelList']['update_user'] = $user_id;
			$data_tel['T17InboundTelList']['update_program'] = $program;
			foreach ($data as $field => $value) {
				if (!empty($field)) {
					$data_tel['T17InboundTelList'][$field] = $value;
				}
			}
			$data_tel['T17InboundTelList']['list_id'] = $call_list_id;
			$tel_list = $this->T17InboundTelList->save($data_tel);
			if(!$tel_list || (isset($lock_new) && !empty($lock_new) && !$this->update_lock($lock_new, __FUNCTION__))){
				$dsT17InboundTelList->rollback($this);
				$this->log("発信規制番号登録：失敗");
				echo 'systemerror';
				exit;
			}
			$dsT17InboundTelList->commit($this);
			$results['status'] = 'update';
		}

		// $batch_result = $this->batch_edit_calllist();
		// $arr_schedule = $this->T20OutSchedule->getScheduleByListNo($call_list_id, STATUS_NO_CALL);
		$batch_result = 'success';
		/*foreach ($arr_schedule as $arr){
			$info_column = $this->T13InboundListItem->getTelNumColumn($call_list_id);
			$tel_column = $info_column["T13InboundListItem"]["column"];
			$tel_no = $data[$tel_column];
			$schedule_id = $arr["T20OutSchedule"]["id"];
			$template_id = $arr["T20OutSchedule"]["template_id"];
			$external_number = $arr["T20OutSchedule"]["external_number"];
			$arr_server_info = $this->M01Server->getServerByExternalNumber($external_number, "1");
			$server_id = $arr_server_info["M01Server"]["server_id"];
			$server_ip = $arr_server_info["M01Server"]["server_ip"];
			$local_path  = $arr_server_info["M01Server"]["local_path"];
			$batch_result = $this->batch_edit_calllist($server_id, $server_ip, $local_path, $schedule_id, $template_id, $call_list_id, $tel_no);
		}*/
		if ($batch_result != 'success') {
			if($results['status'] == 'insert'){
				$tel_list_ids = Array($tel_list['T17InboundTelList']['id']);
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
				$call_list = $this->T16InboundCallList->getListInfoById($call_list_id);
				$tel_total = $call_list['T16InboundCallList']['tel_total'] + 1;
				if (!$this->update_tel_total_call_list($call_list_id, $tel_total, $program)) {
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
		$my_result = $this->T92Lock->save($lock);
		if (!$my_result) {
			$this->log("[upload_file][failed][" . __LINE__ . "]" . print_r($my_result, 1));
			$failed_msg = $this->_getErrorMsg();
			$this->log($failed_msg);

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

	function recover_del_flag_tel($tel_list_ids = null, $del_flag = null) {
		$dsT17InboundTelList = $this->T17InboundTelList->getDataSource();
		$dsT17InboundTelList->begin($this);

		$update_user = $this->ESession->getUserId($this);
		$update_program = $this->name.'_'.__FUNCTION__;

		$t11_query_batch = "UPDATE t17_inbound_tel_lists ".
			"SET del_flag='".$del_flag."', update_user='$update_user', update_program='$update_program'".
			"WHERE id IN (".implode(',', $tel_list_ids).");";

		if ($this->T17InboundTelList->query($t11_query_batch)) {
			$dsT17InboundTelList->rollback($this);
			return 'systemerror';
		}

		$dsT17InboundTelList->commit($this);
		return 'done';
	}

	function recover_tel_info($data = null) {
		$dsT17InboundTelList = $this->T17InboundTelList->getDataSource();
		$dsT17InboundTelList->begin($this);

		$data['T17InboundTelList']['update_user'] = $this->ESession->getUserId($this);
		$data['T17InboundTelList']['update_program'] = $this->name.'_'.__FUNCTION__;

		if (!$this->T17InboundTelList->save($data)) {
			$dsT17InboundTelList->rollback($this);
			return 'systemerror';
		}

		$dsT17InboundTelList->commit($this);
		return 'done';
	}

	// 最後に発生したMysqlerrorを拾う。
	function _getErrorMsg() {
		$errInfor = $this->T17InboundTelList->query("show errors limit 0,1");
		$msg = '';
		if (count($errInfor) >0) {
			$msg = implode($errInfor[0][0], ' ');
		}
		return $msg;
	}


	/* Add by Giang - #6740 - Run batch update muko - Begin */
	// 20160530 Edit by Giang - Comment out muko - Begin
	/*function batch_update_muko($server_id, $inbound_id, $str_tel_no, $flag) {
		$result = "success";
		$info_server = $this->M01Server->getInfoServerByServerId($server_id);
		$local_path = $info_server["M01Server"]["local_path"];
		$cmd = "/usr/local/bin/ruby ".$local_path."reject.rb '".$server_id."' '".$inbound_id."' '".$str_tel_no."' '".$flag."'";
		exec($cmd, $shell_result, $shell_result_status);
		if($shell_result_status != 0){
			$result = $shell_result[0];
			$this->log($cmd);
			$this->log($shell_result);
			$this->log($shell_result_status);
			$this->log('BATCH_UPDATE_MUKO_ERROR');
		}
		return $result;
	}*/
	// 20160530 Edit by Giang - Comment out muko - End
	/* Add by Giang - #6740 - Run batch update muko - End */
}
