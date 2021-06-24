<?php

class T202SmsSendLog extends AppModel {
    var $name = 'T202SmsSendLog';

    function getByScheduleId($schedule_id=null) {
        $options['fields'] = array(
            'T202SmsSendLog.*',
        );

        $options['conditions'] = array(
            'T202SmsSendLog.schedule_id' => $schedule_id,
            'T202SmsSendLog.del_flag' => "N",
        );

        $options['order'] = array(
            'T202SmsSendLog.time_start'
        );

        return $this->find('all', $options);
    }

    function getTimeEndByScheduleId($schedule_id=null) {
        $options['conditions'] = array(
            'T202SmsSendLog.schedule_id' => $schedule_id,
        );
        $options['order'] = array(
            'T202SmsSendLog.time_end desc',
        );
        return $this->find('first', $options);
    }
}