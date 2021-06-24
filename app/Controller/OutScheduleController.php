<?php
App::uses('AppController', 'Controller');

class OutScheduleController extends AppController {
	var $uses = array(
		'M90PulldownCode', 'M01Config', 'T20OutSchedule', 'T10CallList',
		'T30Template', 'T31TemplateQuestion', 'T11TelList', 'T92Lock',
		'M04ControllerAction', 'T21OutTime', 'M06CompanyExternal',
		'T14OutgoingNgList', 'M02Company','T31TemplateQuestion', 'M08SmsApiInfo', 
		'M99SystemParameter', 'T80OutgoingResult', 'T22OutLog',
		'T51TelHistory', 'T55TelNgHistory', 'T61QuestionHistory', 'T12ListItem', 'M01Server', 'T15OutgoingNgTel', 'T52TelRedial',
		'T83OutgoingSmsStatus','M07ServerExternal', 'M09KaisenInfo');

	const ITEM_REGEX = '/{.*?}/';
	const LEFT_BRACE_REGEX = '/{/';
	const RIGHT_BRACE_REGEX = '/}/';
	const BRACE_REGEX = '/{|}/';

	function index($mode = null, $del_count=null) {/*20160311 Edit by Giang : #6695 - display the record quantity has been deleted*/
		$this->ESession->setDataCreateSchedule(null, $this);

		if($mode == "delete"){
			$sortColumn = $this->ESession->getSortColumn($this);
			$sortType = $this->ESession->getSortType($this);
			$page = $this->ESession->getPage($this);
			$this->set("sortColumn", $sortColumn);
			$this->set("sortType", $sortType);
			$this->set("page", $page);
			$this->set('del_count', $del_count);/*20160311 Add by Giang : #6695 - display the record quantity has been deleted*/
		}

		$schedule_time_reload = $this->M90PulldownCode->getSelectOption('schedule_time_reload');

		$this->set('mode', $mode);
		$this->set('schedule_time_reload', $schedule_time_reload);
		$this->set('time_reload', $this->ESession->getTimeReload($this));

		$post_code = $this->ESession->getUserPostCode($this);

        $create_flag = $this->M04ControllerAction->check_permission($post_code, 'Schedule', 'create');
        $delete_flag = $this->M04ControllerAction->check_permission($post_code, 'Schedule', 'delete');
        $download_flag = $this->M04ControllerAction->check_permission($post_code, 'Schedule', 'download');

		$min_distance_call_time = $this->M99SystemParameter->getByFunctionIdAndParameterId('SCHEDULE', 'MIN_TIME_CALL');
		if (sizeof($min_distance_call_time) > 0) {
			$min_distance_call_time = $min_distance_call_time['M99SystemParameter']['parameter_value'];
		} else {
			$min_distance_call_time = 0;
		}
		$this->set('min_distance_call_time', $min_distance_call_time);

        $this->set('create_flag', $create_flag);
        $this->set('delete_flag', $delete_flag);
        $this->set('download_flag', $download_flag);
	}

	function arr_schedule($js_page, $limit, $column) {
		if (isset($this->viewVars['error_login']) && $this->viewVars['error_login']) {
			$res = array('status' => 'error_login');
			echo json_encode($res);
			exit;
		}

		$this->layout = 'ajax';
		if(isset($_GET["filter"]) && !empty($_GET["filter"])){
			$filter = $_GET["filter"];
		}else $filter = null;
		$post_code = $this->ESession->getUserPostCode($this);
        $delete_flag = $this->M04ControllerAction->check_permission($post_code, 'Schedule', 'delete');
		$page = $js_page + 1;
		$json_data = Array();
		$json_data["headers"] = Array("NO","スケジュール名","発信日","発信時間","テンプレート","発信リスト","リスト数","発信件数", "作成日時", "作成者", "アクション");
		$json_data["rows"] = Array();
		$company_id = $this->ESession->getUserCompanyId($this);
		$sort_order = $this->Util->getScheduleSortOrder($column, $delete_flag ? 1 : 0);
		if ($delete_flag) {
			array_unshift($json_data["headers"], "cb");
		}
		else {
			$keyArr = array();
			if ($filter != null) {
				while (current($filter)) {
					$keyArr[] = key($filter) + 1;
					next($filter);
				}
				$filter = array_combine($keyArr, array_values($filter));
			}
		}

		//20160328 - Add by Thai - Fix filter by tel_total - Begin
		if (isset($filter[7])) {
			if ($column == 'column[7]=0' || $column == 'column[7]=1') {
				$arr_schedules = $this->T20OutSchedule->getScheduleByCompanyId($company_id, null, null, null, $filter);
			} else {
				$arr_schedules = $this->T20OutSchedule->getScheduleByCompanyId($company_id, null, null, $sort_order[0], $filter);
			}
			$arr_schedules = $this->filter_tel_total_schedules($filter[7], $arr_schedules, null);

			if ($column == 'column[7]=0' || $column == 'column[7]=1') {
				$arr_schedules = $this->sort_tel_total_schedules($column, $arr_schedules);
			}
			$json_data["total_rows"] = sizeof($arr_schedules);
			$arr_schedules = array_slice($arr_schedules, ($page - 1) * $limit, $limit);
		} else {
			if ($column == 'column[7]=0' || $column == 'column[7]=1') {
				$arr_schedules = $this->T20OutSchedule->getScheduleByCompanyId($company_id, null, null, null, $filter);
				$arr_schedules = $this->filter_tel_total_schedules(null, $arr_schedules, null);
				$arr_schedules = $this->sort_tel_total_schedules($column, $arr_schedules);
				$json_data["total_rows"] = sizeof($arr_schedules);
				$arr_schedules = array_slice($arr_schedules, ($page - 1) * $limit, $limit);
			} else {
				$arr_schedules = $this->T20OutSchedule->getScheduleByCompanyId($company_id, $limit, $page, $sort_order[0], $filter);
				$schedule_count = $this->T20OutSchedule->getScheduleByCompanyIdCount($company_id, $filter);
				$arr_schedules = $this->filter_tel_total_schedules(null, $arr_schedules, null);
				$total_row = $schedule_count[0]["total"];
				$json_data["total_rows"] = (int)$total_row;
			}
		}
		//20160328 - Add by Thai - Fix filter by tel_total - End

		//20160328 - Delete by Thai - Fix filter by tel_total - Begin
		/*$arr_schedules = $this->T20OutSchedule->getScheduleByCompanyId($company_id, $limit, $page, $sort_order[0], $filter);
		$schedule_count = $this->T20OutSchedule->getScheduleByCompanyIdCount($company_id, $filter);
		$total_row = $schedule_count[0]["total"];
		$json_data["total_rows"] = (int)$total_row;*/
		//20160328 - Delete by Thai - Fix filter by tel_total - End

		$schedule_ids = array();
		foreach ($arr_schedules as $arr_schedule) {
			$schedule_ids[] = $arr_schedule['T20OutSchedule']['id'];
		}

		if ($column == 'column[4]=0' || $column == 'column[4]=1') {
			$sort_order_out_time = $this->Util->getOutTimeSortOrder($column);
			$arr_out_time_tmps = $this->T21OutTime->getByScheduleIds($schedule_ids, $sort_order_out_time[0]);
		} else {
			$arr_out_time_tmps = $this->T21OutTime->getByScheduleIds($schedule_ids);
		}

		$arr_out_times = array();
		foreach ($arr_out_time_tmps as $arr_out_time) {
			$arr_out_times[$arr_out_time['T21OutTime']['schedule_id']][] = $arr_out_time;
		}

		$schedules = array();
		//20160328 - Delete by Thai - Fix filter by call_time - Begin
//		if(isset($filter[4])){
//			$schedules = $this->T21OutTime->getScheduleByTime($filter[4], $schedule_ids);
//			$json_data["total_rows"] = sizeof($schedules);
//		}
		//20160328 - Delete by Thai - Fix filter by call_time - End
		//20160328 - Delete by Thai - Fix filter by tel_total - Begin
/*		$arr_schedules = $this->filter_tel_total_schedules(isset($filter[7]) ? $filter[7] : null, $arr_schedules, $schedules);
		if (isset($filter[7])) {
			$json_data["total_rows"] = sizeof($arr_schedules);
		}

		if ($column == 'column[7]=0' || $column == 'column[7]=1') {
			$arr_schedules = $this->sort_tel_total_schedules($column, $arr_schedules);
		}*/
		//20160328 - Delete by Thai - Fix filter by tel_total - End

		foreach ($arr_schedules as $key => $arr_schedule) {
			$i = 0;
			//20160328 - Delete by Thai - Fix filter by call_time - Begin
			//if (!isset($filter[4]) || in_array($arr_schedule['T20OutSchedule']['id'], $schedules)){
			//20160328 - Delete by Thai - Fix filter by call_time - End
				$json_row = array();
				$status = $arr_schedule['T20OutSchedule']['status'];

				if($status == STATUS_NO_CALL){
					$color = "white";
					$class = "";
				}else if($status == STATUS_CALLING){
					$color = "#b4e3f2";
					$class = "elereload";
				}else if($status == STATUS_STOP_CALL){
					$color = "#ed9191";
					$class = "";
				}else if($status == STATUS_FINISH){
					$color = "#c3c3c3";
					$class = "";
				}else if($status == STATUS_STOPING || $status == STATUS_FINISHING){
					$color = "#f2d6b1";
					$class = "elereload";
				}else if($status == STATUS_TEMP_FINISH){
					$color = "#FBF483";
					$class = "elereload";
				}else if($status == STATUS_REDIAL_WAIT){
					$color = "#D1F18E";
					$class = "elereload";
				}else{
					$color = "white";
					$class = "";
				}
				if ($delete_flag)
				$json_row[$json_data["headers"][$i++]] = '<td style="background-color: '.$color.'">'
					. '<input type="checkbox" name="cbSelect['
					. $arr_schedule['T20OutSchedule']['id'] . ']" id="cbSelect['
					. $arr_schedule['T20OutSchedule']['id'] . ']" schedule_id="'
					. $arr_schedule['T20OutSchedule']['id'] . '" onclick="updateCheckStatus(\'bundleCheckbox\');">'
					. '<label for="cbSelect[' . $arr_schedule['T20OutSchedule']['id'] . ']" style="margin-top: 2px;"></label>'
					. '</td>';

				$json_row[$json_data["headers"][$i++]] = '<td style="background-color: '.$color.'">'.$arr_schedule['T20OutSchedule']['schedule_no'].'</td>';
				$json_row[$json_data["headers"][$i++]] = '<td style="background-color: '.$color.'" class="break_word">'.$arr_schedule['T20OutSchedule']['schedule_name'].'</td>';


				$str_call_time = '';
				if (isset($arr_out_times[$arr_schedule['T20OutSchedule']['id']])) {
					foreach ($arr_out_times[$arr_schedule['T20OutSchedule']['id']] as $out_time) {
						$time_start = date('H:i', strtotime($out_time['T21OutTime']['time_start']));
						$time_end = date('H:i', strtotime($out_time['T21OutTime']['time_end']));
						$str_call_time .= $time_start.'～'.$time_end.'<br>';
					}
				}
				$str_call_date = date('Y-m-d', strtotime($arr_schedule['T21OutTime']['time_start']));
				$json_row[$json_data["headers"][$i++]] = '<td style="background-color: '.$color.'">'.$str_call_date.'</td>';
				$json_row[$json_data["headers"][$i++]] = '<td style="background-color: '.$color.'">'.$str_call_time.'</td>';
				$json_row[$json_data["headers"][$i++]] = '<td style="background-color: '.$color.'" class="break_word">'.$arr_schedule[0]['template_name'].'</td>';
				$json_row[$json_data["headers"][$i++]] = '<td style="background-color: '.$color.'" class="break_word">'.$arr_schedule[0]['list_name'].'</td>';

				$json_row[$json_data["headers"][$i++]] = '<td style="background-color: '.$color.'">'.$arr_schedule['tel_total'].'</td>';
				$json_row[$json_data["headers"][$i++]] = '<td style="background-color: '.$color.'" class="called_total '.$class.'">'.$arr_schedule['T20OutSchedule']['called_total'].'</td>';
				$json_row[$json_data["headers"][$i++]] = '<td style="background-color: '.$color.'">'.date('Y-m-d H:i', strtotime($arr_schedule['T20OutSchedule']['created'])).'</td>';
				$json_row[$json_data["headers"][$i++]] = '<td style="background-color: '.$color.'" class="break_word">'.$arr_schedule['M05User']['user_name'].'</td>';

				$post_code = $this->ESession->getUserPostCode($this);
	            $create_flag = $this->M04ControllerAction->check_permission($post_code, 'Schedule', 'create');
	            $status_flag = $this->M04ControllerAction->check_permission($post_code, 'Schedule', 'status');
	            $stop_call_flag = $this->M04ControllerAction->check_permission($post_code, 'Schedule', 'stop_call');
	            $call_right_away_flag = $this->M04ControllerAction->check_permission($post_code, 'Schedule', 'call_right_away');

				$str_btn_edit = '<div class="iconFormat"></div>';
				$str_btn_duplicate = '<div class="iconFormat"></div>';
				$str_btn_statistic = '<div class="iconFormat"></div>';
				$str_btn_stop = '<div class="iconFormat btnStopContainer"></div>';
				$str_btn_recall = '<div class="iconFormat btnRestartContainer"></div>';

				$str_btn_edit = '<div class="iconFormat"><a href="javascript:void(0);" class="lnkEdit" schedule_id="'.$arr_schedule['T20OutSchedule']['id'].'"><i title="編集" data-toggle="tooltip" class="glyphicon glyphicon-edit icon-white" ></i></a></div>';
				if ($create_flag) {
					$str_btn_duplicate = '<div class="iconFormat"><a href="javascript:void(0);" class="lnkDuplicate" schedule_id="'.$arr_schedule['T20OutSchedule']['id'].'"><i title="複製" data-toggle="tooltip" class="glyphicon glyphicon-duplicate icon-white" ></i></a></div>';
				}
				if ($status != STATUS_NO_CALL && $status_flag) {
					$str_btn_statistic = '<div class="iconFormat"><a href="javascript:void(0);" class="lnkStatistic" schedule_id="'.$arr_schedule['T20OutSchedule']['id'].'"><i title="状況をみる" data-toggle="tooltip" class="glyphicon glyphicon-stats icon-white" ></i></a></div>';
				}
				if ($status == STATUS_CALLING && $stop_call_flag) {
					$str_btn_stop = '<div class="iconFormat btnStopContainer"><a href="javascript:void(0);" class="lnkStop" schedule_id="'.$arr_schedule['T20OutSchedule']['id'].'"><i title="停止" data-toggle="tooltip" class="glyphicon glyphicon-pause icon-white" ></i></a></div>';
				}
				if ($status == STATUS_STOP_CALL && $call_right_away_flag) {//20160322 - Edit by Canh
					$str_btn_recall = '<div class="iconFormat btnRestartContainer"><a href="javascript:void(0);" screen="index" action="recall" title_btn="再開" class="lnkRestart" schedule_id="'.$arr_schedule['T20OutSchedule']['id'].'"><i title="再開" data-toggle="tooltip" class="glyphicon glyphicon-repeat icon-white" ></i></a></div>';
				}
				//20160323 - Add by Canh - begin
				if (($status == STATUS_TEMP_FINISH || $status == STATUS_REDIAL_WAIT) && $call_right_away_flag) {
					$str_btn_recall = '<div class="iconFormat btnRestartContainer"><a href="javascript:void(0);" screen="index" action="call" title_btn="即時発信" class="lnkRestart" schedule_id="'.$arr_schedule['T20OutSchedule']['id'].'"><i title="再開" data-toggle="tooltip" class="glyphicon glyphicon-repeat icon-white" ></i></a></div>';
				}
				//20160323 - Add by Canh - end

				$str_btn_func = $str_btn_edit . $str_btn_duplicate . $str_btn_statistic . $str_btn_stop . $str_btn_recall;

				$json_row[$json_data["headers"][$i++]] = '<td style="background-color: '.$color.'">'.$str_btn_func.'</td>';
				$json_data["rows"][] = (object) $json_row;
			//}
		}
		$json_data['sortColumn'] = $sort_order[1];
		$json_data['sortType'] = $sort_order[2];
		$json_data['page'] = $js_page;

		$json_string = json_encode($json_data);
		echo $json_string;
		$this->ESession->setSortColumn($sort_order[1], $this);
		$this->ESession->setSortType($sort_order[2], $this);
		$this->ESession->setPage($js_page, $this);
		exit;
	}

	// 発信スケジュール詳細画面の詳細ポップアップの表の値を作成するアクション
	// 初回描画はもちろん、ソートやフィルタ、ページング時の取得も本関数で行う。
	// 		$js_page：選択ページ数（初期表示時：0）
	// 		$limit：表に表示する最大件数（常に20固定）
	// 		$schedule_id：表示中の発信スケジュールのスケジュールID（t20.id）
	// 		$column：ソート中のカラム（一番左を0とカウント）と昇順・降順（初期表示時：1）
	//			※カラムの数は、そのテンプレートのセクション数で変わる。
	function arr_schedule_detail($js_page, $limit, $schedule_id, $column) {
		$arr_operator = array('＜', '＝', '＞', '≠');
		$question_types = array(
//			QUESTION_VOICE,
			QUESTION_BASIC,
			QUESTION_AUTH,
			QUESTION_TEL,
			QUESTION_TRANS, //20160329 Update by Thai : update format tran ques
			QUESTION_RECORD,
			QUESTION_COUNT,
			QUESTION_AUTH_CHAR
		);

		if (isset($this->viewVars['error_login']) && $this->viewVars['error_login']) {
			$res = array('status' => 'error_login');
			echo json_encode($res);
			exit;
		}

		$this->layout = 'ajax';
		if (isset($_GET["filter"]) && !empty($_GET["filter"])){
			$filter = $_GET["filter"];
		} else {
			$filter = null;
		}

		$schedule = $this->T20OutSchedule->getHistoryInfoById($schedule_id);
		$list_id = $schedule['T20OutSchedule']['list_id'];

		$arr_answer_pos = $this->get_answer_pos($schedule_id);
		$arr_ques_pos = $this->get_ques_pos_in_header_detail($schedule_id, $question_types);
		//20160329 Delete by Thai : update format tran ques - Begin
		//$have_tran_ques = $this->check_have_tran_ques($schedule_id);
		//20160329 Delete by Thai : update format tran ques - End

		$page = $js_page + 1;
		$json_data = array();
		$json_data['headers'] = Array(
			'発信日時',
			'発信先',
			'接続時間',
			'ステータス'
		);

		//20160324 Add by Thai : #6779 - update format when have tran ques - Begin
		//20160329 Delete by Thai : update format tran ques - Begin
/*		if ($have_tran_ques) {
			$json_data['headers'][] = '転送時間';
		}*/
		//20160329 Delete by Thai : update format tran ques - End
		//20160324 Add by Thai : #6779 - update format when have tran ques - End

		$questions = array();
		$question_temps = $this->T61QuestionHistory->getInfoQuesAnswByScheduleId($schedule_id, $question_types);
		foreach ($question_temps as $ques) {
			$questions[$ques['T61QuestionHistory']['question_no']]['T61QuestionHistory'] = $ques['T61QuestionHistory'];
			$questions[$ques['T61QuestionHistory']['question_no']]['T62ButtonHistory'][$ques['T62ButtonHistory']['answer_no']] = $ques['T62ButtonHistory'];
		}

		$data_headers = $this->get_data_header_schedule($schedule_id, $question_types, true);
		$get_list_tel_flag = $data_headers['get_list_tel_flag'];
		$json_data['headers'] = array_merge($json_data['headers'], $data_headers['headers']);

		//get format csv from t12
		$list_items = $this->T12ListItem->getTitleByListId($list_id);

		//add header for csv file
		$arr_list_items = Array();
		foreach ($list_items as $list_item) {
			if ($list_item['T12ListItem']['item_code'] == 'tel_no') {
				$tel_column = $list_item['T12ListItem']['column'];
			}

			$arr_list_items[$list_item['T12ListItem']['item_name']] = array(
				'item_code' => $list_item['T12ListItem']['item_code'],
				'column' => $list_item['T12ListItem']['column']
			);
		}

		$arr_auth_column = array();
		if ($get_list_tel_flag) {
			foreach ($questions as $question) {
				if ($question['T61QuestionHistory']['question_type'] == QUESTION_AUTH || $question['T61QuestionHistory']['question_type'] == QUESTION_AUTH_CHAR) {
					$arr_auth_column[$question['T61QuestionHistory']['question_no']] = $arr_list_items[$question['T61QuestionHistory']['auth_item']];
				}
			}
		}

		$referents = array();			//position_in_header => answer_position_in_t80
		$arr_pos_ques_basic = array();	//position_in_header => question_no
		$arr_pos_ques_auth = array();	//position_in_header => question_no
		foreach ($arr_ques_pos as $question_no => $ques_pos) {
			$referents[$ques_pos] = $arr_answer_pos[$question_no];
			if ($questions[$question_no]['T61QuestionHistory']['question_type'] == QUESTION_AUTH || $questions[$question_no]['T61QuestionHistory']['question_type'] == QUESTION_AUTH_CHAR) {
				$referents[$ques_pos + 1] = $arr_answer_pos[$question_no];
				if ($questions[$question_no]['T61QuestionHistory']['recheck_flag'] == 1) {
					$referents[$ques_pos + 2] = $arr_answer_pos[$question_no] + 1;
				}
			}

			if ($questions[$question_no]['T61QuestionHistory']['question_type'] == QUESTION_AUTH || $questions[$question_no]['T61QuestionHistory']['question_type'] == QUESTION_AUTH_CHAR) {
				$arr_pos_ques_auth[$ques_pos + 1] = array(
					'question_no' => $question_no,
					'auth_item_code' => $arr_auth_column[$question_no]['item_code'],
					'auth_item_column' => $arr_auth_column[$question_no]['column']
				);

				if ($questions[$question_no]['T61QuestionHistory']['recheck_flag'] == 1) {
					$arr_pos_ques_auth[$ques_pos + 2] = array(
						'question_no' => $question_no,
						'recheck_button_next' => $questions[$question_no]['T61QuestionHistory']['recheck_button_next']
					);
				}
			}

			if ($questions[$question_no]['T61QuestionHistory']['question_type'] == QUESTION_BASIC) {
				$arr_pos_ques_basic[$ques_pos] = $question_no;
			}
		}

		//20160324 Edit by Thai : #6779 - update format when have tran ques - Begin
		if(isset($column) && !empty($column) && $column != "column") {
			$sort_order = $this->Util->getScheduleDetailSortOrder($column, $referents, $arr_pos_ques_basic, $arr_pos_ques_auth);
		}

		//get data to result
		$logs = $this->T80OutgoingResult->getResultByScheduleId($schedule_id, $tel_column, $limit, $page, $sort_order[0], $filter, $referents, $arr_pos_ques_basic, $arr_pos_ques_auth);


		$json_data['total_rows'] = $this->T80OutgoingResult->getCountByScheduleId($schedule_id, $tel_column, $filter, $referents, $arr_pos_ques_basic, $arr_pos_ques_auth);
		//20160324 Edit by Thai : #6779 - update format when have tran ques - End
		$json_data['rows'] = Array();

		foreach ($logs as $log) {
			$i = 0;
			$json_row[$json_data['headers'][$i++]] = '<td>' . $log['T80OutgoingResult']['call_datetime'] . '</td>';
			$json_row[$json_data['headers'][$i++]] = '<td>' . $log['T80OutgoingResult']['tel_no'] . '</td>';

			// t80.statusの値を、画面表示上の値に変換する。
			// また、接続系(発信・着信が成立し、通話時間があるもの)の場合は、接続時間を表示する。
			if (in_array($log['T80OutgoingResult']['status'], $this->Util->getCallResultConnectStatusArray())) {
				$call_time = Date('i:s', strtotime($log['T80OutgoingResult']['cut_datetime']) - strtotime($log['T80OutgoingResult']['connect_datetime']));
				if($log['T80OutgoingResult']['status'] == "transfer"){
					$status = 'TRANSFER';
				}else if($log['T80OutgoingResult']['status'] == "transfertimeout"){
					$status = 'TRANSFERTIMEOUT';
				}else if($log['T80OutgoingResult']['status'] == "transferfull"){
					$status = 'TRANSFERFULL';
				}else if($log['T80OutgoingResult']['status'] == "connect"){
					$status = 'ANSWER';
				}else if($log['T80OutgoingResult']['status'] == "transferreject"
					|| in_array($log['T80OutgoingResult']['status'] , $this->Util->getCallResultConvertTFRejectArray())){
					$status = 'TRANSFERREJECT';
				}
			} else {
				$call_time = '';
				if($log['T80OutgoingResult']['status'] == "reject"){
					$status = 'REJECT';
				}else if($log['T80OutgoingResult']['status'] == "recover"){
					$status = 'SKIP';
				}else{
					$status = 'NOANSWER';
				}
			}
			$json_row[$json_data['headers'][$i++]] = '<td>' . $call_time . '</td>';
			//20160329 Delete by Thai : update format tran ques - Begin
			/*if ($have_tran_ques) {
				$tranfer_time = strtotime($log['T80OutgoingResult']['trans_cut_datetime']) - strtotime($log['T80OutgoingResult']['trans_connect_datetime']);
				if ($tranfer_time > 0) {
					$tranfer_time = Date('i:s', $tranfer_time);
				} else {
					$tranfer_time = '';
				}
				$json_row[$json_data['headers'][$i++]] = $tranfer_time;
			}*/
			//20160329 Delete by Thai : update format tran ques - End
			$json_row[$json_data['headers'][$i++]] = '<td>' . $status . '</td>';

			foreach ($questions as $question) {
				$question_no = $question['T61QuestionHistory']['question_no'];
				$answer_pos = $arr_answer_pos[$question_no];

				$value = isset($answer_pos) && $question['T61QuestionHistory']['question_type'] != QUESTION_TRANS ? $log['T80OutgoingResult']['answer' . $answer_pos] : '';
				$json_row[$json_data['headers'][$i++]] = '<td>' . $value . '</td>';

				if ($question['T61QuestionHistory']['question_type'] == QUESTION_BASIC) {
					//20160407 Add by Thai : #6890 - Fix error statistic answer 51&52 - Begin
					if ($value == '*') {
						$value = 51;
					} else if ($value == '#') {
						$value = 52;
					}
					//20160407 Add by Thai : #6890 - Fix error statistic answer 51&52 - End
					if (isset($question['T62ButtonHistory'][$value]) && !empty($question['T62ButtonHistory'][$value]['answer_content'])) {
						$json_row[$json_data['headers'][$i - 1]] = '<td>' . $question['T62ButtonHistory'][$value]['answer_content'] . '</td>';
					}
				} elseif ($question['T61QuestionHistory']['question_type'] == QUESTION_AUTH) {
					$auth_column = $arr_auth_column[$question_no]['column'];
					$auth_value = $log['T51TelHistory'][$auth_column];
					if (isset($auth_value) && $auth_value !== '' && isset($value) && $value !== '') {
						$auth_item_code = $arr_auth_column[$question_no]['item_code'];
						if ($auth_item_code == 'birthday') {
							$auth_value = DateTime::createFromFormat('Y年m月d日', $auth_value)->format('Ymd');
						} else {
							$auth_value = preg_replace('/[^\d]/', '', $auth_value);
						}

						if ($value < $auth_value) {
							$json_row[$json_data['headers'][$i++]] = '<td>' . $arr_operator[0] . '</td>';
						} elseif ($value == $auth_value) {
							$json_row[$json_data['headers'][$i++]] = '<td>' . $arr_operator[1] . '</td>';
						} else {
							$json_row[$json_data['headers'][$i++]] = '<td>' . $arr_operator[2] . '</td>';
						}
					} else {
						$json_row[$json_data['headers'][$i++]] = '<td></td>';
					}

					if ($question['T61QuestionHistory']['recheck_flag'] == 1) {
						$pos_input = -1;
						for ($k=0; $k<3; $k++) {
							if ($log['T80OutgoingResult']['answer' . ($answer_pos + $k + 1)] != '' && $pos_input < 0) {
								$pos_input = $k;
							}
							if ($log['T80OutgoingResult']['answer' . ($answer_pos + $k + 1)] == $question['T61QuestionHistory']['recheck_button_next']) {
								$pos_input = $k;
								break;
							}
						}
						if ($pos_input >= 0) {
							$json_row[$json_data['headers'][$i++]] = '<td>' . $log['T80OutgoingResult']['answer' . ($answer_pos + $pos_input + 1)] . '</td>';
						} else {
							$json_row[$json_data['headers'][$i++]] = '<td></td>';
						}
					}
				} elseif ($question['T61QuestionHistory']['question_type'] == QUESTION_AUTH_CHAR) {
					$auth_column = $arr_auth_column[$question_no]['column'];
					$auth_value = $log['T51TelHistory'][$auth_column];
					if (isset($auth_value) && $auth_value !== '' && isset($value) && $value !== '') {
						$auth_item_code = $arr_auth_column[$question_no]['item_code'];
						if ($auth_item_code == 'birthday') {
							$auth_value = DateTime::createFromFormat('Y年m月d日', $auth_value)->format('Ymd');
						} else {
							$auth_value = preg_replace('/[^\d]/', '', $auth_value);
						}

						if ($value === $auth_value) {
							$json_row[$json_data['headers'][$i++]] = '<td>' . $arr_operator[1] . '</td>';
						} else {
							$json_row[$json_data['headers'][$i++]] = '<td>' . $arr_operator[3] . '</td>';
						}
					} else {
						$json_row[$json_data['headers'][$i++]] = '<td></td>';
					}

					if ($question['T61QuestionHistory']['recheck_flag'] == 1) {
						if (($log['T80OutgoingResult']['answer' . ($answer_pos + 1)] == $question['T61QuestionHistory']['recheck_button_next'])
							|| ($log['T80OutgoingResult']['answer' . ($answer_pos + 2)] == $question['T61QuestionHistory']['recheck_button_next'])) {
							// 正番号が入力された場合
								$auth_input = $question['T61QuestionHistory']['recheck_button_next'];
						} elseif (!empty($log['T80OutgoingResult']['answer' . ($answer_pos + 1)])) {
							$auth_input = $log['T80OutgoingResult']['answer' . ($answer_pos + 1)];
						} elseif (!empty($log['T80OutgoingResult']['answer' . ($answer_pos + 2)])) {
							$auth_input = $log['T80OutgoingResult']['answer' . ($answer_pos + 2)];
						} else {
							$auth_input = '';
						}
						$json_row[$json_data['headers'][$i++]] = '<td>' . $auth_input . '</td>';
					}
				} elseif ($question['T61QuestionHistory']['question_type'] == QUESTION_RECORD) {
					if (!empty($log['T80OutgoingResult']['valid_count'])) {
						if ($schedule['T20OutSchedule']['cron_record_flag'] == 'N') {
							$str_btn_wav = '<p>'
// 							. '<a class="btn btn_wav btnPlay btn-default" schedule_id = "'.$schedule_id.'" tel_no="' . $log['T80OutgoingResult']['tel_no'] . '">'
// 							. '<i class="glyphicon glyphicon-play" ></i>'
// 							. '</a>'
// 							. '<a class="btn btn_wav btnStop btn-default">'
// 							. '<i class="glyphicon glyphicon-stop" ></i>'
// 							. '</a>'
								. '<a class="btn btn_wav btnDownloadRecord btn-default" schedule_id = "'.$schedule_id.'" tel_no="' . $log['T80OutgoingResult']['tel_no'] . '">'
								. '<i class="glyphicon glyphicon-download-alt" ></i>'
								. '</a>'
								. '</p>';
							$json_row[$json_data['headers'][$i - 1]] = '<td>' . $str_btn_wav . '</td>';
						} else {
							$json_row[$json_data['headers'][$i - 1]] = '<td></td>';
						}
						$json_row[$json_data['headers'][$i++]] = '<td>' . $log['T80OutgoingResult']['valid_count'] . '</td>';
					} else {
						$json_row[$json_data['headers'][$i - 1]] = '<td></td>';
						$json_row[$json_data['headers'][$i++]] = '<td></td>';
					}
					//20160329 Add by Thai : update format tran ques - Begin
				} elseif ($question['T61QuestionHistory']['question_type'] == QUESTION_TRANS) {
					$tranfer_time = strtotime($log['T80OutgoingResult']['trans_cut_datetime']) - strtotime($log['T80OutgoingResult']['trans_connect_datetime']);
					$json_row[$json_data['headers'][$i-1]] = $tranfer_time > 0 ? Date('i:s', $tranfer_time) : '';
					//20160329 Add by Thai : update format tran ques - End
				} elseif ($question['T61QuestionHistory']['question_type'] == QUESTION_TEL && $question['T61QuestionHistory']['recheck_flag'] == 1) {
					$json_row[$json_data['headers'][$i++]] = '<td>' . $log['T80OutgoingResult']['answer' . ($answer_pos + 1)] . '</td>';
				}
			}

			$json_data['rows'][] = (object) $json_row;
		}

		$json_data['sortColumn'] = $sort_order[1];
		$json_data['sortType'] = $sort_order[2];
		$json_data['page'] = $js_page;

		$this->ESession->setSortColumn($sort_order[1], $this);
		$this->ESession->setSortType($sort_order[2], $this);
		$this->ESession->setPage($js_page, $this);
		echo json_encode($json_data);
		exit;
	}

	function delete() {
		$data = $this->data;
		if (empty($data)) {
			$this->redirect(array('controller' => 'OutSchedule', 'action' => 'index'));
		}

		$dsT20OutSchedule = $this->T20OutSchedule->getDataSource();
		$dsT21OutTime = $this->T21OutTime->getDataSource();
		$dsT20OutSchedule->begin($this);
		$dsT21OutTime->begin($this);

		$schedule_ids = $data['schedule_ids'];
		$update_user = $this->ESession->getUserId($this);
		$update_program = $this->name.'_'.__FUNCTION__;
		$time = date('Y-m-d H:i:s a', time());

		foreach ($schedule_ids as $id) {
			$arr_schedule_info = $this->T20OutSchedule->getScheduleById($id);

			$arr_schedule_info['T20OutSchedule']['del_flag'] = "Y";
			$arr_schedule_info["T20OutSchedule"]["update_user"] = $update_user;
			$arr_schedule_info["T20OutSchedule"]["update_program"] = $update_program;
			$arr_schedule_info["T20OutSchedule"]["modified"] = $time;

			if (!$this->T20OutSchedule->save($arr_schedule_info)) {
				$dsT20OutSchedule->rollback($this);
				$dsT21OutTime->rollback($this);
				$this->log("スケジュール削除：失敗");
				$this->redirect(array('controller' => 'Login', 'action' => 'index/systemerror'));
			}

			$schedule_id = $arr_schedule_info["T20OutSchedule"]["id"];
			$query = "UPDATE t21_out_times SET del_flag='Y', update_user='"
				. $update_user . "',update_program='" . $update_program
				. "', modified='" . $time . "' WHERE del_flag = 'N' AND schedule_id='" . $schedule_id . "';";

			if ($this->T21OutTime->query($query)) {
				$dsT20OutSchedule->rollback($this);
				$dsT21OutTime->rollback($this);
				$this->log("スケジュール削除：失敗");
				$this->redirect(array('controller' => 'Login', 'action' => 'index/systemerror'));
			}
		}

		$dsT20OutSchedule->commit($this);
		$dsT21OutTime->commit($this);
		$this->redirect(array('controller' => 'OutSchedule', 'action' => 'index/delete/' . count($schedule_ids))); /*20160311 Edit by Giang : #6695 - display the record quantity has been deleted*/
	}

	function check_delete_schedule() {
		$data = $this->data;
		if (empty($data)) {
			$this->redirect(array('controller' => 'OutSchedule', 'action' => 'index'));
		}

		$schedule_ids = $data['schedule_ids'];
		foreach ($schedule_ids as $id) {
			$arr_schedule_info = $this->T20OutSchedule->getScheduleById($id);
			if (count($arr_schedule_info) < 1) {
				$result = array(
					'status' => 'err_not_exist',
					'schedule_id' => $id
				);
				echo json_encode($result);
				exit;
			}

			if (!in_array($arr_schedule_info['T20OutSchedule']['status'], array(STATUS_NO_CALL, STATUS_FINISH))) {
				$result = array(
					'status' => 'err_status_can_not_delete',
					'schedule_id' => $id
				);
				echo json_encode($result);
				exit;
			} else if (!$this->check_unlock_schedule($arr_schedule_info['T20OutSchedule']['id'])) {
				$result = array(
					'status' => 'error_locking',
					'schedule_id' => $id
				);
				echo json_encode($result);
				exit;
			} else if ($arr_schedule_info['T20OutSchedule']['status'] == STATUS_NO_CALL && !$this->call_check_start_time($id, 'delete')) {
				$result = array(
					'status' => 'error_start_time'
				);
				echo json_encode($result);
				exit;
			}
		}
		$result = array(
			'status' => 'can_delete',
		);
		echo json_encode($result);
		exit;
	}

	function check_exist_schedule_name() {
		$data = $this->data;
		$schedule_name = $data['schedule_name'];
		$company_id = $this->ESession->getUserCompanyId($this);

		$info_schedule = $this->T20OutSchedule->getByScheduleName($company_id, $schedule_name);
		if (isset($info_schedule["T20OutSchedule"]["id"]) && !empty($info_schedule["T20OutSchedule"]["id"])) {
			if (!isset($data['schedule_id']) || empty($data['schedule_id']) || (!empty($data['schedule_id']) && $data['schedule_id'] != $info_schedule["T20OutSchedule"]["id"])) {
				echo "false";
				exit;
			}
		}
		echo "true";
		exit;
	}

	function check_info_schedule(){
		$data = $this->data;
		if(isset($data['schedule_id']) && !empty($data['schedule_id'])){
			$arr_schedule_info = $this->T20OutSchedule->getScheduleById($data['schedule_id']);
			if (count($arr_schedule_info) < 1) {
				$result = array(
					"result" => "err_exist_schedule",
				);
				echo json_encode($result);
				exit;
			}
		}

		if(isset($data['list_ng_id']) && !empty($data['list_ng_id']) && !$this->check_exist_list_ng($data)){
			$result = array(
				"result" => "err_exist_list_ng",
			);
			echo json_encode($result);
			exit;
		}
		if(!$this->check_exist_template($data)){
			$result = array(
				"result" => "err_exist_template",
			);
			echo json_encode($result);
			exit;
		}
		if(!$this->check_exist_list($data)){
			$result = array(
				"result" => "err_exist_list",
			);
			echo json_encode($result);
			exit;
		}
		if(!$this->check_unlock_call_list($data)){
			$result = array(
				"result" => "err_lock_call_list",
			);
			echo json_encode($result);
			exit;
		}
		if(!$this->check_unlock_template($data)){
			$result = array(
				"result" => "err_lock_template",
			);
			echo json_encode($result);
			exit;
		}

		if ($data['action'] == 'update' && !$this->call_check_start_time($data['schedule_id'], $data['action'])) {
			$result = array(
				'result' => 'error_start_time'
			);
			echo json_encode($result);
			exit;
		}

		if (!$this->check_exist_item($data)) {
			$result = array(
				"result" => "err_exist_item",
			);
			echo json_encode($result);
			exit;
		}

		if (!$this->check_exist_yuko($data)) {
			$result = array(
				"result" => "err_exist_yuko",
			);
			echo json_encode($result);
			exit;
		}

		//SMS本文をチェックする
		$check_message = $this->check_sms_content($data);
		if ($check_message) {
			$result = array(
				"result" => $check_message,
			);
			echo json_encode($result);
			exit;
		}

		$max_list_item = $this->M99SystemParameter->getByFunctionIdAndParameterId('LIST', 'MAX_LIST_ITEM');
		$max_list_item = $max_list_item['M99SystemParameter']['parameter_value'];
		if (!$this->check_list_over_item($data, $max_list_item)) {
			$result = array(
				"result" => "err_max_list_item",
				"max_list_item" => $max_list_item
			);
			echo json_encode($result);
			exit;
		}

		//check proc_num
		$trans_ques = $this->T31TemplateQuestion->getTransQuesByTemplateId($data['template_id']);
		if (sizeof($trans_ques) > 0 && isset($trans_ques['T31TemplateQuestion']['trans_seat_num'])) {
			$trans_seat_num = $trans_ques['T31TemplateQuestion']['trans_seat_num'];
		} else {
			$trans_seat_num = 0;
		}

		$info_company = $this->M02Company->getByCompanyId($this->ESession->getUserCompanyId($this));
		$max_yuko_procnum = $info_company['M02Company']['ch_num'];

		$time_prepare_procnum = $this->M99SystemParameter->getByFunctionIdAndParameterId('SCHEDULE', 'TIME_PREPARE_PROCNUM');
		$time_prepare_procnum = $time_prepare_procnum['M99SystemParameter']['parameter_value'];

		foreach ($data['list_call_times'] as $key => $list_call_time) {
			if ($data['action'] != 'call') {
				$data_call_time = array(
					'schedule_id' => $data['schedule_id'],
					'start_time' => date('Y-m-d H:i:s', strtotime($data['create_date'] . ' ' . $list_call_time['start_date']) - $time_prepare_procnum),
					'end_time' => date('Y-m-d H:i:s', strtotime($data['create_date'] . ' ' . $list_call_time['end_date']) + $time_prepare_procnum),
					'action' => $data['action']
				);
			} else {
				$data_call_time = array(
					'schedule_id' => $data['schedule_id'],
					'start_time' => date('Y-m-d H:i:s', strtotime($list_call_time['start_date']) - $time_prepare_procnum),
					'end_time' => date('Y-m-d H:i:s', strtotime($list_call_time['end_date']) + $time_prepare_procnum),
					'action' => $data['action']
				);
			}

			$yuko_procnum = $this->check_over_ch($data_call_time);
			if ($yuko_procnum < $max_yuko_procnum) {
				$max_yuko_procnum = $yuko_procnum;
			}
		};

		if (($data["proc_num"] + $trans_seat_num) > $max_yuko_procnum){
			$result = array(
				"result" => "err_over_ch",
				"yuko_procnum" => ($max_yuko_procnum - $trans_seat_num) > 0 ? ($max_yuko_procnum - $trans_seat_num) : 0,
				"limit_proc_num" => $info_company['M02Company']['ch_num']
			);
			echo json_encode($result);
			exit;
		}

		//check over_schedule
		$kaisenInfo = $this->M07ServerExternal->getInfoByExternalNumber($data['external_number']);
		if(!isset($kaisenInfo["M07ServerExternal"]["kaisen_code"])){
			$result = array(
				"result" => "err_over_schedule",
				"limit_schedule" => null
			);
			echo json_encode($result);
			exit;
		}
		foreach ($data['list_call_times'] as $key => $list_call_time) {
			if ($data['action'] != 'call') {
				$data_call_time = array(
					'schedule_id' => $data['schedule_id'],
					'kaisen_code' => $kaisenInfo["M07ServerExternal"]["kaisen_code"],
					'start_time' => $data['create_date'] . ' ' . $list_call_time['start_date'] . ':00',
					'end_time' => $data['create_date'] . ' ' . $list_call_time['end_date'] . ':00',
					'action' => $data['action']
				);
			} else {
				$data_call_time = array(
					'schedule_id' => $data['schedule_id'],
					'kaisen_code' => $kaisenInfo["M07ServerExternal"]["kaisen_code"],
					'start_time' => $list_call_time['start_date'],
					'end_time' => $list_call_time['end_date'],
					'action' => $data['action']
				);
			}
			if (!$this->check_over_schedule($data_call_time)){
				$arr_limit_schedule = $this->M09KaisenInfo->getKaisenInfoByCode($kaisenInfo["M07ServerExternal"]["kaisen_code"]);
				$limit_schedule = $arr_limit_schedule['M09KaisenInfo']['max_schedule'];
				$result = array(
					"result" => "err_over_schedule",
					"limit_schedule" => $limit_schedule
				);
				echo json_encode($result);
				exit;
			}
		};


		if (isset($data['schedule_id']) && !empty($data['schedule_id'])){
			if ($data['action'] == "update") {
				if (!$this->check_run_schedule($data)) {
					$result = array(
						"result" => "err_update_run",
					);
					echo json_encode($result);
					exit;
				}
			}

			if ($data['action'] == 'call') {
				$arr_schedule_info = $this->T20OutSchedule->getScheduleById($data['schedule_id']);
				$status = $arr_schedule_info['T20OutSchedule']['status'];

				if ($status != STATUS_NO_CALL && $status != STATUS_TEMP_FINISH) {
					$result = array(
						'result' => 'error_status',
						'msg' => SCHEDULE_ERROR_CALL_RIGHT_AWAY1 . $this->get_status_name($status) . SCHEDULE_ERROR_CALL_RIGHT_AWAY2
					);
					echo json_encode($result);
					exit;
				}
			}

			if ($data['action'] == "call" || $data['action'] == "update") {
				if(!$this->check_unlock_schedule($data['schedule_id'])){
					$result = array(
						"result" => "err_editing",
					);
					echo json_encode($result);
					exit;
				}
			}
		}

		if(isset($data['list_ng_id']) && !empty($data['list_ng_id']) && !$this->check_expired_list_ng($data['list_ng_id'], $data['create_date'])){
			$result = array(
					"result" => "err_expired",
			);
			echo json_encode($result);
			exit;
		}

		if(!$this->check_same_schedule($data)){
			$result = array(
					"result" => "err_same",
			);
			echo json_encode($result);
			exit;
		}
		echo "true";
		exit;
	}

	/**
	 * 「即時発信」ボタン押下時チェック処理
	 * チェック実行後、呼び出し元へ結果を返却する。
	 */
	function check_popup()
	{
		$data = $this->data;
		if ($data['edit_mode'] == "update" && !$this->call_check_start_time($data['schedule_id'], $data['action'])) {
			$result = array(
				'result' => 'error_start_time'
			);
			echo json_encode($result);
			exit;
		}

		echo "true";
		exit;
	}

	/*
	* SMS内容は70文字をチェックする
	*/
	function check_sms_content($data){
		$arr_ques = $this->T31TemplateQuestion->getQuesByTemplateId($data['template_id']);
		$list_id = $data['list_id'];
		$ng_list_id = $data['list_ng_id'];
		$list_items = array();
		$existed_list_items = false;
		$ngTelList = array();
		$existed_ngTelList = false;
		$telList = array();
		$existed_telList = false;

		// $arr_ques＝その添付レーオ上の全てのセクション
		foreach ($arr_ques as $question) {
			if ($question['T31TemplateQuestion']['question_type'] == QUESTION_SMS || $question['T31TemplateQuestion']['question_type'] == QUESTION_SMS_INPUT) {
				$sms_content = $question['T31TemplateQuestion']['sms_content'];
				$sms_use_short_url = $question['T31TemplateQuestion']['yuko_button_record'];
				$M08SmsApiInfo = $this->M08SmsApiInfo->getApiInfoByDisplayNumber($question['T31TemplateQuestion']['sms_display_number']);
				$api_id = $M08SmsApiInfo['M08SmsApiInfo']['api_id'];

				$had_item = false;
				//sms本文が空白の場合、文字数オーバーとみなす（セクション編集で本文空欄はNGとしているが、念のために。）
				if(empty($sms_content))
					return "err_sms_over_length";

				////挿入項目の洗い出し。
				$arr_items = array();
				preg_match_all($this::ITEM_REGEX, $sms_content, $items);
				foreach ($items[0] as $item) {
					$item_name = preg_replace($this::LEFT_BRACE_REGEX, "",preg_replace($this::RIGHT_BRACE_REGEX, "", $item,1),1);
					if (!empty($item_name)) {
						$had_item = true;
						//SMS本文の中に挿入項目を洗い出してarrayに入れる
						if(!in_array($item_name, $arr_items))
							array_push($arr_items, $item_name);
					}
				}
				////挿入項目の洗い出し_ここまで


				//挿入項目あり　または　APIV2を使うなら文字数の再確認が必要
				// 短縮URL有効・無効は$api_id == SMS_API_V2_VALUEの時にOnになる。（画面で制御）
				if($had_item || $api_id == SMS_API_V2_VALUE){ //挿入項目があった場合、挿入項目値を含めて本文の長さをチェックする
					$tel_column = "";
					if(!$existed_list_items){
						$list_items = $this->T12ListItem->getTitleByListId($list_id);
						$existed_list_items = true;
					}
					$list_columns = array();
					//リストの付加項目を取得する
					foreach ($list_items as $list_item) {
						$list_columns[$list_item['T12ListItem']['item_name']] = $list_item['T12ListItem']['column'];
						if($list_item['T12ListItem']["item_code"] == 'tel_no')
							$tel_column = $list_item['T12ListItem']['column'];
					}

					//リストの項目の中に挿入項目が存在しない場合、FALSEを返す(別の箇所でエラーとするため。)
					foreach ($arr_items as $item_name) {
						if (!isset($list_columns[$item_name])){
							return "err_sms_over_length";
						}
					}

					$arrNgTelList = array();
					//NGリストが存在する場合、電話番号を取得してその一覧を発信リストに除外する
					if(isset($ng_list_id) && !empty($ng_list_id)){
						if(!$existed_ngTelList){
							$ngTelList = $this->T15OutgoingNgTel->getTelListByCallListNgId($ng_list_id);
							$existed_ngTelList = true;
						}
						foreach ($ngTelList as $ngTel) {
							$arrNgTelList[] = $ngTel["T15OutgoingNgTel"]["tel_no"];
						}
					}
					if(!$existed_telList){
						$telList = $this->T11TelList->getAllByListId($list_id, $tel_column, $arrNgTelList);
						$existed_telList = true;
					}

					//// 発信リスト毎に、SMS本文の長さをチェックする。
					// 挿入項目を置き換える。
					foreach ($telList as $tel) {
						$tmp_sms_content = $sms_content;
						foreach ($arr_items as $item_name) {
							$tmp_item = "{".$item_name."}";
							//挿入項目を実際値を入れ替えて長さをチェックする
							$tmp_sms_content = str_replace($tmp_item, $tel["T11TelList"][$list_columns[$item_name]], $tmp_sms_content);
						}

						// API_v2の場合は、改行を2文字とカウントする
						if($api_id == SMS_API_V2_VALUE){
							$error_message = "";
							list($error_message, $tmp_sms_content) = $this->Util->checkSmsBodyValueForApiV2($sms_use_short_url, $tmp_sms_content);
							if($error_message){
								return $error_message;
							}
						}


						if(mb_strlen($tmp_sms_content) > MAX_LEN_SMS_CONTENT){
							return "err_sms_over_length";
						}
					}
					//// 発信リスト毎に、SMS本文の長さをチェックする。_ここまで
				}
			}
		}
		return "";
	}
	function check_exist_list_ng($data){
		$arr_list_ng_info = $this->T14OutgoingNgList->getNgListInfoByListNgId($data['list_ng_id']);
		if (count($arr_list_ng_info) < 1) {
			return false;
		}
		return true;
	}
	function check_exist_template($data){
		$arr_template_info = $this->T30Template->getInfoTemplateById($data['template_id']);
		if (count($arr_template_info) < 1) {
			return false;
		}
		return true;
	}
	function check_exist_list($data){
		$arr_list_info = $this->T10CallList->getListInfoById($data['list_id']);
		if (count($arr_list_info) < 1) {
			return false;
		}
		return true;
	}

	function check_exist_item($data) {
		$arr_ques = $this->T31TemplateQuestion->getQuesByTemplateId($data['template_id']);
		$list_id = $data['list_id'];

		$list_items = $this->T12ListItem->getTitleByListId($list_id);
		$list_columns = array();
		foreach ($list_items as $list_item) {
			$list_columns[$list_item['T12ListItem']['item_name']] = $list_item['T12ListItem']['column'];
		}

		$tel_lists = $this->T11TelList->getAllByListId($list_id);

		foreach ($arr_ques as $question) {
			//音声内容チェック
			if ($question['T31TemplateQuestion']['audio_type'] == 1 || $question['T31TemplateQuestion']['audio_type'] == 2) {
				$str_content = $question['T31TemplateQuestion']['audio_content'];
				preg_match_all($this::ITEM_REGEX, $str_content, $items);
				foreach ($items[0] as $item) {
					$item_name = preg_replace($this::LEFT_BRACE_REGEX, "",preg_replace($this::RIGHT_BRACE_REGEX, "", $item,1),1);
					if (!isset($list_columns[$item_name])){
						return false;
					}
				}
			}

			if ($question['T31TemplateQuestion']['question_type'] == QUESTION_TRANS && ($question['T31TemplateQuestion']['trans_timeout_audio_type'] == 1 || $question['T31TemplateQuestion']['trans_timeout_audio_type'] == 2)) {
				$str_content = $question['T31TemplateQuestion']['trans_timeout_audio_content'];
				preg_match_all($this::ITEM_REGEX, $str_content, $items);
				foreach ($items[0] as $item) {
					$item_name = preg_replace($this::LEFT_BRACE_REGEX, "",preg_replace($this::RIGHT_BRACE_REGEX, "", $item,1),1);
					if (!isset($list_columns[$item_name])){
						return false;
					}
				}
			}

			if ($question['T31TemplateQuestion']['recheck_flag'] == 1 && ($question['T31TemplateQuestion']['recheck_audio_type'] == 1 || $question['T31TemplateQuestion']['recheck_audio_type'] == 2)) {
				$str_content = $question['T31TemplateQuestion']['recheck_audio_content'];
				preg_match_all($this::ITEM_REGEX, $str_content, $items);
				foreach ($items[0] as $item) {
					$item_name = preg_replace($this::LEFT_BRACE_REGEX, "",preg_replace($this::RIGHT_BRACE_REGEX, "", $item,1),1);
					if (!isset($list_columns[$item_name])){
						return false;
					}
				}
			}
			if ($question['T31TemplateQuestion']['question_type'] == QUESTION_SMS || $question['T31TemplateQuestion']['question_type'] == QUESTION_SMS_INPUT) {
				$str_content = $question['T31TemplateQuestion']['sms_content'];
				preg_match_all($this::ITEM_REGEX, $str_content, $items);
				foreach ($items[0] as $item) {
					$item_name = preg_replace($this::LEFT_BRACE_REGEX, "",preg_replace($this::RIGHT_BRACE_REGEX, "", $item,1),1);
					if (!isset($list_columns[$item_name])){
						return false;
					}
				}
			}
			//認証項目チェック
			if ($question['T31TemplateQuestion']['question_type'] == QUESTION_AUTH || $question['T31TemplateQuestion']['question_type'] == QUESTION_AUTH_CHAR) {
				$auth_item = $question['T31TemplateQuestion']['auth_item'];
				if (!isset($list_columns[$auth_item])){
					return false;
				}

				foreach ($tel_lists as $tel_list) {
					if ($this->Util->isNullOrWhitespace($tel_list['T11TelList'][$list_columns[$auth_item]])) {
						return false;
					}
				}
			}
		}
		return true;
	}

	function check_exist_yuko($data) {
		if($data['term_valid_count'] > 0){
			$template_id = $data['template_id'];
			$arr_yuko = $this->T31TemplateQuestion->getQuestionYukoByTemplateId($template_id);
			if(count($arr_yuko) > 0){
				return true;
			}else{
				return false;
			}
		}
		return true;
	}

	function check_list_over_item($data, $max_list_item) {
		$had_item = false;
		$arr_ques = $this->T31TemplateQuestion->getQuesByTemplateId($data['template_id']);

		foreach ($arr_ques as $question) {
			if ($had_item) {
				break;
			}

			if ($question['T31TemplateQuestion']['audio_type'] == 1 || $question['T31TemplateQuestion']['audio_type'] == 2) {
				$str_content = $question['T31TemplateQuestion']['audio_content'];
				preg_match_all($this::ITEM_REGEX, $str_content, $items);
				foreach ($items[0] as $item) {
					$item_name = preg_replace($this::BRACE_REGEX, "", $item);
					if (!empty($item_name)) {
						$had_item = true;
						break;
					}
				}
			}

			if (!$had_item && $question['T31TemplateQuestion']['question_type'] == QUESTION_TRANS && ($question['T31TemplateQuestion']['trans_timeout_audio_type'] == 1 || $question['T31TemplateQuestion']['trans_timeout_audio_type'] == 2)) {
				$str_content = $question['T31TemplateQuestion']['trans_timeout_audio_content'];
				preg_match_all($this::ITEM_REGEX, $str_content, $items);
				foreach ($items[0] as $item) {
					$item_name = preg_replace($this::BRACE_REGEX, "", $item);
					if (!empty($item_name)) {
						$had_item = true;
						break;
					}
				}
			}

			if (!$had_item && $question['T31TemplateQuestion']['recheck_flag'] == 1 && ($question['T31TemplateQuestion']['recheck_audio_type'] == 1 || $question['T31TemplateQuestion']['recheck_audio_type'] == 2)) {
				$str_content = $question['T31TemplateQuestion']['recheck_audio_content'];
				preg_match_all($this::ITEM_REGEX, $str_content, $items);
				foreach ($items[0] as $item) {
					$item_name = preg_replace($this::BRACE_REGEX, "", $item);
					if (!empty($item_name)) {
						$had_item = true;
						break;
					}
				}
			}
		}

		if ($had_item) {
			$list_info = $this->T10CallList->getListInfoById($data['list_id']);
			$count_item = $list_info['T10CallList']['tel_total'];
			if ($count_item > $max_list_item) {
				return false;
			}
		}

		return true;
	}

	function check_unlock_call_list($data) {
		$user_id = $this->ESession->getUserId($this);
		$session_id = $this->Session->id();

		$info_lock = $this->T92Lock->getInfoLock('call_list', $data['list_id']);
		if (count($info_lock) > 0 && ($info_lock['T92Lock']['use_user_id'] != $user_id || $info_lock['T92Lock']['session_id'] != $session_id)){
			return false;
		} else {
			return true;
		}
	}
	function check_unlock_template($data) {
		$user_id = $this->ESession->getUserId($this);
		$session_id = $this->Session->id();

		$info_lock = $this->T92Lock->getInfoLock('template', $data['template_id']);
		if (count($info_lock) > 0 && ($info_lock['T92Lock']['use_user_id'] != $user_id || $info_lock['T92Lock']['session_id'] != $session_id)){
			return false;
		} else {
			return true;
		}
	}
	function check_unlock_schedule($schedule_id) {
		$user_id = $this->ESession->getUserId($this);
		$session_id = $this->Session->id();
		$info_lock = $this->T92Lock->getInfoLock('schedule', $schedule_id);
		if (count($info_lock) > 0 && ($info_lock['T92Lock']['use_user_id'] != $user_id || $info_lock['T92Lock']['session_id'] != $session_id)){
			return false;
		} else {
			return true;
		}
	}
	function check_same_schedule($data){
		$count_schedule_exist = $this->T20OutSchedule->checkSameSchedule(
			$data['schedule_id'],
			$data['create_date'],
			$data['list_ng_id'],
			$data['template_id'],
			$data['list_id'],
			$data['action']);
		if ($count_schedule_exist >= 1) {
			return false;
		}
		return true;
	}
	function check_over_ch($data){
		$company_id = $this->ESession->getUserCompanyId($this);
		$schedule_id = $data['schedule_id'];
		$time_start = $data['start_time'];
		$time_end = $data['end_time'];
		$action = $data['action'];

		$info_company = $this->M02Company->getByCompanyId($this->ESession->getUserCompanyId($this));
		$max_procnum = $info_company['M02Company']['ch_num'];

		$arr_infos = $this->T20OutSchedule->getSumProcNumByOperationTime($company_id, $schedule_id, $time_start, $time_end, $action);
		$sum_proc_num = 0;
		$sum_trans_seat_num = 0;
		foreach ($arr_infos as $arr_info) {
			$sum_proc_num += $arr_info["0"]["sum_proc_num"];
			$sum_trans_seat_num += $arr_info["0"]["sum_trans_seat_num"];
		}

		$yuko_procnum = $max_procnum - $sum_proc_num - $sum_trans_seat_num;
		return $yuko_procnum;
	}
	function check_over_schedule($data){
		$company_id = $this->ESession->getUserCompanyId($this);
		$schedule_id = $data['schedule_id'];
		$time_start = $data['start_time'];
		$time_end = $data['end_time'];
		$action = $data['action'];
		$kaisen_code = $data['kaisen_code'];

		$arr_limit_schedule = $this->M09KaisenInfo->getKaisenInfoByCode($kaisen_code);
		$limit_schedule = $arr_limit_schedule['M09KaisenInfo']['max_schedule'];
		$min_time_call = $this->M99SystemParameter->getByFunctionIdAndParameterId('SCHEDULE', 'TIME_PREPARE_PROCNUM');
		$min_time_call = $min_time_call['M99SystemParameter']['parameter_value'];
		if(empty($min_time_call))
			$min_time_call = "900";
		$arr_infos = $this->T20OutSchedule->getScheduleByOperationTime($kaisen_code, $schedule_id, $time_start, $time_end, $action, $min_time_call);

		if (sizeof($arr_infos) >= $limit_schedule) {
			foreach ($arr_infos as $info) {
				$count_nested_time = 0;
				//1つ時間帯に重なっているスケジュール数をカウントしてチェックする
				foreach ($arr_infos as $tmpInfo) {
					if((strtotime($info["T21OutTime"]["time_start"]) <= strtotime($tmpInfo["T21OutTime"]["time_start"]) &&
						strtotime($info["T21OutTime"]["time_end"]) >= strtotime($tmpInfo["T21OutTime"]["time_start"]) - $min_time_call)){
						$count_nested_time ++;
					}else if((strtotime($info["T21OutTime"]["time_start"]) >= strtotime($tmpInfo["T21OutTime"]["time_start"]) &&
						strtotime($info["T21OutTime"]["time_start"]) <= strtotime($tmpInfo["T21OutTime"]["time_end"]) + $min_time_call)){
						$count_nested_time ++;
					}
				}
				if($count_nested_time >= $limit_schedule)
					return false;
			}
			return true;
		}
		return true;
	}
	function check_run_schedule($data){
		$arr_schedule_info = $this->T20OutSchedule->getScheduleById($data['schedule_id']);
		$status = $arr_schedule_info["T20OutSchedule"]["status"];
		if (($status == STATUS_CALLING || $status == STATUS_STOPING) && $data["action"] == "update") {//実行中
			return false;
		}
		return true;
	}

	function check_exist_schedule(){
		$data = $this->data;
		$arr_schedule_info = $this->T20OutSchedule->getScheduleById($data['id']);
		if (count($arr_schedule_info) < 1) {
			echo "false";
			exit;
		}
		echo "true";
		exit;
	}

	function check_status_can_recall($status){
		$status_recall = Array(STATUS_STOP_CALL);//20160323 - Edit by Canh : Delete STATUS_REDIAL_WAIT
		if (in_array($status, $status_recall)) {
			return true;
		} else {
			return false;
		}
	}

	function check_status_can_callnow($status){
		$status_recall = Array(STATUS_TEMP_FINISH, STATUS_REDIAL_WAIT);
		if (in_array($status, $status_recall)) {
			return true;
		} else {
			return false;
		}
	}

	/**
	 * 開始時間チェック処理の呼び出し
	 * @param string $schedule_id スケジュールID
	 * @param string $action 押下されたボタンの種類
	 * @return boolean true：チェックOK／false：NG
	 */
	function call_check_start_time($schedule_id, $action)
	{
		$t21OutTime = $this->T21OutTime->getTimeStartByScheduleId($schedule_id);
		return $this->Util->check_start_time($t21OutTime[0]['time_start'], $action);
	}

	function create() {
		if (!empty($this->data)) {
			$this->layout = false;
			$this->view = 'ajax_form_create';

			$edit_flag = 0;
			$disable_input_flag = 0;
			$call_right_away_flag = 1;
			$msg_edit = '';

			if (isset($this->data['id']) && $this->data['id']) {
				$data_schedule = $this->T20OutSchedule->getScheduleById($this->data["id"]);

				if (isset($this->data['action']) && $this->data['action'] == 'edit') {
					$edit_flag = 1;

					$status = $data_schedule['T20OutSchedule']['status'];
					$post_code = $this->ESession->getUserPostCode($this);
					$edit_permission = $this->M04ControllerAction->check_permission($post_code, 'Schedule', 'edit');
					$call_right_away_permission = $this->M04ControllerAction->check_permission($post_code, 'Schedule', 'call_right_away');

					if ($edit_permission) {
						if ($status != STATUS_NO_CALL) {
							$disable_input_flag = 1;
							$msg_edit = SCHEDULE_ERROR_EDIT_1 . $this->get_status_name($status) . SCHEDULE_ERROR_EDIT_2;
						}
					} else {
						$disable_input_flag = 1;
					}

					if (!$call_right_away_permission || ($status != STATUS_NO_CALL)) {// Edit by Giang - udpate tel_total schedule
						$call_right_away_flag = 0;
					}
				}

				$data_out_times = $this->T21OutTime->getByScheduleId($data_schedule['T20OutSchedule']['id']);
				if (isset($data_out_times[0])) {
					$data_schedule["T20OutSchedule"]["create_date"] = $data_out_times[0]["T21OutTime"]["time_start"];
				}

				$arr_call_times = array();
				foreach ($data_out_times as $key => $data_out_time) {
					$arr_call_times[] = array(
						'start_date' => $data_out_time['T21OutTime']['time_start'],
						'end_date' => $data_out_time['T21OutTime']['time_end'],
						'section_id' => 1,
						'text' => 'call_times_' . $key
					);
				}
				$data_schedule['T20OutSchedule']['call_times'] = json_encode($arr_call_times);

				$this->set('id', $this->data["id"]);
				$this->set('data', $data_schedule);
			}

			$schedule_time_reload = $this->M90PulldownCode->getSelectOption('schedule_time_reload');
			$call_type = $this->M90PulldownCode->getSelectOption('call_type');
			$external_number = $this->M06CompanyExternal->getExternalNumberByCompanyId($this->ESession->getUserCompanyId($this));
			$list_ngs = $this->T14OutgoingNgList->getNgListByCompanyId($this->ESession->getUserCompanyId($this));
			$templates = $this->T30Template->getTemplateByCompanyId($this->ESession->getUserCompanyId($this), TEMPLATE_OUTBOUND);
			$lists = $this->T10CallList->getListByCompanyId($this->ESession->getUserCompanyId($this));
			$info_company = $this->M02Company->getByCompanyId($this->ESession->getUserCompanyId($this));
			$max_proc_num = $info_company['M02Company']['ch_num'];
			$proc_num = $this->M90PulldownCode->getProcNum($max_proc_num);
			$dial_wait_time = $this->M90PulldownCode->getSelectOption('dial_wait_time');
			$ans_timeout = $this->M90PulldownCode->getSelectOption('ans_timeout');
			$recall = $this->M90PulldownCode->getOptionByMaxRedial('schedule_redial_flag', $this->ESession->getMaxRedial($this));
			$recall_time = $this->M90PulldownCode->getSelectOption('schedule_redial_time');
			$outgoing_time = $this->M90PulldownCode->getSelectOption('outgoing_time');

			$this->set('schedule_time_reload', $schedule_time_reload);
			$this->set('call_type', $call_type);
			$this->set('external_number', $external_number);
			$this->set('list_ngs', $list_ngs);
			$this->set('templates', $templates);
			$this->set('lists', $lists);
			$this->set('proc_num', $proc_num);
			$this->set('dial_wait_time', $dial_wait_time);
			$this->set('ans_timeout', $ans_timeout);
			$this->set('recall', $recall);
			$this->set('recall_time', $recall_time);
			$this->set('outgoing_time', $outgoing_time);

			$this->set('time_reload', $this->ESession->getTimeReload($this));

			$this->set('edit_flag', $edit_flag);
			$this->set('msg_edit', $msg_edit);
			$this->set('disable_input_flag', $disable_input_flag);
			$this->set('call_right_away_flag', $call_right_away_flag);
		}
	}

	function show_popup_recall() {
		$this->layout = false;
		$this->view = 'popup_recall';

		$data = $this->data;

		$outgoing_time = $this->M90PulldownCode->getSelectOption('outgoing_time');
		$info_company = $this->M02Company->getByCompanyId($this->ESession->getUserCompanyId($this));
		$max_proc_num = $info_company['M02Company']['ch_num'];
		$proc_num = $this->M90PulldownCode->getProcNum($max_proc_num);

		$this->set('outgoing_time', $outgoing_time);
		$this->set("proc_num", $proc_num);
		$this->set("schedule_id", $data['schedule_id']);
		$this->set("title_btn", $data['title_btn']);
		$this->set("action", $data['action']);
		$this->set("screen", $data['screen']);
	}

	//作成、更新、すぐ発信、ポップアップ表示
	function save($type = null) {
		$this->layout = "ajax";
		$data = $this->data;
		if (!empty($data)) {
			$user_id = $this->ESession->getUserId($this);
			$company_id = $this->ESession->getUserCompanyId($this);
			$dsSchedule = $this->T20OutSchedule->getDataSource();
			$dsSchedule->begin($this);

			$action_update = false;

			$T20OutSchedule = $data["T20OutSchedule"];
			$T20OutSchedule["id"] = "";
			$T20OutSchedule["company_id"] = $this->ESession->getUserCompanyId($this);
			$T20OutSchedule["cron_flag"] = "Y";
			$update_time = date('Y-m-d H:i:s', time());

			if ($type == "call") {
				$T20OutSchedule["entry_user"] = $user_id;
				$T20OutSchedule["entry_program"] =  $this->name.'_Call_Schedule';
				$T21OutTimes = json_decode($data["T20OutSchedule"]["call_times2"], true);
			} else {
				$T21OutTimes = json_decode($data["T20OutSchedule"]["call_times"], true);
				$run_date = $T20OutSchedule["create_date"];
			}
			//追加処理
			if($type == "create" || $type == "duplicate"
				|| (($type == "call") && (!isset($data["T20OutSchedule"]["id"]) || empty($data["T20OutSchedule"]["id"])))){
				$max_schedule = $this->T20OutSchedule->getMaxScheduleNoByCompanyId($company_id);
				if ($max_schedule["0"]["max_schedule_no"]) {
					$schedule_no = $max_schedule["0"]["max_schedule_no"] + 1;
				} else {
					$schedule_no = 1;
				}
				$T20OutSchedule["schedule_no"] = $schedule_no;
				$T20OutSchedule["entry_user"] = $user_id;
				if ($type == "duplicate") {
					$T20OutSchedule["entry_program"] =  $this->name.'_Duplicate_Schedule';
				}else {
					$T20OutSchedule["entry_program"] =  $this->name.'_Create_Schedule';
				}
			}

			//更新処理
			if ($type == "update" ||($type == "call" && isset($data["T20OutSchedule"]["id"]) && !empty($data["T20OutSchedule"]["id"]))) {
				$action_update = true;
				$T20OutScheduleBackup = $this->T20OutSchedule->getScheduleById($data["T20OutSchedule"]["id"]);
				$T21OutTimeBackups = $this->T21OutTime->getByScheduleIds($data["T20OutSchedule"]["id"]);
				$T20OutSchedule["id"] = $data["T20OutSchedule"]["id"];
				$T20OutSchedule["update_user"] = $user_id;
				$T20OutSchedule["update_program"] =  $this->name.'_Update_Schedule';
			}

			//スケジュール2重登録確認(2重リクエスト対策)
			$check_same_data = array(
				"schedule_id" => $T20OutSchedule["id"],
				"create_date" => $T20OutSchedule["create_date"],
				"list_ng_id" => $T20OutSchedule["list_ng_id"],
				"template_id" => $T20OutSchedule["template_id"],
				"list_id" => $T20OutSchedule["list_id"],
				"action" => $type
			);
			//即時発信処理の場合、create_dateに現在の日付を設定
			if ($type == "call") {
				$check_same_data["create_date"] = Date('Y-m-d');
			}
			//スケジュール2重登録が確認された場合、2重リクエスト発生とし、メールを送信
			if (!$this->check_same_schedule($check_same_data)) {
				$dsSchedule->rollback($this);
				$this->log("スケジュール登録時、2重リクエスト発生");

				$subject = "【はやぶさ】スケジュール登録時、2重リクエスト発生";
				$m02Company = $this->M02Company->getCompanyByCompanyId($company_id);
				$company_name = $m02Company["M02Company"]["company_name"];
				$this->SendMail->sendErrorMail($subject, $company_id, $company_name, $T20OutSchedule['external_number']);

				$result = array("result" => "err_same", "schedule_id" => "",);
				echo json_encode($result);
				exit;
			}

			//保存
			$flag = $this->T20OutSchedule->save($T20OutSchedule);
			if($flag) {
				$schedule_id = $flag['T20OutSchedule']['id'];
				$dsSchedule->commit($this);
				//T92Lock登録
				$T92Lock = array();
				$T92Lock["lock_flag"] = 'schedule';
				$T92Lock["lock_id"] = $schedule_id;
				$T92Lock["use_user_id"] = $user_id;
				$T92Lock['session_id'] = $this->Session->id();
				$T92Lock["entry_user"] = $user_id;
				$T92Lock["entry_program"] = $this->name.'_Update_Schedule';
				$T92Lock["created"] = date('Y-m-d H:i:s a', time());

				$dsT92Lock = $this->T92Lock->getDataSource();
				$dsT92Lock->begin($this);
				$flag = $this->T92Lock->save($T92Lock);
				if($flag){
					$dsT92Lock->commit($this);
					$t92lock_id = $this->T92Lock->getLastInsertId();
				}else{
					$dsT92Lock->rollback($this);
					$dsSchedule->rollback($this);
					$this->log("スケジュール画面でDBの操作：失敗");
					$result = array("result" => "err_db", "schedule_id" => "",);
					echo json_encode($result);
					exit;
				}
			} else {
				//DBに更新失敗の場合
				$dsSchedule->rollback($this);
				$this->log("スケジュール画面でDBの操作：失敗");
				$result = array("result" => "err_db", "schedule_id" => "",);
				echo json_encode($result);
				exit;
			}
			//実行時間追加
			$dsOutTime = $this->T21OutTime->getDataSource();
			$dsOutTime->begin($this);
			if ($type == 'update' || ($type == "call" && isset($data["T20OutSchedule"]["id"]) && !empty($data["T20OutSchedule"]["id"]))) {
				$update_program = $this->name . '_Update_Schedule';
				if ($type == "call" && isset($data["T20OutSchedule"]["id"]) && !empty($data["T20OutSchedule"]["id"])) {
					$query = "UPDATE t21_out_times
								  SET
									del_flag='Y',
									update_user='" . $user_id . "',
									update_program='" . $update_program. "',
									modified='" . $update_time . "'
								  WHERE
									schedule_id='" . $schedule_id . "' AND
									time_start > '" . date('Y-m-d H:i:s') . "' AND 
									del_flag = 'N';
								  ";
				} else {
					$query = "UPDATE t21_out_times
								  SET
									del_flag='Y',
									update_user='". $user_id . "',
									update_program='" . $update_program. "',
									modified='" . $update_time . "'
								  WHERE
									schedule_id='" . $schedule_id . "' AND 
									del_flag = 'N';
								  ";
				}
				$flag = $this->T21OutTime->query($query);
				if ($flag) {
					$dsSchedule->rollback($this);
					$dsOutTime->rollback($this);
					$this->log("スケジュール画面で実行時間削除の操作：失敗");
					$result = array("result" => "err_db", "schedule_id" => "",);
					echo json_encode($result);
					exit;
				}
			}
			foreach ($T21OutTimes as $arr) {
				$this->T21OutTime->create();
				$T21OutTime = array();
				$T21OutTime['schedule_id'] = $schedule_id;
				if ($type == 'call') {
					$T21OutTime['time_start'] = $arr['start_date'];
					$T21OutTime['time_end'] = $arr['end_date'];
				} else {
					$T21OutTime['time_start'] = $run_date . " " . $arr['start_date'];
					$T21OutTime['time_end'] = $run_date . " " . $arr['end_date'];
				}
				$T21OutTime['entry_user'] = $user_id;
				if ($type == 'duplicate') {
					$T21OutTime['entry_program'] =  $this->name . '_Duplicate_Schedule';
				} else if ($type == 'update') {
					$T21OutTime['entry_program'] =  $update_program;
				} else {
					$T21OutTime['entry_program'] =  $this->name . '_Create_Schedule';
				}
				$flag = $this->T21OutTime->save($T21OutTime);
				if (!$flag) {
					//DBに更新失敗の場合
					$dsSchedule->rollback($this);
					$dsOutTime->rollback($this);
					$this->log("スケジュール画面で実行時間追加の操作：失敗");
					$result = array("result" => "err_db", "schedule_id" => "",);
					echo json_encode($result);
					exit;
				}
			}
			$dsOutTime->commit($this);
			//バッチ
			$template_id = $data["T20OutSchedule"]["template_id"];
			$list_id = $data["T20OutSchedule"]["list_id"];
			$external_number = $data["T20OutSchedule"]["external_number"];
			$arr_server_info = $this->M01Server->getServerByExternalNumber($external_number, "1"); //outbound server_type = 1
			if(!empty($arr_server_info)){
				$update_program = $this->name . '_Update_Schedule';
				$server_id = $arr_server_info["M01Server"]["server_id"];
				$server_ip = $arr_server_info["M01Server"]["server_ip"];
				$local_path  = $arr_server_info["M01Server"]["local_path"];
				if($type == "call") $call_flag = true;
				else $call_flag = false;
				if($action_update) $update_flag = true;
				else $update_flag = false;
				$batch_result = $this->batch_create_schedule($server_id, $server_ip, $local_path, $schedule_id, $template_id, $list_id, $update_flag, $call_flag);
				//$batch_result = 'success';
				$T20OutSchedule = array();
				if($batch_result == "success"){
					$T20OutSchedule["id"] = $schedule_id;
					if($type == "call"){
						$T20OutSchedule["status"] = STATUS_CALLING;
					}
					$T20OutSchedule["cron_flag"] = "N";
 					//T92Lock解除
 					if (isset($t92lock_id) && !empty($t92lock_id)) {
 						$T92Lock = array();
 						$T92Lock["id"] = $t92lock_id;
 						$T92Lock["del_flag"] = "Y";
 						$T92Lock["update_user"] = $user_id;
 						$T92Lock["update_program"] = $update_program;
 						$T92Lock["modified"] = $update_time;

 						$dsT92Lock = $this->T92Lock->getDataSource();
 						$dsT92Lock->begin($this);
 						$flag = $this->T92Lock->save($T92Lock);
 						if ($flag) {
 							$dsT92Lock->commit($this);
 						} else {
 							$dsT92Lock->rollback($this);
 							$dsSchedule->rollback($this);
 							$dsOutTime->rollback($this);

 							$this->log("スケジュール画面でDBの操作：失敗");
 							$result = array(
 									"result" => "err_db",
 									"schedule_id" => "",
 							);
 							echo json_encode($result);
 							exit;
 						}
 					}
				}else{
					if($action_update){
						$T20OutSchedule = $T20OutScheduleBackup;
					}else{
						$T20OutSchedule["id"] = $schedule_id;
						$T20OutSchedule["del_flag"] = "Y";
					}
					$query = "UPDATE t21_out_times
							  SET
								  del_flag='Y',
								  update_user='". $user_id . "',
								  update_program='" . $update_program. "',
								  modified='" . $update_time . "'
							  WHERE
								  schedule_id='" . $schedule_id . "' AND 
								  del_flag = 'N';
							  ";
					$flag = $this->T21OutTime->query($query);
					if ($flag) {
						$dsOutTime->rollback($this);
						$this->log("スケジュール画面で実行時間追加の操作：失敗");
						$result = array("result" => "err_db", "schedule_id" => "",);
						echo json_encode($result);
						exit;
					}
					foreach ($T21OutTimeBackups as $T21OutTimeBackup) {
						$this->T21OutTime->create();
						$T21OutTime = array();
						$flag = $this->T21OutTime->save($T21OutTimeBackup);
						if (!$flag) {
							//DBに更新失敗の場合
							$dsOutTime->rollback($this);
							$this->log("スケジュール画面で実行時間追加の操作：失敗");
							$result = array("result" => "err_db", "schedule_id" => "",);
							echo json_encode($result);
							exit;
						}
					}
				}
				$flag = $this->T20OutSchedule->save($T20OutSchedule);
				if($flag) {
					$dsSchedule->commit($this);
				}else{
					//DBに更新失敗の場合
					$dsSchedule->rollback($this);
					$this->log("スケジュール画面でDBの操作：失敗");
					$result = array("result" => "err_db", "schedule_id" => "",);
					echo json_encode($result);
					exit;
				}
				$result = array("result" => $batch_result, "schedule_id" => $schedule_id,);
				echo json_encode($result);
				if ($type == "call") {
					$this->ESession->setTimeReloadStatus(1, $this);
				}
				exit;
			}else{
				$result = array(
					"result" => 'success',
					"schedule_id" => $schedule_id
				);
				echo json_encode($result);
				if ($type == "call") {
					$this->ESession->setTimeReloadStatus(1, $this);
				}
				exit;
			}
		}
		$this->redirect(array('controller' => 'OutSchedule', 'action' => 'index'));
	}
	/*
	 * 未発信以外ダウンロードできる
	 */
	function check_download_schedule() {
		$data = $this->data;
		if (empty($data)) {
			$this->redirect(array('controller' => 'OutSchedule', 'action' => 'index'));
		}

		$schedule_ids = $data['schedule_ids'];
		if (!is_array($schedule_ids)) {
			$schedule_ids = explode(' ', $schedule_ids);
		}
		foreach ($schedule_ids as $id) {
			$arr_schedule_info = $this->T20OutSchedule->getScheduleById($id);
			if (count($arr_schedule_info) < 1) {
				$result = array(
					'status' => 'err_not_exist',
					'schedule_id' => $id
				);
				echo json_encode($result);
				exit;
			}

			if ($arr_schedule_info['T20OutSchedule']['status'] == STATUS_NO_CALL) {
				$result = array(
					'status' => 'err_status_can_not_download',
					'schedule_id' => $id
				);
				echo json_encode($result);
				exit;
			}
		}
		$result = array(
			'status' => 'can_download',
		);
		echo json_encode($result);
		exit;
	}

	/*　スケジュールのIDなどを貯め込む（function download_schedule()の前準備）
	 * 
	 * @parame $action
	 *     download_all_log　　　：履歴ログ
	 *     download_uncalled　　：未発信ログ
	 *     　　　　　　　　　　　　　　　　　：有効ログ
	 * 
	 */
	function buffer_schedule_data($action) {
		$data = $this->data;
		if (empty($data)) {
			echo 'systemerror';
			exit;
		}
		$tmp_schedule_ids = $data['schedule_ids'];		
		$download_multi = true;
		if (!is_array($tmp_schedule_ids)) {
			$schedule_ids = explode(' ', $tmp_schedule_ids);
			$download_multi = false;
		}else{			
			$schedule_ids = $tmp_schedule_ids;
		}		
		$schedule_data = Array();
		if ($action == 'download_uncalled') {
			$schedule_data['action_name'] = '未発信';
		} else if ($action == 'download_all_log') {			
			$schedule_data['action_name'] = '履歴ログ';
		} else {			
			$schedule_data['action_name'] = '有効ログ';
		}

		$schedule_data['download_multi'] = $download_multi;
		$schedule_data['schedule_ids'] = $schedule_ids;
		$schedule_data['action'] = $action;
		$this->ESession->setScheduleDataDownload($schedule_data, $this);
		echo 'success';
		exit;
	}

	/*　選択したDL項目別にcsvを作成して、DLする。
	 * 
	 */
	function download_schedule() {
		$schedule_data = $this->ESession->getScheduleDataDownload($this);
		if(!isset($schedule_data)){
			$this->redirect(array('controller' => 'OutSchedule', 'action' => 'index'));
		}

		// 複数スケジュール選択の場合（ファイル毎にcsvを作成し、Zipで固める）
		if ($schedule_data['download_multi']) {
			$file_out_name = date('YmdHis', time()) . '_' . $schedule_data['action_name'] . '.zip';
			$file_out_name = mb_convert_encoding($file_out_name, "SJIS-win", "UTF-8");
			$this->Csv->createZip($file_out_name);
		}

		$action = $schedule_data['action'];
		$schedule_ids = $schedule_data['schedule_ids'];

		// 内容毎に出力内容を作成
		if ($action == 'download_uncalled') {
			// 未発信
			$schedule_data['schedule_data'] = $this->download_uncalled($schedule_ids);
		} else if ($action == 'download_all_log') {
			// すべての発信履歴
			$schedule_data['schedule_data'] = $this->download_all_log($schedule_ids);
		} else {
			// 有効回答のみ
			$schedule_data['schedule_data'] = $this->download_ans_log($schedule_ids);
		}
		// 内容毎に出力内容を作成_END

		// スケジュール毎にCSVに書き出す
		foreach ($schedule_data['schedule_data'] as $schedule_id => $data) {

			$schedule = $this->T20OutSchedule->getScheduleById($schedule_id);
			if (!empty($schedule)) {
				$schedule_info = $this->T20OutSchedule->getHistoryInfoById($schedule_id);
				//$template_name = $schedule_info["T60TemplateHistory"]["template_name"];
				//$list_name = $schedule_info["T50ListHistory"]["list_name"];

				foreach ($data as $row) {
					$this->Csv->addRow($row);
				}

				$systemTitle = date('YmdHis', time()) . '_' . $schedule_data['action_name'] . '_' . $schedule_info["T20OutSchedule"]["schedule_name"]. '.csv';
				$title = mb_convert_encoding($systemTitle, "SJIS-win", "UTF-8");

				if ($schedule_data['download_multi']) {
					$this->Csv->addToZip($title, 'SJIS-win');
					$this->Csv->clear();
				} else {
					echo $this->Csv->render($title,'SJIS-win');
					$this->Session->delete('schedule_data_download');
					exit;
				}
			}
		}
		echo $this->Csv->renderZip('SJIS-win');
		$this->Session->delete('schedule_data_download');
		exit;
	}

	function download_uncalled($schedule_ids) {

		$schedule_data = Array();
		foreach ($schedule_ids as $schedule_id) {
			$schedule = $this->T20OutSchedule->getScheduleById($schedule_id);
			if (!empty($schedule)) {
				$schedule_info = $this->T20OutSchedule->getHistoryInfoById($schedule_id);

				//get format csv from t12
				$list_id = $schedule_info["T50ListHistory"]["list_id"];
				$list_items = $this->T12ListItem->getTitleByListId($list_id);

				//add header for csv file
				$header_arr = array();
				$list_columns = array();
				foreach ($list_items as $list_item) {
					$list_columns[] = $list_item['T12ListItem']['column'];
					$header_arr[] = $list_item['T12ListItem']['item_name'];

					if ($list_item['T12ListItem']['item_code'] == 'tel_no') {
						$tel_column = $list_item['T12ListItem']['column'];
					}
				}
				// $this->Csv->addRow($header_arr);
				$schedule_data[$schedule_id][] = $header_arr;

				//get data from db to create csv file
				$tel_no_not_calls = $this->T51TelHistory->getTelNotCalls($schedule_id, $tel_column);
				if (sizeof($tel_no_not_calls) > 0) {
					foreach ($tel_no_not_calls as $tel_no) {
						$r = array();
						foreach ($list_columns as $column) {
							array_push($r, $tel_no['T51TelHistory'][$column]);
						}
						// $this->Csv->addRow($r);
						$schedule_data[$schedule_id][] = $r;
					}
				} else {
					// $this->Csv->addRow(array());
					$schedule_data[$schedule_id][] = Array();
				}
			}
		}

		return $schedule_data;
	}

	// 履歴ダウンロード
	function download_all_log($schedule_ids){
		$schedule_data = Array();
        $smsStatusTitle = array(
            OUTGOING_SMS_STATUS_SUCCESS => '着信済み',
            OUTGOING_SMS_STATUS_OUTSIDE => '圏外',
            OUTGOING_SMS_STATUS_UNKNOWN => '不明',
            OUTGOING_SMS_STATUS_ERROR => 'エラー',
            OUTGOING_SMS_STATUS_SENDING => '送信中',
            OUTGOING_SMS_STATUS_NO_SEND => '',
        );
		$question_types = array(
			// QUESTION_VOICE,
			QUESTION_BASIC,
			QUESTION_AUTH,
			QUESTION_TEL,
			QUESTION_TRANS, //20160329 Update by Thai : update format tran ques
			QUESTION_RECORD,
			QUESTION_COUNT,
			QUESTION_SMS, //20161129 Update by Linh : include sms content
			QUESTION_AUTH_CHAR,
            QUESTION_SMS_INPUT
        );
		
		$header_logs = array(
			'call_datetime' => '発信日時',
			'tel_no' => '電話番号',
		);
		$arr_operator = array('<', '=', '>', '≠');
		$arr_all_listitem = $this->M90PulldownCode->getSelectOption("list_item");
		$num_all_listitem = count($arr_all_listitem);
		foreach ($schedule_ids as $schedule_id) {
			$schedule = $this->T20OutSchedule->getScheduleById($schedule_id);
			if (!empty($schedule)) {
				$schedule_info = $this->T20OutSchedule->getHistoryInfoById($schedule_id);
				$list_id = $schedule_info['T20OutSchedule']['list_id'];
				$arr_answer_pos = $this->get_answer_pos($schedule_id);
				//$have_tran_ques = $this->check_have_tran_ques($schedule_id); //20160329 Delete by Thai : update format tran ques

				//get format csv from t12
				$list_items = $this->T12ListItem->getTitleByListId($list_id);

				//add header for csv file
				$header_lists = array();
				$arr_list_items = Array();
				foreach ($list_items as $list_item) {
					if ($list_item['T12ListItem']['item_code'] == 'tel_no') {
						$tel_column = $list_item['T12ListItem']['column'];
					}else{
						$header_lists[$list_item['T12ListItem']['column']] = $list_item['T12ListItem']['item_name'];
					}

					$arr_list_items[$list_item['T12ListItem']['item_name']] = array(
						'item_code' => $list_item['T12ListItem']['item_code'],
						'column' => $list_item['T12ListItem']['column']
					);
				}
				for($i = 1; $i <= ($num_all_listitem-count($list_items)); $i++){
					array_push($header_lists, "備考".$i);
				}

				// SMS表示有り
				$data_headers = $this->get_data_header_schedule($schedule_id, $question_types, false, true); //20161129 Update by Linh : get header include sms question section
				$get_list_tel_flag = $data_headers['get_list_tel_flag'];
				$header_ques = $data_headers['headers'];

				//20160324 Edit by Thai : #6779 - update format when have tran ques - Begin
				//20160329 Update by Thai : update format tran ques - Begin
				$header_status = array(
					'connect_datetime' => '接続日時',
					'cut_datetime' => '切断日時',
					'count_second_connect' => '接続秒数',
					'status' => 'ステータス',
				);
				//20160329 Update by Thai : update format tran ques - End
				$header_csv_files = array_merge(
					$header_logs,
					$header_lists,
					$header_status,
					$header_ques
				);
				//20160324 Edit by Thai : #6779 - update format when have tran ques - End

				//add header for csv file
				$header_arr = array();
				foreach ($header_csv_files as $header_csv_file) {
					$header_arr[] = $header_csv_file;
				}
				// $this->Csv->addRow($header_arr);
				$schedule_data[$schedule_id][] = $header_arr;

				//get data from db to create csv file
				$logs = $this->T80OutgoingResult->getAllByScheduleId($schedule_id, false, $tel_column); //20161129 Update by Linh : get data with sms (T83)

				// 20170113 Update by Hungnv
				$sms_logs = $this->T83OutgoingSmsStatus->getSmsLogByScheduleId($schedule_id);
				$sms_logs = $this->_organizeSmsData($sms_logs);

				$questions = array();
				$question_temps = $this->T61QuestionHistory->getInfoQuesAnswByScheduleId($schedule_id, $question_types);
				foreach ($question_temps as $ques) {
					$questions[$ques['T61QuestionHistory']['question_no']]['T61QuestionHistory'] = $ques['T61QuestionHistory'];
					$questions[$ques['T61QuestionHistory']['question_no']]['T62ButtonHistory'][$ques['T62ButtonHistory']['answer_no']] = $ques['T62ButtonHistory'];
				}

				$arr_auth_column = array();
				if ($get_list_tel_flag) {
					foreach ($questions as $question) {
						if ($question['T61QuestionHistory']['question_type'] == QUESTION_AUTH || $question['T61QuestionHistory']['question_type'] == QUESTION_AUTH_CHAR) {
							$arr_auth_column[$question['T61QuestionHistory']['question_no']] = $arr_list_items[$question['T61QuestionHistory']['auth_item']];
						}
					}
				}

				if (sizeof($logs) > 0) {
					foreach ($logs as $log) {
						$r = array();
						//if ($log['T80OutgoingResult']['status'] != "recover") {
							foreach ($header_logs as $key => $header_log) {
								$r[] = $log['T80OutgoingResult'][$key];
							}

							foreach ($header_lists as $key => $header_list) {
								if(isset($log['T51TelHistory'][$key])){
									$r[] = $log['T51TelHistory'][$key];
								}else{
									$r[] = '';
								}

							}

							$r[] = $log['T80OutgoingResult']['connect_datetime'] == '0000-00-00 00:00:00' ? '' : $log['T80OutgoingResult']['connect_datetime'];
							$r[] = $log['T80OutgoingResult']['cut_datetime'] == '0000-00-00 00:00:00' ? '' : $log['T80OutgoingResult']['cut_datetime'];
							if (in_array($log['T80OutgoingResult']['status'], $this->Util->getCallResultConnectStatusArray())) {
								$r[] = strtotime($log['T80OutgoingResult']['cut_datetime']) - strtotime($log['T80OutgoingResult']['connect_datetime']);
								//20160324 Edit by Thai : #6779 - update format when have tran ques - Begin
								//20160329 Delete by Thai : update format tran ques - Begin
								/*if ($have_tran_ques) {
									$count_second_tranfer = strtotime($log['T80OutgoingResult']['trans_cut_datetime']) - strtotime($log['T80OutgoingResult']['trans_connect_datetime']);
									$r[] = $count_second_tranfer > 0 ? $count_second_tranfer : '';
								}*/
								//20160329 Delete by Thai : update format tran ques - End
								//20160324 Edit by Thai : #6779 - update format when have tran ques - End
								if($log['T80OutgoingResult']['status'] == "transfer"){
									$r[] = 'TRANSFER';
								}else if($log['T80OutgoingResult']['status'] == "transfertimeout"){
									$r[] = 'TRANSFERTIMEOUT';
								}else if($log['T80OutgoingResult']['status'] == "transferfull"){
									$r[] = 'TRANSFERFULL';
								}else if($log['T80OutgoingResult']['status'] == "connect"){
									$r[] = 'ANSWER';
								}else if($log['T80OutgoingResult']['status'] == "transferreject"
									|| in_array($log['T80OutgoingResult']['status'] , $this->Util->getCallResultConvertTFRejectArray())){
									$r[] = 'TRANSFERREJECT';
								}
							} else {
								$r[] = '';
								//20160324 Edit by Thai : #6779 - update format when have tran ques - Begin
								//20160329 Delete by Thai : update format tran ques - Begin
								/*if ($have_tran_ques) {
									$count_second_tranfer = strtotime($log['T80OutgoingResult']['trans_cut_datetime']) - strtotime($log['T80OutgoingResult']['trans_connect_datetime']);
									$r[] = $count_second_tranfer > 0 ? $count_second_tranfer : '';
								}*/
								//20160329 Delete by Thai : update format tran ques - End
								//20160324 Edit by Thai : #6779 - update format when have tran ques - End
								if($log['T80OutgoingResult']['status'] == "reject"){
									$r[] = 'REJECT';
								}else if($log['T80OutgoingResult']['status'] == "recover"){
									$r[] = 'SKIP';
								}else{
									$r[] = 'NOANSWER';
								}
							}

							foreach ($questions as $question) {
								//20161129 Update by Linh : fill sms question data - BEGIN
								if ($question['T61QuestionHistory']['question_type'] == QUESTION_SMS) {
                                	$idx = $log['T80OutgoingResult']['id'] . "_" .$schedule_id . "_" . $question['T61QuestionHistory']['question_no'];
                                    $smsData = $sms_logs[$idx];
                                	if(empty($smsData)){
                                		$r[] = $smsStatusTitle[OUTGOING_SMS_STATUS_NO_SEND];
                                		$r[] = "";
                                		$r[] = "";
                                	}else{
                                		// 送達状態、送達警告情報、短縮URLキー
                                		$r[] = $smsStatusTitle[$smsData['T83OutgoingSmsStatus']['sms_status']];
                                    	$r[] = $smsData['T83OutgoingSmsStatus']['message'];
                                		$r[] = $smsData['T83OutgoingSmsStatus']['sms_short_url_key'];
                                	}                                    
                                    continue;
                                }
                                if($question['T61QuestionHistory']['question_type'] == QUESTION_SMS_INPUT){
                                    $idx = $log['T80OutgoingResult']['id'] . "_" .$schedule_id . "_" . $question['T61QuestionHistory']['question_no'];
                                    $smsData = $sms_logs[$idx];
                                    if(empty($smsData)){
                                        $r[] = "";
                                        $r[] = "";
                                        $r[] = $smsStatusTitle[OUTGOING_SMS_STATUS_NO_SEND];
                                        $r[] = "";
                                        $r[] = "";
                                    }else{
                                        $r[] = $log['T80OutgoingResult']['answer' . ($answer_pos)];
                                        $r[] = $log['T80OutgoingResult']['answer' . ($answer_pos + 1)];
                                        $r[] = $smsStatusTitle[$smsData['T83OutgoingSmsStatus']['sms_status']];
                                        $r[] = $smsData['T83OutgoingSmsStatus']['message'];
                                        $r[] = $smsData['T83OutgoingSmsStatus']['sms_short_url_key'];
                                    }
                                    continue;
                                }
								//20161129 Update by Linh : fill sms question data - END
								$question_no = $question['T61QuestionHistory']['question_no'];
								$answer_pos = $arr_answer_pos[$question_no];

								$value = isset($answer_pos) && $question['T61QuestionHistory']['question_type'] != QUESTION_TRANS ? $log['T80OutgoingResult']['answer' . $answer_pos] : '';
								$r[] = $value;

								if ($question['T61QuestionHistory']['question_type'] == QUESTION_BASIC) {
									//20160407 Add by Thai : #6890 - Fix error statistic answer 51&52 - Begin
									if ($value == '*') {
										$value = 51;
									} else if ($value == '#') {
										$value = 52;
									}
									//20160407 Add by Thai : #6890 - Fix error statistic answer 51&52 - End
									if (isset($question['T62ButtonHistory'][$value]) && !empty($question['T62ButtonHistory'][$value]['answer_content'])) {
										$r[sizeof($r) - 1] = $question['T62ButtonHistory'][$value]['answer_content'];
									}
								} elseif ($question['T61QuestionHistory']['question_type'] == QUESTION_AUTH) {
									$auth_column = $arr_auth_column[$question_no]['column'];
									$auth_value = $log['T51TelHistory'][$auth_column];
									if (isset($auth_value) && $auth_value !== '' && isset($value) && $value !== '') {
										$auth_item_code = $arr_auth_column[$question_no]['item_code'];
										if ($auth_item_code == 'birthday') {
											$auth_value = DateTime::createFromFormat('Y年m月d日', $auth_value)->format('Ymd');
										} else {
											$auth_value = preg_replace('/[^\d]/', '', $auth_value);
										}

										if ($value < $auth_value) {
											$r[] = $arr_operator[0];
										} elseif ($value == $auth_value) {
											$r[] = $arr_operator[1];
										} else {
											$r[] = $arr_operator[2];
										}
									} else {
										$r[] = '';
									}

									if ($question['T61QuestionHistory']['recheck_flag'] == 1) {
										$pos_input = -1;
										for ($k=0; $k<3; $k++) {
											if ($log['T80OutgoingResult']['answer' . ($answer_pos + $k + 1)] != '' && $pos_input < 0) {
												$pos_input = $k;
											}
											if ($log['T80OutgoingResult']['answer' . ($answer_pos + $k + 1)] == $question['T61QuestionHistory']['recheck_button_next']) {
												$pos_input = $k;
												break;
											}
										}
										if ($pos_input >= 0) {
											$r[] = $log['T80OutgoingResult']['answer' . ($answer_pos + $pos_input + 1)];
										} else {
											$r[] = '';
										}
									}
								} elseif ($question['T61QuestionHistory']['question_type'] == QUESTION_AUTH_CHAR) {
									$auth_column = $arr_auth_column[$question_no]['column'];
									$auth_value = $log['T51TelHistory'][$auth_column];
									if (isset($auth_value) && $auth_value !== '' && isset($value) && $value !== '') {
										$auth_item_code = $arr_auth_column[$question_no]['item_code'];
										if ($auth_item_code == 'birthday') {
											$auth_value = DateTime::createFromFormat('Y年m月d日', $auth_value)->format('Ymd');
										} else {
											$auth_value = preg_replace('/[^\d]/', '', $auth_value);
										}
				
										if ($value === $auth_value) {
											$r[] = $arr_operator[1];
										} else {
											$r[] = $arr_operator[3];
										}
									} else {
										$r[] = '';
									}
				
									if ($question['T61QuestionHistory']['recheck_flag'] == 1) {
										if (($log['T80OutgoingResult']['answer' . ($answer_pos + 1)] == $question['T61QuestionHistory']['recheck_button_next'])
											|| ($log['T80OutgoingResult']['answer' . ($answer_pos + 2)] == $question['T61QuestionHistory']['recheck_button_next'])) {
											// 正番号が入力された場合
											$auth_input = $question['T61QuestionHistory']['recheck_button_next'];
										} elseif (!empty($log['T80OutgoingResult']['answer' . ($answer_pos + 1)])) {
											$auth_input = $log['T80OutgoingResult']['answer' . ($answer_pos + 1)];
										} elseif (!empty($log['T80OutgoingResult']['answer' . ($answer_pos + 2)])) {
											$auth_input = $log['T80OutgoingResult']['answer' . ($answer_pos + 2)];
										} else {
											$auth_input = '';
										}
										$r[] = $auth_input;
									}
								} elseif ($question['T61QuestionHistory']['question_type'] == QUESTION_RECORD) {
									if (!empty($log['T80OutgoingResult']['valid_count'])) {
										$r[sizeof($r) - 1] = 1;
										$r[] = $log['T80OutgoingResult']['valid_count'];
									} else {
										$r[sizeof($r) - 1] = '';
										$r[] = '';
									}
									//20160329 Add by Thai : update format tran ques - Begin
								} elseif ($question['T61QuestionHistory']['question_type'] == QUESTION_TRANS) {
									$count_second_tranfer = strtotime($log['T80OutgoingResult']['trans_cut_datetime']) - strtotime($log['T80OutgoingResult']['trans_connect_datetime']);
									$r[sizeof($r) - 1] = $count_second_tranfer > 0 ? $count_second_tranfer : '';
									//20160329 Add by Thai : update format tran ques - End
								} elseif ($question['T61QuestionHistory']['question_type'] == QUESTION_TEL && $question['T61QuestionHistory']['recheck_flag'] == 1) {
									$r[] = $log['T80OutgoingResult']['answer' . ($answer_pos + 1)];
								}
							}

							// $this->Csv->addRow($r);
							$schedule_data[$schedule_id][] = $r;
						//}
					}
				}
			}
		}

		return $schedule_data;
	}

	// 有効ダウンロード
	// （スケジュール一覧の「有効回答のみ」または、スケジュール詳細画面の「有効DL」）
	function download_ans_log($schedule_ids){
		$schedule_data = Array();

        $smsStatusTitle = array(
            OUTGOING_SMS_STATUS_SUCCESS => '着信済み',
            OUTGOING_SMS_STATUS_OUTSIDE => '圏外',
            OUTGOING_SMS_STATUS_UNKNOWN => '不明',
            OUTGOING_SMS_STATUS_ERROR => 'エラー',
            OUTGOING_SMS_STATUS_SENDING => '送信中',
            OUTGOING_SMS_STATUS_NO_SEND => '',
        );

		$question_types = array(
			// QUESTION_VOICE,
			QUESTION_BASIC,
			QUESTION_AUTH,
			QUESTION_TEL,
			QUESTION_TRANS, //20160329 Update by Thai : update format tran ques
			QUESTION_RECORD,
			QUESTION_COUNT,
			QUESTION_SMS, //20161129 Update by Linh : include sms question
			QUESTION_AUTH_CHAR,
            QUESTION_SMS_INPUT
		);
		$header_logs = array(
			'call_datetime' => '発信日時',
			'tel_no' => '電話番号',
		);
		$arr_operator = array('<', '=', '>', '≠');
		$arr_all_listitem = $this->M90PulldownCode->getSelectOption("list_item");
		$num_all_listitem = count($arr_all_listitem);
		foreach ($schedule_ids as $schedule_id) {
			$schedule = $this->T20OutSchedule->getScheduleById($schedule_id);
			if ($schedule) {
				$schedule_info = $this->T20OutSchedule->getHistoryInfoById($schedule_id);
				$list_id = $schedule_info['T20OutSchedule']['list_id'];
				$arr_answer_pos = $this->get_answer_pos($schedule_id);
//				$have_tran_ques = $this->check_have_tran_ques($schedule_id); //20160329 Delete by Thai : update format tran ques

				//get format csv from t12
				$list_items = $this->T12ListItem->getTitleByListId($list_id);

				//add header for csv file
				$header_lists = array();
				$arr_list_items = Array();
				foreach ($list_items as $list_item) {
					if ($list_item['T12ListItem']['item_code'] == 'tel_no') {
						$tel_column = $list_item['T12ListItem']['column'];
					} else {
						$header_lists[$list_item['T12ListItem']['column']] = $list_item['T12ListItem']['item_name'];
					}

					$arr_list_items[$list_item['T12ListItem']['item_name']] = array(
						'item_code' => $list_item['T12ListItem']['item_code'],
						'column' => $list_item['T12ListItem']['column']
					);
				}
				for($i = 1; $i <= ($num_all_listitem-count($list_items)); $i++){
					array_push($header_lists, "備考".$i);
				}

				$data_headers = $this->get_data_header_schedule($schedule_id, $question_types, false, true);  //20161129 Update by Linh : include question sms on header
				$get_list_tel_flag = $data_headers['get_list_tel_flag'];
				$header_ques = $data_headers['headers'];

				//20160324 Edit by Thai : #6779 - update format when have tran ques - Begin
				//20160329 Update by Thai : update format tran ques - Begin
				$header_status = array(
					'connect_datetime' => '接続日時',
					'cut_datetime' => '切断日時',
					'count_second_connect' => '接続秒数',
					'status' => 'ステータス',
				);
				//20160329 Update by Thai : update format tran ques - End
				$header_csv_files = array_merge(
					$header_logs,
					$header_lists,
					$header_status,
					$header_ques
				);
				//20160324 Edit by Thai : #6779 - update format when have tran ques - End

				//add header for csv file
				$header_arr = array();
				foreach ($header_csv_files as $header_csv_file) {
					$header_arr[] = $header_csv_file;
				}
				// $this->Csv->addRow($header_arr);
				$schedule_data[$schedule_id][] = $header_arr;

				//get data from db to create csv file
				$logs = $this->get_yuko_logs($schedule_id);

				// get sms data
				$sms_logs = $this->T83OutgoingSmsStatus->getSmsLogByScheduleId($schedule_id);
				$sms_logs = $this->_organizeSmsData($sms_logs);

				$questions = array();
				$question_temps = $this->T61QuestionHistory->getInfoQuesAnswByScheduleId($schedule_id, $question_types);
				foreach ($question_temps as $ques) {
					$questions[$ques['T61QuestionHistory']['question_no']]['T61QuestionHistory'] = $ques['T61QuestionHistory'];
					$questions[$ques['T61QuestionHistory']['question_no']]['T62ButtonHistory'][$ques['T62ButtonHistory']['answer_no']] = $ques['T62ButtonHistory'];
				}

				$arr_auth_column = array();
				if ($get_list_tel_flag) {
					foreach ($questions as $question) {
						if ($question['T61QuestionHistory']['question_type'] == QUESTION_AUTH || $question['T61QuestionHistory']['question_type'] == QUESTION_AUTH_CHAR) {
							$arr_auth_column[$question['T61QuestionHistory']['question_no']] = $arr_list_items[$question['T61QuestionHistory']['auth_item']];
						}
					}
				}

				if (sizeof($logs) > 0) {
					foreach ($logs as $log) {
						$r = array();
						if ($log['T80OutgoingResult']['status'] != "recover") {
							foreach ($header_logs as $key => $header_log) {
								$r[] = $log['T80OutgoingResult'][$key];
							}

							foreach ($header_lists as $key => $header_list) {
								if(isset($log['T51TelHistory'][$key])){
									$r[] = $log['T51TelHistory'][$key];
								}else{
									$r[] = '';
								}
							}

							$r[] = $log['T80OutgoingResult']['connect_datetime'] == '0000-00-00 00:00:00' ? '' : $log['T80OutgoingResult']['connect_datetime'];
							$r[] = $log['T80OutgoingResult']['cut_datetime'] == '0000-00-00 00:00:00' ? '' : $log['T80OutgoingResult']['cut_datetime'];
							if (!in_array($log['T80OutgoingResult']['status'], array('timeout', 'reject','recover'))) {
								$r[] = strtotime($log['T80OutgoingResult']['cut_datetime']) - strtotime($log['T80OutgoingResult']['connect_datetime']);
								//20160324 Edit by Thai : #6779 - update format when have tran ques - Begin
								//20160329 Delete by Thai : update format tran ques - Begin
								/*if ($have_tran_ques) {
									$count_second_tranfer = strtotime($log['T80OutgoingResult']['trans_cut_datetime']) - strtotime($log['T80OutgoingResult']['trans_connect_datetime']);
									$r[] = $count_second_tranfer > 0 ? $count_second_tranfer : '';
								}*/
								//20160329 Delete by Thai : update format tran ques - End
								//20160324 Edit by Thai : #6779 - update format when have tran ques - End
								if($log['T80OutgoingResult']['status'] == "transfer"){
									$r[] = 'TRANSFER';
								}else if($log['T80OutgoingResult']['status'] == "transfertimeout"){
									$r[] = 'TRANSFERTIMEOUT';
								}else if($log['T80OutgoingResult']['status'] == "transferfull"){
									$r[] = 'TRANSFERFULL';
								}else if($log['T80OutgoingResult']['status'] == "transferreject"
									|| in_array($log['T80OutgoingResult']['status'] , $this->Util->getCallResultConvertTFRejectArray())){
									$r[] = 'TRANSFERREJECT';
								}else{
									$r[] = 'ANSWER';
								}
							} else {
								$r[] = '';
								//20160324 Edit by Thai : #6779 - update format when have tran ques - Begin
								//20160329 Delete by Thai : update format tran ques - Begin
								/*if ($have_tran_ques) {
									$count_second_tranfer = strtotime($log['T80OutgoingResult']['trans_cut_datetime']) - strtotime($log['T80OutgoingResult']['trans_connect_datetime']);
									$r[] = $count_second_tranfer > 0 ? $count_second_tranfer : '';
								}*/
								//20160329 Delete by Thai : update format tran ques - End
								//20160324 Edit by Thai : #6779 - update format when have tran ques - End
								if($log['T80OutgoingResult']['status'] == "reject"){
									$r[] = 'REJECT';
								}else if($log['T80OutgoingResult']['status'] == "recover"){
									$r[] = 'SKIP';
								}else{
									$r[] = 'NOANSWER';
								}
							}

							foreach ($questions as $key => $question) {
								//20161129 Update by Linh : fill sms question data - BEGIN
								if ($question['T61QuestionHistory']['question_type'] == QUESTION_SMS) {
                                	$idx = $log['T80OutgoingResult']['id'] . "_" .$schedule_id . "_" . $question['T61QuestionHistory']['question_no'];
                                    $smsData = $sms_logs[$idx];
                                    # 電話が途中で切られた場合など。
                                	if(empty($smsData)){
                                		$r[] = $smsStatusTitle[OUTGOING_SMS_STATUS_NO_SEND];
                                		$r[] = "";
                                		$r[] = "";
                                	}else{
                                		$r[] = $smsStatusTitle[$smsData['T83OutgoingSmsStatus']['sms_status']];
                                    	$r[] = $smsData['T83OutgoingSmsStatus']['message'];
                                    	$r[] = $smsData['T83OutgoingSmsStatus']['sms_short_url_key'];
                                	}
                                    continue;
                                }
								//20161129 Update by Linh : fill sms question data - END
								$question_no = $question['T61QuestionHistory']['question_no'];
								$answer_pos = $arr_answer_pos[$question_no];

								$value = isset($answer_pos) && $question['T61QuestionHistory']['question_type'] != QUESTION_TRANS ? $log['T80OutgoingResult']['answer' . $answer_pos] : '';
								$r[] = $value;

								if ($question['T61QuestionHistory']['question_type'] == QUESTION_BASIC) {
									//20160407 Add by Thai : #6890 - Fix error statistic answer 51&52 - Begin
									if ($value == '*') {
										$value = 51;
									} else if ($value == '#') {
										$value = 52;
									}
									//20160407 Add by Thai : #6890 - Fix error statistic answer 51&52 - End
									if (isset($question['T62ButtonHistory'][$value]) && !empty($question['T62ButtonHistory'][$value]['answer_content'])) {
										$r[sizeof($r) - 1] = $question['T62ButtonHistory'][$value]['answer_content'];
									}
								} elseif ($question['T61QuestionHistory']['question_type'] == QUESTION_AUTH) {
									$auth_column = $arr_auth_column[$question_no]['column'];
									$auth_value = $log['T51TelHistory'][$auth_column];
									if (isset($auth_value) && $auth_value !== '' && isset($value) && $value !== '') {
										$auth_item_code = $arr_auth_column[$question_no]['item_code'];
										if ($auth_item_code == 'birthday') {
											$auth_value = DateTime::createFromFormat('Y年m月d日', $auth_value)->format('Ymd');
										} else {
											$auth_value = preg_replace('/[^\d]/', '', $auth_value);
										}

										if ($value < $auth_value) {
											$r[] = $arr_operator[0];
										} elseif ($value == $auth_value) {
											$r[] = $arr_operator[1];
										} else {
											$r[] = $arr_operator[2];
										}
									} else {
										$r[] = '';
									}

									if ($question['T61QuestionHistory']['recheck_flag'] == 1) {
										$pos_input = -1;
										for ($k=0; $k<3; $k++) {
											if ($log['T80OutgoingResult']['answer' . ($answer_pos + $k + 1)] != '' && $pos_input < 0) {
												$pos_input = $k;
											}
											if ($log['T80OutgoingResult']['answer' . ($answer_pos + $k + 1)] == $question['T61QuestionHistory']['recheck_button_next']) {
												$pos_input = $k;
												break;
											}
										}
										if ($pos_input >= 0) {
											$r[] = $log['T80OutgoingResult']['answer' . ($answer_pos + $pos_input + 1)];
										} else {
											$r[] = '';
										}
									}
								} elseif ($question['T61QuestionHistory']['question_type'] == QUESTION_AUTH_CHAR) {
									$auth_column = $arr_auth_column[$question_no]['column'];
									$auth_value = $log['T51TelHistory'][$auth_column];
									if (isset($auth_value) && $auth_value !== '' && isset($value) && $value !== '') {
										$auth_item_code = $arr_auth_column[$question_no]['item_code'];
										if ($auth_item_code == 'birthday') {
											$auth_value = DateTime::createFromFormat('Y年m月d日', $auth_value)->format('Ymd');
										} else {
											$auth_value = preg_replace('/[^\d]/', '', $auth_value);
										}

										if ($value === $auth_value) {
											$r[] = $arr_operator[1];
										} else {
											$r[] = $arr_operator[3];
										}
									} else {
										$r[] = '';
									}

									if ($question['T61QuestionHistory']['recheck_flag'] == 1) {
										if (($log['T80OutgoingResult']['answer' . ($answer_pos + 1)] == $question['T61QuestionHistory']['recheck_button_next'])
											|| ($log['T80OutgoingResult']['answer' . ($answer_pos + 2)] == $question['T61QuestionHistory']['recheck_button_next'])) {
											//正番号が入力された場合
											$auth_input = $question['T61QuestionHistory']['recheck_button_next'];
										} elseif (!empty($log['T80OutgoingResult']['answer' . ($answer_pos + 1)])) {
											$auth_input = $log['T80OutgoingResult']['answer' . ($answer_pos + 1)];
										} elseif (!empty($log['T80OutgoingResult']['answer' . ($answer_pos + 2)])) {
											$auth_input = $log['T80OutgoingResult']['answer' . ($answer_pos + 2)];
										} else {
											$auth_input = '';
										}
										$r[] = $auth_input;
									}
								} elseif ($question['T61QuestionHistory']['question_type'] == QUESTION_RECORD) {
									if (!empty($log['T80OutgoingResult']['valid_count'])) {
										$r[sizeof($r) - 1] = 1;
										$r[] = $log['T80OutgoingResult']['valid_count'];
									} else {
										$r[sizeof($r) - 1] = '';
										$r[] = '';
									}
									//20160329 Add by Thai : update format tran ques - Begin
								} elseif ($question['T61QuestionHistory']['question_type'] == QUESTION_TRANS) {
									$count_second_tranfer = strtotime($log['T80OutgoingResult']['trans_cut_datetime']) - strtotime($log['T80OutgoingResult']['trans_connect_datetime']);
									$r[sizeof($r) - 1] = $count_second_tranfer > 0 ? $count_second_tranfer : '';
									//20160329 Add by Thai : update format tran ques - End
								} elseif ($question['T61QuestionHistory']['question_type'] == QUESTION_TEL && $question['T61QuestionHistory']['recheck_flag'] == 1) {
									$r[] = $log['T80OutgoingResult']['answer' . ($answer_pos + 1)];
								}
							}

							// $this->Csv->addRow($r);
							$schedule_data[$schedule_id][] = $r;
						}
					}
				}
			}
		}

		return $schedule_data;
	}

	function re_call() {
		$this->layout = "ajax";
		$data = $this->data;
		if (!empty($data)) {
			$userId = $this->ESession->getUserId($this);
			if ($data['action'] == 'recall') {
				$program = $this->name . '_Index_RecallSchedule';
			} else {
				$program = $this->name . '_Index_CallNowSchedule';
			}

			//T92Lock登録
			$dsT92Lock = $this->T92Lock->getDataSource();
			$dsT92Lock->begin($this);
			$T92Lock = array();
			$T92Lock["lock_flag"] = 'schedule';
			$T92Lock["lock_id"] = $data["schedule_id"];
			$T92Lock["use_user_id"] = $userId;
			$T92Lock['session_id'] = $this->Session->id();
			$T92Lock["entry_user"] = $userId;
			$T92Lock["entry_program"] = $program;
			$T92Lock["created"] = date('Y-m-d H:i:s a', time());
			$flag = $this->T92Lock->save($T92Lock);
			if($flag){
				$dsT92Lock->commit($this);
				$t92lock_id = $this->T92Lock->getLastInsertId();
			}else{
				$dsT92Lock->rollback($this);
				$this->log("停止処理がステータス画面でDBの操作：失敗");
				$result = array(
					"result" => "err_db",
				);
				echo json_encode($result);
				exit;
			}

			//DBでステータス更新
			$arr_schedule_info = $this->T20OutSchedule->getScheduleById($data['schedule_id']);
			$data['list_id'] = $arr_schedule_info['T20OutSchedule']['list_id'];
			if (!isset($data['proc_num'])) {
				//画面で再開場合ch数がない
				$data['proc_num'] = $arr_schedule_info['T20OutSchedule']['proc_num'];
			}
			$dsSchedule = $this->T20OutSchedule->getDataSource();
			$dsSchedule->begin($this);
			$T20OutSchedule = array();
			$T20OutSchedule['id'] = $data['schedule_id'];
// 			$T20OutSchedule['status'] = STATUS_CALLING;
			$T20OutSchedule['proc_num'] = $data["proc_num"];
			$T20OutSchedule['update_user'] = $userId;
			$T20OutSchedule['update_program'] = $program;
			$flag = $this->T20OutSchedule->save($T20OutSchedule);
			if($flag) {
				$dsSchedule->commit($this);
				//再開コマンド
				$batch_result = "success";
				$arr_server_info = $this->M01Server->getOutServerByScheduleId($data['schedule_id']);
				if(!empty($arr_server_info)){
					$server_id = $arr_server_info["M01Server"]["server_id"];
					$server_ip = $arr_server_info["M01Server"]["server_ip"];
					$local_path  = $arr_server_info["M01Server"]["local_path"];
					$batch_result = $this->batch_recall($server_id, $server_ip, $local_path, $data['schedule_id'], $data['list_id']);
				}
				if($batch_result != "success"){
					//rollback
					$dsSchedule = $this->T20OutSchedule->getDataSource();
					$dsSchedule->begin($this);
					$flag = $this->T20OutSchedule->save($arr_schedule_info);
					$dsSchedule->commit($this);
				}else{
					$dsSchedule = $this->T20OutSchedule->getDataSource();
					$dsSchedule->begin($this);
					$T20OutSchedule = array();
					$T20OutSchedule['id'] = $data['schedule_id'];
					$T20OutSchedule['status'] = STATUS_CALLING;
					$flag = $this->T20OutSchedule->save($T20OutSchedule);
				}
			}else{
				//DBに更新失敗の場合
				$dsSchedule->rollback($this);
				$this->log("再開処理がステータス画面でDBのステータス更新：失敗");
			}

			//update T21OutTime
			$dsOutTime = $this->T21OutTime->getDataSource();
			$dsOutTime->begin($this);

			$query = "UPDATE t21_out_times
						  SET
							del_flag='Y',
							update_user='" . $userId . "',
							update_program='" . $program. "'
						  WHERE
							schedule_id='" . $data['schedule_id'] . "' AND
							del_flag='N'
						  ";

			$out_time = $this->T21OutTime->query($query);
			if ($out_time) {
				$dsSchedule->rollback($this);
				$dsOutTime->rollback($this);
			} else {
				$dsOutTime->commit($this);
			}

			$T21OutTimes = $data["list_call_times"];
			foreach ($T21OutTimes as $arr) {
				$this->T21OutTime->create();
				$T21OutTime = array();
				$T21OutTime['schedule_id'] = $data['schedule_id'];
				$T21OutTime['time_start'] = $arr['start_date'];
				$T21OutTime['time_end'] = $arr['end_date'];
				$T21OutTime['entry_user'] = $userId;
				$T21OutTime['entry_program'] =  $program;

				if (!$this->T21OutTime->save($T21OutTime)) {
					//DBに更新失敗の場合
					$dsSchedule->rollback($this);
					$dsOutTime->rollback($this);
				} else {
					$dsOutTime->commit($this);
				}
			}

			//T92Lock解除
			if (isset($t92lock_id) && !empty($t92lock_id)) {
				$T92Lock = array();
				$T92Lock["id"] = $t92lock_id;
				$T92Lock["del_flag"] = "Y";
				$T92Lock["update_user"] = $userId;
				$T92Lock["update_program"] = $program;
				$T92Lock["modified"] = date('Y-m-d H:i:s a', time());
				$dsT92Lock = $this->T92Lock->getDataSource();
				$dsT92Lock->begin($this);
				$flag = $this->T92Lock->save($T92Lock);
				if ($flag) {
					$dsT92Lock->commit($this);
				} else {
					$dsT92Lock->rollback($this);
					$this->log("再開処理がステータス画面でDBの操作：失敗");
					$result = array(
						"result" => "err_db",
					);
					echo json_encode($result);
					exit;
				}
			}
			$result = array(
				"result" => $batch_result,
			);
			echo json_encode($result);
			exit;
		}
		exit;
	}

	function finish_schedule() {
		$this->layout = "ajax";
		$data = $this->data;
		if (empty($data)) {
			echo 'systemerror';
			exit;
		}

		//T92Lock登録
		$dsT92Lock = $this->T92Lock->getDataSource();
		$dsT92Lock->begin($this);
		$T92Lock = array();
		$T92Lock["lock_flag"] = 'schedule';
		$T92Lock["lock_id"] = $data["schedule_id"];
		$T92Lock["use_user_id"] = $this->ESession->getUserId($this);
		$T92Lock['session_id'] = $this->Session->id();
		$T92Lock["entry_user"] = $this->ESession->getUserId($this);
		$T92Lock["entry_program"] = $this->name.'_Index_FinishSchedule';
		$flag = $this->T92Lock->save($T92Lock);
		if ($flag){
			$dsT92Lock->commit($this);
			$t92lock_id = $this->T92Lock->getLastInsertId();
		} else {
			$dsT92Lock->rollback($this);
			$this->log("停止処理がステータス画面でDBの操作：失敗");
			echo 'err_db';
			exit;
		}

		$dsSchedule = $this->T20OutSchedule->getDataSource();
		$dsSchedule->begin($this);
		$T20OutSchedule = array();
		$T20OutSchedule['id'] = $data['schedule_id'];
		$T20OutSchedule['status'] = STATUS_FINISH;
		$T20OutSchedule['update_user'] = $this->ESession->getUserId($this);
		$T20OutSchedule['update_program'] = $this->name.'_Index_FinishSchedule';
		$schedule = $this->T20OutSchedule->save($T20OutSchedule);
		if($schedule) {
			$dsSchedule->commit($this);
		}else{
			//DBに更新失敗の場合
			$dsSchedule->rollback($this);
			$this->log("再開処理がステータス画面でDBのステータス更新：失敗");
		}
		//T92Lock解除
		if (isset($t92lock_id) && !empty($t92lock_id)) {
			$T92Lock = array();
			$T92Lock["id"] = $t92lock_id;
			$T92Lock["del_flag"] = "Y";
			$T92Lock["update_user"] = $this->ESession->getUserId($this);
			$T92Lock["update_program"] = $this->name.'_Index_FinishSchedule';
			$dsT92Lock = $this->T92Lock->getDataSource();
			$dsT92Lock->begin($this);
			$flag = $this->T92Lock->save($T92Lock);
			if ($flag) {
				$dsT92Lock->commit($this);
			} else {
				$dsSchedule->rollback($this);
				$dsT92Lock->rollback($this);
				$this->log("再開処理がステータス画面でDBの操作：失敗");
				echo 'err_db';
				exit;
			}
		}
		if ($schedule) {
			echo 'success';
			exit;
		}
		echo 'err_db';
		exit;
	}

	function check_finish_schedule() {
		$data = $this->data;
		if (empty($data)) {
			echo 'systemerror';
			exit;
		}

		$arr_schedule_info = $this->T20OutSchedule->getScheduleById($data['schedule_id']);
		if (count($arr_schedule_info) < 1) {
			echo 'err_not_exist';
			exit;
		}

		$status = $arr_schedule_info['T20OutSchedule']['status'];
		if (($status != STATUS_STOP_CALL) && ($status != STATUS_REDIAL_WAIT) && ($status != STATUS_TEMP_FINISH)) {
			echo 'err_status',
			exit;
		}

		echo 'success';
		exit;
	}

	function stop_call(){
		$this->layout = "ajax";
		$data = $this->data;
		if (!empty($data)) {
			//T92Lock登録
			$dsT92Lock = $this->T92Lock->getDataSource();
			$dsT92Lock->begin($this);
			$T92Lock = array();
			$T92Lock["lock_flag"] = 'schedule';
			$T92Lock["lock_id"] = $data["schedule_id"];
			$T92Lock["use_user_id"] = $this->ESession->getUserId($this);
			$T92Lock['session_id'] = $this->Session->id();
			$T92Lock["entry_user"] = $this->ESession->getUserId($this);
			$T92Lock["entry_program"] = $this->name.'_Index_StopSchedule';
			$T92Lock["created"] = date('Y-m-d H:i:s a', time());
			$flag = $this->T92Lock->save($T92Lock);
			if($flag){
				$dsT92Lock->commit($this);
				$t92lock_id = $this->T92Lock->getLastInsertId();
			}else{
				$dsT92Lock->rollback($this);
				$this->log("停止処理がステータス画面でDBの操作：失敗");
				echo 'err_db';
				exit;
			}

			//ステータス更新
			$dsSchedule = $this->T20OutSchedule->getDataSource();
			$dsSchedule->begin($this);
			$T20OutSchedule = array();
			$T20OutSchedule['id'] = $data['schedule_id'];
			$T20OutSchedule['status'] = STATUS_STOPING;
			$T20OutSchedule['update_user'] = $this->ESession->getUserId($this);
			$T20OutSchedule['update_program'] = $this->name.'_StopSchedule';
			$flag = $this->T20OutSchedule->save($T20OutSchedule);
			if($flag) {
				$dsSchedule->commit($this);
			}else{
				//DBに更新失敗の場合
				$dsSchedule->rollback($this);
				$this->log("停止処理がステータス画面でDBの操作：失敗");
				$batch_result = "err_db";
				echo $batch_result;
				exit;
			}
			//停止コマンド実行
			$schedule_id = $data['schedule_id'];
			$batch_result = "success";
			$arr_server_info = $this->M01Server->getOutServerByScheduleId($schedule_id);
			if(!empty($arr_server_info)){
				$server_id = $arr_server_info["M01Server"]["server_id"];
				$server_ip = $arr_server_info["M01Server"]["server_ip"];
				$local_path  = $arr_server_info["M01Server"]["local_path"];
				$batch_result = $this->batch_stop($server_ip, $local_path, $schedule_id);
			}

			//T92Lock解除
			if (isset($t92lock_id) && !empty($t92lock_id)) {
				$T92Lock = array();
				$T92Lock["id"] = $t92lock_id;
				$T92Lock["del_flag"] = "Y";
				$T92Lock["update_user"] = $this->ESession->getUserId($this);
				$T92Lock["update_program"] = $this->name.'_Index_StopSchedule';
				$T92Lock["modified"] = date('Y-m-d H:i:s a', time());
				$flag = $this->T92Lock->save($T92Lock);
				if ($flag) {
					$dsT92Lock->commit($this);
				} else {
					$dsT92Lock->rollback($this);
					$this->log("停止処理がステータス画面でDBの操作：失敗");
					echo 'err_db';
					exit;
				}
			}

			echo $batch_result;
		}
		exit;
	}

	function check_stop_schedule(){
		$data = $this->data;
		if (!empty($data)) {
			$arr_schedule_info = $this->T20OutSchedule->getScheduleById($data['schedule_id']);
			if (count($arr_schedule_info) < 1) {
				$result = array(
					'status' => 'err_not_exist',
					'schedule_id' => $data['schedule_id']
				);
				echo json_encode($result);
				exit;
			}

			//ステータス停止じゃない場合
			$status = $arr_schedule_info['T20OutSchedule']['status'];
			if ($status != STATUS_CALLING) {
				$result = array(
					'result' => 'error_status',
					'msg' => SCHEDULE_ERROR_STOP_CALL_1 . $this->get_status_name($status) . SCHEDULE_ERROR_STOP_CALL_2
				);
				echo json_encode($result);
				exit;
			}

			//スケジュールロック場合
			if ($this->check_unlock_schedule($data['schedule_id']) == false) {
				$result = array(
					'result' => 'error_locking',
				);
				echo json_encode($result);
				exit;
			}

			//通常場合
			$result = array(
				'result' => 'success',
			);
			echo json_encode($result);
			exit;
		}
		exit;
	}

	function check_recall_schedule() {
		$data = $this->data;
		if (empty($data)) {
			$this->redirect(array('controller' => 'OutSchedule', 'action' => 'index'));
		}

		$arr_schedule_info = $this->T20OutSchedule->getScheduleById($data['schedule_id']);
		if (count($arr_schedule_info) < 1) {
			$result = array(
				'result' => 'err_exist_schedule',
				'schedule_id' => $data['schedule_id']
			);
			echo json_encode($result);
			exit;
		}
		//ステータス停止じゃない場合
		$status = $arr_schedule_info['T20OutSchedule']['status'];
		if ($data['action'] == "recall") {
			if (!$this->check_status_can_recall($status)) {
				$result = array(
					'result' => 'error_status',
					'msg' => SCHEDULE_ERROR_RE_CALL_1 . $this->get_status_name($status) . SCHEDULE_ERROR_RE_CALL_2
				);
				echo json_encode($result);
				exit;
			}
		} else if ($data['action'] == 'call') {
			if (!$this->check_status_can_callnow($status)) {
				$result = array(
					'result' => 'error_status',
					'msg' => SCHEDULE_ERROR_CALL_RIGHT_AWAY1 . $this->get_status_name($status) . SCHEDULE_ERROR_CALL_RIGHT_AWAY2
				);
				echo json_encode($result);
				exit;
			}
		}

		//check proc_num
		$trans_ques = $this->T31TemplateQuestion->getTransQuesByTemplateId($arr_schedule_info['T20OutSchedule']['template_id']);
		if (sizeof($trans_ques) > 0 && isset($trans_ques['T31TemplateQuestion']['trans_seat_num'])) {
			$trans_seat_num = $trans_ques['T31TemplateQuestion']['trans_seat_num'];
		} else {
			$trans_seat_num = 0;
		}

		$info_company = $this->M02Company->getByCompanyId($this->ESession->getUserCompanyId($this));
		$max_yuko_procnum = $info_company['M02Company']['ch_num'];

		$time_prepare_procnum = $this->M99SystemParameter->getByFunctionIdAndParameterId('SCHEDULE', 'TIME_PREPARE_PROCNUM');
		$time_prepare_procnum = $time_prepare_procnum['M99SystemParameter']['parameter_value'];

		foreach ($data['list_call_times'] as $key => $list_call_time) {
			$data_call_time = array(
				'schedule_id' => $data['schedule_id'],
				'start_time' => date('Y-m-d H:i:s', strtotime($list_call_time['start_date']) - $time_prepare_procnum),
				'end_time' => date('Y-m-d H:i:s', strtotime($list_call_time['end_date']) + $time_prepare_procnum),
				'action' => $data['action']
			);

			$yuko_procnum = $this->check_over_ch($data_call_time);
			if ($yuko_procnum < $max_yuko_procnum) {
				$max_yuko_procnum = $yuko_procnum;
			}
		}

		if (!isset($data['proc_num'])) {
			$data['proc_num'] = $arr_schedule_info['T20OutSchedule']['proc_num'];
		}

		if (($data["proc_num"] + $trans_seat_num) > $max_yuko_procnum){
			$result = array(
				"result" => "err_over_ch",
				"yuko_procnum" => ($max_yuko_procnum - $trans_seat_num) > 0 ? ($max_yuko_procnum - $trans_seat_num) : 0,
				"limit_proc_num" => $info_company['M02Company']['ch_num']
			);
			echo json_encode($result);
			exit;
		}

		//check over_schedule
		$kaisenInfo = $this->M07ServerExternal->getInfoByExternalNumber($arr_schedule_info["T20OutSchedule"]["external_number"]);

		foreach ($data['list_call_times'] as $key => $list_call_time) {
			$data_call_time = array(
				'schedule_id' => $data['schedule_id'],
				'kaisen_code' => $kaisenInfo["M07ServerExternal"]["kaisen_code"],
				'start_time' => date('Y-m-d H:i:s', strtotime($list_call_time['start_date'])),
				'end_time' => date('Y-m-d H:i:s', strtotime($list_call_time['end_date'])),
				'action' => $data['action']
			);

			if (!$this->check_over_schedule($data_call_time)){
				$arr_limit_schedule = $this->M09KaisenInfo->getKaisenInfoByCode($kaisenInfo["M07ServerExternal"]["kaisen_code"]);
				$limit_schedule = $arr_limit_schedule['M09KaisenInfo']['max_schedule'];
				$result = array(
					"result" => "err_over_schedule",
					"limit_schedule" => $limit_schedule
				);
				echo json_encode($result);
				exit;
			}
		}

		//スケジュールロック場合
		if ($this->check_unlock_schedule($data['schedule_id']) == false) {
			$result = array(
				'result' => 'error_locking',
			);
			echo json_encode($result);
			exit;
		}
		//通常場合
		$result = array(
			'result' => 'success',
		);
		echo json_encode($result);
		exit;
	}

	// Outのスケジュール詳細表示画面
	function status() {
		$data = $this->data;
		if (!empty($data)) {
			$schedule_id = $data['schedule_id'];
			$schedule = $this->T20OutSchedule->getHistoryInfoById($schedule_id);

			if (isset($this->data['request_type']) && $this->data['request_type'] == 'ajax') {
				$this->layout = "ajax";
			}
			$question_types = array(QUESTION_BASIC, QUESTION_AUTH, QUESTION_COUNT, QUESTION_SMS, QUESTION_AUTH_CHAR, QUESTION_SMS_INPUT); //20161129 Update by Linh : include sms question
			$info_questions = $this->T61QuestionHistory->getInfoQuesAnswByScheduleId($schedule_id, $question_types);
			$arr_count_anws_tmp = $this->T61QuestionHistory->getQuesAnswByScheduleId($schedule_id, $question_types);

			$arr_count_anws = array();
			foreach ($arr_count_anws_tmp as $arr_count_anw) {
				$arr_count_anws[$arr_count_anw['T61QuestionHistory']['question_no']] = $arr_count_anw[0]['num_answ'];
			}

			$data_questions = array();
			foreach ($info_questions as $question) {
				$data_questions[$question['T61QuestionHistory']['question_no']]['count_answer'] = $arr_count_anws[$question['T61QuestionHistory']['question_no']];
				$data_questions[$question['T61QuestionHistory']['question_no']]['T61QuestionHistory'] = $question['T61QuestionHistory'];
				$data_questions[$question['T61QuestionHistory']['question_no']]['list_answers'][$question['T62ButtonHistory']['answer_no']] = $question['T62ButtonHistory'];
				$data_questions[$question['T61QuestionHistory']['question_no']]['question_type_txt'] = $this->get_question_type($question['T61QuestionHistory']['question_type']);
				$data_questions[$question['T61QuestionHistory']['question_no']]['question_yuko'] =  $question['T61QuestionHistory']['question_yuko'];
                $data_questions[$question['T61QuestionHistory']['question_no']]['question_type'] = $question['T61QuestionHistory']['question_type'];
                $data_questions[$question['T61QuestionHistory']['question_no']]['sms_content'] = $question['T61QuestionHistory']['sms_content'];
			}

			$arr_answ_title = array(
				"入力値 ＜ 認証項目",
				"入力値 ＝ 認証項目",
				"入力値 ＞ 認証項目"
			);

			$arr_auth_char_answ_title = array(
				"入力値 ＝ 認証項目",
				"入力値 ≠ 認証項目"
			);

			$list_id = $schedule['T20OutSchedule']['list_id'];

			$list_items = $this->T12ListItem->getTitleByListId($list_id);

			$arr_list_items = Array();
			foreach ($list_items as $list_item) {
				if ($list_item['T12ListItem']['item_code'] == 'tel_no') {
					$tel_column = $list_item['T12ListItem']['column'];
				}

				$arr_list_items[$list_item['T12ListItem']['item_name']] = array(
					'item_code' => $list_item['T12ListItem']['item_code'],
					'column' => $list_item['T12ListItem']['column']
				);
			}

			$arr_answer_pos = $this->get_answer_pos($schedule_id);
			foreach ($data_questions as $key => $question) {
				$statistic_ans = array();
				$ques_num = $arr_answer_pos[$question['T61QuestionHistory']['question_no']];

				if ($question['T61QuestionHistory']['question_type'] == QUESTION_AUTH) {
					$data_questions[$key]['list_answers'] = array();
					$data_questions[$key]['count_answer'] = sizeof($arr_answ_title);

					$auth_item_column = $arr_list_items[$question['T61QuestionHistory']['auth_item']]['column'];
					$auth_item_code = $arr_list_items[$question['T61QuestionHistory']['auth_item']]['item_code'];

					$statistic_ans_tmp = $this->T80OutgoingResult->getStatisticAuthQues($schedule_id, $ques_num, $tel_column, $auth_item_column, $auth_item_code);

					for ($i=1; $i<=sizeof($arr_answ_title); $i++) {
						$data_questions[$key]['list_answers'][$i]['answer_content'] = $arr_answ_title[$i-1];
						$data_questions[$key]['list_answers'][$i]['answer_no'] = $i;
						$statistic_ans[$i] = $statistic_ans_tmp[0]['total_choose_' . $i];
					}
				} elseif ($question['T61QuestionHistory']['question_type'] == QUESTION_AUTH_CHAR) {
					$data_questions[$key]['list_answers'] = array();
					$data_questions[$key]['count_answer'] = sizeof($arr_auth_char_answ_title);

					$auth_item_column = $arr_list_items[$question['T61QuestionHistory']['auth_item']]['column'];
					$auth_item_code = $arr_list_items[$question['T61QuestionHistory']['auth_item']]['item_code'];

					$statistic_ans_tmp = $this->T80OutgoingResult->getStatisticAuthCharQues($schedule_id, $ques_num, $tel_column, $auth_item_column, $auth_item_code);

					for ($i=1; $i<=sizeof($arr_auth_char_answ_title); $i++) {
						$data_questions[$key]['list_answers'][$i]['answer_content'] = $arr_auth_char_answ_title[$i-1];
						$data_questions[$key]['list_answers'][$i]['answer_no'] = $i;
						$statistic_ans[$i] = $statistic_ans_tmp[0]['total_choose_' . $i];
					}
				} elseif ($question['T61QuestionHistory']['question_type'] == QUESTION_BASIC) {
					$group_flag = true;
					$statistic_ans_tmp = $this->T80OutgoingResult->getStatisticAnsByQuesNum($schedule_id, $ques_num, $group_flag);
					foreach ($statistic_ans_tmp as $data_ans) {
						//20160407 Add by Thai : #6890 - Fix error statistic answer 51&52 - Begin
						$value = $data_ans['T80OutgoingResult']['answer' . $ques_num];
						if ($value == '*') {
							$value = 51;
						} else if ($value == '#') {
							$value = 52;
						}
						//20160407 Add by Thai : #6890 - Fix error statistic answer 51&52 - End
						$statistic_ans[$value] = $data_ans[0]['total_choose'];
					}
				} elseif ($question['T61QuestionHistory']['question_type'] == QUESTION_COUNT) {
					$statistic_ans_tmp = $this->T80OutgoingResult->getStatisticAnsByQuesNum($schedule_id, $ques_num);
					$statistic_ans[0] = $statistic_ans_tmp[0][0]['total_choose'];
					$data_questions[$key]['ques_count_flag'] = 1;
				}
				$data_questions[$key]['statistic_ans'] = $statistic_ans;
			}

			$call_times = $this->T21OutTime->getByScheduleId($schedule_id);

			$status = $schedule['T20OutSchedule']['status'];
			if($status == STATUS_FINISH){
				$show_btn = true;
			}else $show_btn = false;

			if($status == STATUS_FINISHING){
				$show_btn_finishing = true;
			}else $show_btn_finishing = false;

			if($status == STATUS_CALLING){
				$show_btn_stop = true;
			}else $show_btn_stop = false;

			if($status == STATUS_STOPING){
				$show_btn_stoping = true;
			}else $show_btn_stoping = false;

			if($this->check_status_can_recall($status)){
				$show_btn_recall = true;
			}else $show_btn_recall = false;

			if($status == STATUS_CALLING || $status == STATUS_STOPING || $status == STATUS_FINISHING){
				$show_reload = true;
			}else $show_reload = false;

// 			if($status == STATUS_FINISH || $status == STATUS_STOP_CALL){
// 				$show_btn_dl = true;
// 			}else $show_btn_dl = false;

			if(($status == STATUS_REDIAL_WAIT) || ($status == STATUS_STOP_CALL) || ($status == STATUS_TEMP_FINISH)){
				$show_btn_finish = true;
			}else $show_btn_finish = false;

			if($this->check_status_can_callnow($status)){
				$show_btn_call_now = true;
			}else $show_btn_call_now = false;

			if ($status == STATUS_STOP_CALL || $status == STATUS_TEMP_FINISH) {
				$btn_finish_name = '終了';
				$msg_confirm_finish = SCHEDULE_CONFIRM_FINISH_2;
			}
			if ($status == STATUS_REDIAL_WAIT){
				$btn_finish_name = '中止';
				$msg_confirm_finish = SCHEDULE_CONFIRM_FINISH_3;
			}
			$tel_total = $this->get_tel_total($schedule);
			$num_called = $this->T80OutgoingResult->getNumCalled($schedule_id);
			

			
			$num_connected = $this->T80OutgoingResult->getNumConnect($schedule_id);
			$num_skip = $this->T80OutgoingResult->getNumSkip($schedule_id);

			//20160223 Edit by Thai : #6513 - Update get yuko count - Begin
			$yuko_ques_arr = $this->T61QuestionHistory->getInfoQuesAnswYukoByScheduleId($schedule_id);
			if (sizeof($yuko_ques_arr) > 0) {
				$num_yuko = sizeof($this->get_yuko_logs($schedule_id));
			} else {
				$num_yuko = 0;
			}
			//20160223 Edit by Thai : #6513 - Update get yuko count - End

			$time_end_expect = 0;
			if ($schedule['T20OutSchedule']['status'] == STATUS_CALLING) {
				$log_call_times = $this->T22OutLog->getByScheduleId($schedule_id);

				// 20150531 Add by Giang: #7388 - update time expect when redial - Begin
				$total_redial = $this->get_tel_total_redial($schedule);
				$total_need_call = $tel_total - $num_called + $total_redial;
				// 20150531 Add by Giang: #7388 - update time expect when redial - End

				$seconds = 0;
				foreach ($log_call_times as $log_call_time) {
					if (strtotime($log_call_time['T22OutLog']['time_end'])) {
						$seconds += strtotime($log_call_time['T22OutLog']['time_end']) - strtotime($log_call_time['T22OutLog']['time_start']);
					} else {
						$seconds += time() - strtotime($log_call_time['T22OutLog']['time_start']);
					}
				}

				$minute = $seconds / 60;

				if ($num_called != 0 && $minute != 0) {
					//$time_end_expect = date('Y-m-d H:i:s', time() + ceil(($schedule['T50ListHistory']['tel_total'] - $num_called) / ($num_called / $minute)) * 60);
					$time_end_expect = date('Y-m-d H:i:s', time() + ceil($total_need_call / ($num_called / $minute)) * 60);
				}

				$data_out_times = $this->T21OutTime->getAllNextCallTimeByScheduleId($data['schedule_id']);
				foreach ($data_out_times as $key => $data_out_time) {
					if ($time_end_expect > $data_out_time['T21OutTime']['time_end'] && isset($data_out_times[$key + 1])) {
						$time_end_expect = date('Y-m-d H:i:s', strtotime($time_end_expect) + strtotime($data_out_times[$key + 1]['T21OutTime']['time_start']) - strtotime($data_out_time['T21OutTime']['time_end']));
					}
				}
			}

			$schedule_time_reload = $this->M90PulldownCode->getSelectOption('schedule_time_reload');

			$post_code = $this->ESession->getUserPostCode($this);
			$stop_flag = $this->M04ControllerAction->check_permission($post_code, 'StatusSchedule', 'stop_call');
			$recall_flag = $this->M04ControllerAction->check_permission($post_code, 'StatusSchedule', 'reopen');
			$download_flag = $this->M04ControllerAction->check_permission($post_code, 'StatusSchedule', 'download');
			$finish_flag = $this->M04ControllerAction->check_permission($post_code, 'StatusSchedule', 'finish');
			$call_now_flag = $this->M04ControllerAction->check_permission($post_code, 'StatusSchedule', 'reopen');

			$question_types = array(
//				QUESTION_VOICE,
				QUESTION_BASIC,
				QUESTION_AUTH,
				QUESTION_TEL,
				QUESTION_TRANS, //20160329 Update by Thai : update format tran ques
				QUESTION_RECORD,
				QUESTION_COUNT,
				QUESTION_AUTH_CHAR,
				QUESTION_SMS,
				QUESTION_SMS_INPUT
			);
			$data_headers = $this->get_data_header_schedule($schedule_id, $question_types);
			$headers = $data_headers['headers'];
			$sort_flags = $data_headers['sort_flags'];
//			$have_tran_ques = $this->check_have_tran_ques($schedule_id); //20160329 Delete by Thai : update format tran ques

			$this->set('stop_flag', $stop_flag);
			$this->set('recall_flag', $recall_flag);
			$this->set('download_flag', $download_flag);
			$this->set('finish_flag', $finish_flag);
			$this->set('call_now_flag', $call_now_flag);

			$this->set('schedule_time_reload', $schedule_time_reload);
			$this->set('time_reload', $this->ESession->getTimeReloadStatus($this));
			$this->set('schedule', $schedule);
			$this->set('data_questions', $data_questions);
			$this->set("call_times", $call_times);
			$this->set("time_end_expect", $time_end_expect);
			$this->set('headers', $headers);
			$this->set('sort_flags', $sort_flags);
//			$this->set('have_tran_ques', $have_tran_ques); //20160329 Delete by Thai : update format tran ques

			$this->set('tel_total', $tel_total);
			$this->set('num_called', $num_called);
			$this->set('num_connected', $num_connected);
			$this->set('num_skip', $num_skip);
			$this->set('num_yuko', $num_yuko);

			$this->set("show_btn", $show_btn);
			$this->set("show_btn_finishing", $show_btn_finishing);
			$this->set("show_btn_stop", $show_btn_stop);
			$this->set("show_btn_stoping", $show_btn_stoping);
			$this->set("show_btn_recall", $show_btn_recall);
			$this->set("show_reload", $show_reload);
// 			$this->set("show_btn_dl", $show_btn_dl);
			$this->set("show_btn_finish", $show_btn_finish);
			$this->set("show_btn_call_now", $show_btn_call_now);
			if($status == STATUS_FINISH || $status == STATUS_TEMP_FINISH || $status == STATUS_NO_CALL){
				$info_logs = $this->T22OutLog->getTimeEndByScheduleId($schedule_id);
				$time_end = $info_logs["T22OutLog"]["time_end"];
				$this->set("time_end", $time_end);
				$this->set("show_time_end", true);
			}
			if($status == STATUS_REDIAL_WAIT){
				$info_logs = $this->T22OutLog->getTimeEndByScheduleId($schedule_id);
				$time_end = $info_logs["T22OutLog"]["time_end"];
				$recall_time = $schedule["T20OutSchedule"]["recall_time"];
				$time_redial = date('Y-m-d H:i',strtotime('+'.$recall_time.' minutes',strtotime($time_end)));
				$this->set("time_redial", $time_redial);
				$this->set("show_redial_time", true);
			}
			if($schedule["T20OutSchedule"]["recall"] > 0){
				$recall_num = $schedule["T20OutSchedule"]["recall_flag"];
				$this->set("recall_num", $recall_num);
				$this->set("show_redial_num", true);
			}

			$min_distance_call_time = $this->M99SystemParameter->getByFunctionIdAndParameterId('SCHEDULE', 'MIN_TIME_CALL');
			if (!empty($min_distance_call_time)) {
				$min_distance_call_time = $min_distance_call_time['M99SystemParameter']['parameter_value'];
			} else {
				$min_distance_call_time = 0;
			}
			$this->set('min_distance_call_time', $min_distance_call_time);
			if(isset($btn_finish_name) && isset($msg_confirm_finish)){
				$this->set('btn_finish_name', $btn_finish_name);
				$this->set('msg_confirm_finish', $msg_confirm_finish);
			}
			//20161129 Update by Linh : set sms question data - BEGIN
			$smsData = $this->_getSmsStatusData($schedule_id, $schedule['T20OutSchedule']['template_id']);
            $this->set('smsData', $smsData);
			//20161129 Update by Linh : set sms question data - END
		}else{
			$this->redirect(array('controller' => 'OutSchedule', 'action' => 'index'));
		}
	}

	function get_calltime() {
		$data = $this->data;
		if (empty($data) || !isset($data['schedule_id']) || (!isset($data['limit_datetime']))) {
			echo 'systemerror';
			exit;
		}
		$schedule_id = $data['schedule_id'];
		$limit_datetime = $data['limit_datetime'];

		$data_out_times = $this->T21OutTime->getByScheduleId($schedule_id, false, $limit_datetime);

		$data_out_logs = $this->T22OutLog->getByScheduleId($schedule_id);
		$arr_call_times = array();
		$index = 0;
		foreach ($data_out_logs as $data_out_time) {
			$arr_call_times[] = array(
				'start_date' => $data_out_time['T22OutLog']['time_start'],
				'end_date' => $data_out_time['T22OutLog']['time_end'],
				'section_id' => 1,
				'text' => 'call_times_' . $index,
				'color' => '#A5A5A5',
				'disable_edit' => 1
			);
			$index++;
		}
		foreach ($data_out_times as $data_out_time) {
			$arr_call_times[] = array(
				'start_date' => $data_out_time['T21OutTime']['time_start'],
				'end_date' => $data_out_time['T21OutTime']['time_end'],
				'section_id' => 1,
				'text' => 'call_times_' . $index
			);
			$index++;
		}

		echo json_encode($arr_call_times);
		exit;
	}

	function status_autoupdate() {
		if (isset($this->viewVars['error_login']) && $this->viewVars['error_login']) {
			echo 'error_login';
			exit;
		}
		$this->status();
	}

	function batch_create_schedule($server_id, $server_ip, $local_path, $schedule_id, $template_id, $list_id, $update_flag, $call_flag){
		/*
		$cmd = "gem env";
		exec($cmd, $shell_result, $shell_result_status);
		$this->log($cmd);
		$this->log($shell_result);
		$this->log($shell_result_status);
		exit;
		*/
		//バッチフォルダ作成中
		//追加・複製・更新ボタンを押下
		$message = "success";
		$shell_result_status = 0;
		$schedule_no = substr("000000", strlen($schedule_id)) . $schedule_id;
		//1-フォルダ作成
		$cmd = "/usr/local/bin/ruby ".$local_path."create_folder.rb ".$schedule_no;
		exec($cmd, $shell_result, $shell_result_status);
		if($shell_result_status != 0){
			$message = $shell_result[0];
			$this->log($cmd);
			$this->log($shell_result);
			$this->log($shell_result_status);
			$this->log("BATCHでフォルダ作成：失敗");
		}
		//1-1autopollファイル作成
		if($shell_result_status == 0){
			$cmd = "/usr/local/bin/ruby ".$local_path."create_file_config.rb ".$schedule_no." ".$schedule_id;
			exec($cmd, $shell_result, $shell_result_status);
			if($shell_result_status != 0){
				$message = $shell_result[0];
				$this->log($shell_result);
				$this->log("BATCHでautopollファイル作成：失敗");
			}
		}
		//1-2dialファイル作成
		if($shell_result_status == 0){
			$cmd = "/usr/local/bin/ruby ".$local_path."create_file_dial.rb ".$schedule_no." ".$schedule_id." ".$list_id;
			exec($cmd, $shell_result, $shell_result_status);
			if($shell_result_status != 0){
				$message = $shell_result[0];
				$this->log($shell_result);
				$this->log("BATCHでdialファイル作成：失敗");
			}
		}
		//1-3ansファイル作成
		if($shell_result_status == 0){
			$cmd = "/usr/local/bin/ruby ".$local_path."create_file_ans.rb ".$schedule_no." ".$template_id;
			exec($cmd, $shell_result, $shell_result_status);
			if($shell_result_status != 0){
				$message = $shell_result[0];
				$this->log($shell_result);
				$this->log("BATCHでansファイル作成：失敗");
			}
		}
		//1-4-1pcmファイル作成
		if($shell_result_status == 0){
			$cmd = "/usr/local/bin/ruby ".$local_path."create_file_pcm.rb ".$schedule_no." ".$template_id;
			exec($cmd, $shell_result, $shell_result_status);
			if($shell_result_status != 0){
				$message = $shell_result[0];
				$this->log($shell_result);
				$this->log("BATCHでpcmファイル作成：失敗");
			}
		}
		//1-4-2pcm_varファイル作成
		if($shell_result_status == 0){
			$cmd = "/usr/local/bin/ruby ".$local_path."create_file_pcm_var.rb ".$schedule_no." ".$template_id." ".$list_id;
			exec($cmd, $shell_result, $shell_result_status);
			if($shell_result_status != 0){
				$message = $shell_result[0];
				$this->log($shell_result);
				$this->log("BATCHでpcm_varファイル作成：失敗");
			}
		}
		//1-5splistファイル作成
		if($shell_result_status == 0){
			$cmd = "/usr/local/bin/ruby ".$local_path."create_file_splist.rb ".$schedule_no." ".$template_id." ".$list_id;
			exec($cmd, $shell_result, $shell_result_status);
			if($shell_result_status != 0){
				$message = $shell_result[0];
				$this->log($shell_result);
				$this->log("BATCHでsplistファイル作成：失敗");
			}
		}
		//2-サバ接続して存在したフォルダがあれば削除
		//2-フォルダ転送
		if($shell_result_status == 0){
			if($update_flag) $action = "update";
			else $action = "create";
			$cmd = "/usr/local/bin/ruby ".$local_path."send_folder.rb ".$server_id." ".$schedule_no." ".$action;
			exec($cmd, $shell_result, $shell_result_status);
			$this->log($shell_result);
			$this->log($shell_result_status);
			if($shell_result_status != 0){
				$message = $shell_result[0];
				$this->log($shell_result);
				$this->log("BATCHでフォルダ転送：失敗");
			}
		}
		//3-コールクライアントでのコマンド呼び出し
		if ($shell_result_status == 0) {
			if($call_flag) $action = "call";
			else $action = "create";
			$cmd = "/usr/local/bin/ruby ".$local_path."mega_command.rb ".$server_ip." ".$schedule_no." ".$action;
			exec($cmd, $shell_result, $shell_result_status);
			if($shell_result_status != 0){
				//更新場合ロールバックします
				if($action == "update"){
					$cmd = "/usr/local/bin/ruby ".$local_path."rollback_schedule.rb ".$server_ip." ".$schedule_no;
					exec($cmd, $shell_result, $shell_result_status);
				}
				$message = $shell_result[0];
				$this->log($shell_result_status);
				$this->log($shell_result);
				$this->log("BATCHでコールクライアントでのコマンド呼び出し：失敗");
			}
		}
		if($shell_result_status == 0 && $update_flag){
			$cmd = "/usr/local/bin/ruby ".$local_path."del_schedule_backup.rb ".$server_id." ".$schedule_no;
			exec($cmd, $shell_result, $shell_result_status);
		}
		return $message;
	}

	function batch_recall($server_id, $server_ip, $local_path, $schedule_id, $list_id){
		$schedule_no = substr("000000", strlen($schedule_id)) . $schedule_id;
		//バッチ実行
		$message = "success";
		//1-1autopoll_sys_testファイル作成
		$cmd = "/usr/local/bin/ruby ".$local_path."create_file_config.rb ".$schedule_no." ".$schedule_id;
		exec($cmd, $shell_result, $shell_result_status);
		if($shell_result_status != 0){
			$message = $shell_result[0];
			$this->log($shell_result);
			$this->log("BATCHでautopoll_sys_testファイル作成：失敗");
		}
		//dialファイル作成
		if($shell_result_status == 0){
			$cmd = "/usr/local/bin/ruby ".$local_path."create_file_dial.rb ".$schedule_no." ".$schedule_id." ".$list_id;
			exec($cmd, $shell_result, $shell_result_status);
			//dialファイル作成失敗場合
			if($shell_result_status != 0){
				$message = $shell_result[0];
				$this->log($shell_result);
				$this->log("BATCHでdialファイル作成：失敗");
			}
		}
		//dialファイル転送
		if($shell_result_status == 0){
			$cmd = "/usr/local/bin/ruby ".$local_path."send_folder_recall.rb ".$server_id." ".$schedule_no;
			exec($cmd, $shell_result, $shell_result_status);
			//dialファイル転送失敗場合
			if($shell_result_status != 0){
				$message = $shell_result[0];
				$this->log($shell_result);
				$this->log("BATCHでファイル転送：失敗");
			}
		}
		//実行コマンド
		if($shell_result_status == 0){
			$cmd = "/usr/local/bin/ruby ".$local_path."mega_command.rb ".$server_ip." ".$schedule_no." recall";
			exec($cmd, $shell_result, $shell_result_status);
			if($shell_result_status != 0){
				$cmd = "/usr/local/bin/ruby ".$local_path."rollback_recall.rb ".server_id." ".$schedule_no;
				exec($cmd, $shell_result, $shell_result_status);
				$message = $shell_result[0];
				$this->log($shell_result);
				$this->log("BATCHですぐ発信：失敗");
			}
		}
		if($shell_result_status == 0){
			$cmd = "/usr/local/bin/ruby ".$local_path."del_recall_backup.rb ".$external_number." ".$schedule_id;
			exec($cmd, $shell_result, $shell_result_status);
		}
		return $message;
	}

	function batch_stop($server_ip, $local_path, $schedule_id){
		$schedule_no = substr("000000", strlen($schedule_id)) . $schedule_id;
		//停止コマンド実行
		$cmd = "/usr/local/bin/ruby ".$local_path."mega_command.rb ".$server_ip." ".$schedule_no." stop";
		exec($cmd, $shell_result, $shell_result_status);
		if($shell_result_status != 0){
			$this->log($shell_result);
			$this->log("BATCHで停止コマンド：失敗");
			return "fail";
		}
		return "success";
	}

	function sessionTimeReload(){
		$time_reload = $this->data["time_reload"];
		$this->ESession->setTimeReload($time_reload, $this);
		exit;
	}

	function sessionTimeReloadStatus(){
		$time_reload = $this->data["time_reload"];
		$this->ESession->setTimeReloadStatus($time_reload, $this);
		exit;
	}

	function get_status_name($status) {
		$status_name = array(
			STATUS_NO_CALL => 'まだ発信しない',
			STATUS_CALLING => '発信中',
			STATUS_STOP_CALL => '停止',
			STATUS_FINISH => '終了',
			STATUS_TEMP_FINISH => '一旦終了',
			STATUS_STOPING => '停止中',
			STATUS_FINISHING => '終了中'
		);

		return $status_name[$status];
	}

	function read_file($schedule_id, $tel_no) {
		$schedule_no = substr("000000", strlen($schedule_id)) . $schedule_id;
		$path_base = $this->M99SystemParameter->getByFunctionIdAndParameterId('SCHEDULE', 'PATH_QUESTION_RECORD');
		$path_base = $path_base['M99SystemParameter']['parameter_value'];
		$file_path = $path_base.$schedule_no."/rec/".$tel_no."_1.wav";
		if (file_exists($file_path)) {
			$fp = fopen($file_path, "rb");
			$this->layout = "ajax";
			header('Content-Description: File Transfer');
			header('Content-Type: application/octet-stream');
			header('Content-Disposition: attachment; filename=' . $tel_no.'.wav; charset=SJIS-win');
			header('Content-Transfer-Encoding: binary');
			header('Expires: 0');
			header('Cache-Control: must-revalidate');
			header('Pragma: public');
			header('Content-Length: ' . filesize($file_path));
			echo file_get_contents($file_path);
		}
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
			QUESTION_SMS => 1,
			QUESTION_AUTH_CHAR => array(
				0 => 1,
				1 => 3
			),
			QUESTION_SMS_INPUT => 3
		);
		$questions = $this->T61QuestionHistory->getQuesNumByScheduleId($schedule_id);

		foreach ($questions as $question) {

			$question_no = $question['T61QuestionHistory']['question_no'];
			$question_type = $question['T61QuestionHistory']['question_type'];
			if ($question_type == QUESTION_AUTH || $question_type == QUESTION_AUTH_CHAR || $question_type == QUESTION_TEL) {
				if ($question['T61QuestionHistory']['recheck_flag'] == 1) {
					$recheck_flag = 1;
				} else {
					$recheck_flag = 0;
				}
				$count_column = $arr_count_column[$question_type][$recheck_flag];
			} else {
				$count_column = $arr_count_column[$question_type];
			}

			if ($count_column > 0) {
				$arr_answer_pos[$question_no] = $current_pos;
				$current_pos += $count_column;
			} else if ($question_type == QUESTION_TRANS) {
				$arr_answer_pos[$question_no] = 'trans_call_time';
			} else {
				$arr_answer_pos[$question_no] = NULL;
			}
		}

		return $arr_answer_pos;
	}

	function get_data_header_schedule($schedule_id, $question_types=array(), $contain_question_no=false, $show_sms = false) {
		$questions = $this->T61QuestionHistory->getQuesNumByScheduleId($schedule_id, $question_types);

		$data['get_list_tel_flag'] = false;
		$data['headers'] = array();
		$data['sort_flags'] = array();
		foreach ($questions as $question) {
			$question_no = $contain_question_no ? $question['T61QuestionHistory']['question_no'] : '';
			$question_type = $question['T61QuestionHistory']['question_type'];
			$question_title = $this->get_question_type($question_type);
            if ($question_type == QUESTION_AUTH) {
				$data['get_list_tel_flag'] = true;
				$data['headers'][] = $question_no . $question_title . '入力';
				$data['headers'][] = $question_no . $question_title . '結果';
				$data['sort_flags'][] = 1;
				$data['sort_flags'][] = 2;
				if ($question['T61QuestionHistory']['recheck_flag'] == 1) {
					$data['headers'][] = $question_no . $question_title;
					$data['sort_flags'][] = 1;
				}
			} elseif ($question_type == QUESTION_AUTH_CHAR) {
				$data['get_list_tel_flag'] = true;
				$data['headers'][] = $question_no . $question_title . '入力';
				$data['headers'][] = $question_no . $question_title . '結果';
				$data['sort_flags'][] = 1;
				$data['sort_flags'][] = 3;
				if ($question['T61QuestionHistory']['recheck_flag'] == 1) {
					$data['headers'][] = $question_no . $question_title;
					$data['sort_flags'][] = 1;
				}
			} elseif($question_type == QUESTION_TEL) {
				$data['headers'][] = $question_no . $question_title;
				$data['sort_flags'][] = 0;
				if ($question['T61QuestionHistory']['recheck_flag'] == 1) {
					$data['headers'][] = $question_no . $question_title . 'ボタン';
					$data['sort_flags'][] = 0;
				}
			} elseif ($question_type == QUESTION_RECORD) {
				$data['headers'][] = $question_no . $question_title;
				$data['headers'][] = $question_no . $question_title . '時間';
				$data['sort_flags'][] = 0;
				$data['sort_flags'][] = 0;
			} elseif ($question_type == QUESTION_BASIC) {
				if (!empty($question['T61QuestionHistory']['question_title'])) {
					$data['headers'][] = $question_no . preg_replace('/ |　/', "", $question['T61QuestionHistory']['question_title']);
				} else {
					$data['headers'][] = $question_no . $question_title;
				}
				$data['sort_flags'][] = 1;
				//20160329 Add by Thai : update format tran ques - Begin
			} elseif ($question_type == QUESTION_TRANS) {
				if (!empty($question['T61QuestionHistory']['question_title'])) {
					$data['headers'][] = $question_no . preg_replace('/ |　/', "", $question['T61QuestionHistory']['question_title']);
				} else {
					$data['headers'][] = $question_no . $question_title;
				}
				$data['sort_flags'][] = 1;
				//20160329 Add by Thai : update format tran ques - End
				//20161129 Add by Linh : Add header to download history file - BEGIN
            } elseif ($question_type == QUESTION_SMS){
                if($show_sms){
                    $data['headers'][] = "{$question['T61QuestionHistory']['question_title']}送達状態";
                    $data['headers'][] = "{$question['T61QuestionHistory']['question_title']}送達警告情報";
                    $data['headers'][] = "{$question['T61QuestionHistory']['question_title']}短縮URLキー";
                }
                //20161129 Add by Linh : Add header to download history file - END
            } elseif($question_type == QUESTION_SMS_INPUT) {
                if ($show_sms) {
                $data['headers'][] = "{$question['T61QuestionHistory']['question_title']}先入力";
                $data['headers'][] = "{$question['T61QuestionHistory']['question_title']}先確認ボタン";
                $data['headers'][] = "{$question['T61QuestionHistory']['question_title']}(送達状態)";
                $data['headers'][] = "{$question['T61QuestionHistory']['question_title']}(送達警告情報)";
                $data['headers'][] = "{$question['T61QuestionHistory']['question_title']}(短縮URLキー)";
                }
            } else {
				$data['headers'][] = $question_no . $question_title;
				$data['sort_flags'][] = 0;
			}
		}

		return $data;
	}

	function get_ques_pos_in_header_detail($schedule_id, $question_types=array()) {
		$arr_ques_pos = array();
		$current_pos = 1;
		$arr_count_column = array(
			QUESTION_VOICE => 0,
			QUESTION_BASIC => 1,
			QUESTION_AUTH => array(
				0 => 2,
				1 => 3
			),
			QUESTION_TEL => array(
				0 => 1, // 20160421 Update by Giang - #7029 - fixbug sort, filter question after TEL question
				1 => 2 // 20160421 Update by Giang - #7029 - fixbug sort, filter question after TEL question
			),
			QUESTION_TRANS => 1, //20160329 Update by Thai : update format tran ques
			QUESTION_RECORD => 2,
			QUESTION_COUNT => 1,
			QUESTION_END => 0,
			QUESTION_TIMEOUT => 0,
			QUESTION_AUTH_CHAR => array(
				0 => 2,
				1 => 3
			)
		);
		$questions = $this->T61QuestionHistory->getQuesNumByScheduleId($schedule_id, $question_types);

		foreach ($questions as $question) {
			$question_no = $question['T61QuestionHistory']['question_no'];
			$question_type = $question['T61QuestionHistory']['question_type'];
			if ($question_type == QUESTION_AUTH || $question_type == QUESTION_TEL || $question_type == QUESTION_AUTH_CHAR) {
				if ($question['T61QuestionHistory']['recheck_flag'] == 1) {
					$recheck_flag = 1;
				} else {
					$recheck_flag = 0;
				}
				$count_column = $arr_count_column[$question_type][$recheck_flag];
			} else {
				$count_column = $arr_count_column[$question_type];
			}

			if ($count_column > 0) {
				$arr_ques_pos[$question_no] = $current_pos;
				$current_pos += $count_column;
			} else {
				$arr_ques_pos[$question_no] = NULL;
			}
		}

		return $arr_ques_pos;
	}

	function get_question_type($ques_type) {
		$arr_ques_type = array(
			QUESTION_AUTH => '認証',
			QUESTION_BASIC => '質問',
			QUESTION_COUNT => 'カウント',
			QUESTION_END => '切断',
			QUESTION_RECORD => '録音',
			QUESTION_TEL => '番号入力',
			QUESTION_TRANS => '転送',
			QUESTION_VOICE => '再生',
			QUESTION_TIMEOUT => 'タイムアウト',
			QUESTION_SMS => 'SMS',
			QUESTION_AUTH_CHAR => '文字列認証',
			QUESTION_SMS_INPUT => '番号指定SMS送信'
		);

		return $arr_ques_type[$ques_type];
	}

	function get_yuko_logs($schedule_id) {
		$results = array();

		$schedule_info = $this->T20OutSchedule->getHistoryInfoById($schedule_id);
		$list_id = $schedule_info['T20OutSchedule']['list_id'];
		$arr_answer_pos = $this->get_answer_pos($schedule_id);

		//get format csv from t12
		$list_items = $this->T12ListItem->getTitleByListId($list_id);

		//add header for csv file
		$arr_list_items = Array();
		foreach ($list_items as $list_item) {
			if ($list_item['T12ListItem']['item_code'] == 'tel_no') {
				$tel_column = $list_item['T12ListItem']['column'];
			}

			$arr_list_items[$list_item['T12ListItem']['item_name']] = array(
				'item_code' => $list_item['T12ListItem']['item_code'],
				'column' => $list_item['T12ListItem']['column']
			);
		}

		//20160223 Delete by Thai : #6513 - Update get yuko question - Begin
		/*$question_types = array(
			QUESTION_AUTH,
			QUESTION_BASIC
		);*/
		//20160223 Delete by Thai : #6513 - Update get yuko question - End
		$yuko_ques_arr = array();
		//20160223 Update by Thai : #6513 - Update get yuko question
		$yuko_ques_temp = $this->T61QuestionHistory->getInfoQuesAnswYukoByScheduleId($schedule_id);
		//20160224 Add by Thai : #6513 - Update get yuko question - Begin
		if (sizeof($yuko_ques_temp) == 0) {
			return $results;
		}
		//20160224 Add by Thai : #6513 - Update get yuko question - End
		foreach ($yuko_ques_temp as $ques) {
			$yuko_ques_arr[$ques['T61QuestionHistory']['question_no']]['T61QuestionHistory'] = $ques['T61QuestionHistory'];
			$yuko_ques_arr[$ques['T61QuestionHistory']['question_no']]['T62ButtonHistory'][] = $ques['T62ButtonHistory'];
		}

        $logs = $this->T80OutgoingResult->getAllByScheduleId($schedule_id, false, $tel_column);

		$arr_auth_column = array();
		foreach ($yuko_ques_arr as $question) {
			if ($question['T61QuestionHistory']['question_type'] == QUESTION_AUTH || $question['T61QuestionHistory']['question_type'] == QUESTION_AUTH_CHAR) {
				$arr_auth_column[$question['T61QuestionHistory']['question_no']] = $arr_list_items[$question['T61QuestionHistory']['auth_item']];
			}
		}

		if (sizeof($logs) > 0) {
			foreach ($logs as $log) {
				if ($log['T80OutgoingResult']['status'] != "recover") {
					$yuko_flag = true;
					foreach ($yuko_ques_arr as $question) {
						$yuko_ques_flag = false;

						$question_no = $question['T61QuestionHistory']['question_no'];
						$answer_pos = $arr_answer_pos[$question_no];
						$value = isset($answer_pos) ? $log['T80OutgoingResult']['answer' . $answer_pos] : '';

						if ($question['T61QuestionHistory']['question_type'] == QUESTION_AUTH) {
							$auth_column = $arr_auth_column[$question_no]['column'];
							$auth_value = $log['T51TelHistory'][$auth_column];
							if (isset($auth_value) && $auth_value !== '' && isset($value) && $value !== '') {
								$auth_item_code = $arr_auth_column[$question_no]['item_code'];
								if ($auth_item_code == 'birthday') {
									$auth_value = DateTime::createFromFormat('Y年m月d日', $auth_value)->format('Ymd');
								} else {
									$auth_value = preg_replace('/[^\d]/', '', $auth_value);
								}

								foreach ($question['T62ButtonHistory'] as $button) {
									$yuko_ans = $button['answer_no'];
									if (($yuko_ans == 1 && ($value < $auth_value))
										|| ($yuko_ans == 2 && ($value == $auth_value))
										|| ($yuko_ans == 3 && ($value > $auth_value))
									) {
										$yuko_ques_flag = true;
										break;
									}
								}
							} else {
								$yuko_flag = false;
								break;
							}
						} elseif ($question['T61QuestionHistory']['question_type'] == QUESTION_AUTH_CHAR) {
							$auth_column = $arr_auth_column[$question_no]['column'];
							$auth_value = $log['T51TelHistory'][$auth_column];

							if (isset($auth_value) && $auth_value !== '' && isset($value) && $value !== '') {
								$auth_item_code = $arr_auth_column[$question_no]['item_code'];
								if ($auth_item_code == 'birthday') {
									$auth_value = DateTime::createFromFormat('Y年m月d日', $auth_value)->format('Ymd');
								} else {
									$auth_value = preg_replace('/[^\d]/', '', $auth_value);
								}

								foreach ($question['T62ButtonHistory'] as $button) {
									$yuko_ans = $button['answer_no'];
									if (($yuko_ans == 1 && ($value == $auth_value))
										|| ($yuko_ans == 2 && ($value != $auth_value))
									) {
										$yuko_ques_flag = true;
										break;
									}
								}
							} else {
								$yuko_flag = false;
								break;
							}
						} elseif ($question['T61QuestionHistory']['question_type'] == QUESTION_BASIC) {
							//20160407 Add by Thai : #6890 - Fix error statistic answer 51&52 - Begin
							if ($value == '*') {
								$value = 51;
							} else if ($value == '#') {
								$value = 52;
							}
							//20160407 Add by Thai : #6890 - Fix error statistic answer 51&52 - End
							foreach ($question['T62ButtonHistory'] as $button) {
								$yuko_ans = $button['answer_no'];
								if ($value == $yuko_ans) {
									$yuko_ques_flag = true;
									break;
								}
							}
						}

						if (!$yuko_ques_flag) {
							$yuko_flag = false;
							break;
						}
					}

					if ($yuko_flag) {
						$results[] = $log;
					}
				}
			}
		}

		return $results;
	}

	function check_expired_list_ng($list_ng_id, $schedule_start_date){
		$list_ng = $this->T14OutgoingNgList->getNgListInfoByListNgId($list_ng_id);
		if ($list_ng['T14OutgoingNgList']['expired_date_from']
			&& $list_ng['T14OutgoingNgList']['expired_date_to']
			&& (strtotime($list_ng['T14OutgoingNgList']['expired_date_to']) < strtotime($schedule_start_date)
				|| strtotime($list_ng['T14OutgoingNgList']['expired_date_from']) > strtotime($schedule_start_date))) {
			return false;
		}
		return true;
	}

	function get_tel_total($schedule_info) {
		$tel_ng_arr = Array();
		$tel_num_col = NULL;
		if (!empty($schedule_info['T20OutSchedule']['list_ng_id'])) {
			if ($schedule_info['T20OutSchedule']['status'] == STATUS_NO_CALL) {
				$tel_ng_lists = $this->T15OutgoingNgTel->getTelListByCallListNgId($schedule_info['T20OutSchedule']['list_ng_id']);
				foreach ($tel_ng_lists as $tel_ng) {
					$tel_ng_arr[] = $tel_ng['T15OutgoingNgTel']['tel_no'];
				}
			}else {
				$tel_ng_lists = $this->T55TelNgHistory->getTelNgByScheduleId($schedule_info['T20OutSchedule']['id']);
				foreach ($tel_ng_lists as $tel_ng) {
					$tel_ng_arr[] = $tel_ng['T55TelNgHistory']['tel_no'];
				}
			}
			$t12_list_item = $this->T12ListItem->getTelNumColumn($schedule_info['T20OutSchedule']['list_id']);
			$tel_num_col = $t12_list_item['T12ListItem']['column'];
		}
		if ($schedule_info['T20OutSchedule']['status'] == STATUS_NO_CALL) {
			$tel_total = $this->T11TelList->getTelTotalByListId($schedule_info['T20OutSchedule']['list_id'], $tel_num_col, $tel_ng_arr);
		} else {
			$tel_total = $this->T51TelHistory->getTelTotalByScheduleId($schedule_info['T20OutSchedule']['id'], $tel_num_col, $tel_ng_arr);
		}

		return $tel_total;
	}

	function filter_tel_total_schedules($filter, $arr_schedules, $t21_out_times) {
		$result1 = Array();
		$result2 = Array();
		foreach ($arr_schedules as $key => $schedule_info) {
			if (!$t21_out_times || in_array($schedule_info['T20OutSchedule']['id'], $t21_out_times)) {
				// #14498 【ロボットコール】スケジュール一覧の表示が遅い
				if(isset($schedule_info['T20OutSchedule']['tel_total']) && $schedule_info['T20OutSchedule']['tel_total'] >= 0) {
					$tel_total = $schedule_info['T20OutSchedule']['tel_total'];
				} else {
				$tel_ng_arr = Array();
				$tel_num_col = NULL;
				if (!empty($schedule_info['T20OutSchedule']['list_ng_id'])) {
					if ($schedule_info['T20OutSchedule']['status'] == STATUS_NO_CALL) {
						$tel_ng_lists = $this->T15OutgoingNgTel->getTelListByCallListNgId($schedule_info['T20OutSchedule']['list_ng_id']);
						foreach ($tel_ng_lists as $tel_ng) {
							$tel_ng_arr[] = $tel_ng['T15OutgoingNgTel']['tel_no'];
						}
					}else {
						$tel_ng_lists = $this->T55TelNgHistory->getTelNgByScheduleId($schedule_info['T20OutSchedule']['id']);
						foreach ($tel_ng_lists as $tel_ng) {
							$tel_ng_arr[] = $tel_ng['T55TelNgHistory']['tel_no'];
						}
					}
					$t12_list_item = $this->T12ListItem->getTelNumColumn($schedule_info['T20OutSchedule']['list_id']);
					$tel_num_col = $t12_list_item['T12ListItem']['column'];
				}
				if ($schedule_info['T20OutSchedule']['status'] == STATUS_NO_CALL) {
					$tel_total = $this->T11TelList->getTelTotalByListId($schedule_info['T20OutSchedule']['list_id'], $tel_num_col, $tel_ng_arr);
				} else {
					$tel_total = $this->T51TelHistory->getTelTotalByScheduleId($schedule_info['T20OutSchedule']['id'], $tel_num_col, $tel_ng_arr);
				}
				}

				$schedule_info['tel_total'] = $tel_total;
				if (isset($filter) && (strpos((string)$tel_total, $filter) !== false)) {
					$result1[$key] = $schedule_info;
				} else {
					$result2[$key] = $schedule_info;
				}
			}
		}

		if (!isset($filter)) {
			$result1 = $result2;
		}
		return $result1;
	}

	function sort_tel_total_schedules($sort_flag, $arr_schedules) {
		if ($sort_flag == 'column[7]=0') {
			usort($arr_schedules, function($a, $b) {
			    return $a['tel_total'] - $b['tel_total'];
			});
		} else {
			usort($arr_schedules, function($a, $b) {
			    return $b['tel_total'] - $a['tel_total'];
			});
		}

		return $arr_schedules;
	}

	//20160324 Add by Thai : #6779 - update format when have tran ques - Begin
	function check_have_tran_ques($schedule_id) {
		$question_types = array(
			QUESTION_TRANS,
		);
		$questions = $this->T61QuestionHistory->getQuesNumByScheduleId($schedule_id, $question_types);

		return sizeof($questions) > 0;
	}
	//20160324 Add by Thai : #6779 - update format when have tran ques - End

	// 20150531 Add by Giang: #7388 - update time expect when redial - Begin
	function get_tel_total_redial($schedule_info) {
		$tel_ng_arr = Array();
		$tel_num_col = NULL;
		if (!empty($schedule_info['T20OutSchedule']['list_ng_id'])) {

			$tel_ng_lists = $this->T55TelNgHistory->getTelNgByScheduleId($schedule_info['T20OutSchedule']['id']);
			foreach ($tel_ng_lists as $tel_ng) {
				$tel_ng_arr[] = $tel_ng['T55TelNgHistory']['tel_no'];
			}

			$t12_list_item = $this->T12ListItem->getTelNumColumn($schedule_info['T20OutSchedule']['list_id']);
			$tel_num_col = $t12_list_item['T12ListItem']['column'];
		}

		$tel_total = $this->T52TelRedial->getTelTotalByScheduleId($schedule_info['T20OutSchedule']['id'], $tel_num_col, $tel_ng_arr, $schedule_info['T20OutSchedule']['recall_flag']);

		return $tel_total;
	}
	/* Reorganize sms data from log
	* @param $arrSmsData data is selected by schedule id from T83OutgoingSmsStatus
	* @return array
	*/
	function _organizeSmsData($arrSmsData){
		$rs = array();
		if(empty($arrSmsData))
			return $rs;
		foreach ($arrSmsData as $data) {
			//Create unique key for sms log record
			$idx = $data['T83OutgoingSmsStatus']['log_id'] . "_" .$data['T83OutgoingSmsStatus']['schedule_id'] . "_" . $data['T83OutgoingSmsStatus']['sms_question_no'];
			$rs[$idx] = $data;
		}
		return $rs;
	}
	// 20150531 Add by Giang: #7388 - update time expect when redial - End

    //20161129 Update by Linh : process and get SMS data - BEGIN
    private function _getSmsStatusData($scheduleId, $templateId)
    {
        $smsStatusTitle = array(
            OUTGOING_SMS_STATUS_SUCCESS => '着信済み',
            OUTGOING_SMS_STATUS_OUTSIDE => '圏外',
            OUTGOING_SMS_STATUS_UNKNOWN => '不明',
            OUTGOING_SMS_STATUS_ERROR => 'エラー',
        );
        $smsStatusCount = array();
        $result = array();
        $telTmp = array(); // 送信件数
        $smsStatus = $this->T83OutgoingSmsStatus->getSmsByScheduleId($scheduleId, $templateId);

        foreach ($smsStatus as $sms) {
            $t83 = $sms['T83OutgoingSmsStatus'];
            if($t83['sms_status'] == OUTGOING_SMS_STATUS_NO_SEND){
                continue;
            }
            $t31 = $sms['T61'];
            $telTmp[$t83['sms_question_no']] += 1;
            if (!isset($result[$t83['sms_question_no']])) {
                $result[$t83['sms_question_no']]['sms_content'] = $t31['sms_content'];
            }
            if ($t83['sms_status'] == OUTGOING_SMS_STATUS_SUCCESS) {
                $smsStatusCount[$t83['sms_question_no']][OUTGOING_SMS_STATUS_SUCCESS] += 1;
            } else if ($t83['sms_status'] == OUTGOING_SMS_STATUS_OUTSIDE) {
                $smsStatusCount[$t83['sms_question_no']][OUTGOING_SMS_STATUS_OUTSIDE] += 1;
            } else if ($t83['sms_status'] == OUTGOING_SMS_STATUS_UNKNOWN) {
                $smsStatusCount[$t83['sms_question_no']][OUTGOING_SMS_STATUS_UNKNOWN] += 1;
            } else if ($t83['sms_status'] == OUTGOING_SMS_STATUS_ERROR) {
                $smsStatusCount[$t83['sms_question_no']][OUTGOING_SMS_STATUS_ERROR] += 1;
            }
        }

        foreach ($result as $questionNo => $question) {
            $success = $outside = $unknown = $error = 0;
            $result[$questionNo]['total_tel_send'] = $telTmp[$questionNo];
            $result[$questionNo]['send_complete'] = $smsStatusCount[$questionNo][OUTGOING_SMS_STATUS_SUCCESS];
            $totalSendComplete = $smsStatusCount[$questionNo][OUTGOING_SMS_STATUS_SUCCESS] + $smsStatusCount[$questionNo][OUTGOING_SMS_STATUS_OUTSIDE] + $smsStatusCount[$questionNo][OUTGOING_SMS_STATUS_UNKNOWN] + $smsStatusCount[$questionNo][OUTGOING_SMS_STATUS_ERROR];
            if ($smsStatusCount[$questionNo][OUTGOING_SMS_STATUS_SUCCESS] > 0) {
                $success = round(100 * $smsStatusCount[$questionNo][OUTGOING_SMS_STATUS_SUCCESS] / $totalSendComplete, 1);
                if ($success > 0) {
                    $result[$questionNo]['progress'][$smsStatusTitle[OUTGOING_SMS_STATUS_SUCCESS]] = array('value' => $smsStatusCount[$questionNo][OUTGOING_SMS_STATUS_SUCCESS], 'percent' => $success, 'class' => 'progress-bar-success');
                }
            }
            if ($smsStatusCount[$questionNo][OUTGOING_SMS_STATUS_OUTSIDE] > 0) {
                $outside = round(100 * $smsStatusCount[$questionNo][OUTGOING_SMS_STATUS_OUTSIDE] / $totalSendComplete, 1);
                if ($outside > 0) {
                    $result[$questionNo]['progress'][$smsStatusTitle[OUTGOING_SMS_STATUS_OUTSIDE]] = array('value' => $smsStatusCount[$questionNo][OUTGOING_SMS_STATUS_OUTSIDE], 'percent' => $outside, 'class' => 'progress-bar-warning');
                }
            }
            if ($smsStatusCount[$questionNo][OUTGOING_SMS_STATUS_UNKNOWN] > 0) {
                $unknown = round(100 * $smsStatusCount[$questionNo][OUTGOING_SMS_STATUS_UNKNOWN] / $totalSendComplete, 1);
                if ($unknown > 0) {
                    $result[$questionNo]['progress'][$smsStatusTitle[OUTGOING_SMS_STATUS_UNKNOWN]] = array('value' => $smsStatusCount[$questionNo][OUTGOING_SMS_STATUS_UNKNOWN], 'percent' => $unknown, 'class' => 'progress-bar-info');
                }
            }
            if ($smsStatusCount[$questionNo][OUTGOING_SMS_STATUS_ERROR] > 0) {
                $error = round(100 * $smsStatusCount[$questionNo][OUTGOING_SMS_STATUS_ERROR] / $totalSendComplete, 1);
                if ($error > 0) {
                    $result[$questionNo]['progress'][$smsStatusTitle[OUTGOING_SMS_STATUS_ERROR]] = array('value' => $smsStatusCount[$questionNo][OUTGOING_SMS_STATUS_ERROR], 'percent' => $error, 'class' => 'progress-bar-danger');
                }
            }
        }

        return $result;
    }
    //20161129 Update by Linh : process and get SMS data - END
}
