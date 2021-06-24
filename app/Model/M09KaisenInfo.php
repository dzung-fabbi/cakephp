<?php

class M09KaisenInfo extends AppModel {
    var $name = 'M09KaisenInfo';

    function getKaisenInfoByCode($kaisen_code=null) {
        $options['fields'] = array(
            'M09KaisenInfo.kaisen_code',
            'M09KaisenInfo.max_schedule',
        );

        $options['conditions']['M09KaisenInfo.kaisen_code'] = $kaisen_code;
        $options['conditions']['M09KaisenInfo.del_flag'] = 'N';
        return $this->find('first', $options);
    }

    function getAllKaisen() {
        $options['fields'] = array(
            'M09KaisenInfo.kaisen_code',
            'M09KaisenInfo.max_schedule',
        );
        $options['conditions']['M09KaisenInfo.del_flag'] = 'N';
        return $this->find('all', $options);
    }
}