<?php

/**
 * T800SmsSendResult model.
 */
class T800SmsSendResult extends AppModel {
    var $name = 'T800SmsSendResult';

    function getAllByScheduleId($schedule_id=null, $tel_column=null, $limit=null, $page=null, $sort_order=null, $filter=null, $date_from=null, $date_to=null, $valid_del_flag = false) {
        $options['fields'] = array(
            'T800SmsSendResult.*',
            'T501SmsTelHistory.*'
        );
        $options['joins'] = array(
            array(
                'table' => 't501_sms_tel_histories',
                'alias' => 'T501SmsTelHistory',
                'type' => 'left',
                'conditions' => array(
                    'T501SmsTelHistory.' . $tel_column . ' = T800SmsSendResult.tel_no',
                    'T501SmsTelHistory.schedule_id = T800SmsSendResult.schedule_id',
                    'T501SmsTelHistory.schedule_id = "' . $schedule_id . '"',
                    'T501SmsTelHistory.del_flag = "N"',
                )
            ),
        );
        $options['conditions'] = array(
            'T800SmsSendResult.schedule_id' => $schedule_id,
        );

        if ($valid_del_flag) {
            $options['conditions']['T800SmsSendResult.del_flag'] = "N";
        }
        if(isset($filter) && !empty($filter)) {
            if (isset($filter[0])) {
                $options['conditions']['T800SmsSendResult.send_datetime LIKE'] = "%" . $filter[0] . "%";
            }
            if (isset($filter[1])) {
                $options['conditions']['T800SmsSendResult.tel_no LIKE'] = "%" . $filter[1] . "%";
            }
            if (isset($filter[2])) {
                $options['conditions']['T501SmsTelHistory.carrier ='] = $filter[2];
            }
            if (isset($filter[3])) {
                $options['conditions']['IF(T800SmsSendResult.status IS NULL, "", IF(T800SmsSendResult.status = "success", "着信済み",IF(T800SmsSendResult.status = "outside", "圏外", IF(T800SmsSendResult.status = "unknown", "不明", IF(T800SmsSendResult.status = "history_judgement_ng", "履歴判定NG", "エラー"))))) ='] = $filter[3]; // #8298 add consentday
            }
        }

        if (isset($date_from) && $date_from) {
            $options['conditions']['T800SmsSendResult.send_datetime >='] = $date_from . ' 00:00:00';
        }
        if (isset($date_to) && $date_to) {
            $options['conditions']['T800SmsSendResult.send_datetime <='] = $date_to . ' 23:59:59';
        }

        if (isset($sort_order) && !empty($sort_order)) {
            $options['order'] = $sort_order;
        } else {
            $options['order'] = array(
                'T800SmsSendResult.send_datetime ASC'
            );
        }
        if (isset($limit) && !empty($limit)) {
            $options['limit'] = $limit;
        }
        if (isset($page) && !empty($page)) {
            $options['page'] = $page;
        }
        return $this->find('all', $options);
    }

    function getCountByScheduleId($schedule_id=null, $tel_column=null, $filter=null) {
        $options['fields'] = array(
            'T800SmsSendResult.*'
        );
        $options['joins'] = array(
            array(
                'table' => 't501_sms_tel_histories',
                'alias' => 'T501SmsTelHistory',
                'type' => 'left',
                'conditions' => array(
                    'T501SmsTelHistory.' . $tel_column . ' = T800SmsSendResult.tel_no',
                    'T501SmsTelHistory.schedule_id = T800SmsSendResult.schedule_id',
                    'T501SmsTelHistory.schedule_id = "' . $schedule_id . '"',
                    'T501SmsTelHistory.del_flag = "N"',
                )
            ),
        );
        $options['conditions'] = array(
            'T800SmsSendResult.schedule_id' => $schedule_id,
        );

        if(isset($filter) && !empty($filter)) {
            if (isset($filter[0])) {
                $options['conditions']['T800SmsSendResult.send_datetime LIKE'] = "%" . $filter[0] . "%";
            }
            if (isset($filter[1])) {
                $options['conditions']['T800SmsSendResult.tel_no LIKE'] = "%" . $filter[1] . "%";
            }
            if (isset($filter[2])) {
                $options['conditions']['T501SmsTelHistory.carrier ='] = $filter[2];
            }
            if (isset($filter[3])) {
                $options['conditions']['IF(T800SmsSendResult.status IS NULL, "", IF(T800SmsSendResult.status = "success", "着信済み",IF(T800SmsSendResult.status = "outside", "圏外", IF(T800SmsSendResult.status = "unknown", "不明", IF(T800SmsSendResult.status = "history_judgement_ng", "履歴判定NG", "エラー"))))) ='] = $filter[3]; // #8298 add consentday
            }
        }

        return $this->find('count', $options);
    }

    function getStatisticByScheduleId($schedule_id=null) {
        $options['fields'] = array(
            'COUNT(T800SmsSendResult.tel_no) as num_send',
            'SUM(IF(T800SmsSendResult.status = "success", 1, 0)) as num_send_success',
            'SUM(IF(T800SmsSendResult.status = "fail", 1,IF(T800SmsSendResult.status = "outside", 1,IF(T800SmsSendResult.status = "history_judgement_ng", 1, 0)))) as num_send_not_success', // #8298 add consentday
        	'SUM(IF(T800SmsSendResult.status = "outside", 1, 0)) as num_send_outside',
        	'SUM(IF(T800SmsSendResult.status = "fail", 1, 0)) as num_send_fail',
            'SUM(IF(T800SmsSendResult.status = "unknown", 1, 0)) as num_send_unknown',
            'SUM(IF(T800SmsSendResult.status = "history_judgement_ng", 1, 0)) as num_send_history_judgement_ng', // #8298 add consentday
        );

        $options['conditions'] = array(
            'T800SmsSendResult.schedule_id' => $schedule_id,
        );
        return $this->find('first', $options);
    }


    function getStatisticGroupByCarrier($schedule_id=null, $tel_column=null) {
        $options['fields'] = array(
            'T501SmsTelHistory.carrier',
            'COUNT(*) as count_by_carrier',
        );
        $options['joins'] = array(
            array(
                'table' => 't501_sms_tel_histories',
                'alias' => 'T501SmsTelHistory',
                'type' => 'left',
                'conditions' => array(
                    'T501SmsTelHistory.' . $tel_column . ' = T800SmsSendResult.tel_no',
                    'T501SmsTelHistory.schedule_id = T800SmsSendResult.schedule_id',
                    'T501SmsTelHistory.schedule_id = "' . $schedule_id . '"',
                    'T501SmsTelHistory.del_flag = "N"',
                )
            ),
        );
        $options['conditions'] = array(
            'T800SmsSendResult.schedule_id' => $schedule_id,
//            'T800SmsSendResult.status' => 'success',
        );
        $options['group'] = array(
            'T501SmsTelHistory.carrier'
        );
        return $this->find('all', $options);
    }
}