<?php

/**
 * T52TelRedial model.
 */
class T52TelRedial extends AppModel {
	var $name = 'T52TelRedial';

	function getTelTotalByScheduleId($schedule_id=null, $tel_num_col=null, $tel_ng_arr=array(), $redial_flag=null) {
		$options['conditions'] = array(
			'T52TelRedial.del_flag' => 'N',
			'T52TelRedial.schedule_id' => $schedule_id
		);

		if ($tel_num_col && !empty($tel_ng_arr)) {
			$options['conditions']['NOT'] = array(
				"T52TelRedial.$tel_num_col" => $tel_ng_arr
			);
		}
		if(isset($redial_flag))
			$options['conditions']['T52TelRedial.redial_flag'] = $redial_flag;
		return $this->find('count', $options);
	}
}