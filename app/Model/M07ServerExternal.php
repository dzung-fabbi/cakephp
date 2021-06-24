<?php

class M07ServerExternal extends AppModel {
    var $name = 'M07ServerExternal';

    function getServerExternalByTel($external_number=null, $server_type=null) {
        $options['fields'] = array(
            'M07ServerExternal.server_id',
        	'M07ServerExternal.in_server_id',
            'M07ServerExternal.external_prefix',
        	'M07ServerExternal.enosip_port',
            'M07ServerExternal.bukken_company_id',
            'M07ServerExternal.bukken_shop_id',
        );

        $options['joins'] = array(
            array(
                'table' => 'm01_servers',
                'alias' => 'M01Server',
                'type' => 'inner',
                'conditions' => array(
                    'M01Server.server_id = M07ServerExternal.server_id',
                )
            )
        );

        $options['conditions']['M07ServerExternal.del_flag'] = 'N';
        $options['conditions']['M07ServerExternal.external_number'] = $external_number;
        if (isset($server_type)) {
            $options['conditions']['M01Server.server_type'] = $server_type;
        }

        return $this->find('first', $options);
    }

    function getInProcNumByExternalNumber($external_number){
    	$options['fields'] = array(
    		'M07ServerExternal.in_proc_num',
    	);
    	$options['conditions']['M07ServerExternal.del_flag'] = 'N';
    	$options['conditions']['M07ServerExternal.external_number'] = $external_number;
    	return $this->find('first', $options);
    }
    
    function getInfoByExternalNumber($external_number){
        $options['fields'] = array(
            'M07ServerExternal.kaisen_code',
        );
        $options['conditions']['M07ServerExternal.del_flag'] = 'N';
        $options['conditions']['M07ServerExternal.external_number'] = $external_number;
        return $this->find('first', $options);
    }
}