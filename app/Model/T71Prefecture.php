<?php

/**
 * T71Prefecture model.
 */

class T71Prefecture extends AppModel {
    var $name = 'T71Prefecture';

    function findNameByPrefectureCode($prefecture_code=null) {
        $options['fields'] = array(
            'T71Prefecture.prefecture_name'
        );

        $options['conditions'] = array(
            'T71Prefecture.prefecture_code' => $prefecture_code
        );

        return $this->find('first', $options);
    }
}