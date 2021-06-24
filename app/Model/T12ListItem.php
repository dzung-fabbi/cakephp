<?php

/**
 * T12ListItem model.
 */
class T12ListItem extends AppModel {
	var $name = 'T12ListItem';

	function getTitleByListId($list_id = null) {
		$options['fields'] = array(
			'T12ListItem.*',
		);
		$options['conditions']['T12ListItem.list_id'] = $list_id;
		$options['order'] = array(
			'T12ListItem.order_num',
		);
		return $this->find('all', $options);
	}

	function getTelNumColumn($list_id = null) {
		$options['fields'] = array(
			'T12ListItem.column'
		);

		$options['conditions']['list_id'] = $list_id;
		$options['conditions']['item_code'] = 'tel_no';

		return $this->find('first', $options);
	}

	function getColumnListByItemName($list_id = null, $item_name = null) {
		$options['fields'] = array(
			'T12ListItem.column'
		);
		$options['conditions']['T12ListItem.list_id'] = $list_id;
		$options['conditions']['T12ListItem.item_name'] = $item_name;
		$options['conditions']['T12ListItem.del_flag'] = 'N';
		return $this->find('first', $options);
	}

	function getColumnListByItemCode($list_id = null, $item_code = null) {
		$options['fields'] = array(
				'T12ListItem.column'
		);
		$options['conditions']['T12ListItem.list_id'] = $list_id;
		$options['conditions']['T12ListItem.item_code'] = $item_code;
		$options['conditions']['T12ListItem.del_flag'] = 'N';
		return $this->find('first', $options);
	}

	function getListItemNameByCompany($company_id=null) {
		$options['fields'] = array(
			'T12ListItem.item_name'
		);

		$options['conditions'] = array(
			'T12ListItem.company_id' => $company_id,
			'T12ListItem.item_name <>' => '',
			'T12ListItem.del_flag' => 'N'
		);

		$options['group'] = array(
			'T12ListItem.item_name'
		);

		$options['order'] = array(
			'T12ListItem.order_num'
		);

		return $this->find('all', $options);
	}
}