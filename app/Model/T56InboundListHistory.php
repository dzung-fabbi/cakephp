<?php

class T56InboundListHistory extends AppModel {
	var $name = 'T56InboundListHistory';

	function getItemMainByInboundId($id = null) {
		$options['fields'] = array(
			'T56InboundListHistory.item_main'
		);
		$options['conditions'] = array(
			'T56InboundListHistory.inbound_id' => $id,
			'T56InboundListHistory.del_flag' => "N",
		);
		return $this->find('first', $options);
	}

	function getInfoItemMain($schedule_id, $list_id) {
		$options['fields'] = array(
			'T13InboundListItem.item_code',
			'T13InboundListItem.column'
		);
		$options['joins'] = array(
			array(
				'table' => 't13_inbound_list_items',
				'alias' => 'T13InboundListItem',
				'type' => 'inner',
				'conditions' => array(
					"T13InboundListItem.list_id = T56InboundListHistory.list_id",
					"T13InboundListItem.item_name = T56InboundListHistory.item_main",
					"T13InboundListItem.list_id = $list_id",
					"T13InboundListItem.del_flag = 'N'",
					"T56InboundListHistory.del_flag = 'N'",
				)
			)
		);
		$options['conditions']['inbound_id'] = $schedule_id;

		return $this->find('first', $options);
	}
}