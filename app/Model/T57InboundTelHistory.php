<?php

/**
 * T57InboundTelHistory model.
 */
class T57InboundTelHistory extends AppModel {
	var $name = 'T57InboundTelHistory';

	function getTelNotCalls($inbound_id=null, $tel_column=null) {
		$options['fields'] = array(
			'T57InboundTelHistory.*'
		);
		$options['conditions'] = array(
			'T57InboundTelHistory.del_flag' => 'N',
			'T57InboundTelHistory.inbound_id' => $inbound_id,
			"T57InboundTelHistory." . $tel_column . " NOT IN (select tel_no from t81_incoming_results where inbound_id = '" . $inbound_id . "')"
		);

		return $this->find('all', $options);
	}

	function getByTels($inbound_id=null, $arr_tels=array(), $tel_column=null) {
		$options['fields'] = array(
			'T57InboundTelHistory.*'
		);
		$options['conditions'] = array(
			'T57InboundTelHistory.del_flag' => 'N',
			'T57InboundTelHistory.inbound_id' => $inbound_id,
			"T57InboundTelHistory." . $tel_column => $arr_tels
		);

		return $this->find('all', $options);
	}

	function getTelTotalByScheduleId($inbound_id=null, $tel_num_col=null, $tel_ng_arr=null) {
		$options['conditions'] = array(
			'T57InboundTelHistory.del_flag' => 'N',
			'T57InboundTelHistory.muko_flag' => 'N',
			'T57InboundTelHistory.inbound_id' => $inbound_id
		);

		if ($tel_num_col && $tel_ng_arr) {
			$options['conditions']['NOT'] = array(
				"T57InboundTelHistory.$tel_num_col" => $tel_ng_arr
			);
		}

		return $this->find('count', $options);
	}
	
	/*
		���M�ƍ��ƕ�����F�؁i���X�g�ƍ�����j������e���v���[�g�ő��݂���ꍇ�A
		�R�[���T�[�o�[���ōŏI�I�ɕێ����Ă���s�f�[�^���璅�M�ƍ����ʂ𔻒f����B
	*/
	function getByMatchitem($inbound_id=null, $item_main_column=null, $match_item=null) {
		$options['fields'] = array(
			"T57InboundTelHistory." . $item_main_column
		);
		$options['conditions'] = array(
			'T57InboundTelHistory.del_flag' => 'N',
			'T57InboundTelHistory.inbound_id' => $inbound_id,
			"T57InboundTelHistory.$item_main_column" => $match_item
		);

		return $this->find('count', $options);
	}

	function getDataItemMainByIdAndItemMain($inbound_id, $item_main_column) {
		$options['fields'] = array(
			"T57InboundTelHistory.$item_main_column",
		);
		$options['conditions']['T57InboundTelHistory.inbound_id'] = $inbound_id;
		$options['conditions']['T57InboundTelHistory.del_flag'] = "N";
		return $this->find('list', $options);
	}
}