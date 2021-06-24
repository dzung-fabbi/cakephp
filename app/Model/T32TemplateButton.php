<?php

/**
 * T32TemplateButton model.
 */
class T32TemplateButton extends AppModel {
    var $name = 'T32TemplateButton';

    function getInfoAnswByTemplateId($template_id){
    	$options['fields'] = array(
    		'T32TemplateButton.*',
    	);
    	$options['conditions']['T32TemplateButton.template_id'] = $template_id;
    	$options['conditions']['T32TemplateButton.del_flag'] = 'N';
    	$options['order'] = array('T32TemplateButton.question_no asc', 'T32TemplateButton.answer_no asc');
    	return $this->find('all', $options);
    }


	function getAnwsByScriptId($script_id){
    	$options['fields'] = array(
    		'T32ScriptButton.*',
    	);

    	$options['conditions']['T32ScriptButton.script_id'] = $script_id;
    	$options['conditions']['T32ScriptButton.del_flag'] = 'N';

    	$options['order'] = array('T32ScriptButton.question_num asc', 'T32ScriptButton.no asc');
    	//検索
    	return $this->find('all', $options);
    }

    function getScriptButtonById($id){
        $options['fields'] = array(
            'T32ScriptButton.*',
        );

        $options['conditions']['T32ScriptButton.id'] = $id;
        $options['conditions']['T32ScriptButton.del_flag'] = 'N';

        //検索
        return $this->find('first', $options);
    }

    /**
     * Get max id.
     */
    function getMaxId() {
        $options['fields'] = array(
            'max(T32ScriptButton.id) as id',
        );
        return $this->find('first', $options);
    }

    function countInfoAnswByTemplateId($template_id)
    {
        $options['fields'] = array(
            'T32TemplateButton.*',
        );
        $options['conditions']['T32TemplateButton.template_id'] = $template_id;
        $options['conditions']['T32TemplateButton.del_flag'] = 'N';
        return $this->find('count', $options);
    }

    function getAnwsByQuestionNo($template_id, $question_no){
        $options['fields'] = array(
            'T32TemplateButton.*',
        );

        $options['conditions']['T32TemplateButton.template_id'] = $template_id;
        $options['conditions']['T32TemplateButton.question_no'] = $question_no;
        $options['conditions']['T32TemplateButton.del_flag'] = 'N';

        $options['order'] = array('T32TemplateButton.answer_no asc');
        return $this->find('all', $options);
    }

    function getAnwsByTemplateId($template_id){
    	$options['fields'] = array(
    			'T32TemplateButton.*',
    	);

    	$options['conditions']['T32TemplateButton.template_id'] = $template_id;
    	$options['conditions']['T32TemplateButton.del_flag'] = 'N';

    	return $this->find('all', $options);
    }
}