<?php
App::uses('Controller', 'Controller');

class AppController extends Controller {
    public $viewClass = 'Smarty';
    var $components = array('Session','ESession','Security', 'Csv', 'Util','SendMail');
	var $uses = Array('T90LoginHistory', 'M05User', 'M04ControllerAction', 'M02Company', 'M99SystemParameter', 'T94CompanyHideMenu');
	var $defaultScreen = 'OutSchedule';
    public $helpers = array(
        'SmartyBase',
        'SmartyHtml',
        'SmartyForm',
        'SmartySession',
        'SmartyJavascript',
        'Html',
    	'Session'
    );
	var $commInfo;

	//処理前
	function beforeFilter() {
		parent::beforeFilter();
		//$this->log('- begin'.', date : '.date("Ymd",time()));
		$this->Security->blackHoleCallback = 'blackHole';
		$this->Security->validatePost = false;
		$this->Security->csrfCheck = false;

		//パラメータテーブルから共通情報の取得してから、セッションにセットする
		/*$C99Param = $this->C99Parameter->getAll();
		$this->commInfo = array();
		if (!empty($C99Param)) {
			foreach($C99Param as $row) {
				$this->commInfo[$row['C99Parameter']['function_id'].'_'.$row['C99Parameter']['parameter_id']] = $row['C99Parameter']['parameter_value'];
			}
		}

		$this->ESession->setCommInfo($this->commInfo,$this);

		$this->commInfo = $this->ESession->getCommInfo($this);
		*/
		//ログインチェック
		$user_id = $this->ESession->getUserId($this);
		if (empty($user_id) && strtolower($this->name) !== 'login') {
			$arr_controller = array(
				'OutSchedule',
				'SmsSchedule'
			);

			$arr_action = array(
				'status_autoupdate',
				'arr_schedule',
				'arr_schedule_detail'
			);
			if (in_array($this->name, $arr_controller) && in_array($this->action, $arr_action)) {
				$this->set('error_login', true);
			} else {
				$this->redirect(array('controller' => 'Login'));
			}
		} else if (!$this->check_end_session($user_id, $this->Session->id()) && strtolower($this->name) !== 'login') {
			$this->ESession->logout($this);
			$this->redirect(array('controller' => 'Login'));
		} else if (!empty($user_id) && (!in_array(strtolower($this->name), array('passwordchange', 'login')))) {
			$resultInfoByUserId = $this->M05User->getInfoByUserId($user_id);
			if ($resultInfoByUserId['M05User']['password_change_date'] == null
				|| $resultInfoByUserId['M05User']['password_change_date'] < date("Y-m-d", time())) {
				$this->redirect(array('controller' => 'PasswordChange', 'action' => 'index/password'));
			}
		}
		$appRoot = $this->siteURL().$this->base;
		$this->set('appRoot', $appRoot);
		$this->set('userName', $this->ESession->getUserName($this));
		$this->set('postName', $this->ESession->getUserPostName($this));
		$this->set("controller", strtolower($this->name));
		$this->set("current_action", $this->action);

		$post_code = $this->ESession->getUserPostCode($this);
		if ($post_code == "U30" || $post_code == "U20"){
			$manager_list_flag =  false;
		}
		else $manager_list_flag =  true;
		$rdd_create_flag = $this->M04ControllerAction->check_permission($post_code, 'RDD', 'create');
		$this->set("manager_list_flag", $manager_list_flag);
		$this->set("rdd_create_flag", $rdd_create_flag);
		$this->set("post_code", $post_code);
		$this->post_code = $post_code;

		$enable_list_manageuser = $this->M04ControllerAction->check_permission($this->post_code, 'ManageUser', 'list');
		$this->set('enable_list_manageuser', $enable_list_manageuser);
		$enable_manage_account = $this->M04ControllerAction->check_permission($this->post_code, 'ManagerAccount', 'list');
		$this->set('enable_manage_account', $enable_manage_account);

		if (in_array($post_code, array("G10", "G20", "G30"))){
			$companies = $this->M02Company->getAll();
			$this->set("companies", $companies);
		}
		$company_id = $this->ESession->getUserCompanyId($this);

		$gs_company = $this->M99SystemParameter->getByFunctionIdAndParameterId('COMPANY', 'GS_COMPANY_ID');
		$gs_company_id = $gs_company['M99SystemParameter']['parameter_value'];
		$enable_manage_menu = $company_id == $gs_company_id;

		$data_hide_menu_tmp = $this->T94CompanyHideMenu->getHideMenuByCompanyId($company_id);
		$data_hide_menu = array();
		foreach ($data_hide_menu_tmp as $data) {
			$data_hide_menu[$data['T94CompanyHideMenu']['menu_item_code']] = 1;
		}

		$menu_items = array(
			'Template' => 'outbound',
			'CallList' => 'outbound',
			'CallListNg' => 'outbound',
			'OutSchedule' => 'outbound',
			'InboundTemplate' => 'inbound',
			'InboundCallList' => 'inbound',
			'InboundIncomingHistory' => 'inbound',
			'InboundRestrict' => 'inbound',
			'SmsTemplate' => 'sms',
			'SmsSendList' => 'sms',
			'SmsSchedule' => 'sms',
		);
		$defaultControllers = array(
			'outbound' => 'OutSchedule',
			'inbound' => 'InboundIncomingHistory',
			'sms' => 'SmsSchedule'
		);

		$current_item_menu = isset($menu_items[$this->name]) ? $menu_items[$this->name] : '';

		if (isset($data_hide_menu[$current_item_menu]) && $data_hide_menu[$current_item_menu] == 1) {
			$screen = $this->defaultScreen;
			if (isset($menu_items[$screen]) && isset($data_hide_menu[$menu_items[$screen]]) && $data_hide_menu[$menu_items[$screen]] == 1) {
				foreach ($defaultControllers as $item_menu => $controller) {
					if (!isset($data_hide_menu[$item_menu]) || $data_hide_menu[$item_menu] != 1) {
						$this->redirect(array('controller' => $controller));
					}
				}
				$this->redirect(array('controller' => 'Login', 'action' => 'logout'));
			} else {
				$this->redirect(array('controller' => $screen));
			}
		}
		$this->set('enable_manage_menu', $enable_manage_menu);
		$this->set("data_hide_menu", $data_hide_menu);

		$enable_download_result = $company_id == $gs_company_id;
		$this->set('enable_download_result', $enable_download_result);

		$company_name = $this->M02Company->getCompanyByCompanyId($company_id);
		$this->set("company_name", $company_name);
	}

	function check_end_session($user_id, $session_id) {
		$login_history = $this->T90LoginHistory->getLastByUserId($user_id, $session_id);

		if (isset($login_history['T90LoginHistory']['logout_time'])) {
			return false;
		} else {
			return true;
		}
	}

	function siteURL() {
		if (isset($_SERVER['HTTPS']) && ($_SERVER['HTTPS'] == 'on' || $_SERVER['HTTPS'] == 1) ||
			isset($_SERVER['HTTP_X_FORWARDED_PROTO']) &&
			$_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https') {

			$protocol = 'https://';
		}else {
			$protocol = 'http://';
		}
		$domainName = $_SERVER['HTTP_HOST'];

		return $protocol.$domainName;
	}

	function generateRandomString($length = 10) {
		$characters = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
		$charactersLength = strlen($characters);
		$randomString = '';
		for ($i = 0; $i < $length; $i++) {
			$randomString .= $characters[rand(0, $charactersLength - 1)];
		}
		return $randomString;
	}

	function log($message = null, $mode = "error"){
		//$callers=debug_backtrace();
		//parent::log($this->ESession->getUserId($this).', control:'.$this->name.', action :'.$this->action. ': ' .$message, $mode);
		parent::log($message);
	}

	//後処理
	function afterFilter(){
		parent::afterFilter();
		//$this->log('- end'.', date : '.date("Ymd",time()));
	}

	function blackHole($type) {
		$this->log("blackHole Type:".$type);
		throw new NotFoundException();
	}
}

