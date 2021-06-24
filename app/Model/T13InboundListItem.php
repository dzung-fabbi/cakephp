<?php

/**
 * T13InboundListItem model.
 */
class T13InboundListItem extends AppModel {
	var $name = 'T13InboundListItem';

	function getTitleByListId($list_id = null) {
		$options['fields'] = array(
			'T13InboundListItem.*',
		);
		$options['conditions']['T13InboundListItem.list_id'] = $list_id;
		$options['order'] = array(
			'T13InboundListItem.order_num',
		);
		return $this->find('all', $options);
	}

	function getTelNumColumn($list_id = null) {
		$options['fields'] = array(
			'T13InboundListItem.column'
		);

		$options['conditions']['list_id'] = $list_id;
		$options['conditions']['item_code'] = 'tel_no';

		return $this->find('first', $options);
	}
	
	//着信リスト項目の存在確認
	function SearchItemName($list_id = null, $item_name = null) {
		$options['fields'] = array(
			'T13InboundListItem.item_name'
		);

		$options['conditions']['list_id'] = $list_id;
		$options['conditions']['item_name'] = $item_name;

		return $this->find('count', $options);
	}

	function getColumnListByItemName($list_id = null, $item_name = null) {
		$options['fields'] = array(
			'T13InboundListItem.column'
		);
		$options['conditions']['T13InboundListItem.list_id'] = $list_id;
		$options['conditions']['T13InboundListItem.item_name'] = $item_name;
		$options['conditions']['T13InboundListItem.del_flag'] = 'N';
		return $this->find('first', $options);
	}

	// 20160406 Add by Giang - #6740: check item main unique - Begin
	function getColumnListByListId($list_id = null, $item_name = null) {
		$options['fields'] = array(
			'T13InboundListItem.column'
		);

		$options['joins'] = array(
			array(
				'table' => 't16_inbound_call_lists',
				'alias' => 'T16InboundCallList',
				'type' => 'right',
				'conditions' => array(
					"T16InboundCallList.id = $list_id",
					"T16InboundCallList.del_flag = 'N'",
					"T16InboundCallList.item_main = T13InboundListItem.item_name",
				)
			),
		);
		$options['conditions'] = array(
			'T13InboundListItem.del_flag' => 'N',
			'T13InboundListItem.list_id' => $list_id,
		);

		return $this->find('first', $options);
	}
	// 20160406 Add by Giang - #6740: check item main unique - Begin

	function getColumnListByItemCode($list_id = null, $item_code = null) {
		$options['fields'] = array(
				'T13InboundListItem.column'
		);
		$options['conditions']['T13InboundListItem.list_id'] = $list_id;
		$options['conditions']['T13InboundListItem.item_code'] = $item_code;
		$options['conditions']['T13InboundListItem.del_flag'] = 'N';
		return $this->find('first', $options);
	}

	function getListItemNameByCompany($company_id=null) {
		$options['fields'] = array(
			'T13InboundListItem.item_name'
		);

		$options['conditions'] = array(
			'T13InboundListItem.company_id' => $company_id,
			'T13InboundListItem.item_name <>' => '',
			'T13InboundListItem.del_flag' => 'N'
		);

		$options['group'] = array(
			'T13InboundListItem.item_name'
		);

		$options['order'] = array(
			'T13InboundListItem.order_num'
		);

		return $this->find('all', $options);
	}
}