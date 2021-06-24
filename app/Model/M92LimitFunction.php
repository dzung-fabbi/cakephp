<?php

class M92LimitFunction extends AppModel {
	var $name = 'M92LimitFunction';

	function getLimitFuncByCompany($company_id, $template_type, $function_name){
		$options['fields'] = array(
			'M92LimitFunction.value',
			'M92LimitFunction.id',
		);
		$options['conditions']['M92LimitFunction.company_id'] = $company_id;
		$options['conditions']['M92LimitFunction.template_type'] = $template_type;
		$options['conditions']['M92LimitFunction.function_name'] = $function_name;
		$options['conditions']['M92LimitFunction.del_flag'] = 'N';

		return $this->find('list', $options);
	}
}

?>