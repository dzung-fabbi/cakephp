<?php
App::uses('AppController', 'Controller');

class SmsSendListController extends AppController {
	var $uses = array('M01Server', 'T100SmsSendList', 'T101SmsTelList', 'T102SmsListItem', 'M99SystemParameter','T200SmsSendSchedule', 'M90PulldownCode', 'T92Lock', 'M05User', 'M08SmsApiInfo',
		'T300SmsTemplate', );

	const ITEM_REGEX = '/{.*?}/';
	const LEFT_BRACE_REGEX = '/{/';
	const RIGHT_BRACE_REGEX = '/}/';

	/** Index method. Refer to View/SmsSendList/index.tpl
	 * @param	: $mode. $mode value can be: save, systemerror
	 * @param	: $del_count is number lists be deleted. Using when delete list
	 */
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

		//Get MAX_SMS_TEL. Max item to upload
		$max_tel_param = $this->M99SystemParameter->getByFunctionIdAndParameterId('LIST_SMS', 'MAX_SMS_TEL');
		$this->set('max_tel_param', $max_tel_param);

		// Get all of list item from PulldownCode table
		$list_item_fields = $this->M90PulldownCode->getSelectOption('list_item');
		$this->set('list_item_fields', json_encode($list_item_fields));
		$headers = Array();
		foreach ($list_item_fields as $list_item) {
			$headers[$list_item['M90PulldownCode']['item_code']] = $list_item['M90PulldownCode']['item_name'];
		}
		$this->set('headers', $headers);

		// Get using download function authority flag
		$enable_download = $this->M04ControllerAction->check_permission($this->post_code, 'SmsSendList', 'download');
		// Get using create function authority flag
		$enable_create = $this->M04ControllerAction->check_permission($this->post_code, 'SmsSendList', 'create');
		// Get using delete function authority flag
		$enable_delete = $this->M04ControllerAction->check_permission($this->post_code, 'SmsSendList', 'delete');
		$this->set('enable_download', $enable_download);
		$this->set('enable_create', $enable_create);
		$this->set('enable_delete', $enable_delete);
	}

    /** Create lists data and save to session for download
	 * @param array list_id be sent by ajax request
	 * @return response ajax request a "success" string
	 */
	function buffer_csv_data() {
		$data = $this->data;
		if (empty($data)) {
			$this->redirect(array('controller' => 'SmsSendList', 'action' => 'index'));
		}

		$data_csv = $this->ESession->getDataCsvDownload($this);
		if(isset($data_csv)){
			$this->Session->delete('data_csv_download');
		}

		$list_ids = $data['list_ids'];
		$data_csv_tmp = Array();

		foreach ($list_ids as $list_id) {
			$tel_lists = $this->T101SmsTelList->getAllTelByListId($list_id);
			$t102_list_items = $this->T102SmsListItem->getTitleByListId($list_id);

			if ($tel_lists && !empty($t102_list_items)) {
				$headers = Array();
				foreach ($t102_list_items as $t102_list_item) {
					$headers[] = $t102_list_item['T102SmsListItem']['item_name'];
				}
				$data_csv_tmp[$list_id][] = $headers;

				foreach ($tel_lists as $tel_list) {
					$row =  Array();
					foreach ($t102_list_items as $t102_list_item) {
						$column = $t102_list_item['T102SmsListItem']['column'];
						array_push($row, $tel_list['T101SmsTelList'][$column]);
					}
					$data_csv_tmp[$list_id][] = $row;
				}
			}
		}
		$this->ESession->setDataCsvDownload($data_csv_tmp,$this);

		echo 'success';
		exit;
	}

	/** Get data from session and response to client request as Zip file
	 *  Be called after buffer_csv_data function be executed
	 */
	function download_csv_file() {
		$data_csv = $this->ESession->getDataCsvDownload($this);
		if(!isset($data_csv)){
			$this->redirect(array('controller' => 'SmsSendList', 'action' => 'index'));
		}

		$file_out_name = date('Ymdhis', time()) . '_SMS送信リスト.zip';
		$file_out_name = mb_convert_encoding($file_out_name, "SJIS-win", "UTF-8");
		$this->Csv->createZip($file_out_name);

		foreach ($data_csv as $key => $data) {

			$list = $this->T100SmsSendList->getListInfoById($key);
			if ($list) {
				foreach ($data as $row) {
					$this->Csv->addRow($row);
				}

				$title_csv = $list['T100SmsSendList']['list_name'] . '.csv';
				$title_csv = mb_convert_encoding($title_csv, "SJIS-win", "UTF-8");
				$this->Csv->addToZip($title_csv, 'SJIS-win');
				$this->Csv->clear();
			}
		}
		$this->Session->delete('data_csv_download');
		echo $this->Csv->renderZip('SJIS-win');
		exit;
	}

	/** Delete the selected list from screen
	 *@param array list_id be sent by ajax request
	 *@return redirect to list index
	 */
	function delete() {
		$data = $this->data;
		if (empty($data)) {
			$this->redirect(array('controller' => 'SmsSendList', 'action' => 'index'));
		}

		$dsT100SmsSendList = $this->T100SmsSendList->getDataSource();
		$dsT101SmsTelList = $this->T101SmsTelList->getDataSource();
		$dsT102SmsListItem = $this->T102SmsListItem->getDataSource();
		$dsT100SmsSendList->begin($this);
		$dsT101SmsTelList->begin($this);
		$dsT102SmsListItem->begin($this);

		$update_user = $this->ESession->getUserId($this);
		$update_program = $this->name.'_'.__FUNCTION__;
		$time = date('Y-m-d H:i:s a', time());

		$list_ids = $data['list_ids'];

		$query1 = "UPDATE t100_sms_send_lists ".
			"SET del_flag='Y', update_user='$update_user', update_program='$update_program', modified='$time' ".
			"WHERE id IN (".implode(',', $list_ids).");";
		if ($this->T100SmsSendList->query($query1)) {
			$dsT100SmsSendList->rollback($this);
			$this->log("T100削除：失敗");
			$this->redirect(array('controller' => 'Login', 'action' => 'index'));
			exit;
		}

		$count_tel = $this->T101SmsTelList->getTelByListIdsCount($list_ids);
		if ($count_tel > 0) {
			$query2 = "UPDATE t101_sms_tel_lists ".
				"SET del_flag='Y', update_user='$update_user', update_program='$update_program', modified='$time' ".
				"WHERE del_flag = 'N' AND list_id IN (".implode(',', $list_ids).");";
			if ($this->T101SmsTelList->query($query2)) {
				$dsT100SmsSendList->rollback($this);
				$dsT101SmsTelList->rollback($this);
				$this->log("T101削除：失敗");
				$this->redirect(array('controller' => 'Login', 'action' => 'index'));
				exit;
			}
		}

		$query3 = "UPDATE t102_sms_list_items ".
			"SET del_flag='Y' ".
			"WHERE del_flag = 'N' AND list_id IN (".implode(',', $list_ids).");";
		if ($this->T102SmsListItem->query($query3)) {
			$dsT100SmsSendList->rollback($this);
			$dsT101SmsTelList->rollback($this);
			$dsT102SmsListItem->rollback($this);
			$this->log("T102削除：失敗");
			$this->redirect(array('controller' => 'Login', 'action' => 'index'));
			exit;
		}

		$dsT100SmsSendList->commit($this);
		$dsT101SmsTelList->commit($this);
		$dsT102SmsListItem->commit($this);
		$this->redirect(array('controller' => 'SmsSendList', 'action' => 'index/delete/' . count($list_ids)));
	}

	/** Check info list before delete
	 * @param array|string list_ids
	 * @return string|redirect
	 */
	function check_info_list() {
		$data = $this->data;
		if (empty($data)) {
			$this->redirect(array('controller' => 'SmsSendList', 'action' => 'index'));
		}

		$list_ids = $data['list_ids'];
		if (!is_array($list_ids)) {
			$list_ids = explode(' ', $list_ids);
		}

		foreach ($list_ids as $id) {
			$info_list = $this->T100SmsSendList->getListInfoById($id);
			if (!isset($info_list["T100SmsSendList"]["id"]) || empty($info_list["T100SmsSendList"]["id"])) {
				//リスト存在しない
				echo "err_not_exist";
				exit;
			}

			$info_schedule = $this->T200SmsSendSchedule->getScheduleByListNo($info_list["T100SmsSendList"]["id"]);
			foreach ($info_schedule as $schedule) {
				if (isset($schedule["T200SmsSendSchedule"]["id"]) && $schedule["T200SmsSendSchedule"]["status"] != STATUS_FINISH) {
					//予定されているスケジュールに存在するスクリプトの為削除できません
					echo "err_used";
					exit;
				}
			}
		}
		exit;
	}

	/** Check exist list_name before update
	 * @param string list_name
	 * @param string list_name_old
	 * @return string true | false
	 */
	function check_exist_listname() {
		$data = $this->data;
		$company_id = $this->ESession->getUserCompanyId($this);
		$info_list = $this->T100SmsSendList->getByListName($data['list_name'], $company_id);
		if(isset($info_list["T100SmsSendList"]["id"]) && !empty($info_list["T100SmsSendList"]["id"])){
			if (isset($data['list_name_old']) && $data['list_name_old'] == $info_list['T100SmsSendList']['list_name']) {
				echo "true";
				exit;
			}
			echo "false";
		}else{
			echo "true";
		}
		exit;
	}

	/** Check info tel before del, edit or muko tel
	 * @param string action
	 * @param array|int tel_list_ids
	 * @return response ajax request a "success" string
	 */
	function check_info_tel() {
		if (empty($this->data)) {
			$this->redirect(array('controller' => 'SmsSendList', 'action' => 'index'));
		}

		$list_id = $this->ESession->getSmsSendListId($this);
		$info_list = $this->T100SmsSendList->getListInfoById($list_id);
		if (!isset($info_list["T100SmsSendList"]["id"]) || empty($info_list["T100SmsSendList"]["id"])) {
			//リスト存在しない
			echo "err_list_not_exist";
			exit;
		}
		$info_schedule = $this->T200SmsSendSchedule->getScheduleByListNo($info_list["T100SmsSendList"]["id"]);
		foreach ($info_schedule as $schedule) {
			if (isset($schedule["T200SmsSendSchedule"]["id"]) && $schedule["T200SmsSendSchedule"]["status"] == STATUS_SENDING) {
				echo "err_sending";
				exit;
			} else if (isset($schedule["T200SmsSendSchedule"]["id"]) && ($schedule["T200SmsSendSchedule"]["status"] != STATUS_FINISH) && ($schedule["T200SmsSendSchedule"]["status"] != STATUS_NO_SEND)) {
				//予定されているスケジュールに存在するスクリプトの為削除できません
				echo "err_used";
				exit;
			}
		}

		if (isset($this->data['action']) && ($this->data['action'] == 'add')) {
			$max_tel_param = $this->M99SystemParameter->getByFunctionIdAndParameterId('LIST_SMS', 'MAX_SMS_TEL');
			if ($info_list['T100SmsSendList']['tel_total'] >= $max_tel_param['M99SystemParameter']['parameter_value']) {
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
			$info_tel = $this->T101SmsTelList->getTelInfoById($id);
			if(empty($info_tel)){
				echo "err_tel_not_exist";
				exit;
			}
		}
		echo 'success';
		exit;
	}

	/** Show list get from T100 table
	 * @param int js_page: curren page number
	 * @param int limit: limit record in one page
	 * @param string column: type sort of column
	 * @return object json
	 */
	function arr_list($js_page, $limit, $column) {
		$this->layout = 'ajax';
		$filter = $_GET["filter"];
		$page = $js_page + 1;
		$json_data = Array();
		$json_data["headers"] = Array("NO","リスト名","件数","作成日時","作成者","アクション",);
		$json_data["rows"] = Array();
		$company_id = $this->ESession->getUserCompanyId($this);

		$enable_download = $this->M04ControllerAction->check_permission($this->post_code, 'SmsSendList', 'download');
		$enable_create = $this->M04ControllerAction->check_permission($this->post_code, 'SmsSendList', 'create');
		$enable_delete = $this->M04ControllerAction->check_permission($this->post_code, 'SmsSendList', 'delete');

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
			$sort_order = $this->Util->getSmsSendListSortOrder($column,$enable_delete || $enable_download ? 1 : 0);
		}

		$sort_order_col = isset($sort_order[0]) ? $sort_order[0] : null;
		$arr_lists = $this->T100SmsSendList->getListByCompanyId($company_id, $limit, $page, $sort_order_col, $filter);

		$json_data["total_rows"] = $this->T100SmsSendList->getListByCompanyIdCount($company_id, $filter);
		foreach ($arr_lists as $arr_list) {
			$json_row = array();
			$entry_user = $this->M05User->getUserByUserId($arr_list['T100SmsSendList']['entry_user']);
			$entry_user_name = isset($entry_user["M05User"]['user_name']) ? $entry_user["M05User"]['user_name'] : ''; //20160224 Add by Giang : #6531 - show list create by the user deleted
			if ($enable_delete || $enable_download) {
				$json_row['checkbox'] = '<input type="checkbox" name="list_ids[' . $arr_list['T100SmsSendList']['id'] . ']" id="cbSelect[' . $arr_list['T100SmsSendList']['id'] . ']" value="' . $arr_list['T100SmsSendList']['id'] . '" onclick="updateCheckStatus(\'bundleCheckbox\');">'
					. '<label for="cbSelect[' . $arr_list['T100SmsSendList']['id'] . ']" style="margin-top: 2px;"></label>';
			}
			$json_row['NO'] = str_replace($company_id, '', $arr_list['T100SmsSendList']['list_no']);
			$json_row['リスト名'] = $arr_list['T100SmsSendList']['list_test_flag'] == 1 ? "<font color='red'>(テスト)".$arr_list['T100SmsSendList']['list_name']."</font>" : $arr_list['T100SmsSendList']['list_name'];
			$json_row['件数'] = $arr_list['T100SmsSendList']['tel_total'].'件';
			$json_row['作成日時'] = date('Y-m-d H:i', strtotime($arr_list['T100SmsSendList']['created']));
			$json_row['作成者'] = $entry_user_name;
			$json_row['アクション'] = '<a href="javascript:void(0);" title="編集" data-toggle="tooltip" class="iconCenterFormat ajax-link lnkDetail" list_id="'.$arr_list['T100SmsSendList']['id'].'"><i class="glyphicon glyphicon-edit icon-white" ></i></a>';
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

	/** Insert list for T100, T101, T102 table
	 * @param string listName be sent by ajax request
	 * @param object json uploadData be sent by ajax request
	 * @param array fieldImport be sent by ajax request
	 * @param array listItemData be sent by ajax request
	 * @return response ajax request a "save" string
	 */
	function upload_file() {
		setlocale(LC_ALL, 'ja_JP.UTF-8');
		if (empty($this->data) || empty($this->data['listName']) || empty($this->data['uploadData']) || empty($this->data['fieldImport']) || empty($this->data['listItemData'])) {
			echo 'systemerror';
			exit;
		}

		$company_id = $this->ESession->getUserCompanyId($this);
		$max_list_no = $this->T100SmsSendList->getMaxListNoByCompanyId($company_id);

		if ($max_list_no['0']['max_list_no']) {
			$list_no_new = $max_list_no['0']['max_list_no'] + 1;
		} else {
			$list_no_new = '1';
		}

		$check_lock = $this->T92Lock->getInfoLock('upload_sms_send_list', $list_no_new);
		if (!empty($check_lock)) {
			echo 'systemerror';
			exit;
		}

		$lock_new = $this->create_lock('upload_sms_send_list', $list_no_new, __FUNCTION__);
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
		$dsT100SmsSendList = $this->T100SmsSendList->getDataSource();
		$dsT101SmsTelList = $this->T101SmsTelList->getDataSource();
		$dsT102SmsListItem = $this->T102SmsListItem->getDataSource();

		$dsT100SmsSendList->begin($this);
		$dsT101SmsTelList->begin($this);
		$dsT102SmsListItem->begin($this);

		$time = date('Y-m-d H:i:s a', time());

		$this->T100SmsSendList->create();
		$data_call_list['T100SmsSendList']['company_id'] = $company_id;
		$data_call_list['T100SmsSendList']['list_no'] = $list_no_new;
		$data_call_list['T100SmsSendList']['list_name'] = $list_name;
		$data_call_list['T100SmsSendList']['list_test_flag'] = $list_test_flag;
		$data_call_list['T100SmsSendList']['tel_total'] = count($uploadData);
		$data_call_list['T100SmsSendList']['muko_tel_total'] = count($uploadData);
		$data_call_list['T100SmsSendList']['entry_user'] = $this->ESession->getUserId($this);
		$data_call_list['T100SmsSendList']['entry_program'] = $this->name.'_'.__FUNCTION__;
		$call_list = $this->T100SmsSendList->save($data_call_list);

		if(!$call_list){
			$this->update_lock($lock_new, __FUNCTION__);
			$dsT100SmsSendList->rollback($this);
			$dsT101SmsTelList->rollback($this);
			$this->log("発信規制番号登録：失敗");
			echo 'systemerror';
			exit;
		}

		$list_id = $call_list['T100SmsSendList']['id'];
		$entry_user = $this->ESession->getUserId($this);
		$entry_program = $this->name.'_'.__FUNCTION__;

		$query_base = "INSERT INTO t101_sms_tel_lists ".
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
				$query = $query."('".$list_id."','".$count."','".$entry_user."','".$entry_program."','".$time."','".
					$cus1."','".$cus2."','".$cus3."','".$cus4."','".$cus5."','".$cus6."','".$cus7."','".$cus8."','".$cus9."','".$cus10."','".$cus11."');";
				if ($this->T101SmsTelList->query($query)) {
					$this->update_lock($lock_new, __FUNCTION__);
					$dsT100SmsSendList->rollback($this);
					$dsT101SmsTelList->rollback($this);
					$this->log("T101削除：失敗");
					echo 'systemerror';
					exit;
				}
				$query = $query_base;
			}else{
				$query = $query."('".$list_id."','".$count."','".$entry_user."','".$entry_program."','".$time."','".
					$cus1."','".$cus2."','".$cus3."','".$cus4."','".$cus5."','".$cus6."','".$cus7."','".$cus8."','".$cus9."','".$cus10."','".$cus11."'), ";
			}
		}

		$listItemData = $this->data['listItemData'];
		$t102_query_base = "INSERT INTO t102_sms_list_items ".
			"(company_id, list_id, order_num, item_name, item_code, `column`, del_flag, entry_user, entry_program, created) " .
			"VALUES ";
		$t102_query = $t102_query_base;
		$order_num = 0;


		$item_codes = array();
		$list_item_tmps = $this->M90PulldownCode->getSelectOption('list_item');
		foreach ($list_item_tmps as $item) {
			$item_codes[$item['M90PulldownCode']['item_name']] = $item['M90PulldownCode']['item_code'];
		}
		foreach ($listItemData as $column => $item_name) {
			$order_num ++;
			$item_code = isset($item_codes[$item_name]) ? $item_codes[$item_name] : '';

			// #8298 add consentday
			if ($item_code == 'consentday'){
				$consent_col = "customize".$column;
				$consent_id = $list_id;
				$arr = $this->T101SmsTelList->findAllByListId($consent_id);

				foreach($arr as $cons_rec){
					if ($cons_rec['T101SmsTelList'][$consent_col] != null){
						$data_cons['T101SmsTelList']['id'] = $cons_rec['T101SmsTelList']['id'];
						$data_cons['T101SmsTelList']['consentday'] = preg_replace('/[^0-9]/', '', $cons_rec['T101SmsTelList'][$consent_col])."000000";
						$result = $this->T101SmsTelList->save($data_cons);
					}
				}
			}

			if($order_num == count($listItemData)){
				$t102_query = $t102_query."('".$company_id."','".$list_id."','".$order_num."','".$item_name."','".$item_code."','customize".$column."','N','".$entry_user."','".$entry_program."','".date('Y-m-d H:i:s a', time())."');";
				if ($this->T102SmsListItem->query($t102_query)) {
					$this->update_lock($lock_new, __FUNCTION__);
					$dsT100SmsSendList->rollback($this);
					$dsT101SmsTelList->rollback($this);
					$dsT102SmsListItem->rollback($this);
					$this->log("T102削除：失敗");
					echo 'systemerror';
					exit;
				}
				$t102_query = $t102_query_base;
			}else{
				$t102_query = $t102_query."('".$company_id."','".$list_id."','".$order_num."','".$item_name."','".$item_code."','customize".$column."','N','".$entry_user."','".$entry_program."','".date('Y-m-d H:i:s a', time())."'), ";
			}
		}
		if (isset($lock_new) && !empty($lock_new) && !$this->update_lock($lock_new, __FUNCTION__)) {
			$dsT100SmsSendList->rollback($this);
			$dsT101SmsTelList->rollback($this);
			$dsT102SmsListItem->rollback($this);
			echo 'systemerror';
			exit;
		}

		$dsT100SmsSendList->commit($this);
		$dsT101SmsTelList->commit($this);
		$dsT102SmsListItem->commit($this);
		echo 'save';
		exit;
	}


	/** detail method. Refer to View/SmsSendList/detail.tpl
	 * show sms tel list get from T101SmsTelList table
	 */
	function detail() {
		$data = $this->data;
		if (empty($data['edit_list_id'])) {
			$this->redirect(array('controller' => 'SmsSendList', 'action' => 'index'));
		}
		//set session list_id
		$this->ESession->setSmsSendListId($data['edit_list_id'],$this);
		$list = $this->T100SmsSendList->getListInfoById($data['edit_list_id']);
		$t102_list_items = $this->T102SmsListItem->getTitleByListId($data['edit_list_id']);
		$headers = Array();
		foreach ($t102_list_items as $t102_list_item) {
			$headers[$t102_list_item['T102SmsListItem']['column']] = $t102_list_item['T102SmsListItem']['item_name'];
		}

		$schedule = $this->T200SmsSendSchedule->getScheduleByListId($data['edit_list_id'], Array(STATUS_SENDING, STATUS_STOPING, STATUS_STOP_SEND, STATUS_TEMP_FINISH));
		$enable_create_edit_delete = empty($schedule) ? true : false;
		if (!$enable_create_edit_delete) {
			$status_text = $this->get_status_schedule($schedule['T200SmsSendSchedule']['status']);
			$this->Session->setFlash('対象リストは' . $status_text . 'のスケジュールに存在する為新規登録・削除・編集できません。', 'default', array('class' => 'flash_msg error'));
		}

		$enable_edit_smssend_list = $this->M04ControllerAction->check_permission($this->post_code, 'SmsSendList', 'edit') && $enable_create_edit_delete;
		$enable_create = $this->M04ControllerAction->check_permission($this->post_code, 'DetailSmsSendList', 'create') && $enable_create_edit_delete;
		$enable_delete = $this->M04ControllerAction->check_permission($this->post_code, 'DetailSmsSendList', 'delete') && $enable_create_edit_delete;
		$enable_edit = $this->M04ControllerAction->check_permission($this->post_code, 'DetailSmsSendList', 'edit') && $enable_create_edit_delete;
		$enable_report_not_effective = $this->M04ControllerAction->check_permission($this->post_code, 'DetailSmsSendList', 'report_not_effective') && $enable_create_edit_delete;

		$this->set("list", $list);
		$this->set("t102_list_items", $t102_list_items);
		$this->set("headers", $headers);
		$this->set('enable_edit_smssend_list', $enable_edit_smssend_list);
		$this->set('enable_create', $enable_create);
		$this->set('enable_delete', $enable_delete);
		$this->set('enable_edit', $enable_edit);
		$this->set('enable_report_not_effective', $enable_report_not_effective);
	}

	/** Show tel list get from T101SmsTelList table
	 * @param int js_page: curren page number
	 * @param int limit: limit record in one page
	 * @param string column: type sort of column
	 * @return object json
	 */
	function tel_list($js_page, $limit, $column) {
		$this->layout = 'ajax';
		$filter = $_GET["filter"];
		$page = $js_page + 1;
		$json_data = Array();

		$list_id = $this->ESession->getSmsSendListId($this);
		$t102_list_items = $this->T102SmsListItem->getTitleByListId($list_id);

		$headers = Array("dummy_gs_id_string");
		foreach ($t102_list_items as $t102_list_item) {
			$headers[] = $t102_list_item['T102SmsListItem']['item_name'];
		}
		$headers[] = '無効';
		$json_data["rows"] = Array();

		$schedule = $this->T200SmsSendSchedule->getScheduleByListId($list_id, Array(STATUS_SENDING, STATUS_STOPING, STATUS_STOP_SEND, STATUS_TEMP_FINISH));
		$enable_create_edit_delete = empty($schedule) ? true : false;

		$enable_edit = $this->M04ControllerAction->check_permission($this->post_code, 'DetailSmsSendList', 'edit') && $enable_create_edit_delete;
		$enable_delete = $this->M04ControllerAction->check_permission($this->post_code, 'DetailSmsSendList', 'delete') && $enable_create_edit_delete;
		$enable_report_not_effective = $this->M04ControllerAction->check_permission($this->post_code, 'DetailSmsSendList', 'report_not_effective') && $enable_create_edit_delete;

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
			$sort_order = $this->Util->getTelSMSListSortOrder($column, $t102_list_items, $enable_delete ? 1 : 0);
		}

		$sort_order_col = isset($sort_order[0]) ? $sort_order[0] : null;
		$tel_lists = $this->T101SmsTelList->getTelByListId($list_id, $limit, $page, $sort_order_col, $filter, $t102_list_items);
		$json_data["total_rows"] = $this->T101SmsTelList->getListByListIdCount($list_id, $filter, $t102_list_items);

		if ($enable_edit) {
			$headers[] = 'アクション';
		}

		foreach ($tel_lists as $arr_list) {
			if (!$enable_report_not_effective || (!$enable_create_edit_delete && $arr_list['T101SmsTelList']['muko_flag'] == 'Y')) {
				$is_disable = 'disabled';
			} else {
				$is_disable = '';
			}

			$muko_flag = ($arr_list['T101SmsTelList']['muko_flag'] == 'Y')?'checked':'';
			$json_row = array();
			if ($enable_delete) {
				$json_row['selectItem'] = '<input class="select_item" type="checkbox" name="cbSelect[' . $arr_list['T101SmsTelList']['id'] . ']" id="cbSelect[' . $arr_list['T101SmsTelList']['id'] . ']" value="' . $arr_list['T101SmsTelList']['id'] . '" onclick="updateCheckStatus(\'bundleCheckbox\');">'
					. '<label class="label_select_item" for="cbSelect[' . $arr_list['T101SmsTelList']['id'] . ']" style="margin-top: 2px;"></label>';
			}
			$json_row['dummy_gs_id_string'] = $arr_list['T101SmsTelList']['tel_no'];
			foreach ($t102_list_items as $t102_list_item) {
				$key = $t102_list_item['T102SmsListItem']['item_name'];

				if (isset($t102_list_item['T102SmsListItem']['item_code']) && ($t102_list_item['T102SmsListItem']['item_code'] == 'birthday')) {
					$json_row[$key] = $this->displayDate($arr_list['T101SmsTelList'][$t102_list_item['T102SmsListItem']['column']]);
				} else if(isset($t102_list_item['T102SmsListItem']['item_code']) && ($t102_list_item['T102SmsListItem']['item_code'] == 'consentday')) { // #8298 add consentday
					$json_row[$key] = $this->displayDate($arr_list['T101SmsTelList'][$t102_list_item['T102SmsListItem']['column']]);
				} else {
					$json_row[$key] = $arr_list['T101SmsTelList'][$t102_list_item['T102SmsListItem']['column']] ? $arr_list['T101SmsTelList'][$t102_list_item['T102SmsListItem']['column']] : '';
				}
			}

			$json_row['無効'] = '<input class="inefficient '.$is_disable.'" type="checkbox" name="noEffect[' . $arr_list['T101SmsTelList']['id'] . ']" id="noEffect[' . $arr_list['T101SmsTelList']['id'] . ']" tel_list_id="' . $arr_list['T101SmsTelList']['id'] . '"' . $muko_flag . ' ' . $is_disable . '>'
				. '<label for="noEffect[' . $arr_list['T101SmsTelList']['id'] . ']" style="margin-top: 2px;"></label>';
			if ($enable_edit) {
				$json_row['アクション'] = '<a href="javascript:void(0);" class="iconCenterFormat ajax-link lnkEdit" tel_list_id="'.$arr_list['T101SmsTelList']['id'].'"><i title="編集" data-toggle="tooltip" class="glyphicon glyphicon-edit icon-white" ></i></a>';

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

	/** Display date
	 * @param string date
	 * @return string date follow "Ymd" format
	 */
	function displayDate($date = null) {
		$date = preg_replace("/\D/", "", $date);
		if (strlen($date) != 8) {
			$this->log($date);
			return '';
		}

		$date_tmp = substr($date, 0, 4) . '-' . substr($date, 4, 2) . '-' . substr($date, 6, 2);
		return $date_tmp;
	}

	/** Update list_name for T100SmsSendList table
	 * @param string listName be sent by ajax request
	 * @param int listId be sent by ajax request
	 * @param string listTestFlag be sent by ajax request
	 * @return response ajax request a "save" string
	 */
	function update_tel_list_name() {
		$enable_edit_sms_send_list = $this->M04ControllerAction->check_permission($this->post_code, 'SmsSendList', 'edit');
		if (empty($this->data) || empty($this->data['listId']) || empty($this->data['listName']) || !$enable_edit_sms_send_list) {
			echo 'submit_data_failed_or_not_permission_update';
			exit;
		}

		$check_lock = $this->T92Lock->getInfoLock('sms_send_list', $this->ESession->getSmsSendListId($this));
		if (!empty($check_lock)) {
			echo 'check_lock_error';
			exit;
		}

		$lock_new = $this->create_lock('sms_send_list', $this->ESession->getSmsSendListId($this), __FUNCTION__);
		if (!$lock_new) {
			echo 'create_lock_error';
			exit;
		}

		$list_name = $this->data['listName'];
		$list_id = $this->data['listId'];
		if ($this->data['listTestFlag'] == 'true') {
			$list_test_flag = 1;
		} else {
			$list_test_flag = 0;
		}

		//Save data to DB
		$dsT100SmsSendList = $this->T100SmsSendList->getDataSource();
		$dsT100SmsSendList->begin($this);

		$data_sms_send_list['T100SmsSendList']['id'] = $list_id;
		$data_sms_send_list['T100SmsSendList']['list_name'] = $list_name;
		$data_sms_send_list['T100SmsSendList']['list_test_flag'] = $list_test_flag;
		$data_sms_send_list['T100SmsSendList']['update_user'] = $this->ESession->getUserId($this);
		$data_sms_send_list['T100SmsSendList']['update_program'] = $this->name.'_'.__FUNCTION__;

		$sms_send_list = $this->T100SmsSendList->save($data_sms_send_list['T100SmsSendList']);

		if(!$sms_send_list || (isset($lock_new) && !empty($lock_new) && !$this->update_lock($lock_new, __FUNCTION__))){
			$dsT100SmsSendList->rollback($this);
			$this->log("Update sms list_name error");
			echo 'systemerror';
			exit;
		}

		$dsT100SmsSendList->commit($this);
		echo 'save';
		exit;
	}

	/** Delete tel from T101SmsTelList table
	 * @param array tel_list_ids be sent by ajax request
	 * @param int list_id be sent by ajax request
	 * @return object json
	 */
	function delete_tel() {
		$results = Array();
		if (empty($this->data) || empty($this->data['tel_list_ids']) || empty($this->data['list_id'])) {
			$results['status'] = 'submit_data_error';
			echo json_encode($results);
			exit;
		}
		$tel_list_ids = $this->data['tel_list_ids'];
		$list_id = $this->data['list_id'];

		$dsT101SmsTelList = $this->T101SmsTelList->getDataSource();
		$dsT101SmsTelList->begin($this);

		$update_user = $this->ESession->getUserId($this);
		$update_program = $this->name.'_'.__FUNCTION__;

		$query = "UPDATE t101_sms_tel_lists ".
			"SET del_flag='Y', update_user='$update_user', update_program='$update_program'".
			"WHERE id IN (".implode(',', $tel_list_ids).");";
		if ($this->T101SmsTelList->query($query)) {
			$dsT101SmsTelList->rollback($this);
			$this->log("T101削除：失敗");
			$results['status'] = 'update_t101_error';
			echo json_encode($results);
			exit;
		}

		$sms_send_list = $this->T100SmsSendList->getListInfoById($list_id);
		$tel_total = $sms_send_list['T100SmsSendList']['tel_total'];
		$tel_total_new = (int)$tel_total - count($tel_list_ids);
		if (!$this->update_tel_total_sms_send_list($list_id, $tel_total_new, $update_program)) {
			$results['status'] = 'update_tel_total_t100_error';
			echo json_encode($results);
			exit;
		} else if (!$this->update_muko_tel_total($list_id, $update_program)) {
			$results['status'] = 'update_muko_tel_total_t101_error';
			echo json_encode($results);
			exit;
		}
		$dsT101SmsTelList->commit($this);

		$results['status'] = 'delete_success';
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

	/** Add or edit T101SmsTelList
	 * @param array data_tel be sent by ajax request
	 * @return object json
	 */
	function add_and_edit_tel() {
		$results = Array();
		if (empty($this->data)) {
			$results['status'] = 'data_submit_error';
			echo json_encode($results);
			exit;
		}
		$data = $this->data['data_tel'];

		$list_id = $this->ESession->getSmsSendListId($this);
		$tel_id = $data['id'];

		$arr_schedule = $this->T200SmsSendSchedule->getAllScheduleByListId($list_id, STATUS_NO_SEND);
		foreach ($arr_schedule as $arr){
			$tel_info = array();
			foreach ($data as $field => $value) {
				if (!empty($field)) {
					$tel_info['T101SmsTelList'][$field] = $value;
				}
			}
			$check_message = $this->check_sms_content_length($arr["T200SmsSendSchedule"], $tel_info);
			if($check_message){
				$results['status'] = $check_message;
				echo json_encode($results);
				exit;
			}
		}

		//Save data to DB
		$dsT101SmsTelList = $this->T101SmsTelList->getDataSource();
		$dsT101SmsTelList->begin($this);

		$function_name = $this->name.'_'.__FUNCTION__;
		if (empty($tel_id)) {

			$max_tel_no = $this->T101SmsTelList->getMaxTelNoByListId($list_id);
			$data_tel['T101SmsTelList']['tel_no'] = $max_tel_no[0]['max_tel_no'] + 1;
			$data_tel['T101SmsTelList']['entry_user'] = $this->ESession->getUserId($this);
			$data_tel['T101SmsTelList']['entry_program'] = $this->name.'_'.__FUNCTION__;

			foreach ($data as $field => $value) {
				if (!empty($field)) {
					$data_tel['T101SmsTelList'][$field] = $value;
				}
			}
			
			// #8298 add consentday
			if($data['consentday']==null){
				$data_tel['T101SmsTelList']['consentday'] = null;
			}
			
			$data_tel['T101SmsTelList']['list_id'] = $list_id;
			$tel_list = $this->T101SmsTelList->save($data_tel);
			if(!$tel_list){
				$dsT101SmsTelList->rollback($this);
				$results['status'] = 'update_t101_error';
				echo json_encode($results);
				exit;
			}

			$sms_send_list = $this->T100SmsSendList->getListInfoById($list_id);
			$tel_total = $sms_send_list['T100SmsSendList']['tel_total'] + 1;
			if (!$this->update_tel_total_sms_send_list($list_id, $tel_total, $function_name)) {
				$dsT101SmsTelList->rollback($this);
				$results['status'] = 'update_tel_total_t100_error';
				echo json_encode($results);
				exit;
			} else if (!$this->update_muko_tel_total($list_id, $function_name)) {
				$dsT101SmsTelList->rollback($this);
				$results['status'] = 'update_muko_tel_total_t101_error';
				echo json_encode($results);
				exit;
			}

			$dsT101SmsTelList->commit($this);
			$results['status'] = 'insert';
		} else {
			$check_lock = $this->T92Lock->getInfoLock('t101_sms_tel_list', $tel_id);
			if (!empty($check_lock)) {
				$results['status'] = 'check_lock_error';
				echo json_encode($results);
				exit;
			}
			$lock_new = $this->create_lock('t101_sms_tel_list', $tel_id, __FUNCTION__);
			if (!$lock_new) {
				$results['status'] = 'create_lock_error';
				echo json_encode($results);
				exit;
			}
			$tel_list_backup = $this->T101SmsTelList->getTelInfoById($tel_id);
			$data_tel['T101SmsTelList']['update_user'] = $this->ESession->getUserId($this);
			$data_tel['T101SmsTelList']['update_program'] = $function_name;
			foreach ($data as $field => $value) {
				if (!empty($field)) {
					$data_tel['T101SmsTelList'][$field] = $value;
				}
			}

			// #8298 add consentday
			if($data['consentday']==null){
				$data_tel['T101SmsTelList']['consentday'] = null;
			}

			$data_tel['T101SmsTelList']['list_id'] = $list_id;
			$tel_list = $this->T101SmsTelList->save($data_tel);
			if(!$tel_list || (isset($lock_new) && !empty($lock_new) && !$this->update_lock($lock_new, __FUNCTION__))){
				$dsT101SmsTelList->rollback($this);
				$results['status'] = 'save_t101_error';
				echo json_encode($results);
				exit;
			}
			$dsT101SmsTelList->commit($this);
			$results['status'] = 'update';
		}

		$results['sortColumn'] = $this->ESession->getSortColumn($this);
		$results['sortType'] = $this->ESession->getSortType($this);
		$results['page'] = $this->ESession->getPage($this);
		echo json_encode($results);
		exit;
	}

	/** Update muko for T101SmsTelList table
	 * @param string list_id be sent by ajax request
	 * @param array tel_list_ids be sent by ajax request
	 * @return string
	 */
	function inefficient_tel() {
		$enable_report_not_effective = $this->M04ControllerAction->check_permission($this->post_code, 'DetailSmsSendList', 'report_not_effective');
		if (empty($this->data) || empty($this->data['tel_list_ids']) || !$enable_report_not_effective) {
			echo 'data_submit_error_or_not_permission';
			exit;
		}
		$tel_list_ids = $this->data['tel_list_ids'];
		$list_id = $this->data['list_id'];

		$info_column = $this->T102SmsListItem->getTelNumColumn($list_id);
		$tel_column = $info_column["T102SmsListItem"]["column"];
		$dsT101SmsTelList = $this->T101SmsTelList->getDataSource();
		$dsT101SmsTelList->begin($this);

		$time = date('Y-m-d H:i:s', time());
		foreach ($tel_list_ids as $tel_list_id => $muko_flag) {
			$arr_list = $this->T101SmsTelList->findById($tel_list_id);
			$tel_no = $arr_list["T101SmsTelList"][$tel_column];
			
			$arr_list['T101SmsTelList']['muko_flag'] = $muko_flag;
			$arr_list['T101SmsTelList']['muko_modified'] = $time;
			$arr_list['T101SmsTelList']['modified'] = $time;
			$arr_list['T101SmsTelList']['update_user'] = $this->ESession->getUserId($this);
			$arr_list['T101SmsTelList']['update_program'] = $this->name.'_'.__FUNCTION__;
			$this->T101SmsTelList->create();
			if (!$this->T101SmsTelList->save($arr_list)) {
				$dsT101SmsTelList->rollback($this);
				$this->log("T101削除：失敗");
				echo 'udpate_muko_t101_error';
				exit;
			}
		}

		if (!$this->update_muko_tel_total($list_id, $this->name.'_'.__FUNCTION__)) {
			$dsT101SmsTelList->rollback($this);
			echo 'udpate_muko_tel_total_t101_error';
			exit;
		}
		$dsT101SmsTelList->commit($this);
		echo 'update_muko_success';
		exit;
	}

	/** Check exist tel_no when add or edit tel
	 * @param string list_id get from session
	 * @param string tel_number be sent by ajax request
	 * @param string tel_number_col be sent by ajax request
	 * @return string: true|false
	 */
	function check_exist_tel_no() {
		$data = $this->data;
		$list_id = $this->ESession->getSmsSendListId($this);
		$tel_number = preg_replace("/\D/", "", $data['tel_number']); //20160224 Add by Giang : #6473 - remove the sign isn't number before insert tel number
		$tel_list = $this->T101SmsTelList->getByTelNoAndListId($tel_number, $data['tel_number_col'], $list_id); //20160224 Edit by Giang : #6473 - remove the sign isn't number before insert tel number

		if(isset($tel_list['T101SmsTelList'])){
			if (!empty($data['tel_list_id']) && $data['tel_list_id'] == $tel_list['T101SmsTelList']['id']) {
				echo "true";
				exit;
			}
			echo "false";
		} else {
			echo "true";
		}
		exit;
	}

	/** Create lock success or false
	 * @param string lock_flag: flag name
	 * @param int lock_id
	 * @param string function : method_name save for entry_program
	 * @return object|false
	 */
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

	/** Delete lock
	 * @param object lock: flag name
	 * @param string function : method_name save for update_program
	 * @return boolean
	 */
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

	/** Update T100.tel_total when del or add tel
	 * @param int list_id
	 * @param int tel_total
	 * @param string function : method_name save for update_program
	 * @return boolean
	 */
	function update_tel_total_sms_send_list($list_id = null, $tel_total = null, $function = null) {
		$dsT100SmsSendList = $this->T100SmsSendList->getDataSource();
		$dsT100SmsSendList->begin($this);

		$sms_send_list['T100SmsSendList']['id'] = $list_id;
		$sms_send_list['T100SmsSendList']['update_user'] = $this->ESession->getUserId($this);
		$sms_send_list['T100SmsSendList']['update_program'] = $function;
		$sms_send_list['T100SmsSendList']['tel_total'] = $tel_total;

		if (!$this->T100SmsSendList->save($sms_send_list)) {
			$dsT100SmsSendList->rollback($this);
			$this->log("Update tel total T100 error");
			return false;
		}

		$dsT100SmsSendList->commit($this);
		return true;
	}

	/** Update T100.muko_tel_total when del, add or muko tel
	 * @param int list_id
	 * @param int tel_total
	 * @param string function : method_name save for update_program
	 * @return boolean
	 */
	function update_muko_tel_total($list_id = null, $function = null) {
		$count_muko_tel = $this->T101SmsTelList->getCountMukoTelByListId($list_id);

		$dsT100SmsSendList = $this->T100SmsSendList->getDataSource();
		$dsT100SmsSendList->begin($this);

		$sms_send_list['T100SmsSendList']['id'] = $list_id;
		$sms_send_list['T100SmsSendList']['update_user'] = $this->ESession->getUserId($this);
		$sms_send_list['T100SmsSendList']['update_program'] = $function;
		$sms_send_list['T100SmsSendList']['muko_tel_total'] = $count_muko_tel;

		if (!$this->T100SmsSendList->save($sms_send_list)) {
			$dsT100SmsSendList->rollback($this);
			$this->log("Update muko tel total T100 error");
			return false;
		}

		$dsT100SmsSendList->commit($this);
		return true;
	}

	/** Get status text of Schedule by status
	* @param int $status
	* @return string status text
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
	function check_sms_content_length($data, $tel){
		$template_info = $this->T300SmsTemplate->getSmsTemplateById($data['template_id']);
		if(!empty($template_info)){
			$content = $template_info["T300SmsTemplate"]["content"];
			$arr_items = array();

			//　OutやInとは異なり、SMS一括送信は「sms_use_short_url」に短縮URLOn-OFFを保持する。
			//　OutやInは「yuko_button_record」に保持。
			$sms_use_short_url = $template_info['T300SmsTemplate']['sms_use_short_url'];
			$M08SmsApiInfo = $this->M08SmsApiInfo->getApiInfoByDisplayNumber($data["display_number"]);
			$api_id = $M08SmsApiInfo['M08SmsApiInfo']['api_id'];

			preg_match_all($this::ITEM_REGEX, $content, $items);

			//挿入項目あり　または　APIV2を使うなら文字数の再確認が必要
			// 短縮URL有効・無効は$api_id == SMS_API_V2_VALUEの時にOnになる。（画面で制御）
			if(!empty($items[0]) || $api_id == SMS_API_V2_VALUE){ //挿入項目があった場合、挿入項目値を含めて本文の長さをチェックする
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
			}else{
				if(mb_strlen($content) > MAX_LEN_SMS_CONTENT)
					return "err_sms_over_length";
			}
		}
		return "";
	}
}