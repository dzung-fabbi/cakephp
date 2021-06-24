<?php
class UtilComponent extends Component {

	// 接続系(発信・着信が成立し、通話時間があるもの)の結果となるステータスのうち、画面にそのまま表示するステータス
	function getCallResultNoConvertArray(){
		return array("transfer", "transferfull", "transfertimeout", "transferreject");
	}

	// 接続系(発信・着信が成立し、通話時間があるもの)の結果となるステータスのうち、表示上は「transferreject」に変換されるステータス
	function getCallResultConvertTFRejectArray(){
		return array("transfercancel", "transferdisconnect");
	}

	// 接続系(発信・着信が成立し、通話時間があるもの)の結果となるステータスのうち、表示上は「Answer」に変換されるステータス
	function getCallResultConvertAnserArray(){
		return array("connect");
	}

	// 接続なし系の結果となるステータスのうち、画面にそのまま表示するステータス
	function getCallResultNoConnectNoConvertArray(){
		return array("reject");
	}

	// 接続系ステータスのみ
	function getCallResultConnectStatusArray(){
		$work_array = $this->getCallResultConvertAnserArray();
		$work_array = array_merge($work_array, $this->getCallResultNoConvertArray());
		$work_array = array_merge($work_array, $this->getCallResultConvertTFRejectArray());
		return $work_array;
	}

	// ダブルクォーテーションでくくった文字列で戻す
	// return = "transfer","transferfull","transfertimeout","transferreject"
	function getCallResultConnectStatusString(){
		return '"'.implode('","',$this->getCallResultConnectStatusArray()).'"';
	}

	function getCallResultConvertTFRejectString(){
		$work_array = $this->getCallResultConvertTFRejectArray();
		return '"'.implode('","',$work_array).'"';
	}

	function getCallResultNoConvertString(){
		$work_array = $this->getCallResultNoConvertArray();
		$work_array = array_merge($work_array, $this->getCallResultNoConnectNoConvertArray());
		return '"'.implode('","',$work_array).'"';
	}




	function getScheduleSortOrder($column, $start = 1){
		$i = $start;
		$column_master = Array(
			'column[' . $i . ']=0' => Array(Array('T20OutSchedule.schedule_no ASC'), '1', '0'),
			'column[' . $i++ . ']=1' => Array(Array('T20OutSchedule.schedule_no DESC'), '1', '1'),
			'column[' . $i . ']=0' => Array(Array('T20OutSchedule.schedule_name ASC'), '2', '0'),
			'column[' . $i++ . ']=1' => Array(Array('T20OutSchedule.schedule_name DESC'), '2', '1'),
			'column[' . $i . ']=0' => Array(Array('T21OutTime.time_start ASC'), '3', '0'),
			'column[' . $i++ . ']=1' => Array(Array('T21OutTime.time_start DESC'), '3', '1'),
			'column[' . $i . ']=0' => Array(Array('SUBSTR(MIN(T21OutTime.time_start), 12) ASC', 'SUBSTR(MIN(T21OutTime.time_end), 12) ASC'), '4', '0'),
			'column[' . $i++ . ']=1' => Array(Array('SUBSTR(MAX(T21OutTime.time_start), 12) DESC', 'SUBSTR(MAX(T21OutTime.time_end), 12) DESC'), '4', '1'),
			'column[' . $i . ']=0' => Array(Array('IF(T20OutSchedule.status = "' . STATUS_FINISH . '", T60TemplateHistory.template_name, T30Template.template_name) ASC'), '5', '0'),
			'column[' . $i++ . ']=1' => Array(Array('IF(T20OutSchedule.status = "' . STATUS_FINISH . '", T60TemplateHistory.template_name, T30Template.template_name) DESC'), '5', '1'),
			'column[' . $i . ']=0' => Array(Array('IF(T20OutSchedule.status = "' . STATUS_FINISH . '", T50ListHistory.list_name, T10CallList.list_name) ASC'), '6', '0'),
			'column[' . $i++ . ']=1' => Array(Array('IF(T20OutSchedule.status = "' . STATUS_FINISH . '", T50ListHistory.list_name, T10CallList.list_name) DESC'), '6', '1'),
			'column[' . $i . ']=0' => Array(Array('CAST(IF(T20OutSchedule.status = "' . STATUS_FINISH . '", T50ListHistory.tel_total, T10CallList.tel_total) as UNSIGNED) ASC'), '7', '0'),
			'column[' . $i++ . ']=1' => Array(Array('CAST(IF(T20OutSchedule.status = "' . STATUS_FINISH . '", T50ListHistory.tel_total, T10CallList.tel_total) as UNSIGNED) DESC'), '7', '1'),
			'column[' . $i . ']=0' => Array(Array('T20OutSchedule.called_total ASC'), '8', '0'),
			'column[' . $i++ . ']=1' => Array(Array('T20OutSchedule.called_total DESC'), '8', '1'),
			'column[' . $i . ']=0' => Array(Array('T20OutSchedule.created ASC'), '9', '0'),
			'column[' . $i++ . ']=1' => Array(Array('T20OutSchedule.created DESC'), '9', '1'),
			'column[' . $i . ']=0' => Array(Array('M05User.user_name ASC'), '10', '0'),
			'column[' . $i++ . ']=1' => Array(Array('M05User.user_name DESC'), '10', '1'),
			'column[' . $start . ']=0&column[' . $start++ . ']=0' => Array(Array('T20OutSchedule.schedule_name ASC'), '2', '0'),
			'column[' . $start . ']=1&column[' . $start++ . ']=1' => Array(Array('T20OutSchedule.schedule_name DESC'), '2', '1'),
		);

		return $column_master[$column];
	}

	// Outnoの詳細画面で表示する項目を取得する。
	function getScheduleDetailSortOrder($column, $referents, $arr_pos_ques_basic, $arr_pos_ques_auth){
		//20160324 Edit by Thai : #6779 - update sort when have tran ques - Begin
		$i = 0;
		$work_sql = 'IF(T80OutgoingResult.status IN ('. $this->getCallResultConnectStatusString() .'), (UNIX_TIMESTAMP(T80OutgoingResult.cut_datetime) - UNIX_TIMESTAMP(T80OutgoingResult.connect_datetime)), 0)';

		$column_master = Array(
			// 発信日時がソート指定だった時
			'column[' . $i . ']=0' => Array(Array('T80OutgoingResult.call_datetime ASC'), $i, '0'),
			'column[' . $i . ']=1' => Array(Array('T80OutgoingResult.call_datetime DESC'), $i++, '1'),
			// 発信先（電話番号）がソート指定だった時
			'column[' . $i . ']=0' => Array(Array('T80OutgoingResult.tel_no ASC'), $i, '0'),
			'column[' . $i . ']=1' => Array(Array('T80OutgoingResult.tel_no DESC'), $i++, '1'),
			//20160222 Edit by Thai : #6464 - update sort by status result - Begin
			//'column[3]=0' => Array(Array('IF(T80OutgoingResult.status = "timeout", "NOANSWER", IF(T80OutgoingResult.status IN ("reject", "transfer", "transfertimeout", "transferfull"), UPPER(T80OutgoingResult.status), "ANSWER")) ASC'), '3', '0'),
			//'column[3]=1' => Array(Array('IF(T80OutgoingResult.status = "timeout", "NOANSWER", IF(T80OutgoingResult.status IN ("reject", "transfer", "transfertimeout", "transferfull"), UPPER(T80OutgoingResult.status), "ANSWER")) DESC'), '3', '1'),
			//20160222 Edit by Thai : #6464 - update sort by status result - End

			// 接続時間がソート指定だった時
			// 「接続」となるコール結果は全てgetCallResultConnectStatusString()に書くこと。
			'column[' . $i . ']=0' => Array(Array($work_sql . ' ASC'), $i, '0'),
			'column[' . $i . ']=1' => Array(Array($work_sql . '  DESC'), $i++, '1'),
		);
		//20160324 Edit by Thai : #6779 - update sort when have tran ques - End

		//20160324 Add by Thai : #6779 - update sort when have tran ques - Begin
		//20160329 Delete by Thai : update format tran ques - Begin
/*		if ($have_tran_ques) {
			$column_master['column[' . $i . ']=0'] = Array(Array('(UNIX_TIMESTAMP(T80OutgoingResult.trans_cut_datetime) - UNIX_TIMESTAMP(T80OutgoingResult.trans_connect_datetime)) ASC'), $i, '0');
			$column_master['column[' . $i . ']=1'] = Array(Array('(UNIX_TIMESTAMP(T80OutgoingResult.trans_cut_datetime) - UNIX_TIMESTAMP(T80OutgoingResult.trans_connect_datetime)) DESC'), $i++, '1');
		}*/
		//20160329 Delete by Thai : update format tran ques - End


		// ステータスがソート指定だった時。
		// t80.statusを画面表示の値として変換し、ソートする。
		// 画面上にTRANSFERREJECTと変換して表示するt80.statusはgetCallResultConvertTFRejectStringに、
		// 画面上にそのままの値として表示するt80.statusはgetCallResultNoConvertStringに追加する事。
		$work_sql = 'IF(T80OutgoingResult.status = "connect", "ANSWER", IF(T80OutgoingResult.status = "recover", "SKIP", IF(T80OutgoingResult.status in (' . $this->getCallResultConvertTFRejectString(). '), "TRANSFERREJECT", IF(T80OutgoingResult.status IN (' . $this->getCallResultNoConvertString() . '), UPPER(T80OutgoingResult.status), "NOANSWER"))))';
		$column_master['column[' . $i . ']=0'] = Array(Array($work_sql . ' ASC'), $i, '0');
		$column_master['column[' . $i . ']=1'] = Array(Array($work_sql . ' DESC'), $i, '1');


		if (isset($column_master[$column])) {
			return $column_master[$column];
		} else {
			preg_match_all('/[0-9]+/', $column, $options);
			$col = (int)$options[0][0];
			$type = (int)$options[0][1];

			$pos_in_header_ques = $col - sizeof($column_master)/2 + 1;
			if(isset($arr_pos_ques_basic[$pos_in_header_ques])) {
				$question_no = $arr_pos_ques_basic[$pos_in_header_ques];
				$alias = 'T62ButtonHistory' . $question_no;
				return Array(Array('IF(' . $alias . '.answer_content <> "", ' . $alias . '.answer_content, T80OutgoingResult.answer' . $referents[$pos_in_header_ques] . ') ' . ($type==0 ? 'ASC' : 'DESC'), $pos_in_header_ques), $col, $type);
			} elseif (isset($arr_pos_ques_auth[$pos_in_header_ques])) {
				if (isset($arr_pos_ques_auth[$pos_in_header_ques]['recheck_button_next'])) {
					$recheck_button_next = $arr_pos_ques_auth[$pos_in_header_ques]['recheck_button_next'];

					$str_sort = 'IF(' . $recheck_button_next
						. ' IN (T80OutgoingResult.answer' . $referents[$pos_in_header_ques]
						. ', T80OutgoingResult.answer' . ($referents[$pos_in_header_ques] + 1)
						. ', T80OutgoingResult.answer' . ($referents[$pos_in_header_ques] + 2) . '), '
						. $recheck_button_next
						. ', COALESCE(T80OutgoingResult.answer' . $referents[$pos_in_header_ques]
						. ', T80OutgoingResult.answer' . ($referents[$pos_in_header_ques] + 1)
						. ', T80OutgoingResult.answer' . ($referents[$pos_in_header_ques] + 2) . ')) ';

					return Array(Array($str_sort . ($type == 0 ? 'ASC' : 'DESC')), $col, $type);
				} elseif (isset($arr_pos_ques_auth[$pos_in_header_ques]['auth_item_column'])) {
					$auth_item_code = $arr_pos_ques_auth[$pos_in_header_ques]['auth_item_code'];
					$auth_item_column = $arr_pos_ques_auth[$pos_in_header_ques]['auth_item_column'];
					if ($auth_item_code == 'birthday') {
						$value_answer = 'CAST(T80OutgoingResult.answer' . $referents[$pos_in_header_ques] . ' AS UNSIGNED)';
						$value_auth = 'CAST(STR_TO_DATE(T51TelHistory.' . $auth_item_column . ', "%Y年%m月%d日") AS UNSIGNED)';
					} else {
						$value_answer = 'CAST(T80OutgoingResult.answer' . $referents[$pos_in_header_ques] . ' AS UNSIGNED)';
						$value_auth = 'CAST(T51TelHistory.' . $auth_item_column . ' AS UNSIGNED)';
					}

					$str_sort = 'IF(' . $value_answer . ' <> "" AND ' . $value_auth . ' <> "", IF(' . $value_answer . ' < ' . $value_auth . ', "<", IF(' . $value_answer . ' = ' . $value_auth . ', "=", ">")), "") ';
					return Array(Array($str_sort . ($type == 0 ? 'ASC' : 'DESC')), $col, $type);
				}
			} else {
				//20160329 Update by Thai : update format tran ques - Begin
				if ($referents[$pos_in_header_ques] == 'trans_call_time') {
					return Array(Array('(UNIX_TIMESTAMP(T80OutgoingResult.trans_cut_datetime) - UNIX_TIMESTAMP(T80OutgoingResult.trans_connect_datetime)) ' . ($type==0 ? 'ASC' : 'DESC')), $col, $type);
				} else {
					return Array(Array('CAST(T80OutgoingResult.answer' . $referents[$pos_in_header_ques] . ' AS UNSIGNED) ' . ($type==0 ? 'ASC' : 'DESC')), $col, $type);
				}
				//20160329 Update by Thai : update format tran ques - End
			}
		}
	}

	// 20160413 Add by Giang - #6906 Inbound history screen - Begin
	function getInboundDetailSortOrder($column, $referents, $arr_pos_ques_basic, $arr_pos_ques_auth){
		$i = 0;
		$work_sql = 'IF(T81IncomingResult.status NOT IN ("timeout", "reject"), (UNIX_TIMESTAMP(T81IncomingResult.cut_datetime) - UNIX_TIMESTAMP(T81IncomingResult.connect_datetime)), 0)';


		$column_master = Array(
			'column[' . $i . ']=0' => Array(Array('T81IncomingResult.call_datetime ASC'), $i, '0'),
			'column[' . $i . ']=1' => Array(Array('T81IncomingResult.call_datetime DESC'), $i++, '1'),
			'column[' . $i . ']=0' => Array(Array('T81IncomingResult.tel_no ASC'), $i, '0'),
			'column[' . $i . ']=1' => Array(Array('T81IncomingResult.tel_no DESC'), $i++, '1'),
			'column[' . $i . ']=0' => Array(Array($work_sql . ' ASC'), $i, '0'),
			'column[' . $i . ']=1' => Array(Array($work_sql . ' DESC'), $i++, '1'),
		);

		$work_sql = 'IF(T81IncomingResult.status = "timeout", "NOANSWER", IF(T81IncomingResult.status in (' . $this->getCallResultConvertTFRejectString(). '), "TRANSFERREJECT", IF(T81IncomingResult.status IN (' . $this->getCallResultNoConvertString() . '), UPPER(T81IncomingResult.status), "ANSWER")))';

		$column_master['column[' . $i . ']=0'] = Array(Array($work_sql .' ASC'), $i, '0');
		$column_master['column[' . $i . ']=1'] = Array(Array($work_sql .' DESC'), $i, '1');

		if (isset($column_master[$column])) {
			return $column_master[$column];
		} else {
			preg_match_all('/[0-9]+/', $column, $options);
			$col = (int)$options[0][0];
			$type = (int)$options[0][1];

			$pos_in_header_ques = $col - sizeof($column_master)/2 + 1;
			if(isset($arr_pos_ques_basic[$pos_in_header_ques])) {
				$question_no = $arr_pos_ques_basic[$pos_in_header_ques];
				$alias = 'T65InboundButtonHistory' . $question_no;
				return Array(Array('IF(' . $alias . '.answer_content <> "", ' . $alias . '.answer_content, T81IncomingResult.answer' . $referents[$pos_in_header_ques] . ') ' . ($type==0 ? 'ASC' : 'DESC'), $pos_in_header_ques), $col, $type);
			} elseif (isset($arr_pos_ques_auth[$pos_in_header_ques])) {
				if (isset($arr_pos_ques_auth[$pos_in_header_ques]['recheck_button_next'])) {
					$recheck_button_next = $arr_pos_ques_auth[$pos_in_header_ques]['recheck_button_next'];

					$str_sort = 'IF(' . $recheck_button_next
						. ' IN (T81IncomingResult.answer' . $referents[$pos_in_header_ques]
						. ', T81IncomingResult.answer' . ($referents[$pos_in_header_ques] + 1)
						. ', T81IncomingResult.answer' . ($referents[$pos_in_header_ques] + 2) . '), '
						. $recheck_button_next
						. ', COALESCE(T81IncomingResult.answer' . $referents[$pos_in_header_ques]
						. ', T81IncomingResult.answer' . ($referents[$pos_in_header_ques] + 1)
						. ', T81IncomingResult.answer' . ($referents[$pos_in_header_ques] + 2) . ')) ';

					return Array(Array($str_sort . ($type == 0 ? 'ASC' : 'DESC')), $col, $type);
				} elseif (isset($arr_pos_ques_auth[$pos_in_header_ques]['auth_item_column'])) {
					$auth_item_code = $arr_pos_ques_auth[$pos_in_header_ques]['auth_item_code'];
					$auth_item_column = $arr_pos_ques_auth[$pos_in_header_ques]['auth_item_column'];
					if ($auth_item_code == 'birthday') {
						$value_answer = 'CAST(T81IncomingResult.answer' . $referents[$pos_in_header_ques] . ' AS UNSIGNED)';
						$value_auth = 'CAST(STR_TO_DATE(T57InboundTelHistory.' . $auth_item_column . ', "%Y年%m月%d日") AS UNSIGNED)';
					} else {
						$value_answer = 'CAST(T81IncomingResult.answer' . $referents[$pos_in_header_ques] . ' AS UNSIGNED)';
						$value_auth = 'CAST(T57InboundTelHistory.' . $auth_item_column . ' AS UNSIGNED)';
					}

					$str_sort = 'IF(' . $value_answer . ' <> "" AND ' . $value_auth . ' <> "", IF(' . $value_answer . ' < ' . $value_auth . ', "<", IF(' . $value_answer . ' = ' . $value_auth . ', "=", ">")), "") ';
					return Array(Array($str_sort . ($type == 0 ? 'ASC' : 'DESC')), $col, $type);
				}
			} elseif ($referents[$pos_in_header_ques] == 'fax_status') {
				return Array(Array('T82BukkenFaxStatus'.$referents['fax_ques_no_'.$pos_in_header_ques].'.fax_status ' . ($type==0 ? 'ASC' : 'DESC')), $col, $type);
			} elseif($referents[$pos_in_header_ques] == 'inbound_sms_status'){
				return Array(Array('T86InboundSmsStatus'.$referents['inbound_sms_'.$pos_in_header_ques].'.sms_status ' . ($type==0 ? 'ASC' : 'DESC')), $col, $type);
			} elseif($referents[$pos_in_header_ques] == 'inbound_sms_input_status'){
				return Array(Array('T86InboundSmsStatus'.$referents['inbound_sms_input_'.$pos_in_header_ques].'.sms_status ' . ($type==0 ? 'ASC' : 'DESC')), $col, $type);
			} else {
				if ($referents[$pos_in_header_ques] == 'trans_call_time') {
					return Array(Array('(UNIX_TIMESTAMP(T81IncomingResult.trans_cut_datetime) - UNIX_TIMESTAMP(T81IncomingResult.trans_connect_datetime)) ' . ($type==0 ? 'ASC' : 'DESC')), $col, $type);
				} else {
					return Array(Array('CAST(T81IncomingResult.answer' . $referents[$pos_in_header_ques] . ' AS UNSIGNED) ' . ($type==0 ? 'ASC' : 'DESC')), $col, $type);
				}
			}
		}
	}
	// 20160413 Add by Giang - #6906 Inbound history screen - End

	function getOutTimeSortOrder($column){
		$column_master = Array(
			'column[4]=0' => Array(Array('SUBSTR(T21OutTime.time_start, 12) ASC', 'SUBSTR(T21OutTime.time_end, 12) ASC'), '4', '0'),
			'column[4]=1' => Array(Array('SUBSTR(T21OutTime.time_start, 12) DESC', 'SUBSTR(T21OutTime.time_end, 12) DESC'), '4', '1'),
		);

		return $column_master[$column];
	}

	function getScriptSortOrder($column){
		$column_master = Array(
			'column[0]=0' => Array(Array('T30Template.id ASC'), '0', '0'),
			'column[0]=1' => Array(Array('T30Template.id DESC'), '0', '1'),
			'column[1]=0' => Array(Array('T30Template.script_name ASC'), '1', '0'),
			'column[1]=1' => Array(Array('T30Template.script_name DESC'), '1', '1'),
			'column[2]=0' => Array(Array('T30Template.question_total ASC'), '2', '0'),
			'column[2]=1' => Array(Array('T30Template.question_total DESC'), '2', '1'),
			'column[3]=0' => Array(Array('T30Template.used_date ASC'), '3', '0'),
			'column[3]=1' => Array(Array('T30Template.used_date DESC'), '3', '1'),
		);

		return $column_master[$column];
	}

	function getListSortOrder($column, $start = 1){
		$i = $start;
		$column_master = Array(
			'column[' . $i . ']=0' => Array(Array('T10CallList.id ASC'), '1', '0'),
			'column[' . $i++ . ']=1' => Array(Array('T10CallList.id DESC'), '1', '1'),
			'column[' . $i . ']=0' => Array(Array('T10CallList.list_test_flag DESC, T10CallList.list_name ASC'), '2', '0'),
			'column[' . $i++ . ']=1' => Array(Array('T10CallList.list_test_flag ASC, T10CallList.list_name DESC'), '2', '1'),
			'column[' . $i . ']=0' => Array(Array('T10CallList.tel_total ASC'), '3', '0'),
			'column[' . $i++ . ']=1' => Array(Array('T10CallList.tel_total DESC'), '3', '1'),
			'column[' . $i . ']=0' => Array(Array('T10CallList.created ASC'), '4', '0'),
			'column[' . $i++ . ']=1' => Array(Array('T10CallList.created DESC'), '4', '1'),
			'column[' . $i . ']=0' => Array(Array('T10CallList.entry_user ASC'), '5', '0'),
			'column[' . $i++ . ']=1' => Array(Array('T10CallList.entry_user DESC'), '5', '1'),
			'column[' . $start . ']=0&column[' . $start + 1 . ']=0' => Array(Array('T10CallList.list_test_flag DESC, T10CallList.list_name ASC'), '2', '0'),
			'column[' . $start . ']=0&column[' . $start + 1 . ']=1' => Array(Array('T10CallList.list_test_flag ASC, T10CallList.list_name DESC'), '2', '1'),
		);

		return $column_master[$column];
	}

	function getTelListSortOrder($column, $t12ListItems, $start = 1){
		$column_master = Array(
			'column[' . $start . ']=0' => Array(Array('T11TelList.tel_no ASC'), '1', '0'),
			'column[' . $start ++ . ']=1' => Array(Array('T11TelList.tel_no DESC'), '1', '1'),
		);
		foreach ($t12ListItems as $key => $value) {
			if ($start == 2)
				$col = $key + 2;
			else
				$col = $key + 1;
			$column_master["column[$col]=0"] = Array(Array('T11TelList.'.$value['T12ListItem']['column'].' ASC'), $col, '0');
			$column_master["column[$col]=1"] = Array(Array('T11TelList.'.$value['T12ListItem']['column'].' DESC'), $col, '1');
		}

		return $column_master[$column];
	}

	function getTemplateSortOrder($column, $start = 1){
		$column_master = Array(
			'column[' . $start . ']=0' => Array(Array('T30Template.template_no ASC'), '1', '0'),
			'column[' . $start++ . ']=1' => Array(Array('T30Template.template_no DESC'), '1', '1'),
			'column[' . $start . ']=0' => Array(Array('T30Template.template_name ASC'), '2', '0'),
			'column[' . $start++ . ']=1' => Array(Array('T30Template.template_name DESC'), '2', '1'),
			'column[' . $start . ']=0' => Array(Array('T30Template.description ASC'), '3', '0'),
			'column[' . $start++ . ']=1' => Array(Array('T30Template.description DESC'), '3', '1'),
			'column[' . $start . ']=0' => Array(Array('T30Template.created ASC'), '4', '0'),
			'column[' . $start++ . ']=1' => Array(Array('T30Template.created DESC'), '4', '1'),
			'column[' . $start . ']=0' => Array(Array('T30Template.entry_user ASC'), '5', '0'),
			'column[' . $start++ . ']=1' => Array(Array('T30Template.entry_user DESC'), '5', '1'),
		);

		return $column_master[$column];
	}

	function getUserSortOrder($column, $col_start = 1){
/*		$column_master = Array(
			'column[' . $col_start . ']=0' => Array(Array('M05User.user_no ASC'), $col_start, '0'),
			'column[' . $col_start . ']=1' => Array(Array('M05User.user_no DESC'), $col_start, '1'),
			'column[' . ($col_start + 1) . ']=0' => Array(Array('M02Company.company_name ASC'), $col_start + 1, '0'),
			'column[' . ($col_start + 1) . ']=1' => Array(Array('M02Company.company_name DESC'), $col_start + 1, '1'),
			'column[' . ($col_start + 2) . ']=0' => Array(Array('M05User.user_id ASC'), $col_start + 2, '0'),
			'column[' . ($col_start + 2) . ']=1' => Array(Array('M05User.user_id DESC'), $col_start + 2, '1'),
			'column[' . ($col_start + 3) . ']=0' => Array(Array('M05User.user_name ASC'), $col_start + 3, '0'),
			'column[' . ($col_start + 3) . ']=1' => Array(Array('M05User.user_name DESC'), $col_start + 3, '1'),
			'column[' . ($col_start + 4) .']=0' => Array(Array('M03Auth.post_name ASC'), $col_start + 4, '0'),
			'column[' . ($col_start + 4) .']=1' => Array(Array('M03Auth.post_name DESC'), $col_start + 4, '1'),
			'column[' . ($col_start + 5) . ']=0' => Array(Array('M05User.created ASC'), $col_start + 5, '0'),
			'column[' . ($col_start + 5) . ']=1' => Array(Array('M05User.created DESC'), $col_start + 5, '1'),
		);*/
		$column_master = Array(
			'column[' . $col_start . ']=0' => Array(Array('M02Company.company_name ASC'), $col_start, '0'),
			'column[' . $col_start . ']=1' => Array(Array('M02Company.company_name DESC'), $col_start, '1'),
			'column[' . ($col_start + 1) . ']=0' => Array(Array('M05User.user_id ASC'), $col_start + 1, '0'),
			'column[' . ($col_start + 1) . ']=1' => Array(Array('M05User.user_id DESC'), $col_start + 1, '1'),
			'column[' . ($col_start + 2) . ']=0' => Array(Array('M05User.user_name ASC'), $col_start + 2, '0'),
			'column[' . ($col_start + 2) . ']=1' => Array(Array('M05User.user_name DESC'), $col_start + 2, '1'),
			'column[' . ($col_start + 3) . ']=0' => Array(Array('M03Auth.post_name ASC'), $col_start + 3, '0'),
			'column[' . ($col_start + 3) . ']=1' => Array(Array('M03Auth.post_name DESC'), $col_start + 3, '1'),
			'column[' . ($col_start + 4) .']=0' => Array(Array('M05User.created ASC'), $col_start + 4, '0'),
			'column[' . ($col_start + 4) .']=1' => Array(Array('M05User.created DESC'), $col_start + 4, '1'),
		);

		return $column_master[$column];
	}

	function getAccountSortOrder($column, $col_start = 1){
		$column_master = Array(
			'column[' . $col_start . ']=0' => Array(Array('M02Company.id ASC'), $col_start, '0'),
			'column[' . $col_start . ']=1' => Array(Array('M02Company.id DESC'), $col_start, '1'),
			'column[' . ($col_start + 1) . ']=0' => Array(Array('M02Company.company_code ASC'), $col_start + 1, '0'),
			'column[' . ($col_start + 1) . ']=1' => Array(Array('M02Company.company_code DESC'), $col_start + 1, '1'),
			'column[' . ($col_start + 2) . ']=0' => Array(Array('M02Company.company_name ASC'), $col_start + 2, '0'),
			'column[' . ($col_start + 2) . ']=1' => Array(Array('M02Company.company_name DESC'), $col_start + 2, '1'),
			'column[' . ($col_start + 3) . ']=0' => Array(Array('0.tel_num ASC'), $col_start + 3, '0'),
			'column[' . ($col_start + 3) . ']=1' => Array(Array('0.tel_num DESC'), $col_start + 3, '1'),
			'column[' . ($col_start + 4) . ']=0' => Array(Array('M90PulldownCode.item_name ASC'), $col_start + 4, '0'),
			'column[' . ($col_start + 4) . ']=1' => Array(Array('M90PulldownCode.item_name DESC'), $col_start + 4, '1'),
			'column[' . ($col_start + 5) . ']=0' => Array(Array('M02Company.max_redial ASC'), $col_start + 5, '0'),
			'column[' . ($col_start + 5) . ']=1' => Array(Array('M02Company.max_redial DESC'), $col_start + 5, '1'),
			'column[' . ($col_start + 6) . ']=0' => Array(Array('M02Company.created ASC'), $col_start + 6, '0'),
			'column[' . ($col_start + 6) . ']=1' => Array(Array('M02Company.created DESC'), $col_start + 6, '1'),
			'column[' . ($col_start + 7) . ']=0' => Array(Array('M02Company.entry_user ASC'), $col_start + 7, '0'),
			'column[' . ($col_start + 7) . ']=1' => Array(Array('M02Company.entry_user DESC'), $col_start + 7, '1'),
		);

		return $column_master[$column];
	}

	/* 20160226 Add by Giang : #6532 - call list ng screen - start */
	function getListNgSortOrder($column, $start = 1){
		$i = $start;
		$column_master = Array(
			'column[' . $i . ']=0' => Array(Array('T14OutgoingNgList.list_ng_no ASC'), $start, '0'),
			'column[' . $i++ . ']=1' => Array(Array('T14OutgoingNgList.list_ng_no DESC'), $start, '1'),
			'column[' . $i . ']=0' => Array(Array('T14OutgoingNgList.list_name ASC'), $start + 1, '0'),
			'column[' . $i++ . ']=1' => Array(Array('T14OutgoingNgList.list_name DESC'), $start + 1, '1'),
			'column[' . $i . ']=0' => Array(Array('T14OutgoingNgList.total ASC'), $start + 2, '0'),
			'column[' . $i++ . ']=1' => Array(Array('T14OutgoingNgList.total DESC'), $start + 2, '1'),
			'column[' . $i . ']=0' => Array(Array('T14OutgoingNgList.expired_date_from ASC'), $start + 3, '0'),
			'column[' . $i++ . ']=1' => Array(Array('T14OutgoingNgList.expired_date_from DESC'), $start + 3, '1'),
			'column[' . $i . ']=0' => Array(Array('T14OutgoingNgList.created ASC'), $start + 4, '0'),
			'column[' . $i++ . ']=1' => Array(Array('T14OutgoingNgList.created DESC'), $start + 4, '1'),
			'column[' . $i . ']=0' => Array(Array('T14OutgoingNgList.entry_user ASC'), $start + 5, '0'),
			'column[' . $i++ . ']=1' => Array(Array('T14OutgoingNgList.entry_user DESC'), $start + 5, '1'),
		);

		return $column_master[$column];
	}
	/* 20160226 Add by Giang : #6532 - call list ng screen - end */

	/* 20160229 Add by Giang : #6538 - call list ng detail screen - start */
	function getTelListNgSortOrder($column, $start = 1){
		$i = $start;
		$column_master = Array(
			'column[' . $i . ']=0' => Array(Array('T15OutgoingNgTel.no ASC'), $start, '0'),
			'column[' . $i ++ . ']=1' => Array(Array('T15OutgoingNgTel.no DESC'), $start, '1'),
			'column[' . $i . ']=0' => Array(Array('T15OutgoingNgTel.tel_no ASC'), $start + 1, '0'),
			'column[' . $i ++ . ']=1' => Array(Array('T15OutgoingNgTel.tel_no DESC'), $start + 1, '1'),
			'column[' . $i . ']=0' => Array(Array('T15OutgoingNgTel.memo ASC'), $start + 2, '0'),
			'column[' . $i ++ . ']=1' => Array(Array('T15OutgoingNgTel.memo DESC'), $start + 2, '1'),
		);

		return $column_master[$column];
	}
	/* 20160229 Add by Giang : #6538 - call list ng detail screen - end */

	/* 20160314 Add by Giang : #6711 - Inbound Restrict index screen - start */
	function getListIncomingNgSortOrder($column, $start = 1){
		$column_master = Array(
			'column[' . $start . ']=0' => Array(Array('T18IncomingNgList.list_ng_no ASC'), $start, '0'),
			'column[' . $start . ']=1' => Array(Array('T18IncomingNgList.list_ng_no DESC'), $start, '1'),
			'column[' . ($start + 1) . ']=0' => Array(Array('T18IncomingNgList.list_name ASC'), $start + 1, '0'),
			'column[' . ($start + 1) . ']=1' => Array(Array('T18IncomingNgList.list_name DESC'), $start + 1, '1'),
			'column[' . ($start + 2) . ']=0' => Array(Array('T18IncomingNgList.total ASC'), $start + 2, '0'),
			'column[' . ($start + 2) . ']=1' => Array(Array('T18IncomingNgList.total DESC'), $start + 2, '1'),
			'column[' . ($start + 3) . ']=0' => Array(Array('T18IncomingNgList.created ASC'), $start + 3, '0'),
			'column[' . ($start + 3) . ']=1' => Array(Array('T18IncomingNgList.created DESC'), $start + 3, '1'),
			'column[' . ($start + 4) . ']=0' => Array(Array('T18IncomingNgList.entry_user ASC'), $start + 4, '0'),
			'column[' . ($start + 4) . ']=1' => Array(Array('T18IncomingNgList.entry_user DESC'), $start + 4, '1'),
		);

		return $column_master[$column];
	}

	function getTelListIncomingNgSortOrder($column, $start = 1){
		$column_master = Array(
			'column[' . $start . ']=0' => Array(Array('T19IncomingNgTel.no ASC'), $start, '0'),
			'column[' . $start . ']=1' => Array(Array('T19IncomingNgTel.no DESC'), $start, '1'),
			'column[' . ($start + 1) . ']=0' => Array(Array('T19IncomingNgTel.tel_no ASC'), $start + 1, '0'),
			'column[' . ($start + 1) . ']=1' => Array(Array('T19IncomingNgTel.tel_no DESC'), $start + 1, '1'),
			'column[' . ($start + 2) . ']=0' => Array(Array('T19IncomingNgTel.memo ASC'), $start + 2, '0'),
			'column[' . ($start + 2) . ']=1' => Array(Array('T19IncomingNgTel.memo DESC'), $start + 2, '1'),
		);

		return $column_master[$column];
	}
	/* 20160314 Add by Giang : #6711 - Inbound Restrict index screen  - end */

	/* 20160317 Add by Giang : #6740 - Inbound call list screen - start */
	function getInboundListSortOrder($column, $start = 1){
		$column_master = Array(
			'column[' . $start . ']=0' => Array(Array('T16InboundCallList.list_no ASC'), $start, '0'),
			'column[' . $start . ']=1' => Array(Array('T16InboundCallList.list_no DESC'), $start, '1'),
			'column[' . ($start + 1) . ']=0' => Array(Array('T16InboundCallList.list_test_flag DESC, T16InboundCallList.list_name ASC'), ($start + 1), '0'),
			'column[' . ($start + 1) . ']=1' => Array(Array('T16InboundCallList.list_test_flag ASC, T16InboundCallList.list_name DESC'), ($start + 1), '1'),
			'column[' . ($start + 2) . ']=0' => Array(Array('T16InboundCallList.tel_total ASC'), ($start + 2), '0'),
			'column[' . ($start + 2) . ']=1' => Array(Array('T16InboundCallList.tel_total DESC'), ($start + 2), '1'),
			'column[' . ($start + 3) . ']=0' => Array(Array('T16InboundCallList.created ASC'), ($start + 3), '0'),
			'column[' . ($start + 3) . ']=1' => Array(Array('T16InboundCallList.created DESC'), ($start + 3), '1'),
			'column[' . ($start + 4) . ']=0' => Array(Array('M05User.user_name ASC'), ($start + 4), '0'),
			'column[' . ($start + 4) . ']=1' => Array(Array('M05User.user_name DESC'), ($start + 4), '1'),
			'column[' . $start . ']=0&column[' . ($start + 1) . ']=0' => Array(Array('T16InboundCallList.list_test_flag DESC, T16InboundCallList.list_name ASC'), ($start + 1), '0'),
			'column[' . $start . ']=0&column[' . ($start + 1) . ']=1' => Array(Array('T16InboundCallList.list_test_flag ASC, T16InboundCallList.list_name DESC'), ($start + 1), '1'),
		);

		return $column_master[$column];
	}

	function getInboundTelListSortOrder($column, $t12ListItems, $start = 1){
		$column_master = Array(
			'column[' . $start . ']=0' => Array(Array('T17InboundTelList.tel_no ASC'), $start, '0'),
			'column[' . $start . ']=1' => Array(Array('T17InboundTelList.tel_no DESC'), $start, '1'),
		);
		foreach ($t12ListItems as $key => $value) {
			$column_master["column[" . ($start + 1) . "]=0"] = Array(Array('T17InboundTelList.'.$value['T13InboundListItem']['column'].' ASC'), ($start + 1), '0');
			$column_master["column[" . ($start + 1) . "]=1"] = Array(Array('T17InboundTelList.'.$value['T13InboundListItem']['column'].' DESC'), ($start + 1), '1');
			$start++;
		}

		return $column_master[$column];
	}
	/* 20160317 Add by Giang : #6740 -  Inbound call list screen - end */

	//20160412 Add by Thai : #6766 List setting inbound screen - Begin
	function getSettingInboundSortOrder($column, $start = 1){
		$i = $start;
		$column_master = Array(
			'column[' . $i . ']=0' => Array(Array('T25Inbound.inbound_no ASC'), $i, '0'),
			'column[' . $i . ']=1' => Array(Array('T25Inbound.inbound_no DESC'), $i++, '1'),
			'column[' . $i . ']=0' => Array(Array('T25Inbound.external_number ASC'), $i, '0'),
			'column[' . $i . ']=1' => Array(Array('T25Inbound.external_number DESC'), $i++, '1'),
			'column[' . $i . ']=0' => Array(Array('SUBSTR(T25Inbound.time_start, 1, 10) ASC', 'SUBSTR(T25Inbound.time_end, 1, 10) ASC'), $i, '0'),
			'column[' . $i . ']=1' => Array(Array('SUBSTR(T25Inbound.time_start, 1, 10) DESC', 'SUBSTR(T25Inbound.time_end, 1, 10) DESC'), $i++, '1'),
			'column[' . $i . ']=0' => Array(Array('IF(T25Inbound.template_id = "", "busy", IF(T25Inbound.status = "' . STATUS_INBOUND_END . '", T63InboundTemplateHistory.template_name, T30Template.template_name)) ASC'), $i, '0'),
			'column[' . $i . ']=1' => Array(Array('IF(T25Inbound.template_id = "", "busy", IF(T25Inbound.status = "' . STATUS_INBOUND_END . '", T63InboundTemplateHistory.template_name, T30Template.template_name)) DESC'), $i++, '1'),
			'column[' . $i . ']=0' => Array(Array('IF(T25Inbound.status = "' . STATUS_INBOUND_END . '", T58InboundListNgHistory.list_name, T18IncomingNgList.list_name) ASC'), $i, '0'),
			'column[' . $i . ']=1' => Array(Array('IF(T25Inbound.status = "' . STATUS_INBOUND_END . '", T58InboundListNgHistory.list_name, T18IncomingNgList.list_name) DESC'), $i++, '1'),
			'column[' . $i . ']=0' => Array(Array('IF(T25Inbound.status = "' . STATUS_INBOUND_END . '", T56InboundListHistory.list_name, T16InboundCallList.list_name) ASC'), $i, '0'),
			'column[' . $i . ']=1' => Array(Array('IF(T25Inbound.status = "' . STATUS_INBOUND_END . '", T56InboundListHistory.list_name, T16InboundCallList.list_name) DESC'), $i++, '1'),
			'column[' . $i . ']=0' => Array(Array('T25Inbound.created ASC'), $i, '0'),
			'column[' . $i . ']=1' => Array(Array('T25Inbound.created DESC'), $i++, '1'),
			'column[' . $i . ']=0' => Array(Array('M05User.user_name ASC'), $i, '0'),
			'column[' . $i . ']=1' => Array(Array('M05User.user_name DESC'), $i++, '1'),
			'column[' . $start . ']=0&column[' . $start++ . ']=0' => Array(Array('T25Inbound.inbound_no ASC'), $start, '0'),
			'column[' . $start . ']=1&column[' . $start++ . ']=1' => Array(Array('T25Inbound.inbound_no DESC'), $start, '1'),
		);

		return $column_master[$column];
	}
	//20160412 Add by Thai : #6766 List setting inbound screen - End
	/**
	 *
	 */
	function getSmsSendListSortOrder($column, $start = 1){
		$i = $start;
		$column_master = Array(
				'column[' . $i . ']=0' => Array(Array('T100SmsSendList.id ASC'), $i, '0'),
				'column[' . $i . ']=1' => Array(Array('T100SmsSendList.id DESC'), $i++, '1'),
				'column[' . $i . ']=0' => Array(Array('T100SmsSendList.list_test_flag DESC, T100SmsSendList.list_name ASC'), $i, '0'),
				'column[' . $i . ']=1' => Array(Array('T100SmsSendList.list_test_flag ASC, T100SmsSendList.list_name DESC'), $i++, '1'),
				'column[' . $i . ']=0' => Array(Array('T100SmsSendList.tel_total ASC'), $i, '0'),
				'column[' . $i . ']=1' => Array(Array('T100SmsSendList.tel_total DESC'), $i++, '1'),
				'column[' . $i . ']=0' => Array(Array('T100SmsSendList.created ASC'), $i, '0'),
				'column[' . $i . ']=1' => Array(Array('T100SmsSendList.created DESC'), $i++, '1'),
				'column[' . $i . ']=0' => Array(Array('T100SmsSendList.entry_user ASC'), $i, '0'),
				'column[' . $i . ']=1' => Array(Array('T100SmsSendList.entry_user DESC'), $i, '1'),
				'column[' . $start . ']=0&column[' . $start + 1 . ']=0' => Array(Array('T100SmsSendList.list_test_flag DESC, T100SmsSendList.list_name ASC'), '2', '0'),
				'column[' . $start . ']=0&column[' . $start + 1 . ']=1' => Array(Array('T100SmsSendList.list_test_flag ASC, T100SmsSendList.list_name DESC'), '2', '1'),
		);

		return $column_master[$column];
	}

	function getTelSMSListSortOrder($column, $t102_sms_list_items, $start = 1){
		$column_master = Array(
			'column[' . $start . ']=0' => Array(Array('T101SmsTelList.tel_no ASC'), '1', '0'),
			'column[' . $start ++ . ']=1' => Array(Array('T101SmsTelList.tel_no DESC'), '1', '1'),
		);
		foreach ($t102_sms_list_items as $key => $value) {
			if ($start == 2)
				$col = $key + 2;
			else
				$col = $key + 1;
			$column_master["column[$col]=0"] = Array(Array('T101SmsTelList.'.$value['T102SmsListItem']['column'].' ASC'), $col, '0');
			$column_master["column[$col]=1"] = Array(Array('T101SmsTelList.'.$value['T102SmsListItem']['column'].' DESC'), $col, '1');
		}

		return $column_master[$column];
	}

	/* 20160427 Add by Giang : #7074 - Sms template screen - start */
	function getSmsTemplateSortOrder($column, $start = 1){
		$column_master = Array(
			'column[' . $start . ']=0' => Array(Array('T300SmsTemplate.template_no ASC'), $start, '0'),
			'column[' . $start . ']=1' => Array(Array('T300SmsTemplate.template_no DESC'), $start, '1'),
			'column[' . ($start + 1) . ']=0' => Array(Array('T300SmsTemplate.template_name ASC'), ($start + 1), '0'),
			'column[' . ($start + 1) . ']=1' => Array(Array('T300SmsTemplate.template_name DESC'), ($start + 1), '1'),
			'column[' . ($start + 2) . ']=0' => Array(Array('T300SmsTemplate.description ASC'), ($start + 2), '0'),
			'column[' . ($start + 2) . ']=1' => Array(Array('T300SmsTemplate.description DESC'), ($start + 2), '1'),
			'column[' . ($start + 3) . ']=0' => Array(Array('T300SmsTemplate.created ASC'), ($start + 3), '0'),
			'column[' . ($start + 3) . ']=1' => Array(Array('T300SmsTemplate.created DESC'), ($start + 3), '1'),
			'column[' . ($start + 4) . ']=0' => Array(Array('M05User.user_name ASC'), ($start + 4), '0'),
			'column[' . ($start + 4) . ']=1' => Array(Array('M05User.user_name DESC'), ($start + 4), '1'),
		);

		return $column_master[$column];
	}
	/* 20160427 Add by Giang : #7074 - Sms template screen - end */

	function getSmsScheduleSortOrder($column, $start = 1){
		$i = $start;
		$column_master = Array(
			'column[' . $i . ']=0' => Array(Array('T200SmsSendSchedule.schedule_no ASC'), $i, '0'),
			'column[' . $i . ']=1' => Array(Array('T200SmsSendSchedule.schedule_no DESC'), $i++, '1'),
			'column[' . $i . ']=0' => Array(Array('T200SmsSendSchedule.schedule_name ASC'), $i, '0'),
			'column[' . $i . ']=1' => Array(Array('T200SmsSendSchedule.schedule_name DESC'), $i++, '1'),
			'column[' . $i . ']=0' => Array(Array('T201SmsSendTime.time_start ASC'), $i, '0'),
			'column[' . $i . ']=1' => Array(Array('T201SmsSendTime.time_start DESC'), $i++, '1'),
			'column[' . $i . ']=0' => Array(Array('SUBSTR(MIN(T201SmsSendTime.time_start), 12) ASC', 'SUBSTR(MIN(T201SmsSendTime.time_end), 12) ASC'), $i, '0'),
			'column[' . $i . ']=1' => Array(Array('SUBSTR(MAX(T201SmsSendTime.time_start), 12) DESC', 'SUBSTR(MAX(T201SmsSendTime.time_end), 12) DESC'), $i++, '1'),
			'column[' . $i . ']=0' => Array(Array('IF(T200SmsSendSchedule.status = "' . STATUS_FINISH . '", T600SmsTemplateHistory.template_name, T300SmsTemplate.template_name) ASC'), $i, '0'),
			'column[' . $i . ']=1' => Array(Array('IF(T200SmsSendSchedule.status = "' . STATUS_FINISH . '", T600SmsTemplateHistory.template_name, T300SmsTemplate.template_name) DESC'), $i++, '1'),
			'column[' . $i . ']=0' => Array(Array('IF(T200SmsSendSchedule.status = "' . STATUS_FINISH . '", T500SmsListHistory.list_name, T100SmsSendList.list_name) ASC'), $i, '0'),
			'column[' . $i . ']=1' => Array(Array('IF(T200SmsSendSchedule.status = "' . STATUS_FINISH . '", T500SmsListHistory.list_name, T100SmsSendList.list_name) DESC'), $i++, '1'),
			'column[' . $i . ']=0' => Array(Array('CAST(IF(T200SmsSendSchedule.status = "' . STATUS_FINISH . '", T500SmsListHistory.muko_tel_total, T100SmsSendList.muko_tel_total) as UNSIGNED) ASC'), $i, '0'),
			'column[' . $i . ']=1' => Array(Array('CAST(IF(T200SmsSendSchedule.status = "' . STATUS_FINISH . '", T500SmsListHistory.muko_tel_total, T100SmsSendList.muko_tel_total) as UNSIGNED) DESC'), $i++, '1'),
			'column[' . $i . ']=0' => Array(Array('T200SmsSendSchedule.send_total ASC'), $i, '0'),
			'column[' . $i . ']=1' => Array(Array('T200SmsSendSchedule.send_total DESC'), $i++, '1'),
			'column[' . $i . ']=0' => Array(Array('T200SmsSendSchedule.created ASC'), $i, '0'),
			'column[' . $i . ']=1' => Array(Array('T200SmsSendSchedule.created DESC'), $i++, '1'),
			'column[' . $i . ']=0' => Array(Array('M05User.user_name ASC'), $i, '0'),
			'column[' . $i . ']=1' => Array(Array('M05User.user_name DESC'), $i++, '1'),
		);

		return $column_master[$column];
	}

	function getSendTimeSortOrder($column, $time_send_position){
		$column_master = Array(
			'column[' . $time_send_position . ']=0' => Array(Array('SUBSTR(T201SmsSendTime.time_start, 12) ASC', 'SUBSTR(T201SmsSendTime.time_end, 12) ASC'), $time_send_position, '0'),
			'column[' . $time_send_position . ']=1' => Array(Array('SUBSTR(T201SmsSendTime.time_start, 12) DESC', 'SUBSTR(T201SmsSendTime.time_end, 12) DESC'), $time_send_position, '1'),
		);

		return $column_master[$column];
	}

	function getSmsScheduleDetailSortOrder($column){
		$i = 0;
		$column_master = Array(
			'column[' . $i . ']=0' => Array(Array('T800SmsSendResult.send_datetime ASC'), $i, '0'),
			'column[' . $i . ']=1' => Array(Array('T800SmsSendResult.send_datetime DESC'), $i++, '1'),
			'column[' . $i . ']=0' => Array(Array('T800SmsSendResult.tel_no ASC'), $i, '0'),
			'column[' . $i . ']=1' => Array(Array('T800SmsSendResult.tel_no DESC'), $i++, '1'),
			'column[' . $i . ']=0' => Array(Array('T501SmsTelHistory.carrier ASC'), $i, '0'),
			'column[' . $i . ']=1' => Array(Array('T501SmsTelHistory.carrier DESC'), $i++, '1'),
			'column[' . $i . ']=0' => Array(Array('IF(T800SmsSendResult.status IS NULL, "", IF(T800SmsSendResult.status = "success", "着信済み",IF(T800SmsSendResult.status = "outside", "圏外", IF(T800SmsSendResult.status = "unknown", "不明", IF(T800SmsSendResult.status = "history_judgement_ng", "履歴判定NG","エラー"))))) ASC'), $i, '0'),  // #8298 add consentday
			'column[' . $i . ']=1' => Array(Array('IF(T800SmsSendResult.status IS NULL, "", IF(T800SmsSendResult.status = "success", "着信済み",IF(T800SmsSendResult.status = "outside", "圏外", IF(T800SmsSendResult.status = "unknown", "不明", IF(T800SmsSendResult.status = "history_judgement_ng", "履歴判定NG","エラー"))))) DESC'), $i, '1'), // #8298 add consentday
		);

		return $column_master[$column];
	}

	function getManageMenuSortOrder($column){
		$column_master = Array(
			'column[0]=0' => Array(Array('M02Company.id ASC'), '0', '0'),
			'column[0]=1' => Array(Array('M02Company.id DESC'), '0', '1'),
			'column[1]=0' => Array(Array('M02Company.company_code ASC'), '1', '0'),
			'column[1]=1' => Array(Array('M02Company.company_code DESC'), '1', '1'),
			'column[2]=0' => Array(Array('M02Company.company_name ASC'), '2', '0'),
			'column[2]=1' => Array(Array('M02Company.company_name DESC'), '2', '1'),
		);

		return $column_master[$column];
	}


	/***
	* Out、In、SMS一括送信の発信・着信設定時、SMS本文のチェックを行う。
	* また、同時に改行コードやURLをダミー文字列に置き換える。
	* $sms_use_short_url：短縮URLを使うか（1：使う　or　0：使わない）
	* $tmp_sms_content：SMS本文
	* 
	* return
	* 　　エラーメッセージ（空欄（問題なし） or 各種エラー（その時点での$tmp_sms_contentを戻す））
	* 　　ダミー文字列に置き換えたSMS本文
	***/
	function checkSmsBodyValueForApiV2($sms_use_short_url, $tmp_sms_content){
		// 挿入項目置き換え済みのSMS本文より、Url短縮パターンを抜き出す。
		$arr_url_strings = array();
		if($sms_use_short_url){
			// URL短縮を考慮しないで、SMS本文が挿入項目込で300文字を超えないかチェック
			if(mb_strlen($tmp_sms_content) > SMS_URL_PATTERN_MAX_CONTENT){
				return array("err_sms_over_url_length", $tmp_sms_content);
			}

			preg_match_all(SMS_URL_PATTERN_REGEX, $tmp_sms_content, $arr_url_strings);
			// $arr_url_strings[1] にも同じものが入るので、0だけを保持する
			$arr_url_strings = $arr_url_strings[0];
		}
		// 禁則check（短縮URLの中に挿入項目がある場合、それらの中に禁則がないかチェックする。）
		foreach ($arr_url_strings as $key => $url_string) {
			// 全角スペース以外の禁則文字。
			preg_match_all(SMS_URL_NG_PATTERN_REGEX, $url_string, $arr_illegal_strings);
			// 全角スペースをSMS_URL_NG_PATTERN_REGEXにまとめると、全角文字にHITしてしまうので苦肉の策。
			preg_match_all(SMS_URL_NG_PATTERN_ZENKAKU_REGEX, $url_string, $arr_illegal_zenkaku_strings);

			// preg_match_allは array(array("<Hitした文字>","<Hitした文字>"))となる。
			// Hitした文字がない場合は、array(array())となる
			if($arr_illegal_strings[0] || $arr_illegal_zenkaku_strings[0]){
				return array("err_sms_illegal_url_string", $tmp_sms_content);
			}
		}

		// 短縮URL対象の文字列がある場合は、その文字列を22文字のダミー文字に置き換える。
		// $sms_use_short_url=1(短縮URLON)　のときのみ、$arr_url_stringsに値が入る。
		$tmp_sms_content = str_replace($arr_url_strings, SMS_URL_DUMMY_STRING, $tmp_sms_content);
		// API_v2の場合は、改行を2文字とカウントする
		$tmp_sms_content = preg_replace(SMS_URL_PATTERN_KAIGYOU_REGEX, SMS_URL_DUMMY_KAIGYOU_STRING, $tmp_sms_content );
		return array("", $tmp_sms_content);
	}

	/**
	 * 開始時間が閾値以上かチェックする
	 * @param string $start_datetime 発信（送信）開始時間
	 * @param string $action 押下されたボタンの種類
	 * @return boolean true：実行可能／false：不可
	 */
	function check_start_time($start_datetime, $action)
	{
		if ($action == 'update' || $action == 'delete') {
			$interval_time = SCHEDULE_UPDATE_DELETE_SETTING_INTERVAL;
		} else {
			$interval_time = SCHEDULE_SETTING_INTERVAL;
		}

		$start_datetime = strtotime($start_datetime);
		$current_datetime = strtotime('now');
		if (($start_datetime - $current_datetime) / 60 <= $interval_time) {
			//開始時間が閾値以内の場合、処理不可とする
			return false;
		}

		return true;
	}

	/**
	 * 空かどうか判定する
	 *
	 * @param object $target チェック対象
	 * @return boolean true：空の場合／false：それ以外
	 */
	function isNullOrEmpty($target)
	{
		if ($target === 0 || $target === '0') {
			return false;
		}

		return empty($target);
	}

	/**
	 * 空かどうか判定する
	 * 空白(スペース)のみも空とする
	 *
	 * @param object $target チェック対象
	 * @return boolean true：空の場合／false：それ以外
	 */
	function isNullOrWhitespace($target)
	{
		if ($this->isNullOrEmpty($target)) {
			return true;
		}

		return is_string($target) && mb_ereg_match('^(\s|　)+$', $target);
	}
}
