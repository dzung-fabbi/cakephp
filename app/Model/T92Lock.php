<?php

class T92Lock extends AppModel {
	var $name = 'T92Lock';

	function getInfoLock($lock_flag, $lock_id){
		$options['fields'] = array(
			'T92Lock.*',
		);

		$options['conditions']['T92Lock.lock_flag'] = $lock_flag;
		$options['conditions']['T92Lock.lock_id'] = $lock_id;
		$options['conditions']['T92Lock.del_flag'] = 'N';
		return $this->find('first', $options);
	}
}

?>