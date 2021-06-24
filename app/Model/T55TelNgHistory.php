<?php

/**
 * T55TelNgHistory model.
 */
class T55TelNgHistory extends AppModel {
	var $name = 'T55TelNgHistory';

	function getTelNgByScheduleId($schedule_id) {
		$options['fields'] = array(
			'T55TelNgHistory.tel_no',
		);
		$options['conditions'] = array(
			'T55TelNgHistory.schedule_id' => $schedule_id,
			'T55TelNgHistory.del_flag' => "N",
		);
		return $this->find('all', $options);
	}
}