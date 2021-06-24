<?php
App::uses('AppController', 'Controller');

class ManageRateDetailsController extends AppController {
	var $uses = Array('M15User');

	/**
	 * 「Manage rate details」ページ初期表示のアクション
	 * @param string $mode
	 */
	function index($mode = null) {

		$this->set("mode", $mode);

	}
	
}
