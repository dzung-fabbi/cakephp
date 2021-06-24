<?php

class M03Auth extends AppModel {
	var $name = 'M03Auth';

	function getAuthByPostCode($post_code, $post_code_pre) {
		$options['fields'] = array(
			'M03Auth.post_code',
			'M03Auth.post_name'
		);

		$options['conditions']['M03Auth.post_code >='] = $post_code;
		$options['conditions']['M03Auth.post_code LIKE'] = $post_code_pre;
		$options['conditions']['M03Auth.del_flag'] = 'N';
		$options['order'] = array('M03Auth.order_num');

		return $this->find('all', $options);
	}

	function getRankByPostCode($post_code) {
		$options['fields'] = array(
			'M03Auth.rank',
		);

		$options['conditions']['M03Auth.del_flag'] = 'N';
		$options['conditions']['M03Auth.post_code'] = $post_code;

		return $this->find('first', $options);
	}
	
	function getPostNameByPostCode($post_code = null) {
		$options['fields'] = array(
			'M03Auth.post_name',
		);

		$options['conditions']['M03Auth.post_code ='] = $post_code;
		$options['conditions']['M03Auth.del_flag'] = 'N';
		$options['order'] = array('M03Auth.order_num');

		return $this->find('all', $options);
	}

}