<?php

class T16InboundCallList extends AppModel {
	var $name = 'T16InboundCallList';

	function getListByCompanyId($company_id, $limit=null, $page=null, $sort_order=null, $filter=null) {
		$options['fields'] = array(
			'T16InboundCallList.*',
			'M05User.user_name',
		);

		$options['joins'] = array(
			array(
				'table' => 'm05_users',
				'alias' => 'M05User',
				'fields' => array('user_name'),
				'type' => 'left',
				'conditions' => array(
					'T16InboundCallList.entry_user = M05User.user_id',
				),
			),
		);

		if(isset($filter) && !empty($filter)){
			if(isset($filter[1])){
				$options['conditions']['T16InboundCallList.list_no LIKE'] = "%".$filter[1]."%";
			}
			if(isset($filter[2])){
				$options['conditions']['T16InboundCallList.list_name LIKE'] = "%".$filter[2]."%";
			}
			if(isset($filter[3])){
				$options['conditions']['T16InboundCallList.tel_total LIKE'] = "%".$filter[3]."%";
			}
			if(isset($filter[4])){
				$options['conditions']['DATE_FORMAT(T16InboundCallList.created, "%Y-%m-%d %k:%i") LIKE'] = "%".$filter[4]."%";
			}
			if(isset($filter[5])){
				$options['conditions']['M05User.user_name LIKE'] = "%".$filter[5]."%";
			}
		}
		$options['conditions']['T16InboundCallList.company_id'] = $company_id;
		$options['conditions']['T16InboundCallList.del_flag'] = "N";
		if(isset($sort_order) && !empty($sort_order)){
			$options['order'] = $sort_order;
		}else{
			$options['order'] = array(
				'T16InboundCallList.list_test_flag desc',
				'T16InboundCallList.created desc',
			);
		}
		if(isset($limit) && !empty($limit)){
			$options['limit'] = $limit;
		}
		if(isset($page) && !empty($page)){
			$options['page'] = $page;
		}
		return $this->find('all', $options);
	}

	function getListByCompanyIdCount($company_id, $filter=null) {
		$options['fields'] = array(
			'T16InboundCallList.*',
			'M05User.user_name',
		);

		$options['joins'] = array(
			array(
				'table' => 'm05_users',
				'alias' => 'M05User',
				'type' => 'left',
				'conditions' => array(
					'T16InboundCallList.entry_user = M05User.user_id',
				),
			),
		);

		$options['conditions']['T16InboundCallList.company_id'] = $company_id;
		$options['conditions']['T16InboundCallList.del_flag'] = "N";
		if(isset($filter) && !empty($filter)){
			if(isset($filter[1])){
				$options['conditions']['T16InboundCallList.list_no LIKE'] = "%".$filter[1]."%";
			}
			if(isset($filter[2])){
				$options['conditions']['T16InboundCallList.list_name LIKE'] = "%".$filter[2]."%";
			}
			if(isset($filter[3])){
				$options['conditions']['T16InboundCallList.tel_total LIKE'] = "%".$filter[3]."%";
			}
			if(isset($filter[4])){
				$options['conditions']['DATE_FORMAT(T16InboundCallList.created, "%Y-%m-%d %k:%i") LIKE'] = "%".$filter[4]."%";
			}
			if(isset($filter[5])){
				$options['conditions']['M05User.user_name LIKE'] = "%".$filter[5]."%";
			}
		}
		return $this->find('count', $options);
	}

	function getMaxListNoByCompanyId($company_id=null) {
		$options['fields'] = array(
			'max(cast(T16InboundCallList.list_no as unsigned integer)) as max_list_no',
		);
		$options['conditions']['T16InboundCallList.company_id'] = $company_id;
		$options['conditions']['T16InboundCallList.del_flag'] = "N";

		return $this->find('first', $options);
	}

	function getListInfoById($id = null) {
		$options['fields'] = array(
				'T16InboundCallList.*',
		);
		$options['conditions'] = array(
				'T16InboundCallList.id' => $id,
				'T16InboundCallList.del_flag' => "N",
		);
		return $this->find('first', $options);
	}

	function getItemMainById($id = null) {
		$options['fields'] = array(
			'T16InboundCallList.item_main'
		);
		$options['conditions'] = array(
			'T16InboundCallList.id' => $id,
			'T16InboundCallList.del_flag' => "N",
		);
		return $this->find('first', $options);
	}
	/*--------*/
	function getByCompanyId($company_id = null, $flag_controller = null) {
		$options['fields'] = array(
			'T16InboundCallList.*',
		);

		$options['conditions'] = array(
			'T16InboundCallList.company_id' => $company_id,
			'T16InboundCallList.del_flag' => "N",
		);

		if ($flag_controller == "CallList") {
			$options['order'] = array(
				'T16InboundCallList.list_test_flag desc',
				'T16InboundCallList.created desc',
			);
		} else if ($flag_controller == "OutSchedule") {
			$options['order'] = array(
				'T16InboundCallList.created desc',
			);
		}

		return $this->find('all', $options);
	}

	function getMaxListNo() {
		$options['fields'] = array(
			'max(T16InboundCallList.list_no) as max_list_no',
		);
		return $this->find('first', $options);
	}

	function countTestCallList($company_id=null) {
		$options['fields'] = array(
			'T16InboundCallList.id',
			'T16InboundCallList.list_no',
		);

		$options['conditions'] = array(
			'T16InboundCallList.list_test_flag' => 1,
			'T16InboundCallList.del_flag' => "N",
		);

		if ($company_id) {
			$options['conditions']['T16InboundCallList.company_id'] = $company_id;
		}
		return $this->find('count', $options);
	}

	/**
	 * Get List name By List Id
	 * @param: $list_no
	 */
	function getListInfoByListNo($list_no = null) {
		$options['fields'] = array(
			'T16InboundCallList.*',
		);
		$options['conditions'] = array(
			'T16InboundCallList.list_no' => $list_no,
			'T16InboundCallList.del_flag' => "N",
		);
		return $this->find('first', $options);
	}

	function getByListName($list_name = null, $company_id = null) {
		$options['fields'] = array(
			'T16InboundCallList.*'
		);
		$options['conditions'] = array(
			'T16InboundCallList.list_name' => $list_name,
			'T16InboundCallList.del_flag' => "N",
		);
		if ($company_id) {
			$options['conditions']['T16InboundCallList.company_id'] = $company_id;
		}
		return $this->find('first', $options);
	}
}