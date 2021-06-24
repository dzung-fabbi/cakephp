<?php

/**
 * T11TelList model.
 */
class T11TelList extends AppModel {
	var $name = 'T11TelList';

	function getTelByCallListId($call_list_id=null, $limit=null, $page=null, $sort_order=null, $filter=null, $t12_list_items=null) {
		$options['fields'] = array(
			'T11TelList.*',
		);
		if(isset($filter) && !empty($filter)){
			if(isset($filter[1])){
				$options['conditions']['T11TelList.tel_no LIKE'] = "%".$filter[1]."%";
			}
			foreach ($t12_list_items as $key => $value) {
				$col = $key + 2;
				if(isset($filter[$col])){
					$options['conditions']['T11TelList.'.$value['T12ListItem']['column'].' LIKE'] = "%".$filter[$col]."%";
				}
			}
		}
		$options['conditions']['T11TelList.list_id'] = $call_list_id;
		$options['conditions']['T11TelList.del_flag'] = "N";
		if(isset($sort_order) && !empty($sort_order)){
			$options['order'] = $sort_order;
		}else{
			$options['order'] = array(
				'T11TelList.tel_no desc'
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

	function getListByCallListIdCount($call_list_id=null, $filter=null, $t12_list_items=null) {
		$options['fields'] = array(
			'T11TelList.*',
		);
		$options['conditions']['T11TelList.list_id'] = $call_list_id;
		$options['conditions']['T11TelList.del_flag'] = "N";
		if(isset($filter) && !empty($filter)){
			if(isset($filter[1])){
				$options['conditions']['T11TelList.tel_no LIKE'] = "%".$filter[1]."%";
			}
			foreach ($t12_list_items as $key => $value) {
				$col = $key + 2;
				if(isset($filter[$col])){
					$options['conditions']['T11TelList.'.$value['T12ListItem']['column'].' LIKE'] = "%".$filter[$col]."%";
				}
			}
		}
		return $this->find('count', $options);
	}

	function getByTelNoAndCallListId($tel_number = null, $tel_number_col = null, $call_list_id = null) {
		$options['fields'] = array(
			'T11TelList.*'
		);
		$options['conditions'] = array(
			"T11TelList.$tel_number_col" => $tel_number,
			'T11TelList.list_id' => $call_list_id,
			'T11TelList.del_flag' => "N",
		);
		return $this->find('first', $options);
	}

	function getMaxTelNoByCallListId($call_list_id = null) {
		$options['fields'] = array(
			'max(T11TelList.tel_no) as max_tel_no'
		);
		$options['conditions'] = array(
			'T11TelList.list_id' => $call_list_id,
			'T11TelList.del_flag' => "N",
		);
		return $this->find('first', $options);
	}

	function getAllTelByCallListId($call_list_id = null) {
		$options['fields'] = array(
				'T11TelList.*',
		);
		$options['conditions'] = array(
				'T11TelList.list_id' => $call_list_id,
				'T11TelList.del_flag' => "N",
		);
		return $this->find('all', $options);
	}

	function getTelInfoById($id = null) {
		$options['fields'] = array(
			'T11TelList.*',
		);
		$options['conditions'] = array(
			'T11TelList.id' => $id,
			'T11TelList.del_flag' => "N",
		);
		return $this->find('first', $options);
	}

	function getTelTotalByListId($list_id=null, $tel_num_col=null, $tel_ng_arr=null) {
		$options['conditions'] = array(
			'T11TelList.del_flag' => 'N',
			'T11TelList.muko_flag' => 'N',
			'T11TelList.list_id' => $list_id
		);
		if ($tel_num_col && $tel_ng_arr) {
			$options['conditions']['NOT'] = array(
				"T11TelList.$tel_num_col" => $tel_ng_arr
			);
		}

		return $this->find('count', $options);
	}

	function getTelByListIdsCount($call_list_ids=array()) {
		$options['fields'] = array(
			'T11TelList.*',
		);
		$options['conditions']['T11TelList.list_id'] = $call_list_ids;
		$options['conditions']['T11TelList.del_flag'] = "N";
		return $this->find('count', $options);
	}

	function getTelYukoByListIdArrTel($list_id, $arr_tel, $tel_column) {
		$options['fields'] = array(
			'T11TelList.*',
		);
		$options['conditions']['T11TelList.list_id'] = $list_id;
		$options['conditions']['T11TelList.'.$tel_column] = $arr_tel;
		$options['conditions']['T11TelList.muko_flag'] = "N";
		$options['conditions']['T11TelList.del_flag'] = "N";
		return $this->find('all', $options);
	}
	
	function getAllByListId($list_id=null, $tel_num_col=null, $tel_ng_arr=null) {
		$options['fields'] = array(
			'T11TelList.*',
		);
		$options['conditions'] = array(
			'T11TelList.del_flag' => 'N',
			/*'T11TelList.muko_flag' => 'N',*/
			'T11TelList.list_id' => $list_id
		);
		if ($tel_num_col && $tel_ng_arr) {
			$options['conditions']['NOT'] = array(
				"T11TelList.$tel_num_col" => $tel_ng_arr
			);
		}
		return $this->find('all', $options);
	}
}