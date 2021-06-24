<?php

/**
 * T61QuestionHistory model.
 */
class T61QuestionHistory extends AppModel {
    var $name = 'T61QuestionHistory';

	function getQuesNumByScheduleId($schedule_id=null, $question_types=array()) {
		$options['fields'] = array(
			'T61QuestionHistory.question_title',
			'T61QuestionHistory.question_no',
			'T61QuestionHistory.question_type',
			'T61QuestionHistory.recheck_flag',
			'T61QuestionHistory.recheck_button_next',
			'T61QuestionHistory.auth_item',
		);

		$options['conditions']['T61QuestionHistory.schedule_id'] = $schedule_id;
		$options['conditions']['T61QuestionHistory.del_flag'] = 'N';
		if (sizeof($question_types) > 0) {
			$options['conditions']['T61QuestionHistory.question_type'] = $question_types;
		}

		$options['group'] = array('T61QuestionHistory.question_no');
		$options['order'] = array('CAST(T61QuestionHistory.question_no AS UNSIGNED) asc');

		return $this->find('all', $options);
	}

	function getInfoQuesAnswByScheduleId ($schedule_id, $question_types=array()){
		$options['fields'] = array(
			'T61QuestionHistory.id',
			'T61QuestionHistory.question_no',
			'T61QuestionHistory.question_yuko',
			'T61QuestionHistory.question_type',
			'T61QuestionHistory.question_title',
			'T61QuestionHistory.auth_item',
			'T61QuestionHistory.recheck_flag',
			'T61QuestionHistory.recheck_button_next',
			'T61QuestionHistory.recheck_button_prev',
			'T62ButtonHistory.id',
			'T62ButtonHistory.question_no',
			'T62ButtonHistory.answer_no',
			'T62ButtonHistory.answer_content',
			'T61QuestionHistory.sms_content'
		);

		//??????
		$options['joins'] = array(
			array(
				'table' => 't62_button_histories',
				'alias' => 'T62ButtonHistory',
				'type' => 'left',
				'conditions' => array(
					'T61QuestionHistory.schedule_id = T62ButtonHistory.schedule_id',
					'T61QuestionHistory.question_no = T62ButtonHistory.question_no',
					'T62ButtonHistory.del_flag = "N"',
				)
			),
		);

		$options['conditions'] = array(
			'T61QuestionHistory.del_flag' => 'N',
			'T61QuestionHistory.schedule_id' => $schedule_id,
		);
		if (sizeof($question_types) > 0) {
			$options['conditions']['T61QuestionHistory.question_type'] = $question_types;
		}
		$options['order'] = array(
			'T61QuestionHistory.question_no asc',
			'T62ButtonHistory.answer_no asc'
		);
		//??
		return $this->find('all', $options);
	}

	function getQuesAnswByScheduleId ($schedule_id, $question_types=array()){
		$options['fields'] = array(
			'T61QuestionHistory.question_no',
			'count(T62ButtonHistory.answer_no) as num_answ',
		);

		//??????
		$options['joins'] = array(
			array(
				'table' => 't62_button_histories',
				'alias' => 'T62ButtonHistory',
				'type' => 'left',
				'conditions' => array(
					'T61QuestionHistory.schedule_id = T62ButtonHistory.schedule_id',
					'T61QuestionHistory.question_no = T62ButtonHistory.question_no',
					'T62ButtonHistory.del_flag = "N"',
				)
			),
		);
		$options['conditions']['T61QuestionHistory.schedule_id'] = $schedule_id;
		$options['conditions']['T61QuestionHistory.del_flag'] = 'N';
		if (sizeof($question_types) > 0) {
			$options['conditions']['T61QuestionHistory.question_type'] = $question_types;
		}
		$options['group'] = array('T61QuestionHistory.schedule_id', 'T61QuestionHistory.question_no');
		$options['order'] = array('CAST(T61QuestionHistory.question_no AS UNSIGNED) asc');
		//??
		return $this->find('all', $options);
	}

	function getInfoQuesAnswYukoByScheduleId ($schedule_id){
		//20160223 Add by Thai : #6513 - Update get yuko question - Begin
		$yuko_question_types = array(
			QUESTION_AUTH,
			QUESTION_BASIC,
			QUESTION_AUTH_CHAR
		);
		//20160223 Add by Thai : #6513 - Update get yuko question - End

		$options['fields'] = array(
			'T61QuestionHistory.id',
			'T61QuestionHistory.question_no',
			'T61QuestionHistory.question_type',
			'T61QuestionHistory.question_title',
			'T61QuestionHistory.auth_item',
			'T61QuestionHistory.recheck_flag',
			'T61QuestionHistory.recheck_button_next',
			'T61QuestionHistory.recheck_button_prev',
			'T62ButtonHistory.id',
			'T62ButtonHistory.question_no',
			'T62ButtonHistory.answer_no',
			'T62ButtonHistory.answer_content'
		);

		//??????
		$options['joins'] = array(
			array(
				'table' => 't62_button_histories',
				'alias' => 'T62ButtonHistory',
				'type' => 'inner',
				'conditions' => array(
					'T61QuestionHistory.schedule_id = T62ButtonHistory.schedule_id',
					'T61QuestionHistory.question_no = T62ButtonHistory.question_no',
					'T62ButtonHistory.del_flag = "N"',
					'T62ButtonHistory.yuko_flag = "1"',
				)
			),
		);

		$options['conditions'] = array(
			'T61QuestionHistory.del_flag' => 'N',
			'T61QuestionHistory.schedule_id' => $schedule_id,
			'T61QuestionHistory.question_type' => $yuko_question_types,
			'T61QuestionHistory.question_yuko' => '1',

		);
		//20160223 Delete by Thai : #6513 - Update get yuko question - Begin
/*		if (sizeof($question_types) > 0) {
			$options['conditions']['T61QuestionHistory.question_type'] = $question_types;
		}*/
		//20160223 Delete by Thai : #6513 - Update get yuko question - Begin
		$options['order'] = array(
			'T61QuestionHistory.question_no asc',
			'T62ButtonHistory.answer_no asc'
		);
		//??
		return $this->find('all', $options);
	}
}