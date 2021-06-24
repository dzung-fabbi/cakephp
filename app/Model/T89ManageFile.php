<?php

/**
 * T89ManageFile model.
 */
class T89ManageFile extends AppModel {
    var $name = 'T89ManageFile';

	function getInfoFile($id){
		$options['fields'] = array(
			'T89ManageFile.*'
		);
		$options['conditions']['T89ManageFile.id'] = $id;
		return $this->find('first', $options);
	}

	function getFileById($id){
		$options['fields'] = array(
			'T89ManageFile.file_name',
			'T89ManageFile.file_contents',
		);
		$options['conditions']['T89ManageFile.id'] = $id;
		return $this->find('first', $options);
	}
}