<?php

/**
 * T31TemplateQuestion model.
 */
class T31TemplateQuestion extends AppModel {
    var $name = 'T31TemplateQuestion';

	function getTransQuesByTemplateId($template_id=null) {
		$options['fields'] = array(
			'T31TemplateQuestion.trans_seat_num',
		);

		$options['conditions']['T31TemplateQuestion.template_id'] = $template_id;
		$options['conditions']['T31TemplateQuestion.question_type'] = QUESTION_TRANS;
		$options['conditions']['T31TemplateQuestion.del_flag'] = 'N';

		return $this->find('first', $options);
	}

	function countQuesByTemplateId($template_id){
        $options['fields'] = array(
            'T31TemplateQuestion.*',
        );

        $options['conditions']['T31TemplateQuestion.template_id'] = $template_id;
        $options['conditions']['T31TemplateQuestion.del_flag'] = 'N';

        $options['order'] = array('T31TemplateQuestion.question_no asc');
        //検索
        return $this->find('count', $options);
    }

    function getInfoQuesByTemplateId($template_id){
    	$options['fields'] = array(
    		'T31TemplateQuestion.question_no',
    		'COUNT(T32TemplateButton.answer_no) as num_answ',
    	);
        $options['joins'] = array(
            array(
                'table' => 't32_template_buttons',
                'alias' => 'T32TemplateButton',
                'type' => 'left',
                'conditions' => array(
                    'T31TemplateQuestion.template_id = T32TemplateButton.template_id',
                    'T32TemplateButton.del_flag = "N"',
                )
            ),
        );

    	$options['conditions']['T31TemplateQuestion.del_flag'] = 'N';
    	$options['order'] = array('T31TemplateQuestion.question_no asc');
    	//検索
    	return $this->find('all', $options);
    }

    function getQuesAnwsByTemplateId($template_id){
    	$options['fields'] = array(
    		'T31TemplateQuestion.question_no',
    		'MAX(T32TemplateButton.answer_no) as num_answ',
    	);

    	//内部結合条件
    	$options['joins'] = array(
    		array(
    			'table' => 't32_template_buttons',
    			'alias' => 'T32TemplateButton',
    			'type' => 'left',
    			'conditions' => array(
    				'T31TemplateQuestion.template_id = T32TemplateButton.template_id',
    				'T31TemplateQuestion.question_no = T32TemplateButton.question_no',
    				'T32TemplateButton.answer_no not in ("51", "52")',
    				'T32TemplateButton.del_flag = "N"',
    			)
    		),
    	);
    	$options['conditions']['T31TemplateQuestion.template_id'] = $template_id;
    	$options['conditions']['T31TemplateQuestion.question_no <>'] = array("0", "21", "22");
    	$options['conditions']['T31TemplateQuestion.del_flag'] = 'N';
    	$options['group'] = array('T31TemplateQuestion.template_id', 'T31TemplateQuestion.question_no');
    	$options['order'] = array('T31TemplateQuestion.question_no asc');
    	//検索
    	return $this->find('all', $options);
    }

	function getQuesByTemplateId($template_id){
    	$options['fields'] = array(
    		'T31TemplateQuestion.*',
    	);

    	$options['conditions']['T31TemplateQuestion.template_id'] = $template_id;
    	$options['conditions']['T31TemplateQuestion.del_flag'] = 'N';
        $options['order'] = array('T31TemplateQuestion.question_no asc');

        return $this->find('all', $options);
	}

    function getQuesById($id){
        $options['fields'] = array(
            'T31TemplateQuestion.*',
        );

        $options['conditions']['T31TemplateQuestion.id'] = $id;
        $options['conditions']['T31TemplateQuestion.del_flag'] = 'N';

        //検索
        return $this->find('first', $options);
    }

	function getInfoQuesAnwsByTemplateId($template_id){
		$options['fields'] = array(
			'T31TemplateQuestion.id',
			'T31TemplateQuestion.question_no',
			'T31TemplateQuestion.question_type',
			'T31TemplateQuestion.question_title',
			'T32TemplateButton.id',
			'T32TemplateButton.question_no',
			'T32TemplateButton.answer_no',
			'T32TemplateButton.answer_content'
		);

		//内部結合条件
		$options['joins'] = array(
			array(
				'table' => 't32_template_buttons',
				'alias' => 'T32TemplateButton',
				'type' => 'left',
				'conditions' => array(
					'T31TemplateQuestion.template_id = T32TemplateButton.template_id',
					'T31TemplateQuestion.question_no = T32TemplateButton.question_no',
					'T32TemplateButton.del_flag = "N"',
				)
			),
		);

		$without_question_no = array('0', '21', '22');
		$options['conditions'] = array(
			'T31TemplateQuestion.del_flag' => 'N',
			'T31TemplateQuestion.template_id' => $template_id,
			'T31TemplateQuestion.question_no NOT IN' => $without_question_no
		);
		$options['order'] = array('T31TemplateQuestion.question_no asc');
		//検索
		return $this->find('all', $options);
	}

    /**
     * Get max id.
     */
    function getMaxId() {
        $options['fields'] = array(
            'max(T31TemplateQuestion.id) as id',
        );
        return $this->find('first', $options);
    }

	function getQuesNumByTemplateId($template_id) {
		$options['fields'] = array(
			'T31TemplateQuestion.question_no'
		);

		$options['conditions']['T31TemplateQuestion.template_id'] = $template_id;
		$options['conditions']['T31TemplateQuestion.question_no <>'] = array("0", "21", "22");
		$options['conditions']['T31TemplateQuestion.del_flag'] = 'N';

		$options['group'] = array('T31TemplateQuestion.question_no');
		$options['order'] = array('T31TemplateQuestion.question_no asc');

		return $this->find('all', $options);
	}

	function checkQuestionType($questionId, $type) {
		$options['fields'] = array(
			'T31TemplateQuestion.question_type'
		);

        $options['conditions']['T31TemplateQuestion.id'] = $questionId;
		$options['conditions']['T31TemplateQuestion.question_type'] = $type;
		$options['conditions']['T31TemplateQuestion.del_flag'] = 'N';

		return $this->find('count', $options) > 0;
	}

	function getQuestionYukoByTemplateId($template_id){
		$options['fields'] = array(
				'T31TemplateQuestion.*'
		);

		$options['conditions']['T31TemplateQuestion.template_id'] = $template_id;
		$options['conditions']['T31TemplateQuestion.question_yuko'] = '1';
		$options['conditions']['T31TemplateQuestion.del_flag'] = 'N';

		return $this->find('all', $options);
	}
	/* Check template have $question_type
	* @param $template_id
	* @param $question_type
	* @return boolean. TRUE if question_type question existed, otherwise return FALSE
  
  */
  function checkExistQuestionType($template_id, $question_type) {
      $options['fields'] = array(
          'T31TemplateQuestion.question_type'
      );

      $options['conditions']['T31TemplateQuestion.template_id'] = $template_id;
      $options['conditions']['T31TemplateQuestion.question_type'] = $question_type;
      $options['conditions']['T31TemplateQuestion.del_flag'] = 'N';
      return $this->find('count', $options) > 0;
  }
}