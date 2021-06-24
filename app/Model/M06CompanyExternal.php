<?php

class M06CompanyExternal extends AppModel {
    var $name = 'M06CompanyExternal';

    function getExternalNumberByCompanyId($company_id=null) {
        $options['fields'] = array(
            'M06CompanyExternal.id',
            'M06CompanyExternal.company_id',
            'M06CompanyExternal.external_number',
            'M06CompanyExternal.out_system',
            'M06CompanyExternal.out_price',
            'M06CompanyExternal.out_unit',
            'M06CompanyExternal.out_phone',
            'M06CompanyExternal.out_mobile',
            // 'M06CompanyExternal.out_voice',
            'M06CompanyExternal.in_system',
            'M06CompanyExternal.in_price',
            'M06CompanyExternal.in_unit',
            'M06CompanyExternal.in_phone',
            'M06CompanyExternal.in_mobile',
            // 'M06CompanyExternal.in_voice',

        );

        $options['conditions']['M06CompanyExternal.del_flag'] = 'N';
        if (isset($company_id)) {
            $options['conditions']['M06CompanyExternal.company_id'] = $company_id;
        }

        return $this->find('all', $options);
    }

    function getMaxId(){
        $options['fields'] = array(
            'MAX(M06CompanyExternal.id) as max_id',
        );

        return $this->find('all', $options);

    }

    function getExternalNumberDetail($company_id = null, $number = null){
        $options['fields'] = array(
            'M06CompanyExternal.*'
        );

        $options['joins'] = array(
            array(
                'table' => 'm02_companies',
                'alias' => 'M02Company',
                'type' => 'inner',
                'conditions' => array(
                    'M02Company.company_id = M06CompanyExternal.company_id',
                ),
            ),
        );

        $options['conditions']['M02Company.del_flag'] = 'N';
        $options['conditions']['M06CompanyExternal.del_flag'] = 'N';
        $options['conditions']['M06CompanyExternal.company_id'] = $company_id;
        $options['conditions']['M06CompanyExternal.external_number'] = $number;

        return $this->find('first', $options);
    }

    function getExternalNumber($number = null){
        $options['conditions']['M06CompanyExternal.external_number'] = $number;
        $options['conditions']['M06CompanyExternal.del_flag'] = 'N';

        return $this->find('count', $options);
    }
}