<?php

class T94CompanyHideMenu extends AppModel {
    var $name = 'T94CompanyHideMenu';

    function getAll() {
        $options['fields'] = array(
            'T94CompanyHideMenu.*'
        );

        $options['conditions'] = array(
            'T94CompanyHideMenu.del_flag' => 'N',
        );

        return $this->find('all', $options);
    }

    function getHideMenuByCompanyId($company_id) {
        $options['fields'] = array(
            'T94CompanyHideMenu.*'
        );

        $options['conditions'] = array(
            'T94CompanyHideMenu.company_id' => $company_id,
            'T94CompanyHideMenu.del_flag' => 'N',
        );

        return $this->find('all', $options);
    }
}