<?php

/**
 *T70RddTel model.
*/
class T70RddTel extends AppModel {
    var $name = 'T70RddTel';

    function getRandomTels($switchboard=null, $prefecture_name=null, $district_name=null, $count=0, $keisai_flag=null) {
        $options['fields'] = array(
            'T70RddTel.tel_no',
            'T70RddTel.prefecture',
            'T70RddTel.district'
        );

        if (isset($switchboard)) {
            $options['conditions']['T70RddTel.tel_no LIKE'] = $switchboard . '%';
        }

        if (isset($prefecture_name)) {
            $options['conditions']['T70RddTel.prefecture'] = $prefecture_name;
        }

        if (isset($district_name)) {
            $options['conditions']['T70RddTel.district'] = $district_name;
        }

        if (isset($keisai_flag) && $keisai_flag == 1) {
            $options['conditions']['T70RddTel.keisai_flag'] = $keisai_flag;
        }

        $options['order'] = array(
            'RAND()'
        );

        $options['limit'] = $count;

        return $this->find('all', $options);
    }

    function countTelBySwitchBoard($switchboard = null, $keisai_flag = null) {
        if (isset($switchboard)) {
            $options['conditions']['T70RddTel.tel_no LIKE'] = $switchboard . '%';
        }
        if (isset($keisai_flag) && $keisai_flag == 1) {
            $options['conditions']['T70RddTel.keisai_flag'] = $keisai_flag;
        }

        return $this->find('count', $options);
    }

    function countTelBySixDigits($six_digits = array(), $keisai_flag = null) {
        $options['fields'] = array(
            'COUNT(*) as quantity',
            'SUBSTR(T70RddTel.tel_no FROM 1 FOR 6) as six_digit'
        );

        if (isset($six_digits) && sizeof($six_digits) > 0) {
            foreach ($six_digits as $six_digit) {
                if ($six_digit != '') {
                    $options['conditions']['OR'][]['T70RddTel.tel_no LIKE'] = $six_digit . '%';
                }
            }
        }
        if (isset($keisai_flag) && $keisai_flag == 1) {
            $options['conditions']['T70RddTel.keisai_flag'] = $keisai_flag;
        }

        $options['group'] = array(
            'six_digit'
        );

        return $this->find('all', $options);
    }
}