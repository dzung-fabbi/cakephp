<?php
App::uses('AppController', 'Controller');

class UserActionController extends AppController {
	var $uses = array('T91ActionHistory');

	function index() {
		$controller_action = $_POST['controller_action'];
        $textContent = $_POST['textContent'];
        
        $dsT91ActionHistory = $this->T91ActionHistory->getDataSource();
        $dsT91ActionHistory->begin($this);
        //ログイン履歴を更新する
        $T91History = array();
        $T91History['client_ip'] = $_SERVER['REMOTE_ADDR'];
        $T91History['client_name'] = gethostbyaddr($_SERVER["REMOTE_ADDR"]);
        // $T91History['mac_addr'] = $macAddr;
        $T91History['session_id'] = $this->Session->id();
        $T91History['user_id'] = $this->ESession->getUserId($this);
        $T91History['company_id'] = $this->ESession->getUserCompanyId($this);
        $T91History['operation'] = str_replace(" > ", "", $textContent)."__".$controller_action;
        $flag = $this->T91ActionHistory->save($T91History);
        if ($flag) {
            $dsT91ActionHistory->commit($this);
            echo "succes";
        } else {
            $dsT91ActionHistory->rollback($this);
            $this->log("DB更新失敗。".$dsT91ActionHistory->lastError());
            echo "error";
        }
        exit;
	}
}