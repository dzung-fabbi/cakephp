<?php
App::uses('AppController', 'Controller');

class ManagePasswordController extends AppController {
	var $uses = Array('M15User');

	/**
	 * 「Manage password」ページ初期表示のアクション
	 * @param string $mode
	 */
	function index($mode = null) {

		$this->set("mode", $mode);

	}
	
}
