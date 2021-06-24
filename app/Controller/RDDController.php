<?php
App::uses('AppController', 'Controller');
class RDDController extends AppController{
    var $uses = array('T70RddTel', 'T71Prefecture', 'T72District', 'T10CallList', 'T11TelList', 'C99Parameter');

    function index() {
        $prefectures_tmp = $this->T71Prefecture->find('all');
//         $this->log($prefectures_tmp);

        foreach ($prefectures_tmp as $prefecture) {
            $prefectures[$prefecture['T71Prefecture']['prefecture_code'] - 1] = $prefecture;
        }

        $limit_num_item_prefecture = $this->T72District->getLimitNumItem();

        foreach ($limit_num_item_prefecture as $limit) {
            $prefectures[$limit['T72District']['prefecture_code'] - 1][] = $limit[0];
        }

        $max_item = 0;
        $max_tel_param = $this->C99Parameter->getByFunctionIdAndParameterId('LIST', 'MAX_TEL');
        if (is_array($max_tel_param) && sizeof($max_tel_param) > 0) {
            $max_item = $max_tel_param['C99Parameter']['parameter_value'];
        }

        $max_list = 0;
        $max_list_param = $this->C99Parameter->getByFunctionIdAndParameterId('RDD', 'MAX_LIST');
        if (is_array($max_list_param) && sizeof($max_list_param) > 0) {
            $max_list = $max_list_param['C99Parameter']['parameter_value'];
        }

        $this->set('prefectures', $prefectures);
        $this->set('max_item', $max_item);
        $this->set('max_list', $max_list);
    }

    function load_list_district() {
        $keisai_flag = false;
        if (!empty($this->data)) {
            $katakana_tmp = array(
                'ア行' => array('ア', 'イ', 'ウ', 'エ', 'オ'),
                'カ行' => array('カ', 'キ', 'ク', 'ケ', 'コ'),
                'サ行' => array('サ', 'シ', 'ス', 'セ', 'ソ'),
                'タ行' => array('タ', 'チ', 'ツ', 'テ', 'ト'),
                'ナ行' => array('ナ', 'ニ', 'ヌ', 'ネ', 'ノ'),
                'ハ行' => array('ハ', 'ヒ', 'フ', 'ヘ', 'ホ'),
                'マ行' => array('マ', 'ミ', 'ム', 'メ', 'モ'),
                'ヤ行' => array('ヤ', 'ユ', 'ヨ'),
                'ラ行' => array('ラ', 'リ', 'ル', 'レ', 'ロ'),
                'ワ行' => array('ワ', 'ヲ'),
            );

            foreach ($katakana_tmp as $row_name => $katakana_row) {
                foreach ($katakana_row as $kana_char) {
                    $katakana[$kana_char] = $row_name;
                }

                $group_districts[$row_name] = array();
            }

            $this->layout = false;
            $this->view = 'ajax_load_list_district';

            $prefecture_code = $this->data['prefecture_code'];
            if ($this->data['keisai_flag'] == "1") {
                $keisai_flag = true;
            }
            if ($keisai_flag) {
                $districts_tmp = $this->T72District->getAllByPrefectureCode($prefecture_code, "district_name_kana", true);
            } else {
                $districts_tmp = $this->T72District->getAllByPrefectureCode($prefecture_code, "district_name_kana", false);
            }
            foreach ($districts_tmp as $district) {
                $group_districts[$katakana[mb_convert_kana(mb_substr($district['T72District']['district_name_kana'], 0, 1))]][] = $district;
            }

            $this->set('keisai_flag', $keisai_flag);
            $this->set('group_districts', $group_districts);
        }
    }

    function create_call_list() {
        if (!empty($this->data)) {
            $list_name_base = $this->data['RDD']['list_name'];
            $tel_count = $this->data['RDD']['quantity_item_total'];
            $list_count = $this->data['RDD']['quantity_list'] > 0 ? $this->data['RDD']['quantity_list'] : 1;
            $type_create = $this->data['RDD']['type_create'];
            $keisai_flag = isset($this->data['RDD']['only_use_data_posted_flag']) ? $this->data['RDD']['only_use_data_posted_flag'] : 0;
            switch ($type_create) {
                case 'type_switchboard': // create by switchboard
                    $datas = $this->data['data_switchboard'];
                    break;
                case 'type_prefecture': // create by prefecture
                    $datas = $this->data['data_prefecture'];
                    break;
                case 'type_district': // create by district
                    $datas = $this->data['data_district'];
                    break;
            }

            //prepare data for T11TelList
            //$this->log("start get data");
            $arr_tel_nos = array();
            foreach ($datas as $data) {
                $quantity = $data['quantity'];
                if ($quantity > 0) {
                    switch ($type_create) {
                        case 'type_switchboard': // create by switchboard
                            $switchboard = $data['switchboard'];
                            $tel_nos_tmp = $this->T70RddTel->getRandomTels($switchboard, null, null, $quantity * $list_count, $keisai_flag);

                            for ($i = 0; $i < $list_count; $i++) {
                                if (!(isset($arr_tel_nos[$i]) && is_array($arr_tel_nos[$i]))) {
                                    $arr_tel_nos[$i] = array();
                                }
                                $arr_tel_nos[$i] = array_merge($arr_tel_nos[$i], array_slice($tel_nos_tmp, 0 + $quantity * $i, $quantity));
                            }
                            break;
                        // create by prefecture
                        case 'type_prefecture':
                            $prefecture_code = $data['prefecture_code'];
                            $prefecture_name = $this->T71Prefecture->findNameByPrefectureCode($prefecture_code);
                            $prefecture_name = $prefecture_name['T71Prefecture']['prefecture_name'];
                            $prefecture_pop = $this->T72District->getPopByPrefectureCode($prefecture_code);
                            $district_arr = $this->T72District->getAllByPrefectureCode($prefecture_code, "num");
                            $prefecture_pop = $prefecture_pop[0]['total_population'];
                            $count = 0;
                            $total_rate = 0;
                            $total_need = 0;
                            foreach ($district_arr as $district) {
                            	$count++;
                            	if($count == count($district_arr)){
                            		$pop_rate = round(1 - $total_rate, 5);
                            		$tel_need = $quantity - $total_need;
                            	}else{
                            		$pop_rate = round($district['T72District']['population']/$prefecture_pop, 5);
                            		$tel_need = round($pop_rate * $quantity);
                            		if($tel_need == 0) $tel_need = 1;
                            		$total_rate = $total_rate + $pop_rate;
                            		$total_need = $total_need + $tel_need;
                            	}
                                $district_name = $district["T72District"]["district_name"];
                                if ($keisai_flag) {
                                    $num = $district['T72District']['num_keisai'];
                                } else {
                                    $num = $district['T72District']['num'];
                                }
                                $num = floor($num / $list_count);
                                if ($num < $tel_need) {
                                    $tel_get = $num;
                                } else {
                                    $tel_get = $tel_need;
                                }
                                $tel_get = $list_count * $tel_get;
                              	//$this->log($district_name." - ".$num." - ".$pop_rate." - ".$tel_need." - ".$tel_get);
                                $tel_nos_tmp = $this->T70RddTel->getRandomTels(null, $prefecture_name, $district_name, $tel_get, $keisai_flag);
                                for ($i = 0; $i < $list_count; $i++) {
                                    if (!(isset($arr_tel_nos[$i]) && is_array($arr_tel_nos[$i]))) {
                                        $arr_tel_nos[$i] = array();
                                    }
                                    $arr_tmp = array_slice($tel_nos_tmp, $tel_get / $list_count * $i, $tel_get / $list_count);
                                    $arr_tel_nos[$i] = array_merge($arr_tel_nos[$i], $arr_tmp);
                                }
                            }
                            break;
                        case 'type_district': // create by district
                            $district_code = $data['district_code'];
                            $district_name = $this->T72District->findNameByDistrictCode($district_code);
                            $district_name = $district_name['T72District']['district_name'];
                            $prefecture_name = $this->T71Prefecture->findNameByPrefectureCode($this->data['RDD']['prefecture_code']);
                            $prefecture_name = $prefecture_name['T71Prefecture']['prefecture_name'];

                            $tel_nos_tmp = $this->T70RddTel->getRandomTels(null, trim($prefecture_name), $district_name, $quantity * $list_count, $keisai_flag);
                            //$this->log(trim($prefecture_name)." - ".$district_name." - ".$quantity * $list_count." - ".$keisai_flag);
                            //$this->log($tel_nos_tmp);
                            for ($i = 0; $i < $list_count; $i++) {
                                if (!(isset($arr_tel_nos[$i]) && is_array($arr_tel_nos[$i]))) {
                                    $arr_tel_nos[$i] = array();
                                }
                                $arr_tel_nos[$i] = array_merge($arr_tel_nos[$i], array_slice($tel_nos_tmp, 0 + $quantity * $i, $quantity));
                            }
                            break;

                    }
                }
            }
            //$this->log("end get data");
            //$this->log("start insert");
            $dsT10CallList = $this->T10CallList->getDataSource();
            $dsT11TelList = $this->T11TelList->getDataSource();
            $dsT10CallList->begin($this);
            $dsT11TelList->begin($this);
            for ($i = 0; $i < $list_count; $i++) {
                $tel_nos = $arr_tel_nos[$i];
                //create T10CallList
                $list_name = $list_name_base . ($list_count > 1 ? ($i + 1) : '');
                $max_list_id = $this->T10CallList->getMaxListId();
                if ($max_list_id['0']['max_list_id']) {
                    $list_id = (string)($max_list_id['0']['max_list_id'] + 1);
                    $list_id = substr('000000', strlen($list_id)) . $list_id;
                } else {
                    $list_id = '000001';
                }
                $this->T10CallList->create();
                $data_call_list['T10CallList']['company_id'] = $this->ESession->getUserCompanyId($this);
                $data_call_list['T10CallList']['list_id'] = $list_id;
                $data_call_list['T10CallList']['list_name'] = $list_name;
                $data_call_list['T10CallList']['tel_count'] = sizeof($tel_nos);
                $data_call_list['T10CallList']['entry_user'] = $this->ESession->getUserId($this);
                $data_call_list['T10CallList']['entry_program'] = $this->name . '_' . __FUNCTION__;
                $call_list = $this->T10CallList->save($data_call_list);
                if (!$call_list) {
                    $dsT10CallList->rollback($this);
                    $this->log("T10登録：失敗");
                    echo 'error';
                    exit;
                }
                //create T11TelList
                $company_id = $this->ESession->getUserCompanyId($this);
                $list_id = $call_list['T10CallList']['list_id'];
                $entry_user = $this->ESession->getUserId($this);
                $entry_program = $this->name . '_' . __FUNCTION__;
                $query_base = "INSERT INTO t11_tel_lists ".
                		"(company_id, list_id, tel_no, memo, entry_user, entry_program) ".
                		"VALUES ";
                $query = $query_base;
                $count = 0;
                foreach ($tel_nos as $tel_no) {
                	$count ++;
                	$tel = $tel_no['T70RddTel']['tel_no'];
                	$memo = $tel_no['T70RddTel']['prefecture'] . $tel_no['T70RddTel']['district'];
                	if($count % 10000 == 0 || $count == count($tel_nos)){
                		$query = $query."('".$company_id."','".$list_id."','".$tel."','".$memo."','".$entry_user."','".$entry_program."');";
                        if ($this->T11TelList->query($query)) {
                            $dsT10CallList->rollback($this);
                            $dsT11TelList->rollback($this);
                            $this->log("T11削除：失敗");
                            echo 'error';
                            exit;
                        }
                        $query = $query_base;
                	}else{
                		$query = $query."('".$company_id."','".$list_id."','".$tel."','".$memo."','".$entry_user."','".$entry_program."'), ";
                	}
                }
            }
            $dsT10CallList->commit($this);
            $dsT11TelList->commit($this);
            //$this->log("end insert");
            echo 'success';
            exit;
        }
        exit;
    }

    function check_exist_listname() {
        $data = $this->data;
        $list_name_base = $data['list_name'];
        $list_count = $data['quantity_list'] > 0 ? $data['quantity_list'] : 1;

        for ($i=1; $i<=$list_count; $i++) {
            $list_name = $list_name_base . ($list_count > 1 ? $i : '');
            $info_list = $this->T10CallList->getByListName($list_name);
            if (isset($info_list["T10CallList"]["list_id"]) && !empty($info_list["T10CallList"]["list_id"])) {
                echo "false";
                exit;
            }
        }
        echo "true";
        exit;
    }

    function get_tel_num() {
        $data = $this->data;
        $keisai_flag = 0;
        if (isset($data['keisai_flag'])) {
            $keisai_flag = $data['keisai_flag'];
        }

        $result = $this->T70RddTel->countTelBySwitchBoard($data['switchboard'], $keisai_flag);
        echo $result;
        exit;
    }

    function get_tel_num2() {
        $data = $this->data;

        $keisai_flag = 0;
        if (isset($data['keisai_flag'])) {
            $keisai_flag = $data['keisai_flag'];
        }

        $result_tmp = $this->T70RddTel->countTelBySixDigits($data['listSixDigit'], $keisai_flag);

        foreach ($data['listSixDigit'] as $key => $value) {
            if ($value != '') {
                $result[$key] = 0;
            }
        }

        foreach ($result_tmp as $rs) {
            $result[array_search($rs[0]['six_digit'], $data['listSixDigit'])] = $rs[0]['quantity'];
        }

        echo json_encode($result);
        exit;
    }

    function getPrefecture() {
        $prefectures_tmp = $this->T71Prefecture->find('all');

        foreach ($prefectures_tmp as $prefecture) {
            $prefectures[$prefecture['T71Prefecture']['prefecture_code'] - 1] = $prefecture;
        }

        $keisai_flag = $this->data['keisai_flag'];
        $limit_num_item_prefecture = $this->T72District->getLimitNumItem($keisai_flag);

        foreach ($limit_num_item_prefecture as $limit) {
            $prefectures[$limit['T72District']['prefecture_code'] - 1][] = $limit[0];
        }

        echo json_encode($prefectures);
        exit();
    }

    function getDistrictNum() {
        $data = $this->data;
        $district_code_arr = $data['district_code_arr'];
        $result = array();
        foreach ($district_code_arr as $district_code) {
            $result[] = $this->T72District->findNameByDistrictCode($district_code);
        }
        echo json_encode($result);
        exit;
    }

/*    function check_prefecture() {
        $data = $this->data;
        $prefecture_code = $data['prefecture_code'];
        $quantity = $data['quantity'];
        $quantity_list = $data['quantity_list'];
        $keisai_flag = $data['keisai_flag'];

        $districts = $this->T72District->getAllByPrefectureCode($prefecture_code, "num");
        $result = 'true';

        if ($keisai_flag == 1) {
            $field_to_check = 'num_keisai';
        } else {
            $field_to_check = 'num';
        }
        foreach ($districts as $district) {
            if (round($quantity * $district['T72District']['population_percent']) < 1 ||
            	$quantity * $district['T72District']['population_percent'] * $quantity_list > $district['T72District'][$field_to_check]) {
            	$result = 'false';
                break;
            }
        }

        echo $result;
        exit;
    }*/
}