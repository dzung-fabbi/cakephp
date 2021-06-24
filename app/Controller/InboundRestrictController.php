<?php
App::uses('AppController', 'Controller');

class InboundRestrictController extends AppController {
	var $uses = array('M01Server', 'T18IncomingNgList', 'T19IncomingNgTel', 'M99SystemParameter', 'T25Inbound', 'M90PulldownCode', 'T92Lock', 'M05User', 'M07ServerExternal');

	function index($mode=null, $del_count=null) {
		$max_tel_param = $this->M99SystemParameter->getByFunctionIdAndParameterId('LIST', 'MAX_INCOMING_NG_TEL');
		$this->set('max_tel_param', $max_tel_param);

		$enable_download = $this->M04ControllerAction->check_permission($this->post_code, 'IncomingNg', 'download');
		$enable_create = $this->M04ControllerAction->check_permission($this->post_code, 'IncomingNg', 'create');
		$enable_delete = $this->M04ControllerAction->check_permission($this->post_code, 'IncomingNg', 'delete');
		$enable_download_or_delete = $enable_download || $enable_delete;

		$this->set('enable_download', $enable_download);
		$this->set('enable_create', $enable_create);
		$this->set('enable_delete', $enable_delete);
		$this->set('enable_download_or_delete', $enable_download_or_delete);
	}

	function arr_incoming_ng_list($js_page, $limit, $column) {
		$this->layout = 'ajax';
		$filter = $_GET["filter"];
		$page = $js_page + 1;
		$json_data = Array();
		$json_data["headers"] = Array("NO","リスト名","件数","作成日時","作成者","アクション",);
		$json_data["rows"] = Array();
		$company_id = $this->ESession->getUserCompanyId($this);

		$enable_download = $this->M04ControllerAction->check_permission($this->post_code, 'IncomingNg', 'download');
		$enable_create = $this->M04ControllerAction->check_permission($this->post_code, 'IncomingNg', 'create');
		$enable_delete = $this->M04ControllerAction->check_permission($this->post_code, 'IncomingNg', 'delete');

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
			$sort_order = $this->Util->getListIncomingNgSortOrder($column,$enable_delete || $enable_download ? 1 : 0);
		}

		$sort_order_col = isset($sort_order[0]) ? $sort_order[0] : null;
		$arr_lists = $this->T18IncomingNgList->getListNgByCompanyId($company_id, $limit, $page, $sort_order_col, $filter);

		$json_data["total_rows"] = $this->T18IncomingNgList->getListByCompanyIdCount($company_id, $filter);
		foreach ($arr_lists as $arr_list) {
			$json_row = array();
			$entry_user = $this->M05User->getUserByUserId($arr_list['T18IncomingNgList']['entry_user']);
			$entry_user_name = isset($entry_user["M05User"]['user_name']) ? $entry_user["M05User"]['user_name'] : '';
			if ($enable_delete || $enable_download) {
				$json_row['checkbox'] = '<input type="checkbox" name="call_list_ids[' . $arr_list['T18IncomingNgList']['id'] . ']" id="cbSelect[' . $arr_list['T18IncomingNgList']['id'] . ']" value="' . $arr_list['T18IncomingNgList']['id'] . '" onclick="updateCheckStatus(\'bundleCheckbox\');">'
					. '<label for="cbSelect[' . $arr_list['T18IncomingNgList']['id'] . ']" style="margin-top: 2px;"></label>';
			}
			$json_row['NO'] = str_replace($company_id, '', $arr_list['T18IncomingNgList']['list_ng_no']);
			$json_row['リスト名'] = $arr_list['T18IncomingNgList']['list_name'];
			$json_row['件数'] = $arr_list['T18IncomingNgList']['total'].'件';
			$json_row['作成日時'] = date('Y-m-d H:i', strtotime($arr_list['T18IncomingNgList']['created']));
			$json_row['作成者'] = $entry_user_name;
			$json_row['アクション'] = '<a href="javascript:void(0);" title="編集" data-toggle="tooltip" class="iconCenterFormat ajax-link lnkDetail" call_list_id="'.$arr_list['T18IncomingNgList']['id'].'"><i class="glyphicon glyphicon-edit icon-white" ></i></a>';
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
		if (empty($this->data) || empty($this->data['listName']) || empty($this->data['uploadData'])) {
			echo 'systemerror';
			exit;
		}

		$company_id = $this->ESession->getUserCompanyId($this);
		$max_list_ng_no = $this->T18IncomingNgList->getMaxListNgNoByCompanyId($company_id);

		if ($max_list_ng_no['0']['max_list_ng_no']) {
			$list_ng_no_new = $max_list_ng_no['0']['max_list_ng_no'] + 1;
		} else {
			$list_ng_no_new = '1';
		}

		$user_id = $this->ESession->getUserId($this);
		$program = $this->name.'_'.__FUNCTION__;
		$list_name = $this->data['listName'];
		$uploadData = json_decode($this->data['uploadData']);

		//Save data to DB
		$dsT18IncomingNgList = $this->T18IncomingNgList->getDataSource();
		$dsT19IncomingNgTel = $this->T19IncomingNgTel->getDataSource();
		$dsT18IncomingNgList->begin($this);
		$dsT19IncomingNgTel->begin($this);

		$this->T18IncomingNgList->create();
		$data_call_list_ng['T18IncomingNgList']['company_id'] = $company_id;
		$data_call_list_ng['T18IncomingNgList']['list_ng_no'] = $list_ng_no_new;
		$data_call_list_ng['T18IncomingNgList']['list_name'] = $list_name;
		$data_call_list_ng['T18IncomingNgList']['total'] = count($uploadData);
		$data_call_list_ng['T18IncomingNgList']['entry_user'] = $user_id;
		$data_call_list_ng['T18IncomingNgList']['entry_program'] = $program;
		$call_list_ng = $this->T18IncomingNgList->save($data_call_list_ng);

		if(!$call_list_ng){
			$dsT18IncomingNgList->rollback($this);
			$dsT19IncomingNgTel->rollback($this);
			echo 'systemerror';
			exit;
		}

		$call_list_ng_id = $call_list_ng['T18IncomingNgList']['id'];
		$created = date('Y-m-d H:i:s a', time());

		$query_base = "INSERT INTO t19_incoming_ng_tels ".
			"(list_ng_id, no, tel_no, memo, entry_user, entry_program, created) " .
			"VALUES ";
		$query = $query_base;
		$count = 0;

		for ($i = 0; $i < count($uploadData); $i++) {
			$count ++;
			$tel_number = $uploadData[$i][0];
			$memo = isset($uploadData[$i][1]) ? $uploadData[$i][1] : null;

			if($count % 10000 == 0 || $count == count($uploadData)){
				$query = $query."('".$call_list_ng_id."','".$count."','".$tel_number."','".$memo."','".$user_id."','".$program."','".$created."');";
				if ($this->T19IncomingNgTel->query($query)) {
					$dsT18IncomingNgList->rollback($this);
					$dsT19IncomingNgTel->rollback($this);
					echo 'systemerror';
					exit;
				}
				$query = $query_base;
			}else{
				$query = $query."('".$call_list_ng_id."','".$count."','".$tel_number."','".$memo."','".$user_id."','".$program."','".$created."'), ";
			}
		}

		$dsT18IncomingNgList->commit($this);
		$dsT19IncomingNgTel->commit($this);

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
		$info_list = $this->T18IncomingNgList->getByListName($data['list_name'], $company_id);
		if(isset($info_list["T18IncomingNgList"]["id"]) && !empty($info_list["T18IncomingNgList"]["id"])){
			if (isset($data['list_name_old']) && $data['list_name_old'] == $info_list['T18IncomingNgList']['list_name']) {
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
			$tel_lists = $this->T19IncomingNgTel->getAllTelByListNgId($call_list_id);

			if (!empty($tel_lists)) {
				// $headers = Array('電話番号', 'メモ');
				// $data_csv_tmp[$call_list_id][] = $headers;

				foreach ($tel_lists as $tel_list) {
					$row =  Array($tel_list['T19IncomingNgTel']['tel_no'], $tel_list['T19IncomingNgTel']['memo']);
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
			$this->redirect(array('controller' => 'InboundRestrict', 'action' => 'index'));
		}

		$file_out_name = date('Ymdhis', time()) . '_着信拒否リスト.zip';
		$file_out_name = mb_convert_encoding($file_out_name, "SJIS-win", "UTF-8");
		$this->Csv->createZip($file_out_name);

		foreach ($data_csv as $key => $data) {

			$call_list = $this->T18IncomingNgList->getListNgInfoById($key);
			if ($call_list) {
				foreach ($data as $row) {
					$this->Csv->addRow($row);
				}

				$title_csv = $call_list['T18IncomingNgList']['list_name'] . '.csv';
				$title_csv = mb_convert_encoding($title_csv, "SJIS-win", "UTF-8");
				$this->Csv->addToZip($title_csv, 'SJIS-win');
				$this->Csv->clear();
			}
		}
		$this->Session->delete('data_csv_download');
		echo $this->Csv->renderZip('SJIS-win');
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
			$info_list = $this->T18IncomingNgList->getListNgInfoById($id);
			if (!isset($info_list["T18IncomingNgList"]["id"]) || empty($info_list["T18IncomingNgList"]["id"])) {
				//リスト存在しない
				echo "err_not_exist";
				exit;
			}

			$info_schedule = $this->T25Inbound->getScheduleByListNgId($id);
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

	function delete() {
		$data = $this->data;
		if (empty($data)) {
			echo 'systemerror';
			exit;
		}

		$dsT18IncomingNgList = $this->T18IncomingNgList->getDataSource();
		$dsT19IncomingNgTel = $this->T19IncomingNgTel->getDataSource();
		$dsT18IncomingNgList->begin($this);
		$dsT19IncomingNgTel->begin($this);

		$update_user = $this->ESession->getUserId($this);
		$update_program = $this->name.'_'.__FUNCTION__;
		$time = date('Y-m-d H:i:s a', time());

		$call_list_ids = $data['call_list_ids'];

		$query1 = "UPDATE t18_incoming_ng_lists ".
			"SET del_flag='Y', update_user='$update_user', update_program='$update_program' ".
			"WHERE id IN (".implode(',', $call_list_ids).");";
		if ($this->T18IncomingNgList->query($query1)) {
			$dsT18IncomingNgList->rollback($this);
			echo 'systemerror';
			exit;
		}

		$query2 = "UPDATE t19_incoming_ng_tels ".
			"SET del_flag='Y', update_user='$update_user', update_program='$update_program', modified='$time' ".
			"WHERE del_flag = 'N' AND list_ng_id IN (".implode(',', $call_list_ids).");";
		if ($this->T19IncomingNgTel->query($query2)) {
			$dsT18IncomingNgList->rollback($this);
			$dsT19IncomingNgTel->rollback($this);
			echo 'systemerror';
			exit;
		}

		$dsT18IncomingNgList->commit($this);
		$dsT19IncomingNgTel->commit($this);

		$results = Array();
		$results['status'] = 'deleted';
		$results['sortColumn'] = $this->ESession->getSortColumn($this);
		$results['sortType'] = $this->ESession->getSortType($this);

		$company_id = $this->ESession->getUserCompanyId($this);
		$incoming_ng_count = $this->T18IncomingNgList->getListByCompanyIdCount($company_id);
		$max_page = round($incoming_ng_count / PAGE_LENGTH);
		$current_page = $this->ESession->getPage($this);
		if (($current_page == $max_page) && (count($call_list_ids) == ($incoming_ng_count % PAGE_LENGTH)) && ($current_page > 0)) {
			$current_page--;
		}
		$results['page'] = $current_page;

		echo json_encode($results);
		exit;
	}

	function detail() {
		$data = $this->data;
		if (!empty($data['edit_call_list_id'])) {
			//set session list_id
			$this->ESession->setCallListId($data['edit_call_list_id'],$this);
			$list = $this->T18IncomingNgList->getListNgInfoById($data['edit_call_list_id']);

			$schedule = $this->T25Inbound->getScheduleByListNgId($data['edit_call_list_id'], Array(STATUS_INBOUND_MESSAGE, STATUS_INBOUND_BUSY));
			$enable_create_edit_delete = empty($schedule) ? true : false;
			if (!$enable_create_edit_delete) {
				$this->Session->setFlash('着信設定されている着信拒否リストの為編集できません。', 'default', array('class' => 'flash_msg error'));
			}

			$enable_edit_call_list = $this->M04ControllerAction->check_permission($this->post_code, 'IncomingNg', 'edit') && $enable_create_edit_delete;
			$enable_create = $this->M04ControllerAction->check_permission($this->post_code, 'IncomingNg', 'create');
			$enable_delete = $this->M04ControllerAction->check_permission($this->post_code, 'IncomingNg', 'delete'); /*Edit by Giang - #6711 - enable delete tel_ng anytime*/

			$this->set("list", $list);
			$this->set('enable_edit_call_list', $enable_edit_call_list);
			$this->set('enable_create', $enable_create);
			$this->set('enable_delete', $enable_delete);

			$max_tel_param = $this->M99SystemParameter->getByFunctionIdAndParameterId('LIST', 'MAX_INCOMING_NG_TEL');
			$this->set('max_tel_param', $max_tel_param);
		}else{
			$this->redirect(array('controller' => 'InboundRestrict', 'action' => 'index'));
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

		/*Delete by Giang - #6711 - enable delete tel_ng anytime*/
		/*$schedule = $this->T25Inbound->getScheduleByListNgId($call_list_id, Array(STATUS_INBOUND_MESSAGE, STATUS_INBOUND_BUSY));
		$enable_create_edit_delete = empty($schedule) ? true : false;*/

		$enable_delete = $this->M04ControllerAction->check_permission($this->post_code, 'IncomingNg', 'delete'); /*Edit by Giang - #6711 - enable delete tel_ng anytime*/

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
			$sort_order = $this->Util->getTelListIncomingNgSortOrder($column, $enable_delete ? 1 : 0);
		}

		$sort_order_col = isset($sort_order[0]) ? $sort_order[0] : null;
		$tel_lists = $this->T19IncomingNgTel->getTelByListNgId($call_list_id, $limit, $page, $sort_order_col, $filter);
		$json_data["total_rows"] = $this->T19IncomingNgTel->getListByListNgIdCount($call_list_id, $filter);

		foreach ($tel_lists as $arr_list) {
			$json_row = array();
			if ($enable_delete) {
				$json_row['selectItem'] = '<input class="select_item" type="checkbox" name="cbSelect[' . $arr_list['T19IncomingNgTel']['id'] . ']" id="cbSelect[' . $arr_list['T19IncomingNgTel']['id'] . ']" value="' . $arr_list['T19IncomingNgTel']['id'] . '" onclick="updateCheckStatus(\'bundleCheckbox\');">'
					. '<label class="label_select_item" for="cbSelect[' . $arr_list['T19IncomingNgTel']['id'] . ']" style="margin-top: 2px;"></label>';
			}
			$json_row['NO'] = $arr_list['T19IncomingNgTel']['no'];
			$json_row['電話番号'] = $arr_list['T19IncomingNgTel']['tel_no'];
			$json_row['メモ'] = empty($arr_list['T19IncomingNgTel']['memo']) ? '' : $arr_list['T19IncomingNgTel']['memo'];

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

	function update_incoming_ng_list() {
		if (empty($this->data) || empty($this->data['callListId']) || empty($this->data['listName'])) {
			echo 'systemerror';
			exit;
		}

		$list_name = $this->data['listName'];
		$call_list_id = $this->data['callListId'];

		//Save data to DB
		$dsT18IncomingNgList = $this->T18IncomingNgList->getDataSource();
		$dsT18IncomingNgList->begin($this);

		$data_call_list['T18IncomingNgList']['id'] = $call_list_id;
		$data_call_list['T18IncomingNgList']['list_name'] = $list_name;
		$data_call_list['T18IncomingNgList']['update_user'] = $this->ESession->getUserId($this);
		$data_call_list['T18IncomingNgList']['update_program'] = $this->name.'_'.__FUNCTION__;

		$call_list = $this->T18IncomingNgList->save($data_call_list['T18IncomingNgList']);
		if(!$call_list){
			$dsT18IncomingNgList->rollback($this);
			echo 'systemerror';
			exit;
		}

		$dsT18IncomingNgList->commit($this);
		echo 'save';
		exit;
	}

	function check_info_tel() {
		if (empty($this->data)) {
			$this->redirect(array('controller' => 'InboundRestrict', 'action' => 'index'));
		}

		$results = Array();
		$call_list_id = $this->ESession->getCallListId($this);
		$info_list = $this->T18IncomingNgList->getListNgInfoById($call_list_id);
		if (!isset($info_list["T18IncomingNgList"]["id"]) || empty($info_list["T18IncomingNgList"]["id"])) {
			//リスト存在しない
			$results['status'] = 'err_list_not_exist';
			echo json_encode($results);
			exit;
		}

		if (isset($this->data['action']) && isset($this->data['uploadData']) && ($this->data['action'] == 'add')) {
			$uploadData = json_decode($this->data['uploadData']);
			$max_tel_param = $this->M99SystemParameter->getByFunctionIdAndParameterId('LIST', 'MAX_INCOMING_NG_TEL');
			$max_tel_param = $max_tel_param['M99SystemParameter']['parameter_value'];
			$current_tel_total = $this->T19IncomingNgTel->getTelTotalByCallListNgId($call_list_id);
			$new_tel_total = $current_tel_total + count($uploadData);
			$tel_total_over = $new_tel_total - $max_tel_param;

			if ($tel_total_over > 0) {
				$results['status'] = 'tel_total_over';
				$results['err_msg'] = Array('10000件を超えるの為追加できません。');
				echo json_encode($results);
				exit;
			}

			$tel_no_tmp = Array();
			$error_tmp = Array();
			$current_tel_no_lists = $this->T19IncomingNgTel->getTelListByCallListNgId($call_list_id);
			foreach ($current_tel_no_lists as $tel_no) {
				$tel_no_tmp[] = $tel_no['T19IncomingNgTel']['tel_no'];
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
			$info_tel = $this->T19IncomingNgTel->getTelInfoById($id);
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

	function add_file() {
		setlocale(LC_ALL, 'ja_JP.UTF-8');
		if (empty($this->data) || empty($this->data['uploadData'])) {
			echo 'systemerror';
			exit;
		}
		$list_ng_id = $this->ESession->getCallListId($this);
		$uploadData = json_decode($this->data['uploadData']);
		$user_id = $this->ESession->getUserId($this);
		$program = $this->name.'_'.__FUNCTION__;
		$results = Array();

		//T18 insert
		$current_tel_total = $this->T19IncomingNgTel->getTelTotalByCallListNgId($list_ng_id);
		$total_new_record = count($uploadData);
		$tel_total = $current_tel_total + $total_new_record;
		$dsT18IncomingNgList = $this->T18IncomingNgList->getDataSource();
		$dsT18IncomingNgList->begin($this);

		$call_list['T18IncomingNgList']['id'] = $list_ng_id;
		$call_list['T18IncomingNgList']['total'] = $tel_total;
		$call_list['T18IncomingNgList']['update_user'] = $user_id;
		$call_list['T18IncomingNgList']['update_program'] = $program;

		if (!$this->T18IncomingNgList->save($call_list)) {
			$dsT18IncomingNgList->rollback($this);
			echo 'systemerror';
			exit;
		}

		//T19 insert
		$dsT19IncomingNgTel = $this->T19IncomingNgTel->getDataSource();
		$dsT19IncomingNgTel->begin($this);
		$created = date('Y-m-d H:i:s a', time());
		$max_tel_no = $this->T19IncomingNgTel->getMaxTelNoByCallListNgId($list_ng_id);
		$max_tel_no = $max_tel_no[0]['max_tel_no'];
		$query_base = "INSERT INTO t19_incoming_ng_tels ".
			"(list_ng_id, no, tel_no, memo, entry_user, entry_program, created) " .
			"VALUES ";
		$query = $query_base;
		$count = 0;
		$str_tel_num = '';
		$count_tmp = $total_new_record - 1;

		for ($i = 0; $i < $total_new_record; $i++) {
			$max_tel_no = $max_tel_no + 1;
			$count ++;
			$tel_number = $uploadData[$i][0];
			$memo = isset($uploadData[$i][1]) ? $uploadData[$i][1] : null;

			$str_tel_num = $str_tel_num . $uploadData[$i][0];
			if ($i < $count_tmp) {
				$str_tel_num = $str_tel_num . ',';
			}

			if($count % 10000 == 0 || $count == count($uploadData)){
				$query = $query."('".$list_ng_id."','".$max_tel_no."','".$tel_number."','".$memo."','".$user_id."','".$program."','".$created."');";
				if ($this->T19IncomingNgTel->query($query)) {
					$dsT18IncomingNgList->rollback($this);
					$dsT19IncomingNgTel->rollback($this);
					echo 'systemerror';
					exit;
				}
				$query = $query_base;
			}else{
				$query = $query."('".$list_ng_id."','".$max_tel_no."','".$tel_number."','".$memo."','".$user_id."','".$program."','".$created."'), ";
			}
		}

		// 20160516 - Add by Giang - run batch when add or del tel - Begin
		$arr_schedule = $this->T25Inbound->getScheduleByListNgId($list_ng_id, STATUS_INBOUND_MESSAGE);
		$batch_result = 'success';
		foreach ($arr_schedule as $arr){
			$inbound_id = $arr["T25Inbound"]["id"];
			$external_number = $arr["T25Inbound"]["external_number"];
			$external_info = $this->M07ServerExternal->getServerExternalByTel($external_number);
			$server_id = $external_info['M07ServerExternal']['in_server_id'];
			$batch_result = $this->batch_edit_incoming_ng_list($server_id, $inbound_id, $str_tel_num, 'add');

			if ($batch_result != 'success') {
				$dsT18IncomingNgList->rollback($this);
				$dsT19IncomingNgTel->rollback($this);
				echo 'systemerror';
				exit;
			}
		}

		// 20160516 - Add by Giang - run batch when add or del tel - End
		$dsT18IncomingNgList->commit($this);
		$dsT19IncomingNgTel->commit($this);
		$results['status'] = 'save';
		$results['sortColumn'] = $this->ESession->getSortColumn($this);
		$results['sortType'] = $this->ESession->getSortType($this);
		$results['page'] = $this->ESession->getPage($this);
		echo json_encode($results);
		exit;
	}

	function delete_tel() {
		if (empty($this->data) || empty($this->data['tel_list_ids']) || empty($this->data['call_list_id'])) {
			echo 'systemerror';
			exit;
		}
		$tel_ng_ids = $this->data['tel_list_ids'];
		$list_ng_id = $this->data['call_list_id'];
		$user_id = $this->ESession->getUserId($this);
		$program = $this->name.'_'.__FUNCTION__;

		$arr_tel = $this->T19IncomingNgTel->getTelNumByIds($tel_ng_ids);
		$str_tel_num = implode(',', $arr_tel);

		//T14件数更新
		$current_tel_total = $this->T19IncomingNgTel->getTelTotalByCallListNgId($list_ng_id);
		$tel_total = $current_tel_total - count($tel_ng_ids);
		$dsT18IncomingNgList = $this->T18IncomingNgList->getDataSource();
		$dsT18IncomingNgList->begin($this);

		$call_list['T18IncomingNgList']['id'] = $list_ng_id;
		$call_list['T18IncomingNgList']['total'] = $tel_total;
		$call_list['T18IncomingNgList']['update_user'] = $user_id;
		$call_list['T18IncomingNgList']['update_program'] = $program;

		if (!$this->T18IncomingNgList->save($call_list)) {
			$dsT18IncomingNgList->rollback($this);
			echo 'systemerror';
			exit;
		}

		$dsT19IncomingNgTel = $this->T19IncomingNgTel->getDataSource();
		$dsT19IncomingNgTel->begin($this);
		$query = "UPDATE t19_incoming_ng_tels ".
			"SET del_flag='Y', update_user='$user_id', update_program='$program'".
			"WHERE id IN (".implode(',', $tel_ng_ids).");";
		if ($this->T19IncomingNgTel->query($query)) {
			$dsT18IncomingNgList->rollback($this);
			$dsT19IncomingNgTel->rollback($this);
			echo 'systemerror';
			exit;
		}

		// 20160516 - Add by Giang - run batch when add or del tel - Begin
		$arr_schedule = $this->T25Inbound->getScheduleByListNgId($list_ng_id, STATUS_INBOUND_MESSAGE);
		$batch_result = 'success';
		foreach ($arr_schedule as $arr){
			$inbound_id = $arr["T25Inbound"]["id"];
			$external_number = $arr["T25Inbound"]["external_number"];
			$external_info = $this->M07ServerExternal->getServerExternalByTel($external_number);
			$server_id = $external_info['M07ServerExternal']['in_server_id'];
			$batch_result = $this->batch_edit_incoming_ng_list($server_id, $inbound_id, $str_tel_num, 'del');

			if ($batch_result != 'success') {
				$dsT18IncomingNgList->rollback($this);
				$dsT19IncomingNgTel->rollback($this);
				echo 'systemerror';
				exit;
			}
		}
		// 20160516 - Add by Giang - run batch when add or del tel - End
		$dsT18IncomingNgList->commit($this);
		$dsT19IncomingNgTel->commit($this);

		$results = Array();
		$results['status'] = 'del_tel_list_only';
		$results['sortColumn'] = $this->ESession->getSortColumn($this);
		$results['sortType'] = $this->ESession->getSortType($this);

		$max_page = round($tel_total / PAGE_LENGTH);
		$current_page = $this->ESession->getPage($this);
		if (($current_page == $max_page) && (count($tel_ng_ids) == ($tel_total % PAGE_LENGTH))) {
			$current_page--;
		}
		$results['page'] = $current_page;

		echo json_encode($results);
		exit;
	}

	function batch_edit_incoming_ng_list($server_id, $inbound_id, $str_tel_no, $flag) {
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
			$this->log("拒否コマンド実行：失敗");
		}
		return $result;
	}
}