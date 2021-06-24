<?php

class M08SmsApiInfo extends AppModel {
    var $name = 'M08SmsApiInfo';

    function getServiceIdByCompanyId($company_id = null)
    {
        $options['fields'] = array(
            'M08SmsApiInfo.service_id',
            'M08SmsApiInfo.display_number',
            'M08SmsApiInfo.api_id',
            'M08SmsApiInfo.sms_short_url_allow_flag',
            'M08SmsApiInfo.company_id'
        );

        if (isset($company_id)) {
            $options['conditions']['M08SmsApiInfo.company_id'] = $company_id;
        }
        $options['conditions']["or"]['and'][]['M08SmsApiInfo.role_code'] = '30';
        $options['conditions']["or"]['and'][]['M08SmsApiInfo.api_id !='] = SMS_API_V2_VALUE;
        $options['conditions']["or"][]['M08SmsApiInfo.api_id'] = SMS_API_V2_VALUE;
        $options['conditions']['M08SmsApiInfo.del_flag'] = 'N';

        return $this->find('all', $options);
    }

    // 未使用関数
    function getServerInfoByServiceId($service_id = null) {
        $options['fields'] = array(
            'M08SmsApiInfo.*',
        );

        $options['conditions']['M08SmsApiInfo.service_id'] = $service_id;
        $options['conditions']['M08SmsApiInfo.role_code'] = '30';
        $options['conditions']['M08SmsApiInfo.del_flag'] = 'N';

        return $this->find('first', $options);
    }
    
    // 未使用関数(getServiceIdByCompanyId に統合)
    /** Get all the display number by company id
     * @param string $company_id: comapany id
     * @return array records from M08 or NULL if not found
     * @author Hungnv
     * @since 2016/06/09 
     */
    function getDisplayNumberByCompanyId($company_id = null){
    	$options['fields'] = array(
    			'M08SmsApiInfo.company_id',
    			'M08SmsApiInfo.service_id',
    			'M08SmsApiInfo.display_number',
    	);

        if (isset($company_id)) {
            $options['conditions']['M08SmsApiInfo.company_id'] = $company_id;
        }
    	$options['conditions']['M08SmsApiInfo.role_code'] = '30';
    	$options['conditions']['M08SmsApiInfo.del_flag'] = 'N';
    	
    	return $this->find('all', $options);
    }
    
    /** Get Sms api info by display number
     * @param string $display_number: display number
     * @return first record from M08 or NULL if not found
     * @author Hungnv
     * @since 2016/06/09
     */
    function getApiInfoByDisplayNumber($display_number = null) {
    	$options['fields'] = array(
    			'M08SmsApiInfo.*',
    	);
    
    	$options['conditions']['M08SmsApiInfo.display_number'] = $display_number;
        $options['conditions']["or"]['and'][]['M08SmsApiInfo.role_code'] = '30';
        $options['conditions']["or"]['and'][]['M08SmsApiInfo.api_id !='] = SMS_API_V2_VALUE;
        $options['conditions']["or"][]['M08SmsApiInfo.api_id'] = SMS_API_V2_VALUE;
    	$options['conditions']['M08SmsApiInfo.del_flag'] = 'N';
    
    	return $this->find('first', $options);
    }
}