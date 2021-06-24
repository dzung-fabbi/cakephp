<?php
App::uses('AppController', 'Controller');

class ManageAccountController extends AppController {
	var $name = 'ManageAccount';
	var $uses = Array('M15User', 'M04ControllerAction', 'M02Company', 'M90PulldownCode', 'M06CompanyExternal');

	/**
	 * 「Manage account」ページ初期表示のアクション
	 * @param string $mode
	 */
	function index($mode = null) {

		$this->set("mode", $mode);
		$post_code = $this->ESession->getUserPostCode($this);

		$create_flag = $this->M04ControllerAction->check_permission($post_code, 'ManagerAccount', 'create');
		$delete_flag = $this->M04ControllerAction->check_permission($post_code, 'ManagerAccount', 'delete');
		$edit_flag = $this->M04ControllerAction->check_permission($post_code, 'ManagerAccount', 'edit');

		$view_only_flag = $edit_flag || $create_flag || $edit_flag;

		$outbound_setup_sys = $this->M90PulldownCode->getSelectOption("out_setup_sys");
		$outbound_unit = $this->M90PulldownCode->getSelectOption("out_unit");
		// $outbound_voice = $this->M90PulldownCode->getSelectOption("out_voice");
		$inbound_setup_sys = $this->M90PulldownCode->getSelectOption("in_setup_sys");
		$inbound_unit = $this->M90PulldownCode->getSelectOption("in_unit");
		$sync_voice = $this->M90PulldownCode->getSelectOption("sync_voice");
		$recall = $this->M90PulldownCode->getSelectOption('schedule_redial_flag');

		$this->set("create_flag", $create_flag);
		$this->set("delete_flag", $delete_flag);
		$this->set("edit_flag", $edit_flag);
		$this->set("view_only_flag", $view_only_flag);
		$this->set("outbound_setup_sys", $outbound_setup_sys);
		$this->set("outbound_unit", $outbound_unit);
		// $this->set("outbound_voice", $outbound_voice);
		$this->set("inbound_setup_sys", $inbound_setup_sys);
		$this->set("inbound_unit", $inbound_unit);
		$this->set("sync_voice", $sync_voice);
		$this->set('recall', $recall);
		$this->set("post_code", $post_code);
	}


	function arr_account($js_page, $limit, $column) {
		$this->layout = 'ajax';
		$filter = $_GET["filter"];
		$page = $js_page + 1;
		$json_data = Array();
		$json_data["headers"] = Array("No","アカウント","企業名","電話番号数","音声合成","最大リダイヤル数","作成日時","作成者",);

		$json_data["rows"] = Array();
		$post_code = $this->ESession->getUserPostCode($this);

		$edit_flag = $this->M04ControllerAction->check_permission($post_code, 'ManagerAccount', 'edit');
		$delete_flag = $this->M04ControllerAction->check_permission($post_code, 'ManagerAccount', 'delete');
		if ($delete_flag) {
			array_unshift($json_data["headers"], "cbDelete");
			$col_start = 1;
		}
		else {
			$col_start = 0;
			$keyArr = array();
			if ($filter != null) {
				while (current($filter)) {
					$keyArr[] = key($filter) + 1;
					next($filter);
				}
				$filter = array_combine($keyArr, array_values($filter));
			}
		}

		if ($edit_flag) {
			array_push($json_data["headers"], "アクション");
		}

		if(isset($column) && !empty($column) && $column != "column") {
			$sort_order = $this->Util->getAccountSortOrder($column, $col_start);
		}

		if(isset($sort_order[0])){
			$arr_accounts = $this->M02Company->getCompanyData($limit, $page, $sort_order[0], $filter);
		}else{
			$arr_accounts = $this->M02Company->getCompanyData($limit, $page, null, $filter);
		}
		$total_rows = $this->M02Company->getCompanyAll($filter);
		$json_data["total_rows"] = count($total_rows);
		foreach ($arr_accounts as $arr_account) {

			$json_row = array();
			$i = 0;
			if ($delete_flag) {
				$json_row[$json_data["headers"][$i++]] = '<input type="checkbox" class="cbDelete"
				name="cbSelect[' .$arr_account['M02Company']['company_id'] . ']"
				value="' . $arr_account['M02Company']['company_id'] . '"
				id="cbSelect[' . $arr_account['M02Company']['company_id'] . ']"
				company_id="' . $arr_account['M02Company']['company_id'] . '">'. '<label for="cbSelect[' . $arr_account['M02Company']['company_id'] . ']" style="margin-top: 2px;"></label>';
			}
			$json_row[$json_data["headers"][$i++]] = $arr_account['M02Company']['id'];
			$json_row[$json_data["headers"][$i++]] = $arr_account['M02Company']['company_code'];
			$json_row[$json_data["headers"][$i++]] = $arr_account['M02Company']['company_name'];
			$json_row[$json_data["headers"][$i++]] = $arr_account['0']['tel_num'];
			$json_row[$json_data["headers"][$i++]] = $arr_account['M90PulldownCode']['item_name'];
			$json_row[$json_data["headers"][$i++]] = $arr_account['M90PulldownCodeMaxRedial']['item_name'];
			$json_row[$json_data["headers"][$i++]] = $arr_account['M02Company']['created'] ? date('Y-m-d H:i', strtotime($arr_account['M02Company']['created'])) : '';
			$json_row[$json_data["headers"][$i++]] = $arr_account['M05User']['user_name'] ? $arr_account['M05User']['user_name'] : '';

			$str_btn_func = '';
			if ($edit_flag){
				$str_btn_func .= '<div><a href="javascript:void(0);" class="iconCenterFormat lnkEdit btnEdit" company_id="'.
					$arr_account['M02Company']['company_id'].'"><i title="編集" data-toggle="tooltip" class="glyphicon glyphicon-edit icon-white" ></i></a></div>';
			}
			if ($edit_flag) {
				$json_row[$json_data["headers"][$i++]] = $str_btn_func;
			}
			$json_data["rows"][] = (object) $json_row;
		}
		$json_string = json_encode($json_data);
		echo $json_string;

		if(isset($sort_order)){
			$this->ESession->setSortColumn($sort_order[1], $this);
			$this->ESession->setSortType($sort_order[2], $this);
		}
		$this->ESession->setPage($js_page, $this);
		exit;
	}

	function add_edit_account(){
		//$this->log($this->data);
		if (empty($this->data)) {
			echo 'systemerror';
			exit;
		}else{
			$flag = true;
			$results = array();
			$dsM02Company = $this->M02Company->getDataSource();
			$dsM06CompanyExternal = $this->M06CompanyExternal->getDataSource();
			$dsM02Company->begin($this);
			$dsM06CompanyExternal->begin($this);
			$data['M02Company'] = array();

			foreach($this->data['data_account'] as $item){
				$data['M02Company'][$item['name']] = $item['value'];
			}
			$company_id = '';
			if($data['M02Company']['id'] == null || $data['M02Company']['id'] == ''){
				$company_max_id = $this->M02Company->getCompanyMax();
				$company_id = $company_max_id["M02Company"]["company_id"]+1;
				$company_id = str_pad($company_id,3,'0',STR_PAD_LEFT);
				$data['M02Company']['company_id'] = $company_id;
				$data['M02Company']['created'] = date('Y-m-d H:i:s');
				$data['M02Company']['entry_user'] = $this->ESession->getUserId($this);
				$data['M02Company']['entry_program'] = $this->name.'_'.__FUNCTION__;
				if($flag) {
					$results['status'] = 'insert';
					$flag = $this->M02Company->save($data);
				}
			}else{
				$data['M02Company']['modified'] = date('Y-m-d H:i:s');
				$data['M02Company']['update_user'] = $this->ESession->getUserId($this);
				$data['M02Company']['update_program'] = $this->name.'_'.__FUNCTION__;
				if($flag){
					$results['status'] = 'update';
					$flag = $this->M02Company->save($data);
				}

			}

			//電話番号を登録編集の処理
			if($flag) {
				if (isset($this->data['data_number']) && count($this->data['data_number'])) {
					foreach ($this->data['data_number'] as $item) {
						if (isset($item['action']) && $item['action'] == 'create') {
							$number = array();

							if ($item['M06CompanyExternal']['company_id'] == '' || $item['M06CompanyExternal']['company_id'] == null ){
								$item['M06CompanyExternal']['company_id'] = $company_id;
							}
							$number['M06CompanyExternal'] = $item['M06CompanyExternal'];
							$number['M06CompanyExternal']['created'] = date('Y-m-d H:i:s');
							$number['M06CompanyExternal']['entry_user'] = $this->ESession->getUserId($this);
							$number['M06CompanyExternal']['entry_program'] = $this->name . '_' . __FUNCTION__;
							unset($number['M06CompanyExternal']['id']);
							if($flag) {
								$this->M06CompanyExternal->create();
								$flag = $this->M06CompanyExternal->save($number);
							} else{
								break;
							}

						} elseif(isset($item['action']) && $item['action'] == 'edit') {

							$number['M06CompanyExternal'] = $item['M06CompanyExternal'];
							$number['M06CompanyExternal']['modified'] = date('Y-m-d H:i:s');
							$number['M06CompanyExternal']['update_user'] = $this->ESession->getUserId($this);
							$number['M06CompanyExternal']['update_program'] = $this->name . '_' . __FUNCTION__;
							if ($flag) {
								$flag = $this->M06CompanyExternal->save($number);
							} else {
								break;
							}
						}
					}
				}
			}
			//電話番号を削除の処理
			if($flag){
				if(isset($this->data['delete']) && count($this->data['delete']) > 0) {
					foreach ($this->data['delete'] as $item) {
						$delete_number = $this->M06CompanyExternal->getExternalNumberDetail($item['company_id'], $item['number']);
						if (!empty($delete_number)) {
							$delete_number['M06CompanyExternal']['del_flag'] = 'Y';
							$delete_number['M06CompanyExternal']['modified'] = date('Y-m-d H:i:s');
							$delete_number['M06CompanyExternal']['update_user'] = $this->ESession->getUserId($this);
							$delete_number['M06CompanyExternal']['update_program'] = $this->name . '_' . 'Delete';
							if ($flag) {
								$flag = $this->M06CompanyExternal->save($delete_number);
							} else {
								break;
							}
						}
					}
				}
			}

			if($flag){
				$dsM02Company->commit($this);
				$dsM06CompanyExternal->commit($this);
				$results['sortColumn'] = $this->ESession->getSortColumn($this);
				$results['sortType'] = $this->ESession->getSortType($this);
				$results['page'] = $this->ESession->getPage($this);
				echo json_encode($results);
				exit;
			}else{
				$dsM02Company->rollback($this);
				$dsM06CompanyExternal->rollback($this);
				$this->log("アカウント新規登録・修正：失敗");
				echo 'systemerror';
				exit;
			}

		}

	}

	function get_account_info(){
		if (empty($this->data)) {
			echo 'systemerror';
			exit;
		}
		$this->layout = false;
		$this->view = 'list_number';

		$results = array();
		$company_id = $this->data['company_id'];
		$company = $this->M02Company->getByCompanyId($company_id);
		$external_number = $this->M06CompanyExternal->getExternalNumberByCompanyId($company_id);
		if(count($company) == 0){
			$results['message'] = 'not_exist';
			echo json_encode($results);
			exit;
		} else {
			$results['message'] = 'success';
			$results['data'][] = $company;
			$results['data'][] = $external_number;

			echo json_encode($results);
			exit;
		}
	}

	function get_number_list(){
		if (empty($this->data)) {
			echo 'systemerror';
		}
		$company_id = $this->data['company_id'];
		$numbers = $this->M06CompanyExternal->getExternalNumberByCompanyId($company_id);

		echo json_encode($numbers);
		exit;
	}


	function delete_account(){
		if (empty($this->data)) {
			echo 'systemerror';
			exit;
		}

		$results = array();
		$company_ids = $this->data['company_ids'];;
		foreach($company_ids as $company_id){
			$company = $this->M02Company->getByCompanyId($company_id);
			if(empty($company)){
				$results['message'] = 'company_not_exist';
				echo json_encode($results);
				exit;
			}
		}
		$dsM02Company = $this->M02Company->getDataSource();
		$dsM06CompanyExternal = $this->M06CompanyExternal->getDataSource();
		$dsM02Company->begin($this);
		$dsM06CompanyExternal->begin($this);
		$flag = true;
		foreach ($company_ids as $company_id) {
			$company = $this->M02Company->getByCompanyId($company_id);
			$company['M02Company']['del_flag'] = 'Y';
			$company['M02Company']['modified'] = date('Y-m-d H:i:s');
			$company['M02Company']['update_user'] = $this->ESession->getUserId($this);
			$company['M02Company']['update_program'] = $this->name.'_'.__FUNCTION__;
			if($flag){
				$results['message'] = 'deleted';
				$flag = $this->M02Company->save($company);
			}else{
				break;
			}
			$external_numbers = $this->M06CompanyExternal->getExternalNumberByCompanyId($company_id);
			if(count($external_numbers) > 0){
				foreach($external_numbers as $number){
					$number['M06CompanyExternal']['del_flag'] = 'Y';
					$number['M06CompanyExternal']['modified'] = date('Y-m-d H:i:s');
					$number['M06CompanyExternal']['update_user'] = $this->ESession->getUserId($this);
					$number['M06CompanyExternal']['update_program'] = $this->name.'_'.__FUNCTION__;
					if($flag){
						$flag = $this->M06CompanyExternal->save($number);
					} else{
						break;
					}
				}
			}
		}

		if($flag){
			$dsM02Company->commit($this);
			$dsM06CompanyExternal->commit($this);
			echo json_encode($results);
			exit;
		}else{
			$dsM02Company->rollback($this);
			$dsM06CompanyExternal->rollback($this);
			echo 'systemerror';
			exit;
		}

	}

	function get_max_id(){
		$data = $this->M06CompanyExternal->getMaxId();
		echo $data[0][0]['max_id'];
		exit;
	}

	function check_duplicate_company_code(){
		if (empty($this->data)) {
			echo 'systemerror';
			exit;
		}
		$company_code = $this->data['company_code'];
		$company = $this->M02Company->getCompanyByCode($company_code);

		if($company > 0){
			echo 'false';
		}else {
			echo 'true';
		}
		exit;
	}

	function check_duplicate_number(){
		if (empty($this->data)) {
			echo 'systemerror';
			exit;
		}

		$number = $this->data['number'];
		$number_data = $this->M06CompanyExternal->getExternalNumber($number);

		if($number_data > 0){
			echo 'false';
		}else {
			echo 'true';
		}
		exit;

	}

	function get_pull_down(){
		$results = array();
		$results['out_system'] = $this->M90PulldownCode->getSelectOption("out_setup_sys");
		$results['out_unit'] = $this->M90PulldownCode->getSelectOption("out_unit");
		// $results['out_voice'] = $this->M90PulldownCode->getSelectOption("out_voice");
		$results['in_system'] = $this->M90PulldownCode->getSelectOption("in_setup_sys");
		$results['in_unit'] = $this->M90PulldownCode->getSelectOption("in_unit");
		// $results['in_voice'] = $this->M90PulldownCode->getSelectOption("in_voice");

		echo json_encode($results);
		exit;
	}
}