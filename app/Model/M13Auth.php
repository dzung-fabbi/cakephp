<?php

class M13Auth extends AppModel {
	var $name = 'M13Auth';
	
	function getAllAuth($post_code){
		
		//取得項目
		$options['fields'] = array(
				'M13Auth.id',
				'M13Auth.post_code',
				'M13Auth.post_name',
		);
		
		//検索条件
		$options['conditions']['post_code >='] = $post_code;
		
		//ソート
		$options['order'] = array('M13Auth.post_code ASC');
		//検索
		return $this->find('all', $options);
	}
	
}
?>