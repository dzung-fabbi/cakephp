<?php
App::uses('AppController', 'Controller');

class OutboundRestrictListController extends AppController {
	var $uses = Array('M15User');

	/**
	 * 「Outbound restrict list」ページ初期表示のアクション
	 * @param string $mode
	 */
	function index($mode = null) {

		$this->set("mode", $mode);

	}
	
}
