<?php

/**
 * T82BukkenFaxStatus model.
 */
class T82BukkenFaxStatus extends AppModel {
	var $name = 'T82BukkenFaxStatus';

	function getFaxStatus($log_id, $question_no) {
		$options['fields'] = array(
			'T82BukkenFaxStatus.*'
		);
		$options['conditions'] = array(
			'T82BukkenFaxStatus.log_id' => $log_id,
            'T82BukkenFaxStatus.fax_question_no' => $question_no,
            'T82BukkenFaxStatus.del_flag' => 'N'
		);
		return $this->find('first', $options);
	}	
}