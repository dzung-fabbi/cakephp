<?php

/**
 * T64InboundQuestionHistory model.
 */
class T64InboundQuestionHistory extends AppModel {
    var $name = 'T64InboundQuestionHistory';

	function getQuesNumByScheduleId($inbound_id=null, $question_types=array()) {
		$options['fields'] = array(
			'T64InboundQuestionHistory.question_title',
			'T64InboundQuestionHistory.question_no',
			'T64InboundQuestionHistory.question_type',
			'T64InboundQuestionHistory.recheck_flag',
			'T64InboundQuestionHistory.recheck_button_next',
			'T64InboundQuestionHistory.auth_item',
			'T64InboundQuestionHistory.auth_match_flag',
		);

		$options['conditions']['T64InboundQuestionHistory.inbound_id'] = $inbound_id;
		$options['conditions']['T64InboundQuestionHistory.del_flag'] = 'N';
		if (!empty($question_types)) {
			$options['conditions']['T64InboundQuestionHistory.question_type'] = $question_types;
		}

		$options['group'] = array('T64InboundQuestionHistory.question_no');
		$options['order'] = array('CAST(T64InboundQuestionHistory.question_no AS UNSIGNED) asc');

		return $this->find('all', $options);
	}

	function getInfoQuesAnswByScheduleId ($inbound_id, $question_types=array()){
		$options['fields'] = array(
			'T64InboundQuestionHistory.id',
			'T64InboundQuestionHistory.question_no',
			'T64InboundQuestionHistory.question_yuko',
			'T64InboundQuestionHistory.question_type',
			'T64InboundQuestionHistory.question_title',
			'T64InboundQuestionHistory.auth_item',
			'T64InboundQuestionHistory.auth_match_flag',
			'T64InboundQuestionHistory.recheck_flag',
			'T64InboundQuestionHistory.recheck_button_next',
			'T64InboundQuestionHistory.recheck_button_prev',
			'T65InboundButtonHistory.id',
			'T65InboundButtonHistory.question_no',
			'T65InboundButtonHistory.answer_no',
			'T65InboundButtonHistory.answer_content'
		);

		$options['joins'] = array(
			array(
				'table' => 't65_inbound_button_histories',
				'alias' => 'T65InboundButtonHistory',
				'type' => 'left',
				'conditions' => array(
					'T64InboundQuestionHistory.inbound_id = T65InboundButtonHistory.inbound_id',
					'T64InboundQuestionHistory.question_no = T65InboundButtonHistory.question_no',
					'T65InboundButtonHistory.del_flag = "N"',
				)
			),
		);

		$options['conditions'] = array(
			'T64InboundQuestionHistory.del_flag' => 'N',
			'T64InboundQuestionHistory.inbound_id' => $inbound_id,
		);
		if (sizeof($question_types) > 0) {
			$options['conditions']['T64InboundQuestionHistory.question_type'] = $question_types;
		}
		$options['order'] = array(
			'T64InboundQuestionHistory.question_no asc',
			'T65InboundButtonHistory.answer_no asc'
		);

		return $this->find('all', $options);
	}

	function getInfoQuesAnswYukoByScheduleId ($inbound_id){
		$yuko_question_types = array(
			QUESTION_AUTH,
			QUESTION_AUTH_CHAR,
			QUESTION_BASIC
		);

		$options['fields'] = array(
			'T64InboundQuestionHistory.id',
			'T64InboundQuestionHistory.question_no',
			'T64InboundQuestionHistory.question_type',
			'T64InboundQuestionHistory.question_title',
			'T64InboundQuestionHistory.auth_item',
			'T64InboundQuestionHistory.auth_match_flag',
			'T64InboundQuestionHistory.recheck_flag',
			'T64InboundQuestionHistory.recheck_button_next',
			'T64InboundQuestionHistory.recheck_button_prev',
			'T65InboundButtonHistory.id',
			'T65InboundButtonHistory.question_no',
			'T65InboundButtonHistory.answer_no',
			'T65InboundButtonHistory.answer_content'
		);

		$options['joins'] = array(
			array(
				'table' => 't65_inbound_button_histories',
				'alias' => 'T65InboundButtonHistory',
				'type' => 'left',
				'conditions' => array(
					'T64InboundQuestionHistory.inbound_id = T65InboundButtonHistory.inbound_id',
					'T64InboundQuestionHistory.question_no = T65InboundButtonHistory.question_no',
					'T65InboundButtonHistory.del_flag = "N"',
					'T65InboundButtonHistory.yuko_flag = "1"',
				)
			),
		);

		$options['conditions'] = array(
			'T64InboundQuestionHistory.del_flag' => 'N',
			'T64InboundQuestionHistory.inbound_id' => $inbound_id,
			'T64InboundQuestionHistory.question_type' => $yuko_question_types,
			'T64InboundQuestionHistory.question_yuko' => '1',
		);

		$options['order'] = array(
			'T64InboundQuestionHistory.question_no asc',
			'T65InboundButtonHistory.answer_no asc'
		);
		return $this->find('all', $options);
	}
}