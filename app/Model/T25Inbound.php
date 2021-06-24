<?php

class T25Inbound extends AppModel {
	var $name = 'T25Inbound';

	function getScheduleByListId($list_id=null, $status=null) {
		$options['fields'] = array(
			'T25Inbound.*'
		);
		if(isset($list_id) && !empty($list_id)){
			$options['conditions']['T25Inbound.list_id'] = $list_id;
		}
		if(isset($status)){
			if (is_array($status)) {
				$options['conditions']['T25Inbound.status in'] = $status;
			} else {
				$options['conditions']['T25Inbound.status'] = $status;
			}
		}
		$options['conditions']['T25Inbound.del_flag'] = 'N';

		$options['order'] = array(
			'T25Inbound.id desc',
		);
		return $this->find('all', $options);
	}

    function getScheduleByListNgId($list_ng_id=null, $status=null) {
    	$options['fields'] = array(
    			'T25Inbound.*'
    	);
    	if(isset($list_ng_id) && !empty($list_ng_id)){
    		$options['conditions']['T25Inbound.list_ng_id'] = $list_ng_id;
    	}
    	if(isset($status)){
    		if (is_array($status)) {
	    		$options['conditions']['T25Inbound.status in'] = $status;
    		} else {
	    		$options['conditions']['T25Inbound.status'] = $status;
    		}
    	}
    	$options['conditions']['T25Inbound.del_flag'] = 'N';

    	$options['order'] = array(
    			'T25Inbound.id desc',
    	);
    	return $this->find('all', $options);
    }

	//20160325 Add by Thai : change check when delete inbound template - Begin
	function getInboundByTemplateId($template_id=null) {
		$options['fields'] = array(
			'T25Inbound.*'
		);
		if(isset($template_id) && !empty($template_id)){
			$options['conditions']['OR']['T25Inbound.main_template_id'] = $template_id;
			$options['conditions']['OR']['T25Inbound.absence_template_id'] = $template_id;
			$options['conditions']['OR']['T25Inbound.non_noti_template_id'] = $template_id;
		}

		$options['conditions']['T25Inbound.del_flag'] = 'N';

		$options['order'] = array(
			'T25Inbound.id desc',
		);
		return $this->find('all', $options);
	}
	//20160325 Add by Thai : change check when delete inbound template - End

	function getInboundNotFinishByTemplateId($template_id) {
		$options['fields'] = array(
			'T25Inbound.id',
		);
		$options['conditions']['T25Inbound.status <>'] = STATUS_INBOUND_END;
		$options['conditions']['T25Inbound.template_id'] = $template_id;
		$options['conditions']['T25Inbound.del_flag'] = 'N';
		return $this->find('first', $options);
	}

	//20160412 Add by Thai : #6766 List setting inbound screen - Begin
	function getInboundById($id=null) {
		$options['fields'] = array(
			'T25Inbound.*'
		);

		$options['conditions']['T25Inbound.del_flag'] = 'N';
		$options['conditions']['T25Inbound.id'] = $id;

		$options['order'] = array(
			'T25Inbound.created desc',
		);
		return $this->find('first', $options);
	}

	function getInboundByCompanyId($company_id=null, $limit=null, $page=null, $sort_order=null, $filter=null) {
		$options['fields'] = array(
			'T25Inbound.*',
			'M05User.user_name',
			'IF(T25Inbound.template_id = "", "busy", IF(T25Inbound.status = "' . STATUS_INBOUND_END . '", T63InboundTemplateHistory.template_name, T30Template.template_name)) as template_name',
			'IF(T25Inbound.status = "' . STATUS_INBOUND_END . '", T58InboundListNgHistory.list_name, T18IncomingNgList.list_name) as list_ng_name',
			'IF(T25Inbound.status = "' . STATUS_INBOUND_END . '", T56InboundListHistory.list_name, T16InboundCallList.list_name) as list_name'
		);
		$options['joins'] = array(
			array(
				'table' => 't30_templates',
				'alias' => 'T30Template',
				'type' => 'left',
				'conditions' => array(
					'T30Template.id = T25Inbound.template_id',
					'T30Template.del_flag = "N"',
				)
			),
			array(
				'table' => 't63_inbound_template_histories',
				'alias' => 'T63InboundTemplateHistory',
				'type' => 'left',
				'conditions' => array(
					'T63InboundTemplateHistory.inbound_id = T25Inbound.id',
					'T63InboundTemplateHistory.template_id = T25Inbound.template_id',
					'T63InboundTemplateHistory.del_flag = "N"',
				)
			),
			array(
				'table' => 't18_incoming_ng_lists',
				'alias' => 'T18IncomingNgList',
				'type' => 'left',
				'conditions' => array(
					'T18IncomingNgList.id = T25Inbound.list_ng_id',
					'T18IncomingNgList.del_flag = "N"',
				)
			),
			array(
				'table' => 't58_inbound_list_ng_histories',
				'alias' => 'T58InboundListNgHistory',
				'type' => 'left',
				'conditions' => array(
					'T58InboundListNgHistory.inbound_id = T25Inbound.id',
					'T58InboundListNgHistory.list_ng_id = T25Inbound.list_ng_id',
					'T58InboundListNgHistory.del_flag = "N"',
				)
			),
			array(
				'table' => 't16_inbound_call_lists',
				'alias' => 'T16InboundCallList',
				'type' => 'left',
				'conditions' => array(
					'T16InboundCallList.id = T25Inbound.list_id',
					'T16InboundCallList.del_flag = "N"',
				)
			),
			array(
				'table' => 't56_inbound_list_histories',
				'alias' => 'T56InboundListHistory',
				'type' => 'left',
				'conditions' => array(
					'T56InboundListHistory.inbound_id = T25Inbound.id',
					'T56InboundListHistory.list_id = T25Inbound.list_id',
					'T56InboundListHistory.del_flag = "N"',
				)
			),
			array(
				'table' => 'm05_users',
				'alias' => 'M05User',
				'type' => 'left',
				'conditions' => array(
					'M05User.user_id = T25Inbound.entry_user',
				)
			),
		);

		$options['conditions']['T25Inbound.del_flag'] = "N";
		$options['conditions']['T25Inbound.company_id'] = $company_id;


		if (isset($filter) && !empty($filter)) {
			if(isset($filter[1])){
				$options['conditions']['T25Inbound.inbound_no LIKE'] = "%".$filter[1]."%";
			}
			if(isset($filter[2])){
				$options['conditions']['T25Inbound.external_number LIKE'] = "%".$filter[2]."%";
			}
			if(isset($filter[3])){
				$options['conditions']['OR']['SUBSTR(T25Inbound.time_start, 1, 10) LIKE'] = "%".$filter[3]."%";
				$options['conditions']['OR']['SUBSTR(T25Inbound.time_end, 1, 10) LIKE'] = "%".$filter[3]."%";
			}
			if(isset($filter[4])){
				$options['conditions']['IF(T25Inbound.template_id = "", "busy", IF(T25Inbound.status = "' . STATUS_INBOUND_END . '", T63InboundTemplateHistory.template_name, T30Template.template_name)) LIKE'] = "%".$filter[4]."%";
			}
			if(isset($filter[5])){
				$options['conditions']['IF(T25Inbound.status = "' . STATUS_INBOUND_END . '", T58InboundListNgHistory.list_name, T18IncomingNgList.list_name) LIKE'] = "%".$filter[5]."%";
			}
			if(isset($filter[6])){
				$options['conditions']['IF(T25Inbound.status = "' . STATUS_INBOUND_END . '", T56InboundListHistory.list_name, T16InboundCallList.list_name) LIKE'] = "%".$filter[6]."%";
			}
			if(isset($filter[7])){
				$options['conditions']['SUBSTR(T25Inbound.created, 1, 16) LIKE'] = "%".$filter[7]."%";
			}
			if(isset($filter[8])){
				$options['conditions']['M05User.user_name LIKE'] = "%".$filter[8]."%";
			}
		}
		$options['group'] = array('T25Inbound.id');
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

	function getInboundByCompanyIdCount($company_id=null, $filter=null) {
		$options['fields'] = array(
			'T25Inbound.*',
		);
		$options['joins'] = array(
			array(
				'table' => 't30_templates',
				'alias' => 'T30Template',
				'type' => 'left',
				'conditions' => array(
					'T30Template.id = T25Inbound.template_id',
					'T30Template.del_flag = "N"',
				)
			),
			array(
				'table' => 't63_inbound_template_histories',
				'alias' => 'T63InboundTemplateHistory',
				'type' => 'left',
				'conditions' => array(
					'T63InboundTemplateHistory.inbound_id = T25Inbound.id',
					'T63InboundTemplateHistory.template_id = T25Inbound.template_id',
					'T63InboundTemplateHistory.del_flag = "N"',
				)
			),
			array(
				'table' => 't18_incoming_ng_lists',
				'alias' => 'T18IncomingNgList',
				'type' => 'left',
				'conditions' => array(
					'T18IncomingNgList.id = T25Inbound.list_ng_id',
					'T18IncomingNgList.del_flag = "N"',
				)
			),
			array(
				'table' => 't58_inbound_list_ng_histories',
				'alias' => 'T58InboundListNgHistory',
				'type' => 'left',
				'conditions' => array(
					'T58InboundListNgHistory.inbound_id = T25Inbound.id',
					'T58InboundListNgHistory.list_ng_id = T25Inbound.list_ng_id',
					'T58InboundListNgHistory.del_flag = "N"',
				)
			),
			array(
				'table' => 't16_inbound_call_lists',
				'alias' => 'T16InboundCallList',
				'type' => 'left',
				'conditions' => array(
					'T16InboundCallList.id = T25Inbound.list_id',
					'T16InboundCallList.del_flag = "N"',
				)
			),
			array(
				'table' => 't56_inbound_list_histories',
				'alias' => 'T56InboundListHistory',
				'type' => 'left',
				'conditions' => array(
					'T56InboundListHistory.inbound_id = T25Inbound.id',
					'T56InboundListHistory.list_id = T25Inbound.list_id',
					'T56InboundListHistory.del_flag = "N"',
				)
			),
			array(
				'table' => 'm05_users',
				'alias' => 'M05User',
				'type' => 'left',
				'conditions' => array(
					'M05User.user_id = T25Inbound.entry_user',
				)
			),
		);

		$options['conditions']['T25Inbound.del_flag'] = "N";
		$options['conditions']['T25Inbound.company_id'] = $company_id;


		if (isset($filter) && !empty($filter)) {
			if(isset($filter[1])){
				$options['conditions']['T25Inbound.inbound_no LIKE'] = "%".$filter[1]."%";
			}
			if(isset($filter[2])){
				$options['conditions']['T25Inbound.external_number LIKE'] = "%".$filter[2]."%";
			}
			if(isset($filter[3])){
				$options['conditions']['OR']['SUBSTR(T25Inbound.time_start, 1, 10) LIKE'] = "%".$filter[3]."%";
				$options['conditions']['OR']['SUBSTR(T25Inbound.time_end, 1, 10) LIKE'] = "%".$filter[3]."%";
			}
			if(isset($filter[4])){
				$options['conditions']['IF(T25Inbound.template_id = "", "busy", IF(T25Inbound.status = "' . STATUS_INBOUND_END . '", T63InboundTemplateHistory.template_name, T30Template.template_name)) LIKE'] = "%".$filter[4]."%";
			}
			if(isset($filter[5])){
				$options['conditions']['IF(T25Inbound.status = "' . STATUS_INBOUND_END . '", T58InboundListNgHistory.list_name, T18IncomingNgList.list_name) LIKE'] = "%".$filter[5]."%";
			}
			if(isset($filter[6])){
				$options['conditions']['IF(T25Inbound.status = "' . STATUS_INBOUND_END . '", T56InboundListHistory.list_name, T16InboundCallList.list_name) LIKE'] = "%".$filter[6]."%";
			}
			if(isset($filter[7])){
				$options['conditions']['SUBSTR(T25Inbound.created, 1, 16) LIKE'] = "%".$filter[7]."%";
			}
			if(isset($filter[8])){
				$options['conditions']['M05User.user_name LIKE'] = "%".$filter[8]."%";
			}
		}
		$options['group'] = array('T25Inbound.id');

		return $this->find('count', $options);
	}

	function getInboundBusyByNumber($external_number=null) {
		$options['fields'] = array(
			'T25Inbound.*'
		);

		$options['conditions']['T25Inbound.del_flag'] = 'N';
		$options['conditions']['T25Inbound.external_number'] = $external_number;
		$options['conditions']['T25Inbound.status'] = STATUS_INBOUND_BUSY;

		$options['order'] = array(
			'T25Inbound.created desc',
		);
		return $this->find('first', $options);
	}

	function getInboundNotFinishByExtNumber($external_number=null) {
		$options['fields'] = array(
			'T25Inbound.*'
		);

		$options['conditions']['T25Inbound.del_flag'] = 'N';
		$options['conditions']['T25Inbound.external_number'] = $external_number;
		$options['conditions']['T25Inbound.status <>'] = STATUS_INBOUND_END;

		$options['order'] = array(
			'T25Inbound.created desc',
		);
		return $this->find('all', $options);
	}

	function getMaxInboundNoByCompanyId($company_id=null) {
		$options['fields'] = array(
			'max(CAST(T25Inbound.inbound_no AS UNSIGNED)) as max_inbound_no',
		);

		$options['conditions']['T25Inbound.company_id'] = $company_id;

		return $this->find('first', $options);
	}
	//20160412 Add by Thai : #6766 List setting inbound screen - End

	// 20160413 Add by Giang - #6906 Inbound history screen - Begin
	function getInboundInfoById($id=null) {
		$options['fields'] = array(
			'T25Inbound.*',
			'IF(T25Inbound.status = "' . STATUS_INBOUND_END . '", T63InboundTemplateHistory.template_name, T30Template.template_name) as template_name',
			'IF(T25Inbound.status = "' . STATUS_INBOUND_END . '", T58InboundListNgHistory.list_name, T18IncomingNgList.list_name) as list_ng_name',
			'IF(T25Inbound.status = "' . STATUS_INBOUND_END . '", T56InboundListHistory.list_name, T16InboundCallList.list_name) as list_name'
		);

		$options['joins'] = array(
			array(
				'table' => 't30_templates',
				'alias' => 'T30Template',
				'type' => 'left',
				'conditions' => array(
					'T30Template.id = T25Inbound.template_id',
					'T30Template.del_flag = "N"',
				)
			),
			array(
				'table' => 't63_inbound_template_histories',
				'alias' => 'T63InboundTemplateHistory',
				'type' => 'left',
				'conditions' => array(
					'T63InboundTemplateHistory.inbound_id = T25Inbound.id',
					'T63InboundTemplateHistory.template_id = T25Inbound.template_id',
					'T63InboundTemplateHistory.del_flag = "N"',
				)
			),
			array(
				'table' => 't18_incoming_ng_lists',
				'alias' => 'T18IncomingNgList',
				'type' => 'left',
				'conditions' => array(
					'T18IncomingNgList.id = T25Inbound.list_ng_id',
					'T18IncomingNgList.del_flag = "N"',
				)
			),
			array(
				'table' => 't58_inbound_list_ng_histories',
				'alias' => 'T58InboundListNgHistory',
				'type' => 'left',
				'conditions' => array(
					'T58InboundListNgHistory.inbound_id = T25Inbound.id',
					'T58InboundListNgHistory.list_ng_id = T25Inbound.list_ng_id',
					'T58InboundListNgHistory.del_flag = "N"',
				)
			),
			array(
				'table' => 't16_inbound_call_lists',
				'alias' => 'T16InboundCallList',
				'type' => 'left',
				'conditions' => array(
					'T16InboundCallList.id = T25Inbound.list_id',
					'T16InboundCallList.del_flag = "N"',
				)
			),
			array(
				'table' => 't56_inbound_list_histories',
				'alias' => 'T56InboundListHistory',
				'type' => 'left',
				'conditions' => array(
					'T56InboundListHistory.inbound_id = T25Inbound.id',
					'T56InboundListHistory.list_id = T25Inbound.list_id',
					'T56InboundListHistory.del_flag = "N"',
				)
			),
		);

		$options['conditions'] = array(
			'T25Inbound.id' => $id,
			'T25Inbound.del_flag' => 'N'
		);

		return $this->find('first', $options);
	}

	function getHistoryInfoById ($id=null) {
		$options['fields'] = array(
			'T25Inbound.*',
			'T56InboundListHistory.list_id',
			'T56InboundListHistory.list_name',
			'T56InboundListHistory.tel_total',
			'T63InboundTemplateHistory.template_name',
		);

		$options['joins'] = array(
			array(
				'table' => 't56_inbound_list_histories',
				'alias' => 'T56InboundListHistory',
				'type' => 'left',
				'conditions' => array(
					// 'T56InboundListHistory.list_id = T25Inbound.list_id',
					'T56InboundListHistory.inbound_id = T25Inbound.id',
					'T56InboundListHistory.del_flag' => 'N',
				)
			),
			array(
				'table' => 't63_inbound_template_histories',
				'alias' => 'T63InboundTemplateHistory',
				'type' => 'left',
				'conditions' => array(
					'T63InboundTemplateHistory.template_id = T25Inbound.template_id',
					'T63InboundTemplateHistory.inbound_id = T25Inbound.id',
					'T63InboundTemplateHistory.del_flag' => 'N',
				)
			),
		);

		$options['conditions'] = array(
			'T25Inbound.del_flag' => 'N',
			'T25Inbound.id' => $id
		);

		return $this->find('first', $options);
	}

	function getScheduleById($id = null) {
		$options['fields'] = array(
			'T25Inbound.*',
		);
		$options['conditions']['T25Inbound.id'] = $id;
		$options['conditions']['T25Inbound.del_flag'] = 'N';
		return $this->find('first', $options);
	}
	// 20160413 Add by Giang - #6906 Inbound history screen - End

	function getInboundPrev($external_number=null, $id=null) {
		$options['fields'] = array(
			'T25Inbound.*',
		);
		$options['conditions']['T25Inbound.external_number'] = $external_number;
		$options['conditions']['T25Inbound.id <'] = $id;
		$options['conditions']['T25Inbound.del_flag'] = 'N';
		$options['order'] = array(
			'T25Inbound.id desc',
		);
		return $this->find('first', $options);
	}

	function getCallResultCountByCompanyAndTel($company_id=null, $tel_number=null, $date_from=null, $date_to=null) {
		$condition_joins = array(
			'T25Inbound.id = T81IncomingResult.inbound_id',
			'T25Inbound.company_id' => $company_id,
			'T81IncomingResult.del_flag' => 'N',
			'T81IncomingResult.call_datetime >=' => $date_from . ' 00:00:00',
			'T81IncomingResult.call_datetime <=' => $date_to . ' 23:59:59',
			'T81IncomingResult.status !=' => 'recover',
		);
		if ($tel_number) {
			$condition_joins['T25Inbound.external_number'] = $tel_number;
		}
		$options['joins'] = array(
			array(
				'table' => 't81_incoming_results',
				'alias' => 'T81IncomingResult',
				'type' => 'inner',
				'conditions' => $condition_joins
			),
		);

		return $this->find('count', $options);
	}

	function getScheduleByCompanyAndTel($company_id=null, $tel_number=null, $date_from=null, $date_to=null) {
        $options['fields'] = array(
            'T25Inbound.id',
            'T25Inbound.external_number',
            'T25Inbound.list_id',
        );
        $options['joins'] = array(
            array(
                'table' => 't81_incoming_results',
                'alias' => 'T81IncomingResult',
                'type' => 'INNER',
                'conditions' => array(
                    'T25Inbound.id = T81IncomingResult.inbound_id',
                )
            )
        );
        $options['conditions']['T25Inbound.company_id'] = $company_id;
        $options['conditions']['T81IncomingResult.call_datetime >='] = $date_from . ' 00:00:00';
        $options['conditions']['T81IncomingResult.call_datetime <='] = $date_to . ' 23:59:59';
        if ($tel_number) {
            $options['conditions']['T25Inbound.external_number'] = $tel_number;
        }
        $options['order'] = array('T25Inbound.time_start');
        $options['group'] = array('T25Inbound.id');

        return $this->find('all', $options);
	}
}