<?php

/**
 * T81IncomingResult model.
 */
class T81IncomingResult extends AppModel {
	var $name = 'T81IncomingResult';

    function importUtilComponent()
    {
       App::import('Component','UtilComponent');
       // new ComponentCollection()が無いとErrorが発生する。
       // Argument 1 passed to Component::__construct() must be an instance of ComponentCollection,
       $gc = new UtilComponent(new ComponentCollection());
       return $gc;
    }

	function getIncomingResultById($id) {
		$options['fields'] = array(
			'T81IncomingResult.*'
		);
		$options['conditions'] = array(
			'T81IncomingResult.id' => $id
		);

		return $this->find('all', $options);
	}

	function getListByCompanyId($company_id, $limit=null, $page=null, $sort_order=null, $filter=null) {
		$options['fields'] = array(
			'T81IncomingResult.*',
			'M05User.user_name',
		);

		$options['joins'] = array(
			array(
				'table' => 'm05_users',
				'alias' => 'M05User',
				'fields' => array('user_name'),
				'type' => 'left',
				'conditions' => array(
					'T81IncomingResult.entry_user = M05User.user_id',
				),
			),
		);

		if(isset($filter) && !empty($filter)){
			if(isset($filter[1])){
				$options['conditions']['T81IncomingResult.list_no LIKE'] = "%".$filter[1]."%";
			}
			if(isset($filter[2])){
				$options['conditions']['T81IncomingResult.list_name LIKE'] = "%".$filter[2]."%";
			}
			if(isset($filter[3])){
				$options['conditions']['T81IncomingResult.tel_total LIKE'] = "%".$filter[3]."%";
			}
			if(isset($filter[4])){
				$options['conditions']['DATE_FORMAT(T81IncomingResult.created, "%Y-%m-%d %k:%i") LIKE'] = "%".$filter[4]."%";
			}
			if(isset($filter[5])){
				$options['conditions']['M05User.user_name LIKE'] = "%".$filter[5]."%";
			}
		}
		$options['conditions']['T81IncomingResult.company_id'] = $company_id;
		$options['conditions']['T81IncomingResult.del_flag'] = "N";
		if(isset($sort_order) && !empty($sort_order)){
			$options['order'] = $sort_order;
		}else{
			$options['order'] = array(
				'T81IncomingResult.list_test_flag desc',
				'T81IncomingResult.created desc',
			);
		}
		if(isset($limit) && !empty($limit)){
			$options['limit'] = $limit;
		}
		if(isset($page) && !empty($page)){
			$options['page'] = $page;
		}
		return $this->find('all', $options);
	}

	function getListByCompanyIdCount($company_id, $filter=null) {
		$options['fields'] = array(
			'T81IncomingResult.*',
			'M05User.user_name',
		);

		$options['joins'] = array(
			array(
				'table' => 'm05_users',
				'alias' => 'M05User',
				'type' => 'left',
				'conditions' => array(
					'T81IncomingResult.entry_user = M05User.user_id',
				),
			),
		);

		$options['conditions']['T81IncomingResult.company_id'] = $company_id;
		$options['conditions']['T81IncomingResult.del_flag'] = "N";
		if(isset($filter) && !empty($filter)){
			if(isset($filter[1])){
				$options['conditions']['T81IncomingResult.list_no LIKE'] = "%".$filter[1]."%";
			}
			if(isset($filter[2])){
				$options['conditions']['T81IncomingResult.list_name LIKE'] = "%".$filter[2]."%";
			}
			if(isset($filter[3])){
				$options['conditions']['T81IncomingResult.tel_total LIKE'] = "%".$filter[3]."%";
			}
			if(isset($filter[4])){
				$options['conditions']['DATE_FORMAT(T81IncomingResult.created, "%Y-%m-%d %k:%i") LIKE'] = "%".$filter[4]."%";
			}
			if(isset($filter[5])){
				$options['conditions']['M05User.user_name LIKE'] = "%".$filter[5]."%";
			}
		}
		return $this->find('count', $options);
	}

    // 着信設定の状況画面（詳細画面）の表
    function getResultByScheduleId(
    	$inbound_id = null,
    	$item_main_column = null,
    	$limit = null, $page = null,
    	$sort_order = null,
    	$filter = null,
    	$referents = array(),
    	$arr_pos_ques_basic = array(),
    	$arr_pos_ques_auth = array(),
    	$join_col = null
    ) {

        $myUtil = $this->importUtilComponent();
        $options['fields'][] = 'T81IncomingResult.*';
        if(isset($item_main_column) && isset($join_col) && $join_col == 'memo'){
            $options['fields'][] = 'T57InboundTelHistory.*';
            $options['joins'] = array(
                array(
                    'table' => 't57_inbound_tel_histories',
                    'alias' => 'T57InboundTelHistory',
                    'type' => 'left',
                    'conditions' => array(
                        "T57InboundTelHistory.$item_main_column = SUBSTRING_INDEX(T81IncomingResult.$join_col,':',1)",
                        'T57InboundTelHistory.inbound_id = T81IncomingResult.inbound_id',
                        'T57InboundTelHistory.inbound_id = "' . $inbound_id . '"',
                        'T57InboundTelHistory.del_flag = "N"',
                    )
                ),
            );
        }elseif (isset($item_main_column) && isset($join_col)) {
	        $options['fields'][] = 'T57InboundTelHistory.*';
	        $options['joins'] = array(
				array(
					'table' => 't57_inbound_tel_histories',
					'alias' => 'T57InboundTelHistory',
					'type' => 'left',
					'conditions' => array(
						"T57InboundTelHistory.$item_main_column = T81IncomingResult.$join_col",
						'T57InboundTelHistory.inbound_id = T81IncomingResult.inbound_id',
						'T57InboundTelHistory.inbound_id = "' . $inbound_id . '"',
						'T57InboundTelHistory.del_flag = "N"',
				 	)
				),
            );
        }

        $options['conditions'] = array(
            'T81IncomingResult.inbound_id' => $inbound_id,
        );

        $index = 0;
        $attr_filters = array(
            // 着信日時でのフィルタの際に利用
            $index++ => 'T81IncomingResult.call_datetime',
            // 着信元でのフィルタに利用
            $index++ => 'IF(T81IncomingResult.tel_no IS NULL OR T81IncomingResult.tel_no = "", "anonymous", T81IncomingResult.tel_no)',
            // 接続時間でのフィルタに利用
            $index++ => 'IF(T81IncomingResult.status NOT IN ("timeout", "reject"), FROM_UNIXTIME(UNIX_TIMESTAMP(T81IncomingResult.cut_datetime) - UNIX_TIMESTAMP(T81IncomingResult.connect_datetime), "%i:%s"), "")',
        );

        // ステータスのフィルタの際に利用に利用
        $attr_filters[$index] = 'IF(T81IncomingResult.status = "timeout", "NOANSWER", IF(T81IncomingResult.status in (' . $myUtil->getCallResultConvertTFRejectString(). '), "TRANSFERREJECT", IF(T81IncomingResult.status IN (' . $myUtil->getCallResultNoConvertString() . '), UPPER(T81IncomingResult.status), "ANSWER")))';

        if(isset($filter) && !empty($filter)){
            foreach ($filter as $pos_in_header => $value_filter) {

                $pos_in_header_ques = $pos_in_header - sizeof($attr_filters) + 1;
                if (isset($attr_filters[$pos_in_header])) {
                    if ($pos_in_header == $index) {
                        $options['conditions'][$attr_filters[$pos_in_header] . ' = '] = $value_filter;
                    } else {
                        $options['conditions'][$attr_filters[$pos_in_header] . ' LIKE'] = "%" . $value_filter . "%";
                    }
                } elseif (isset($arr_pos_ques_basic[$pos_in_header_ques])) {
                    $question_no = $arr_pos_ques_basic[$pos_in_header_ques];
                    $alias = 'T65InboundButtonHistory' . $question_no;
                    $pos_in_t81 = $referents[$pos_in_header_ques];

                    $options['joins'][] = array(
                        'table' => 't65_inbound_button_histories',
                        'alias' => $alias,
                        'type' => 'left',
                        'conditions' => array(
                            $alias . '.inbound_id = T81IncomingResult.inbound_id',
                            $alias . '.question_no = ' . $question_no,
                            'CAST(IF(' . $alias . '.answer_no=51, "*", IF(' . $alias . '.answer_no=52, "#", ' . $alias . '.answer_no)) AS CHAR) = T81IncomingResult.answer' . $pos_in_t81,
                            $alias . '.del_flag = "N"',
                        )
                    );
                    $options['conditions']['IF(' . $alias . '.answer_content <> "", ' . $alias . '.answer_content, T81IncomingResult.answer' . $referents[$pos_in_header_ques] . ') LIKE'] = "%" . $value_filter . "%";
                } elseif (isset($arr_pos_ques_auth[$pos_in_header_ques])) {
                    if (isset($arr_pos_ques_auth[$pos_in_header_ques]['recheck_button_next'])) {
                        $recheck_button_next = $arr_pos_ques_auth[$pos_in_header_ques]['recheck_button_next'];

                        $str_filter = 'IF(' . $recheck_button_next
                            . ' IN (T81IncomingResult.answer' . $referents[$pos_in_header_ques]
                            . ', T81IncomingResult.answer' . ($referents[$pos_in_header_ques] + 1)
                            . ', T81IncomingResult.answer' . ($referents[$pos_in_header_ques] + 2) . '), '
                            . $recheck_button_next
                            . ', COALESCE(T81IncomingResult.answer' . $referents[$pos_in_header_ques]
                            . ', T81IncomingResult.answer' . ($referents[$pos_in_header_ques] + 1)
                            . ', T81IncomingResult.answer' . ($referents[$pos_in_header_ques] + 2) . ')) LIKE';

                        $options['conditions'][$str_filter] = "%" . $value_filter . "%";
                    } elseif (isset($arr_pos_ques_auth[$pos_in_header_ques]['auth_item_column'])) {
                        $auth_item_code = $arr_pos_ques_auth[$pos_in_header_ques]['auth_item_code'];
                        $auth_item_column = $arr_pos_ques_auth[$pos_in_header_ques]['auth_item_column'];
                        if (!in_array($value_filter, array('＜', '＝', '＞', '<', '=', '>'))) {
                            if (($value_filter == '≠')) {
	                            $str_filter1 = 'CAST(T81IncomingResult.answer' . $referents[$pos_in_header_ques] . ' AS UNSIGNED) '
		                                . '>'
		                                . ' ' . 'CAST(T57InboundTelHistory.' . $auth_item_column . ' AS UNSIGNED)';
	                            $str_filter2 = 'CAST(T81IncomingResult.answer' . $referents[$pos_in_header_ques] . ' AS UNSIGNED) '
		                                . '<'
		                                . ' ' . 'CAST(T57InboundTelHistory.' . $auth_item_column . ' AS UNSIGNED)';
		                        $options['conditions'][1]['OR'][$str_filter1] = 1;
		                        $options['conditions'][1]['OR'][$str_filter2] = 1;
                            } else {
                            	$options['conditions']['T81IncomingResult.answer' . $referents[$pos_in_header_ques]] = NULL;
                            }
                        } else {

	                        if ($auth_item_code == 'birthday') {
	                            $str_filter = 'CAST(T81IncomingResult.answer' . $referents[$pos_in_header_ques] . ' AS UNSIGNED) '
	                                . $value_filter
	                                . ' ' . 'CAST(STR_TO_DATE(T57InboundTelHistory.' . $auth_item_column . ', "%Y年%m月%d日") AS UNSIGNED)';
	                        } else {
	                            $str_filter = 'CAST(T81IncomingResult.answer' . $referents[$pos_in_header_ques] . ' AS UNSIGNED) '
	                                . $value_filter
	                                . ' ' . 'CAST(T57InboundTelHistory.' . $auth_item_column . ' AS UNSIGNED)';
	                        }
	                        $options['conditions'][$str_filter] = 1;
                        }
                    }
                } elseif ($referents[$pos_in_header_ques] == 'fax_status') {
                    $question_no = $referents['fax_ques_no_'.$pos_in_header_ques];                    
                    $alias = 'T82BukkenFaxStatus' . $question_no;
                    $options['joins'][] = array(
                        'table' => 't82_bukken_fax_statuses',
                        'alias' => $alias,
                        'type' => 'left',
                        'conditions' => array(
                            $alias . '.log_id = T81IncomingResult.id',
                            $alias . '.fax_question_no = ' . $question_no,                            
                            $alias . '.del_flag = "N"',
                        )
                    );
                    $options['conditions'][ $alias . '.fax_status LIKE'] = "%" . $value_filter . "%";
                } elseif ($referents[$pos_in_header_ques] == 'inbound_sms_status' || $referents[$pos_in_header_ques] == 'inbound_sms_input_status') {
                    $smsStatusTitle = array(
                        '着信済み' => INBOUND_SMS_STATUS_SUCCESS,
                        '圏外' => INBOUND_SMS_STATUS_OUTSIDE,
                        '不明' => INBOUND_SMS_STATUS_UNKNOWN,
                        'エラー' => INBOUND_SMS_STATUS_ERROR,
                        '送信中' => INBOUND_SMS_STATUS_SENDING,
                        '' => INBOUND_SMS_STATUS_NO_SEND
                    );
                    if ($referents[$pos_in_header_ques] == 'inbound_sms_status'){
                        $question_no = $referents['inbound_sms_'.$pos_in_header_ques];
                    }elseif($referents[$pos_in_header_ques] == 'inbound_sms_input_status'){
                        $question_no = $referents['inbound_sms_input_'.$pos_in_header_ques];
                    }
                    $alias = 'T86InboundSmsStatus' . $question_no;
                    $options['joins'][] = array(
                        'table' => 't86_inbound_sms_statuses',
                        'alias' => $alias,
                        'type' => 'left',
                        'conditions' => array(
                            $alias . '.log_id = T81IncomingResult.id',
                            $alias . '.sms_question_no = ' . $question_no,                            
                            $alias . '.del_flag = "N"',
                        )
                    );
                    $options['conditions'][ $alias . '.sms_status'] = $smsStatusTitle[$value_filter];
                }else {
                    if ($referents[$pos_in_header_ques] == 'trans_call_time') {
                        $options['conditions']['IF(UNIX_TIMESTAMP(T81IncomingResult.trans_cut_datetime) - UNIX_TIMESTAMP(T81IncomingResult.trans_connect_datetime) > 0, FROM_UNIXTIME(UNIX_TIMESTAMP(T81IncomingResult.trans_cut_datetime) - UNIX_TIMESTAMP(T81IncomingResult.trans_connect_datetime), "%i:%s"), "") LIKE'] = "%" . $value_filter . "%";
                    } else {
                        $options['conditions']['T81IncomingResult.answer' . $referents[$pos_in_header_ques] . ' LIKE'] = "%" . $value_filter . "%";
                    }
                }
            }
        }

        if(isset($sort_order) && !empty($sort_order)){
            if (strpos($sort_order[0], 'T65InboundButtonHistory') !== false) {
                $pos_in_header = $sort_order[1];
                unset($sort_order[1]);

                preg_match_all('/T65InboundButtonHistory[0-9]+/', $sort_order[0], $alias_tmp);
                $alias = $alias_tmp[0][0];

                $join_flag = true;

                if (isset($options['joins'])) {
	                foreach ($options['joins'] as $table_join) {
	                    if ($table_join['alias'] == $alias) {
	                        $join_flag = false;
	                        break;
	                    }
	                }
                }

                if ($join_flag) {
                    $question_no = substr($alias, strlen('T65InboundButtonHistory'));
                    $pos_in_t81 = $referents[$pos_in_header];
                    $options['joins'][] = array(
                        'table' => 't65_inbound_button_histories',
                        'alias' => $alias,
                        'type' => 'left',
                        'conditions' => array(
                            $alias . '.inbound_id = T81IncomingResult.inbound_id',
                            $alias . '.question_no = ' . $question_no,
                            'CAST(IF(' . $alias . '.answer_no=51, "*", IF(' . $alias . '.answer_no=52, "#", ' . $alias . '.answer_no)) AS CHAR) = T81IncomingResult.answer' . $pos_in_t81,
                            $alias . '.del_flag = "N"',
                        )
                    );
                }
            }            
            if(isset($sort_order[0][0]) && strpos($sort_order[0], 'T82BukkenFaxStatus') !== false){
                    $join_flag = true;
                    preg_match_all('/T82BukkenFaxStatus[0-9]+/', $sort_order[0], $alias_tmp);
                    $alias = $alias_tmp[0][0];                    
                    if (isset($options['joins'])) {
                        foreach ($options['joins'] as $table_join) {
                            if ($table_join['alias'] == $alias) {
                                $join_flag = false;
                                break;
                            }
                        }
                    }
                    if ($join_flag) {
                        $question_no = substr($alias, strlen('T82BukkenFaxStatus'));                        
                        $options['joins'][] = array(
                            'table' => 't82_bukken_fax_statuses',
                            'alias' => $alias,
                            'type' => 'left',
                            'conditions' => array(
                                $alias . '.log_id = T81IncomingResult.id',
                                $alias . '.fax_question_no = ' . $question_no,                            
                                $alias . '.del_flag = "N"',
                            )
                        );
                    }
                }
                if(isset($sort_order[0][0]) && strpos($sort_order[0], 'T86InboundSmsStatus') !== false){
                    $join_flag = true;
                    preg_match_all('/T86InboundSmsStatus[0-9]+/', $sort_order[0], $alias_tmp);
                    $alias = $alias_tmp[0][0];                    
                    if (isset($options['joins'])) {
                        foreach ($options['joins'] as $table_join) {
                            if ($table_join['alias'] == $alias) {
                                $join_flag = false;
                                break;
                            }
                        }
                    }
                    if ($join_flag) {
                        $question_no = substr($alias, strlen('T86InboundSmsStatus'));
                        $options['joins'][] = array(
                            'table' => 't86_inbound_sms_statuses',
                            'alias' => $alias,
                            'type' => 'left',
                            'conditions' => array(
                                $alias . '.log_id = T81IncomingResult.id',
                                $alias . '.sms_question_no = ' . $question_no,                            
                                $alias . '.del_flag = "N"',
                            )
                        );
                    }
                }
            $options['order'] = $sort_order;
        }
        if(isset($limit) && !empty($limit)){
            $options['limit'] = $limit;
        }
        if(isset($page) && !empty($page)){
            $options['page'] = $page;
        }
        return $this->find('all', $options);
    }

    // そのスケジュールにあるフィルタなどを考慮した発信結果の数を戻す
    function getCountByScheduleId(
    	$inbound_id = null,
    	$item_main_column = null,
    	$filter = null,
    	$referents = array(),
    	$arr_pos_ques_basic = array(),
    	$arr_pos_ques_auth = array(),
    	$join_col = null
    ) {
        $myUtil = $this->importUtilComponent();
        $options['fields'] = array(
            'T81IncomingResult.*',
        );

        $options['conditions'] = array(
            'T81IncomingResult.inbound_id' => $inbound_id,
            'T81IncomingResult.status <>' => 'recover',
        );

        $index = 0;
        $attr_filters = array(
            $index++ => 'T81IncomingResult.call_datetime',
            $index++ => 'IF(T81IncomingResult.tel_no IS NULL OR T81IncomingResult.tel_no = "", "anonymous", T81IncomingResult.tel_no)',
            $index++ => 'IF(T81IncomingResult.status NOT IN ("timeout", "reject"), FROM_UNIXTIME(UNIX_TIMESTAMP(T81IncomingResult.cut_datetime) - UNIX_TIMESTAMP(T81IncomingResult.connect_datetime), "%i:%s"), "")',
        );

        $attr_filters[$index] = 'IF(T81IncomingResult.status = "timeout", "NOANSWER", IF(T81IncomingResult.status in (' . $myUtil->getCallResultConvertTFRejectString(). '), "TRANSFERREJECT", IF(T81IncomingResult.status IN (' . $myUtil->getCallResultNoConvertString(). '), UPPER(T81IncomingResult.status), "ANSWER")))';

        if(isset($filter) && !empty($filter)){
            $join_flag = true;
            foreach ($filter as $pos_in_header => $value_filter) {
                $pos_in_header_ques = $pos_in_header - sizeof($attr_filters) + 1;
                if (isset($attr_filters[$pos_in_header])) {
                    if ($pos_in_header == $index) {
                        $options['conditions'][$attr_filters[$pos_in_header] . ' = '] = $value_filter;
                    } else {
                        $options['conditions'][$attr_filters[$pos_in_header] . ' LIKE'] = "%" . $value_filter . "%";
                    }
                } elseif (isset($arr_pos_ques_basic[$pos_in_header_ques])) {
                    $question_no = $arr_pos_ques_basic[$pos_in_header_ques];
                    $alias = 'T65InboundButtonHistory' . $question_no;
                    $pos_in_t81 = $referents[$pos_in_header_ques];

                    $options['joins'][] = array(
                        'table' => 't65_inbound_button_histories',
                        'alias' => $alias,
                        'type' => 'left',
                        'conditions' => array(
                            $alias . '.inbound_id = T81IncomingResult.inbound_id',
                            $alias . '.question_no = ' . $question_no,
                            'CAST(IF(' . $alias . '.answer_no=51, "*", IF(' . $alias . '.answer_no=52, "#", ' . $alias . '.answer_no)) AS CHAR) = T81IncomingResult.answer' . $pos_in_t81,
                            $alias . '.del_flag = "N"',
                        )
                    );
                    $options['conditions']['IF(' . $alias . '.answer_content <> "", ' . $alias . '.answer_content, T81IncomingResult.answer' . $referents[$pos_in_header_ques] . ') LIKE'] = "%" . $value_filter . "%";
                } elseif (isset($arr_pos_ques_auth[$pos_in_header_ques])) {
                    if (isset($arr_pos_ques_auth[$pos_in_header_ques]['recheck_button_next'])) {
                        $recheck_button_next = $arr_pos_ques_auth[$pos_in_header_ques]['recheck_button_next'];

                        $str_filter = 'IF(' . $recheck_button_next
                            . ' IN (T81IncomingResult.answer' . $referents[$pos_in_header_ques]
                            . ', T81IncomingResult.answer' . ($referents[$pos_in_header_ques] + 1)
                            . ', T81IncomingResult.answer' . ($referents[$pos_in_header_ques] + 2) . '), '
                            . $recheck_button_next
                            . ', COALESCE(T81IncomingResult.answer' . $referents[$pos_in_header_ques]
                            . ', T81IncomingResult.answer' . ($referents[$pos_in_header_ques] + 1)
                            . ', T81IncomingResult.answer' . ($referents[$pos_in_header_ques] + 2) . ')) LIKE';

                        $options['conditions'][$str_filter] = "%" . $value_filter . "%";
                    } elseif (isset($arr_pos_ques_auth[$pos_in_header_ques]['auth_item_column'])) {
                        if ($join_flag) {
                            $options['joins'][] = array(
                                'table' => 't57_inbound_tel_histories',
                                'alias' => 'T57InboundTelHistory',
                                'type' => 'left',
                                'conditions' => array(
                                    "T57InboundTelHistory.$item_main_column = T81IncomingResult.$join_col",
                                    'T57InboundTelHistory.inbound_id = T81IncomingResult.inbound_id',
                                    'T57InboundTelHistory.inbound_id = "' . $inbound_id . '"',
                                    'T57InboundTelHistory.del_flag = "N"',
                                )
                            );
                            $join_flag = false;
                        }

                        $auth_item_code = $arr_pos_ques_auth[$pos_in_header_ques]['auth_item_code'];
                        $auth_item_column = $arr_pos_ques_auth[$pos_in_header_ques]['auth_item_column'];
                        if (!in_array($value_filter, array('＜', '＝', '＞', '<', '=', '>'))) {
                            if (($value_filter == '≠')) {
                            	$str_filter1 = 'CAST(T81IncomingResult.answer' . $referents[$pos_in_header_ques] . ' AS UNSIGNED) '
		                                . '>'
		                                . ' ' . 'CAST(T57InboundTelHistory.' . $auth_item_column . ' AS UNSIGNED)';
	                            $str_filter2 = 'CAST(T81IncomingResult.answer' . $referents[$pos_in_header_ques] . ' AS UNSIGNED) '
		                                . '<'
		                                . ' ' . 'CAST(T57InboundTelHistory.' . $auth_item_column . ' AS UNSIGNED)';
		                        $options['conditions'][1]['OR'][$str_filter1] = 1;
		                        $options['conditions'][1]['OR'][$str_filter2] = 1;
                            } else {
                            	$options['conditions']['T81IncomingResult.answer' . $referents[$pos_in_header_ques]] = NULL;
                            }
                        } else {
	                        if ($auth_item_code == 'birthday') {
	                            $str_filter = 'CAST(T81IncomingResult.answer' . $referents[$pos_in_header_ques] . ' AS UNSIGNED) '
	                                . $value_filter
	                                . ' ' . 'CAST(STR_TO_DATE(T57InboundTelHistory.' . $auth_item_column . ', "%Y年%m月%d日") AS UNSIGNED)';
	                        } else {
	                            $str_filter = 'CAST(T81IncomingResult.answer' . $referents[$pos_in_header_ques] . ' AS UNSIGNED) '
	                                . $value_filter
	                                . ' ' . 'CAST(T57InboundTelHistory.' . $auth_item_column . ' AS UNSIGNED)';
	                        }
	                        $options['conditions'][$str_filter] = 1;
                    	}
                    }
                } elseif ($referents[$pos_in_header_ques] == 'fax_status') {
                    $question_no = $referents['fax_ques_no_'.$pos_in_header_ques];                    
                    $alias = 'T82BukkenFaxStatus' . $question_no;
                    $options['joins'][] = array(
                        'table' => 't82_bukken_fax_statuses',
                        'alias' => $alias,
                        'type' => 'left',
                        'conditions' => array(
                            $alias . '.log_id = T81IncomingResult.id',
                            $alias . '.fax_question_no = ' . $question_no,                            
                            $alias . '.del_flag = "N"',
                        )
                    );
                    $options['conditions'][ $alias . '.fax_status LIKE'] = "%" . $value_filter . "%";
                } elseif ($referents[$pos_in_header_ques] == 'inbound_sms_status' || $referents[$pos_in_header_ques] == 'inbound_sms_input_status') {
                    $smsStatusTitle = array(
                        '着信済み' => INBOUND_SMS_STATUS_SUCCESS,
                        '圏外' => INBOUND_SMS_STATUS_OUTSIDE,
                        '不明' => INBOUND_SMS_STATUS_UNKNOWN,
                        'エラー' => INBOUND_SMS_STATUS_ERROR,
                        '送信中' => INBOUND_SMS_STATUS_SENDING,
                        '' => INBOUND_SMS_STATUS_NO_SEND
                    );
                    if ($referents[$pos_in_header_ques] == 'inbound_sms_status'){
                        $question_no = $referents['inbound_sms_'.$pos_in_header_ques];
                    }elseif($referents[$pos_in_header_ques] == 'inbound_sms_input_status'){
                        $question_no = $referents['inbound_sms_input_'.$pos_in_header_ques];
                    }
                    
                    $alias = 'T86InboundSmsStatus' . $question_no;
                    $options['joins'][] = array(
                        'table' => 't86_inbound_sms_statuses',
                        'alias' => $alias,
                        'type' => 'left',
                        'conditions' => array(
                            $alias . '.log_id = T81IncomingResult.id',
                            $alias . '.sms_question_no = ' . $question_no,                            
                            $alias . '.del_flag = "N"',
                        )
                    );
                    $options['conditions'][ $alias . '.sms_status'] = $smsStatusTitle[$value_filter];
                } else {
                    if ($referents[$pos_in_header_ques] == 'trans_call_time') {
                        $options['conditions']['IF(UNIX_TIMESTAMP(T81IncomingResult.trans_cut_datetime) - UNIX_TIMESTAMP(T81IncomingResult.trans_connect_datetime) > 0, FROM_UNIXTIME(UNIX_TIMESTAMP(T81IncomingResult.trans_cut_datetime) - UNIX_TIMESTAMP(T81IncomingResult.trans_connect_datetime), "%i:%s"), "") LIKE'] = "%" . $value_filter . "%";
                    } else {
                        $options['conditions']['T81IncomingResult.answer' . $referents[$pos_in_header_ques] . ' LIKE'] = "%" . $value_filter . "%";
                    }
                }
            }
        }

        return $this->find('count', $options);
    }

    function getAllByScheduleId($inbound_id = null, $item_main_column = null, $join_col = null, $ans_only = null, $date_from=null, $date_to=null, $valid_del_flag = false) {
        $options['fields'] = array(
            'T81IncomingResult.*'
        );

        if (isset($item_main_column) && isset($join_col)) {
            $options['fields'][] = 'T57InboundTelHistory.*';
            $options['joins'] = array(
                array(
                    'table' => 't57_inbound_tel_histories',
                    'alias' => 'T57InboundTelHistory',
                    'type' => 'left',
                    'conditions' => array(
                        "T57InboundTelHistory.$item_main_column = T81IncomingResult.$join_col",
                        'T57InboundTelHistory.inbound_id = T81IncomingResult.inbound_id',
                        'T57InboundTelHistory.del_flag = "N"',
                    )
                ),
            );
        }
        $options['conditions'] = array(
            'T81IncomingResult.inbound_id' => $inbound_id,
        );

        if ($valid_del_flag) {
            $options['conditions']['T81IncomingResult.del_flag'] = "N";
        }
        if ($ans_only) {
            $options['conditions'][] = 'SUBSTR(T81IncomingResult.ans_accuracy,1,POSITION("/" IN T81IncomingResult.ans_accuracy) - 1) > 0';
            $options['conditions'][] = 'SUBSTR(T81IncomingResult.ans_accuracy,1,POSITION("/" IN T81IncomingResult.ans_accuracy) - 1) = SUBSTR(T81IncomingResult.ans_accuracy,POSITION("/" IN T81IncomingResult.ans_accuracy) + 1)';
        }
        if (isset($date_from) && $date_from) {
            $options['conditions']['T81IncomingResult.call_datetime >='] = $date_from . ' 00:00:00';
        }
        if (isset($date_to) && $date_to) {
            $options['conditions']['T81IncomingResult.call_datetime <='] = $date_to . ' 23:59:59';
        }
        $options['order'] = array(
        	'T81IncomingResult.call_datetime asc',
        );
        return $this->find('all', $options);
    }
		
		function getallbyscheduleid_inboundcollation($inbound_id = null, $item_main_column = null, $join_col = null, $ans_only = null, $date_from=null, $date_to=null, $valid_del_flag = false) {
				$options['fields'] = array(
						'T81IncomingResult.*'
				);

				if (isset($item_main_column) && isset($join_col)) {
						$options['fields'][] = 'T57InboundTelHistory.*';
						$options['joins'] = array(
								array(
										'table' => 't57_inbound_tel_histories',
										'alias' => 'T57InboundTelHistory',
										'type' => 'left',
										'conditions' => array(
												"T57InboundTelHistory.$item_main_column = SUBSTRING_INDEX(T81IncomingResult.$join_col,':',1)",
												'T57InboundTelHistory.inbound_id = T81IncomingResult.inbound_id',
												'T57InboundTelHistory.del_flag = "N"',
										)
								),
						);
				}
				$options['conditions'] = array(
						'T81IncomingResult.inbound_id' => $inbound_id,
				);
				if ($valid_del_flag) {
					$options['conditions']['T81IncomingResult.del_flag'] = "N";
				}
				if ($ans_only) {
						$options['conditions'][] = 'SUBSTR(T81IncomingResult.ans_accuracy,1,POSITION("/" IN T81IncomingResult.ans_accuracy) - 1) > 0';
						$options['conditions'][] = 'SUBSTR(T81IncomingResult.ans_accuracy,1,POSITION("/" IN T81IncomingResult.ans_accuracy) - 1) = SUBSTR(T81IncomingResult.ans_accuracy,POSITION("/" IN T81IncomingResult.ans_accuracy) + 1)';
				}
				if (isset($date_from) && $date_from) {
						$options['conditions']['T81IncomingResult.call_datetime >='] = $date_from . ' 00:00:00';
				}
				if (isset($date_to) && $date_to) {
						$options['conditions']['T81IncomingResult.call_datetime <='] = $date_to . ' 23:59:59';
				}
				$options['order'] = array(
					'T81IncomingResult.call_datetime asc',
				);
				return $this->find('all', $options);
		}
		
}