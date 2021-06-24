<?php

class T17InboundTelList extends AppModel {
	var $name = 'T17InboundTelList';

	function getTelByCallListId($call_list_id=null, $limit=null, $page=null, $sort_order=null, $filter=null, $t13_list_items=null) {
		$options['fields'] = array(
			'T17InboundTelList.*',
		);
		if(isset($filter) && !empty($filter)){
			if(isset($filter[1])){
				$options['conditions']['T17InboundTelList.tel_no LIKE'] = "%".$filter[1]."%";
			}
			foreach ($t13_list_items as $key => $value) {
				$col = $key + 2;
				if(isset($filter[$col])){
					$options['conditions']['T17InboundTelList.'.$value['T13InboundListItem']['column'].' LIKE'] = "%".$filter[$col]."%";
				}
			}
		}
		$options['conditions']['T17InboundTelList.list_id'] = $call_list_id;
		$options['conditions']['T17InboundTelList.del_flag'] = "N";
		if(isset($sort_order) && !empty($sort_order)){
			$options['order'] = $sort_order;
		}else{
			$options['order'] = array(
				'T17InboundTelList.tel_no desc'
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

	function getListByCallListIdCount($call_list_id=null, $filter=null, $t13_list_items=null) {
		$options['fields'] = array(
			'T17InboundTelList.*',
		);
		$options['conditions']['T17InboundTelList.list_id'] = $call_list_id;
		$options['conditions']['T17InboundTelList.del_flag'] = "N";
		if(isset($filter) && !empty($filter)){
			if(isset($filter[1])){
				$options['conditions']['T17InboundTelList.tel_no LIKE'] = "%".$filter[1]."%";
			}
			foreach ($t13_list_items as $key => $value) {
				$col = $key + 2;
				if(isset($filter[$col])){
					$options['conditions']['T17InboundTelList.'.$value['T13InboundListItem']['column'].' LIKE'] = "%".$filter[$col]."%";
				}
			}
		}
		return $this->find('count', $options);
	}

	function getTelInfoById($id = null) {
		$options['fields'] = array(
			'T17InboundTelList.*',
		);
		$options['conditions'] = array(
			'T17InboundTelList.id' => $id,
			'T17InboundTelList.del_flag' => "N",
		);
		return $this->find('first', $options);
	}

	function getByTelNoAndCallListId($tel_number = null, $tel_number_col = null, $call_list_id = null) {
		$options['fields'] = array(
			'T17InboundTelList.*'
		);
		$options['conditions'] = array(
			"T17InboundTelList.$tel_number_col" => $tel_number,
			'T17InboundTelList.list_id' => $call_list_id,
			'T17InboundTelList.del_flag' => "N",
		);
		return $this->find('first', $options);
	}

	function getMaxTelNoByCallListId($call_list_id = null) {
		$options['fields'] = array(
			'max(T17InboundTelList.tel_no) as max_tel_no'
		);
		$options['conditions'] = array(
			'T17InboundTelList.list_id' => $call_list_id,
			'T17InboundTelList.del_flag' => "N",
		);
		return $this->find('first', $options);
	}

	function getTelByListIdsCount($call_list_ids=array()) {
		$options['fields'] = array(
			'T17InboundTelList.*',
		);
		$options['conditions']['T17InboundTelList.list_id'] = $call_list_ids;
		$options['conditions']['T17InboundTelList.del_flag'] = "N";
		return $this->find('count', $options);
	}

	function getAllTelByCallListId($call_list_id = null) {
		$options['fields'] = array(
				'T17InboundTelList.*',
		);
		$options['conditions'] = array(
				'T17InboundTelList.list_id' => $call_list_id,
				'T17InboundTelList.del_flag' => "N",
		);
		return $this->find('all', $options);
	}


	function getTelTotalByListId($list_id=null, $tel_num_col=null, $tel_ng_arr=null) {
		$options['conditions'] = array(
			'T17InboundTelList.del_flag' => 'N',
			'T17InboundTelList.muko_flag' => 'N',
			'T17InboundTelList.list_id' => $list_id
		);
		if ($tel_num_col && $tel_ng_arr) {
			$options['conditions']['NOT'] = array(
				"T17InboundTelList.$tel_num_col" => $tel_ng_arr
			);
		}

		return $this->find('count', $options);
	}

	function getTelYukoByListIdArrTel($list_id, $arr_tel, $tel_column) {
		$options['fields'] = array(
			'T17InboundTelList.*',
		);
		$options['conditions']['T17InboundTelList.list_id'] = $list_id;
		$options['conditions']['T17InboundTelList.'.$tel_column] = $arr_tel;
		$options['conditions']['T17InboundTelList.muko_flag'] = "N";
		$options['conditions']['T17InboundTelList.del_flag'] = "N";
		return $this->find('all', $options);
	}

	function getAllByListId($list_id=null, $tel_num_col=null, $tel_ng_arr=null) {
		$options['fields'] = array(
				'T17InboundTelList.*',
		);
		$options['conditions'] = array(
			'T17InboundTelList.del_flag' => 'N',
			'T17InboundTelList.list_id' => $list_id
		);
		if ($tel_num_col && $tel_ng_arr) {
			$options['conditions']['NOT'] = array(
				"T17InboundTelList.$tel_num_col" => $tel_ng_arr
			);
		}

		return $this->find('all', $options);
	}

	// 20160404 Add by Giang - #6740: check item main unique - Begin
	function getDataItemMainByIdAndItemMain($list_id, $item_main_col) {
		$options['fields'] = array(
			"T17InboundTelList.$item_main_col",
		);
		$options['conditions']['T17InboundTelList.list_id'] = $list_id;
		$options['conditions']['T17InboundTelList.del_flag'] = "N";
		return $this->find('list', $options);
	}

	function getTelByIdAndItemMain($list_id, $item_main_col, $item_main_val) {
		$options['fields'] = array(
			"T17InboundTelList.*", // 20160406 Edit by Giang - #6740: check item main unique - End
		);
		$options['conditions']['T17InboundTelList.list_id'] = $list_id;
		$options['conditions']["T17InboundTelList.$item_main_col"] = $item_main_val;
		$options['conditions']['T17InboundTelList.del_flag'] = "N";
		return $this->find('first', $options);
	}
	// 20160404 Add by Giang - #6740: check item main unique - End
}