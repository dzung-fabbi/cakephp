<?php
/**
 * T72District model.
 */

class T72District extends AppModel {
    var $name = 'T72District';

    function getAllByPrefectureCode($prefecture_code = null, $order = null, $district_notnull = null) {
        $options['conditions'] = array(
            'T72District.prefecture_code' => $prefecture_code
        );
        if (isset($order) && !empty($order)) {
            $options['order'] = array(
                'T72District.'.$order
            );
        }
        //get district have num keisai tel > 0
        if($district_notnull){
        	$options['conditions']['T72District.num_keisai >'] = 0;
        }else{
        	//get district have num tel > 0
        	$options['conditions']['T72District.num >'] = 0;
        }
        return $this->find('all', $options);
    }

    function findNameByDistrictCode($district_code=null) {
        $options['fields'] = array(
            'T72District.district_name',
            'T72District.district_code',
            'T72District.num',
            'T72District.num_keisai',
        );

        $options['conditions'] = array(
            'T72District.district_code' => $district_code
        );

        return $this->find('first', $options);
    }

    function getPopByPrefectureCode($prefecture_code = null) {
        $options['fields'] = array(
            'sum(T72District.population) as total_population'
        );
        $options['conditions'] = array(
            'T72District.prefecture_code' => $prefecture_code
        );
        return $this->find('first', $options);
    }

    function getLimitNumItem($keisai_flag=false, $prefecture_code=null) {
        if ($keisai_flag) {
            $field_to_check = 'num_keisai';
        } else {
            $field_to_check = 'num';
        }
        $options['fields'] = array(
            'T72District.prefecture_code',
//            'MIN(T72District.population_percent) as min_percent',
            'CEIL(0.5/MIN(T72District.population_percent)) as bottom_limit',
            'FLOOR(MIN(T72District.' . $field_to_check . '/T72District.population_percent)) as top_limit'
        );

        if (isset($prefecture_code) && $prefecture_code) {
            $options['conditions'] = array(
                'T72District.prefecture_code' => $prefecture_code
            );
        }

        $options['group'] = array(
            'T72District.prefecture_code'
        );

        return $this->find('all', $options);
    }
}