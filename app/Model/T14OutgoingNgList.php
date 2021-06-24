<?php

class T14OutgoingNgList extends AppModel {
	var $name = 'T14OutgoingNgList';

	function getNgListByCompanyId($company_id = null) {
		$options['fields'] = array(
			'T14OutgoingNgList.*',
		);

		$options['conditions'] = array(
			'T14OutgoingNgList.company_id' => $company_id,
			'T14OutgoingNgList.del_flag' => "N",
		);

		$options['order'] = array(
			'T14OutgoingNgList.id desc',
		);

		return $this->find('all', $options);
	}

	function getNgListInfoByListNgId($list_ng_id = null) {
		$options['fields'] = array(
			'T14OutgoingNgList.*',
		);
		$options['conditions'] = array(
			'T14OutgoingNgList.id' => $list_ng_id,
			'T14OutgoingNgList.del_flag' => "N",
		);
		return $this->find('first', $options);
	}

	//20160226 Add by Giang : #6532 - get data for call_list_ng index screen - begin
	function getListNgByCompanyId($company_id, $limit=null, $page=null, $sort_order=null, $filter=null) {
		$options['fields'] = array(
			'T14OutgoingNgList.*',
			'M05User.user_name',
		);

		$options['joins'] = array(
			array(
				'table' => 'm05_users',
				'alias' => 'M05User',
				'fields' => array('user_name'),
				'type' => 'left',
				'conditions' => array(
					'T14OutgoingNgList.entry_user = M05User.user_id',
				),
			),
		);

		if(isset($filter) && !empty($filter)){
			if(isset($filter[1])){
				$options['conditions']['T14OutgoingNgList.list_ng_no LIKE'] = "%".$filter[1]."%";
			}
			if(isset($filter[2])){
				$options['conditions']['T14OutgoingNgList.list_name LIKE'] = "%".$filter[2]."%";
			}
			if(isset($filter[3])){
				$options['conditions']['T14OutgoingNgList.total LIKE'] = "%".$filter[3]."%";
			}
			if(isset($filter[4])){
				$options['conditions']['OR']['DATE_FORMAT(T14OutgoingNgList.expired_date_from, "%Y-%m-%d") LIKE'] = "%".$filter[4]."%";
				$options['conditions']['OR']['DATE_FORMAT(T14OutgoingNgList.expired_date_to, "%Y-%m-%d") LIKE'] = "%".$filter[4]."%";
			}
			if(isset($filter[5])){
				$options['conditions']['DATE_FORMAT(T14OutgoingNgList.created, "%Y-%m-%d %k:%i") LIKE'] = "%".$filter[5]."%";
			}
			if(isset($filter[6])){
				$options['conditions']['M05User.user_name LIKE'] = "%".$filter[6]."%";
			}
		}
		$options['conditions']['T14OutgoingNgList.company_id'] = $company_id;
		$options['conditions']['T14OutgoingNgList.del_flag'] = "N";
		if(isset($sort_order) && !empty($sort_order)){
			$options['order'] = $sort_order;
		}else{
			$options['order'] = array(
				'T14OutgoingNgList.list_ng_no desc',
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
			'T14OutgoingNgList.*',
			'M05User.user_name',
		);

		$options['joins'] = array(
			array(
				'table' => 'm05_users',
				'alias' => 'M05User',
				'type' => 'left',
				'conditions' => array(
					'T14OutgoingNgList.entry_user = M05User.user_id',
				),
			),
		);

		$options['conditions']['T14OutgoingNgList.company_id'] = $company_id;
		$options['conditions']['T14OutgoingNgList.del_flag'] = "N";
		if(isset($filter) && !empty($filter)){
			if(isset($filter[1])){
				$options['conditions']['T14OutgoingNgList.list_ng_no LIKE'] = "%".$filter[1]."%";
			}
			if(isset($filter[2])){
				$options['conditions']['T14OutgoingNgList.list_name LIKE'] = "%".$filter[2]."%";
			}
			if(isset($filter[3])){
				$options['conditions']['T14OutgoingNgList.total LIKE'] = "%".$filter[3]."%";
			}
			if(isset($filter[4])){
				$options['conditions']['OR']['DATE_FORMAT(T14OutgoingNgList.expired_date_from, "%Y-%m-%d") LIKE'] = "%".$filter[4]."%"; /* 20160311 Edit by Giang : #6538 - refactor code */
				$options['conditions']['OR']['DATE_FORMAT(T14OutgoingNgList.expired_date_to, "%Y-%m-%d") LIKE'] = "%".$filter[4]."%"; /* 20160311 Edit by Giang : #6538 - refactor code */
			}
			if(isset($filter[5])){
				$options['conditions']['DATE_FORMAT(T14OutgoingNgList.created, "%Y-%m-%d %k:%i") LIKE'] = "%".$filter[5]."%";
			}
			if(isset($filter[6])){
				$options['conditions']['M05User.user_name LIKE'] = "%".$filter[6]."%";
			}
		}
		return $this->find('count', $options);
	}

	function getMaxListNgNoByCompanyId($company_id=null) {
		$options['fields'] = array(
			'max(cast(T14OutgoingNgList.list_ng_no as unsigned integer)) as max_list_ng_no',
		);
		$options['conditions']['T14OutgoingNgList.company_id'] = $company_id;

		return $this->find('first', $options);
	}

	function getByListName($list_name = null, $company_id = null) {
		$options['fields'] = array(
			'T14OutgoingNgList.*'
		);
		$options['conditions'] = array(
			'T14OutgoingNgList.list_name' => $list_name,
			'T14OutgoingNgList.del_flag' => "N",
		);
		if ($company_id) {
			$options['conditions']['T14OutgoingNgList.company_id'] = $company_id;
		}
		return $this->find('first', $options);
	}

	function getListNgInfoById($id = null) {
		$options['fields'] = array(
				'T14OutgoingNgList.*',
		);
		$options['conditions'] = array(
				'T14OutgoingNgList.id' => $id,
				'T14OutgoingNgList.del_flag' => "N",
		);
		return $this->find('first', $options);
	}
	//20160226 Add by Giang : #6532 - get data for call_list_ng index screen - end
}