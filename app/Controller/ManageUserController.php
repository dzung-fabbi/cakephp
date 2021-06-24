<?php
App::uses('AppController', 'Controller');

class ManageUserController extends AppController {
	var $uses = Array('M02Company', 'M03Auth', 'M99SystemParameter', 'M05User');

	/**
	 * 「Manage user」ページ初期表示のアクション
	 * @param string $mode
	 */
	function index($mode = null) {
		$enable_list = $this->M04ControllerAction->check_permission($this->post_code, 'ManageUser', 'list');
		if (!$enable_list) {
			$this->redirect(array('controller' => 'Menu', 'action' => 'index'));
		}

		if($this->post_code != 'U10') {
			$companies = $this->M02Company->getAll();
		}else {
			$company_id = $this->ESession->getUserCompanyId($this);
			$companies = $this->M02Company->getCompanyByCompanyId($company_id);
		}

		$this->set('m02companies', $companies);

		$enable_create = $this->M04ControllerAction->check_permission($this->post_code, 'ManageUser', 'create');
		$enable_edit = $this->M04ControllerAction->check_permission($this->post_code, 'ManageUser', 'edit');
		$enable_unlock = $this->M04ControllerAction->check_permission($this->post_code, 'ManageUser', 'unlock');
		$enable_delete = $this->M04ControllerAction->check_permission($this->post_code, 'ManageUser', 'delete');
		$this->set('enable_create', $enable_create);
		$this->set('enable_edit', $enable_edit);
		$this->set('enable_unlock', $enable_unlock);
		$this->set('enable_delete', $enable_delete);
		$this->set("mode", $mode);
	}

	function user_list($js_page, $limit, $column) {

		$this->layout = 'ajax';
		$filter = $_GET["filter"];
		$page = $js_page + 1;
		$json_data = Array();

		$enable_edit = $this->M04ControllerAction->check_permission($this->post_code, 'ManageUser', 'edit');
		$enable_unlock = $this->M04ControllerAction->check_permission($this->post_code, 'ManageUser', 'unlock');
		$enable_delete = $this->M04ControllerAction->check_permission($this->post_code, 'ManageUser', 'delete');
		$current_user = $this->ESession->getUserId($this);
		//201600302 Add by Thai : #6495 - can't edit user over post_code  - Begin
		$rank = $this->M03Auth->getRankByPostCode($this->post_code);
		$rank = $rank['M03Auth']['rank'];
		//201600302 Add by Thai : #6495 - can't edit user over post_code  - End

		// $headers = Array('cbDelete', 'user_no', 'アカウント', 'ユーザーID', 'ユーザー名', '権限', '作成日時');
		$headers = Array('企業名', 'ユーザーID', 'ユーザー名', '権限', '作成日時');
		$col_start = 0;
		if($enable_delete) {
			array_unshift($headers, "cbDelete");
			$col_start = 1;
		}
		if ($enable_unlock) {
			$headers[] = 'ロック';
		}
		if ($enable_edit) {
			$headers[] = 'アクション';
		}

		$json_data["rows"] = Array();

		if(isset($column) && !empty($column) && $column != "column"){
			$sort_order = $this->Util->getUserSortOrder($column, $col_start);
		}

		$company_id = ($this->post_code == 'U10') ? $this->ESession->getUserCompanyId($this) : null;
		if(isset($sort_order[0])){
			$user_lists = $this->M05User->getUserByCompanyIdandPostCode($company_id, null, $limit, $page, $sort_order[0], $filter, $col_start);
		}else{
			$user_lists = $this->M05User->getUserByCompanyIdandPostCode($company_id, null, $limit, $page, null, $filter, $col_start);
		}
		$json_data["total_rows"] = $this->M05User->getUserCountByCompanyIdandPostCode($company_id, null, $filter, $col_start);
		foreach ($user_lists as $arr_list) {
			$can_edit = $rank <= $arr_list['M03Auth']['rank'];
			$lock = (($arr_list['M05User']['user_id'] == $current_user) || ($arr_list['M05User']['lock_flag'] == 'N' && $arr_list['M05User']['login_flag'] == 'N')) ? false : true;
			$json_row = array();
			if ($enable_delete) {
				//201600302 Edit by Thai : #6495 - can't edit user over post_code  - Begin
				if ($can_edit) {
					$json_row['cbDelete'] = ($arr_list['M05User']['user_id'] == $current_user) ? '' : '<input class="cbDelete" type="checkbox" name="cbDelete[' . $arr_list['M05User']['id'] . ']" id="cbDelete[' . $arr_list['M05User']['id'] . ']" value="' . $arr_list['M05User']['id'] . '">'
						. '<label for="cbDelete[' . $arr_list['M05User']['id'] . ']" style="margin-top: 2px;"></label>';
				} else {
					$json_row['cbDelete'] = '<div style="height: 35px;"></div>';
				}
				//201600302 Edit by Thai : #6495 - can't edit user over post_code  - End
			}
			// $json_row['user_no'] = $arr_list['M05User']['user_no'];
			$json_row['企業名'] = $arr_list['M02Company']['company_name'] ? $arr_list['M02Company']['company_name'] : '';
			$json_row['ユーザーID'] = $arr_list['M05User']['user_id'];
			$json_row['ユーザー名'] = $arr_list['M05User']['user_name'] ? $arr_list['M05User']['user_name'] : '';
			$json_row['権限'] = $arr_list['M03Auth']['post_name'];
			$json_row['作成日時'] = $arr_list['M05User']['created'] ? date('Y-m-d H:i', strtotime($arr_list['M05User']['created'])) : '';

			if ($enable_unlock) {
				//201600302 Edit by Thai : #6495 - can't edit user over post_code  - Begin
				if ($can_edit) {
					$json_row['ロック'] = $lock ? '<input class="cbUnlock" type="checkbox" name="unlock[' . $arr_list['M05User']['id'] . ']" id="unlock[' . $arr_list['M05User']['id'] . ']" value="' . $arr_list['M05User']['id'] . '">'
						. '<label for="unlock[' . $arr_list['M05User']['id'] . ']" style="margin-top: 2px;"></label>' : '';
				} else {
					$json_row['ロック'] = '<div style="height: 35px;"></div>';
				}
				//201600302 Edit by Thai : #6495 - can't edit user over post_code  - End
			}
			if ($enable_edit) {
				//201600302 Edit by Thai : #6495 - can't edit user over post_code  - Begin
				if ($can_edit) {
					$json_row['アクション'] = '<a href="javascript:void(0);" class="iconCenterFormat ajax-link btnEdit" user_id="' . $arr_list['M05User']['id'] . '"><i title="アクション" data-toggle="tooltip" class="glyphicon glyphicon-edit icon-white" ></i></a>';
				} else {
					$json_row['アクション'] = '<div style="height: 35px;"></div>';
				}
				//201600302 Edit by Thai : #6495 - can't edit user over post_code  - End
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

	function check_exist_user() {
		if (empty($this->data)) {
			echo 'systemerror';
			exit;
		}

		if (isset($this->data['action']) && ($this->data['action'] == 'add')) {
			echo 'success';
			exit;
		}
		$user_ids = $this->data['user_ids'];

		if (!is_array($user_ids)) {
			$user_ids = explode(' ', $user_ids);
		}
		foreach ($user_ids as $id) {
			$user = $this->M05User->getUserById($id);
			if(empty($user)){
				echo "err_user_not_exist";
				exit;
			}
		}
		echo 'success';
		exit;
	}

	function check_duplicate_user_id() {
		$data = $this->data;
		$user = $this->M05User->getUserByUserId($data['user_id']);

		if(isset($user['M05User'])){
			if (!empty($data['id']) && ($data['id'] == $user['M05User']['id'])) {
				echo "true";
				exit;
			}
			echo "false";
		} else {
			$deleted_user = $this->M05User->getDeletedUserByUserId($data['user_id']);
			if(isset($deleted_user['M05User'])){
				echo "false";
				exit;
			}else{
				echo "true";
				exit;
			}
		}
		exit;
	}

	function unlock_user() {
		$enable_unlock = $this->M04ControllerAction->check_permission($this->post_code, 'ManageUser', 'unlock');
		if (empty($this->data) || empty($this->data['user_ids']) || !$enable_unlock) {
			echo 'systemerror';
			exit;
		}
		$user_ids = $this->data['user_ids'];

		$dsM05User = $this->M05User->getDataSource();
		$dsM05User->begin($this);

		$update_program = $this->name.'_'.__FUNCTION__;
		$update_user = $this->ESession->getUserId($this);

		$query = "UPDATE m05_users ".
			"SET lock_flag='N', login_flag='N', update_user='$update_user', update_program='$update_program'".
			"WHERE id IN (".implode(',', $user_ids).");";
		if ($this->M05User->query($query)) {
			$dsM05User->rollback($this);
			$this->log("M05削除：失敗");
			echo 'systemerror';
			exit;
		}

		$dsM05User->commit($this);

		$results = Array();
		$results['status'] = 'unlock';
		$results['sortColumn'] = $this->ESession->getSortColumn($this);
		$results['sortType'] = $this->ESession->getSortType($this);
		$results['page'] = $this->ESession->getPage($this);

		echo json_encode($results);
		exit;
	}

	function delete_user() {
		$enable_delete = $this->M04ControllerAction->check_permission($this->post_code, 'ManageUser', 'delete');
		if (empty($this->data) || empty($this->data['user_ids']) || !$enable_delete) {
			echo 'systemerror';
			exit;
		}
		$user_ids = $this->data['user_ids'];

		$dsM05User = $this->M05User->getDataSource();
		$dsM05User->begin($this);

		$update_program = $this->name.'_'.__FUNCTION__;
		$update_user = $this->ESession->getUserId($this);
		$time = date('Y-m-d H:i:s', time());

		$query = "UPDATE m05_users ".
			"SET del_flag='Y', update_user='$update_user', update_program='$update_program', modified='$time'".
			"WHERE id IN (".implode(',', $user_ids).");";
		if ($this->M05User->query($query)) {
			$dsM05User->rollback($this);
			$this->log("M05削除：失敗");
			echo 'systemerror';
			exit;
		}

		$dsM05User->commit($this);

		$results = Array();
		$results['status'] = 'delete';
		$results['sortColumn'] = $this->ESession->getSortColumn($this);
		$results['sortType'] = $this->ESession->getSortType($this);

		$user_total = $this->M05User->find('count');
		$max_page = ceil($user_total / PAGE_LENGTH);
		$current_page = $this->ESession->getPage($this);
		if (($current_page == $max_page) && (count($user_ids) == ($user_total % PAGE_LENGTH))) {
			$current_page--;
		}
		$results['page'] = $current_page;

		echo json_encode($results);
		exit;
	}


	/**
	 * 「Manage user」ページユーザー情報更新アクション
	 * @param array $this->data：POST値
	 * 	Note
	 * 	  ・下記のように値を持つ。（nameとvalueで1セット）
	 * 		data_user[1][name]:company_id
	 * 		data_user[1][value]:002
	 * 
	 * 	  ・POST値のうち、Javascript側でvalidateされているものは
	 * 	   本関数で値がない場合はエラーとする。（その旨を画面側に通知し、再度の保存を促す。）
	 * 			company_id
	 * 			user_id
	 * 			post_code
	 * 
	 * 	  ・POST値のキー「id」に値が無ければ「ADD（追加）」、あれば「UPDATE（編集）」
	 */
	function add_and_edit_user() {
		if (empty($this->data)) {
			echo 'systemerror';
			exit;
		}

		$data = $this->data['data_user'];
		$results = Array();
		$company_id = $this->ESession->getUserCompanyId($this);
		$insert = false;

		// 値が存在するかを表すフラグ
		// $("#form_add_and_edit_user").validate の required : true となる項目が監視対象。
		$exist_flags = Array("company_id"=>false, "user_id"=>false, "post_code"=>false);

		//Save data to DB
		$dsM05User = $this->M05User->getDataSource();
		$dsM05User->begin($this);

		$time_to_change_pass = $this->M99SystemParameter->getByFunctionIdAndParameterId('CHANGE_PASS', 'TIME_TO_CHANGE_PASS');
		if (is_array($time_to_change_pass) && sizeof($time_to_change_pass) > 0) {
			$time_to_change_pass = $time_to_change_pass['M99SystemParameter']['parameter_value'];
		} else {
			$time_to_change_pass = 0;
		}

		foreach ($data as $value) {
			// パスワード確認用のフォーム値「user_pass_confirm」は保存対象外とする
			if (!empty($value['name']) && ($value['name'] != 'user_pass_confirm')) {
				// 今回のフォーム値がパスワードの場合
				if ($value['name'] == 'user_pass') {
					// パスワードに何らかの値が入っている場合は、パスワード更新期限を設定
					if($value['value'] != null && $value['value'] != '') {
						$data_user['M05User'][$value['name']] = Security::hash($value['value'], 'sha256', true);
						$time = date('Y-m-d H:i:s', time() + $time_to_change_pass);
						$data_user['M05User']['password_change_date'] = $time;
					}
				} else {
					// それ以外の場合
					$data_user['M05User'][$value['name']] = $value['value'];
					if ($value['name'] == 'company_id') {
						$company_id = $value['value'];
					} else if (($value['name'] == 'id') && ($value['value'] == '')){
						$insert = true;
					}
				}
				// 空欄ではないことを記録
				if(array_key_exists($value['name'], $exist_flags) && $value['value']){
					$exist_flags[$value['name']] = true;
				}
			}
		}
		// 期待した値が存在しない場合はエラーとし、ユーザーには再度ユーザー登録を再度促す。
		if( array_search(false, $exist_flags, true) !== false){
			$this->log("add_and_edit_user_FAILED");
			$this->log(print_r($this->data, 1));
			$this->log(print_r($exist_flags, 1));
			$results['status'] = 'validate_error';
			echo json_encode($results);
			exit;
		}

		if ($insert) {
			$max_user_no = $this->M05User->getMaxUserNoBycompanyId($company_id);
			$user_no = $max_user_no[0]['max_user_no'] ? $max_user_no[0]['max_user_no'] : 0;

			$data_user['M05User']['user_no'] = $user_no + 1;
			$data_user['M05User']['login_flag'] = 'N';
			$data_user['M05User']['lock_flag'] = 'N';
			$data_user['M05User']['del_flag'] = 'N';
			$data_user['M05User']['created'] = date('Y-m-d H:i:s');
			$data_user['M05User']['entry_user'] = $this->ESession->getUserId($this);
			$data_user['M05User']['entry_program'] = $this->name.'_'.__FUNCTION__;

			$results['status'] = 'insert';
		} else {
			$data_user['M05User']['update_user'] = $this->ESession->getUserId($this);
			$data_user['M05User']['update_program'] = $this->name.'_'.__FUNCTION__;
			$data_user['M05User']['modified'] = date('Y-m-d H:i:s');

			$results['status'] = 'update';
		}


		if(!$this->M05User->save($data_user)) {
			$dsM05User->rollback($this);
			$this->log("発信規制番号登録：失敗");
			echo 'systemerror';
			exit;
		}
		$results['sortColumn'] = $this->ESession->getSortColumn($this);
		$results['sortType'] = $this->ESession->getSortType($this);
		$results['page'] = $this->ESession->getPage($this);

		$dsM05User->commit($this);
		echo json_encode($results);
		exit;
	}

	function get_info_user() {
		$data = $this->data;
		if (!isset($data['user_id'])) {
			echo 'systemerror';
			exit;
		}
		$user = $this->M05User->findById($data['user_id']);
		echo json_encode($user['M05User']);
		exit;
	}

	function check_change_password() {
		$data = $this->data;
		$user = $this->M05User->getUserById($data['user_id']);
		$password_new = Security::hash($data['password_new'],'sha256',true);
		if ($password_new == $user['M05User']['user_pass']) {
			echo 'false';
			exit;
		}
		echo 'true';
		exit;
	}

	/**
	 * 権限情報の取得
	 * @return array $display_auths 権限のコードと名称
	 */
	function get_auth_by_post_code(){
		$this->layout = 'ajax';

		$gs_company = $this->M99SystemParameter->getByFunctionIdAndParameterId('COMPANY', 'GS_COMPANY_ID');

		if($this->data['company_id'] == $gs_company['M99SystemParameter']['parameter_value']){
			// GSを選択した場合
			$post_code_pre = 'G%';
		} else {
			$post_code_pre = 'U%';
		}

		// 権限取得
		$arr_auth = $this->M03Auth->getAuthByPostCode($this->post_code, $post_code_pre);
		$display_auths = array();

		foreach ($arr_auth as $auth){
			$display_auths[] = array('post_code' => $auth['M03Auth']['post_code'], 'post_name' => $auth['M03Auth']['post_name']);
		}

		echo json_encode($display_auths);
		exit;
	}
}
