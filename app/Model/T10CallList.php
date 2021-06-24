<?php

/**
 * Created by PhpStorm.
 * User: PTT
 * Date: 8/10/2015
 * Time: 2:09 PM
 */
class T10CallList extends AppModel {
	var $name = 'T10CallList';

	function getByCompanyId($company_id = null, $flag_controller = null) {
		$options['fields'] = array(
			'T10CallList.*',
		);

		$options['conditions'] = array(
			'T10CallList.company_id' => $company_id,
			'T10CallList.del_flag' => "N",
		);

		if ($flag_controller == "CallList") {
			$options['order'] = array(
				'T10CallList.list_test_flag desc',
				'T10CallList.created desc',
			);
		} else if ($flag_controller == "OutSchedule") {
			$options['order'] = array(
				'T10CallList.created desc',
			);
		}

		return $this->find('all', $options);
	}

	function getListByCompanyId($company_id, $limit=null, $page=null, $sort_order=null, $filter=null) {
		$options['fields'] = array(
			'T10CallList.*',
			'M05User.user_name',
		);

		$options['joins'] = array(
			array(
				'table' => 'm05_users',
				'alias' => 'M05User',
				'fields' => array('user_name'),
				'type' => 'left', //20160224 Add by Giang : #6531 - show list create by the user deleted
				'conditions' => array(
					'T10CallList.entry_user = M05User.user_id',
				),
			),
		);

		if(isset($filter) && !empty($filter)){
			if(isset($filter[1])){
				$options['conditions']['T10CallList.list_no LIKE'] = "%".$filter[1]."%";
			}
			if(isset($filter[2])){
				$options['conditions']['T10CallList.list_name LIKE'] = "%".$filter[2]."%";
			}
			if(isset($filter[3])){
				$options['conditions']['T10CallList.tel_total LIKE'] = "%".$filter[3]."%";
			}
			if(isset($filter[4])){
				$options['conditions']['DATE_FORMAT(T10CallList.created, "%Y-%m-%d %k:%i") LIKE'] = "%".$filter[4]."%";
			}
			if(isset($filter[5])){
				$options['conditions']['M05User.user_name LIKE'] = "%".$filter[5]."%";
			}
		}
		$options['conditions']['T10CallList.company_id'] = $company_id;
		$options['conditions']['T10CallList.del_flag'] = "N";
		if(isset($sort_order) && !empty($sort_order)){
			$options['order'] = $sort_order;
		}else{
			$options['order'] = array(
				'T10CallList.list_test_flag desc',
				'T10CallList.created desc',
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
			'T10CallList.*',
			'M05User.user_name',
		);

		$options['joins'] = array(
			array(
				'table' => 'm05_users',
				'alias' => 'M05User',
				'type' => 'left', //20160224 Add by Giang : #6531 - show list create by the user deleted
				'conditions' => array(
					'T10CallList.entry_user = M05User.user_id',
				),
			),
		);

		$options['conditions']['T10CallList.company_id'] = $company_id;
		$options['conditions']['T10CallList.del_flag'] = "N";
		if(isset($filter) && !empty($filter)){
			if(isset($filter[1])){
				$options['conditions']['T10CallList.list_no LIKE'] = "%".$filter[1]."%";
			}
			if(isset($filter[2])){
				$options['conditions']['T10CallList.list_name LIKE'] = "%".$filter[2]."%";
			}
			if(isset($filter[3])){
				$options['conditions']['T10CallList.tel_total LIKE'] = "%".$filter[3]."%";
			}
			if(isset($filter[4])){
				$options['conditions']['DATE_FORMAT(T10CallList.created, "%Y-%m-%d %k:%i") LIKE'] = "%".$filter[4]."%";
			}
			if(isset($filter[5])){
				$options['conditions']['M05User.user_name LIKE'] = "%".$filter[5]."%";
			}
		}
		return $this->find('count', $options);
	}

	function getMaxListNo() {
		$options['fields'] = array(
			'max(T10CallList.list_no) as max_list_no',
		);
		return $this->find('first', $options);
	}

	function getMaxListNoByCompanyId($company_id=null) {
		$options['fields'] = array(
			'max(cast(T10CallList.list_no as unsigned integer)) as max_list_no',
		);
		$options['conditions']['T10CallList.company_id'] = $company_id;

		return $this->find('first', $options);
	}

	function countTestCallList($company_id=null) {
		$options['fields'] = array(
			'T10CallList.id',
			'T10CallList.list_no',
		);

		$options['conditions'] = array(
			'T10CallList.list_test_flag' => 1,
			'T10CallList.del_flag' => "N",
		);

		if ($company_id) {
			$options['conditions']['T10CallList.company_id'] = $company_id;
		}
		return $this->find('count', $options);
	}

	/**
	 * Get List name By List Id
	 * @param: $list_no
	 */
	function getListInfoByListNo($list_no = null) {
		$options['fields'] = array(
			'T10CallList.*',
		);
		$options['conditions'] = array(
			'T10CallList.list_no' => $list_no,
			'T10CallList.del_flag' => "N",
		);
		return $this->find('first', $options);
	}
	/**
	 * Get List name By Id
	 * @param: $id
	 */
	function getListInfoById($id = null) {
		$options['fields'] = array(
				'T10CallList.*',
		);
		$options['conditions'] = array(
				'T10CallList.id' => $id,
				'T10CallList.del_flag' => "N",
		);
		return $this->find('first', $options);
	}
	/**
	 * Get List name By List Name
	 * @param: $list_name
	 */
	function getByListName($list_name = null, $company_id = null) {
		$options['fields'] = array(
			'T10CallList.*'
		);
		$options['conditions'] = array(
			'T10CallList.list_name' => $list_name,
			'T10CallList.del_flag' => "N",
		);
		if ($company_id) {
			$options['conditions']['T10CallList.company_id'] = $company_id;
		}
		return $this->find('first', $options);
	}
}