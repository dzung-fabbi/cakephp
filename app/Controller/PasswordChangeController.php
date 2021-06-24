<?php
App::uses('AppController', 'Controller');

class PasswordChangeController extends AppController {
	var $name = 'PasswordChange';
	var $uses = Array('M05User', 'M99SystemParameter');

	function index($mode = null){
		$user_id = $this->ESession->getUserId($this);
		$resultInfoByUserId = $this->M05User->getInfoByUserId($user_id);
		if ($resultInfoByUserId['M05User']['password_change_date'] == null
			|| $resultInfoByUserId['M05User']['password_change_date'] < date("Y-m-d", time())) {
			$this->set('hide_menu_flag', true);
		}

		$this->set("mode", $mode);
	}
	
	function change_password(){
		if (empty($this->data)) {
			echo 'systemerror';
			exit;
		} else {
			$data = array();

			foreach ($this->data['pass_data'] as $value) {
				$data[$value['name']] = $value['value'];
			}

			$id = $this->ESession->getSeqId($this);
			$resultCurrentUserPwd = $this->M05User->getUserById($id);
			$old_pword = $resultCurrentUserPwd['M05User']['user_pass'];
			$entry_pword = Security::hash($data['old_pword'],'sha256',true);

			if ($old_pword != $entry_pword) {
				echo 'invalid';
				exit;
			} else{
				//新しいパスワード
				$dsM05User = $this->M05User->getDataSource();
				$dsM05User->begin($this);
				$new_pword = Security::hash($data['new_pword'],'sha256',true);
				//パスワード変更する
				$time_to_change_pass = $this->M99SystemParameter->getByFunctionIdAndParameterId('CHANGE_PASS', 'TIME_TO_CHANGE_PASS');
				if (is_array($time_to_change_pass) && sizeof($time_to_change_pass) > 0) {
					$time_to_change_pass = $time_to_change_pass['M99SystemParameter']['parameter_value'];
				} else {
					$time_to_change_pass = 0;
				}
				$M05PwordChange = array();
				$M05PwordChange['M05User']['id'] = $id;
				$M05PwordChange['M05User']['user_pass'] = $new_pword;
				$M05PwordChange['M05User']['password_change_date'] = date('Y-m-d H:i:s', time() + $time_to_change_pass);
				$M05PwordChange['M05User']['update_user'] = $this->ESession->getUserId($this);
				$M05PwordChange['M05User']['update_program'] = $this->name.'_'.__FUNCTION__;
				$flag = $this->M05User->save($M05PwordChange);
				if(!$flag){
					$this->log("パスワード変更：失敗");
					$dsM05User->rollback($this);
					echo 'systemerror';
					exit;
				}else{
					$dsM05User->commit($this);
					echo 'success';
					exit;
				}
			}
		}
	}

}
