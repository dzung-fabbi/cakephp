<?php

class M05User extends AppModel {
	var $name = 'M05User';
	/**
	**
	*
	* ログイン時ユーザーが存在するかどうか判断の処理の為
	* @param $user_id, $password
	*/
	function getInfoByUserIdAndPassword($user_id, $password) {
		//取得項目
		$options['fields'] = array(
			'M05User.id',
			'M05User.user_id',
			'M05User.user_name',
			'M05User.company_id',
			'M02Company.company_name',
			'M02Company.max_redial',
			'M05User.user_pass',
			'M05User.lock_flag',
			'M05User.login_flag',
			'M05User.password_change_date',
			'M05User.post_code',
		);
		$options['joins'] = array(
    		array(
    			'table' => 'm02_companies',
    			'alias' => 'M02Company',
    			'type' => 'inner',
    			'conditions' => array(
    				'M05User.company_id = M02Company.company_id',
    			),
    		),
    	);

		//検索条件
		$options['conditions']['M05User.user_id'] = $user_id;
		$options['conditions']['M05User.user_pass ='] = Security::hash($password, 'sha256', true);
		$options['conditions']['M05User.del_flag'] = 'N';
		$options['conditions']['M02Company.del_flag'] = 'N';

		return $this->find('first', $options);
	}

	function getInfoByUserId($user_id) {
		//取得項目
		$options['fields'] = array(
			'M05User.id',
			'M05User.user_id',
			'M05User.user_name',
			'M05User.company_id',
			'M02Company.company_name',
			'M05User.user_pass',
			'M05User.lock_flag',
			'M05User.login_flag',
			'M05User.password_change_date',
			'M05User.post_code'
		);

		$options['joins'] = array(
    		array(
    			'table' => 'm02_companies',
    			'alias' => 'M02Company',
    			'type' => 'inner',
    			'conditions' => array(
    				'M05User.company_id = M02Company.company_id' ,
					'M02Company.del_flag = "N"',
    			),
    		),
    	);

		//検索条件
		$options['conditions']['M05User.del_flag'] = 'N';
		$options['conditions']['M05User.user_id'] = $user_id;
		return $this->find('first', $options);
	}

	function getUserById($id = null) {
		$options['fields'] = array(
			'M05User.*',
		);
		//検索条件
		$options['conditions']['M05User.id'] = $id;
		$options['conditions']['M05User.del_flag'] = 'N';

		return $this->find('first', $options);
	}

	function getInfoByUserIdAndEmail($user_id, $mail) {
		//取得項目
		$options['fields'] = array(
			'M05User.*',
		);

		//検索条件
		$options['conditions']['M05User.user_id'] = $user_id;
		$options['conditions']['M05User.user_email ='] = $mail;
		$options['conditions']['M05User.del_flag'] = 'N';
		return $this->find('all', $options);
	}

	function getAllUser() {
		//取得項目
		$options['fields'] = array(
			'M05User.*',
		);
		$options['conditions']['M05User.del_flag'] = 'N';
		$options['order'] = array('M05User.id DESC');

		return $this->find('all', $options);
	}

	function countByUserId($user_id) {
		//取得項目
		$options['fields'] = array(
			'M05User.*',
		);
		//検索条件
		$options['conditions']['M05User.user_id'] = $user_id;
		$options['conditions']['M05User.del_flag'] = 'N';

		return $this->find('count', $options);
	}

	function getUserByCompanyIdandPostCode($company_id=null, $post_code=null, $limit=null, $page=null, $sort_order=null, $filter=null, $col_start = 1) {
		$options['fields'] = array(
			'M05User.*',
			'M03Auth.post_name',
			'M03Auth.rank',
			'M02Company.company_name',
		);

		$options['joins'] = array(
			array(
				'table' => 'm03_auths',
				'alias' => 'M03Auth',
				'type' => 'inner',
				'conditions' => array(
					'M05User.post_code = M03Auth.post_code',
					'M03Auth.del_flag = "N"',
				),
			),
			array(
				'table' => 'm02_companies',
				'alias' => 'M02Company',
				'fields' => array('post_name'),
				'type' => 'inner',
				'conditions' => array(
					'M05User.company_id = M02Company.company_id',
					'M02Company.del_flag = "N"',
				),
			),
		);

		if(isset($filter) && !empty($filter)){
			if(isset($filter[$col_start])){
				$options['conditions']['M02Company.company_name LIKE'] = "%".$filter[$col_start]."%";
			}
			if(isset($filter[($col_start + 1)])){
				$options['conditions']['M05User.user_id LIKE'] = "%".$filter[($col_start + 1)]."%";
			}
			if(isset($filter[($col_start + 2)])){
				$options['conditions']['M05User.user_name LIKE'] = "%".$filter[($col_start + 2)]."%";
			}
			if(isset($filter[($col_start + 3)])){
				$options['conditions']['M03Auth.post_name LIKE'] = "%".$filter[($col_start + 3)]."%";
			}
			if(isset($filter[($col_start + 4)])){
				$options['conditions']['DATE_FORMAT(M05User.created, "%Y-%m-%d %k:%i") LIKE'] = "%".$filter[($col_start + 4)]."%";
			}
		}

		if (isset($company_id) && !empty($company_id)) {
			$options['conditions']['M05User.company_id'] = $company_id;
		}
		if (isset($post_code) && !empty($post_code)) {
			$options['conditions']['M05User.post_code'] = $post_code;
		}
		$options['conditions']['M05User.del_flag'] = "N";

		if(isset($sort_order) && !empty($sort_order)){
			$options['order'] = $sort_order;
		}else{
			$options['order'] = array(
				'M05User.created desc'
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

	function getUserCountByCompanyIdandPostCode($company_id=null, $post_code=null, $filter=null, $col_start = 1) {
		$options['fields'] = array(
			'M05User.*',
			'M03Auth.post_name',
			'M02Company.company_name',
		);

		$options['joins'] = array(
			array(
				'table' => 'm03_auths',
				'alias' => 'M03Auth',
				'type' => 'inner',
				'conditions' => array(
					'M05User.post_code = M03Auth.post_code' ,
					'M03Auth.del_flag = "N"',
				),
			),
			array(
				'table' => 'm02_companies',
				'alias' => 'M02Company',
				'fields' => array('post_name'),
				'type' => 'inner',
				'conditions' => array(
					'M05User.company_id = M02Company.company_id' ,
					'M02Company.del_flag = "N"',
				),
			),
		);

		if (isset($company_id) && !empty($company_id)) {
			$options['conditions']['M05User.company_id'] = $company_id;
		}
		if (isset($post_code) && !empty($post_code)) {
			$options['conditions']['M05User.post_code'] = $post_code;
		}
		$options['conditions']['M05User.del_flag'] = "N";

		if(isset($filter) && !empty($filter)){
			if(isset($filter[$col_start])){
				$options['conditions']['M02Company.company_name LIKE'] = "%".$filter[$col_start]."%";
			}
			if(isset($filter[($col_start + 1)])){
				$options['conditions']['M05User.user_id LIKE'] = "%".$filter[($col_start + 1)]."%";
			}
			if(isset($filter[($col_start + 2)])){
				$options['conditions']['M05User.user_name LIKE'] = "%".$filter[($col_start + 2)]."%";
			}
			if(isset($filter[($col_start + 3)])){
				$options['conditions']['M03Auth.post_name LIKE'] = "%".$filter[($col_start + 3)]."%";
			}
			if(isset($filter[($col_start + 4)])){
				$options['conditions']['DATE_FORMAT(M05User.created, "%Y-%m-%d %k:%i") LIKE'] = "%".$filter[($col_start + 4)]."%";
			}
		}
		return $this->find('count', $options);
	}

	function getMaxUserNoBycompanyId($company_id = null) {
		$options['fields'] = array(
			'max(M05User.user_no) as max_user_no'
		);
		$options['conditions'] = array(
			'M05User.company_id' => $company_id,
			'M05User.del_flag' => "N",
		);
		return $this->find('first', $options);
	}

	function getUserByUserId($user_id = null) {
		$options['fields'] = array(
			'M05User.*'
		);
		$options['conditions'] = array(
			"M05User.user_id" => $user_id,
			'M05User.del_flag' => "N",
		);
		return $this->find('first', $options);
	}

	function getDeletedUserByUserId($user_id = null) {
		$options['fields'] = array(
			'M05User.*'
		);
		$options['conditions'] = array(
			"M05User.user_id" => $user_id,
			'M05User.del_flag' => "Y",
		);
		return $this->find('first', $options);
	}
}

?>