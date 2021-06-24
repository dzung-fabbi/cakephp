<?php

class T19IncomingNgTel extends AppModel {
	var $name = 'T19IncomingNgTel';

	function getAllTelByListNgId($list_id = null) {
		$options['fields'] = array(
				'T19IncomingNgTel.*',
		);
		$options['conditions'] = array(
				'T19IncomingNgTel.list_ng_id' => $list_id,
				'T19IncomingNgTel.del_flag' => "N",
		);
		return $this->find('all', $options);
	}

	function getTelByListNgId($list_id=null, $limit=null, $page=null, $sort_order=null, $filter=null) {
		$options['fields'] = array(
			'T19IncomingNgTel.*',
		);
		if(isset($filter) && !empty($filter)){
			if(isset($filter[1])){
				$options['conditions']['T19IncomingNgTel.no LIKE'] = "%".$filter[1]."%";
			}
			if(isset($filter[2])){
				$options['conditions']['T19IncomingNgTel.tel_no LIKE'] = "%".$filter[2]."%";
			}
			if(isset($filter[3])){
				$options['conditions']['T19IncomingNgTel.memo LIKE'] = "%".$filter[3]."%";
			}
		}
		$options['conditions']['T19IncomingNgTel.list_ng_id'] = $list_id;
		$options['conditions']['T19IncomingNgTel.del_flag'] = "N";
		if(isset($sort_order) && !empty($sort_order)){
			$options['order'] = $sort_order;
		}else{
			$options['order'] = array(
				'T19IncomingNgTel.no desc'
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

	function getListByListNgIdCount($list_id=null, $filter=null) {
		$options['fields'] = array(
			'T19IncomingNgTel.*',
		);
		$options['conditions']['T19IncomingNgTel.list_ng_id'] = $list_id;
		$options['conditions']['T19IncomingNgTel.del_flag'] = "N";
		if(isset($filter) && !empty($filter)){
			if(isset($filter[1])){
				$options['conditions']['T19IncomingNgTel.no LIKE'] = "%".$filter[1]."%";
			}
			if(isset($filter[2])){
				$options['conditions']['T19IncomingNgTel.tel_no LIKE'] = "%".$filter[2]."%";
			}
			if(isset($filter[3])){
				$options['conditions']['T19IncomingNgTel.memo LIKE'] = "%".$filter[3]."%";
			}
		}
		return $this->find('count', $options);
	}

	function getTelTotalByCallListNgId($list_ng_id = null) {
		$options['fields'] = array(
			'T19IncomingNgTel.*',
		);
		$options['conditions'] = array(
			'T19IncomingNgTel.list_ng_id' => $list_ng_id,
			'T19IncomingNgTel.del_flag' => "N",
		);
		return $this->find('count', $options);
	}

	function getTelListByCallListNgId($list_ng_id) {
		$options['fields'] = array(
			'T19IncomingNgTel.tel_no',
		);
		$options['conditions'] = array(
			'T19IncomingNgTel.list_ng_id' => $list_ng_id,
			'T19IncomingNgTel.del_flag' => "N",
		);
		return $this->find('all', $options);
	}

	function getTelInfoById($id = null) {
		$options['fields'] = array(
			'T19IncomingNgTel.*',
		);
		$options['conditions'] = array(
			'T19IncomingNgTel.id' => $id,
			'T19IncomingNgTel.del_flag' => "N",
		);
		return $this->find('first', $options);
	}

	function getMaxTelNoByCallListNgId($list_ng_id = null) {
		$options['fields'] = array(
			'max(T19IncomingNgTel.no) as max_tel_no'
		);
		$options['conditions'] = array(
			'T19IncomingNgTel.list_ng_id' => $list_ng_id,
			'T19IncomingNgTel.del_flag' => "N",
		);
		return $this->find('first', $options);
	}

	function getTelNumByIds($ids = null) {
		$options['fields'] = array(
			'T19IncomingNgTel.tel_no'
		);
		$options['conditions'] = array(
			'T19IncomingNgTel.id' => $ids,
			'T19IncomingNgTel.del_flag' => 'N'
		);

		return $this->find('list', $options);
	}
}