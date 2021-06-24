<?php

class M90PulldownCode extends AppModel {
	var $name = 'M90PulldownCode';

	function getSelectOption($type_code, $without_item_codes=array()){
		//取得項目
		$options['fields'] = array(
			'M90PulldownCode.type_code',
			'M90PulldownCode.item_code',
			'M90PulldownCode.item_name',
			'M90PulldownCode.order_num',
		);
		//条件
		$options['conditions']['M90PulldownCode.type_code'] = $type_code;
		if ($without_item_codes) {
			$options['conditions'][] = 'M90PulldownCode.item_code NOT IN ("' . implode($without_item_codes, '","') . '")';
		}
		$options['conditions']['M90PulldownCode.del_flag'] = 'N';
		//順番
		$options['order'] = array('M90PulldownCode.order_num ASC');

		return $this->find('all', $options);
	}

	// 20160413 Add by Giang - #6906 Inbound history screen - Begin
	function getCountSelectOptionByTypeCode($type_code = null){

		$options['conditions']['M90PulldownCode.type_code'] = $type_code;
		$options['conditions']['M90PulldownCode.del_flag'] = 'N';

		return $this->find('count', $options);
	}
	// 20160413 Add by Giang - #6906 Inbound history screen - End

	function getOptionByMaxRedial($type_code, $max_redial){
		//取得項目
		$options['fields'] = array(
			'M90PulldownCode.type_code',
			'M90PulldownCode.item_code',
			'M90PulldownCode.item_name',
			'M90PulldownCode.order_num',
		);
		//条件
		$options['conditions']['M90PulldownCode.type_code'] = $type_code;
		$options['conditions']['M90PulldownCode.item_code <='] = $max_redial;
		$options['conditions']['M90PulldownCode.del_flag'] = 'N';
		//順番
		$options['order'] = array('M90PulldownCode.order_num ASC');

		return $this->find('all', $options);
	}

	function getItemNameByTypeCodeAndItemCode($type_code = null, $item_code = null){
		$options['fields'] = array(
			'M90PulldownCode.*',
		);

		$options['conditions']['M90PulldownCode.type_code'] = $type_code;
		$options['conditions']['M90PulldownCode.item_code'] = $item_code;
		$options['conditions']['M90PulldownCode.del_flag'] = 'N';

		return $this->find('first', $options);
	}

	function getItemCodeByTypeCodeAndItemName($type_code = null, $item_name = null){
		$options['fields'] = array(
			'M90PulldownCode.item_code',
		);

		$options['conditions']['M90PulldownCode.type_code'] = $type_code;
		$options['conditions']['M90PulldownCode.item_name'] = $item_name;
		$options['conditions']['M90PulldownCode.del_flag'] = 'N';

		return $this->find('first', $options);
	}

	function getProcNum($max){
		//取得項目
		$options['fields'] = array(
			'M90PulldownCode.type_code',
			'M90PulldownCode.item_code',
			'M90PulldownCode.item_name',
			'M90PulldownCode.order_num',
		);
		//条件
		$options['conditions']['M90PulldownCode.type_code'] = 'proc_num';
		$options['conditions']['CAST(M90PulldownCode.item_code AS UNSIGNED) <='] = $max;
		$options['conditions']['M90PulldownCode.del_flag'] = 'N';
		//順番
		$options['order'] = array('M90PulldownCode.order_num ASC');

		return $this->find('all', $options);

	}
}

?>