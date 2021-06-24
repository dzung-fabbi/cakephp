<?php

/**
 * Created by PhpStorm.
 * User: PTT
 * Date: 8/13/2015
 * Time: 11:14 AM
 */
class M99SystemParameter extends AppModel {
    var $name = 'M99SystemParameter';

    function getByFunctionIdAndParameterId($function_id='', $parameter_id='') {
        $options['fields'] = array(
            'M99SystemParameter.parameter_value'
        );

        $options['conditions'] = array(
            'M99SystemParameter.function_id' => $function_id,
            'M99SystemParameter.parameter_id' => $parameter_id,
            'M99SystemParameter.del_flag' => 'N',
        );

        return $this->find('first', $options);
    }

    function getByFunctionIdAndParameterIdAll($function_id='', $parameter_id='') {
        $options['fields'] = array(
            'M99SystemParameter.parameter_value'
        );

        $options['conditions'] = array(
            'M99SystemParameter.function_id' => $function_id,
            'M99SystemParameter.parameter_id' => $parameter_id,
            'M99SystemParameter.del_flag' => 'N',
        );

        return $this->find('all', $options);
    }
}
