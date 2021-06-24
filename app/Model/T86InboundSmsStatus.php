<?php

/**
 * User: hungnv
 * Date: 2017/09/29
 */
class T86InboundSmsStatus extends AppModel {
    var $name = 'T86InboundSmsStatus';

    public function getSmsByInboundId($inboundId, $template_id)
    {
        $options['fields'] = array(
            'T86InboundSmsStatus.*',
            'T64.sms_content',
        );
        $options['joins'] = array(
            array(
                'table' => 't64_inbound_question_histories',
                'alias' => 'T64',
                'type' => 'inner',
                'conditions' => array(
                    'T86InboundSmsStatus.sms_question_no = T64.question_no',
                    'T86InboundSmsStatus.inbound_id = T64.inbound_id',
                )
            ),
        );
        $options['conditions']['T86InboundSmsStatus.inbound_id'] = $inboundId;
        $options['conditions']['T86InboundSmsStatus.template_id'] = $template_id;
        $options['conditions']['T86InboundSmsStatus.del_flag'] = 'N';
        $options['conditions']['T64.question_type'] = QUESTION_INBOUND_SMS;
        $options['conditions']['T64.del_flag'] = 'N';

        return $this->find('all', $options);
    }

    /* Get all sms record by inbound id
    * @param $inbound_id
    * @return Mix array|null
    * @author: Hungnv
    * @created: 2017/09/29
    */
    public function getSmsLogByInboundId($inbound_id){
        $options['fields'] = array(
            'T86InboundSmsStatus.*'
        );
        $options['conditions']['T86InboundSmsStatus.inbound_id'] = $inbound_id;
        $options['conditions']['T86InboundSmsStatus.del_flag'] = 'N';
    
        return $this->find('all', $options);
    }
}
