<?php
App::uses('AppController', 'Controller');

class MenuController extends AppController {
	var $uses = Array('M15User');

	/**
	 * 「メニュー」ページ初期表示のアクション
	 * @param string $mode
	 */
	function index($mode = null) {
		$this->set("mode", $mode);

	}

	function download_manual() {
		$file_path = WWW_ROOT."/fileuploads/manual.pdf";
		$file_name = mb_convert_encoding("ロボットコールセンター_マニュアル.pdf", "SJIS-win", "UTF-8");
		if (file_exists($file_path)) {
			$fp = fopen($file_path, "rb");
			$this->layout = "ajax";
			header('Content-Description: File Transfer');
			header('Content-Type: application/octet-stream');
			header('Content-Disposition: attachment; filename='.$file_name.'; charset=SJIS-win');
			header('Content-Transfer-Encoding: binary');
			header('Expires: 0');
			header('Cache-Control: must-revalidate');
			header('Pragma: public');
			header('Content-Length: ' . filesize($file_path));
			echo file_get_contents($file_path);
		}
		exit;
	}

	function download_clear_cache_guide() {
		$file_path = WWW_ROOT."/fileuploads/clear_cache_guide.pdf";
		$file_name = mb_convert_encoding("ロボットコールセンター_マニュアル_ブラウザキャッシュ.pdf", "SJIS-win", "UTF-8");
		if (file_exists($file_path)) {
			$fp = fopen($file_path, "rb");
			$this->layout = "ajax";
			header('Content-Description: File Transfer');
			header('Content-Type: application/octet-stream');
			header('Content-Disposition: attachment; filename='.$file_name.'; charset=SJIS-win');
			header('Content-Transfer-Encoding: binary');
			header('Expires: 0');
			header('Cache-Control: must-revalidate');
			header('Pragma: public');
			header('Content-Length: ' . filesize($file_path));
			echo file_get_contents($file_path);
		}
		exit;
	}

}
