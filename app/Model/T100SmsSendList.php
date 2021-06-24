<?php

/** This class is copied from T10CallList class.
 * This class will define method to get, insert, update or delete data in t100_sms_send_lists table.
 * t100_sms_send_lists table of column: 
 * - id
 * - company_id
 * - list_no
 * - list_name
 * - list_test_flag
 * - tel_total
 * - del_flag
 * - created
 * - entry_user
 * - entry_program
 * - modified
 * - update_user
 * - update_program
 * 
 * @author	: Hungnv
 * @version	: 1.0
 * @since	:created	: 2016/04/20
 * @since	:modified	: 2016/04/20
 * 
 */
class T100SmsSendList extends AppModel {
	
	/**
	 * @var Alias of t100_sms_send_lists table
	 */
	var $name = 'T100SmsSendList';

	/** Get all sms send list by company_id from T100SmsSendList
	 * @param string $company_id		is company id. Default is NULL
	 * @param string $flag_controller	is controller name where this method wil be called. Default is NULL
	 * @return array T100SmsSendList records or NULL if no record be found. Order by test list flag and created date
	 * @since	: Created: 2016/04/20
	 * @since	: Modified: 2016/04/20
	 * @author	: Hungnv
	 */
	function getByCompanyId($company_id = null, $flag_controller = null) {
		$options['fields'] = array(
			'T100SmsSendList.*',
		);

		$options['conditions'] = array(
			'T100SmsSendList.company_id' => $company_id,
			'T100SmsSendList.del_flag' => "N",
		);

		if ($flag_controller == "SmsSendList") {
			$options['order'] = array(
				'T100SmsSendList.list_test_flag desc',
				'T100SmsSendList.created desc',
			);
		} else if ($flag_controller == "SmsSchedule") {
			$options['order'] = array(
				'T100SmsSendList.created desc',
			);
		}

		return $this->find('all', $options);
	}

	/** Get all sms send list by company_id, page limit, page number, filter
	 * @param string $company_id		is company id
	 * @param string $limit	is item's limit/page. Default value is NULL
	 * @param int $page	is page number. Default value is NULL
	 * @param string $sort_order	is sort order. Default value is NULL
	 * @param array $filter	is array of filter value. Default value is NULL. 
	 * 				$filter[1] : T100.list_no.
	 * 				$filter[2] : T100.list_name.
	 * 				$filter[3] : T100.tel_total.
	 * 				$filter[4] : T100.created.
	 * 				$filter[5] : M05.user_name.
	 * @return array or NULL if no record be found
	 * @since	: Created: 2016/04/20
	 * @since	: Modified: 2016/04/20
	 * @author	: Hungnv
	 */
	function getListByCompanyId($company_id, $limit=null, $page=null, $sort_order=null, $filter=null) {
		$options['fields'] = array(
			'T100SmsSendList.*',
			'M05User.user_name',
		);

		$options['joins'] = array(
			array(
				'table' => 'm05_users',
				'alias' => 'M05User',
				'fields' => array('user_name'),
				'type' => 'left', //20160224 Add by Giang : #6531 - show list create by the user deleted
				'conditions' => array(
					'T100SmsSendList.entry_user = M05User.user_id',
				),
			),
		);

		if(isset($filter) && !empty($filter)){
			if(isset($filter[1])){ // list_no of value
				$options['conditions']['T100SmsSendList.list_no LIKE'] = "%".$filter[1]."%";
			}
			if(isset($filter[2])){ // list_name of value
				$options['conditions']['T100SmsSendList.list_name LIKE'] = "%".$filter[2]."%";
			}
			if(isset($filter[3])){ // tel_total of value
				$options['conditions']['T100SmsSendList.tel_total LIKE'] = "%".$filter[3]."%";
			}
			if(isset($filter[4])){ // created of value
				$options['conditions']['DATE_FORMAT(T100SmsSendList.created, "%Y-%m-%d %k:%i") LIKE'] = "%".$filter[4]."%";
			}
			if(isset($filter[5])){ // user_name of value
				$options['conditions']['M05User.user_name LIKE'] = "%".$filter[5]."%";
			}
		}
		$options['conditions']['T100SmsSendList.company_id'] = $company_id;
		$options['conditions']['T100SmsSendList.del_flag'] = "N";
		if(isset($sort_order) && !empty($sort_order)){
			$options['order'] = $sort_order;
		}else{
			$options['order'] = array(
				'T100SmsSendList.list_test_flag desc',
				'T100SmsSendList.created desc',
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
	
	/** Count sms send list by company_id, filter
	 * @param string $company_id		is company id
	 * @param array $filter	is array of filter value. Default value is NULL.
	 * 				$filter[1] : T100.list_no.
	 * 				$filter[2] : T100.list_name.
	 * 				$filter[3] : T100.tel_total.
	 * 				$filter[4] : T100.created.
	 * 				$filter[5] : M05.user_name.
	 * @return possitive number or 0 if no record be found
	 * @since	: Created: 2016/04/20
	 * @since	: Modified: 2016/04/20
	 * @author	: Hungnv
	 */
	function getListByCompanyIdCount($company_id, $filter=null) {
		$options['fields'] = array(
			'T100SmsSendList.*',
			'M05User.user_name',
		);

		$options['joins'] = array(
			array(
				'table' => 'm05_users',
				'alias' => 'M05User',
				'type' => 'left', //20160224 Add by Giang : #6531 - show list create by the user deleted
				'conditions' => array(
					'T100SmsSendList.entry_user = M05User.user_id',
				),
			),
		);

		$options['conditions']['T100SmsSendList.company_id'] = $company_id;
		$options['conditions']['T100SmsSendList.del_flag'] = "N";
		if(isset($filter) && !empty($filter)){
			if(isset($filter[1])){
				$options['conditions']['T100SmsSendList.list_no LIKE'] = "%".$filter[1]."%";
			}
			if(isset($filter[2])){
				$options['conditions']['T100SmsSendList.list_name LIKE'] = "%".$filter[2]."%";
			}
			if(isset($filter[3])){
				$options['conditions']['T100SmsSendList.tel_total LIKE'] = "%".$filter[3]."%";
			}
			if(isset($filter[4])){
				$options['conditions']['DATE_FORMAT(T100SmsSendList.created, "%Y-%m-%d %k:%i") LIKE'] = "%".$filter[4]."%";
			}
			if(isset($filter[5])){
				$options['conditions']['M05User.user_name LIKE'] = "%".$filter[5]."%";
			}
		}
		return $this->find('count', $options);
	}
	
	/** Get max list_no of sms send list
	 * @return array contain max list_no of T100
	 * @since	: Created: 2016/04/20
	 * @since	: Modified: 2016/04/20
	 * @author	: Hungnv
	 */
	function getMaxListNo() {
		$options['fields'] = array(
			'max(T100SmsSendList.list_no) as max_list_no',
		);
		return $this->find('first', $options);
	}
	
	/** Get max list_no of sms send list by company_id
	 * @return array contain max list_no of T100
	 * @since	: Created: 2016/04/20
	 * @since	: Modified: 2016/04/20
	 * @author	: Hungnv
	 */
	function getMaxListNoByCompanyId($company_id=null) {
		$options['fields'] = array(
			'max(cast(T100SmsSendList.list_no as unsigned integer)) as max_list_no',
		);
		$options['conditions']['T100SmsSendList.company_id'] = $company_id;

		return $this->find('first', $options);
	}
	
	/** Count sms_send test list by company_id
	 * @param	: $company_id is company id. Default value is NULL
	 * @return possitive number or 0 if no record be found
	 * @since	: Created: 2016/04/20
	 * @since	: Modified: 2016/04/20
	 * @author	: Hungnv
	 */
	function countTestCallList($company_id=null) {
		$options['fields'] = array(
			'T100SmsSendList.id',
			'T100SmsSendList.list_no',
		);

		$options['conditions'] = array(
			'T100SmsSendList.list_test_flag' => 1,
			'T100SmsSendList.del_flag' => "N",
		);

		if ($company_id) {
			$options['conditions']['T100SmsSendList.company_id'] = $company_id;
		}
		return $this->find('count', $options);
	}

	/**
	 * Get List Info By List Id
	 * @param	: $list_no is list id. Default value is NULL.
	 * @return	: array or NULL if no record be found
	 * @since	: Created: 2016/04/20
	 * @since	: Modified: 2016/04/20
	 * @author	: Hungnv
	 */
	function getListInfoByListNo($list_no = null) {
		$options['fields'] = array(
			'T100SmsSendList.*',
		);
		$options['conditions'] = array(
			'T100SmsSendList.list_no' => $list_no,
			'T100SmsSendList.del_flag' => "N",
		);
		return $this->find('first', $options);
	}
	/**
	 * Get List Info By Id
	 * @param	: $id is id. Default value is NULL.
	 * @return	: array or NULL if no record be found
	 * @since	: Created: 2016/04/20
	 * @since	: Modified: 2016/04/20
	 * @author	: Hungnv
	 */
	function getListInfoById($id = null) {
		$options['fields'] = array(
				'T100SmsSendList.*',
		);
		$options['conditions'] = array(
				'T100SmsSendList.id' => $id,
				'T100SmsSendList.del_flag' => "N",
		);
		return $this->find('first', $options);
	}
	/**
	 * Get List Info By list name and company id
	 * @param	: $list_name is list name. Default value is NULL.
	 * @param	: $company_id is company id. Default value is NULL.
	 * @return	: array or NULL if no record be found
	 * @since	: Created: 2016/04/20
	 * @since	: Modified: 2016/04/20
	 * @author	: Hungnv
	 */
	function getByListName($list_name = null, $company_id = null) {
		$options['fields'] = array(
			'T100SmsSendList.*'
		);
		$options['conditions'] = array(
			'T100SmsSendList.list_name' => $list_name,
			'T100SmsSendList.del_flag' => "N",
		);
		if ($company_id) {
			$options['conditions']['T100SmsSendList.company_id'] = $company_id;
		}
		return $this->find('first', $options);
	}
}