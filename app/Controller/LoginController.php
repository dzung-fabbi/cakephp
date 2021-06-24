<?php
App::uses('AppController', 'Controller');
App::uses('CakeEmail', 'Network/Email');

class LoginController extends AppController {
	var $name = 'Login';
	var $uses = Array('M03Auth','M05User', 'T90LoginHistory', 'T91ActionHistory');
	var $defaultScreen = 'OutSchedule';

	/**
	 * 「ログイン」ページ初期表示のアクション
	 * @param string $mode
	 */
	function index($mode = null) {
		if ($mode == 'password_error') {
			$error_remaining = $this->Session->read('error_remaining');
			if (!is_null($error_remaining)) {
				$this->Session->delete('error_remaining');
				$this->set("error_remaining", $error_remaining);
			}
		}
		if ($this->ESession->getUserId($this)) {
			$this->redirect(array('controller' => $this->defaultScreen));
		}
		$this->set("mode", $mode);
		//$this->ESession->logout($this);
	}

	/**
	 * 「ログイン」ページログインボタン押すアクション
	 */
	function login() {
		if ($this->ESession->getUserId($this)) {
			$this->redirect(array('controller' => $this->defaultScreen));
		}
		if (empty($this->data)) {
			$this->redirect(array('action' => 'index'));
		}

		$user_id = $this->data['M05User']['user_id'];
		$password = $this->data['M05User']['password'];
		if ($this->M05User->countByUserId($user_id) == 0) {
			//ログインに失敗した場合の処理
			$this->redirect(array('action' => 'index/username_error'));
		}

		$resultInfoByUserId = $this->M05User->getInfoByUserIdAndPassword($user_id, $password);
		if (empty($resultInfoByUserId)) {
			$this->create_history($user_id, 'Y', $this->name.'_'.__FUNCTION__);

			if ($this->Session->check('failure_times')) {
				$login_failure = $this->Session->read('failure_times') + 1;
			} else {
				$login_failure = 1;
			}

			$this->Session->write('failure_times', $login_failure);

			$resultInfo = $this->M05User->getInfoByUserId($user_id);
			if ($login_failure >= LOGIN_FAILURE_LIMIT) {
				if ($resultInfo['M05User']['lock_flag'] == 'N') {
					$resultInfo['M05User']['lock_flag'] = 'Y';
					if (!$this->M05User->save($resultInfo)) {
						//更新失敗時のエラー処理
						$this->log("最終ログイン時間更新失敗");
						$this->redirect(array('action' => 'index/systemerror'));
					}
				}
				$this->redirect(array('action' => 'index/user_locked'));
			}

			$this->Session->write('error_remaining', LOGIN_FAILURE_LIMIT - $login_failure);
			$this->redirect(array('action' => 'index/password_error'));
		} else if ($resultInfoByUserId['M05User']['lock_flag'] == 'Y') {
			$this->redirect(array('action' => 'index/user_locked'));
		} else if ($resultInfoByUserId['M05User']['login_flag'] == 'Y') {
			$last_login_history = $this->T90LoginHistory->getLastByUserId($user_id);
			$time_life_session = ini_get("session.gc_maxlifetime");
			$last_entry = $last_login_history['T90LoginHistory']['created'];

			if (strtotime($last_entry) + $time_life_session > time()) {
				$this->redirect(array('action' => 'index/login_other_session'));
			} else {
				$this->create_history($user_id, 'N', $this->name.'_'.__FUNCTION__);
			}

			$this->redirect(array('action' => 'index/login_other_session'));
		} else {
			$this->Session->delete('failure_times');
			$this->create_history($user_id, 'N', $this->name.'_'.__FUNCTION__);
		}

		$resultInfoByUserId['M05User']['login_flag'] = 'Y';
		$this->M05User->save($resultInfoByUserId);
		
		$post_name = $this->M03Auth->getPostNameByPostCode($resultInfoByUserId['M05User']['post_code']);
		
		//顧客情報をセッションにセットする
		$this->ESession->setSeqId($resultInfoByUserId['M05User']['id'],$this);
		$this->ESession->setUserId($resultInfoByUserId['M05User']['user_id'],$this);
		$this->ESession->setUserName($resultInfoByUserId['M05User']['user_name'],$this);
		$this->ESession->setUserCompanyId($resultInfoByUserId['M05User']['company_id'],$this);
		$this->ESession->setUserPostCode($resultInfoByUserId['M05User']['post_code'],$this);
		$this->ESession->setUserPostName($post_name[0]['M03Auth']['post_name'],$this);
		$this->ESession->setMaxRedial($resultInfoByUserId['M02Company']['max_redial'],$this);
		
		$loginId = $this->T90LoginHistory->getLoginId($this->ESession->getUserId($this), $this->Session->id());
		$this->ESession->setLoginId($loginId[0]['T90LoginHistory']['id'],$this);

		if ($resultInfoByUserId['M05User']['password_change_date'] == null
			|| $resultInfoByUserId['M05User']['password_change_date'] < date("Y-m-d", time())) {
			$this->redirect(array('controller' => 'PasswordChange', 'action' => 'index/password'));
		}

		//メニュー画面へ遷移
		$this->redirect(array('controller' => $this->defaultScreen));
	}

	function create_history($user_id=null, $login_flag, $program=null) {
		if (!isset($program)) {
			$program = $this->name.'_'.__FUNCTION__;
		}
		//ログイン履歴を更新する
		$T90LoginHistory = array();
		$T90LoginHistory['user_id'] = $user_id;
		$T90LoginHistory['client_ip'] = $_SERVER['REMOTE_ADDR'];
		$T90LoginHistory['session_id'] = $this->Session->id();
		$T90LoginHistory['entry_user'] = $user_id;
		$T90LoginHistory['entry_program'] = $program;
		$T90LoginHistory['update_user'] = $user_id;
		$T90LoginHistory['update_program'] = $program;

		if (!$this->T90LoginHistory->save($T90LoginHistory)) {
			//更新失敗時のエラー処理
			$this->log("最終ログイン時間更新失敗");
			$this->redirect(array('controller' => 'Login', 'action' => 'index/systemerror'));
		}
	}

	/**
	 * 「ログアウト」ボタンを押すアクション
	 */
	function logout($mode = null) {
		//ログイン履歴を更新する
		if($this->ESession->getLoginId($this)){
			$T90LoginHistory = array();
			$T90LoginHistory['id'] = $this->ESession->getLoginId($this);
			$T90LoginHistory['logout_time'] = date("Y-m-d H:i:s",time());
			$T90LoginHistory['update_user'] = $this->ESession->getUserId($this);
			$T90LoginHistory['update_program'] = $this->name.'_'.__FUNCTION__;

			$user_id = $this->ESession->getSeqId($this);

			$resultInfoByUserId = $this->M05User->getUserById($user_id);
			$resultInfoByUserId['M05User']['login_flag'] = 'N';
			$this->M05User->save($resultInfoByUserId);

			$this->T90LoginHistory->save($T90LoginHistory);
			$this->ESession->logout($this);
		}
		$this->redirect(array('controller' => 'Login', 'action' => 'index'));
	}

}
