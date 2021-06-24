<?php

class T21OutTime extends AppModel {
    var $name = 'T21OutTime';

    function getByScheduleIds($schedule_ids=array(), $sort_order=null) {
        $options['fields'] = array(
            'T21OutTime.*',
        );

        $options['conditions'] = array(
            'T21OutTime.schedule_id' => $schedule_ids,
        	'T21OutTime.del_flag' => "N",
        );

        if(isset($sort_order) && !empty($sort_order)){
            $options['order'] = $sort_order;
        } else {
            $options['order'] = array(
                'T21OutTime.time_start'
            );
        }

        return $this->find('all', $options);
    }

    function getByScheduleId($schedule_id=null, $feature_flag=false, $time_end_run=false) {
        $options['fields'] = array(
            'T21OutTime.*',
        );

        $options['conditions'] = array(
            'T21OutTime.schedule_id' => $schedule_id,
            'T21OutTime.del_flag' => "N",
        );

        if ($feature_flag) {
            $options['conditions']['T21OutTime.time_start >'] = date('Y-m-d H:i:s');
        }

        if ($time_end_run) {
            $options['conditions']['T21OutTime.time_start >'] = $time_end_run;
        }

        $options['order'] = array(
            'T21OutTime.time_start'
        );

        return $this->find('all', $options);
    }

    function getScheduleByTime($time='', $schedule_ids=array()) {
        $options['fields'] = array(
            'T21OutTime.schedule_id',
        );

        $options['conditions']['OR']['SUBSTR(T21OutTime.time_start, 12, 5) LIKE'] = "%".$time."%";
        $options['conditions']['OR']['SUBSTR(T21OutTime.time_end, 12, 5) LIKE'] = "%".$time."%";

        $options['conditions']['T21OutTime.del_flag'] = "N";
        $options['conditions']['T21OutTime.schedule_id'] = $schedule_ids;

        return $this->find('list', $options);
    }

    function getAllNextCallTimeByScheduleId($schedule_id = null) {
        $options['fields'] = array(
            'T21OutTime.time_start',
            'T21OutTime.time_end',
        );

        $options['conditions']['T21OutTime.schedule_id'] = $schedule_id;
        $options['conditions']['T21OutTime.del_flag'] = 'N';
        $options['conditions']['T21OutTime.time_end >'] = date('Y-m-d H:i:s');

        $options['order'] = array(
            'T21OutTime.time_end ASC'
        );

        return $this->find('all', $options);
    }

    /**
     * スケジュールの中で一番早い開始時間を取得する
     * @param string $schedule_id スケジュールID
     * @return array 一番早い開始時間
     */
    function getTimeStartByScheduleId($schedule_id)
    {
        $options['fields'] = array(
            'MIN(time_start) as time_start',
        );

        $options['conditions']['schedule_id'] = $schedule_id;
        $options['conditions']['del_flag'] = 'N';

        $options['group'] = array('schedule_id');

        return $this->find('first', $options);
    }
}