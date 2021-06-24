<?php

class T20OutSchedule extends AppModel {
    var $name = 'T20OutSchedule';

    /**
     * Get Schedule By Company Id
     */
    function getScheduleByCompanyId($company_id=null, $limit=null, $page=null, $sort_order=null, $filter=null) {
        $options['fields'] = array(
            'T20OutSchedule.*',
			'M05User.user_name',
            'T30Template.question_total',
			'T21OutTime.time_start',
			'IF(T20OutSchedule.status = "' . STATUS_FINISH . '", T50ListHistory.list_name, T10CallList.list_name) as list_name',
			'IF(T20OutSchedule.status = "' . STATUS_FINISH . '", T50ListHistory.tel_total, T10CallList.tel_total) as tel_total',
			'IF(T20OutSchedule.status = "' . STATUS_FINISH . '", T60TemplateHistory.template_name, T30Template.template_name) as template_name'
        );
        $options['joins'] = array(
			array(
				'table' => 't21_out_times',
				'alias' => 'T21OutTime',
				'type' => 'inner',
				'conditions' => array(
					'T21OutTime.schedule_id = T20OutSchedule.id',
				)
			),
			array(
				'table' => 't10_call_lists',
				'alias' => 'T10CallList',
				'type' => 'left',
				'conditions' => array(
					'T10CallList.id = T20OutSchedule.list_id',
					'T10CallList.del_flag = "N"',
				)
			),
			array(
				'table' => 't50_list_histories',
				'alias' => 'T50ListHistory',
				'type' => 'left',
				'conditions' => array(
					'T50ListHistory.schedule_id = T20OutSchedule.id',
					'T50ListHistory.list_id = T20OutSchedule.list_id',
					'T50ListHistory.del_flag = "N"',
				)
			),
			array(
				'table' => 't30_templates',
				'alias' => 'T30Template',
				'type' => 'left',
				'conditions' => array(
					'T30Template.id = T20OutSchedule.template_id',
					'T30Template.del_flag = "N"',
				)
			),
			array(
				'table' => 't60_template_histories',
				'alias' => 'T60TemplateHistory',
				'type' => 'left',
				'conditions' => array(
					'T60TemplateHistory.schedule_id = T20OutSchedule.id',
					'T60TemplateHistory.del_flag = "N"',
				)
			),
			array(
				'table' => 'm05_users',
				'alias' => 'M05User',
				'type' => 'left',
				'conditions' => array(
					'M05User.user_id = T20OutSchedule.entry_user',
				)
			),
        );

        $options['conditions']['T20OutSchedule.del_flag'] = "N";
		$options['conditions']['T20OutSchedule.company_id'] = $company_id;
		$options['conditions']['T21OutTime.del_flag'] = "N";


        if(isset($filter) && !empty($filter)){
        	if(isset($filter[1])){
        		$options['conditions']['T20OutSchedule.schedule_no LIKE'] = "%".$filter[1]."%";
        	}
        	if(isset($filter[2])){
        		$options['conditions']['T20OutSchedule.schedule_name LIKE'] = "%".$filter[2]."%";
        	}
        	if(isset($filter[3])){
        		$options['conditions']['SUBSTR(T21OutTime.time_start, 1, 10) LIKE'] = "%".$filter[3]."%";
        	}
			//20160328 - Add by Thai - Fix filter by call_time - Begin
			if(isset($filter[4])){
				$options['conditions']['OR']['SUBSTR(T21OutTime.time_start, 12) LIKE'] = "%".$filter[4]."%";
				$options['conditions']['OR']['SUBSTR(T21OutTime.time_end, 12) LIKE'] = "%".$filter[4]."%";
			}
			//20160328 - Add by Thai - Fix filter by call_time - End
			if(isset($filter[5])){
				$options['conditions']['IF(T20OutSchedule.status = "' . STATUS_FINISH . '", T60TemplateHistory.template_name, T30Template.template_name) LIKE'] = "%".$filter[5]."%";
			}
			if(isset($filter[6])){
				$options['conditions']['IF(T20OutSchedule.status = "' . STATUS_FINISH . '", T50ListHistory.list_name, T10CallList.list_name) LIKE'] = "%".$filter[6]."%";
			}
			/*if(isset($filter[7])){
				$options['conditions']['IF(T20OutSchedule.status = "' . STATUS_FINISH . '", T50ListHistory.tel_total, T10CallList.tel_total) LIKE'] = "%".$filter[7]."%";
			}*/
			if(isset($filter[8])){
				$options['conditions']['T20OutSchedule.called_total LIKE'] = "%".$filter[8]."%";
			}
			if(isset($filter[9])){
				$options['conditions']['SUBSTR(T20OutSchedule.created, 1, 16) LIKE'] = "%".$filter[9]."%";
			}
			if(isset($filter[10])){
				$options['conditions']['M05User.user_name LIKE'] = "%".$filter[10]."%";
			}
        }
		$options['group'] = array('T20OutSchedule.id');
        if(isset($sort_order) && !empty($sort_order)){
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
    function getScheduleByCompanyIdCount($company_id=null, $filter) {
    	$options['fields'] = array(
            'COUNT(DISTINCT T20OutSchedule.id) AS total',
    	);
		$options['joins'] = array(
			array(
				'table' => 't21_out_times',
				'alias' => 'T21OutTime',
				'type' => 'inner',
				'conditions' => array(
					'T21OutTime.schedule_id = T20OutSchedule.id',
				)
			),
			array(
				'table' => 't10_call_lists',
				'alias' => 'T10CallList',
				'type' => 'left',
				'conditions' => array(
					'T10CallList.id = T20OutSchedule.list_id',
					'T10CallList.del_flag = "N"',
				)
			),
			array(
				'table' => 't50_list_histories',
				'alias' => 'T50ListHistory',
				'type' => 'left',
				'conditions' => array(
					'T50ListHistory.schedule_id = T20OutSchedule.id',
					'T50ListHistory.list_id = T20OutSchedule.list_id',
					'T50ListHistory.del_flag = "N"',
				)
			),
			array(
				'table' => 't30_templates',
				'alias' => 'T30Template',
				'type' => 'left',
				'conditions' => array(
					'T30Template.id = T20OutSchedule.template_id',
					'T30Template.del_flag = "N"',
				)
			),
			array(
				'table' => 't60_template_histories',
				'alias' => 'T60TemplateHistory',
				'type' => 'left',
				'conditions' => array(
					'T60TemplateHistory.schedule_id = T20OutSchedule.id',
					'T60TemplateHistory.template_id = T20OutSchedule.template_id',
					'T60TemplateHistory.del_flag = "N"',
				)
			),
			array(
				'table' => 'm05_users',
				'alias' => 'M05User',
				'type' => 'left',
				'conditions' => array(
					'M05User.user_id = T20OutSchedule.entry_user',
				)
			),
		);

		$options['conditions']['T20OutSchedule.del_flag'] = "N";
		$options['conditions']['T20OutSchedule.company_id'] = $company_id;
		$options['conditions']['T21OutTime.del_flag'] = "N";


		if(isset($filter) && !empty($filter)){
			if(isset($filter[1])){
				$options['conditions']['T20OutSchedule.schedule_no LIKE'] = "%".$filter[1]."%";
			}
			if(isset($filter[2])){
				$options['conditions']['T20OutSchedule.schedule_name LIKE'] = "%".$filter[2]."%";
			}
			if(isset($filter[3])){
				$options['conditions']['SUBSTR(T21OutTime.time_start, 1, 10) LIKE'] = "%".$filter[3]."%";
			}
			//20160328 - Add by Thai - Fix filter by call_time - Begin
			if(isset($filter[4])){
				$options['conditions']['OR']['SUBSTR(T21OutTime.time_start, 12) LIKE'] = "%".$filter[4]."%";
				$options['conditions']['OR']['SUBSTR(T21OutTime.time_end, 12) LIKE'] = "%".$filter[4]."%";
			}
			//20160328 - Add by Thai - Fix filter by call_time - End
			if(isset($filter[5])){
				$options['conditions']['IF(T20OutSchedule.status = "' . STATUS_FINISH . '", T60TemplateHistory.template_name, T30Template.template_name) LIKE'] = "%".$filter[5]."%";
			}
			if(isset($filter[6])){
				$options['conditions']['IF(T20OutSchedule.status = "' . STATUS_FINISH . '", T50ListHistory.list_name, T10CallList.list_name) LIKE'] = "%".$filter[6]."%";
			}
			/*if(isset($filter[7])){
				$options['conditions']['IF(T20OutSchedule.status = "' . STATUS_FINISH . '", T50ListHistory.tel_total, T10CallList.tel_total) LIKE'] = "%".$filter[7]."%";
			}*/
			if(isset($filter[8])){
				$options['conditions']['T20OutSchedule.called_total LIKE'] = "%".$filter[8]."%";
			}
			if(isset($filter[9])){
				$options['conditions']['SUBSTR(T20OutSchedule.created, 1, 16) LIKE'] = "%".$filter[9]."%";
			}
			if(isset($filter[10])){
				$options['conditions']['M05User.user_name LIKE'] = "%".$filter[10]."%";
			}
		}

    	return $this->find('first', $options);
    }

	function getByScheduleName($company_id=null, $schedule_name = null) {
		$options['fields'] = array(
			'T20OutSchedule.*'
		);

		$options['conditions'] = array(
			'T20OutSchedule.schedule_name' => $schedule_name,
			'T20OutSchedule.del_flag' => "N",
			'T20OutSchedule.company_id' => $company_id,
		);

		return $this->find('first', $options);
	}

    function getScheduleById($id = null) {
        $options['fields'] = array(
            'T20OutSchedule.*',
        );
        $options['conditions']['T20OutSchedule.id'] = $id;
        $options['conditions']['T20OutSchedule.del_flag'] = 'N';
        return $this->find('first', $options);
    }

	function getScheduleInfoById($id = null) {
		$options['fields'] = array(
			'T20OutSchedule.*',
			'T50ListHistory.tel_total',
			'T50ListHistory.list_name',
			'T60TemplateHistory.template_name',
		);

		$options['joins'] = array(
			array(
				'table' => 't10_call_lists',
				'alias' => 'T10CallList',
				'type' => 'left',
				'conditions' => array(
					'T10CallList.id = T20OutSchedule.list_id',
					'T10CallList.del_flag = "N"',
				)
			),
			array(
				'table' => 't50_list_histories',
				'alias' => 'T50ListHistory',
				'type' => 'left',
				'conditions' => array(
					'T50ListHistory.schedule_id = T20OutSchedule.id',
					'T50ListHistory.list_id = T20OutSchedule.list_id',
					'T50ListHistory.del_flag = "N"',
				)
			),
			array(
				'table' => 't30_templates',
				'alias' => 'T30Template',
				'type' => 'left',
				'conditions' => array(
					'T30Template.id = T20OutSchedule.template_id',
					'T30Template.del_flag = "N"',
				)
			),
			array(
				'table' => 't60_template_histories',
				'alias' => 'T60TemplateHistory',
				'type' => 'left',
				'conditions' => array(
					'T60TemplateHistory.schedule_id = T20OutSchedule.id',
					'T60TemplateHistory.template_id = T20OutSchedule.template_id',
					'T60TemplateHistory.del_flag = "N"',
				)
			),
		);

		$options['conditions']['T20OutSchedule.id'] = $id;
		$options['conditions']['T20OutSchedule.del_flag'] = 'N';
		return $this->find('first', $options);
	}

    function getScheduleByScheduleNo($schedule_no = null) {
    	$options['fields'] = array(
    		'T20OutSchedule.*',
    	);
    	$options['conditions']['T20OutSchedule.schedule_no'] = $schedule_no;
    	$options['conditions']['T20OutSchedule.del_flag'] = 'N';
    	return $this->find('first', $options);
    }

    function getMaxScheduleNoByCompanyId($company_id=null) {
        $options['fields'] = array(
            'max(T20OutSchedule.id) as max_id',
            'max(CAST(T20OutSchedule.schedule_no AS UNSIGNED)) as max_schedule_no',
        );

		$options['conditions']['T20OutSchedule.company_id'] = $company_id;

        return $this->find('first', $options);
    }

    function getSumProcNumByOperationTime($company_id = null, $schedule_id = null, $time_start = null, $time_end = null, $action = null) {
        $options['fields'] = array(
			'T20OutSchedule.id',
            'sum(T20OutSchedule.proc_num)/count(*) as sum_proc_num',
			'sum(T31TemplateQuestion.trans_seat_num)/count(*) as sum_trans_seat_num'
        );

		$options['joins'] = array(
			array(
				'table' => 't21_out_times',
				'alias' => 'T21OutTime',
				'type' => 'inner',
				'conditions' => array(
					'T21OutTime.schedule_id = T20OutSchedule.id',
				)
			),
			array(
				'table' => 't31_template_questions',
				'alias' => 'T31TemplateQuestion',
				'type' => 'left',
				'conditions' => array(
					'T31TemplateQuestion.template_id = T20OutSchedule.template_id',
					'T31TemplateQuestion.question_type = ' . QUESTION_TRANS,
					'T31TemplateQuestion.del_flag = "N"',
				)
			),
		);

        $options['conditions'][1]['OR'][0]['T21OutTime.time_start < '] = $time_start;
        $options['conditions'][1]['OR'][0]['T21OutTime.time_end >'] = $time_start;
        $options['conditions'][1]['OR'][1]['T21OutTime.time_start > '] = $time_start;
        $options['conditions'][1]['OR'][1]['T21OutTime.time_start < '] = $time_end;

        if ($action == "update" || $action == "recall" || (!empty($schedule_id) && $action == "call")) {
            $options['conditions']['T20OutSchedule.id <>'] = $schedule_id;
        }

		//$options['conditions'][2]['OR'][0]['T20OutSchedule.status IN'] = array(STATUS_NO_CALL, STATUS_CALLING, STATUS_STOPING, STATUS_FINISHING);
        $options['conditions'][2]['OR'][0]['T20OutSchedule.status <>'] = STATUS_FINISH;
//      $options['conditions'][2]['OR'][1]['T20OutSchedule.status'] = STATUS_FINISH;
// 		$options['conditions'][2]['OR'][1]['T20OutSchedule.recall_flag'] = 'N';
// 		$options['conditions'][2]['OR'][1]['T20OutSchedule.recall'] = '1';

		$options['conditions']['T20OutSchedule.del_flag'] = 'N';
		$options['conditions']['T20OutSchedule.company_id'] = $company_id;
		$options['conditions']['T21OutTime.del_flag'] = 'N';

		$options['group']['T20OutSchedule.id'] = 1;

        return $this->find('all', $options);
    }

    function getScheduleByOperationTime($kaisen_code, $schedule_id = null, $time_start = null, $time_end = null, $action = null, $min_time_call = null) {
        $options['fields'] = array(
            'T20OutSchedule.id',
            'M07ServerExternal.kaisen_code',
            'T21OutTime.time_start',
            'T21OutTime.time_end'
        );

		$options['joins'] = array(
			array(
				'table' => 't21_out_times',
				'alias' => 'T21OutTime',
				'type' => 'inner',
				'conditions' => array(
					'T21OutTime.schedule_id = T20OutSchedule.id',
				)
			),
			array(
				'table' => 'm07_server_externals',
				'alias' => 'M07ServerExternal',
				'type' => 'inner',
				'conditions' => array(
					'M07ServerExternal.external_number = T20OutSchedule.external_number'
				)
			),
		);
		$min_time_call = $min_time_call." second";
        $options['conditions'][1]['OR'][0]['T21OutTime.time_start <= '] = $time_start;
        $options['conditions'][1]['OR'][0]['T21OutTime.time_end >='] = date('Y-m-d H:i:s',(strtotime('-'.$min_time_call, strtotime($time_start))));
        $options['conditions'][1]['OR'][1]['T21OutTime.time_start >= '] = $time_start;
        $options['conditions'][1]['OR'][1]['T21OutTime.time_start <= '] = date('Y-m-d H:i:s',(strtotime('+'.$min_time_call, strtotime($time_end))));

        if ($action == "update" || $action == "recall" || (!empty($schedule_id) && $action == "call")) {
            $options['conditions']['T20OutSchedule.id <>'] = $schedule_id;
        }

		$options['conditions'][2]['OR'][0]['T20OutSchedule.status <>'] = STATUS_FINISH;
		$options['conditions']['M07ServerExternal.kaisen_code'] = $kaisen_code;
		$options['conditions']['T20OutSchedule.del_flag'] = 'N';
		$options['conditions']['T21OutTime.del_flag'] = 'N';
		$options['conditions']['M07ServerExternal.del_flag'] = 'N';

        return $this->find('all', $options);
    }
    function checkSameSchedule($schedule_id = null, $create_date = null, $list_ng_id = null, $template_id = null, $list_id = null, $action = null) {
		$options['joins'] = array(
			array(
				'table' => 't21_out_times',
				'alias' => 'T21OutTime',
				'type' => 'inner',
				'conditions' => array(
					'T21OutTime.schedule_id = T20OutSchedule.id',
				)
			),
		);

        $options['conditions']['T20OutSchedule.list_ng_id'] = $list_ng_id;
        $options['conditions']['T20OutSchedule.template_id'] = $template_id;
		$options['conditions']['T20OutSchedule.list_id'] = $list_id;
        $options['conditions']['T20OutSchedule.del_flag'] = 'N';
		$options['conditions']['T21OutTime.del_flag'] = 'N';
        $options['conditions']['T21OutTime.time_start LIKE'] = $create_date.'%';

        if ($action == "update" || (!empty($schedule_id) && $action == "call")){
        	$options['conditions']['T20OutSchedule.id <>'] = $schedule_id;
        }

        return $this->find('count', $options);
    }

	function getHistoryInfoById ($id=null) {
		$options['fields'] = array(
			'T20OutSchedule.*',
			'T21OutTime.time_start',
			'T50ListHistory.list_id',
			'T50ListHistory.list_name',
			'T50ListHistory.tel_total',
			'T60TemplateHistory.template_name',
		);

		$options['joins'] = array(
			array(
				'table' => 't50_list_histories',
				'alias' => 'T50ListHistory',
				'type' => 'inner',
				'conditions' => array(
					'T50ListHistory.list_id = T20OutSchedule.list_id',
					'T50ListHistory.schedule_id = T20OutSchedule.id',
				)
			),
			array(
				'table' => 't60_template_histories',
				'alias' => 'T60TemplateHistory',
				'type' => 'inner',
				'conditions' => array(
					'T60TemplateHistory.template_id = T20OutSchedule.template_id',
					'T60TemplateHistory.schedule_id = T20OutSchedule.id',
				)
			),
			array(
				'table' => 't21_out_times',
				'alias' => 'T21OutTime',
				'type' => 'inner',
				'conditions' => array(
					'T21OutTime.schedule_id = T20OutSchedule.id',
				)
			),
		);

		$options['conditions'] = array(
			'T20OutSchedule.del_flag' => 'N',
			'T21OutTime.del_flag' => 'N',
			'T50ListHistory.del_flag' => 'N',
			'T60TemplateHistory.del_flag' => 'N',
			'T20OutSchedule.id' => $id
		);

		return $this->find('first', $options);
	}

    function getScheduleByListNo($list_no=null, $status=null) {
    	$options['fields'] = array(
    			'T20OutSchedule.*'
    	);
    	if(isset($list_no) && !empty($list_no)){
    		$options['conditions']['T20OutSchedule.list_id'] = $list_no;
    	}
    	if(isset($status)){
    		if (is_array($status)) {
	    		$options['conditions']['T20OutSchedule.status in'] = $status;
    		} else {
	    		$options['conditions']['T20OutSchedule.status'] = $status;
    		}
    	}
    	$options['conditions']['T20OutSchedule.del_flag'] = 'N';

    	$options['order'] = array(
    			'T20OutSchedule.id desc',
    	);
    	return $this->find('all', $options);
    }

    function getScheduleByListNg($list_ng_id=null, $status=null) {
    	$options['fields'] = array(
    			'T20OutSchedule.*'
    	);
    	if(isset($list_ng_id) && !empty($list_ng_id)){
    		$options['conditions']['T20OutSchedule.list_ng_id'] = $list_ng_id;
    	}
    	if(isset($status)){
    		if (is_array($status)) {
    			$options['conditions']['T20OutSchedule.status in'] = $status;
    		} else {
    			$options['conditions']['T20OutSchedule.status'] = $status;
    		}
    	}
    	$options['conditions']['T20OutSchedule.del_flag'] = 'N';
    	return $this->find('all', $options);
    }

    function getScheduleNotFinishByTemplateId($id) {
        $options['fields'] = array(
        	'T20OutSchedule.id',
            'T20OutSchedule.status',
        );
        $options['conditions']['T20OutSchedule.status <>'] = STATUS_FINISH;
        $options['conditions']['T20OutSchedule.template_id'] = $id;
        $options['conditions']['T20OutSchedule.del_flag'] = 'N';
        return $this->find('first', $options);
    }
    function getScheduleByTemplateId($id) {
    	$options['fields'] = array(
    			'T20OutSchedule.id',
    			'T20OutSchedule.status',
    	);
    	$options['conditions']['T20OutSchedule.template_id'] = $id;
    	$options['conditions']['T20OutSchedule.del_flag'] = 'N';
    	return $this->find('all', $options);
    }

    function getScheduleByListNgId($list_ng_id=null, $status=null) {
    	$options['fields'] = array(
    			'T20OutSchedule.*'
    	);
    	if(isset($list_ng_id) && !empty($list_ng_id)){
    		$options['conditions']['T20OutSchedule.list_ng_id'] = $list_ng_id;
    	}
    	if(isset($status)){
    		if (is_array($status)) {
	    		$options['conditions']['T20OutSchedule.status in'] = $status;
    		} else {
	    		$options['conditions']['T20OutSchedule.status'] = $status;
    		}
    	}
    	$options['conditions']['T20OutSchedule.del_flag'] = 'N';

    	$options['order'] = array(
    			'T20OutSchedule.id desc',
    	);
    	return $this->find('all', $options);
    }

	function getCallResultCountByCompanyAndTel($company_id=null, $tel_number=null, $date_from=null, $date_to=null) {
		$condition_joins = array(
			'T20OutSchedule.id = T80OutgoingResult.schedule_id',
			'T20OutSchedule.company_id' => $company_id,
			'T80OutgoingResult.del_flag' => 'N',
			'T80OutgoingResult.call_datetime >=' => $date_from . ' 00:00:00',
			'T80OutgoingResult.call_datetime <=' => $date_to . ' 23:59:59',
		);
		if ($tel_number) {
			$condition_joins['T20OutSchedule.external_number'] = $tel_number;
		}
		$options['joins'] = array(
			array(
				'table' => 't80_outgoing_results',
				'alias' => 'T80OutgoingResult',
				'type' => 'inner',
				'conditions' => $condition_joins
			),
		);

		return $this->find('count', $options);
	}

	function getScheduleByCompanyAndTel($company_id=null, $tel_number=null, $date_from=null, $date_to=null) {
		$options['fields'] = array(
			'T20OutSchedule.id',
			'T20OutSchedule.external_number',
			'T20OutSchedule.list_id',
		);

		$options['joins'] = array(
			array(
				'table' => 't22_out_logs',
				'alias' => 'T22OutLog',
				'type' => 'inner',
				'conditions' => array(
					'T22OutLog.schedule_id = T20OutSchedule.id',
					'T22OutLog.del_flag = "N"',
				)
			),
		);

		$options['conditions']['T20OutSchedule.company_id'] = $company_id;
		$options['conditions']['T22OutLog.time_start >='] = $date_from . ' 00:00:00';
		$options['conditions']['T22OutLog.time_start <='] = $date_to . ' 23:59:59';
		if ($tel_number) {
			$options['conditions']['T20OutSchedule.external_number'] = $tel_number;
		}

		$options['group'] = array('T20OutSchedule.id');
		$options['order'] = array('T22OutLog.time_start');

		return $this->find('all', $options);
	}
}