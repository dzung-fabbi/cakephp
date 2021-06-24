<?php
App::uses('AppController', 'Controller');

class CompanyController extends AppController {
	var $name = 'Company';
	var $uses = Array('M02Company');

	function change_company() {
		header('Content-type: text/json');
		header('Content-type: application/json');
		$data = $this->data;
		if (empty($data)) {
			echo  json_encode(array('status' => 501, 'message' => 'エラーを発生しました。'));
			exit;
		}
		$company_id = $data['company_id'];
		if ($this->M02Company->getByCompanyId($company_id)){
			$this->ESession->setUserCompanyId($company_id,$this);
			$result_max_redial = $this->M02Company->getCompanyByCompanyId($company_id);
			$max_redial = $result_max_redial['M02Company']['max_redial'];
			$this->ESession->setMaxRedial($max_redial,$this);
			echo json_encode(array('status' => 200, 'message' => '会社を変わりました。'));
			exit;
		}

		echo  json_encode(array('status' => 501, 'message' => 'エラーを発生しました。'));
		exit;
	}
}
