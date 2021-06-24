<?php

class T15OutgoingNgTel extends AppModel {
	var $name = 'T15OutgoingNgTel';

	function getAllTelByCallListNgId($call_list_ng_id = null) {
		$options['fields'] = array(
				'T15OutgoingNgTel.*',
		);
		$options['conditions'] = array(
				'T15OutgoingNgTel.list_ng_id' => $call_list_ng_id,
				'T15OutgoingNgTel.del_flag' => "N",
		);
		return $this->find('all', $options);
	}

	/* 20160229 Add by Giang : #6538 - call list ng detail screen - start */
	function getTelByCallListNgId($call_list_id=null, $limit=null, $page=null, $sort_order=null, $filter=null) {
		$options['fields'] = array(
			'T15OutgoingNgTel.*',
		);
		if(isset($filter) && !empty($filter)){
			if(isset($filter[1])){
				$options['conditions']['T15OutgoingNgTel.no LIKE'] = "%".$filter[1]."%";
			}
			if(isset($filter[2])){
				$options['conditions']['T15OutgoingNgTel.tel_no LIKE'] = "%".$filter[2]."%";
			}
			if(isset($filter[3])){
				$options['conditions']['T15OutgoingNgTel.memo LIKE'] = "%".$filter[3]."%";
			}
		}
		$options['conditions']['T15OutgoingNgTel.list_ng_id'] = $call_list_id;
		$options['conditions']['T15OutgoingNgTel.del_flag'] = "N";
		if(isset($sort_order) && !empty($sort_order)){
			$options['order'] = $sort_order;
		}else{
			$options['order'] = array(
				'T15OutgoingNgTel.no desc'
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

	function getListByCallListNgIdCount($call_list_id=null, $filter=null) {
		$options['fields'] = array(
			'T15OutgoingNgTel.*',
		);
		$options['conditions']['T15OutgoingNgTel.list_ng_id'] = $call_list_id;
		$options['conditions']['T15OutgoingNgTel.del_flag'] = "N";
		if(isset($filter) && !empty($filter)){
			if(isset($filter[1])){
				$options['conditions']['T15OutgoingNgTel.no LIKE'] = "%".$filter[1]."%";
			}
			if(isset($filter[2])){
				$options['conditions']['T15OutgoingNgTel.tel_no LIKE'] = "%".$filter[2]."%";
			}
			if(isset($filter[3])){
				$options['conditions']['T15OutgoingNgTel.memo LIKE'] = "%".$filter[3]."%";
			}
		}
		return $this->find('count', $options);
	}

	function getTelInfoById($id = null) {
		$options['fields'] = array(
			'T15OutgoingNgTel.*',
		);
		$options['conditions'] = array(
			'T15OutgoingNgTel.id' => $id,
			'T15OutgoingNgTel.del_flag' => "N",
		);
		return $this->find('first', $options);
	}

	function getMaxTelNoByCallListNgId($list_ng_id = null) {
		$options['fields'] = array(
			'max(T15OutgoingNgTel.no) as max_tel_no'
		);
		$options['conditions'] = array(
			'T15OutgoingNgTel.list_ng_id' => $list_ng_id,
			'T15OutgoingNgTel.del_flag' => "N",
		);
		return $this->find('first', $options);
	}

	function getTelTotalByCallListNgId($list_ng_id = null) {
		$options['fields'] = array(
			'T15OutgoingNgTel.*',
		);
		$options['conditions'] = array(
			'T15OutgoingNgTel.list_ng_id' => $list_ng_id,
			'T15OutgoingNgTel.del_flag' => "N",
		);
		return $this->find('count', $options);
	}
	function getTelListByCallListNgId($list_ng_id) {
		$options['fields'] = array(
			'T15OutgoingNgTel.tel_no',
		);
		$options['conditions'] = array(
			'T15OutgoingNgTel.list_ng_id' => $list_ng_id,
			'T15OutgoingNgTel.del_flag' => "N",
		);
		return $this->find('all', $options);
	}
	/* 20160229 Add by Giang : #6538 - call list ng detail screen - end */
}