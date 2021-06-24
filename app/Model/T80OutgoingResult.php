<?php

/**
 * T80OutgoingResult model.
 */
class T80OutgoingResult extends AppModel {
    var $name = 'T80OutgoingResult';

    function importUtilComponent()
    {
       App::import('Component','UtilComponent');
       // new ComponentCollection()が無いとErrorが発生する。
       // Argument 1 passed to Component::__construct() must be an instance of ComponentCollection,
       $gc = new UtilComponent(new ComponentCollection());
       return $gc;
    }

    function getNumCalled($schedule_id) {
        $options['conditions'] = array(
            'T80OutgoingResult.schedule_id' => $schedule_id,
        );

        return $this->find('count', $options);
    }

    // スケジュール詳細画面で「接続件数」として採用する。
    // $no_answerで指定したもの以外は全て未接続となる。
    function getNumConnect($schedule_id) {

        $no_answer = $this->importUtilComponent()->getCallResultConnectStatusArray();
        $options['conditions'] = array(
            'T80OutgoingResult.schedule_id' => $schedule_id,
            'T80OutgoingResult.status IN' => $no_answer,
        );

        return $this->find('count', $options);
    }

    // スケジュール詳細画面で「スキップ件数」として採用する。
    // recover＝apdlgのリカバーを指す。従って、このステータスの番号に電話がかかったか同かはわからない状態。
    function getNumSkip($schedule_id) {
        $options['conditions'] = array(
            'T80OutgoingResult.schedule_id' => $schedule_id,
            'T80OutgoingResult.status' => 'recover',
        );

        return $this->find('count', $options);
    }

    function getStatisticAnsByQuesNum($schedule_id, $question_num, $group_flag=false) {
        $options['fields'] = array(
            'T80OutgoingResult.answer' . $question_num,
            'count(*) as total_choose'
        );

        $options ['conditions'] = array(
            'T80OutgoingResult.schedule_id' => $schedule_id,
            'T80OutgoingResult.answer' . $question_num . ' <> ""',
        );

        if ($group_flag) {
            $options['group'] = array(
                'T80OutgoingResult.answer' . $question_num
            );
        }

        return $this->find('all', $options);
    }

    function getStatisticAuthQues($schedule_id, $question_num, $tel_column, $auth_item_column, $auth_item_code) {
        if ($auth_item_code == 'birthday') {
            $options['fields'] = array(
                'SUM(IF(CAST(T80OutgoingResult.answer' . $question_num . ' AS UNSIGNED) < CAST(STR_TO_DATE(T51TelHistory.' . $auth_item_column . ', "%Y年%m月%d日") AS UNSIGNED), 1, 0)) as total_choose_1',
                'SUM(IF(CAST(T80OutgoingResult.answer' . $question_num . ' AS UNSIGNED) = CAST(STR_TO_DATE(T51TelHistory.' . $auth_item_column . ', "%Y年%m月%d日") AS UNSIGNED), 1, 0)) as total_choose_2',
                'SUM(IF(CAST(T80OutgoingResult.answer' . $question_num . ' AS UNSIGNED) > CAST(STR_TO_DATE(T51TelHistory.' . $auth_item_column . ', "%Y年%m月%d日") AS UNSIGNED), 1, 0)) as total_choose_3',
            );
        } else {
            $options['fields'] = array(
                'SUM(IF(CAST(T80OutgoingResult.answer' . $question_num . ' AS UNSIGNED) < CAST(T51TelHistory.' . $auth_item_column . ' AS UNSIGNED), 1, 0)) as total_choose_1',
                'SUM(IF(CAST(T80OutgoingResult.answer' . $question_num . ' AS UNSIGNED) = CAST(T51TelHistory.' . $auth_item_column . ' AS UNSIGNED), 1, 0)) as total_choose_2',
                'SUM(IF(CAST(T80OutgoingResult.answer' . $question_num . ' AS UNSIGNED) > CAST(T51TelHistory.' . $auth_item_column . ' AS UNSIGNED), 1, 0)) as total_choose_3',
            );
        }

        $options['joins'] = array(
            array(
                'table' => 't51_tel_histories',
                'alias' => 'T51TelHistory',
                'type' => 'left',
                'conditions' => array(
                    'T51TelHistory.' . $tel_column . ' = T80OutgoingResult.tel_no',
                    'T51TelHistory.schedule_id = T80OutgoingResult.schedule_id',
                    'T51TelHistory.schedule_id = "' . $schedule_id . '"',
                    'T51TelHistory.del_flag = "N"',
                )
            ),
        );

        $options ['conditions'] = array(
            'T80OutgoingResult.schedule_id' => $schedule_id,
            'T80OutgoingResult.answer' . $question_num . ' != ""',
            'T51TelHistory.' . $auth_item_column . ' != ""',
        );

        return $this->find('first', $options);
    }

    function getStatisticAuthCharQues($schedule_id, $question_num, $tel_column, $auth_item_column, $auth_item_code) {
        if ($auth_item_code == 'birthday') {
            $options['fields'] = array(
                'SUM(IF(CAST(T80OutgoingResult.answer' . $question_num . ' AS UNSIGNED) = CAST(STR_TO_DATE(T51TelHistory.' . $auth_item_column . ', "%Y年%m月%d日") AS UNSIGNED), 1, 0)) as total_choose_1',
                'SUM(IF(CAST(T80OutgoingResult.answer' . $question_num . ' AS UNSIGNED) <> CAST(STR_TO_DATE(T51TelHistory.' . $auth_item_column . ', "%Y年%m月%d日") AS UNSIGNED), 1, 0)) as total_choose_2',
            );
        } else {
            $options['fields'] = array(
                'SUM(IF(CAST(T80OutgoingResult.answer' . $question_num . ' AS UNSIGNED) = CAST(T51TelHistory.' . $auth_item_column . ' AS UNSIGNED), 1, 0)) as total_choose_1',
                'SUM(IF(CAST(T80OutgoingResult.answer' . $question_num . ' AS UNSIGNED) <> CAST(T51TelHistory.' . $auth_item_column . ' AS UNSIGNED), 1, 0)) as total_choose_2',
            );
        }

        $options['joins'] = array(
            array(
                'table' => 't51_tel_histories',
                'alias' => 'T51TelHistory',
                'type' => 'left',
                'conditions' => array(
                    'T51TelHistory.' . $tel_column . ' = T80OutgoingResult.tel_no',
                    'T51TelHistory.schedule_id = T80OutgoingResult.schedule_id',
                    'T51TelHistory.schedule_id = "' . $schedule_id . '"',
                    'T51TelHistory.del_flag = "N"',
                )
            ),
        );

        $options ['conditions'] = array(
            'T80OutgoingResult.schedule_id' => $schedule_id,
            'T80OutgoingResult.answer' . $question_num . ' != ""',
            'T51TelHistory.' . $auth_item_column . ' != ""',
        );

        return $this->find('first', $options);
    }

    function getAllByScheduleId($schedule_id=null, $ans_only=null, $tel_column=null, $date_from=null, $date_to=null, $valid_del_flag = false) {
        $options['fields'] = array(
            'T80OutgoingResult.*',
            'T51TelHistory.*'
        );
        $options['joins'] = array(
            array(
                'table' => 't51_tel_histories',
                'alias' => 'T51TelHistory',
                'type' => 'left',
                'conditions' => array(
                    'T51TelHistory.' . $tel_column . ' = T80OutgoingResult.tel_no',
                    'T51TelHistory.schedule_id = T80OutgoingResult.schedule_id',
                    'T51TelHistory.schedule_id = "' . $schedule_id . '"',
                    'T51TelHistory.del_flag = "N"',
                )
            ),
        );
        /*20161129 Add by Linh : #8852 - get sms data - BEGIN*/
        /*if ($get_sms) {
            $joinSms = array(
                array(
                    'table' => 't83_outgoing_sms_statuses',
                    'alias' => 'T83OutgoingSmsStatus',
                    'type' => 'left',
                    'conditions' => array(
                        'T83OutgoingSmsStatus.tel_no = T80OutgoingResult.tel_no',
                        'T83OutgoingSmsStatus.schedule_id = T80OutgoingResult.schedule_id',
                        'T83OutgoingSmsStatus.schedule_id = "' . $schedule_id . '"',
                        'T83OutgoingSmsStatus.del_flag = "N"',
                    )
                )
            );
            $options['joins'] = array_merge($options['joins'], $joinSms);
            $options['fields'] = array_merge($options['fields'], array('T83OutgoingSmsStatus.message as sms_message', 'T83OutgoingSmsStatus.sms_status'));
        }*/
        /*20161129 Add by Linh : #8852 - get sms data - END*/
        $options['conditions'] = array(
            'T80OutgoingResult.schedule_id' => $schedule_id,
        );

        if ($valid_del_flag) {
            $options['conditions']['T80OutgoingResult.del_flag'] = "N";
        }
        if (isset($ans_only) && $ans_only) {
            $options['conditions'][] = 'SUBSTR(T80OutgoingResult.ans_accuracy,1,POSITION("/" IN T80OutgoingResult.ans_accuracy) - 1) > 0';
            $options['conditions'][] = 'SUBSTR(T80OutgoingResult.ans_accuracy,1,POSITION("/" IN T80OutgoingResult.ans_accuracy) - 1) = SUBSTR(T80OutgoingResult.ans_accuracy,POSITION("/" IN T80OutgoingResult.ans_accuracy) + 1)';
        }
        if (isset($date_from) && $date_from) {
            $options['conditions']['T80OutgoingResult.call_datetime >='] = $date_from . ' 00:00:00';
        }
        if (isset($date_to) && $date_to) {
            $options['conditions']['T80OutgoingResult.call_datetime <='] = $date_to . ' 23:59:59';
        }
        $options['order'] = array(
        	'T80OutgoingResult.call_datetime asc',
        );
        return $this->find('all', $options);
    }

    // Outのテンプレート詳細画面の詳細ポップアップの表。
    // $schedule_id：表示している発信設定のt20.id
    // $tel_column：発信リストの「電話番号」の位置("customizeX"で表現)
    // $limit：最大取得件数。常に20固定
    // $page：表示ページ数
    // $sort_order：表示ページ数
    // $filter：フィルター(where句で利用する。 see function getScheduleDetailSortOrder)
    // $referents：
    // $arr_pos_ques_basic：
    // $arr_pos_ques_auth：
    function getResultByScheduleId($schedule_id=null, $tel_column=null, $limit=null, $page=null, $sort_order=null, $filter=null, $referents=array(), $arr_pos_ques_basic=array(), $arr_pos_ques_auth=array()) {

        $myUtil = $this->importUtilComponent();

        $options['fields'] = array(
            'T80OutgoingResult.*',
             'T51TelHistory.*'
        );
         $options['joins'] = array(
             array(
                 'table' => 't51_tel_histories',
                 'alias' => 'T51TelHistory',
                 'type' => 'left',
                 'conditions' => array(
                     'T51TelHistory.' . $tel_column . ' = T80OutgoingResult.tel_no',
                     'T51TelHistory.schedule_id = T80OutgoingResult.schedule_id',
                     'T51TelHistory.schedule_id = "' . $schedule_id . '"',
                     'T51TelHistory.del_flag = "N"',
                 )
             ),
        );

        $options['conditions'] = array(
            'T80OutgoingResult.schedule_id' => $schedule_id,
        );

        //20160324 Edit by Thai : #6779 - update filter when have tran ques - Begin
        $index = 0;
        $attr_filters = array(
            // 発信日時のフィルタの際に利用
            $index++ => 'T80OutgoingResult.call_datetime',
            // 発信先のフィルタの際に利用
            $index++ => 'T80OutgoingResult.tel_no',
            // 接続時間のフィルタの際に利用
            $index++ => 'IF(T80OutgoingResult.status IN (' . $myUtil->getCallResultConnectStatusString() . '), FROM_UNIXTIME(UNIX_TIMESTAMP(T80OutgoingResult.cut_datetime) - UNIX_TIMESTAMP(T80OutgoingResult.connect_datetime), "%i:%s"), "")',
            //20160222 Edit by Thai : #6464 - update search by status result
        );
        //20160329 Delete by Thai : update format tran ques - Begin
/*        if ($have_tran_ques) {
            $attr_filters[$index++] = 'IF(UNIX_TIMESTAMP(T80OutgoingResult.trans_cut_datetime) - UNIX_TIMESTAMP(T80OutgoingResult.trans_connect_datetime) > 0, FROM_UNIXTIME(UNIX_TIMESTAMP(T80OutgoingResult.trans_cut_datetime) - UNIX_TIMESTAMP(T80OutgoingResult.trans_connect_datetime), "%i:%s"), "")';
        }*/
        //20160329 Delete by Thai : update format tran ques - End

        // ステータスのフィルタの際に利用
        $attr_filters[$index] = 'IF(T80OutgoingResult.status = "connect", "ANSWER", IF(T80OutgoingResult.status = "recover", "SKIP", IF(T80OutgoingResult.status in (' . $myUtil->getCallResultConvertTFRejectString(). '), "TRANSFERREJECT", IF(T80OutgoingResult.status IN (' . $myUtil->getCallResultNoConvertString() . '), UPPER(T80OutgoingResult.status), "NOANSWER"))))';
        //20160324 Edit by Thai : #6779 - update filter when have tran ques - End

        if(isset($filter) && !empty($filter)){
            foreach ($filter as $pos_in_header => $value_filter) {
                $pos_in_header_ques = $pos_in_header - sizeof($attr_filters) + 1;
                if (isset($attr_filters[$pos_in_header])) {
                    //20160222 Edit by Thai : #6464 - update search by status result - Begin
                    if ($pos_in_header == $index) {
                        $options['conditions'][$attr_filters[$pos_in_header] . ' = '] = $value_filter;
                    } else {
                        $options['conditions'][$attr_filters[$pos_in_header] . ' LIKE'] = "%" . $value_filter . "%";
                    }
                    //20160222 Edit by Thai : #6464 - update search by status result - End
                } elseif (isset($arr_pos_ques_basic[$pos_in_header_ques])) {
                    $question_no = $arr_pos_ques_basic[$pos_in_header_ques];
                    $alias = 'T62ButtonHistory' . $question_no;
                    $pos_in_t80 = $referents[$pos_in_header_ques];

                    $options['joins'][] = array(
                        'table' => 't62_button_histories',
                        'alias' => $alias,
                        'type' => 'left',
                        'conditions' => array(
                            $alias . '.schedule_id = T80OutgoingResult.schedule_id',
                            $alias . '.question_no = ' . $question_no,
                            'CAST(IF(' . $alias . '.answer_no=51, "*", IF(' . $alias . '.answer_no=52, "#", ' . $alias . '.answer_no)) AS CHAR) = T80OutgoingResult.answer' . $pos_in_t80,
                            $alias . '.del_flag = "N"',
                        )
                    );
                    $options['conditions']['IF(' . $alias . '.answer_content <> "", ' . $alias . '.answer_content, T80OutgoingResult.answer' . $referents[$pos_in_header_ques] . ') LIKE'] = "%" . $value_filter . "%";
                } elseif (isset($arr_pos_ques_auth[$pos_in_header_ques])) {
                    if (isset($arr_pos_ques_auth[$pos_in_header_ques]['recheck_button_next'])) {
                        $recheck_button_next = $arr_pos_ques_auth[$pos_in_header_ques]['recheck_button_next'];

                        $str_filter = 'IF(' . $recheck_button_next
                            . ' IN (T80OutgoingResult.answer' . $referents[$pos_in_header_ques]
                            . ', T80OutgoingResult.answer' . ($referents[$pos_in_header_ques] + 1)
                            . ', T80OutgoingResult.answer' . ($referents[$pos_in_header_ques] + 2) . '), '
                            . $recheck_button_next
                            . ', COALESCE(T80OutgoingResult.answer' . $referents[$pos_in_header_ques]
                            . ', T80OutgoingResult.answer' . ($referents[$pos_in_header_ques] + 1)
                            . ', T80OutgoingResult.answer' . ($referents[$pos_in_header_ques] + 2) . ')) LIKE';

                        $options['conditions'][$str_filter] = "%" . $value_filter . "%";
                    } elseif (isset($arr_pos_ques_auth[$pos_in_header_ques]['auth_item_column'])) {
                        $auth_item_code = $arr_pos_ques_auth[$pos_in_header_ques]['auth_item_code'];
                        $auth_item_column = $arr_pos_ques_auth[$pos_in_header_ques]['auth_item_column'];
                        if ($auth_item_code == 'birthday') {
                            $str_filter = 'CAST(T80OutgoingResult.answer' . $referents[$pos_in_header_ques] . ' AS UNSIGNED) '
                                . $this->convertFilter($value_filter)
                                . ' ' . 'CAST(STR_TO_DATE(T51TelHistory.' . $auth_item_column . ', "%Y年%m月%d日") AS UNSIGNED)';
                        } else {
                            $str_filter = 'CAST(T80OutgoingResult.answer' . $referents[$pos_in_header_ques] . ' AS UNSIGNED) '
                                . $this->convertFilter($value_filter)
                                . ' ' . 'CAST(T51TelHistory.' . $auth_item_column . ' AS UNSIGNED)';
                        }
                        $options['conditions'][$str_filter] = 1;
                    }
                } else {
                    //20160329 Update by Thai : update format tran ques - Begin
                    if ($referents[$pos_in_header_ques] == 'trans_call_time') {
                        $options['conditions']['IF(UNIX_TIMESTAMP(T80OutgoingResult.trans_cut_datetime) - UNIX_TIMESTAMP(T80OutgoingResult.trans_connect_datetime) > 0, FROM_UNIXTIME(UNIX_TIMESTAMP(T80OutgoingResult.trans_cut_datetime) - UNIX_TIMESTAMP(T80OutgoingResult.trans_connect_datetime), "%i:%s"), "") LIKE'] = "%" . $value_filter . "%";
                    } else {
                        $options['conditions']['T80OutgoingResult.answer' . $referents[$pos_in_header_ques] . ' LIKE'] = "%" . $value_filter . "%";
                    }
                    //20160329 Update by Thai : update format tran ques - End
                }
            }
        }

        if(isset($sort_order) && !empty($sort_order)){
            if (strpos($sort_order[0], 'T62ButtonHistory') !== false) {
                $pos_in_header = $sort_order[1];
                unset($sort_order[1]);

                preg_match_all('/T62ButtonHistory[0-9]+/', $sort_order[0], $alias_tmp);
                $alias = $alias_tmp[0][0];

                $join_flag = true;
                foreach ($options['joins'] as $table_join) {
                    if ($table_join['alias'] == $alias) {
                        $join_flag = false;
                        break;
                    }
                }

                if ($join_flag) {
                    $question_no = substr($alias, strlen('T62ButtonHistory'));
                    $pos_in_t80 = $referents[$pos_in_header];
                    $options['joins'][] = array(
                        'table' => 't62_button_histories',
                        'alias' => $alias,
                        'type' => 'left',
                        'conditions' => array(
                            $alias . '.schedule_id = T80OutgoingResult.schedule_id',
                            $alias . '.question_no = ' . $question_no,
                            'CAST(IF(' . $alias . '.answer_no=51, "*", IF(' . $alias . '.answer_no=52, "#", ' . $alias . '.answer_no)) AS CHAR) = T80OutgoingResult.answer' . $pos_in_t80,
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
    function getCountByScheduleId($schedule_id=null, $tel_column=null, $filter=null, $referents=array(), $arr_pos_ques_basic=array(), $arr_pos_ques_auth=array()) {

        $myUtil = $this->importUtilComponent();

        $options['fields'] = array(
            'T80OutgoingResult.*',
        );

        $options['conditions'] = array(
            'T80OutgoingResult.schedule_id' => $schedule_id,
        );

        //20160324 Edit by Thai : #6779 - update filter when have tran ques - Begin
        $index = 0;
        $attr_filters = array(
            $index++ => 'T80OutgoingResult.call_datetime',
            $index++ => 'T80OutgoingResult.tel_no',
            $index++ => 'IF(T80OutgoingResult.status IN (' . $myUtil->getCallResultConnectStatusString(). '), FROM_UNIXTIME(UNIX_TIMESTAMP(T80OutgoingResult.cut_datetime) - UNIX_TIMESTAMP(T80OutgoingResult.connect_datetime), "%i:%s"), "")',
            //20160222 Edit by Thai : #6464 - update search by status result
        );
        //20160329 Delete by Thai : update format tran ques - Begin
/*        if ($have_tran_ques) {
            $attr_filters[$index++] = 'IF(UNIX_TIMESTAMP(T80OutgoingResult.trans_cut_datetime) - UNIX_TIMESTAMP(T80OutgoingResult.trans_connect_datetime) > 0, FROM_UNIXTIME(UNIX_TIMESTAMP(T80OutgoingResult.trans_cut_datetime) - UNIX_TIMESTAMP(T80OutgoingResult.trans_connect_datetime), "%i:%s"), "")';
        }*/
        //20160329 Delete by Thai : update format tran ques - End
        $attr_filters[$index] = 'IF(T80OutgoingResult.status = "connect", "ANSWER", IF(T80OutgoingResult.status = "recover", "SKIP", IF(T80OutgoingResult.status in (' . $myUtil->getCallResultConvertTFRejectString(). '), "TRANSFERREJECT", IF(T80OutgoingResult.status IN (' . $myUtil->getCallResultNoConvertString(). '), UPPER(T80OutgoingResult.status), "NOANSWER"))))';
        //20160324 Edit by Thai : #6779 - update filter when have tran ques - End

        if(isset($filter) && !empty($filter)){
            $join_flag = true;
            foreach ($filter as $pos_in_header => $value_filter) {
                $pos_in_header_ques = $pos_in_header - sizeof($attr_filters) + 1;
                if (isset($attr_filters[$pos_in_header])) {
                    //20160222 Edit by Thai : #6464 - update search by status result - Begin
                    if ($pos_in_header == $index) {
                        $options['conditions'][$attr_filters[$pos_in_header] . ' = '] = $value_filter;
                    } else {
                        $options['conditions'][$attr_filters[$pos_in_header] . ' LIKE'] = "%" . $value_filter . "%";
                    }
                    //20160222 Edit by Thai : #6464 - update search by status result - End
                } elseif (isset($arr_pos_ques_basic[$pos_in_header_ques])) {
                    $question_no = $arr_pos_ques_basic[$pos_in_header_ques];
                    $alias = 'T62ButtonHistory' . $question_no;
                    $pos_in_t80 = $referents[$pos_in_header_ques];

                    $options['joins'][] = array(
                        'table' => 't62_button_histories',
                        'alias' => $alias,
                        'type' => 'left',
                        'conditions' => array(
                            $alias . '.schedule_id = T80OutgoingResult.schedule_id',
                            $alias . '.question_no = ' . $question_no,
                            'CAST(IF(' . $alias . '.answer_no=51, "*", IF(' . $alias . '.answer_no=52, "#", ' . $alias . '.answer_no)) AS CHAR) = T80OutgoingResult.answer' . $pos_in_t80,
                            $alias . '.del_flag = "N"',
                        )
                    );
                    $options['conditions']['IF(' . $alias . '.answer_content <> "", ' . $alias . '.answer_content, T80OutgoingResult.answer' . $referents[$pos_in_header_ques] . ') LIKE'] = "%" . $value_filter . "%";
                } elseif (isset($arr_pos_ques_auth[$pos_in_header_ques])) {
                    if (isset($arr_pos_ques_auth[$pos_in_header_ques]['recheck_button_next'])) {
                        $recheck_button_next = $arr_pos_ques_auth[$pos_in_header_ques]['recheck_button_next'];

                        $str_filter = 'IF(' . $recheck_button_next
                            . ' IN (T80OutgoingResult.answer' . $referents[$pos_in_header_ques]
                            . ', T80OutgoingResult.answer' . ($referents[$pos_in_header_ques] + 1)
                            . ', T80OutgoingResult.answer' . ($referents[$pos_in_header_ques] + 2) . '), '
                            . $recheck_button_next
                            . ', COALESCE(T80OutgoingResult.answer' . $referents[$pos_in_header_ques]
                            . ', T80OutgoingResult.answer' . ($referents[$pos_in_header_ques] + 1)
                            . ', T80OutgoingResult.answer' . ($referents[$pos_in_header_ques] + 2) . ')) LIKE';

                        $options['conditions'][$str_filter] = "%" . $value_filter . "%";
                    } elseif (isset($arr_pos_ques_auth[$pos_in_header_ques]['auth_item_column'])) {
                        if ($join_flag) {
                            $options['joins'][] = array(
                                'table' => 't51_tel_histories',
                                'alias' => 'T51TelHistory',
                                'type' => 'left',
                                'conditions' => array(
                                    'T51TelHistory.' . $tel_column . ' = T80OutgoingResult.tel_no',
                                    'T51TelHistory.schedule_id = T80OutgoingResult.schedule_id',
                                    'T51TelHistory.schedule_id = "' . $schedule_id . '"',
                                    'T51TelHistory.del_flag = "N"',
                                )
                            );
                            $join_flag = false;
                        }

                        $auth_item_code = $arr_pos_ques_auth[$pos_in_header_ques]['auth_item_code'];
                        $auth_item_column = $arr_pos_ques_auth[$pos_in_header_ques]['auth_item_column'];
                        if ($auth_item_code == 'birthday') {
                            $str_filter = 'CAST(T80OutgoingResult.answer' . $referents[$pos_in_header_ques] . ' AS UNSIGNED) '
                                . $this->convertFilter($value_filter)
                                . ' ' . 'CAST(STR_TO_DATE(T51TelHistory.' . $auth_item_column . ', "%Y年%m月%d日") AS UNSIGNED)';
                        } else {
                            $str_filter = 'CAST(T80OutgoingResult.answer' . $referents[$pos_in_header_ques] . ' AS UNSIGNED) '
                                . $this->convertFilter($value_filter)
                                . ' ' . 'CAST(T51TelHistory.' . $auth_item_column . ' AS UNSIGNED)';
                        }
                        $options['conditions'][$str_filter] = 1;
                    }
                } else {
                    //20160329 Update by Thai : update format tran ques - Begin
                    if ($referents[$pos_in_header_ques] == 'trans_call_time') {
                        $options['conditions']['IF(UNIX_TIMESTAMP(T80OutgoingResult.trans_cut_datetime) - UNIX_TIMESTAMP(T80OutgoingResult.trans_connect_datetime) > 0, FROM_UNIXTIME(UNIX_TIMESTAMP(T80OutgoingResult.trans_cut_datetime) - UNIX_TIMESTAMP(T80OutgoingResult.trans_connect_datetime), "%i:%s"), "") LIKE'] = "%" . $value_filter . "%";
                    } else {
                        $options['conditions']['T80OutgoingResult.answer' . $referents[$pos_in_header_ques] . ' LIKE'] = "%" . $value_filter . "%";
                    }
                    //20160329 Update by Thai : update format tran ques - End
                }
            }
        }

        return $this->find('count', $options);
    }

    /**
     * 絞り込み条件として、画面で「≠」が入力された場合
     * SQLの条件に使用出来ないので変換する
     *
     * @param string $input_filter 画面で入力したフィルター
     * @return string 変換後のフィルター
     */
    function convertFilter($input_filter)
    {
        if ($input_filter == '≠') {
            return '<>';
        }

        return $input_filter;
    }
}
