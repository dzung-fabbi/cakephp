<?php

class M02Company extends AppModel {
	var $name = 'M02Company';

	function getByCompanyId($company_id=null) {
		$options['fields'] = array(
			'M02Company.*'
		);

		$options['conditions']['M02Company.company_id'] = $company_id;
		$options['conditions']['M02Company.del_flag'] = 'N';

		return $this->find('first', $options);
	}

	function getCompanyByCompanyId($company_id) {
		$options['fields'] = array(
			'M02Company.*'
		);

		$options['conditions']['M02Company.company_id'] = $company_id;
		$options['conditions']['M02Company.del_flag'] = 'N';

		return $this->find('first', $options);
	}

	function getAll() {
		$options['fields'] = array(
			'M02Company.*'
		);

		$options['conditions']['M02Company.del_flag'] = 'N';

		return $this->find('all', $options);
	}

	function getCompanyData($limit=null, $page=null, $sort_order=null, $filter=null){
		$options['fields'] = array(
			'M02Company.*',
			'M05User.user_name',
			'M90PulldownCode.item_name',
			'M90PulldownCodeMaxRedial.item_name',
			'COUNT(M06CompanyExternal.external_number) as tel_num',
		);

		$options['joins'] = array(
			array(
				'table' => 'm06_company_externals',
				'alias' => 'M06CompanyExternal',
				'type' => 'left',
				'conditions' => array(
					'M02Company.company_id = M06CompanyExternal.company_id',
					"M06CompanyExternal.del_flag = 'N'",
				),
			),
			array(
				'table' => 'm05_users',
				'alias' => 'M05User',
				'type' => 'left',
				'conditions' => array(
					'M02Company.entry_user = M05User.user_id',
				)
			),
			array(
				'table' => 'm90_pulldown_codes',
				'alias' => 'M90PulldownCode',
				'type' => 'left',
				'conditions' => array(
					'M02Company.audio_mix_flag = M90PulldownCode.item_code',
					"M90PulldownCode.type_code = 'sync_voice'",
					"M90PulldownCode.del_flag = 'N'",
				)
			),
			array(
				'table' => 'm90_pulldown_codes',
				'alias' => 'M90PulldownCodeMaxRedial',
				'type' => 'left',
				'conditions' => array(
					'M02Company.max_redial = M90PulldownCodeMaxRedial.item_code',
					"M90PulldownCodeMaxRedial.type_code = 'schedule_redial_flag'",
					"M90PulldownCodeMaxRedial.del_flag = 'N'",
				)
			)
		);

		$options['conditions']['M02Company.del_flag ='] = 'N';

		$filter4 = false;
		if(isset($filter) && !empty($filter)){
			if(isset($filter[1])){
				$options['conditions']['M02Company.id LIKE'] = "%".$filter[1]."%";
			}
			if(isset($filter[2])){
				$options['conditions']['M02Company.company_code LIKE'] = "%".$filter[2]."%";
			}
			if(isset($filter[3])){
				$options['conditions']['M02Company.company_name LIKE'] = "%".$filter[3]."%";
			}
			if(isset($filter[4])){
				$options['group'] = 'M02Company.company_id HAVING(tel_num LIKE'." '%".$filter[4]."%'".')';
				$filter4 = true;

			}
			if(isset($filter[5])){
				$options['conditions']['M90PulldownCode.item_name LIKE'] = "%".$filter[5]."%";
			}
			if(isset($filter[6])){
				$options['conditions']['DATE_FORMAT(M02Company.created, "%Y-%m-%d %k:%i") LIKE'] = "%".$filter[6]."%";
			}
			if(isset($filter[7])){
				$options['conditions']['M05User.user_name LIKE'] = "%".$filter[7]."%";
			}
		}
		if($filter4 == false) {
			$options['group'] = array('M02Company.company_id');
		}

		if(isset($limit) && !empty($limit)){
			$options['limit'] = $limit;
		}
		if(isset($page) && !empty($page)){
			$options['page'] = $page;
		}

		if(isset($sort_order) && !empty($sort_order)){
			if($sort_order[0] == '0.tel_num ASC'){
				$options['order'] = array('tel_num ASC');
			} elseif($sort_order[0] == '0.tel_num DESC'){
				$options['order'] = array('tel_num DESC');
			} else {
				$options['order'] = $sort_order;
			}
		}else{
			$options['order'] = Array('M02Company.created DESC');
		}

		return $this->find('all', $options);
	}

	function getCompanyAll($filter = null){
		$options['fields'] = array(
			'COUNT(*) as count',
			'COUNT(M06CompanyExternal.external_number) as tel_num',
		);

		$options['joins'] = array(
			array(
				'table' => 'm06_company_externals',
				'alias' => 'M06CompanyExternal',
				'type' => 'left',
				'conditions' => array(
					'M02Company.company_id = M06CompanyExternal.company_id',
					"M02Company.company_id = 'N'"
				),
			),
			array(
				'table' => 'm05_users',
				'alias' => 'M05User',
				'type' => 'left',
				'conditions' => array(
					'M02Company.entry_user = M05User.user_id',
				)
			),
			array(
				'table' => 'm90_pulldown_codes',
				'alias' => 'M90PulldownCode',
				'type' => 'left',
				'conditions' => array(
					'M02Company.audio_mix_flag = M90PulldownCode.item_code',
					"M90PulldownCode.type_code = 'sync_voice'",
					"M90PulldownCode.del_flag = 'N'",
				)
			)
		);

		$options['conditions']['M02Company.del_flag ='] = 'N';

		$filter4 = false;
		if(isset($filter) && !empty($filter)){
			if(isset($filter[1])){
				$options['conditions']['M02Company.id LIKE'] = "%".$filter[1]."%";
			}
			if(isset($filter[2])){
				$options['conditions']['M02Company.company_code LIKE'] = "%".$filter[2]."%";
			}
			if(isset($filter[3])){
				$options['conditions']['M02Company.company_name LIKE'] = "%".$filter[3]."%";
			}
			if(isset($filter[4])){
				$options['group'] = array('M02Company.company_id HAVING(tel_num LIKE'." '%".$filter[4]."%'".')');
				$filter4 = true;

			}
			if(isset($filter[5])){
				$options['conditions']['M90PulldownCode.item_name LIKE'] = "%".$filter[5]."%";
			}
			if(isset($filter[6])){
				$options['conditions']['DATE_FORMAT(M02Company.created, "%Y-%m-%d %k:%i") LIKE'] = "%".$filter[6]."%";
			}
			if(isset($filter[7])){
				$options['conditions']['M05User.user_name LIKE'] = "%".$filter[7]."%";
			}
		}
		if($filter4 == false) {
			$options['group'] = array('M02Company.company_id');
		}

		return $this->find('all', $options);
	}

	function getCompanyMax(){
		$options['fields'] = array(
			'M02Company.company_id'
		);
		$options['order'] = array('M02Company.company_id DESC');
		return $this->find('first', $options);
	}

	function getCompanyByCode($company_code = null){
		$option['conditions']['M02Company.company_code'] = $company_code;
		$option['conditions']['M02Company.del_flag ='] = 'N';

		return $this->find('count', $option);
	}

	function getAllCompanyHideMenuInfo($sort_order=null, $filter=null) {
		$options['fields'] = array(
			'M02Company.id',
			'M02Company.company_id',
			'M02Company.company_code',
			'M02Company.company_name',
			'T94CompanyHideMenu.id',
			'T94CompanyHideMenu.menu_item_code'
		);
		$options['joins'] = array(
			array(
				'table' => 't94_company_hide_menus',
				'alias' => 'T94CompanyHideMenu',
				'type' => 'left',
				'conditions' => array(
					'T94CompanyHideMenu.company_id = M02Company.company_id' ,
					'T94CompanyHideMenu.del_flag = "N"',
				),
			),
		);

		$options['conditions']['M02Company.del_flag'] = 'N';
		if(isset($filter) && !empty($filter)){
			if(isset($filter[0])){
				$options['conditions']['M02Company.id LIKE'] = "%".$filter[0]."%";
			}
			if(isset($filter[1])){
				$options['conditions']['M02Company.company_code LIKE'] = "%".$filter[1]."%";
			}
			if(isset($filter[2])){
				$options['conditions']['M02Company.company_name LIKE'] = "%".$filter[2]."%";
			}
		}

		if(isset($sort_order) && !empty($sort_order)){
			$options['order'] = $sort_order;
		} else {
			$options['order'] = array('M02Company.id ASC');
		}

		return $this->find('all', $options);
	}
	function getCompanyCount($filter=null) {
		$options['fields'] = array(
			'M02Company.*',
		);

		$options['conditions']['M02Company.del_flag'] = 'N';
		if(isset($filter) && !empty($filter)){
			if(isset($filter[0])){
				$options['conditions']['M02Company.id LIKE'] = "%".$filter[0]."%";
			}
			if(isset($filter[1])){
				$options['conditions']['M02Company.company_code LIKE'] = "%".$filter[1]."%";
			}
			if(isset($filter[2])){
				$options['conditions']['M02Company.company_name LIKE'] = "%".$filter[2]."%";
			}
		}

		return $this->find('count', $options);
	}
	function getAcceptConsentFlag($company_id=null){
		$options['fields'] = array(
			'M02Company.accept_consent_flag'
		);
		$options['conditions']['M02Company.company_id'] = $company_id;
		$options['conditions']['M02Company.del_flag'] = 'N';
		return $this->find('first', $options);
	}
}