<?php

class T300SmsTemplate extends AppModel {
	var $name = 'T300SmsTemplate';

	function getListByCompanyId($company_id, $limit=null, $page=null, $sort_order=null, $filter=null) {
		$options['fields'] = array(
			'T300SmsTemplate.*',
			'M05User.user_name',
		);

		$options['joins'] = array(
			array(
				'table' => 'm05_users',
				'alias' => 'M05User',
				'fields' => array('user_name'),
				'type' => 'left',
				'conditions' => array(
					'T300SmsTemplate.entry_user = M05User.user_id',
				),
			),
		);

		if(isset($filter) && !empty($filter)){
			if(isset($filter[1])){
				$options['conditions']['T300SmsTemplate.template_no LIKE'] = "%".$filter[1]."%";
			}
			if(isset($filter[2])){
				$options['conditions']['T300SmsTemplate.template_name LIKE'] = "%".$filter[2]."%";
			}
			if(isset($filter[3])){
				$options['conditions']['T300SmsTemplate.description LIKE'] = "%".$filter[3]."%";
			}
			if(isset($filter[4])){
				$options['conditions']['DATE_FORMAT(T300SmsTemplate.created, "%Y-%m-%d %k:%i") LIKE'] = "%".$filter[4]."%";
			}
			if(isset($filter[5])){
				$options['conditions']['M05User.user_name LIKE'] = "%".$filter[5]."%";
			}
		}
		$options['conditions']['T300SmsTemplate.company_id'] = $company_id;
		$options['conditions']['T300SmsTemplate.del_flag'] = "N";
		if(isset($sort_order) && !empty($sort_order)){
			$options['order'] = $sort_order;
		}else{
			$options['order'] = array(
				'T300SmsTemplate.created desc',
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
			'T300SmsTemplate.*',
			'M05User.user_name',
		);

		$options['joins'] = array(
			array(
				'table' => 'm05_users',
				'alias' => 'M05User',
				'type' => 'left',
				'conditions' => array(
					'T300SmsTemplate.entry_user = M05User.user_id',
				),
			),
		);

		$options['conditions']['T300SmsTemplate.company_id'] = $company_id;
		$options['conditions']['T300SmsTemplate.del_flag'] = "N";
		if(isset($filter) && !empty($filter)){
			if(isset($filter[1])){
				$options['conditions']['T300SmsTemplate.template_no LIKE'] = "%".$filter[1]."%";
			}
			if(isset($filter[2])){
				$options['conditions']['T300SmsTemplate.template_name LIKE'] = "%".$filter[2]."%";
			}
			if(isset($filter[3])){
				$options['conditions']['T300SmsTemplate.description LIKE'] = "%".$filter[3]."%";
			}
			if(isset($filter[4])){
				$options['conditions']['DATE_FORMAT(T300SmsTemplate.created, "%Y-%m-%d %k:%i") LIKE'] = "%".$filter[4]."%";
			}
			if(isset($filter[5])){
				$options['conditions']['M05User.user_name LIKE'] = "%".$filter[5]."%";
			}
		}
		return $this->find('count', $options);
	}

	function getMaxTemplateNoByCompanyId($company_id=null) {
		$options['fields'] = array(
			'max(cast(T300SmsTemplate.template_no as unsigned integer)) as max_template_no',
		);
		$options['conditions']['T300SmsTemplate.company_id'] = $company_id;
		$options['conditions']['T300SmsTemplate.del_flag'] = "N";

		return $this->find('first', $options);
	}

	function getSmsTemplateByTemplateName($template_name = null, $company_id = null) {
		$options['fields'] = array(
			'T300SmsTemplate.*'
		);
		$options['conditions'] = array(
			'T300SmsTemplate.template_name' => $template_name,
			'T300SmsTemplate.del_flag' => "N",
		);
		if ($company_id) {
			$options['conditions']['T300SmsTemplate.company_id'] = $company_id;
		}
		return $this->find('first', $options);
	}

	function getSmsTemplateById($id = null) {
		$options['fields'] = array(
				'T300SmsTemplate.*',
		);
		$options['conditions'] = array(
				'T300SmsTemplate.id' => $id,
				'T300SmsTemplate.del_flag' => "N",
		);
		return $this->find('first', $options);
	}
}