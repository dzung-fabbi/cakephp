<?php

/**
 * Created by PhpStorm.
 * User: linhnt
 * Date: 24/11/2016
 * Time: 2:08 CH
 */
class T83OutgoingSmsStatus extends AppModel {
    var $name = 'T83OutgoingSmsStatus';

    public function getSmsByScheduleId($scheduleId, $template_id)
    {
        $options['fields'] = array(
            'T83OutgoingSmsStatus.*',
            'T61.sms_content',
        );
        $options['joins'] = array(
            array(
                'table' => 't61_question_histories',
                'alias' => 'T61',
                'type' => 'inner',
                'conditions' => array(
                    'T83OutgoingSmsStatus.sms_question_no = T61.question_no',
                    'T83OutgoingSmsStatus.schedule_id = T61.schedule_id',
                )
            ),
        );
        $options['conditions']['T83OutgoingSmsStatus.schedule_id'] = $scheduleId;
        $options['conditions']['T83OutgoingSmsStatus.template_id'] = $template_id;
        $options['conditions']['T83OutgoingSmsStatus.del_flag'] = 'N';
        $options['conditions']['T61.question_type'] = array(QUESTION_SMS, QUESTION_SMS_INPUT);
        $options['conditions']['T61.del_flag'] = 'N';

        return $this->find('all', $options);
    }

    /* Get all sms record by schedule id
    * @param $schedule_id
    * @return Mix array|null
    * @author: Hungnv
    * @created: 2017/01/13
    */
    public function getSmsLogByScheduleId($schedule_id){
        $options['fields'] = array(
            'T83OutgoingSmsStatus.*'
        );
        $options['conditions']['T83OutgoingSmsStatus.schedule_id'] = $schedule_id;
        $options['conditions']['T83OutgoingSmsStatus.del_flag'] = 'N';
    
        return $this->find('all', $options);
    }
}
