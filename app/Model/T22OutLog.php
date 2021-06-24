<?php

class T22OutLog extends AppModel {
    var $name = 'T22OutLog';

    function getByScheduleId($schedule_id=null) {
        $options['fields'] = array(
            'T22OutLog.*',
        );

        $options['conditions'] = array(
            'T22OutLog.schedule_id' => $schedule_id,
            'T22OutLog.del_flag' => "N",
        );

        $options['order'] = array(
            'T22OutLog.time_start'
        );

        return $this->find('all', $options);
    }

    function getTimeEndByScheduleId($schedule_id=null) {
        $options['conditions'] = array(
            'T22OutLog.schedule_id' => $schedule_id,
        );
        $options['order'] = array(
            'T22OutLog.time_end desc',
        );
        return $this->find('first', $options);
    }
}