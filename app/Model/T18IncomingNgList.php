<?php

class T18IncomingNgList extends AppModel {
	var $name = 'T18IncomingNgList';

	function getListNgByCompanyId($company_id, $limit=null, $page=null, $sort_order=null, $filter=null) {
		$options['fields'] = array(
			'T18IncomingNgList.*',
			'M05User.user_name',
		);

		$options['joins'] = array(
			array(
				'table' => 'm05_users',
				'alias' => 'M05User',
				'fields' => array('user_name'),
				'type' => 'left',
				'conditions' => array(
					'T18IncomingNgList.entry_user = M05User.user_id',
				),
			),
		);

		if(isset($filter) && !empty($filter)){
			if(isset($filter[1])){
				$options['conditions']['T18IncomingNgList.list_ng_no LIKE'] = "%".$filter[1]."%";
			}
			if(isset($filter[2])){
				$options['conditions']['T18IncomingNgList.list_name LIKE'] = "%".$filter[2]."%";
			}
			if(isset($filter[3])){
				$options['conditions']['T18IncomingNgList.total LIKE'] = "%".$filter[3]."%";
			}
			if(isset($filter[4])){
				$options['conditions']['DATE_FORMAT(T18IncomingNgList.created, "%Y-%m-%d %k:%i") LIKE'] = "%".$filter[4]."%";
			}
			if(isset($filter[5])){
				$options['conditions']['M05User.user_name LIKE'] = "%".$filter[5]."%";
			}
		}
		$options['conditions']['T18IncomingNgList.company_id'] = $company_id;
		$options['conditions']['T18IncomingNgList.del_flag'] = "N";
		if(isset($sort_order) && !empty($sort_order)){
			$options['order'] = $sort_order;
		}else{
			$options['order'] = array(
				'T18IncomingNgList.list_ng_no desc',
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
			'T18IncomingNgList.*',
			'M05User.user_name',
		);

		$options['joins'] = array(
			array(
				'table' => 'm05_users',
				'alias' => 'M05User',
				'type' => 'left',
				'conditions' => array(
					'T18IncomingNgList.entry_user = M05User.user_id',
				),
			),
		);

		$options['conditions']['T18IncomingNgList.company_id'] = $company_id;
		$options['conditions']['T18IncomingNgList.del_flag'] = "N";
		if(isset($filter) && !empty($filter)){
			if(isset($filter[1])){
				$options['conditions']['T18IncomingNgList.list_ng_no LIKE'] = "%".$filter[1]."%";
			}
			if(isset($filter[2])){
				$options['conditions']['T18IncomingNgList.list_name LIKE'] = "%".$filter[2]."%";
			}
			if(isset($filter[3])){
				$options['conditions']['T18IncomingNgList.total LIKE'] = "%".$filter[3]."%";
			}
			if(isset($filter[4])){
				$options['conditions']['DATE_FORMAT(T18IncomingNgList.created, "%Y-%m-%d %k:%i") LIKE'] = "%".$filter[4]."%";
			}
			if(isset($filter[5])){
				$options['conditions']['M05User.user_name LIKE'] = "%".$filter[5]."%";
			}
		}
		return $this->find('count', $options);
	}

	function getByListName($list_name = null, $company_id = null) {
		$options['fields'] = array(
			'T18IncomingNgList.*'
		);
		$options['conditions'] = array(
			'T18IncomingNgList.list_name' => $list_name,
			'T18IncomingNgList.del_flag' => "N",
		);
		if ($company_id) {
			$options['conditions']['T18IncomingNgList.company_id'] = $company_id;
		}
		return $this->find('first', $options);
	}

	function getMaxListNgNoByCompanyId($company_id=null) {
		$options['fields'] = array(
			'max(cast(T18IncomingNgList.list_ng_no as unsigned integer)) as max_list_ng_no',
		);
		$options['conditions']['T18IncomingNgList.company_id'] = $company_id;
		$options['conditions']['T18IncomingNgList.del_flag'] = "N";

		return $this->find('first', $options);
	}

	function getListNgInfoById($id = null) {
		$options['fields'] = array(
				'T18IncomingNgList.*',
		);
		$options['conditions'] = array(
				'T18IncomingNgList.id' => $id,
				'T18IncomingNgList.del_flag' => "N",
		);
		return $this->find('first', $options);
	}
}