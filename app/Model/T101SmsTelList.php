<?php

/**
 * T101SmsTelList model.
 */
class T101SmsTelList extends AppModel {
	var $name = 'T101SmsTelList';

	function getTelByListId($list_id=null, $limit=null, $page=null, $sort_order=null, $filter=null, $list_items=null) {
		$options['fields'] = array(
			'T101SmsTelList.*',
		);
		if(isset($filter) && !empty($filter)){
			if(isset($filter[1])){
				$options['conditions']['T101SmsTelList.tel_no LIKE'] = "%".$filter[1]."%";
			}
			foreach ($list_items as $key => $value) {
				$col = $key + 2;
				if(isset($filter[$col])){
					if ($value['T102SmsListItem']['item_code'] == 'birthday') {
						$options['conditions']['REPLACE(REPLACE(REPLACE(T101SmsTelList.' . $value['T102SmsListItem']['column'] . ',"年",""),"月",""),"日","") LIKE'] = "%" . $filter[$col] . "%";
					} else if($value['T102SmsListItem']['item_code'] == 'consentday') { // #8298 add consentday
						$options['conditions']['REPLACE(REPLACE(REPLACE(T101SmsTelList.' . $value['T102SmsListItem']['column'] . ',"年",""),"月",""),"日","") LIKE'] = "%" . $filter[$col] . "%";
					} else {
						$options['conditions']['T101SmsTelList.' . $value['T102SmsListItem']['column'] . ' LIKE'] = "%" . $filter[$col] . "%";
					}
				}
			}
		}
		$options['conditions']['T101SmsTelList.list_id'] = $list_id;
		$options['conditions']['T101SmsTelList.del_flag'] = "N";
		if(isset($sort_order) && !empty($sort_order)){
			$options['order'] = $sort_order;
		}else{
			$options['order'] = array(
				'T101SmsTelList.tel_no desc'
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

	function getListByListIdCount($list_id=null, $filter=null, $list_items=null) {
		$options['fields'] = array(
			'T101SmsTelList.*',
		);
		$options['conditions']['T101SmsTelList.list_id'] = $list_id;
		$options['conditions']['T101SmsTelList.del_flag'] = "N";
		if(isset($filter) && !empty($filter)){
			if(isset($filter[1])){
				$options['conditions']['T101SmsTelList.tel_no LIKE'] = "%".$filter[1]."%";
			}
			foreach ($list_items as $key => $value) {
				$col = $key + 2;
				if(isset($filter[$col])){
					if ($value['T102SmsListItem']['item_code'] == 'birthday') {
						$options['conditions']['REPLACE(REPLACE(REPLACE(T101SmsTelList.' . $value['T102SmsListItem']['column'] . ',"年",""),"月",""),"日","") LIKE'] = "%" . $filter[$col] . "%";
					} else if($value['T102SmsListItem']['item_code'] == 'consentday') { // #8298 add consentday
						$options['conditions']['REPLACE(REPLACE(REPLACE(T101SmsTelList.' . $value['T102SmsListItem']['column'] . ',"年",""),"月",""),"日","") LIKE'] = "%" . $filter[$col] . "%";
					} else {
						$options['conditions']['T101SmsTelList.' . $value['T102SmsListItem']['column'] . ' LIKE'] = "%" . $filter[$col] . "%";
					}
				}
			}
		}
		return $this->find('count', $options);
	}

	function getByTelNoAndListId($tel_number = null, $tel_number_col = null, $list_id = null) {
		$options['fields'] = array(
			'T101SmsTelList.*'
		);
		$options['conditions'] = array(
			"T101SmsTelList.$tel_number_col" => $tel_number,
			'T101SmsTelList.list_id' => $list_id,
			'T101SmsTelList.del_flag' => "N",
		);
		return $this->find('first', $options);
	}

	function getMaxTelNoByListId($list_id = null) {
		$options['fields'] = array(
			'max(T101SmsTelList.tel_no) as max_tel_no'
		);
		$options['conditions'] = array(
			'T101SmsTelList.list_id' => $list_id,
			'T101SmsTelList.del_flag' => "N",
		);
		return $this->find('first', $options);
	}

	/** Get all tel number by list_id from T101SmsTelList
	 * @param string $list_id		is list id. Default is NULL	 
	 * @return array all of records be found or NULL if no record be found.
	 * @since	: Created: 2016/04/22
	 * @since	: Modified: 2016/04/22
	 * @author	: Hungnv
	 */
	function getAllTelByListId($list_id = null) {
		$options['fields'] = array(
				'T101SmsTelList.*',
		);
		$options['conditions'] = array(
				'T101SmsTelList.list_id' => $list_id,
				'T101SmsTelList.del_flag' => "N",
		);
		return $this->find('all', $options);
	}

	function getTelInfoById($id = null) {
		$options['fields'] = array(
			'T101SmsTelList.*',
		);
		$options['conditions'] = array(
			'T101SmsTelList.id' => $id,
			'T101SmsTelList.del_flag' => "N",
		);
		return $this->find('first', $options);
	}

	function getTelTotalByListId($list_id=null, $tel_num_col=null, $tel_ng_arr=null) {
		$options['conditions'] = array(
			'T101SmsTelList.del_flag' => 'N',
			'T101SmsTelList.muko_flag' => 'N',
			'T101SmsTelList.list_id' => $list_id
		);
		if ($tel_num_col && $tel_ng_arr) {
			$options['conditions']['NOT'] = array(
				"T101SmsTelList.$tel_num_col" => $tel_ng_arr
			);
		}

		return $this->find('count', $options);
	}

	/** Count all the tel number in array list_ids
	 * @param $list_ids is array list id
	 * @return Number of records be found or 0 if no record be found
	 * @since	: Created: 2016/04/22
	 * @since	: Modified: 2016/04/22
	 * @author	: Hungnv
	 */
	function getTelByListIdsCount($list_ids=array()) {
		$options['fields'] = array(
			'T101SmsTelList.*',
		);
		$options['conditions']['T101SmsTelList.list_id'] = $list_ids;
		$options['conditions']['T101SmsTelList.del_flag'] = "N";
		return $this->find('count', $options);
	}

	function getTelYukoByListIdArrTel($list_id, $arr_tel, $tel_column) {
		$options['fields'] = array(
			'T101SmsTelList.*',
		);
		$options['conditions']['T101SmsTelList.list_id'] = $list_id;
		$options['conditions']['T101SmsTelList.'.$tel_column] = $arr_tel;
		$options['conditions']['T101SmsTelList.muko_flag'] = "N";
		$options['conditions']['T101SmsTelList.del_flag'] = "N";
		return $this->find('all', $options);
	}

	function getCountMukoTelByListId($list_id=null) {
		$options['conditions'] = array(
			'T101SmsTelList.muko_flag' => 'N',
			'T101SmsTelList.list_id' => $list_id,
			'T101SmsTelList.del_flag' => 'N',
		);

		return $this->find('count', $options);
	}

	// #8298 add consentday
	function getConsentday($list_id=null){
		$options['conditions'] = array(
			'T101SmsTelList.consentday' => null,
			'T101SmsTelList.list_id' => $list_id,
			'T101SmsTelList.del_flag' => 'N',
		);
    	return $this->find('count', $options);
	}

}