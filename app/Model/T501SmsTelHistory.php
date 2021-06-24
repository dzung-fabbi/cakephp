<?php

/**
 * T501SmsTelHistory model.
 */
class T501SmsTelHistory extends AppModel {
	var $name = 'T501SmsTelHistory';

	function getTelNotSends($schedule_id=null, $tel_column=null) {
		$options['fields'] = array(
			'T501SmsTelHistory.*'
		);
		$options['conditions'] = array(
			'T501SmsTelHistory.del_flag' => 'N',
			'T501SmsTelHistory.schedule_id' => $schedule_id,
			"T501SmsTelHistory." . $tel_column . " NOT IN (select tel_no from t800_sms_send_results where schedule_id = '" . $schedule_id . "')"
		);

		return $this->find('all', $options);
	}

	function getByTels($schedule_id=null, $arr_tels=array(), $tel_column=null) {
		$options['fields'] = array(
			'T501SmsTelHistory.*'
		);
		$options['conditions'] = array(
			'T501SmsTelHistory.del_flag' => 'N',
			'T501SmsTelHistory.schedule_id' => $schedule_id,
			"T501SmsTelHistory." . $tel_column => $arr_tels
		);

		return $this->find('all', $options);
	}
}