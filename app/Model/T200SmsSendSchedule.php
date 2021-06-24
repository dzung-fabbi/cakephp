<?php

class T200SmsSendSchedule extends AppModel {
    var $name = 'T200SmsSendSchedule';

    /**
     * Get Schedule By Company Id
     */
    function getScheduleByCompanyId($company_id=null, $limit=null, $page=null, $sort_order=null, $filter=null) {
        $options['fields'] = array(
            'T200SmsSendSchedule.*',
			'M05User.user_name',
			'T201SmsSendTime.time_start',
			'T201SmsSendTime.time_end',
        		
			'IF(T200SmsSendSchedule.status = "' . STATUS_FINISH . '", T500SmsListHistory.list_name, T100SmsSendList.list_name) as list_name',
			'IF(T200SmsSendSchedule.status = "' . STATUS_FINISH . '", T500SmsListHistory.muko_tel_total, T100SmsSendList.muko_tel_total) as tel_total',
			'IF(T200SmsSendSchedule.status = "' . STATUS_FINISH . '", T600SmsTemplateHistory.template_name, T300SmsTemplate.template_name) as template_name'
        );
        $options['joins'] = array(
			array(
				'table' => 't201_sms_send_times',
				'alias' => 'T201SmsSendTime',
				'type' => 'inner',
				'conditions' => array(
					'T201SmsSendTime.schedule_id = T200SmsSendSchedule.id',
				)
			),
			array(
				'table' => 't100_sms_send_lists',
				'alias' => 'T100SmsSendList',
				'type' => 'left',
				'conditions' => array(
					'T100SmsSendList.id = T200SmsSendSchedule.list_id',
					'T100SmsSendList.company_id = "' . $company_id . '"',
					'T100SmsSendList.del_flag = "N"',
				)
			),
			array(
				'table' => 't500_sms_list_histories',
				'alias' => 'T500SmsListHistory',
				'type' => 'left',
				'conditions' => array(
					'T500SmsListHistory.schedule_id = T200SmsSendSchedule.id',
					'T500SmsListHistory.list_id = T200SmsSendSchedule.list_id',
					'T500SmsListHistory.del_flag = "N"',
				)
			),
			array(
				'table' => 't300_sms_templates',
				'alias' => 'T300SmsTemplate',
				'type' => 'left',
				'conditions' => array(
					'T300SmsTemplate.id = T200SmsSendSchedule.template_id',
					'T300SmsTemplate.company_id = "' . $company_id . '"',
					'T300SmsTemplate.del_flag = "N"',
				)
			),
			array(
				'table' => 't600_sms_template_histories',
				'alias' => 'T600SmsTemplateHistory',
				'type' => 'left',
				'conditions' => array(
					'T600SmsTemplateHistory.schedule_id = T200SmsSendSchedule.id',
					'T600SmsTemplateHistory.template_id = T200SmsSendSchedule.template_id',
					'T600SmsTemplateHistory.del_flag = "N"',
				)
			),
			array(
				'table' => 'm05_users',
				'alias' => 'M05User',
				'type' => 'left',
				'conditions' => array(
					'M05User.user_id = T200SmsSendSchedule.entry_user',
				)
			),
        );

        $options['conditions']['T200SmsSendSchedule.del_flag'] = "N";
		$options['conditions']['T200SmsSendSchedule.company_id'] = $company_id;
		$options['conditions']['T201SmsSendTime.del_flag'] = "N";


        if(isset($filter) && !empty($filter)){
        	if(isset($filter[1])){
        		$options['conditions']['T200SmsSendSchedule.schedule_no LIKE'] = "%".$filter[1]."%";
        	}
        	if(isset($filter[2])){
        		$options['conditions']['T200SmsSendSchedule.schedule_name LIKE'] = "%".$filter[2]."%";
        	}
        	if(isset($filter[3])){
        		$options['conditions']['SUBSTR(T201SmsSendTime.time_start, 1, 10) LIKE'] = "%".$filter[3]."%";
        	}
			if(isset($filter[4])){
				$options['conditions']['OR']['SUBSTR(T201SmsSendTime.time_start, 12, 5) LIKE'] = "%".$filter[4]."%";
				$options['conditions']['OR']['SUBSTR(T201SmsSendTime.time_end, 12, 5) LIKE'] = "%".$filter[4]."%";
			}
			if(isset($filter[5])){
				$options['conditions']['IF(T200SmsSendSchedule.status = "' . STATUS_FINISH . '", T600SmsTemplateHistory.template_name, T300SmsTemplate.template_name) LIKE'] = "%".$filter[5]."%";
			}
			if(isset($filter[6])){
				$options['conditions']['IF(T200SmsSendSchedule.status = "' . STATUS_FINISH . '", T500SmsListHistory.list_name, T100SmsSendList.list_name) LIKE'] = "%".$filter[6]."%";
			}
			if(isset($filter[7])){
				$options['conditions']['IF(T200SmsSendSchedule.status = "' . STATUS_FINISH . '", T500SmsListHistory.muko_tel_total, T100SmsSendList.muko_tel_total) LIKE'] = "%".$filter[7]."%";
			}
			if(isset($filter[8])){
				$options['conditions']['T200SmsSendSchedule.send_total LIKE'] = "%".$filter[8]."%";
			}
			if(isset($filter[9])){
				$options['conditions']['SUBSTR(T200SmsSendSchedule.created, 1, 16) LIKE'] = "%".$filter[9]."%";
			}
			if(isset($filter[10])){
				$options['conditions']['M05User.user_name LIKE'] = "%".$filter[10]."%";
			}
        }
		$options['group'] = array('T200SmsSendSchedule.id');
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
            'COUNT(DISTINCT T200SmsSendSchedule.id) AS total',
    	);
		$options['joins'] = array(
			array(
				'table' => 't201_sms_send_times',
				'alias' => 'T201SmsSendTime',
				'type' => 'inner',
				'conditions' => array(
					'T201SmsSendTime.schedule_id = T200SmsSendSchedule.id',
				)
			),
			array(
				'table' => 't100_sms_send_lists',
				'alias' => 'T100SmsSendList',
				'type' => 'left',
				'conditions' => array(
					'T100SmsSendList.id = T200SmsSendSchedule.list_id',
					'T100SmsSendList.company_id = "' . $company_id . '"',
					'T100SmsSendList.del_flag = "N"',
				)
			),
			array(
				'table' => 't500_sms_list_histories',
				'alias' => 'T500SmsListHistory',
				'type' => 'left',
				'conditions' => array(
					'T500SmsListHistory.schedule_id = T200SmsSendSchedule.id',
					'T500SmsListHistory.list_id = T200SmsSendSchedule.list_id',
					'T500SmsListHistory.del_flag = "N"',
				)
			),
			array(
				'table' => 't300_sms_templates',
				'alias' => 'T300SmsTemplate',
				'type' => 'left',
				'conditions' => array(
					'T300SmsTemplate.id = T200SmsSendSchedule.template_id',
					'T300SmsTemplate.company_id = "' . $company_id . '"',
					'T300SmsTemplate.del_flag = "N"',
				)
			),
			array(
				'table' => 't600_sms_template_histories',
				'alias' => 'T600SmsTemplateHistory',
				'type' => 'left',
				'conditions' => array(
					'T600SmsTemplateHistory.schedule_id = T200SmsSendSchedule.id',
					'T600SmsTemplateHistory.template_id = T200SmsSendSchedule.template_id',
					'T600SmsTemplateHistory.del_flag = "N"',
				)
			),
			array(
				'table' => 'm05_users',
				'alias' => 'M05User',
				'type' => 'left',
				'conditions' => array(
					'M05User.user_id = T200SmsSendSchedule.entry_user',
				)
			),
		);

		$options['conditions']['T200SmsSendSchedule.del_flag'] = "N";
		$options['conditions']['T200SmsSendSchedule.company_id'] = $company_id;
		$options['conditions']['T201SmsSendTime.del_flag'] = "N";


		if(isset($filter) && !empty($filter)){
			if(isset($filter[1])){
				$options['conditions']['T200SmsSendSchedule.schedule_no LIKE'] = "%".$filter[1]."%";
			}
			if(isset($filter[2])){
				$options['conditions']['T200SmsSendSchedule.schedule_name LIKE'] = "%".$filter[2]."%";
			}
			if(isset($filter[3])){
				$options['conditions']['SUBSTR(T201SmsSendTime.time_start, 1, 10) LIKE'] = "%".$filter[3]."%";
			}
			if(isset($filter[4])){
				$options['conditions']['OR']['SUBSTR(T201SmsSendTime.time_start, 12, 5) LIKE'] = "%".$filter[4]."%";
				$options['conditions']['OR']['SUBSTR(T201SmsSendTime.time_end, 12, 5) LIKE'] = "%".$filter[4]."%";
			}
			if(isset($filter[5])){
				$options['conditions']['IF(T200SmsSendSchedule.status = "' . STATUS_FINISH . '", T600SmsTemplateHistory.template_name, T300SmsTemplate.template_name) LIKE'] = "%".$filter[5]."%";
			}
			if(isset($filter[6])){
				$options['conditions']['IF(T200SmsSendSchedule.status = "' . STATUS_FINISH . '", T500SmsListHistory.list_name, T100SmsSendList.list_name) LIKE'] = "%".$filter[6]."%";
			}
			if(isset($filter[7])){
				$options['conditions']['IF(T200SmsSendSchedule.status = "' . STATUS_FINISH . '", T500SmsListHistory.muko_tel_total, T100SmsSendList.muko_tel_total) LIKE'] = "%".$filter[7]."%";
			}
			if(isset($filter[8])){
				$options['conditions']['T200SmsSendSchedule.send_total LIKE'] = "%".$filter[8]."%";
			}
			if(isset($filter[9])){
				$options['conditions']['SUBSTR(T200SmsSendSchedule.created, 1, 16) LIKE'] = "%".$filter[9]."%";
			}
			if(isset($filter[10])){
				$options['conditions']['M05User.user_name LIKE'] = "%".$filter[10]."%";
			}
		}

    	return $this->find('first', $options);
    }

	function getByScheduleName($company_id=null, $schedule_name = null) {
		$options['fields'] = array(
			'T200SmsSendSchedule.*'
		);

		$options['conditions'] = array(
			'T200SmsSendSchedule.schedule_name' => $schedule_name,
			'T200SmsSendSchedule.del_flag' => "N",
			'T200SmsSendSchedule.company_id' => $company_id,
		);

		return $this->find('first', $options);
	}

    function getScheduleById($id = null) {
        $options['fields'] = array(
            'T200SmsSendSchedule.*',
        );
        $options['conditions']['T200SmsSendSchedule.id'] = $id;
        $options['conditions']['T200SmsSendSchedule.del_flag'] = 'N';
        return $this->find('first', $options);
    }

	function getScheduleInfoById($id = null) {
		$options['fields'] = array(
			'T200SmsSendSchedule.*',
			'T500SmsListHistory.tel_total',
			'T500SmsListHistory.list_name',
			'T600SmsTemplateHistory.template_name',
		);

		$options['joins'] = array(
			array(
				'table' => 't100_sms_send_lists',
				'alias' => 'T100SmsSendList',
				'type' => 'left',
				'conditions' => array(
					'T100SmsSendList.id = T200SmsSendSchedule.list_id',
					'T100SmsSendList.del_flag = "N"',
				)
			),
			array(
				'table' => 't500_sms_list_histories',
				'alias' => 'T500SmsListHistory',
				'type' => 'left',
				'conditions' => array(
					'T500SmsListHistory.schedule_id = T200SmsSendSchedule.id',
					'T500SmsListHistory.list_id = T200SmsSendSchedule.list_id',
					'T500SmsListHistory.del_flag = "N"',
				)
			),
			array(
				'table' => 't300_sms_templates',
				'alias' => 'T300SmsTemplate',
				'type' => 'left',
				'conditions' => array(
					'T300SmsTemplate.id = T200SmsSendSchedule.template_id',
					'T300SmsTemplate.del_flag = "N"',
				)
			),
			array(
				'table' => 't600_sms_template_histories',
				'alias' => 'T600SmsTemplateHistory',
				'type' => 'left',
				'conditions' => array(
					'T600SmsTemplateHistory.schedule_id = T200SmsSendSchedule.id',
					'T600SmsTemplateHistory.template_id = T200SmsSendSchedule.template_id',
					'T600SmsTemplateHistory.del_flag = "N"',
				)
			),
		);

		$options['conditions']['T200SmsSendSchedule.id'] = $id;
		$options['conditions']['T200SmsSendSchedule.del_flag'] = 'N';
		return $this->find('first', $options);
	}

    function getScheduleByScheduleNo($schedule_no = null) {
    	$options['fields'] = array(
    		'T200SmsSendSchedule.*',
    	);
    	$options['conditions']['T200SmsSendSchedule.schedule_no'] = $schedule_no;
    	$options['conditions']['T200SmsSendSchedule.del_flag'] = 'N';
    	return $this->find('first', $options);
    }

    function getMaxScheduleNoByCompanyId($company_id=null) {
        $options['fields'] = array(
            'max(T200SmsSendSchedule.id) as max_id',
            'max(CAST(T200SmsSendSchedule.schedule_no AS UNSIGNED)) as max_schedule_no',
        );

		$options['conditions']['T200SmsSendSchedule.company_id'] = $company_id;

        return $this->find('first', $options);
    }

    function getScheduleNotFinishByOperationTime($company_id = null, $schedule_id = null, $time_start = null, $time_end = null, $action = null) {
        $options['fields'] = array(
			'T200SmsSendSchedule.id',
        );

		$options['joins'] = array(
			array(
				'table' => 't201_sms_send_times',
				'alias' => 'T201SmsSendTime',
				'type' => 'inner',
				'conditions' => array(
					'T201SmsSendTime.schedule_id = T200SmsSendSchedule.id',
				)
			),
		);

        $options['conditions'][1]['OR'][0]['T201SmsSendTime.time_start < '] = $time_start;
        $options['conditions'][1]['OR'][0]['T201SmsSendTime.time_end >'] = $time_start;
        $options['conditions'][1]['OR'][1]['T201SmsSendTime.time_start > '] = $time_start;
        $options['conditions'][1]['OR'][1]['T201SmsSendTime.time_start < '] = $time_end;

        if ($action == "update" || $action == "resend" || (!empty($schedule_id))) {
            $options['conditions']['T200SmsSendSchedule.id <>'] = $schedule_id;
        }

		$options['conditions'][2]['OR'][0]['T200SmsSendSchedule.status <>'] = STATUS_FINISH;

		$options['conditions']['T200SmsSendSchedule.del_flag'] = 'N';
		$options['conditions']['T200SmsSendSchedule.company_id'] = $company_id;
		$options['conditions']['T201SmsSendTime.del_flag'] = 'N';

		$options['group']['T200SmsSendSchedule.id'] = 1;

        return $this->find('all', $options);
    }

	function getHistoryInfoById ($id=null) {
		$options['fields'] = array(
			'T200SmsSendSchedule.*',
			'T201SmsSendTime.time_start',
			'T500SmsListHistory.list_id',
			'T500SmsListHistory.list_name',
			'T500SmsListHistory.tel_total',
			'T500SmsListHistory.muko_tel_total',
			'T600SmsTemplateHistory.template_name',
			'T600SmsTemplateHistory.content',
		);

		$options['joins'] = array(
			array(
				'table' => 't500_sms_list_histories',
				'alias' => 'T500SmsListHistory',
				'type' => 'inner',
				'conditions' => array(
					'T500SmsListHistory.list_id = T200SmsSendSchedule.list_id',
					'T500SmsListHistory.schedule_id = T200SmsSendSchedule.id',
				)
			),
			array(
				'table' => 't600_sms_template_histories',
				'alias' => 'T600SmsTemplateHistory',
				'type' => 'inner',
				'conditions' => array(
					'T600SmsTemplateHistory.template_id = T200SmsSendSchedule.template_id',
					'T600SmsTemplateHistory.schedule_id = T200SmsSendSchedule.id',
				)
			),
			array(
				'table' => 't201_sms_send_times',
				'alias' => 'T201SmsSendTime',
				'type' => 'inner',
				'conditions' => array(
					'T201SmsSendTime.schedule_id = T200SmsSendSchedule.id',
				)
			),
		);

		$options['conditions'] = array(
			'T200SmsSendSchedule.del_flag' => 'N',
			'T201SmsSendTime.del_flag' => 'N',
			'T500SmsListHistory.del_flag' => 'N',
			'T600SmsTemplateHistory.del_flag' => 'N',
			'T200SmsSendSchedule.id' => $id
		);

		return $this->find('first', $options);
	}

    /** Get all the sms scheule by list_no and schedule status
     * @param $list_no is list_id
     * @param $status is status of schedule
     * @return array all of records found or NULL if no record be found
     */
    function getScheduleByListNo($list_no=null, $status=null) {
    	$options['fields'] = array(
    			'T200SmsSendSchedule.*'
    	);
    	if(isset($list_no) && !empty($list_no)){
    		$options['conditions']['T200SmsSendSchedule.list_id'] = $list_no;
    	}
    	if(isset($status)){
    		if (is_array($status)) {
	    		$options['conditions']['T200SmsSendSchedule.status in'] = $status;
    		} else {
	    		$options['conditions']['T200SmsSendSchedule.status'] = $status;
    		}
    	}
    	$options['conditions']['T200SmsSendSchedule.del_flag'] = 'N';

    	$options['order'] = array(
    			'T200SmsSendSchedule.id desc',
    	);
    	return $this->find('all', $options);
    }

    /** Get the sms scheule by list_id and schedule status
     * @param int $list_id is list_id
     * @param array|int $status is status of schedule
     * @return array of records found or NULL if no record be found
     */
    function getScheduleByListId($list_id=null, $status=null) {
    	$options['fields'] = array(
    			'T200SmsSendSchedule.*'
    	);
    	if(isset($list_id) && !empty($list_id)){
    		$options['conditions']['T200SmsSendSchedule.list_id'] = $list_id;
    	}
    	if(isset($status)){
    		if (is_array($status)) {
	    		$options['conditions']['T200SmsSendSchedule.status in'] = $status;
    		} else {
	    		$options['conditions']['T200SmsSendSchedule.status'] = $status;
    		}
    	}
    	$options['conditions']['T200SmsSendSchedule.del_flag'] = 'N';

    	return $this->find('first', $options);
    }
    /** Get the sms scheule by list_id and schedule status
     * @param int $list_id is list_id
     * @param array|int $status is status of schedule
     * @return array of records found or NULL if no record be found
     */
    function getAllScheduleByListId($list_id=null, $status=null) {
    	$options['fields'] = array(
    			'T200SmsSendSchedule.*'
    	);
    	if(isset($list_id) && !empty($list_id)){
    		$options['conditions']['T200SmsSendSchedule.list_id'] = $list_id;
    	}
    	if(isset($status)){
    		if (is_array($status)) {
	    		$options['conditions']['T200SmsSendSchedule.status in'] = $status;
    		} else {
	    		$options['conditions']['T200SmsSendSchedule.status'] = $status;
    		}
    	}
    	$options['conditions']['T200SmsSendSchedule.del_flag'] = 'N';

    	return $this->find('all', $options);
    }
    function getScheduleByListNg($list_ng_id=null, $status=null) {
    	$options['fields'] = array(
    			'T200SmsSendSchedule.*'
    	);
    	if(isset($list_ng_id) && !empty($list_ng_id)){
    		$options['conditions']['T200SmsSendSchedule.list_ng_id'] = $list_ng_id;
    	}
    	if(isset($status)){
    		if (is_array($status)) {
    			$options['conditions']['T200SmsSendSchedule.status in'] = $status;
    		} else {
    			$options['conditions']['T200SmsSendSchedule.status'] = $status;
    		}
    	}
    	$options['conditions']['T200SmsSendSchedule.del_flag'] = 'N';
    	return $this->find('all', $options);
    }

    function getScheduleNotFinishByTemplateId($id) {
        $options['fields'] = array(
        	'T200SmsSendSchedule.id',
            'T200SmsSendSchedule.status',
        );
        $options['conditions']['T200SmsSendSchedule.status <>'] = STATUS_FINISH;
        $options['conditions']['T200SmsSendSchedule.template_id'] = $id;
        $options['conditions']['T200SmsSendSchedule.del_flag'] = 'N';
        return $this->find('first', $options);
    }
    function getScheduleByTemplateId($id) {
    	$options['fields'] = array(
    			'T200SmsSendSchedule.id',
    			'T200SmsSendSchedule.status',
    	);
    	$options['conditions']['T200SmsSendSchedule.template_id'] = $id;
    	$options['conditions']['T200SmsSendSchedule.del_flag'] = 'N';
    	return $this->find('all', $options);
    }

    function getScheduleByListNgId($list_ng_id=null, $status=null) {
    	$options['fields'] = array(
    			'T200SmsSendSchedule.*'
    	);
    	if(isset($list_ng_id) && !empty($list_ng_id)){
    		$options['conditions']['T200SmsSendSchedule.list_ng_id'] = $list_ng_id;
    	}
    	if(isset($status)){
    		if (is_array($status)) {
	    		$options['conditions']['T200SmsSendSchedule.status in'] = $status;
    		} else {
	    		$options['conditions']['T200SmsSendSchedule.status'] = $status;
    		}
    	}
    	$options['conditions']['T200SmsSendSchedule.del_flag'] = 'N';

    	$options['order'] = array(
    			'T200SmsSendSchedule.id desc',
    	);
    	return $this->find('all', $options);
    }

    /*20160511 Add by Giang - #7108 - Sms Schedule screen: create and edit - Begin*/
    function getCountSmsScheduleByTimeStart($schedule_id = '', $time_start = null, $template_id = null, $list_id = null) {
    	$options['joins'] = array(
			array(
				'table' => 't201_sms_send_times',
				'alias' => 'T201SmsSendTime',
				'type' => 'inner',
				'conditions' => array(
					'T201SmsSendTime.schedule_id = T200SmsSendSchedule.id',
				)
			),
        );

        if (!empty($schedule_id)) {
	        $options['conditions']['T200SmsSendSchedule.id !='] = $schedule_id;
        }

        $options['conditions']['T200SmsSendSchedule.template_id'] = $template_id;
        $options['conditions']['T200SmsSendSchedule.list_id'] = $list_id;
        $options['conditions']['T200SmsSendSchedule.del_flag'] = 'N';
        $options['conditions']['T201SmsSendTime.time_start LIKE'] = $time_start . '%';
        $options['conditions']['T201SmsSendTime.del_flag'] = 'N';

        return $this->find('count', $options);
    }

    function getCountSmsScheduleByServiceId($schedule_id = '', $time_start = null, $time_end = null, $service_id = null) {
		$options['fields'] = array(
			'T201SmsSendTime.time_start',
			'T201SmsSendTime.time_end',
		);
    	$options['joins'] = array(
			array(
				'table' => 't201_sms_send_times',
				'alias' => 'T201SmsSendTime',
				'type' => 'inner',
				'conditions' => array(
					'T201SmsSendTime.schedule_id = T200SmsSendSchedule.id',
				)
			),
        );

        if (!empty($schedule_id)) {
        	$options['conditions']['T200SmsSendSchedule.id !='] = $schedule_id;
        }
        $options['conditions']['T200SmsSendSchedule.status !='] = STATUS_FINISH;
        $options['conditions']['T200SmsSendSchedule.service_id'] = $service_id;
        $options['conditions']['T200SmsSendSchedule.del_flag'] = 'N';
        $options['conditions']['T201SmsSendTime.del_flag'] = 'N';
        $options['conditions']['OR'][0]['T201SmsSendTime.time_start <= '] = $time_start;
        $options['conditions']['OR'][0]['T201SmsSendTime.time_end >='] = $time_start;
        $options['conditions']['OR'][1]['T201SmsSendTime.time_start >= '] = $time_start;
        $options['conditions']['OR'][1]['T201SmsSendTime.time_start <= '] = $time_end;

        return $this->find('first', $options);
    }
    
    /** Get schedule by display number
     * @param $schedule_id
     * @param $time_start
     * @param $time_end
     * @param $display_number
     * @return array records or null
     * @author Hungnv
     * @since 2016/06/09
     */
    function getSmsScheduleByDisplayNumber($schedule_id = '', $time_start = null, $time_end = null, $display_number = null) {
    	$options['fields'] = array(
    			'T201SmsSendTime.time_start',
    			'T201SmsSendTime.time_end',
    	);
    	$options['joins'] = array(
    			array(
    					'table' => 't201_sms_send_times',
    					'alias' => 'T201SmsSendTime',
    					'type' => 'inner',
    					'conditions' => array(
    							'T201SmsSendTime.schedule_id = T200SmsSendSchedule.id',
    					)
    			),
    	);
    
    	if (!empty($schedule_id)) {
    		$options['conditions']['T200SmsSendSchedule.id !='] = $schedule_id;
    	}
    	$options['conditions']['T200SmsSendSchedule.status !='] = STATUS_FINISH;
    	$options['conditions']['T200SmsSendSchedule.display_number'] = $display_number;
    	$options['conditions']['T200SmsSendSchedule.del_flag'] = 'N';
    	$options['conditions']['T201SmsSendTime.del_flag'] = 'N';
    	$options['conditions']['OR'][0]['T201SmsSendTime.time_start <= '] = $time_start;
    	$options['conditions']['OR'][0]['T201SmsSendTime.time_end >='] = $time_start;
    	$options['conditions']['OR'][1]['T201SmsSendTime.time_start >= '] = $time_start;
    	$options['conditions']['OR'][1]['T201SmsSendTime.time_start <= '] = $time_end;
    
    	return $this->find('first', $options);
    }

    function getServiceIdById($id = null) {
    	$options['fields'] = array(
			'T200SmsSendSchedule.service_id',
		);
		$options['conditions']['T200SmsSendSchedule.id'] = $id;
		$options['conditions']['T200SmsSendSchedule.del_flag'] = 'N';

		return $this->find('first', $options);
    }
    /*20160511 Add by Giang - #7108 - Sms Schedule screen: create and edit - End*/
    function getDisplayNumberById($id = null) {
    	$options['fields'] = array(
    			'T200SmsSendSchedule.display_number',
    	);
    	$options['conditions']['T200SmsSendSchedule.id'] = $id;
    	$options['conditions']['T200SmsSendSchedule.del_flag'] = 'N';
    
    	return $this->find('first', $options);
    }
    /** Get the sms scheule by template_id and schedule status
     * @param int $template_id is template id
     * @param array|int $status is status of schedule
     * @return array of records found or NULL if no record be found
     * @author Hungnv
     * @since 2016/06/08
     */
    function getScheduleByTemplateIdAndStatus($template_id=null, $status=null) {
    	$options['fields'] = array(
    			'T200SmsSendSchedule.*'
    	);
    	if(isset($template_id) && !empty($template_id)){
    		$options['conditions']['T200SmsSendSchedule.template_id'] = $template_id;
    	}
    	if(isset($status)){
    		if (is_array($status)) {
    			$options['conditions']['T200SmsSendSchedule.status in'] = $status;
    		} else {
    			$options['conditions']['T200SmsSendSchedule.status'] = $status;
    		}
    	}
    	$options['conditions']['T200SmsSendSchedule.del_flag'] = 'N';
    
    	return $this->find('first', $options);
    }

	function getSendResultCountByCompanyAndTel($company_id=null, $tel_number=null, $date_from=null, $date_to=null) {
		$condition_joins = array(
			'T200SmsSendSchedule.id = T800SmsSendResult.schedule_id',
			'T200SmsSendSchedule.company_id' => $company_id,
			'T800SmsSendResult.del_flag' => 'N',
			'T800SmsSendResult.send_datetime >=' => $date_from . ' 00:00:00',
			'T800SmsSendResult.send_datetime <=' => $date_to . ' 23:59:59',
		);
		if ($tel_number) {
			$condition_joins['T200SmsSendSchedule.display_number'] = $tel_number;
		}
		$options['joins'] = array(
			array(
				'table' => 't800_sms_send_results',
				'alias' => 'T800SmsSendResult',
				'type' => 'inner',
				'conditions' => $condition_joins
			),
		);

		return $this->find('count', $options);
	}

	function getScheduleByCompanyAndTel($company_id=null, $tel_number=null, $date_from=null, $date_to=null) {
		$options['fields'] = array(
			'T200SmsSendSchedule.id',
			'T200SmsSendSchedule.display_number',
			'T200SmsSendSchedule.list_id',
		);

		$options['joins'] = array(
			array(
				'table' => 't202_sms_send_logs',
				'alias' => 'T202SmsSendLog',
				'type' => 'inner',
				'conditions' => array(
					'T202SmsSendLog.schedule_id = T200SmsSendSchedule.id',
					'T202SmsSendLog.del_flag = "N"',
				)
			),
		);

		$options['conditions']['T200SmsSendSchedule.company_id'] = $company_id;
		$options['conditions']['T202SmsSendLog.time_start >='] = $date_from . ' 00:00:00';
		$options['conditions']['T202SmsSendLog.time_start <='] = $date_to . ' 23:59:59';
		if ($tel_number) {
			$options['conditions']['T200SmsSendSchedule.display_number'] = $tel_number;
		}

		$options['group'] = array('T200SmsSendSchedule.id');
		$options['order'] = array('T202SmsSendLog.time_start');

		return $this->find('all', $options);
	}
}