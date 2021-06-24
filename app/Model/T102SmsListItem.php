<?php

/**
 * T102SmsListItem model.
 */
class T102SmsListItem extends AppModel {
	var $name = 'T102SmsListItem';

	/** Get all title by list_id from T102SmsListItem
	 * @param string $list_id		is list id. Default is NULL	 
	 * @return array all of records be found or NULL if no record be found. Order by order_num field
	 * @since	: Created: 2016/04/22
	 * @since	: Modified: 2016/04/22
	 * @author	: Hungnv
	 */
	function getTitleByListId($list_id = null) {
		$options['fields'] = array(
			'T102SmsListItem.*',
		);
		$options['conditions']['T102SmsListItem.list_id'] = $list_id;
		$options['order'] = array(
			'T102SmsListItem.order_num',
		);
		return $this->find('all', $options);
	}

	function getTelNumColumn($list_id = null) {
		$options['fields'] = array(
			'T102SmsListItem.column'
		);

		$options['conditions']['list_id'] = $list_id;
		$options['conditions']['item_code'] = 'tel_no';

		return $this->find('first', $options);
	}

	function getColumnListByItemName($list_id = null, $item_name = null) {
		$options['fields'] = array(
			'T102SmsListItem.column'
		);
		$options['conditions']['T102SmsListItem.list_id'] = $list_id;
		$options['conditions']['T102SmsListItem.item_name'] = $item_name;
		$options['conditions']['T102SmsListItem.del_flag'] = 'N';
		return $this->find('first', $options);
	}

	function getColumnListByItemCode($list_id = null, $item_code = null) {
		$options['fields'] = array(
				'T102SmsListItem.column'
		);
		$options['conditions']['T102SmsListItem.list_id'] = $list_id;
		$options['conditions']['T102SmsListItem.item_code'] = $item_code;
		$options['conditions']['T102SmsListItem.del_flag'] = 'N';
		return $this->find('first', $options);
	}

	function getListItemNameByCompany($company_id=null) {
		$options['fields'] = array(
			'T102SmsListItem.item_name'
		);

		$options['conditions'] = array(
			'T102SmsListItem.company_id' => $company_id,
			'T102SmsListItem.item_name <>' => '',
			'T102SmsListItem.del_flag' => 'N'
		);

		$options['group'] = array(
			'T102SmsListItem.item_name'
		);

		$options['order'] = array(
			'T102SmsListItem.order_num'
		);

		return $this->find('all', $options);
	}
}