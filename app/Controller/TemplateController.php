<?php
App::uses('AppController', 'Controller');

class TemplateController extends AppController {
	var $name = 'Template';
    var $uses = Array(
        'M02Company',
        'M90PulldownCode',
        'T30Template',
        'T31TemplateQuestion',
        'T32TemplateButton',
        'T89ManageFile',
        'M04ControllerAction',
        'T20OutSchedule',
        'T33QuestionAudio',
        'T92Lock',
        'T12ListItem',
        'M08SmsApiInfo',
    );

	const IMPORT_QUESTION_QUANTITY_LIMIT = 41;

	function index($mode=null, $del_count=null) { /*20160311 Edit by Giang : #6695 - display the record quantity has been deleted*/
		$this->set("mode", $mode);

		if($mode == "delete"){
			$sortColumn = $this->ESession->getSortColumn($this);
			$sortType = $this->ESession->getSortType($this);
			$page = $this->ESession->getPage($this);
			$this->set("sortColumn", $sortColumn);
			$this->set("sortType", $sortType);
			$this->set("page", $page);
			$this->set('del_count', $del_count);  /*20160311 Add by Giang : #6695 - display the record quantity has been deleted*/
		}
		$post_code = $this->ESession->getUserPostCode($this);

		$create_flag = $this->M04ControllerAction->check_permission($post_code, 'Template', 'create');
		$import_flag = $this->M04ControllerAction->check_permission($post_code, 'Template', 'import');
		$delete_flag = $this->M04ControllerAction->check_permission($post_code, 'Template', 'delete');

		$download_flag = $this->M04ControllerAction->check_permission($post_code, 'Template', 'export');

		$this->set("create_flag", $create_flag);
		$this->set("import_flag", $import_flag);
		$this->set("delete_flag", $delete_flag);
	}

	function arr_template($js_page, $limit, $column) {
		$this->layout = 'ajax';
		$filter = $_GET["filter"];
		$page = $js_page + 1;
		$json_data = Array();
		$json_data["headers"] = Array("NO","名称","説明","作成日時","作成者","アクション");

		$json_data["rows"] = Array();
		$company_id = $this->ESession->getUserCompanyId($this);
		$post_code = $this->ESession->getUserPostCode($this);

		$duplicate_flag = $this->M04ControllerAction->check_permission($post_code, 'Template', 'create');
		$download_flag = $this->M04ControllerAction->check_permission($post_code, 'Template', 'export');
		$delete_flag = $this->M04ControllerAction->check_permission($post_code, 'Template', 'delete');
		if ($delete_flag) {
			array_unshift($json_data["headers"], "cb");
		}
		else {
			$keyArr = array();
			if ($filter != null) {
				while (current($filter)) {
					$keyArr[] = key($filter) + 1;
					next($filter);
				}
				$filter = array_combine($keyArr, array_values($filter));
			}
		}

		if(isset($column) && !empty($column) && $column != "column") {
			$sort_order = $this->Util->getTemplateSortOrder($column, $delete_flag ? 1 : 0);
		}
		if(isset($sort_order[0])){
			$arr_templates = $this->T30Template->getTemplateByCompanyId($company_id, TEMPLATE_OUTBOUND, $limit, $page, $sort_order[0], $filter);
		}else{
			$arr_templates = $this->T30Template->getTemplateByCompanyId($company_id, TEMPLATE_OUTBOUND, $limit, $page, null, $filter);
		}
		$json_data["total_rows"] = $this->T30Template->getTemplateByCompanyIdCount($company_id, TEMPLATE_OUTBOUND, $filter);
		foreach ($arr_templates as $arr_template) {
			$json_row = array();
			$i = 0;
			if ($delete_flag) {
				$json_row[$json_data["headers"][$i++]] = '<input type="checkbox" name="cbSelect[' . $arr_template['T30Template']['id'] . ']" id="cbSelect[' . $arr_template['T30Template']['id'] . ']" template_id="' . $arr_template['T30Template']['id'] . '">'
					. '<label for="cbSelect[' . $arr_template['T30Template']['id'] . ']" style="margin-top: 2px;"></label>';
			}
			$json_row[$json_data["headers"][$i++]] = $arr_template['T30Template']['template_no'];
			$json_row[$json_data["headers"][$i++]] = $arr_template['T30Template']['template_name'];
			$json_row[$json_data["headers"][$i++]] = $arr_template['T30Template']['description'] ? $arr_template['T30Template']['description'] : '';
			$json_row[$json_data["headers"][$i++]] = $arr_template['T30Template']['created'] ? date('Y-m-d H:i', strtotime($arr_template['T30Template']['created'])) : '';
			$json_row[$json_data["headers"][$i++]] = $arr_template['M05User']['user_name'] ? $arr_template['M05User']['user_name'] : '';

			$str_btn_func = '';
			$str_btn_func .= '<div class="iconFormat"><a href="javascript:void(0);" class="lnkEdit btnEdit" template_id="'.$arr_template['T30Template']['id'].'"><i title="編集" data-toggle="tooltip" class="glyphicon glyphicon-edit icon-white" ></i></a></div>';
			if ($duplicate_flag){
				$str_btn_func .= '<div class="iconFormat"><a href="javascript:void(0);" class="btnDuplicate" template_id="'.$arr_template['T30Template']['id'].'"><i title="複製" data-toggle="tooltip" class="glyphicon glyphicon-duplicate icon-white" ></i></a></div>';
			}
			if ($download_flag){
				$str_btn_func .= '<div class="iconFormat"><a href="javascript:void(0);" class="btnDownload" template_id="'.$arr_template['T30Template']['id'].'"><i title="エクスポート" data-toggle="tooltip" class="glyphicon glyphicon-export icon-white" ></i></a></div>';
			}
			$json_row[$json_data["headers"][$i++]] = $str_btn_func;
			$json_data["rows"][] = (object) $json_row;
		}
		$json_string = json_encode($json_data);
		echo $json_string;
		if(isset($sort_order)){
			$this->ESession->setSortColumn($sort_order[1], $this);
			$this->ESession->setSortType($sort_order[2], $this);
		}
		$this->ESession->setPage($js_page, $this);
		exit;
	}

	function delete() {
		$data = $this->data;
		if (empty($data)) {
			$this->redirect(array('controller' => 'Template', 'action' => 'index'));
		}

		$dsT30Template = $this->T30Template->getDataSource();
		$dsT31TemplateQuestion = $this->T31TemplateQuestion->getDataSource();
		$dsT32TemplateButton = $this->T32TemplateButton->getDataSource();

		$dsT30Template->begin($this);
		$dsT31TemplateQuestion->begin($this);
		$dsT32TemplateButton->begin($this);

		$template_ids = $data['template_ids'];
		$update_user = $this->ESession->getUserId($this);
		$update_program = $this->name.'_'.__FUNCTION__;
		$time = date('Y-m-d H:i:s a', time());

		foreach ($template_ids as $id) {
			$arr_template_info = $this->T30Template->getInfoTemplateById($id);
			$arr_template_info['T30Template']['del_flag'] = "Y";
			$arr_template_info["T30Template"]["update_user"] = $update_user;
			$arr_template_info["T30Template"]["update_program"] = $update_program;
			$arr_template_info["T30Template"]["modified"] = $time;

			$template_id = $arr_template_info['T30Template']['id'];

			if (!$this->T30Template->save($arr_template_info)) {
				$dsT30Template->rollback($this);
				$dsT31TemplateQuestion->rollback($this);
				$dsT32TemplateButton->rollback($this);
				$this->log("スケジュール削除：失敗");
				$this->redirect(array('controller' => 'Login', 'action' => 'index/systemerror'));
			}

			if ($this->T31TemplateQuestion->countQuesByTemplateId($template_id) > 0)
			{
				$query_question = "UPDATE t31_template_questions SET del_flag='Y', update_user='"
					. $update_user . "',update_program='" . $update_program
					. "', modified='" . $time . "' WHERE del_flag = 'N' AND template_id='" . $template_id . "';";

				if ($this->T31TemplateQuestion->query($query_question)) {
					$dsT30Template->rollback($this);
					$dsT31TemplateQuestion->rollback($this);
					$dsT32TemplateButton->rollback($this);
					$this->log("スケジュール削除：失敗");
					$this->redirect(array('controller' => 'Login', 'action' => 'index/systemerror'));
				}
			}

			if ($this->T32TemplateButton->countInfoAnswByTemplateId($template_id) > 0)
			{
				$query_button = "UPDATE t32_template_buttons SET del_flag='Y', update_user='"
					. $update_user . "',update_program='" . $update_program
					. "', modified='" . $time . "' WHERE del_flag = 'N' AND template_id='" . $template_id . "';";

				if ($this->T32TemplateButton->query($query_button)) {
					$dsT30Template->rollback($this);
					$dsT31TemplateQuestion->rollback($this);
					$dsT32TemplateButton->rollback($this);
					$this->log("スケジュール削除：失敗");
					$this->redirect(array('controller' => 'Login', 'action' => 'index/systemerror'));
				}
			}
		}
		$dsT30Template->commit($this);
		$dsT31TemplateQuestion->commit($this);
		$dsT32TemplateButton->commit($this);

		$this->redirect(array('controller' => 'Template', 'action' => 'index/delete/' . count($template_ids))); /*20160311 Edit by Giang : #6695 - display the record quantity has been deleted*/
	}

	function template($template_id=null) {
		$data = $this->data;
		$jsObjectkey = array();
		$post_code = $this->ESession->getUserPostCode($this);
		$permission_flag = $this->M04ControllerAction->check_permission($post_code, "Template", "edit");
		$this->set('permission_flag', $permission_flag);
		if (isset($data) && !empty($data)) {
			$template_id = $data["template_id"];
			$action = $data["action"];
			$arr_template = $this->T30Template->getInfoTemplateById($template_id);
			$arr_ques = $this->T31TemplateQuestion->getQuesByTemplateId($template_id);
			$arr_answ = array();
			foreach ($arr_ques as $ques) {
				$quesArr = array(
					"question_no" => $ques["T31TemplateQuestion"]["question_no"],
					"question_type" => $ques["T31TemplateQuestion"]["question_type"],
					"question_type_txt" => $this->get_question_type($ques["T31TemplateQuestion"]["question_type"]),
					"question_title" => $ques["T31TemplateQuestion"]["question_title"],
					"question_yuko" => $ques["T31TemplateQuestion"]["question_yuko"],
					"jump_question" => $ques["T31TemplateQuestion"]["jump_question"],
					"audio_id" => $ques["T31TemplateQuestion"]["audio_id"],
					"audio_name" => $ques["T31TemplateQuestion"]["audio_name"],
					"audio_type" => $ques["T31TemplateQuestion"]["audio_type"],
					"audio_content" => $ques["T31TemplateQuestion"]["audio_content"],
					"question_repeat" => $ques["T31TemplateQuestion"]["question_repeat"],
					"auth_item" => $ques["T31TemplateQuestion"]["auth_item"],
					"auth_item_name" => $ques["T31TemplateQuestion"]["auth_item"],
					"second_record" => $ques["T31TemplateQuestion"]["second_record"],
					"yuko_button_record" => $ques["T31TemplateQuestion"]["yuko_button_record"],
					"trans_tel" => $ques["T31TemplateQuestion"]["trans_tel"],
					"trans_seat_num" => $ques["T31TemplateQuestion"]["trans_seat_num"],
					"trans_empty_seat_flag" => $ques["T31TemplateQuestion"]["trans_empty_seat_flag"],
					"trans_audio_id" => $ques["T31TemplateQuestion"]["audio_id"],
					"trans_audio_name" => $ques["T31TemplateQuestion"]["audio_name"],
					"trans_audio_type" => $ques["T31TemplateQuestion"]["audio_type"],
					"trans_audio_content" => $ques["T31TemplateQuestion"]["audio_content"],
					"trans_timeout_audio_id" => $ques["T31TemplateQuestion"]["trans_timeout_audio_id"],
					"trans_timeout_audio_name" => $ques["T31TemplateQuestion"]["trans_timeout_audio_name"],
					"trans_timeout_audio_type" => $ques["T31TemplateQuestion"]["trans_timeout_audio_type"],
					"trans_timeout_audio_content" => $ques["T31TemplateQuestion"]["trans_timeout_audio_content"],
					"trans_timeout" => $ques["T31TemplateQuestion"]["trans_timeout"],
					"recheck_flag" => $ques["T31TemplateQuestion"]["recheck_flag"],
					"recheck_audio_id" => $ques["T31TemplateQuestion"]["recheck_audio_id"],
					"recheck_audio_name" => $ques["T31TemplateQuestion"]["recheck_audio_name"],
					"recheck_audio_type" => $ques["T31TemplateQuestion"]["recheck_audio_type"],
					"recheck_audio_content" => $ques["T31TemplateQuestion"]["recheck_audio_content"],
					"recheck_button_next" => $ques["T31TemplateQuestion"]["recheck_button_next"],
					"digit_auth" => $ques["T31TemplateQuestion"]["digit"],
					"digit_tel" => $ques["T31TemplateQuestion"]["digit"],
                    "smsPhoneNumber" => $ques["T31TemplateQuestion"]["sms_display_number"],
                    "smsBodyContent" => $ques["T31TemplateQuestion"]["sms_content"],
					"sms_use_short_url" => $ques["T31TemplateQuestion"]["yuko_button_record"],
					"trans_phone_number_play_flag" => $ques["T31TemplateQuestion"]["yuko_button_record"],

					"ques_sms_audio_type" => $ques["T31TemplateQuestion"]["sms_error_audio_type"],
					"ques_sms_audio_name" => $ques["T31TemplateQuestion"]["sms_error_audio_name"],
					"ques_sms_audio_id" => $ques["T31TemplateQuestion"]["sms_error_audio_id"],
					"ques_sms_audio_content" => $ques["T31TemplateQuestion"]["sms_error_audio_content"],

					"ques_sms_input_audio_type" => $ques["T31TemplateQuestion"]["sms_error_audio_type"],
					"ques_sms_input_audio_name" => $ques["T31TemplateQuestion"]["sms_error_audio_name"],
					"ques_sms_input_audio_id" => $ques["T31TemplateQuestion"]["sms_error_audio_id"],
					"ques_sms_input_audio_content" => $ques["T31TemplateQuestion"]["sms_error_audio_content"],
					//番号指定SMS
					//通知番号SMSと同じ値をセットする。
					"smsInputPhoneNumber" => $ques["T31TemplateQuestion"]["sms_display_number"],
					"smsInputBodyContent" => $ques["T31TemplateQuestion"]["sms_content"],
					"sms_input_use_short_url" => $ques["T31TemplateQuestion"]["yuko_button_record"],
				);
				if($action == "update"){
					$quesArr["id"] = $ques["T31TemplateQuestion"]["id"];
				}
				$answArr = array();
				$arr_answ_tmp = $this->T32TemplateButton->getAnwsByQuestionNo($template_id, $ques["T31TemplateQuestion"]["question_no"]);
				foreach ($arr_answ_tmp as $answ) {
					$answ_no = $answ["T32TemplateButton"]["answer_no"];
					if($ques["T31TemplateQuestion"]["question_type"] == QUESTION_AUTH){
						if($action == "update"){
							$answArr["hdAnswId".$answ_no] = $answ["T32TemplateButton"]["id"];
						}
						if(!empty($answ["T32TemplateButton"]["yuko_flag"])){
							$answArr["cbYukoAnswAuth".$answ_no] = $answ["T32TemplateButton"]["yuko_flag"];
						}
						$answArr["txtAnswContentAuth".$answ_no] = $answ["T32TemplateButton"]["answer_content"];
						$answArr["txtAnswJumpAuth".$answ_no] = $answ["T32TemplateButton"]["jump_question"];
						//20160420 Add by Thai : #6722 ADD QUESTION_AUTH_CHAR - Begin
					}else if($ques["T31TemplateQuestion"]["question_type"] == QUESTION_AUTH_CHAR){
						if($action == "update"){
							$answArr["hdAnswId".$answ_no] = $answ["T32TemplateButton"]["id"];
						}
						if(!empty($answ["T32TemplateButton"]["yuko_flag"])){
							$answArr["cbYukoAnswAuthChar".$answ_no] = $answ["T32TemplateButton"]["yuko_flag"];
						}
						$answArr["txtAnswContentAuthChar".$answ_no] = $answ["T32TemplateButton"]["answer_content"];
						$answArr["txtAnswJumpAuthChar".$answ_no] = $answ["T32TemplateButton"]["jump_question"];
						//20160420 Add by Thai : #6722 ADD QUESTION_AUTH_CHAR - End
					}else if($ques["T31TemplateQuestion"]["question_type"] == QUESTION_BASIC){
						if($action == "update"){
							$answArr["hdAnswId".$answ_no] = $answ["T32TemplateButton"]["id"];
						}
						if(!empty($answ["T32TemplateButton"]["yuko_flag"])){
							$answArr["cbYukoAnsw".$answ_no] = $answ["T32TemplateButton"]["yuko_flag"];
						}
						$answArr["txtAnswContent".$answ_no] = $answ["T32TemplateButton"]["answer_content"];
						$answArr["txtAnswJump".$answ_no] = $answ["T32TemplateButton"]["jump_question"];
					}else if($ques["T31TemplateQuestion"]["question_type"] == QUESTION_TRANS){
						if($action == "update"){
							$answArr["hdAnswId"] = $answ["T32TemplateButton"]["id"];
						}
						$answArr["txtAnswTrans"] = $answ_no;
						//20160304 Add by Thai : ADD jump_question for timeout of QUESTION_TEL - Begin
					}else if($ques["T31TemplateQuestion"]["question_type"] == QUESTION_TEL){
						if($action == "update"){
							$answArr["hdAnswId".$answ_no] = $answ["T32TemplateButton"]["id"];
						}
						$answArr["txtAnswJumpTel".$answ_no] = $answ["T32TemplateButton"]["jump_question"];
						//20160304 Add by Thai : ADD jump_question for timeout of QUESTION_TEL - End
					} else if ($ques["T31TemplateQuestion"]["question_type"] == QUESTION_SMS) {
						if ($action == "update") {
							$answArr["hdAnswId" . $answ_no] = $answ["T32TemplateButton"]["id"];
						}
						//送信不可の飛び先 (question_no = 99)
						$answArr["txtAnswJumpSms" . $answ_no] = $answ["T32TemplateButton"]["jump_question"];
					} else if ($ques["T31TemplateQuestion"]["question_type"] == QUESTION_SMS_INPUT) {
						if ($action == "update") {
							$answArr["hdAnswId" . $answ_no] = $answ["T32TemplateButton"]["id"];
						}

						if ($answ_no == 98) {
							//タイムアウトの飛び先(question_no = 98)
							$answArr["txtAnswJumpSmsInputTimeOut" . $answ_no] = $answ["T32TemplateButton"]["jump_question"];
						} else {
							//送信不可の飛び先 (question_no = 99)
							$answArr["txtAnswJumpSmsInput" . $answ_no] = $answ["T32TemplateButton"]["jump_question"];
						}
					}
				}
				if (!empty($answArr)){
					$quesArr = array_merge($quesArr, $answArr);
					$arr_answ[$ques["T31TemplateQuestion"]["question_no"]] = $arr_answ_tmp;
				}
				$jsObjectkey[$ques["T31TemplateQuestion"]["question_no"]] = $quesArr;
			}
			if($action == "update"){
				$info_schedules = $this->T20OutSchedule->getScheduleNotFinishByTemplateId($template_id);
				if (isset($info_schedules["T20OutSchedule"]["id"]) && !empty($info_schedules["T20OutSchedule"]["id"])) {
					$this->set('exist_schedule', true);
				}
			}
			$this->set("template_id", $template_id);
			$this->set("template_name", $arr_template["T30Template"]["template_name"]);
			$this->set("description", $arr_template["T30Template"]["description"]);
			$this->set('ques_info', $jsObjectkey);
			$this->set('jsObjectkey', json_encode($jsObjectkey));
			$this->set("arr_answ", $arr_answ);
			$this->set("action", $action);
			$this->set("post_code", $post_code);
		}else{
			$this->set("action", "insert");
		}
        $company_id = $this->ESession->getUserCompanyId($this);
		$arr_company_info = $this->M02Company->getCompanyByCompanyId($company_id);
		// アウトバウンド。第二引数に表示したくないプルダウンのコードを与えると、
		// アウトバウンドのセクションの種類プルダウンに表示されない。
		$ques_type = $this->M90PulldownCode->getSelectOption("template_ques", array(QUESTION_PROPERTY, QUESTION_FAX, QUESTION_PROPERTY_SEARCH, QUESTION_INBOUND_SMS, QUESTION_INBOUND_COLLATION, QUESTION_INBOUND_SMS_INPUT));
		$audio_mix_flag = $arr_company_info["M02Company"]["audio_mix_flag"];
		$audio_mix_item = $this->T12ListItem->getListItemNameByCompany($company_id);
		$auth_item = $this->T12ListItem->getListItemNameByCompany($company_id);
		$question_repeat = $this->M90PulldownCode->getSelectOption("question_repeat");
		$answer_no = $this->M90PulldownCode->getSelectOption("answer_no");
        $phoneNotifyList = $this->M08SmsApiInfo->getServiceIdByCompanyId($company_id);
		$this->set('ques_types', $ques_type);
		$this->set('audio_mix_flag', $audio_mix_flag);
		$this->set('audio_mix_item', $audio_mix_item);
		$this->set('auth_item', $auth_item);
		$this->set('question_repeat', $question_repeat);
		$this->set('answer_no', $answer_no);
        $this->set('phoneNotifyList', $phoneNotifyList);
	}

	function check_file_import($zip) {
		$import_flag = true;
		$message_error = "";
		$file_text = 0;
		$filenameArr = array();
		$file_text_name = '';

		if ($zip->numFiles) {
			for ($i = 0; $i < $zip->numFiles; $i++) {
				$allowed =  array('wav', 'csv', 'txt');
				$filename = explode('.', $zip->getNameIndex($i));
				$ext = end($filename);

				if (!in_array($ext, $allowed)) {
					$import_flag = false;
					$message_error .= "ファイルアップ形式が正しくありません.<br>";
					break;
				}
				if (in_array($zip->getNameIndex($i), $filenameArr)) {
					$import_flag = false;
					$message_error .= "複数ファイル名がアップされました。<br>";
					break;
				}

				$filenameArr[$i] = $zip->getNameIndex($i);
				if ($ext == 'csv' || $ext == 'txt') {
					++$file_text;
					$file_text_name = $filenameArr[$i];
				}
			}

			if ($file_text > 1) {
				$import_flag = false;
				$message_error .= "TXTもしくはCSVファイルは1以上がアップされました。<br>";
			} else if ($file_text == 0) {
				$import_flag = false;
				$message_error .= "TXTもしくはCSVファイルはアップしてください。<br>";
			}
		} else {
			$import_flag = false;
			$message_error .= "TXTもしくはCSVファイルはアップしてください。<br>";
		}

		$result = Array('filenameArr' => $filenameArr, 'message_error' => $message_error, 'import_flag' => $import_flag, 'file_text_name' => $file_text_name);
		return $result;
	}

	function check_file_csv($csv, $company_id) {
		$import_flag = true;
		$message_error = "";
		$template_name = '';
		$description = '';

		if (count($csv) > $this::IMPORT_QUESTION_QUANTITY_LIMIT) {
			$import_flag = false;
			$message_error .= "テンプレートの質問数が" . (string)($this::IMPORT_QUESTION_QUANTITY_LIMIT - 1) . "を超えています。<br>";
		}

		$template = array_shift($csv);
		$template = mb_convert_encoding($template, "UTF-8", "SJIS");
		$t30Template = explode("|", $template);
		if (count($t30Template) != 2) {
			$import_flag = false;
			$message_error .= "入力形式が正しくありません。<br>";
		} else {
			$info_template = $this->T30Template->getTemplateByTemplateName($t30Template[0], $company_id, TEMPLATE_OUTBOUND);
			if(isset($info_template["T30Template"]["id"]) && !empty($info_template["T30Template"]["id"])){
				$import_flag = false;
				$message_error .= "指定したテンプレート名は既に使用されています。<br>";
			} else {
				$template_name = trim(preg_replace('/\s\s+/', ' ', $t30Template[0]));
				$description = trim(preg_replace('/\s\s+/', ' ', $t30Template[1]));
			}
		}

		$result = Array('message_error' => $message_error, 'import_flag' => $import_flag, 'template_name' => $template_name, 'description' => $description, 'csv' => $csv);
		return $result;
	}

	function import() {
		if($this->request->is('post')){
			$zip = new ZipArchive();
			$zip_file_tmp = $_FILES['files']['tmp_name'];
			$zip->open($zip_file_tmp);
			$this->layout = false;

			$user_id = $this->ESession->getUserId($this);
			$company_id = $this->ESession->getUserCompanyId($this);
			$info_company = $this->M02Company->getCompanyByCompanyId($this->ESession->getUserCompanyId($this));
			$audio_mix_flag = $info_company["M02Company"]["audio_mix_flag"];
			$staArr = array(
				'code' => 200,
				'status'=>'success',
				'message' => '保存しました。',
				'count_file' => $zip->numFiles
			);
			$template_id = 0;

			$zip_array = $this->check_file_import($zip);
			$filenameArr = $zip_array['filenameArr'];
			$import_flag = $zip_array['import_flag'];
			$message_error = $zip_array['message_error'];
			$file_text_name = $zip_array['file_text_name'];

			// Show error import template
			if (!$import_flag) {
				$staArr = array(
					'code' => 501,
					'status'=>'failed',
					'message' => $message_error,
				);
				header('Content-type: text/json');
				header('Content-type: application/json');
				echo json_encode($staArr);
				exit;
			}

			$fileArray = array();

			$csv = array();
			$fp = $zip->getStream($file_text_name);
			while(!feof($fp)) {
			  $csv[] = fgets($fp);
			}

			$file_csv = $this->check_file_csv($csv, $company_id);
			$csv = $file_csv['csv'];
			if (!$file_csv['import_flag']) {
				$staArr = array(
					'code' => 501,
					'status'=>'failed',
					'message' => $file_csv['message_error'],
				);
				header('Content-type: text/json');
				header('Content-type: application/json');
				echo json_encode($staArr);
				exit;
			}

			$template = array();
			$template["T30Template"]["template_name"] = $file_csv['template_name'];
			$template["T30Template"]["template_type"] = TEMPLATE_OUTBOUND;
			$template["T30Template"]["description"] = $file_csv['description'];
			$template["T30Template"]["company_id"] = $company_id;
			$template["T30Template"]["entry_user"] = $user_id;
			$template["T30Template"]["entry_program"] = 'Template_import';
			$template["T30Template"]["update_user"] = $user_id;
			$template["T30Template"]["update_program"] = 'Template_import';

			if (!empty($template)) {
				$max_template_no = $this->T30Template->getMaxTemplateNoByCompanyId($company_id, TEMPLATE_OUTBOUND);
				$this->T30Template->create($template);
				if ($max_template_no) {
					$template["T30Template"]["template_no"] = $max_template_no["T30Template"]["template_no"] + 1;
				}
				else {
					$template["T30Template"]["template_no"] = 1;
				}
// 				$import_flag = $this->T30Template->save($template);
// 				$template_id = $this->T30Template->getLastInsertId();
			}

			$templateQuestions = array();
			$templateButtons = array();

			$line = 1;
			$ques_type_5 = 0;
			$ques_type_6 = 0;
			$ques_type_9 = 0;
			$lastQuestionCutting = false;

			$arr_auth_item_name = array();
			$info_auth_item = $this->T12ListItem->getListItemNameByCompany($this->ESession->getUserCompanyId($this));
			foreach ($info_auth_item as $arr){
				$arr_auth_item_name[$arr["T12ListItem"]["item_name"]] = $arr["T12ListItem"]["item_name"];
			}
			//20160226 Add by Thai : #6519 - Update format csv upload format - Begin
			$arr_ques_nos = array();
			foreach ($csv as $value) {
				$value_convert = mb_convert_encoding($value, "UTF-8", "SJIS");
				$templateValue = explode("|", $value_convert);
				if (isset($templateValue[1]) && $templateValue[1] != QUESTION_TIMEOUT) {
					$arr_ques_nos[] = $templateValue[0];
				}
			}
			//20160226 Add by Thai : #6519 - Update format csv upload format - End
			foreach ($csv as $value) {
				$line_error = "";
				$lastQuestionCutting = false;
				$value_convert = mb_convert_encoding($value, "UTF-8", "SJIS");
				$templateValue = explode("|", $value_convert);
				if ($templateValue[0] != $line) {
					$import_flag = false;
					$line_error .= "質問NOが正しくありません, ";
				}
                if($templateValue[1] == QUESTION_SMS){
                    $import_flag = false;
                    // $arr_message_error[++$line] = '質問の入力形式が正しくありません。';
                    $line_error .= "質問の入力形式が正しくありません。";
					++$line;
					$message_error .= $line."行目: ".$line_error."<br>";
                    continue;
                }
                if($templateValue[1] == QUESTION_SMS_INPUT){
                    $import_flag = false;
                    $line_error .= "質問の入力形式が正しくありません。";
                    ++$line;
                    $message_error .= $line."行目: ".$line_error."<br>";
                    continue;
                }
				if (!in_array($templateValue[1], array(QUESTION_VOICE, QUESTION_BASIC, QUESTION_AUTH, QUESTION_TEL, QUESTION_TRANS, QUESTION_RECORD, QUESTION_COUNT, QUESTION_END, QUESTION_TIMEOUT,  QUESTION_AUTH_CHAR))) {
					$import_flag = false;
					$line_error .= "質問種類が正しくありません, ";
					++$line;
					$message_error .= $line."行目: ".$line_error."<br>";
					continue;
				}
				$templateQuestion = array();
				$templateButton = array();
				$templateValue[2] = trim(preg_replace('/\s\s+/', ' ', $templateValue[2]));
				$templateQuestion["T31TemplateQuestion"]["question_no"] = $templateValue[0];
				$templateQuestion["T31TemplateQuestion"]["question_type"] = $templateValue[1];
				$templateQuestion["T31TemplateQuestion"]["question_title"] = $templateValue[2];
				$templateQuestion["T31TemplateQuestion"]["entry_user"] = $user_id;
				$templateQuestion["T31TemplateQuestion"]["entry_program"] = 'Template_import';
				$templateQuestion["T31TemplateQuestion"]["update_user"] = $user_id;
				$templateQuestion["T31TemplateQuestion"]["update_program"] = 'Template_import';

				if ($templateValue[1] == QUESTION_VOICE) {
					if (count($templateValue) != 7) {
						$import_flag = false;
						++$line;
						$message_error .= $line."行目: 質問の入力形式が正しくありません,<br>";
						continue;
					}
					//20160229 Add by Thai : #6519 - Update format csv upload format - Begin
					if ($templateValue[3] == '' || !in_array($templateValue[3], $arr_ques_nos)) {
						$import_flag = false;
						$line_error .= "飛び先は正しくありません, ";
					} else {
						$templateQuestion["T31TemplateQuestion"]["jump_question"] = $templateValue[3];
					}
					//20160229 Add by Thai : #6519 - Update format csv upload format - End
					if (($templateValue[4] != 0 && $templateValue[4] != 1 && $templateValue[4] != 2) || ($audio_mix_flag == 0 && ($templateValue[4] == 1 || $templateValue[4] == 2))){
						$import_flag = false;
						$line_error .= "音声種類が正しくありません, ";
					} else {
						$templateQuestion["T31TemplateQuestion"]["audio_type"] = $templateValue[4];
						if (($templateValue[4] == 1 || $templateValue[4] == 2) && $templateValue[5] == '') {
							$import_flag = false;
							$line_error .= "音声内容を入力してください, ";
						} elseif ($templateValue[4] == 0 && $templateValue[6] == '') {
							$import_flag = false;
							$line_error .= "音声ファイルを選択してください, ";
						} else {
							$templateQuestion["T31TemplateQuestion"]["audio_content"] = $templateValue[5];
							$templateValue[6] = trim(preg_replace('/\s\s+/', ' ', $templateValue[6]));
							if ($templateValue[6]) {
								if (in_array($templateValue[6], $fileArray)) {
									$import_flag = false;
									$line_error .= "音声ファイル名重複があります, ";
								} elseif (!in_array($templateValue[6], $filenameArr)) {
									$import_flag = false;
									$line_error .= $templateValue[6]."音声ファイルを選択してください, ";
								} else {
									$fileArray[$templateValue[0]] = $templateValue[6];
									$file = $this->upload_file_wav($zip, $templateValue[6], $zip_file_tmp);
									if (!empty($file)) {
										$templateQuestion["T31TemplateQuestion"]["audio_id"] = $file["T89ManageFile"]["id"];
										$templateQuestion["T31TemplateQuestion"]["audio_name"] = preg_replace('/\\.[^.\\s]{3,4}$/', '', $templateValue[6]);
									} else {
										$line_error .= "音声ファイル名が正しくありません, ";
										$import_flag = false;
									}
								}
							}
						}
					}
				} else if ($templateValue[1] == QUESTION_TIMEOUT) {
					$lastQuestionCutting = true;
					$ques_type_9++;

					if (count($templateValue) != 6) {
						$import_flag = false;
						++$line;
						$message_error .= $line."行目: 質問の入力形式が正しくありません,<br>";
						continue;
					}
					if (($templateValue[3] != 0 && $templateValue[3] != 1 && $templateValue[3] != 2) || ($audio_mix_flag == 0 && ($templateValue[3] == 1 || $templateValue[3] == 2))){
						$import_flag = false;
						$line_error .= "音声種類が正しくありません, ";
					} else {
						$templateQuestion["T31TemplateQuestion"]["audio_type"] = $templateValue[3];
						if (($templateValue[3] == 1 || $templateValue[3] == 2) && $templateValue[4] == '') {
							$import_flag = false;
							$line_error .= "音声内容を入力してください, ";
						} elseif ($templateValue[3] == 0 && $templateValue[5] == '') {
							$import_flag = false;
							$line_error .= "音声ファイルを選択してください, ";
						} else {
							$templateQuestion["T31TemplateQuestion"]["audio_content"] = $templateValue[4];
							$templateValue[5] = trim(preg_replace('/\s\s+/', ' ', $templateValue[5]));
							if ($templateValue[5]) {
								if (in_array($templateValue[5], $fileArray)) {
									$import_flag = false;
									$line_error .= "音声ファイル名重複があります, ";
								} elseif (!in_array($templateValue[5], $filenameArr)) {
									$import_flag = false;
									$line_error .= $templateValue[5]."音声ファイルを選択してください, ";
								} else {
									$fileArray[$templateValue[0]] = $templateValue[5];
									$file = $this->upload_file_wav($zip, $templateValue[5], $zip_file_tmp);
									if (!empty($file)) {
										$templateQuestion["T31TemplateQuestion"]["audio_id"] = $file["T89ManageFile"]["id"];
										$templateQuestion["T31TemplateQuestion"]["audio_name"] = preg_replace('/\\.[^.\\s]{3,4}$/', '', $templateValue[5]);
									} else {
										$line_error .= "音声ファイル名が正しくありません, ";
										$import_flag = false;
									}
								}
							}
						}
					}
				} else if ($templateValue[1] == QUESTION_BASIC) {
// 					if (count($templateValue) < 16 || count($templateValue) > 60) {
// 						$import_flag = false;
// 						++$line;
// 						$message_error .= $line."行目: 質問の入力形式が正しくありません,<br>";
// 						continue;
// 					}

					if (($templateValue[3] != 0 && $templateValue[3] != 1)) {
						$import_flag = false;
						$line_error .= "有効質問が正しくありません, ";
					} else {
						$templateQuestion["T31TemplateQuestion"]["question_yuko"] = $templateValue[3];
					}
					//20160226 Add by Thai : #6519 - Update format csv upload format - Begin
					if ($templateValue[4] != '' && !in_array($templateValue[4], $arr_ques_nos)) {
						$import_flag = false;
						$line_error .= "飛び先は正しくありません, ";
					} else {
						$templateQuestion["T31TemplateQuestion"]["jump_question"] = $templateValue[4];
					}
					//20160226 Add by Thai : #6519 - Update format csv upload format - End
					if (($templateValue[5] != 0 && $templateValue[5] != 1 && $templateValue[5] != 2) || ($audio_mix_flag == 0 && ($templateValue[5] == 1 || $templateValue[5] == 2))) {
						$import_flag = false;
						$line_error .= "音声種類が正しくありません, ";
					} else {
						$templateQuestion["T31TemplateQuestion"]["audio_type"] = $templateValue[5];
						if (($templateValue[5] == 1 || $templateValue[5] == 2) && $templateValue[6] == '') {
							$import_flag = false;
							$line_error .= "音声内容を入力してください, ";
						} elseif ($templateValue[5] == 0 && $templateValue[7] == '') {
							$import_flag = false;
							$line_error .= "音声ファイルを選択してください, ";
						} else {
							$templateQuestion["T31TemplateQuestion"]["audio_content"] = trim($templateValue[6]);
							$templateValue[7] = trim(preg_replace('/\s\s+/', ' ', $templateValue[7]));
							if ($templateValue[7]) {
								if (in_array($templateValue[7], $fileArray)) {
									$import_flag = false;
									$line_error .= "音声ファイル名重複があります, ";
								} elseif (!in_array($templateValue[7], $filenameArr)) {
									$import_flag = false;
									$line_error .= "Missing audio file ".$templateValue[7].", ";
								} else {
									$fileArray[$templateValue[0]] = $templateValue[7];
									$file = $this->upload_file_wav($zip, $templateValue[7], $zip_file_tmp);
									if (!empty($file)) {
										$templateQuestion["T31TemplateQuestion"]["audio_id"] = $file["T89ManageFile"]["id"];
										$templateQuestion["T31TemplateQuestion"]["audio_name"] = preg_replace('/\\.[^.\\s]{3,4}$/', '', $templateValue[7]);
									} else {
										$line_error .= "音声ファイル名が正しくありません, ";
										$import_flag = false;
									}
								}
							}
						}
					}
					$templateQuestion["T31TemplateQuestion"]["question_repeat"] = $templateValue[8];
					$i = 9;
					$field_count = count($templateValue);
					$answer_no_arr = array(0=>0,1=>1,2=>2,3=>3,4=>4,5=>5,6=>6,7=>7,8=>8,9=>9,51=>51,52=>52,99=>99);
//					$yuko_flag = false;
					$arr_jumps = array();
					while ($i <= $field_count - 3) {
						$templateButton = array();
						$templateButton['T32TemplateButton']['template_id'] = $template_id;
						$templateButton["T32TemplateButton"]["question_no"] = $templateValue[0];
						$templateButton["T32TemplateButton"]["entry_user"] = $user_id;
						$templateButton["T32TemplateButton"]["entry_program"] = 'Template_import';
						$templateButton["T32TemplateButton"]["update_user"] = $user_id;
						$templateButton["T32TemplateButton"]["update_program"] = 'Template_import';

						if (in_array($templateValue[$i], $answer_no_arr)) {
							$templateButton['T32TemplateButton']['answer_no'] = $templateValue[$i];
							$answer_no = $templateValue[$i];
							//unset($answer_no_arr[$templateValue[$i]]);
						} else {
							$import_flag = false;
							$line_error .= "回答番号が正しくありません, ";
						}
/*						if ($templateValue[$i] == 99 && $templateValue[$i+2] == '') {
							$import_flag = false;
							$line_error .= "タイムアウト飛び先が正しくありません, ";
						}*/
						$i++;
						$templateButton['T32TemplateButton']['answer_content'] = $templateValue[$i++];
						//20160229 Delete by Thai : #6519 - Update format csv upload format - Begin
/*						if ($templateValue[$i] > count($fp) || !is_numeric($templateValue[$i]) && !empty($templateValue[$i])) {
							$import_flag = false;
							$line_error .= "飛び先が正しくありません, ";
						}*/
						//20160229 Delete by Thai : #6519 - Update format csv upload format - End
						//20160226 Add by Thai : #6519 - Update format csv upload format - Begin
						$jump_ques_tmp = trim(preg_replace('/\s\s+/', ' ', $templateValue[$i++]));
						if ($jump_ques_tmp != '' && (!in_array($jump_ques_tmp, $arr_ques_nos) || !is_numeric($jump_ques_tmp))) {
							$import_flag = false;
							if ($answer_no == 51) {
								$line_error .= "回答番号*飛び先が正しくありません, ";
							} elseif ($answer_no == 52) {
								$line_error .= "回答番号#飛び先が正しくありません, ";
							} else if ($answer_no == 99) {
								$line_error .= "タイムアウト飛び先が正しくありません, ";
							} else {
								$line_error .= "回答番号".$answer_no."飛び先が正しくありません, ";
							}
						} else {
							$templateButton['T32TemplateButton']['jump_question'] = $jump_ques_tmp;
							if ($answer_no != 99) {
								$arr_jumps[$answer_no] = $jump_ques_tmp;
							}
						}
						//20160226 Add by Thai : #6519 - Update format csv upload format - End
						if ($templateValue[$i-3] != 99) {
							$templateValue[$i] = trim(preg_replace('/\s\s+/', ' ', $templateValue[$i]));
							if ($templateValue[$i] != 0 && $templateValue[$i] != 1) {
								$import_flag = false;
								$line_error .= "有効フラグ値が正しくありません, ";
							}
							//20160229 Delete by Thai : #6519 - Remove check yuko_flag when upload template - Begin
/*							if ($templateValue[$i] == 1) {
								$yuko_flag = true;
							}*/
							//20160229 Delete by Thai : #6519 - Remove check yuko_flag when upload template - End

							$templateButton['T32TemplateButton']['yuko_flag'] = $templateValue[$i++];
						}
						$templateButtons[] = $templateButton;
					}
					//20160226 Add by Thai : #6519 - Update format csv upload format - Begin
					if (isset($templateQuestion["T31TemplateQuestion"]["jump_question"]) && $templateQuestion["T31TemplateQuestion"]["jump_question"] == '') {
						foreach($answer_no_arr as $answer_no) {
							if ($answer_no != 99 && (!isset($arr_jumps[$answer_no]) || !$arr_jumps[$answer_no])) {
								$import_flag = false;
								$line_error .= "他のの場合飛び先が正しくありません, ";
								break;
							}
						}
					}
					//20160226 Add by Thai : #6519 - Update format csv upload format - End
					//20160229 Delete by Thai : #6519 - Remove check yuko_flag when upload template - Begin
/*					if (!$yuko_flag) {
						$import_flag = false;
						$line_error .= "有効番号を入力してください, ";
					}*/
					//20160229 Delete by Thai : #6519 - Remove check yuko_flag when upload template - End
					if (isset($templateValue[$i])) {
						$import_flag = false;
						$line_error .= "質問の入力形式が正しくありません,";
					}
				} else if ($templateValue[1] == QUESTION_AUTH) { // Q.3
					//フォマットチェック
// 					if (count($templateValue) > 30 || count($templateValue) < 26) {
// 						$import_flag = false;
// 						++$line;
// 						$message_error .= $line."行目: 質問の入力形式が正しくありません,<br>";
// 						continue;
// 					}

					if (($templateValue[3] != 0 && $templateValue[3] != 1)) {
						$import_flag = false;
						$line_error .= "有効質問が正しくありません, ";
					} else {
						$templateQuestion["T31TemplateQuestion"]["question_yuko"] = $templateValue[3];
					}

					//20160226 Add by Thai : #6519 - Update format csv upload format - Begin
					if ($templateValue[4] != '' && !in_array($templateValue[4], $arr_ques_nos)) {
						$import_flag = false;
						$line_error .= "飛び先は正しくありません, ";
					} else {
						$templateQuestion["T31TemplateQuestion"]["jump_question"] = $templateValue[4];
					}
					//20160226 Add by Thai : #6519 - Update format csv upload format - End

					if (($templateValue[5] != 0 && $templateValue[5] != 1 && $templateValue[5] != 2) || ($audio_mix_flag == 0 && ($templateValue[5] == 1 || $templateValue[5] == 2))) {
						$import_flag = false;
						$line_error .= "音声種類が正しくありません, ";
					} else {
						$templateQuestion["T31TemplateQuestion"]["audio_type"] = $templateValue[5];
						if (($templateValue[5] == 1 || $templateValue[5] == 2) && empty($templateValue[6])) {
							$import_flag = false;
							$line_error .= "音声内容を入力してください, ";
						} elseif ($templateValue[5] == 0 && empty($templateValue[7])) {
							$import_flag = false;
							$line_error .= "音声ファイルを選択してください, ";
						} else {
							$templateQuestion["T31TemplateQuestion"]["audio_content"] = trim($templateValue[6]);
							$templateValue[7] = trim(preg_replace('/\s\s+/', ' ', $templateValue[7]));
							if ($templateValue[7]) {
								if (in_array($templateValue[7], $fileArray)) {
									$import_flag = false;
									$line_error .= "音声ファイル名重複があります, ";
								} elseif (!in_array($templateValue[7], $filenameArr)) {
									$import_flag = false;
									$line_error .= $templateValue[7]."音声ファイルを選択してください, ";
								} else {
									$fileArray[$templateValue[0]] = $templateValue[7];
									$file = $this->upload_file_wav($zip, $templateValue[7], $zip_file_tmp);
									if (!empty($file)) {
										$templateQuestion["T31TemplateQuestion"]["audio_id"] = $file["T89ManageFile"]["id"];
										$templateQuestion["T31TemplateQuestion"]["audio_name"] = preg_replace('/\\.[^.\\s]{3,4}$/', '', $templateValue[7]);
										$templateQuestion["T31TemplateQuestion"]["recheck_audio_id"] = $file["T89ManageFile"]["id"];
										if ($templateValue[28]) {
											$templateQuestion["T31TemplateQuestion"]["recheck_audio_name"] = trim(preg_replace('/\s\s+/', ' ', $templateValue[28]));
										}
									} else {
										$line_error .= "音声ファイル名が正しくありません, ";
										$import_flag = false;
									}
								}
							}
						}
					}
// 					if (!isset($arr_auth_item_name[$templateValue[7]])) {
// 						$import_flag = false;
// 						$line_error .= "認証項目の入力が正しくありません, ";
// 					} else {
// 						$templateQuestion['T31TemplateQuestion']['auth_item'] = $arr_auth_item_name[$templateValue[7]];
// 					}
					$templateQuestion['T31TemplateQuestion']['auth_item'] = $templateValue[8];
					$templateQuestion['T31TemplateQuestion']['digit'] = $templateValue[9];
					$i = 10;
					$field_count = count($templateValue);
					$answer_no_arr = array(1=>1, 2=>2, 3=>3, 99=>99);
//					$yuko_flag = false;
					$arr_jumps = array();
					while ($i <= $field_count - 8) {
						$templateButton = array();
// 						$templateButton['T32TemplateButton']['template_id'] = $template_id;
						$templateButton["T32TemplateButton"]["question_no"] = $templateValue[0];
						$templateButton["T32TemplateButton"]["entry_user"] = $user_id;
						$templateButton["T32TemplateButton"]["entry_program"] = 'Template_import';
						$templateButton["T32TemplateButton"]["update_user"] = $user_id;
						$templateButton["T32TemplateButton"]["update_program"] = 'Template_import';

						if (in_array($templateValue[$i], $answer_no_arr)) {
							$templateButton['T32TemplateButton']['answer_no'] = $templateValue[$i];
							$answer_no = $templateValue[$i];
							//unset($answer_no_arr[$templateValue[$i]]);
						} else {
							$import_flag = false;
							$line_error .= "回答番号が正しくありません, ";
						}
/*						if ($templateValue[$i] == 99 && $templateValue[$i+2] == '') {
							$import_flag = false;
							$line_error .= "タイムアウト飛び先が正しくありません, ";
						}*/
						$i++;
						$templateButton['T32TemplateButton']['answer_content'] = $templateValue[$i++];
/*						if ($templateValue[$i] > count($fp) || !is_numeric($templateValue[$i]) && !empty($templateValue[$i])) {
							$import_flag = false;
							$line_error .= "飛び先が正しくありません, ";
						}*/
						//20160226 Add by Thai : #6519 - Update format csv upload format - Begin
						$jump_ques_tmp = trim(preg_replace('/\s\s+/', ' ', $templateValue[$i++]));
						if ($jump_ques_tmp != '' && (!in_array($jump_ques_tmp, $arr_ques_nos) || !is_numeric($jump_ques_tmp))) {
							$import_flag = false;
							if ($answer_no == 99) {
								$line_error .= "タイムアウト飛び先が正しくありません, ";
							} else {
								$line_error .= "回答番号".$answer_no."飛び先が正しくありません, ";
							}
						} else {
							$templateButton['T32TemplateButton']['jump_question'] = $jump_ques_tmp;
							if ($answer_no != 99) {
								$arr_jumps[$answer_no] = $jump_ques_tmp;
							}
						}
						//20160226 Add by Thai : #6519 - Update format csv upload format - End
						//20160226 Edit by Thai : #6519 - Update format csv upload format - Begin
						if ($templateValue[$i-3] != 99) {
							$templateValue[$i] = trim(preg_replace('/\s\s+/', ' ', $templateValue[$i]));
							if ($templateValue[$i] != 0 && $templateValue[$i] != 1) {
								$import_flag = false;
								$line_error .= "有効フラグ値が正しくありません, ";
							}
							//20160229 Delete by Thai : #6519 - Remove check yuko_flag when upload template - Begin
/*							if ($templateValue[$i] == 1) {
								$yuko_flag = true;
							}*/
							//20160229 Delete by Thai : #6519 - Remove check yuko_flag when upload template - End
							$templateButton['T32TemplateButton']['yuko_flag'] = $templateValue[$i++];
						}
						//20160226 Edit by Thai : #6519 - Update format csv upload format - End
						$templateButtons[] = $templateButton;
					}
					//20160226 Add by Thai : #6519 - Update format csv upload format - Begin
					if (isset($templateQuestion["T31TemplateQuestion"]["jump_question"]) && $templateQuestion["T31TemplateQuestion"]["jump_question"] == '') {
						foreach($answer_no_arr as $answer_no) {
							if ($answer_no != 99 && (!isset($arr_jumps[$answer_no]) || !$arr_jumps[$answer_no])) {
								$import_flag = false;
								$line_error .= "他のの場合飛び先が正しくありません, ";
								break;
							}
						}
					}
					//20160229 Delete by Thai : #6519 - Remove check yuko_flag when upload template - Begin
/*					if (!$yuko_flag) {
						$import_flag = false;
						$line_error .= "有効番号を入力してください, ";
					}*/
					//20160229 Delete by Thai : #6519 - Remove check yuko_flag when upload template - End
					//20160226 Add by Thai : #6519 - Update format csv upload format - End

					if ($templateValue[25] != 0 && $templateValue[25] != 1) {
						$import_flag = false;
						$line_error .= "繰返確認フラグが正しくありません, ";
					} else {
						$templateQuestion['T31TemplateQuestion']['recheck_flag'] = $templateValue[25];
					}
					//繰返確認あり
					if ($templateValue[25] == 1){
						if (($templateValue[26] != 0 && $templateValue[26] != 1 && $templateValue[26] != 2) || ($audio_mix_flag == 0 && ($templateValue[26] == 1 || $templateValue[26] == 2))) {
							$import_flag = false;
							$line_error .= "繰返確認音声種類が正しくありません, ";
						} else {
							$templateQuestion["T31TemplateQuestion"]["recheck_audio_type"] = $templateValue[26];
							if (($templateValue[26] == 1 || $templateValue[26] == 2) && empty($templateValue[26])) {
								$import_flag = false;
								$line_error .= "繰返確認音声内容を入力してください, ";
							} elseif ($templateValue[26] == 0 && empty($templateValue[28])) {
								$import_flag = false;
								$line_error .= "繰返確認音声ファイル名を入力してください, ";
							} else {
								$templateQuestion["T31TemplateQuestion"]["recheck_audio_content"] = trim($templateValue[27]);
								$templateValue[28] = trim(preg_replace('/\s\s+/', ' ', $templateValue[28]));
								if ($templateValue[28]) {
									if (in_array($templateValue[28], $fileArray)) {
										$import_flag = false;
										$line_error .= "繰返確認音声ファイル名重複があります, ";
									} elseif (!in_array($templateValue[28], $filenameArr)) {
										$import_flag = false;
										$line_error .= $templateValue[28]."繰返確認音声ファイルを選択してください, ";
									} else {
										$fileArray[$templateValue[0]] = $templateValue[28];
										$file = $this->upload_file_wav($zip, $templateValue[28], $zip_file_tmp);
										if (!empty($file)) {
											$templateQuestion["T31TemplateQuestion"]["recheck_audio_id"] = $file["T89ManageFile"]["id"];
											$templateQuestion["T31TemplateQuestion"]["recheck_audio_name"] = $file["T89ManageFile"]["file_name"];
										} else {
											$line_error .= "音声ファイル名が正しくありません, ";
											$import_flag = false;
										}
									}
								}
							}
						}
					}
					if (in_array($templateValue[29], array(0,1,2,3,4,5,6,7,8,9,51,52)))
						$templateQuestion['T31TemplateQuestion']['recheck_button_next'] = $templateValue[29];
					else {
						$import_flag = false;
						$line_error .= "正番号が正しくありません , ";
					}
				}else if ($templateValue[1] ==  QUESTION_AUTH_CHAR) { // Q.10
					if (($templateValue[3] != 0 && $templateValue[3] != 1)) {
						$import_flag = false;
						$line_error .= "有効質問が正しくありません, ";
					} else {
						$templateQuestion["T31TemplateQuestion"]["question_yuko"] = $templateValue[3];
					}

					if (($templateValue[5] != 0 && $templateValue[5] != 1 && $templateValue[5] != 2) || ($audio_mix_flag == 0 && ($templateValue[5] == 1 || $templateValue[5] == 2))) {
						$import_flag = false;
						$line_error .= "音声種類が正しくありません, ";
					} else {
						$templateQuestion["T31TemplateQuestion"]["audio_type"] = $templateValue[5];
						if (($templateValue[5] == 1 || $templateValue[5] == 2) && empty($templateValue[6])) {
							$import_flag = false;
							$line_error .= "音声内容を入力してください, ";
						} elseif ($templateValue[5] == 0 && empty($templateValue[7])) {
							$import_flag = false;
							$line_error .= "音声ファイルを選択してください, ";
						} else {
							$templateQuestion["T31TemplateQuestion"]["audio_content"] = trim($templateValue[6]);
							$templateValue[7] = trim(preg_replace('/\s\s+/', ' ', $templateValue[7]));
							if ($templateValue[7]) {
								if (in_array($templateValue[7], $fileArray)) {
									$import_flag = false;
									$line_error .= "音声ファイル名重複があります, ";
								} elseif (!in_array($templateValue[7], $filenameArr)) {
									$import_flag = false;
									$line_error .= $templateValue[7]."音声ファイルを選択してください, ";
								} else {
									$fileArray[$templateValue[0]] = $templateValue[7];
									$file = $this->upload_file_wav($zip, $templateValue[7], $zip_file_tmp);
									if (!empty($file)) {
										$templateQuestion["T31TemplateQuestion"]["audio_id"] = $file["T89ManageFile"]["id"];
										$templateQuestion["T31TemplateQuestion"]["audio_name"] = preg_replace('/\\.[^.\\s]{3,4}$/', '', $templateValue[7]);
										$templateQuestion["T31TemplateQuestion"]["recheck_audio_id"] = $file["T89ManageFile"]["id"];
										if ($templateValue[24]) {
											$templateQuestion["T31TemplateQuestion"]["recheck_audio_name"] = trim(preg_replace('/\s\s+/', ' ', $templateValue[24]));
										}
									} else {
										$line_error .= "音声ファイル名が正しくありません, ";
										$import_flag = false;
									}
								}
							}
						}
					}
					$templateQuestion['T31TemplateQuestion']['auth_item'] = $templateValue[8];
					$templateQuestion['T31TemplateQuestion']['digit'] = $templateValue[9];
					$i = 10;
					$field_count = count($templateValue);
					$answer_no_arr = array(1=>1, 2=>2, 99=>99);
					$arr_jumps = array();
					while ($i <= $field_count - 8) {
						$templateButton = array();
						$templateButton["T32TemplateButton"]["question_no"] = $templateValue[0];
						$templateButton["T32TemplateButton"]["entry_user"] = $user_id;
						$templateButton["T32TemplateButton"]["entry_program"] = 'Template_import';
						$templateButton["T32TemplateButton"]["update_user"] = $user_id;
						$templateButton["T32TemplateButton"]["update_program"] = 'Template_import';

						if (in_array($templateValue[$i], $answer_no_arr)) {
							$templateButton['T32TemplateButton']['answer_no'] = $templateValue[$i];
							$answer_no = $templateValue[$i];
						} else {
							$import_flag = false;
							$line_error .= "回答番号が正しくありません, ";
						}

						$i++;
						$templateButton['T32TemplateButton']['answer_content'] = $templateValue[$i++];
						$jump_ques_tmp = trim(preg_replace('/\s\s+/', ' ', $templateValue[$i++]));

						if ($jump_ques_tmp != '' && (!in_array($jump_ques_tmp, $arr_ques_nos) || !is_numeric($jump_ques_tmp))) {
							$import_flag = false;
							if ($answer_no == 99) {
								$line_error .= "タイムアウト飛び先が正しくありません, ";
							} else {
								$line_error .= "回答番号".$answer_no."飛び先が正しくありません, ";
							}
						} else {
							$templateButton['T32TemplateButton']['jump_question'] = $jump_ques_tmp;
							if ($answer_no != 99) {
								$arr_jumps[$answer_no] = $jump_ques_tmp;
							}
						}

						if ($templateValue[$i-3] != 99) {
							$templateValue[$i] = trim(preg_replace('/\s\s+/', ' ', $templateValue[$i]));
							if ($templateValue[$i] != 0 && $templateValue[$i] != 1) {
								$import_flag = false;
								$line_error .= "有効フラグ値が正しくありません, ";
							}
							$templateButton['T32TemplateButton']['yuko_flag'] = $templateValue[$i++];
						}
						$templateButtons[] = $templateButton;
					}

					if ($templateValue[21] != 0 && $templateValue[21] != 1) {
						$import_flag = false;
						$line_error .= "繰返確認フラグが正しくありません, ";
					} else {
						$templateQuestion['T31TemplateQuestion']['recheck_flag'] = $templateValue[21];
					}

					if ($templateValue[21] == 1){
						if (($templateValue[22] != 0 && $templateValue[22] != 1 && $templateValue[22] != 2) || ($audio_mix_flag == 0 && ($templateValue[22] == 1 || $templateValue[22] == 2))) {
							$import_flag = false;
							$line_error .= "繰返確認音声種類が正しくありません, ";
						} else {
							$templateQuestion["T31TemplateQuestion"]["recheck_audio_type"] = $templateValue[22];
							if (($templateValue[22] == 1 || $templateValue[22] == 2) && empty($templateValue[23])) {
								$import_flag = false;
								$line_error .= "繰返確認音声内容を入力してください, ";
							} elseif ($templateValue[22] == 0 && empty($templateValue[24])) {
								$import_flag = false;
								$line_error .= "繰返確認音声ファイル名を入力してください, ";
							} else {
								$templateQuestion["T31TemplateQuestion"]["recheck_audio_content"] = trim($templateValue[23]);
								$templateValue[24] = trim(preg_replace('/\s\s+/', ' ', $templateValue[24]));
								if ($templateValue[24]) {
									if (in_array($templateValue[24], $fileArray)) {
										$import_flag = false;
										$line_error .= "繰返確認音声ファイル名重複があります, ";
									} elseif (!in_array($templateValue[24], $filenameArr)) {
										$import_flag = false;
										$line_error .= $templateValue[24]."繰返確認音声ファイルを選択してください, ";
									} else {
										$fileArray[$templateValue[0]] = $templateValue[24];
										$file = $this->upload_file_wav($zip, $templateValue[24], $zip_file_tmp);
										if (!empty($file)) {
											$templateQuestion["T31TemplateQuestion"]["recheck_audio_id"] = $file["T89ManageFile"]["id"];
											$templateQuestion["T31TemplateQuestion"]["recheck_audio_name"] = $file["T89ManageFile"]["file_name"];
										} else {
											$line_error .= "音声ファイル名が正しくありません, ";
											$import_flag = false;
										}
									}
								}
							}
						}
					}

					if (in_array($templateValue[25], array(0,1,2,3,4,5,6,7,8,9,51,52))){
						$templateQuestion['T31TemplateQuestion']['recheck_button_next'] = $templateValue[25];
					} else {
						$import_flag = false;
						$line_error .= "正番号が正しくありません , ";
					}
				} else if ($templateValue[1] == QUESTION_TEL) { // Q.4
					if (count($templateValue) != 16) {
						$import_flag = false;
						++$line;
						$message_error .= $line."行目: 質問の入力形式が正しくありません, tel<br>";
						continue;
					}
					//20160229 Add by Thai : #6519 - Update format csv upload format - Begin
					if ($templateValue[3] == '' || !in_array($templateValue[3], $arr_ques_nos)) {
						$import_flag = false;
						$line_error .= "飛び先は正しくありません, ";
					} else {
						$templateQuestion["T31TemplateQuestion"]["jump_question"] = $templateValue[3];
					}
					//20160229 Add by Thai : #6519 - Update format csv upload format - End
					if (($templateValue[4] != 0 && $templateValue[4] != 1 && $templateValue[4] != 2) || ($audio_mix_flag == 0 && ($templateValue[4] == 1 || $templateValue[4] == 2))) {
						$import_flag = false;
						$line_error .= "音声種類が正しくありません, ";
					} else {
						$templateQuestion["T31TemplateQuestion"]["audio_type"] = $templateValue[4];
						if (($templateValue[4] == 1 || $templateValue[4] == 2) && $templateValue[5] == '') {
							$import_flag = false;
							$line_error .= "音声内容を入力してください, ";
						} elseif ($templateValue[4] == 0 && $templateValue[6] == '') {
							$import_flag = false;
							$line_error .= "音声ファイルを選択してください, ";
						} else {
							$templateQuestion["T31TemplateQuestion"]["audio_content"] = trim($templateValue[5]);
							$templateValue[6] = trim(preg_replace('/\s\s+/', ' ', $templateValue[6]));
							if ($templateValue[6]) {
								if (in_array($templateValue[6], $fileArray)) {
									$import_flag = false;
									$line_error .= "音声ファイル名重複があります, ";
								} elseif (!in_array($templateValue[6], $filenameArr)) {
									$import_flag = false;
									$line_error .= $templateValue[6]."音声ファイルを選択してください, ";
								} else {
									$fileArray[$templateValue[0]] = $templateValue[6];
									$file = $this->upload_file_wav($zip, $templateValue[6], $zip_file_tmp);
									if (!empty($file)) {
										$templateQuestion["T31TemplateQuestion"]["audio_id"] = $file["T89ManageFile"]["id"];
										$templateQuestion["T31TemplateQuestion"]["audio_name"] = preg_replace('/\\.[^.\\s]{3,4}$/', '', $templateValue[6]);
									} else {
										$line_error .= "音声ファイルはアップ失敗しました, ";
										$import_flag = false;
									}
								}
							}
						}
					}
					if (is_numeric($templateValue[7])) {
						$templateQuestion['T31TemplateQuestion']['digit'] = $templateValue[7];
					}else{
						$import_flag = false;
						$line_error .= "桁数が正しくありません, ";
					}

					//20160304 Add by Thai : ADD jump_question for timeout of QUESTION_TEL - Begin
					$templateButton = array();
					$templateButton["T32TemplateButton"]["question_no"] = $templateValue[0];
					$templateButton["T32TemplateButton"]["entry_user"] = $user_id;
					$templateButton["T32TemplateButton"]["entry_program"] = 'Template_import';
					$templateButton["T32TemplateButton"]["update_user"] = $user_id;
					$templateButton["T32TemplateButton"]["update_program"] = 'Template_import';

					if ($templateValue[8] == 99) {
						$templateButton['T32TemplateButton']['answer_no'] = $templateValue[8];
						$answer_no = $templateValue[8];
					}
					if (!empty($templateValue[8]) && $templateValue[8] != 99){
						$import_flag = false;
						$line_error .= "回答番号が正しくありません, ";
					}

					$templateButton['T32TemplateButton']['answer_content'] = $templateValue[9];

					$jump_ques_tmp = trim(preg_replace('/\s\s+/', ' ', $templateValue[10]));
					if ($jump_ques_tmp != '' && (!in_array($jump_ques_tmp, $arr_ques_nos) || !is_numeric($jump_ques_tmp))) {
						$import_flag = false;
						$line_error .= "タイムアウト飛び先が正しくありません, ";
					} else {
						$templateButton['T32TemplateButton']['jump_question'] = $jump_ques_tmp;
					}
					$templateButtons[] = $templateButton;
					//20160304 Add by Thai : ADD jump_question for timeout of QUESTION_TEL - End

					//繰返確認チェック
					if ($templateValue[11] != 0 && $templateValue[11] != 1) {
						$import_flag = false;
						$line_error .= "繰返確認フラグが正しくありません, ";
					} else {
						$templateQuestion['T31TemplateQuestion']['recheck_flag'] = $templateValue[11];
					}
					//繰返確認あり場合
					if ($templateValue[11] == 1){
						if (($templateValue[12] != 0 && $templateValue[12] != 1 && $templateValue[12] != 2) || ($audio_mix_flag == 0 && ($templateValue[12] == 1 || $templateValue[12] == 2))) {
							$import_flag = false;
							$line_error .= "繰返確認音声種類が正しくありません, ";
						} else {
							$templateQuestion["T31TemplateQuestion"]["recheck_audio_type"] = $templateValue[12];
							if (($templateValue[12] == 1 || $templateValue[12] == 2) && empty($templateValue[13])) {
								$import_flag = false;
								$line_error .= "繰返確認音声内容を入力してください, ";
							} elseif ($templateValue[12] == 0 && empty($templateValue[14])) {
								$import_flag = false;
								$line_error .= "繰返確認音声ファイル名を入力してください, ";
							} else {
								$templateQuestion["T31TemplateQuestion"]["recheck_audio_content"] = trim($templateValue[13]);
								$templateValue[14] = trim(preg_replace('/\s\s+/', ' ', $templateValue[14]));
								if ($templateValue[14]) {
									if (in_array($templateValue[14], $fileArray)) {
										$import_flag = false;
										$line_error .= "繰返確認音声ファイル名重複があります, ";
									} elseif (!in_array($templateValue[14], $filenameArr)) {
										$import_flag = false;
										$line_error .= $templateValue[14]."繰返確認音声ファイルを選択してください, ";
									} else {
										$fileArray[$templateValue[0]] = $templateValue[14];
										$file = $this->upload_file_wav($zip, $templateValue[14], $zip_file_tmp);
										if (!empty($file)) {
											$templateQuestion["T31TemplateQuestion"]["recheck_audio_id"] = $file["T89ManageFile"]["id"];
											$templateQuestion["T31TemplateQuestion"]["recheck_audio_name"] = $file["T89ManageFile"]["file_name"];
										} else {
											$line_error .= "音声ファイル名が正しくありません, ";
											$import_flag = false;
										}
									}
								}
							}
						}
					}
					if (in_array($templateValue[15], array(0,1,2,3,4,5,6,7,8,9,51,52)))
						$templateQuestion['T31TemplateQuestion']['recheck_button_next'] = $templateValue[15];
					else {
						$import_flag = false;
						$line_error .= "正番号が正しくありません , ";
					}
				} else if ($templateValue[1] == QUESTION_TRANS) { // Q.5
					$ques_type_5++;
					if (count($templateValue) != 14) {
						$import_flag = false;
						++$line;
						$message_error .= $line."行目: 質問の入力形式が正しくありません,<br>";
						continue;
					}
					//転送音声チェック
					if (($templateValue[3] != 0 && $templateValue[3] != 1 && $templateValue[3] != 2) || ($audio_mix_flag == 0 && ($templateValue[3] == 1 || $templateValue[3] == 2))) {
						$import_flag = false;
						$line_error .= "転送音声種類が正しくありません, ";
					} else {
						$templateQuestion["T31TemplateQuestion"]["audio_type"] = $templateValue[3];
						if (($templateValue[3] == 1 || $templateValue[3] == 2) && empty($templateValue[4])) {
							$import_flag = false;
							$line_error .= "転送音声内容を入力してください, ";
						} elseif ($templateValue[3] == 0 && empty($templateValue[5])) {
							$import_flag = false;
							$line_error .= "転送音声ファイルを選択してください, ";
						} else {
							$templateQuestion["T31TemplateQuestion"]["audio_content"] = $templateValue[4];
							$templateValue[5] = trim(preg_replace('/\s\s+/', ' ', $templateValue[5]));
							if ($templateValue[3] == 0) {
								if (in_array($templateValue[5], $fileArray)) {
									$import_flag = false;
									$line_error .= "転送音声ファイル名重複があります, ";
								} elseif (!in_array($templateValue[5], $filenameArr)) {
									$import_flag = false;
									$line_error .= $templateValue[5]."転送音声ファイル名を入力してください, ";
								} else {
									$fileArray[$templateValue[0]] = $templateValue[5];
									$file = $this->upload_file_wav($zip, $templateValue[5], $zip_file_tmp);
									if (!empty($file)) {
										$templateQuestion["T31TemplateQuestion"]["audio_id"] = $file["T89ManageFile"]["id"];
										$templateQuestion["T31TemplateQuestion"]["audio_name"] = $file["T89ManageFile"]["file_name"];
									} else {
										$line_error .= "転送音声ファイル名が正しくありません, ";
										$import_flag = false;
									}
								}
							}
						}
					}
					//転送タイムアウト音声チェック
					if (($templateValue[6] != 0 && $templateValue[6] != 1 && $templateValue[6] != 2) || ($audio_mix_flag == 0 && ($templateValue[6] == 1 || $templateValue[6] == 2))) {
						$import_flag = false;
						$line_error .= "転送音声種類が正しくありません, ";
					} else {
						$templateQuestion["T31TemplateQuestion"]["trans_timeout_audio_type"] = $templateValue[6];
						if (($templateValue[6] == 1 || $templateValue[6] == 2) && empty($templateValue[7])) {
							$import_flag = false;
							$line_error .= "転送音声内容を入力してください, ";
						} elseif ($templateValue[6] == 0 && empty($templateValue[8])) {
							$import_flag = false;
							$line_error .= "転送音声ファイルを選択してください, ";
						} else {
							$templateQuestion["T31TemplateQuestion"]["trans_timeout_audio_content"] = $templateValue[7];
							$templateValue[8] = trim(preg_replace('/\s\s+/', ' ', $templateValue[8]));
							if ($templateValue[8]) {
								if (in_array($templateValue[8], $fileArray)) {
									$import_flag = false;
									$line_error .= "転送音声ファイル名重複があります, ";
								} elseif (!in_array($templateValue[8], $filenameArr)) {
									$import_flag = false;
									$line_error .= $templateValue[8]."転送音声ファイルを選択してください, ";
								} else {
									$fileArray[$templateValue[0]] = $templateValue[8];
									$file = $this->upload_file_wav($zip, $templateValue[8], $zip_file_tmp);
									if (!empty($file)) {
										$templateQuestion["T31TemplateQuestion"]["trans_timeout_audio_id"] = $file["T89ManageFile"]["id"];
										$templateQuestion["T31TemplateQuestion"]["trans_timeout_audio_name"] = $file["T89ManageFile"]["file_name"];
									} else {
										$line_error .= "転送音声ファイル名が正しくありません, ";
										$import_flag = false;
									}
								}
							}
						}
					}

					if (!is_numeric($templateValue[9]) || strlen($templateValue[9]) < 10 || $templateValue[9][0] != '0' || strlen($templateValue[9]) > 11){
						$import_flag = false;
						$line_error .= "転送番号が正しくありません, ";
					} else {
						$templateQuestion['T31TemplateQuestion']['trans_tel'] = $templateValue[9];
					}
					if (is_numeric($templateValue[10])) {
						$templateQuestion['T31TemplateQuestion']['trans_seat_num'] = $templateValue[10];
					} else {
						$import_flag = false;
						$line_error .= "転送席数値が正しくありません, ";
					}
					if ($templateValue[11] == 0 || $templateValue[11] == 1) {
						$templateQuestion['T31TemplateQuestion']['trans_empty_seat_flag'] = $templateValue[11];
					} else {
						$import_flag = false;
						$line_error .= "転送空き席数無し時発信停止値が正しくありません, ";
					}
					if (is_numeric(trim(preg_replace('/\s\s+/', ' ', $templateValue[12])))) {
						$templateQuestion['T31TemplateQuestion']['trans_timeout'] = $templateValue[12];
					} else {
						$import_flag = false;
						$line_error .= "転送タイムアウト値が正しくありません, ";
					}
					if ($templateValue[13] == 0 || $templateValue[13] == 1) {
						$templateQuestion['T31TemplateQuestion']['yuko_button_record'] = $templateValue[13];
					} else {
						$import_flag = false;
						$line_error .= "転送元番号再生値が正しくありません, ";
					}
				} else if ($templateValue[1] == QUESTION_RECORD) {
					$ques_type_6++;
					if (count($templateValue) != 9) {
						$import_flag = false;
						++$line;
						$message_error .= $line."行目: 質問の入力形式が正しくありません,<br>";
						continue;
					}
					//20160229 Add by Thai : #6519 - Update format csv upload format - Begin
					if ($templateValue[3] == '' || !in_array($templateValue[3], $arr_ques_nos)) {
						$import_flag = false;
						$line_error .= "飛び先は正しくありません, ";
					} else {
						$templateQuestion["T31TemplateQuestion"]["jump_question"] = $templateValue[3];
					}
					//20160229 Add by Thai : #6519 - Update format csv upload format - End
					if (($templateValue[4] != 0 && $templateValue[4] != 1 && $templateValue[4] != 2) || ($audio_mix_flag == 0 && ($templateValue[4] == 1 || $templateValue[4] == 2))) {
						$import_flag = false;
						$line_error .= "音声種類値が正しくありません, ";
					} else {
						$templateQuestion["T31TemplateQuestion"]["audio_type"] = $templateValue[4];
						if (($templateValue[4] == 1 || $templateValue[4] == 2) && $templateValue[5] == '') {
							$import_flag = false;
							$line_error .= "音声内容を入力してください, ";
						} elseif ($templateValue[4] == 0 && $templateValue[6] == '') {
							$import_flag = false;
							$line_error .= "音声ファイルを選択してください, ";
						} else {
							$templateQuestion["T31TemplateQuestion"]["audio_content"] = $templateValue[5];
							$templateValue[6] = trim(preg_replace('/\s\s+/', ' ', $templateValue[6]));
							if ($templateValue[6]) {
								if (in_array($templateValue[6], $fileArray)) {
									$import_flag = false;
									$line_error .= "音声ファイル名重複があります, ";
								} elseif (!in_array($templateValue[6], $filenameArr)) {
									$import_flag = false;
									$line_error .= $templateValue[6]."音声ファイルを選択してください, ";
								} else {
									$fileArray[$templateValue[0]] = $templateValue[6];
									$file = $this->upload_file_wav($zip, $templateValue[6], $zip_file_tmp);
									if (!empty($file)) {
										$templateQuestion["T31TemplateQuestion"]["audio_id"] = $file["T89ManageFile"]["id"];
										$templateQuestion["T31TemplateQuestion"]["audio_name"] = preg_replace('/\\.[^.\\s]{3,4}$/', '', $templateValue[6]);
									} else {
										$line_error .= "音声ファイル名が正しくありません, ";
										$import_flag = false;
									}
								}
							}
						}
					}
					if (!empty($templateValue[7])) {
						// second_record is integer
						preg_match_all('/\D/', $templateValue[7], $output_array);
						if (!empty($output_array[0]) || ((int)$templateValue[7] > 30)) {
							$import_flag = false;
							$line_error .= "録音秒数値が正しくありません, ";
						} else {
							$templateQuestion["T31TemplateQuestion"]["second_record"] = (int)$templateValue[7];
						}
					}
					if (!empty($templateValue[8])) {
						if (($templateValue[8] != 0) && ($templateValue[8] != 1)) {
							$import_flag = false;
							$line_error .= "#終了ボタン値が正しくありません, ";
						} else {
							$templateQuestion["T31TemplateQuestion"]["yuko_button_record"] = $templateValue[8];
						}
					}
				} else if($templateValue[1] == QUESTION_COUNT) {
					if (count($templateValue) != 4) {//20160325 Edit by Canh : カウントセクションで飛び先項目を追加する
						$import_flag = false;
						$line_error .= "質問の入力形式が正しくありません,";
					}
					//20160325 Add by Canh : カウントセクションで飛び先項目を追加する - begin
					$templateQuestion["T31TemplateQuestion"]["jump_question"] = $templateValue[3];
					//20160325 Add by Canh : カウントセクションで飛び先項目を追加する - end
				} else if ($templateValue[1] == QUESTION_END) {
					if (count($templateValue) != 3) {
						$import_flag = false;
						$line_error .= "質問の入力形式が正しくありません,";
					}
				}

				if (!empty($templateQuestion) && $import_flag) {
					$templateQuestions[] = $templateQuestion;
				}
				++$line;
				if (!empty($line_error))
					$message_error .= $line."行目: ".$line_error."<br>";
			}
			if ($ques_type_5 > 1) {
				$import_flag = false;
				$message_error .= "転送質問は1つのみ作成できます。<br>";
			}
			if ($ques_type_6 > 1) {
				$import_flag = false;
				$message_error .= "録音質問は1つのみ作成できます。<br>";
			}
			if ($ques_type_9 > 1) {
				$import_flag = false;
				$message_error .= "切断質問は1つのみ作成できます。<br>";
			}
			// if (!$lastQuestionCutting) {
			// 	$import_flag = false;
			// 	$message_error .= "切断質問が最後テンプレートの位置で設定ください。<br>";
			// }

// 			$question_flag = $this->T31TemplateQuestion->saveMany($templateQuestions, array());
// 			$button_flag = $this->T32TemplateButton->saveMany($templateButtons, array());
			$dsT30Template = $this->T30Template->getDataSource();
			$dsT31TemplateQuestion = $this->T31TemplateQuestion->getDataSource();
			$dsT32TemplateButton = $this->T32TemplateButton->getDataSource();

			$dsT30Template->begin($this);
			$dsT31TemplateQuestion->begin($this);
			$dsT32TemplateButton->begin($this);
			if($import_flag){
				$template["T30Template"]["question_total"] = count($templateQuestions);
				$flag = $this->T30Template->save($template);
				$template_id = $this->T30Template->getLastInsertId();
				if(!$flag){
					$dsT30Template->rollback($this);
					$message_error .= "アップ ファイルが失敗しました。<br>";
					$staArr = array(
						'code' => 501,
						'status'=>'failed',
						'message' => $message_error,
						'count_file' => $zip->numFiles
					);
					header('Content-type: text/json');
					header('Content-type: application/json');
					echo json_encode($staArr);
					exit;
				}
				foreach ($templateQuestions as $arr){
					$this->T31TemplateQuestion->create();
					$arr['T31TemplateQuestion']['template_id'] = $template_id;
					$flag = $this->T31TemplateQuestion->save($arr);
					if(!$flag){
						$dsT30Template->rollback($this);
						$dsT31TemplateQuestion->rollback($this);
						$message_error .= "アップ ファイルが失敗しました。<br>";
						$staArr = array(
								'code' => 501,
								'status'=>'failed',
								'message' => $message_error,
								'count_file' => $zip->numFiles
						);
						header('Content-type: text/json');
						header('Content-type: application/json');
						echo json_encode($staArr);
						exit;
					}
				}
				foreach ($templateButtons as $arr){
					$this->T32TemplateButton->create();
					$arr['T32TemplateButton']['template_id'] = $template_id;
					$flag = $this->T32TemplateButton->save($arr);
					if(!$flag){
						$dsT30Template->rollback($this);
						$dsT31TemplateQuestion->rollback($this);
						$dsT32TemplateButton->rollback($this);
						$message_error .= "アップ ファイルが失敗しました。<br>";
						$staArr = array(
							'code' => 501,
							'status'=>'failed',
							'message' => $message_error,
							'count_file' => $zip->numFiles
						);
						header('Content-type: text/json');
						header('Content-type: application/json');
						echo json_encode($staArr);
						exit;
					}

				}
				if($flag){
					$dsT30Template->commit($this);
					$dsT31TemplateQuestion->commit($this);
					$dsT32TemplateButton->commit($this);
					$staArr = array(
						'code' => 200,
						'status'=>'success',
						'message' => '保存しました。',
						'count_file' => $zip->numFiles
					);
					header('Content-type: text/json');
					header('Content-type: application/json');
					echo json_encode($staArr);
					exit;
				}
			}else{
				$staArr = array(
					'code' => 501,
					'status'=>'failed',
					'message' => $message_error,
					'count_file' => $zip->numFiles
				);
				header('Content-type: text/json');
				header('Content-type: application/json');
				echo json_encode($staArr);
				exit;
			}
		}
	}

	public function upload_file_wav($zip, $wavname, $zippath) {
		$file = array();
		$dsT89ManageFile = $this->T89ManageFile->getDataSource();
		$dsT89ManageFile->begin($this);
		for ($i = 0; $i < $zip->numFiles; $i++) {
			$name = $zip->getNameIndex($i);
			$user_id = $this->ESession->getUserId($this);
			$filename = explode('.', $name);
			$ext = end($filename);
			if($ext == 'wav' && $name == $wavname) {
				$this->T89ManageFile->create();
				$filezip = $zip->statIndex($i);
				$content = file_get_contents('zip://' . realpath($zippath) . '#' . $filezip['name']);
				$tmp = tempnam(sys_get_temp_dir(), $filezip['name']);
				$tmpPcm = tempnam(sys_get_temp_dir(), $filezip['name'].".pcm");
				$tmpMp3 = tempnam(sys_get_temp_dir(), $filezip['name']).".mp3";
				file_put_contents($tmp, $content);
				exec('sox -t wav '.$tmp.' -b 8 -c 1 -r 8000 -t ul '.$tmpPcm, $shell_result, $shell_result_status);
				exec('ffmpeg -i '.$tmp.' -ab 256k '.$tmpMp3, $shell_result, $shell_result_status);
				$wav_content = file_get_contents($tmp);
				$pcm_content = file_get_contents($tmpPcm);
				$mp3_content = file_get_contents($tmpMp3);
				$file["T89ManageFile"]["file_name"] = preg_replace('/\\.[^.\\s]{3,4}$/', '', $name);
				$file["T89ManageFile"]["file_contents"] = $wav_content;
				$file["T89ManageFile"]["file_pcm_contents"] = $pcm_content;
				$file["T89ManageFile"]["file_mp3_contents"] = $mp3_content;
				$file["T89ManageFile"]["file_size"] = $filezip['size'];
				$file["T89ManageFile"]["file_mp3_size"] = filesize($tmpMp3);
				$file["T89ManageFile"]["entry_user"] = $user_id;
				$file["T89ManageFile"]["entry_program"] = 'Template_import';
				$file["T89ManageFile"]["update_user"] = $user_id;
				$file["T89ManageFile"]["update_program"] = 'Template_import';
				$flag = $this->T89ManageFile->save($file);
				if(!$flag){
					$dsT89ManageFile->rollback($this);
					$this->log("アップロードファイル：失敗", "debug");
					return 0;
				}
				$file["T89ManageFile"]["id"] = $this->T89ManageFile->getLastInsertId();
			}
		}
		$dsT89ManageFile->commit($this);
		return $file;
	}

	public function reArrayFiles(&$file_post) {
		$file_ary = array();
		$file_count = count($file_post['name']);
		$file_keys = array_keys($file_post);
		for ($i=0; $i<$file_count; $i++) {
			foreach ($file_keys as $key) {
				$file_ary[$i][$key] = $file_post[$key][$i];
			}
		}
		return $file_ary;
	}

	function save_template(){
		$this->layout = "ajax";

		$dsT30Template = $this->T30Template->getDataSource();
		$dsT31TemplateQuestion = $this->T31TemplateQuestion->getDataSource();
		$dsT32TemplateButton = $this->T32TemplateButton->getDataSource();

		$dsT30Template->begin($this);
		$dsT31TemplateQuestion->begin($this);
		$dsT32TemplateButton->begin($this);

		$data = $this->data;
		if(isset($data["template_id"])){
			$info_schedules = $this->T20OutSchedule->getScheduleNotFinishByTemplateId($data["template_id"]);
			if (isset($info_schedules["T20OutSchedule"]["id"]) && !empty($info_schedules["T20OutSchedule"]["id"])) {
				echo "err_exist_schedule";
				exit;
			}
		}

		$company_id = $this->ESession->getUserCompanyId($this);

		//T30Template
		$T30Template = array();
		if(isset($data["template_id"])){
			$data["T30Template"]["id"] = $data["template_id"];
		}
		$data["T30Template"]["template_name"] = $data["template_name"];
		$data["T30Template"]["template_type"] = TEMPLATE_OUTBOUND;
		$data["T30Template"]["description"] = $data["description"];
		$data["T30Template"]["question_total"] = count($data["glb_arr_ques"]);

		if(isset($data["T30Template"]["id"]) && !empty($data["T30Template"]["id"])){
			$template_id = $data["T30Template"]["id"];
			$data["T30Template"]["update_user"] = $this->ESession->getUserId($this);
			$data["T30Template"]["update_program"] = $this->name.'_'.__FUNCTION__;
			$flag = $this->T30Template->save($data["T30Template"]);
		}else{
			$max_template_no = $this->T30Template->getMaxTemplateNoByCompanyId($company_id, TEMPLATE_OUTBOUND);
			if (isset($max_template_no["T30Template"]["template_no"]) && !empty($max_template_no["T30Template"]["template_no"])) {
				$template_no = (string)($max_template_no["T30Template"]["template_no"] + 1);
			} else {
				$template_no = "1";
			}
			$data["T30Template"]["template_no"] = $template_no;
			$data["T30Template"]["company_id"] = $company_id;
			$data["T30Template"]["entry_user"] = $this->ESession->getUserId($this);
			$data["T30Template"]["entry_program"] = $this->name.'_'.__FUNCTION__;
			$flag = $this->T30Template->save($data["T30Template"]);
			$template_id = $this->T30Template->getLastInsertID();
		}
		if(!$flag){
			$dsT30Template->rollback($this);
			$this->log("テンプレート登録：失敗");
			echo "err_db";
			exit;
		}

		//20160225 Edit by Thai : #6549 - Update when delete question - Begin
		//質問削除
		if(isset($data["glb_arr_ques_del"])){
			foreach($data["glb_arr_ques_del"] as $ques_id){
				$ques_tmp = $this->T31TemplateQuestion->getQuesById($ques_id);
				$question_no = $ques_tmp['T31TemplateQuestion']['question_no'];
				//T31TemplateQuestion
				$this->T31TemplateQuestion->create();
				$T31Question = array();
				$T31Question["id"] = $ques_id;
				$T31Question["del_flag"] = "Y";
				$T31Question["update_user"] = $this->ESession->getUserId($this);
				$T31Question["update_program"] = $this->name.'_'.__FUNCTION__;
				$flag = $this->T31TemplateQuestion->save($T31Question);
				if(!$flag){
					$dsT30Template->rollback($this);
					$dsT31TemplateQuestion->rollback($this);
					$dsT32TemplateButton->rollback($this);
					$this->log("質問削除：失敗");
					echo "err_db";
					exit;
				}

				//20160229 Delete by Canh - Begin
				//回答削除
// 				$update_user = $this->ESession->getUserId($this);
// 				$update_program = $this->name.'_'.__FUNCTION__;
// 				$time = date('Y-m-d H:i:s a', time());

// 				$query = "UPDATE t32_template_buttons ".
// 					"SET del_flag='Y', update_user='$update_user', update_program='$update_program', modified='$time' ".
// 					"WHERE template_id='$template_id' AND question_no='$question_no';";
// 				if ($this->T32TemplateButton->query($query)) {
// 					$dsT30Template->rollback($this);
// 					$dsT31TemplateQuestion->rollback($this);
// 					$dsT32TemplateButton->rollback($this);
// 					$this->log("回答削除：失敗", "debug");
// 					$this->redirect(array('controller' => 'Login', 'action' => 'index/systemerror'));
// 				}
				//20160229 Delete by Canh - End
			}
		}
		//20160225 Edit by Thai : #6549 - Update when delete question - End

		//20160229 Edit by Canh : 既に存在回答ボタンを削除 - Begin
		$arr_info_ans = $this->T32TemplateButton->getAnwsByTemplateId($template_id);
		if(count($arr_info_ans) > 0){
			$dsT32TemplateButton->begin($this);
			foreach ($arr_info_ans as $arr){
				$this->T32TemplateButton->create();
				$T32TemplateButton = array();
				$T32TemplateButton["id"] = $arr["T32TemplateButton"]["id"];
				$T32TemplateButton["del_flag"] = "Y";
				$T32TemplateButton["update_user"] = $this->ESession->getUserId($this);
				$T32TemplateButton["update_program"] = $this->name.'_'.__FUNCTION__;
				$flag = $this->T32TemplateButton->save($T32TemplateButton);
				if(!$flag){
					$dsT30Template->rollback($this);
					$dsT31TemplateQuestion->rollback($this);
					$dsT32TemplateButton->rollback($this);
					$this->log("回答処理：失敗");
					echo "err_db";
					exit;
				}
			}
			$dsT32TemplateButton->commit($this);
		}
		//20160229 Edit by Canh : 既に存在回答ボタンを削除 - End

		foreach($data["glb_arr_ques"] as $key => $value){
			if($key > 0){
				//T31TemplateQuestion
				$this->T31TemplateQuestion->create();
				$T31Question = $value;
				if($T31Question["question_type"] == QUESTION_TRANS){
					$T31Question["audio_id"] = $T31Question["trans_audio_id"];
					$T31Question["audio_name"] = $T31Question["trans_audio_name"];
					$T31Question["audio_type"] = $T31Question["trans_audio_type"];
					$T31Question["audio_content"] = $T31Question["trans_audio_content"];
					// checkOFFの場合は空欄が入るので、0を入れる。(値なしはインポート・エクスポートの時に都合が悪いため。)
					$T31Question["yuko_button_record"] = $T31Question["trans_phone_number_play_flag"] ? $T31Question["trans_phone_number_play_flag"] : 0;
				}
				if($T31Question["question_type"] == QUESTION_TEL){
					$T31Question["digit"] = $T31Question["digit_tel"];
				}
				if($T31Question["question_type"] == QUESTION_AUTH || $T31Question["question_type"] == QUESTION_AUTH_CHAR){
					$T31Question["digit"] = $T31Question["digit_auth"];
				}
				if(isset($value["jump_question"])){
					$T31Question["jump_question"] = $value["jump_question"];
				}
				$T31Question["question_no"] = $key;
				if(isset($T31Question["id"]) && !empty($T31Question["id"])){
					$T31Question["update_user"] = $this->ESession->getUserId($this);
					$T31Question["update_program"] = $this->name.'_'.__FUNCTION__;

				}else{
					$T31Question["template_id"] = $template_id;
					$T31Question["entry_user"] = $this->ESession->getUserId($this);
					$T31Question["entry_program"] = $this->name.'_'.__FUNCTION__;
				}
                if ($T31Question["question_type"] == QUESTION_SMS) {
                    $T31Question["sms_display_number"] = $T31Question["smsPhoneNumber"];
					$T31Question["yuko_button_record"] = $T31Question["sms_use_short_url"];
                    $T31Question["sms_content"] = str_replace("\r\n","\n",$T31Question["smsBodyContent"]);
                    $T31Question["sms_error_audio_id"] = $T31Question["ques_audio_id"];
                    $T31Question["sms_error_audio_name"] = $T31Question["ques_audio_name"];
                    $T31Question["sms_error_audio_type"] = $T31Question["ques_sms_audio_type"];
                    $T31Question["sms_error_audio_content"] = $T31Question["ques_sms_audio_content"];
                }
                if ($T31Question["question_type"] == QUESTION_SMS_INPUT) {
                    $T31Question["sms_display_number"] = $T31Question["smsInputPhoneNumber"];
                    $T31Question["sms_content"] = str_replace("\r\n","\n",$T31Question["smsInputBodyContent"]);
                    $T31Question["yuko_button_record"] = $T31Question["sms_input_use_short_url"];
                    $T31Question["sms_error_audio_id"] = $T31Question["ques_sms_input_audio_id"];
                    $T31Question["sms_error_audio_name"] = $T31Question["ques_sms_input_audio_name"];
                    $T31Question["sms_error_audio_type"] = $T31Question["ques_sms_input_audio_type"];
                    $T31Question["sms_error_audio_content"] = $T31Question["ques_sms_input_audio_content"];
                }

				$flag = $this->T31TemplateQuestion->save($T31Question);
				if(!$flag){
					$dsT30Template->rollback($this);
					$dsT31TemplateQuestion->rollback($this);
					$this->log("質問登録：失敗");
					echo "err_db";
					exit;
				}
				//T32TemplateButton
				if (in_array($value["question_type"], array(QUESTION_BASIC, QUESTION_AUTH, QUESTION_AUTH_CHAR, QUESTION_TEL, QUESTION_SMS, QUESTION_SMS_INPUT))) {
					$arr_answer_no = array();
					if($value["question_type"] == QUESTION_BASIC){
						$arr_answer_no = array(0,1,2,3,4,5,6,7,8,9,51,52,99);//51: *, 52: #, 99: timeout
					}else if($value["question_type"] == QUESTION_AUTH){
						$arr_answer_no = array(1,2,3,99);//1: 入力値  <, 2: =, 3: 入力値 > , 99: timeout
						//20160420 Add by Thai : #6722 ADD QUESTION_AUTH_CHAR - Begin
					}else if($value["question_type"] == QUESTION_AUTH_CHAR){
						$arr_answer_no = array(1,2,99);
						//20160420 Add by Thai : #6722 ADD QUESTION_AUTH_CHAR - End
					}else if($value["question_type"] == QUESTION_TEL){
						$arr_answer_no = array(99); //99: timeout
					} else if ($value["question_type"] == QUESTION_SMS) {
						$arr_answer_no = array(99); //99: 送信不可
					} else if ($value["question_type"] == QUESTION_SMS_INPUT) {
						$arr_answer_no = array(98, 99);//98:タイムアウト, 99: 送信不可
					}
					foreach ($arr_answer_no as $answer_no){
						if($value["question_type"] == QUESTION_BASIC){
							if(isset($value["cbYukoAnsw".$answer_no])){
								$yuko_flag = 1;
							}else $yuko_flag = 0;
							if(isset($value["txtAnswContent".$answer_no])){
								$answer_content = $value["txtAnswContent".$answer_no];
							}else $answer_content = "";
							if(isset($value["txtAnswJump".$answer_no])){
								$jump_question = $value["txtAnswJump".$answer_no];
							}else $jump_question = "";
						}else if($value["question_type"] == QUESTION_AUTH){
							if(isset($value["cbYukoAnswAuth".$answer_no])){
								$yuko_flag = 1;
							}else $yuko_flag = 0;
							if(isset($value["txtAnswContentAuth".$answer_no])){
								$answer_content = $value["txtAnswContentAuth".$answer_no];
							}else $answer_content = "";
							if(isset($value["txtAnswJumpAuth".$answer_no])){
								$jump_question = $value["txtAnswJumpAuth".$answer_no];
							}else $jump_question = "";
							//20160420 Add by Thai : #6722 ADD QUESTION_AUTH_CHAR - Begin
						}else if($value["question_type"] == QUESTION_AUTH_CHAR){
							$yuko_flag = isset($value["cbYukoAnswAuthChar".$answer_no]) ? 1 : 0;
							$answer_content = isset($value["txtAnswContentAuthChar".$answer_no]) ? $value["txtAnswContentAuthChar".$answer_no] : '';
							$jump_question = isset($value["txtAnswJumpAuthChar".$answer_no]) ? $value["txtAnswJumpAuthChar".$answer_no] : '';
							//20160420 Add by Thai : #6722 ADD QUESTION_AUTH_CHAR - End
							//20160304 Add by Thai : ADD jump_question for timeout of QUESTION_TEL - Begin
						}else if($value["question_type"] == QUESTION_TEL){
							if(isset($value["txtAnswJumpTel".$answer_no])){
								$jump_question = $value["txtAnswJumpTel".$answer_no];
							}else $jump_question = "";
							//20160304 Add by Thai : ADD jump_question for timeout of QUESTION_TEL - End
						} else if ($value["question_type"] == QUESTION_SMS) {
							if (isset($value["txtAnswJumpSms" . $answer_no])) {
								$jump_question = $value["txtAnswJumpSms" . $answer_no];
							} else $jump_question = "";
						} else if ($value["question_type"] == QUESTION_SMS_INPUT) {
							if (isset($value["txtAnswJumpSmsInput" . $answer_no]) && $answer_no == 99) {
								$jump_question = $value["txtAnswJumpSmsInput" . $answer_no];
							} elseif (isset($value["txtAnswJumpSmsInputTimeOut" . $answer_no]) && $answer_no == 98) {
								$jump_question = $value["txtAnswJumpSmsInputTimeOut" . $answer_no];
							} else $jump_question = "";
						}
						//20160229 Edit by Canh : 回答ボタンを追加 - Begin
						//種類質問場合有効または回答内容または飛び先がある場合追加する
						//種類認証場合チェックしなく追加する
						if(!empty($yuko_flag) || !empty($answer_content) || !empty($jump_question) || $value["question_type"] == QUESTION_AUTH || $value["question_type"] == QUESTION_AUTH_CHAR){
							$this->T32TemplateButton->create();
							$T32TemplateButton = array();
							$T32TemplateButton["template_id"] = $template_id;
							$T32TemplateButton["question_no"] = $key;
							$T32TemplateButton["answer_no"] = $answer_no;
							//20160304 Edit by Thai : ADD jump_question for timeout of QUESTION_TEL - Begin
							if(isset($yuko_flag)){
								$T32TemplateButton["yuko_flag"] = $yuko_flag;
							}
							//20160304 Edit by Thai : ADD jump_question for timeout of QUESTION_TEL - End
							if(isset($answer_content)){
								$T32TemplateButton["answer_content"] = $answer_content;
							}
							if(isset($jump_question)){
								$T32TemplateButton["jump_question"] = $jump_question;
							}
							$T32TemplateButton["entry_user"] = $this->ESession->getUserId($this);
							$T32TemplateButton["entry_program"] = $this->name.'_'.__FUNCTION__;
							$flag = $this->T32TemplateButton->save($T32TemplateButton);
							if(!$flag){
								$dsT30Template->rollback($this);
								$dsT31TemplateQuestion->rollback($this);
								$dsT32TemplateButton->rollback($this);
								$this->log("回答処理：失敗");
								echo "err_db";
								exit;
							}
						}
						//20160229 Edit by Canh : 回答ボタンを追加 - End
					}
				}
			}
		}
		//コミット
		$dsT30Template->commit($this);
		$dsT31TemplateQuestion->commit($this);
		$dsT32TemplateButton->commit($this);
		echo "success";
		exit;
	}

	function delete_template() {
		$data = $this->data;
		if (empty($data)) {
			$this->redirect(array('controller' => 'Template', 'action' => 'index'));
		}
		$info_template = $this->T30Template->getScriptByScriptId($data['template_id']);
		$info_ques = $this->T31TemplateQuestion->getQuesByTemplateId($data['template_id']);
		$info_answ = $this->T32TemplateButton->getAnwsByScriptId($data['template_id']);

		$dsT30Template = $this->T30Template->getDataSource();
		$dsT31TemplateQuestion = $this->T31TemplateQuestion->getDataSource();
		$dsT32TemplateButton = $this->T32TemplateButton->getDataSource();

		$dsT30Template->begin($this);
		$dsT31TemplateQuestion->begin($this);
		$dsT32TemplateButton->begin($this);

		//スクリプト削除
		$T30Template = array();
		$T30Template['id'] = $info_template["T30Template"]["id"];
		$T30Template['del_flag'] = 'Y';
		$T30Template['update_program'] = $this->name.'_'.__FUNCTION__;
		$T30Template['update_user'] = $this->ESession->getUserId($this);
		$flag = $this->T30Template->save($T30Template);
		if(!$flag){
			$dsT30Template->rollback($this);
			$this->log("スクリプト削除：失敗", "debug");
			$this->redirect(array('controller' => 'Login', 'action' => 'index/systemerror'));
		}
		//質問削除
		foreach($info_ques as $ques){
			$this->T31TemplateQuestion->create();
			$T31TemplateQuestion = array();
			$T31TemplateQuestion['id'] = $ques["T31TemplateQuestion"]["id"];
			$T31TemplateQuestion['del_flag'] = 'Y';
			$T31TemplateQuestion['update_program'] = $this->name.'_'.__FUNCTION__;
			$T31TemplateQuestion['update_user'] = $this->ESession->getUserId($this);
			$flag = $this->T31TemplateQuestion->save($T31TemplateQuestion);
			if(!$flag){
				$dsT30Template->rollback($this);
				$dsT31TemplateQuestion->rollback($this);
				$this->log("質問削除：失敗", "debug");
				$this->redirect(array('controller' => 'Login', 'action' => 'index/systemerror'));
			}
		}
		//回答削除
		foreach($info_answ as $answ){
			$this->T32TemplateButton->create();
			$T32TemplateButton = array();
			$T32TemplateButton['id'] = $answ["T32TemplateButton"]["id"];
			$T32TemplateButton['del_flag'] = 'Y';
			$T32TemplateButton['update_program'] = $this->name.'_'.__FUNCTION__;
			$T32TemplateButton['update_user'] = $this->ESession->getUserId($this);
			$flag = $this->T32TemplateButton->save($T32TemplateButton);
			if(!$flag){
				$dsT30Template->rollback($this);
				$dsT31TemplateQuestion->rollback($this);
				$dsT32TemplateButton->rollback($this);
				$this->log("回答削除：失敗", "debug");
				$this->redirect(array('controller' => 'Login', 'action' => 'index/systemerror'));
			}
		}
		$dsT30Template->commit($this);
		$dsT31TemplateQuestion->commit($this);
		$dsT32TemplateButton->commit($this);
		$this->redirect(array('controller' => 'Script', 'action' => 'index/delete'));

	}

	function upload_file() {
		$data = $this->data;
		if (empty($data) || is_uploaded_file($data['File']['tmp_name']) == false) {
			//ファイルがない場合（万が一）
			$this->redirect(array('controller' => 'Login', 'action' => 'index/systemerror'));
		}else{
			//insert t89
			$dsT89ManageFile = $this->T89ManageFile->getDataSource();
			$dsT89ManageFile->begin($this);

			$tmpName = $data['File']['tmp_name'];
			$tmpNamePcm = $tmpName.".pcm";
			exec('sox -t wav '.$tmpName.' -b 8 -c 1 -r 8000 -t ul '.$tmpNamePcm, $shell_result, $shell_result_status);

			$tmpNameMp3 = $tmpName.".mp3";
			exec('ffmpeg -i '.$tmpName.' -ab 256k '.$tmpNameMp3, $shell_result, $shell_result_status);
			//wav形式がpcm形式に変換する
			if($shell_result_status != 0){
				$this->log($shell_result);
				$this->log("アップロードファイルが変換：失敗", "debug");
				echo "err_pcm";
				exit;
			}
			$fp = fopen($tmpName, 'r');
			$wav_content = fread($fp, filesize($tmpName));
			fclose($fp);
			$fp = fopen($tmpNameMp3, 'r');
			$mp3_content = fread($fp, filesize($tmpNameMp3));
			fclose($fp);
			$fp = fopen($tmpNamePcm, 'r');
			$pcm_content = fread($fp, filesize($tmpNamePcm));
			fclose($fp);
			$T89ManageFile = array();
			$T89ManageFile["file_name"] = $data['File']['name'];
			$T89ManageFile["file_size"] = $data['File']['size'];
			$T89ManageFile["file_contents"] = $wav_content;
			$T89ManageFile["file_pcm_contents"] = $pcm_content;
			$T89ManageFile["file_mp3_size"] = filesize($tmpNameMp3);
			$T89ManageFile["file_mp3_contents"] = $mp3_content;
			$T89ManageFile["entry_user"] = $this->ESession->getUserId($this);
			$T89ManageFile["entry_program"] = $this->name.'_'.__FUNCTION__;
			$T89ManageFile["update_user"] = $this->ESession->getUserId($this);
			$T89ManageFile["update_program"] = $this->name.'_'.__FUNCTION__;

			$flag = $this->T89ManageFile->save($T89ManageFile);
			$audio_id = $this->T89ManageFile->getLastInsertID();
			if(!$flag){
				$dsT89ManageFile->rollback($this);
				$this->log("アップロードファイル：失敗", "debug");
				echo "err_db";
			}
			$dsT89ManageFile->commit($this);
			echo $audio_id;
		}
		exit;
	}

	function read_file($id){
		$this->layout = "ajax";
		$fileInfo = $this->T89ManageFile->getInfoFile($id);
		$file_size = $fileInfo["T89ManageFile"]["file_mp3_size"];
		$file_name = $fileInfo["T89ManageFile"]["file_name"];
		header('Content-Description: File Transfer');
		header("Content-type: audio/mpeg ");
		header('Content-Disposition: attachment; filename='.$file_name);
		header('Content-Transfer-Encoding: binary');
		header('Content-Length: ' . $file_size);
		echo $fileInfo["T89ManageFile"]["file_mp3_contents"];
		exit;
	}

	function buffer_template_data(){
		$data = $this->data;
		if (empty($data)) {
			echo 'systemerror';
			exit;
		}
		$template_id = $data['template_id'];

		$questions = $this->T31TemplateQuestion->getQuesByTemplateId($template_id);
		$wavfiles = array();
		$template_question_data = Array();

		foreach ($questions as $question) {
			$r = Array();
            if($question['T31TemplateQuestion']["question_type"] == QUESTION_SMS || $question['T31TemplateQuestion']["question_type"] == QUESTION_SMS_INPUT){
                echo "err_exist_question_sms";
                exit;
            }
			if (in_array($question['T31TemplateQuestion']["question_type"], array(QUESTION_VOICE, QUESTION_BASIC, QUESTION_AUTH, QUESTION_TEL, QUESTION_TRANS, QUESTION_RECORD, QUESTION_COUNT, QUESTION_END, QUESTION_TIMEOUT, QUESTION_AUTH_CHAR))) {
				array_push($r, $question['T31TemplateQuestion']['question_no']);
				array_push($r, $question['T31TemplateQuestion']['question_type']);
				array_push($r, $question['T31TemplateQuestion']['question_title']);
			}

			if (in_array($question['T31TemplateQuestion']["question_type"], array(QUESTION_BASIC, QUESTION_AUTH, QUESTION_AUTH_CHAR))) {
				array_push($r, $question['T31TemplateQuestion']['question_yuko']);
			}

			if (in_array($question['T31TemplateQuestion']["question_type"], array(QUESTION_VOICE, QUESTION_BASIC, QUESTION_AUTH, QUESTION_TEL, QUESTION_RECORD, QUESTION_COUNT, QUESTION_AUTH_CHAR))) { //20160325 Edit by Canh : カウントセクションで飛び先項目を追加する
				array_push($r, $question['T31TemplateQuestion']['jump_question']);
			}

			if (in_array($question['T31TemplateQuestion']["question_type"], array(QUESTION_VOICE, QUESTION_BASIC, QUESTION_AUTH, QUESTION_TEL, QUESTION_TRANS, QUESTION_RECORD, QUESTION_TIMEOUT, QUESTION_AUTH_CHAR))) {
				array_push($r, $question['T31TemplateQuestion']['audio_type']);
				$audio_content = trim(preg_replace('/\s\s+/', ' ', $question['T31TemplateQuestion']['audio_content']));
				array_push($r, $audio_content);
				$file = $this->T89ManageFile->getFileById($question['T31TemplateQuestion']['audio_id']);
				$filename = '';
				if(!empty($file)) {
					$filename = 'q'.$question['T31TemplateQuestion']['question_no'] . '.wav';
					$wavfiles[$filename] = $file['T89ManageFile']['file_contents'];
				}
				array_push($r, $filename);
			}

			if ($question['T31TemplateQuestion']["question_type"] == QUESTION_BASIC) {
				array_push($r, $question['T31TemplateQuestion']['question_repeat']);
				$template_ans = $this->T32TemplateButton->getAnwsByQuestionNo($template_id, $question['T31TemplateQuestion']['question_no']);
				foreach ($template_ans as $ans) {
					array_push($r, $ans['T32TemplateButton']['answer_no']);
					array_push($r, $ans['T32TemplateButton']['answer_content']);
					array_push($r, $ans['T32TemplateButton']['jump_question']);
					if ($ans['T32TemplateButton']['answer_no'] != 99) {
						array_push($r, $ans['T32TemplateButton']['yuko_flag']);
					}
				}
			} else if ($question['T31TemplateQuestion']["question_type"] == QUESTION_AUTH || $question['T31TemplateQuestion']["question_type"] == QUESTION_AUTH_CHAR) {
				array_push($r, $question['T31TemplateQuestion']['auth_item']);
				array_push($r, $question['T31TemplateQuestion']['digit']);

				$template_ans = $this->T32TemplateButton->getAnwsByQuestionNo($template_id, $question['T31TemplateQuestion']['question_no']);
				foreach ($template_ans as $ans) {
					array_push($r, $ans['T32TemplateButton']['answer_no']);
					array_push($r, $ans['T32TemplateButton']['answer_content']);
					array_push($r, $ans['T32TemplateButton']['jump_question']);
					if ($ans['T32TemplateButton']['answer_no'] != 99) {
						array_push($r, $ans['T32TemplateButton']['yuko_flag']);
					}
				}
				array_push($r, $question['T31TemplateQuestion']['recheck_flag']);
				array_push($r, $question['T31TemplateQuestion']['recheck_audio_type']);
				$recheck_audio_content = trim(preg_replace('/\s\s+/', ' ', $question['T31TemplateQuestion']['recheck_audio_content']));
				array_push($r, $recheck_audio_content);

				$file = $this->T89ManageFile->getFileById($question['T31TemplateQuestion']['recheck_audio_id']);
				$filename = '';
				if(!empty($file)) {
					$filename = 'q'.$question['T31TemplateQuestion']['question_no'] . '_1.wav';
					$wavfiles[$filename] = $file['T89ManageFile']['file_contents'];
				}
				array_push($r, $filename);
				array_push($r, $question['T31TemplateQuestion']['recheck_button_next']);
			} else if ($question['T31TemplateQuestion']["question_type"] == QUESTION_TEL) {
				array_push($r, $question['T31TemplateQuestion']['digit']);

				//20160304 Add by Thai : ADD jump_question for timeout of QUESTION_TEL - Begin
				$template_ans = $this->T32TemplateButton->getAnwsByQuestionNo($template_id, $question['T31TemplateQuestion']['question_no']);
				if (count($template_ans) > 0) {
					$ans = $template_ans[0];
					array_push($r, $ans['T32TemplateButton']['answer_no']);
					array_push($r, $ans['T32TemplateButton']['answer_content']);
					array_push($r, $ans['T32TemplateButton']['jump_question']);
				} else {
					array_push($r, '');
					array_push($r, '');
					array_push($r, '');
				}
				//20160304 Add by Thai : ADD jump_question for timeout of QUESTION_TEL - End

				array_push($r, $question['T31TemplateQuestion']['recheck_flag']);
				array_push($r, $question['T31TemplateQuestion']['recheck_audio_type']);
				$recheck_audio_content = trim(preg_replace('/\s\s+/', ' ', $question['T31TemplateQuestion']['recheck_audio_content']));
				array_push($r, $recheck_audio_content);

				$file = $this->T89ManageFile->getFileById($question['T31TemplateQuestion']['recheck_audio_id']);
				$filename = '';
				if(!empty($file)) {
					$filename = 'q'.$question['T31TemplateQuestion']['question_no'] . '_1.wav';
					$wavfiles[$filename] = $file['T89ManageFile']['file_contents'];
				}
				array_push($r, $filename);
				array_push($r, $question['T31TemplateQuestion']['recheck_button_next']);
			} else if ($question['T31TemplateQuestion']["question_type"] == QUESTION_TRANS){
				array_push($r, $question['T31TemplateQuestion']['trans_timeout_audio_type']);
				$trans_timeout_audio_content = trim(preg_replace('/\s\s+/', ' ', $question['T31TemplateQuestion']['trans_timeout_audio_content']));
				array_push($r, $trans_timeout_audio_content);

				$file = $this->T89ManageFile->getFileById($question['T31TemplateQuestion']['trans_timeout_audio_id']);
				$filename = '';
				if(!empty($file)) {
					$filename = 'q'.$question['T31TemplateQuestion']['question_no'] . '_1.wav';
					$wavfiles[$filename] = $file['T89ManageFile']['file_contents'];
				}
				array_push($r, $filename);
				array_push($r, $question['T31TemplateQuestion']['trans_tel']);
				array_push($r, $question['T31TemplateQuestion']['trans_seat_num']);
				array_push($r, $question['T31TemplateQuestion']['trans_empty_seat_flag']);
				array_push($r, $question['T31TemplateQuestion']['trans_timeout']);
				array_push($r, $question['T31TemplateQuestion']['yuko_button_record']);
			} else if ($question['T31TemplateQuestion']["question_type"] == QUESTION_RECORD){
				array_push($r, $question['T31TemplateQuestion']['second_record']);
				array_push($r, $question['T31TemplateQuestion']['yuko_button_record']);
			}
			//$this->Csv->addRow($r,'|',false);
			$template_question_data[] = $r;
		}

		$this->ESession->setTemplateQuestionDataDownload($template_question_data, $this);
		$this->ESession->setTemplateWavFileDownload($wavfiles, $this);

		echo 'success';
		exit;
	}

	function download_file($template_id = null){
		$template_question_data = $this->ESession->getTemplateQuestionDataDownload($this);
		$wavfiles = $this->ESession->getTemplateWavFileDownload($this);
		if(!isset($template_question_data) || !isset($wavfiles) || !isset($template_id)){
			$this->redirect(array('controller' => 'Template', 'action' => 'index'));
		}

		$template = $this->T30Template->getInfoTemplateById($template_id);
		$template_name = $template["T30Template"]["template_name"];
		$file_out_name = date('Ymdhis', time()) . '_' . $template_name . '.zip';
		$file_out_name = mb_convert_encoding($file_out_name, "SJIS-win", "UTF-8");
		$this->Csv->createZip($file_out_name);
		$this->Csv->addRow(array($template["T30Template"]["template_name"],$template["T30Template"]["description"]),'|',false);

		foreach ($template_question_data as $question_data) {
			$this->Csv->addRow($question_data, '|', false);
		}

		$title_csv = $template_name . '.csv';
		$title_csv = mb_convert_encoding($title_csv, "SJIS-win", "UTF-8");
		$this->Csv->addToZip($title_csv, "SJIS-win");
		$this->Csv->clear();
		foreach ($wavfiles as $name => $content) {
			$this->Csv->addFile($name, $content);
		}

		$this->Session->delete('template_question_data');
		$this->Session->delete('template_wav_file');
		echo $this->Csv->renderZip('SJIS-win');
		exit;
	}

	function check_delete_template() {
		$data = $this->data;
		$template_ids = $data['template_ids'];
		foreach ($template_ids as $id) {
			$template = $this->T30Template->getInfoTemplateById($id);
			//20160404 Edit by Thai : check exist when delete template - Begin
			if (!isset($template["T30Template"]["id"]) || empty($template["T30Template"]["id"])) {
				$result = array(
					'status' => 'err_not_exist',
					'template_id' => $id
				);
				echo json_encode($result);
				exit;
			}
			//20160404 Edit by Thai : check exist when delete template - End

			$info_schedules = $this->T20OutSchedule->getScheduleNotFinishByTemplateId($template["T30Template"]["id"]);
			if (isset($info_schedules["T20OutSchedule"]["id"]) && !empty($info_schedules["T20OutSchedule"]["id"])) {
				$result = array(
					'status' => 'err_exist_schedule',
					'template_id' => $id
				);
				echo json_encode($result);
				exit;
			}
		}
		$result = array(
			'status' => 'can_delete',
		);
		echo json_encode($result);
		exit;
	}

	function check_exist_template() {
		$template_id = $this->data['template_id'];
		if(isset($template_id) && !empty($template_id)){
			$info_template = $this->T30Template->getInfoTemplateById($template_id);
			if(!isset($info_template["T30Template"]["id"]) || empty($info_template["T30Template"]["id"])){
				//スクリプト存在しない
				echo "err_not_exist";
				exit;
			}
		}
		exit;
	}

	function check_exist_templatename() {
		//作成パタンと更新パタン
		$data = $this->data;
		$company_id = $this->ESession->getUserCompanyId($this);
		$info_template = $this->T30Template->getTemplateByTemplateName($data['template_name'], $company_id, TEMPLATE_OUTBOUND);
		if(isset($info_template["T30Template"]["id"]) &&
				!empty($info_template["T30Template"]["id"]) &&
				$info_template["T30Template"]["id"] != $data['template_id']
		){
			echo "false";
		}else{
			echo "true";
		}
		exit;
	}

    function get_question_type($ques_type){
        $arr_ques_type = array(
            QUESTION_AUTH => '数値認証',
            QUESTION_AUTH_CHAR => '文字列認証',
            QUESTION_BASIC => '質問',
            QUESTION_COUNT => 'カウント',
            QUESTION_END => '切断',
            QUESTION_RECORD => '録音',
            QUESTION_TEL => '番号入力',
            QUESTION_TRANS => '転送',
            QUESTION_VOICE => '再生',
            QUESTION_TIMEOUT => 'タイムアウト',
            QUESTION_SMS => 'SMS',
            QUESTION_SMS_INPUT => '番号指定SMS送信'
        );

        return $arr_ques_type[$ques_type];
    }

}
