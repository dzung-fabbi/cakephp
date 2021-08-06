<?php
App::uses('AppController', 'Controller');

class DownloadResultController extends AppController {
	var $uses = Array(
		'M03Auth',
		'M06CompanyExternal',
		'M08SmsApiInfo',
		'T12ListItem',
		'T13InboundListItem',
		'T20OutSchedule',
		'T25Inbound',
		'T56InboundListHistory',
		'T64InboundQuestionHistory',
		'T80OutgoingResult',
		'T81IncomingResult',
		'T102SmsListItem',
		'T200SmsSendSchedule',
		'T800SmsSendResult'
	);

	private $divisions = array(
		'outbound' => 'アウトバウンド',
		'inbound' => 'インバウンド',
		'sms' => 'SMS',
	);

	function beforeFilter() {
		parent::beforeFilter();

		$company_id = $this->ESession->getUserCompanyId($this);
		$gs_company = $this->M99SystemParameter->getByFunctionIdAndParameterId('COMPANY', 'GS_COMPANY_ID');
		$gs_company_id = $gs_company['M99SystemParameter']['parameter_value'];

		if ($company_id != $gs_company_id) {
			return false;
		}
		return true;
	}

	// 結果ログ一括DL
	function index($mode = null) {
		$gs_company = $this->beforeFilter();
		if ($gs_company) {
			$accounts = $this->M02Company->getAll();
		} else {
			$company_id = $this->ESession->getUserCompanyId($this);
			$accounts = $this->M02Company->getCompanyByCompanyId($company_id);
		}
		$this->set("mode", $mode);
		$this->set("divisions", $this->divisions);
		$this->set("accounts", $accounts);
		$this->set("gs_company", $gs_company);
	}

	/**
	 * 電話番号（通知番号）の取得
	 * @return array $display_numbers 電話番号（通知番号）
	 */
	function get_number_by_division_and_company() {
		$this->layout = 'ajax';
		$display_numbers = array();

		if ($this->data['division'] == 'outbound' || $this->data['division'] == 'inbound') {
			$arr_numbers = $this->M06CompanyExternal->getExternalNumberByCompanyId($this->data['company_id']);

			foreach ($arr_numbers as $tel_number) {
				$display_numbers[] = array('division' => $this->data['division'], 'tel_number' => $tel_number['M06CompanyExternal']['external_number']);
			}
		} elseif ($this->data['division'] == 'sms') {
			$arr_numbers = $this->M08SmsApiInfo->getServiceIdByCompanyId($this->data['company_id']);

			foreach ($arr_numbers as $tel_number) {
				$display_numbers[] = array('division' => $this->data['division'], 'tel_number' => $tel_number['M08SmsApiInfo']['display_number'], 'api_id' => $tel_number['M08SmsApiInfo']['api_id']);
			}
		}
		echo json_encode($display_numbers);
		exit;
	}

	function buffer_download_data() {
		$data = $this->data;
		if (empty($data)) {
			echo 'systemerror';
			exit;
		}
		$LIMIT_COUNT_RESULT = 200000;

		$division_code = $data['division_code'];
		$company_id = $data['company_id'];
		$tel_number = $data['tel_number'];
		$date_from = $data['date_from'];
		$date_to = $data['date_to'];

		$company_info = $this->M02Company->getCompanyByCompanyId($company_id);

		$download_data = Array(
			'account' => $company_info['M02Company']['company_name'],
			'tel_number' => $tel_number,
			'division' => $this->divisions[$division_code],
			'date_from' => $date_from,
			'date_to' => $date_to,
		);

		if ($division_code == 'outbound') {
			$count_result = $this->T20OutSchedule->getCallResultCountByCompanyAndTel($company_id, $tel_number, $date_from, $date_to);
			if ($count_result > $LIMIT_COUNT_RESULT) {
				$results = array(
					'status' => 'error_limit_count',
					'count_result' => $count_result
				);
				echo json_encode($results);
				exit;
			}
			$download_data['download_data'] = $this->download_outbound($company_id, $tel_number, $date_from, $date_to);
		} elseif ($division_code == 'inbound') {
			$count_result = $this->T25Inbound->getCallResultCountByCompanyAndTel($company_id, $tel_number, $date_from, $date_to);
			if ($count_result > $LIMIT_COUNT_RESULT) {
				$results = array(
					'status' => 'error_limit_count',
					'count_result' => $count_result
				);
				echo json_encode($results);
				exit;
			}
			$download_data['download_data'] = $this->download_inbound($company_id, $tel_number, $date_from, $date_to);
		} else {
			$count_result = $this->T200SmsSendSchedule->getSendResultCountByCompanyAndTel($company_id, $tel_number, $date_from, $date_to);
			if ($count_result > $LIMIT_COUNT_RESULT) {
				$results = array(
					'status' => 'error_limit_count',
					'count_result' => $count_result
				);
				echo json_encode($results);
				exit;
			}
			$download_data['download_data'] = $this->download_sms($company_id, $tel_number, $date_from, $date_to);
		}

		$this->ESession->setResultDataDownload($download_data, $this);
		$results = array(
			'status' => 'success'
		);
		echo json_encode($results);
		exit;
	}

	// 結果ログ一括ダウンロード
	function download_outbound($company_id, $tel_number, $date_from, $date_to) {
		$download_data = Array();
		$download_data_tmp = Array();
		$call_datetime_data = Array();

		for ($i=1; $i<=10; $i++) {
			$header_lists["customize$i"] = "備考$i";
		}
		$headers = array_merge(
			array(
				'external_number' => '発信元電話番号',
				'tel_no' => '電話番号',
			),
			$header_lists,
			array(
				'call_datetime' => '発信日時',
				'connect_datetime' => '接続日時',
				'cut_datetime' => '切断日時',
				'trans_call_datetime' => '転送発信日時',
				'trans_connect_datetime' => '転送接続日時',
				'trans_cut_datetime' => '転送切断日時',
				'status' => 'ステータス',
				'seconds_connect' => '通話秒数',
				'seconds_trans' => '転送秒数',
			)
		);
		$download_data[] = $headers;


		$schedules = $this->T20OutSchedule->getScheduleByCompanyAndTel($company_id, $tel_number, $date_from, $date_to);
		foreach ($schedules as $schedule) {
			$schedule_id = $schedule['T20OutSchedule']['id'];

			//get tel_column from t12
			$tel_column = $this->T12ListItem->getTelNumColumn($schedule['T20OutSchedule']['list_id']);
			$tel_column = $tel_column['T12ListItem']['column'];

			//get data from db to create csv file
			$logs = $this->T80OutgoingResult->getAllByScheduleId($schedule_id, false, $tel_column, $date_from, $date_to, true);

			foreach ($logs as $log) {
				$data = $log['T80OutgoingResult'];
				$r = array();

				$r[] = $schedule['T20OutSchedule']['external_number'];
				$r[] = $data['tel_no'];

				for ($i=1; $i<=11; $i++) {
					if ("customize$i" != $tel_column)
						$r[] = isset($log['T51TelHistory']["customize$i"]) ? $log['T51TelHistory']["customize$i"] : '';
				}

				$r[] = $call_datetime_data[] = $data['call_datetime'] == '0000-00-00 00:00:00' ? '' : $data['call_datetime'];
				$r[] = $data['connect_datetime'] == '0000-00-00 00:00:00' ? '' : $data['connect_datetime'];
				$r[] = $data['cut_datetime'] == '0000-00-00 00:00:00' ? '' : $data['cut_datetime'];

				$r[] = $data['trans_call_datetime'] == '0000-00-00 00:00:00' ? '' : $data['trans_call_datetime'];
				$r[] = $data['trans_connect_datetime'] == '0000-00-00 00:00:00' ? '' : $data['trans_connect_datetime'];
				$r[] = $data['trans_cut_datetime'] == '0000-00-00 00:00:00' ? '' : $data['trans_cut_datetime'];

				if (in_array($data['status'], $this->Util->getCallResultConnectStatusArray())) {
					if($data['status'] == "connect"){
						$r[] = 'ANSWER';
					}
					else if(in_array($data['status'], $this->Util->getCallResultConvertTFRejectArray())){
						$r[] = "TRANSFERREJECT";
					}
					else{
						$r[] = strtoupper($data['status']);
					}
					$r[] = strtotime($data['cut_datetime']) - strtotime($data['connect_datetime']);
				} else {
					$status_names = array(
						'reject' => 'REJECT',
						'recover' => 'SKIP'
					);
					$r[] = isset($status_names[$data['status']]) ? $status_names[$data['status']] : 'NOANSWER';
					$r[] = '';
				}

				$count_second_trans = strtotime($data['trans_cut_datetime']) - strtotime($data['trans_connect_datetime']);
				$r[] = $count_second_trans > 0 ? $count_second_trans : '';

				$download_data_tmp[] = $r;
			}
		}
		array_multisort($call_datetime_data, SORT_ASC, $download_data_tmp);

		return array_merge($download_data, $download_data_tmp);
	}
	function download_inbound($company_id, $tel_number, $date_from, $date_to) {
		$download_data = Array();
		$download_data_tmp = Array();
		$call_datetime_data = Array();

		for ($i=1; $i<=10; $i++) {
			$header_lists["customize$i"] = "備考$i";
		}
		$headers = array_merge(
			array(
				'external_number' => '着信先電話番号',
				'tel_no' => '電話番号',
			),
			$header_lists,
			array(
				'call_datetime' => '着信日時',
				'connect_datetime' => '接続日時',
				'cut_datetime' => '切断日時',
				'trans_call_datetime' => '転送発信日時',
				'trans_connect_datetime' => '転送接続日時',
				'trans_cut_datetime' => '転送切断日時',
				'status' => 'ステータス',
				'seconds_connect' => '通話秒数',
				'seconds_trans' => '転送秒数',
			)
		);
		$download_data[] = $headers;
		
		$inbound_question_types = array(
			QUESTION_BASIC,
			QUESTION_AUTH,
			QUESTION_TEL,
			QUESTION_TRANS,
			QUESTION_RECORD,
			QUESTION_COUNT,
			QUESTION_AUTH_CHAR,
			QUESTION_PROPERTY,
			QUESTION_FAX,
			QUESTION_PROPERTY_SEARCH,
			QUESTION_INBOUND_SMS,
			QUESTION_INBOUND_COLLATION,
			QUESTION_INBOUND_SMS_INPUT
		);
		


		$schedules = $this->T25Inbound->getScheduleByCompanyAndTel($company_id, $tel_number, $date_from, $date_to);

		foreach ($schedules as $schedule) {
			$schedule_id = $schedule['T25Inbound']['id'];
			$list_id = $schedule['T25Inbound']['list_id'];
			$arr_answer_pos = $this->get_answer_pos($schedule_id);
			
			//テンプレートの全タイプを保持
			$download_log_tmp_question_all_type = $this->T64InboundQuestionHistory->getQuesNumByScheduleId($schedule_id, $inbound_question_types);
			foreach ($download_log_tmp_question_all_type as $download_log_tmp) {
				$download_log_question_all_type[] = $download_log_tmp['T64InboundQuestionHistory']['question_type'];
			}

			$answer_pos_auth_character = NULL;
			$question_types = array(
				QUESTION_AUTH_CHAR
			);
			$question_temps = $this->T64InboundQuestionHistory->getInfoQuesAnswByScheduleId($schedule_id, $question_types);
			foreach ($question_temps as $ques) {
				$ques_no = $ques['T64InboundQuestionHistory']['question_no'];
				if ($ques['T64InboundQuestionHistory']['auth_match_flag'] == 1) {
					$answer_pos_auth_character = $arr_answer_pos[$ques_no];
					break;
				}
			}

			//add header for csv file
			$item_main_column = NULL;
			$join_col = NULL;
			$item_main_code = NULL;
			$tel_column = '';

			if ($list_id) {
				$tel_column = $this->T13InboundListItem->getTelNumColumn($list_id);
				$tel_column = isset($tel_column['T13InboundListItem']['column']) ? $tel_column['T13InboundListItem']['column'] : '';

				$list_item = $this->T56InboundListHistory->getInfoItemMain($schedule_id, $list_id);
				if ($list_item) {
					$item_main_column = $list_item['T13InboundListItem']['column'];
					$item_main_code = $list_item['T13InboundListItem']['item_code'];
				}

				if ($answer_pos_auth_character) {
					$join_col = 'answer' . $answer_pos_auth_character;
				} elseif ($item_main_code == 'tel_no') {
					$join_col = 'tel_no';
				}
			}
			
			//着信番号照合のみ（文字列認証なし）の場合は電話番号のカラムをセットする。
			if(!in_array(QUESTION_AUTH_CHAR,$download_log_question_all_type) && in_array(QUESTION_INBOUND_COLLATION,$download_log_question_all_type)){
				$tmp_item_main_column = $this->T13InboundListItem->getTelNumColumn($list_id);
				$item_main_column = $tmp_item_main_column['T13InboundListItem']['column'];
			}

			if (in_array(QUESTION_AUTH_CHAR,$download_log_question_all_type) && in_array(QUESTION_INBOUND_COLLATION,$download_log_question_all_type)
					|| in_array(QUESTION_INBOUND_COLLATION,$download_log_question_all_type)){
				$join_col = 'memo';
				$logs = $this->T81IncomingResult->getallbyscheduleid_inboundcollation($schedule_id, $item_main_column, $join_col , null , $date_from , $date_to, true);
			} else{
				$logs = $this->T81IncomingResult->getAllByScheduleId($schedule_id, $item_main_column, $join_col , null , $date_from , $date_to, true);
			}

			foreach ($logs as $log) {
				if ($log['T81IncomingResult']['status'] != "recover") {
					$data = $log['T81IncomingResult'];
					$r = array();
					$r[] = $schedule['T25Inbound']['external_number'];
					$r[] = empty($data['tel_no']) ? 'anonymous' : $data['tel_no'];

					if ($tel_column) {
						for ($i = 1; $i <= 11; $i++) {
							if ("customize$i" != $tel_column)
								$r[] = isset($log['T57InboundTelHistory']["customize$i"]) ? $log['T57InboundTelHistory']["customize$i"] : '';
						}
					} else {
						for ($i = 1; $i <= 10; $i++) {
							$r[] = isset($log['T57InboundTelHistory']["customize$i"]) ? $log['T57InboundTelHistory']["customize$i"] : '';
						}
					}

					$r[] = $call_datetime_data[] = $data['call_datetime'] == '0000-00-00 00:00:00' ? '' : $data['call_datetime'];
					$r[] = $data['connect_datetime'] == '0000-00-00 00:00:00' ? '' : $data['connect_datetime'];
					$r[] = $data['cut_datetime'] == '0000-00-00 00:00:00' ? '' : $data['cut_datetime'];

					$r[] = $data['trans_call_datetime'] == '0000-00-00 00:00:00' ? '' : $data['trans_call_datetime'];
					$r[] = $data['trans_connect_datetime'] == '0000-00-00 00:00:00' ? '' : $data['trans_connect_datetime'];
					$r[] = $data['trans_cut_datetime'] == '0000-00-00 00:00:00' ? '' : $data['trans_cut_datetime'];

					if(in_array($data['status'], $this->Util->getCallResultNoConvertArray())){
						$r[] = strtoupper($data['status']);
					}
					else if(in_array($data['status'], $this->Util->getCallResultConvertTFRejectArray())){
						$r[] = "TRANSFERREJECT";
					}
					else{
						$r[] = 'ANSWER';
					}

					$r[] = strtotime($data['cut_datetime']) - strtotime($data['connect_datetime']);
					$count_second_trans = strtotime($data['trans_cut_datetime']) - strtotime($data['trans_connect_datetime']);
					$r[] = $count_second_trans > 0 ? $count_second_trans : '';

					$download_data_tmp[] = $r;
				}
			}
		}
		array_multisort($call_datetime_data, SORT_ASC, $download_data_tmp);

		return array_merge($download_data, $download_data_tmp);
	}
	function download_sms($company_id, $tel_number, $date_from, $date_to) {
		$download_data = Array();
		$download_data_tmp = Array();
		$call_datetime_data = Array();

		for ($i=1; $i<=10; $i++) {
			$header_lists["customize$i"] = "備考$i";
		}
		$headers = array_merge(
			array(
				'time_start' => '送信日時',
				'display_number' => '通知番号',
				'tel_no' => '電話番号',
			),
			$header_lists,
			array(
				'status' => '送達状態',
				'warning_msg' => '送達警告情報',
				'sms_short_url_key' => '短縮URLキー',
			)
		);

		$download_data[] = $headers;

		$schedules = $this->T200SmsSendSchedule->getScheduleByCompanyAndTel($company_id, $tel_number, $date_from, $date_to);
		foreach ($schedules as $schedule) {
			$schedule_id = $schedule['T200SmsSendSchedule']['id'];

			//get tel_column from t102
			$tel_column = $this->T102SmsListItem->getTelNumColumn($schedule['T200SmsSendSchedule']['list_id']);
			$tel_column = $tel_column['T102SmsListItem']['column'];

			//get data from db to create csv file
			$logs = $this->T800SmsSendResult->getAllByScheduleId($schedule_id, $tel_column, null, null, null, null, $date_from, $date_to, true);

			foreach ($logs as $log) {
				$data = $log['T800SmsSendResult'];
				$r = array();

				$r[] = $schedule['T202SmsSendLog']['time_start'];
				$r[] = $schedule['T200SmsSendSchedule']['display_number'];
				$r[] = $data['tel_no'];

				for ($i=1; $i<=11; $i++) {
					if ("customize$i" != $tel_column)
						$r[] = empty($log['T501SmsTelHistory']["customize$i"]) ? '' : $log['T501SmsTelHistory']["customize$i"];
				}

				$status_names = array(
					'success' => '着信済み',
					'unknown' => '不明',
					'outside' => '圏外',
					'history_judgement_ng' => '履歴判定NG', // #8298 add consentday
				);

				if (!empty($data['status'])) {
					$r[] = isset($status_names[$data['status']]) ? $status_names[$data['status']] : 'エラー';
				} else {
					$r[] = '';
				}

				$r[] = !empty($data['warning_msg']) ? $data['warning_msg'] : '';
				$r[] = !empty($data['sms_short_url_key']) ? $data['sms_short_url_key'] : '';

				$download_data_tmp[] = $r;

				$call_datetime_data[] = $data['send_datetime'];
			}
		}

		array_multisort($call_datetime_data, SORT_ASC, $download_data_tmp);

		return array_merge($download_data, $download_data_tmp);
	}

	function download_result() {
		$download_data = $this->ESession->getResultDataDownload($this);
		if (!isset($download_data)) {
			$this->redirect(array('controller' => 'DownloadResult', 'action' => 'index'));
		}

		foreach ($download_data['download_data'] as $row) {
			$this->Csv->addRow($row);
		}

		$systemTitle = $download_data['account'] . '_' .
			$download_data['tel_number'] . '_' .
			$download_data['division'] . '_' .
			date('Ymd', strtotime($download_data['date_from'])) . '_' .
			date('Ymd', strtotime($download_data['date_to'])) . '_' .
			date('YmdHis', time()) . '.csv';
		$title = mb_convert_encoding($systemTitle, "SJIS-win", "UTF-8");

		echo $this->Csv->render($title, 'SJIS-win');
		$this->Session->delete('result_data_download');
		exit;
	}
	function buffer_download_all_data() {
        $data = $this->data;
        if (empty($data)) {
            $results = array(
                'status' => 'systemerror'
            );
            echo json_encode($results);
            exit;
        }
        $divisions = array(
            'outbound' => 'アウトバウンド',
            'inbound' => 'インバウンド',
            'sms' => 'SMS',
        );

        $division_code = $data['division_code'];
        $division_code = $divisions[$division_code];
        $year = $data['year'];
        $month = $data['month'];
        $filename = $division_code . "_" . $year . $month . '.zip';
        $path_base = "/home/robo/var/bulk_history/";
        $fullPath = $path_base.$filename;
        if( headers_sent() )
            die('Headers Sent');

        if(ini_get('zlib.output_compression'))
            ini_set('zlib.output_compression', 'Off');

        if( file_exists($fullPath) )
        {
            $this->ESession->setResultDataDownload($fullPath, $this);
            $results = array(
                'status' => 'success'
            );
            echo json_encode($results);
            exit;

        } else {
            $results = array(
                'status' => 'file_not_found'
            );
            echo json_encode($results);
            die();
        }

    }
    function download_all_result() {
        $fullPath = $this->ESession->getResultDataDownload($this);
        $filename = substr($fullPath, strlen("/home/robo/var/bulk_history/") - strlen($fullPath));
        $filesize = filesize($fullPath);
        header("Pragma: public");
        header("Expires: 0");
        header("Cache-Control: must-revalidate, post-check=0, pre-check=0");
        header("Cache-Control: private",false);
        header("Content-Type: application/zip");
        header("Content-Disposition: attachment; filename=\"".$filename."\";" );
        header("Content-Transfer-Encoding: binary");
        header("Content-Length: ".$filesize);
        ob_clean();
        flush();
        echo readfile( $fullPath );
        $this->Session->delete('result_data_download');
        exit;
    }
	function get_answer_pos($schedule_id) {
		$arr_answer_pos = array();
		$current_pos = 1;
		$arr_count_column = array(
			QUESTION_VOICE => 0,
			QUESTION_BASIC => 1,
			QUESTION_AUTH => array(
				0 => 1,
				1 => 4
			),
			QUESTION_TEL => array(
				0 => 1,
				1 => 2
			),
			QUESTION_TRANS => 0,
			QUESTION_RECORD => 0,
			QUESTION_COUNT => 1,
			QUESTION_END => 0,
			QUESTION_TIMEOUT => 0,
			QUESTION_AUTH_CHAR => array(
				0 => 1,
				1 => 3
			),
			QUESTION_FAX => 5,
			QUESTION_PROPERTY => 7,
			QUESTION_PROPERTY_SEARCH => 13,
		);
		$questions = $this->T64InboundQuestionHistory->getQuesNumByScheduleId($schedule_id);

		foreach ($questions as $question) {
			$question_no = $question['T64InboundQuestionHistory']['question_no'];
			$question_type = $question['T64InboundQuestionHistory']['question_type'];
			if (in_array($question_type, array(QUESTION_AUTH, QUESTION_TEL, QUESTION_AUTH_CHAR))) {
				$count_column = $arr_count_column[$question_type][$question['T64InboundQuestionHistory']['recheck_flag']];
			} else {
				$count_column = $arr_count_column[$question_type];
			}

			if ($count_column > 0) {
				$arr_answer_pos[$question_no] = $current_pos;
				$current_pos += $count_column;
			} elseif ($question_type == QUESTION_TRANS) {
				$arr_answer_pos[$question_no] = 'trans_call_time';
			} else {
				$arr_answer_pos[$question_no] = NULL;
			}
		}

		return $arr_answer_pos;
	}

	private function _getInboundCheduleOutTime($timeStart, $timeEnd){

    }
}
