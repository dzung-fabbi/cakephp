<?php

class M91MenuManageItem extends AppModel {
    var $name = 'M91MenuManageItem';

    function getAll() {
        $options['fields'] = array(
            'M91MenuManageItem.*'
        );

        $options['conditions'] = array(
            'M91MenuManageItem.del_flag' => 'N',
        );

        $options['order'] = array(
            'M91MenuManageItem.order_num'
        );

        return $this->find('all', $options);
    }
}