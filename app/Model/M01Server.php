<?php

class M01Server extends AppModel {
	var $name = 'M01Server';

    function getServerByExternalNumber($external_number, $server_type) {
    	$options['fields'] = array(
    		'M01Server.server_id',
    		'M01Server.server_ip',
    		'M01Server.local_path',
    	);
    	$options['joins'] = array(
    		array(
    			'table' => 'm07_server_externals',
    			'alias' => 'M07ServerExternals',
    			'type' => 'inner',
    			'conditions' => array(
    				'M01Server.server_id = M07ServerExternals.server_id' ,
					'M07ServerExternals.del_flag = "N"',
    			),
    		)
    	);
    	$options['conditions']['M07ServerExternals.external_number'] = $external_number;
    	$options['conditions']['M01Server.server_type'] = $server_type;
    	$options['conditions']['M01Server.del_flag'] = "N";
    	return $this->find('first', $options);
    }

    function getInfoServerByServerId($server_id){
    	$options['fields'] = array(
    			'M01Server.server_id',
    			'M01Server.server_ip',
    			'M01Server.local_path',
    	);
    	$options['conditions']['M01Server.server_id'] = $server_id;
    	$options['conditions']['M01Server.del_flag'] = "N";
    	return $this->find('first', $options);
    }

    function getOutServerByScheduleId($schedule_id) {
    	$options['fields'] = array(
    			'M01Server.server_id',
    			'M01Server.server_ip',
    			'M01Server.local_path',
    	);
    	$options['joins'] = array(
    			array(
	    			'table' => 'm07_server_externals',
	    			'alias' => 'M07ServerExternals',
	    			'type' => 'inner',
	    			'conditions' => array(
	    				'M01Server.server_id = M07ServerExternals.server_id',
	    				'M07ServerExternals.del_flag = "N"',
    				),
    			),
    			array(
    				'table' => 't20_out_schedules',
    				'alias' => 'T20OutSchedules',
    				'type' => 'inner',
    				'conditions' => array(
    					'T20OutSchedules.external_number = M07ServerExternals.external_number',
    					'T20OutSchedules.del_flag = "N"',
    				),
    			)
    	);
    	$options['conditions']['T20OutSchedules.id'] = $schedule_id;
    	$options['conditions']['M01Server.server_type'] = "1";
    	$options['conditions']['M01Server.del_flag'] = "N";
    	return $this->find('first', $options);
    }

	function getOutServerBySmsScheduleId($schedule_id) {
		$options['fields'] = array(
			'M01Server.server_id',
			'M01Server.server_ip',
			'M01Server.local_path',
		);
		$options['joins'] = array(
			array(
				'table' => 'm07_server_externals',
				'alias' => 'M07ServerExternals',
				'type' => 'inner',
				'conditions' => array(
					'M01Server.server_id = M07ServerExternals.server_id',
					'M07ServerExternals.del_flag = "N"',
				),
			),
			array(
				'table' => 't200_sms_send_schedules',
				'alias' => 'T200SmsSchedule',
				'type' => 'inner',
				'conditions' => array(
					'T200SmsSchedule.external_number = M07ServerExternals.external_number',
					'T200SmsSchedule.del_flag = "N"',
				),
			)
		);
		$options['conditions']['T200SmsSchedule.id'] = $schedule_id;
		$options['conditions']['M01Server.server_type'] = "1";
		$options['conditions']['M01Server.del_flag'] = "N";
		return $this->find('first', $options);
	}
}
?>