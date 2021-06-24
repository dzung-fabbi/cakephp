<?php

class M04ControllerAction extends AppModel {
	var $name = 'M04ControllerAction';

	function check_permission($post_code, $controller_name=null, $function_name=null) {
		$options['fields'] = array(
			'M04ControllerAction.*',
		);

		$options['conditions']['M04ControllerAction.post_code'] = $post_code;
		$options['conditions']['M04ControllerAction.controller_name'] = $controller_name;
		$options['conditions']['M04ControllerAction.function_name'] = $function_name;
		$options['conditions']['M04ControllerAction.del_flag'] = 'N';

		return $this->find('count', $options) == 0;
	}
}

?>
