<?php

/**
 * T51TelHistory model.
 */
class T51TelHistory extends AppModel {
	var $name = 'T51TelHistory';

	function getTelNotCalls($schedule_id=null, $tel_column=null) {
		$options['fields'] = array(
			'T51TelHistory.*'
		);
		$options['conditions'] = array(
			'T51TelHistory.del_flag' => 'N',
			'T51TelHistory.schedule_id' => $schedule_id,
			"T51TelHistory." . $tel_column . " NOT IN (select tel_no from t80_outgoing_results where schedule_id = '" . $schedule_id . "')"
		);

		return $this->find('all', $options);
	}

	function getByTels($schedule_id=null, $arr_tels=array(), $tel_column=null) {
		$options['fields'] = array(
			'T51TelHistory.*'
		);
		$options['conditions'] = array(
			'T51TelHistory.del_flag' => 'N',
			'T51TelHistory.schedule_id' => $schedule_id,
			"T51TelHistory." . $tel_column => $arr_tels
		);

		return $this->find('all', $options);
	}

	function getTelTotalByScheduleId($schedule_id=null, $tel_num_col=null, $tel_ng_arr=null) {
		$options['conditions'] = array(
			'T51TelHistory.del_flag' => 'N',
			'T51TelHistory.muko_flag' => 'N',
			'T51TelHistory.schedule_id' => $schedule_id
		);

		if ($tel_num_col && $tel_ng_arr) {
			$options['conditions']['NOT'] = array(
				"T51TelHistory.$tel_num_col" => $tel_ng_arr
			);
		}

		return $this->find('count', $options);
	}
}