<?php
App::uses('AppController', 'Controller');

class ManageNewsController extends AppController {
	var $uses = Array('M15User');

	/**
	 * 「Manage news」ページ初期表示のアクション
	 * @param string $mode
	 */
	function index($mode = null) {

		$this->set("mode", $mode);

	}
	
}
