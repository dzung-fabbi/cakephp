<?php

class T90LoginHistory extends AppModel {
	var $name = 'T90LoginHistory';
	
	function getLoginId($user_id, $session_id){
		//取得項目
		$options['fields'] = array(
			'T90LoginHistory.id',
		);
		//条件
		$options['conditions']['T90LoginHistory.user_id'] = $user_id;
		$options['conditions']['T90LoginHistory.session_id'] = $session_id;
		$options['conditions']['T90LoginHistory.login_flag'] = 'N';
		
		return $this->find('all', $options);
	}

	function getLastByUserId($user_id=null, $session_id=null) {
		$options['conditions']['T90LoginHistory.user_id'] = $user_id;
		$options['conditions']['T90LoginHistory.del_flag'] = 'N';
		$options['conditions']['T90LoginHistory.login_flag'] = 'N';

		if ($session_id) {
			$options['conditions']['T90LoginHistory.session_id'] = $session_id;
		}

		$options['order'] = array(
			'T90LoginHistory.modified DESC',
			'T90LoginHistory.created DESC',
		);

		return $this->find('first', $options);
	}

	function getLoginFailure($user_id=null, $session_id=null) {
		$options['conditions']['T90LoginHistory.user_id'] = $user_id;
		$options['conditions']['T90LoginHistory.del_flag'] = 'N';
		$options['conditions']['T90LoginHistory.login_flag'] = 'Y';
		$options['conditions']['T90LoginHistory.session_id'] = $session_id;

		return $this->find('count', $options);
	}
	
}

?>