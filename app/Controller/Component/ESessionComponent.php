<?php
class ESessionComponent extends Component {
	//ログイン履歴関連
	function setLoginId($value, &$controller) {
		$flag = $controller->Session->write('login_id', $value);

		if($flag == false) {
			//セッション作成失敗
			$controller->log("セッション作成失敗：".__FUNCTION__);
			$controller->redirect(array('controller' => 'Login', 'action' => 'index/error'));
		}
	}
	function getLoginId(&$controller) {
		return $controller->Session->read('login_id');
	}
	//パラメータ関連
	function setCommInfo($value, &$controller) {
		$flag = $controller->Session->write('comm_info', $value);

		if($flag == false) {
			//セッション作成失敗
			$controller->log("セッション作成失敗：".__FUNCTION__);
			$controller->redirect(array('controller' => 'Login', 'action' => 'index/error'));
		}
	}
	function getCommInfo(&$controller) {
		return $controller->Session->read('comm_info');
	}
	//分類コード関連
	function setPostCode($value, &$controller) {
		$flag = $controller->Session->write('post_code', $value);

		if($flag == false) {
			//セッション作成失敗
			$controller->log("セッション作成失敗：".__FUNCTION__);
			$controller->redirect(array('controller' => 'Login', 'action' => 'index/error'));
		}
	}
	function getPostCode(&$controller) {
		return $controller->Session->read('post_code');
	}



	//ログインユーザーSeqID関連
	function setSeqId($value, &$controller) {
		$flag = $controller->Session->write('id', $value);

		if($flag == false) {
			//セッション作成失敗
			$controller->log("セッション作成失敗：".__FUNCTION__);
			$controller->redirect(array('controller' => 'Login', 'action' => 'index/error'));
		}
	}
	function getSeqId(&$controller) {
		return $controller->Session->read('id');
	}

	//ログインユーザーID関連
	function setUserId($value, &$controller) {
		$flag = $controller->Session->write('user_id', $value);

		if($flag == false) {
			//セッション作成失敗
			$controller->log("セッション作成失敗：".__FUNCTION__);
			$controller->redirect(array('controller' => 'Login', 'action' => 'index/error'));
		}
	}
	function getUserId(&$controller) {
		return $controller->Session->read('user_id');
	}


	//ログインユーザー名関連
	function setUserName($value, &$controller) {
		$flag = $controller->Session->write('user_name', $value);

		if($flag == false) {
			//セッション作成失敗
			$controller->log("セッション作成失敗：".__FUNCTION__);
			$controller->redirect(array('controller' => 'Login', 'action' => 'index/error'));
		}
	}
	function getUserName(&$controller) {
		return $controller->Session->read('user_name');
	}

	function setUserCompanyId($value, &$controller) {
		$flag = $controller->Session->write('company_id', $value);

		if($flag == false) {
			//セッション作成失敗
			$controller->log("セッション作成失敗：".__FUNCTION__);
			$controller->redirect(array('controller' => 'Login', 'action' => 'index/error'));
		}
	}
	function getUserCompanyId(&$controller) {
		return $controller->Session->read('company_id');
	}

	function setUserPostCode($value, &$controller) {
		$flag = $controller->Session->write('post_code', $value);

		if($flag == false) {
			//セッション作成失敗
			$controller->log("セッション作成失敗：".__FUNCTION__);
			$controller->redirect(array('controller' => 'Login', 'action' => 'index/error'));
		}
	}
	function getUserPostCode(&$controller) {
		return $controller->Session->read('post_code');
	}

	function setUserPostName($value, &$controller) {
		$flag = $controller->Session->write('post_name', $value);

		if($flag == false) {
			//セッション作成失敗
			$controller->log("セッション作成失敗：".__FUNCTION__);
			$controller->redirect(array('controller' => 'Login', 'action' => 'index/error'));
		}
	}
	function getUserPostName(&$controller) {
		return $controller->Session->read('post_name');
	}

	function setMaxRedial($value, &$controller) {
		$flag = $controller->Session->write('max_redial', $value);

		if($flag == false) {
			//セッション作成失敗
			$controller->log("セッション作成失敗：".__FUNCTION__);
			$controller->redirect(array('controller' => 'Login', 'action' => 'index/error'));
		}
	}
	function getMaxRedial(&$controller) {
		return $controller->Session->read('max_redial');
	}

	function setServerId($value, &$controller) {
		$flag = $controller->Session->write('server_id', $value);

		if($flag == false) {
			//セッション作成失敗
			$controller->log("セッション作成失敗：".__FUNCTION__);
			$controller->redirect(array('controller' => 'Login', 'action' => 'index/error'));
		}
	}
	function getServerId(&$controller) {
		return $controller->Session->read('server_id');
	}

	function setCallTell($value, &$controller) {
		$flag = $controller->Session->write('call_tel', $value);

		if($flag == false) {
			//セッション作成失敗
			$controller->log("セッション作成失敗：".__FUNCTION__);
			$controller->redirect(array('controller' => 'Login', 'action' => 'index/error'));
		}
	}
	function getCallTell(&$controller) {
		return $controller->Session->read('call_tel');
	}

	//ログアウト処理
	function logout(&$controller) {
		$controller->Session->destroy();
	}

	// set data for create schedule
	function setDataCreateSchedule($data_create_schedule, &$controller) {
		$flag = $controller->Session->write('data_create_schedule', $data_create_schedule);

		if($flag == false) {
			//セッション作成失敗
			$controller->log("セッション作成失敗：".__FUNCTION__);
			$controller->redirect(array('controller' => 'Login', 'action' => 'error'));
		}
	}

	function getDataCreateShedule(&$controller) {
		return $controller->Session->read('data_create_schedule');
	}

	//sort script
	function setSortColumn($sort, &$controller) {
		$flag = $controller->Session->write('sort_column', $sort);

		if($flag == false) {
			//セッション作成失敗
			$controller->log("セッション作成失敗：".__FUNCTION__);
			$controller->redirect(array('controller' => 'Login', 'action' => 'error'));
		}
	}
	function getSortColumn(&$controller) {
		return $controller->Session->read('sort_column');
	}
	function setSortType($sort, &$controller) {
		$flag = $controller->Session->write('sort_type', $sort);

		if($flag == false) {
			//セッション作成失敗
			$controller->log("セッション作成失敗：".__FUNCTION__);
			$controller->redirect(array('controller' => 'Login', 'action' => 'error'));
		}
	}
	function getSortType(&$controller) {
		return $controller->Session->read('sort_type');
	}
	//page script
	function setPage($sort, &$controller) {
		$flag = $controller->Session->write('page', $sort);

		if($flag == false) {
			//セッション作成失敗
			$controller->log("セッション作成失敗：".__FUNCTION__);
			$controller->redirect(array('controller' => 'Login', 'action' => 'error'));
		}
	}

	function getPage(&$controller) {
		return $controller->Session->read('page');
	}
	//server_id
	function setServerIp($value, &$controller) {
		$flag = $controller->Session->write('server_ip', $value);

		if($flag == false) {
			//セッション作成失敗
			$controller->log("セッション作成失敗：".__FUNCTION__);
			$controller->redirect(array('controller' => 'Login', 'action' => 'index/error'));
		}
	}
	function getServerIp(&$controller) {
		return $controller->Session->read('server_ip');
	}
	//time_reload
	function setTimeReload($value, &$controller) {
		$flag = $controller->Session->write('time_reload', $value);

		if($flag == false) {
			//セッション作成失敗
			$controller->log("セッション作成失敗：".__FUNCTION__);
			$controller->redirect(array('controller' => 'Login', 'action' => 'index/error'));
		}
	}
	function getTimeReload(&$controller) {
		return $controller->Session->read('time_reload');
	}

	//time_reload_status
	function setTimeReloadStatus($value, &$controller) {
		$flag = $controller->Session->write('time_reload_status', $value);

		if($flag == false) {
			//セッション作成失敗
			$controller->log("セッション作成失敗：".__FUNCTION__);
			$controller->redirect(array('controller' => 'Login', 'action' => 'index/error'));
		}
	}
	function getTimeReloadStatus(&$controller) {
		return $controller->Session->read('time_reload_status');
	}

	//time_reload_sms
	function setTimeReloadSms($value, &$controller) {
		$flag = $controller->Session->write('time_reload_sms', $value);

		if($flag == false) {
			//セッション作成失敗
			$controller->log("セッション作成失敗：".__FUNCTION__);
			$controller->redirect(array('controller' => 'Login', 'action' => 'index/error'));
		}
	}
	function getTimeReloadSms(&$controller) {
		return $controller->Session->read('time_reload_sms');
	}

	//time_reload_sms_status
	function setTimeReloadSmsStatus($value, &$controller) {
		$flag = $controller->Session->write('time_reload_sms_status', $value);

		if($flag == false) {
			//セッション作成失敗
			$controller->log("セッション作成失敗：".__FUNCTION__);
			$controller->redirect(array('controller' => 'Login', 'action' => 'index/error'));
		}
	}
	function getTimeReloadSmsStatus(&$controller) {
		return $controller->Session->read('time_reload_sms_status');
	}

	function setCallListId($value, &$controller) {
		$flag = $controller->Session->write('call_list_id', $value);

		if($flag == false) {
			//セッション作成失敗
			$controller->log("セッション作成失敗：".__FUNCTION__);
			$controller->redirect(array('controller' => 'Login', 'action' => 'index/error'));
		}
	}
	function getCallListId(&$controller) {
		return $controller->Session->read('call_list_id');
	}

	function setDataCsvDownload($value, &$controller) {
		$flag = $controller->Session->write('data_csv_download', $value);

		if($flag == false) {
			//セッション作成失敗
			$controller->log("セッション作成失敗：".__FUNCTION__);
			$controller->redirect(array('controller' => 'Login', 'action' => 'index/error'));
		}
	}
	function getDataCsvDownload(&$controller) {
		return $controller->Session->read('data_csv_download');
	}

	function setTemplateQuestionDataDownload($value, &$controller) {
		$flag = $controller->Session->write('template_question_data', $value);

		if($flag == false) {
			//セッション作成失敗
			$controller->log("セッション作成失敗：".__FUNCTION__);
			$controller->redirect(array('controller' => 'Login', 'action' => 'index/error'));
		}
	}
	function getTemplateQuestionDataDownload(&$controller) {
		return $controller->Session->read('template_question_data');
	}

	function setTemplateWavFileDownload($value, &$controller) {
		$flag = $controller->Session->write('template_wav_file', $value);

		if($flag == false) {
			//セッション作成失敗
			$controller->log("セッション作成失敗：".__FUNCTION__);
			$controller->redirect(array('controller' => 'Login', 'action' => 'index/error'));
		}
	}
	function getTemplateWavFileDownload(&$controller) {
		return $controller->Session->read('template_wav_file');
	}

	function setScheduleDataDownload($value, &$controller) {
		$flag = $controller->Session->write('schedule_data_download', $value);

		if($flag == false) {
			//セッション作成失敗
			$controller->log("セッション作成失敗：".__FUNCTION__);
			$controller->redirect(array('controller' => 'Login', 'action' => 'index/error'));
		}
	}
	function getScheduleDataDownload(&$controller) {
		return $controller->Session->read('schedule_data_download');
	}

	function setResultDataDownload($value, &$controller) {
		$flag = $controller->Session->write('result_data_download', $value);

		if($flag == false) {
			//セッション作成失敗
			$controller->log("セッション作成失敗：".__FUNCTION__);
			$controller->redirect(array('controller' => 'Login', 'action' => 'index/error'));
		}
	}
	function getResultDataDownload(&$controller) {
		return $controller->Session->read('result_data_download');
	}

	function setSmsScheduleDataDownload($value, &$controller) {
		$flag = $controller->Session->write('sms_schedule_data_download', $value);

		if($flag == false) {
			//セッション作成失敗
			$controller->log("セッション作成失敗：".__FUNCTION__);
			$controller->redirect(array('controller' => 'Login', 'action' => 'index/error'));
		}
	}
	function getSmsScheduleDataDownload(&$controller) {
		return $controller->Session->read('sms_schedule_data_download');
	}

	// 20160413 Add by Giang - #6906 Inbound history screen - Begin
	function setInboundId($value, &$controller) {
		$flag = $controller->Session->write('inbound_id', $value);

		if($flag == false) {
			//セッション作成失敗
			$controller->log("セッション作成失敗：".__FUNCTION__);
			$controller->redirect(array('controller' => 'Login', 'action' => 'index/error'));
		}
	}
	function getInboundId(&$controller) {
		return $controller->Session->read('inbound_id');
	}
	// 20160413 Add by Giang - #6906 Inbound history screen - Begin

	function setSmsSendListId($value, &$controller) {
		$flag = $controller->Session->write('smssend_list_id', $value);

		if($flag == false) {
			//セッション作成失敗
			$controller->log("セッション作成失敗：".__FUNCTION__);
			$controller->redirect(array('controller' => 'Login', 'action' => 'index/error'));
		}
	}
	function getSmsSendListId(&$controller) {
		return $controller->Session->read('smssend_list_id');
	}
}