<?php

class T91ActionHistory extends AppModel {
	var $name = 'T91ActionHistory';
	
	/*function getLoginId($user_id, $session_id){
		//取得項目
		$options['fields'] = array(
			'T91ActionHistory.id',
		);
		//条件
		$options['conditions']['T91ActionHistory.user_id'] = $user_id;
		$options['conditions']['T91ActionHistory.session_id'] = $session_id;
		
		return $this->find('all', $options);
	}*/

	function getLastHistory($user_id, $client_id, $session_id){
		$options['fields'] = array(
			'T91ActionHistory.id',
			'T91ActionHistory.created'
		);
		//条件
		$options['conditions']['T91ActionHistory.user_id'] = $user_id;
		$options['conditions']['T91ActionHistory.client_ip'] = $client_id;
		$options['conditions']['T91ActionHistory.session_id'] = $session_id;

		$options['order'] = array(
			'T91ActionHistory.created DESC'
		);

		return $this->find('first', $options);
	}
}

?>