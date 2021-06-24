<?php
App::uses('AppController', 'Controller');

class InboundTemplateController extends AppController {
	var $name = 'InboundTemplate';
	var $uses = Array(
		'M02Company', 
		'M90PulldownCode', 
		'T30Template', 
		'T31TemplateQuestion', 
		'T32TemplateButton', 
		'T89ManageFile',
		'M04ControllerAction', 
		'T33QuestionAudio', 
		'T92Lock', 
		'T13InboundListItem', 
		'T25Inbound', 
		'M92LimitFunction', 
		'M08SmsApiInfo'
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
			$this->set('del_count', $del_count); /*20160311 Add by Giang : #6695 - display the record quantity has been deleted*/
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
			$arr_templates = $this->T30Template->getTemplateByCompanyId($company_id, TEMPLATE_INBOUND, $limit, $page, $sort_order[0], $filter);
		}else{
			$arr_templates = $this->T30Template->getTemplateByCompanyId($company_id, TEMPLATE_INBOUND, $limit, $page, null, $filter);
		}
		$json_data["total_rows"] = $this->T30Template->getTemplateByCompanyIdCount($company_id, TEMPLATE_INBOUND, $filter);
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
			$this->redirect(array('controller' => 'InboundTemplate', 'action' => 'index'));
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

		$this->redirect(array('controller' => 'InboundTemplate', 'action' => 'index/delete/' . count($template_ids))); /*20160311 Edit by Giang : #6695 - display the record quantity has been deleted*/
	}

	// テンプレート詳細画面を表示するアクション
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
					"auth_match_flag" => $ques["T31TemplateQuestion"]["auth_match_flag"],//20160406 Add by Thai : #6722 - Add item for QUESTION_AUTH
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
					"digit_fax" => $ques["T31TemplateQuestion"]["digit"],
					"digit_prop" => $ques["T31TemplateQuestion"]["digit"],

					"bukken_audio_id" => $ques["T31TemplateQuestion"]["bukken_audio_id"],
					"bukken_audio_name" => $ques["T31TemplateQuestion"]["bukken_audio_name"],
					"bukken_audio_type" => $ques["T31TemplateQuestion"]["bukken_audio_type"],
					"bukken_audio_content" => $ques["T31TemplateQuestion"]["bukken_audio_content"],
					"bukken_diagram_audio_id" => $ques["T31TemplateQuestion"]["bukken_diagram_audio_id"],
					"bukken_diagram_audio_name" => $ques["T31TemplateQuestion"]["bukken_diagram_audio_name"],
					"bukken_diagram_audio_type" => $ques["T31TemplateQuestion"]["bukken_diagram_audio_type"],
					"bukken_diagram_audio_content" => $ques["T31TemplateQuestion"]["bukken_diagram_audio_content"],
					"bukken_cont_audio_id" => $ques["T31TemplateQuestion"]["bukken_cont_audio_id"],
					"bukken_cont_audio_name" => $ques["T31TemplateQuestion"]["bukken_cont_audio_name"],
					"bukken_cont_audio_type" => $ques["T31TemplateQuestion"]["bukken_cont_audio_type"],
					"bukken_cont_audio_content" => $ques["T31TemplateQuestion"]["bukken_cont_audio_content"],

					"bukken_answer_no" => $ques["T31TemplateQuestion"]["bukken_answer_no"],
					"bukken_diagram_answer_no" => $ques["T31TemplateQuestion"]["bukken_diagram_answer_no"],
					"ques_property_cost_digit" => $ques["T31TemplateQuestion"]["digit"],
					"ques_property_cost_audio_id" => $ques["T31TemplateQuestion"]["audio_id"],
					"ques_property_cost_audio_name" => $ques["T31TemplateQuestion"]["audio_name"],
					"ques_property_cost_audio_type" => $ques["T31TemplateQuestion"]["audio_type"],
					"ques_property_cost_audio_content" => $ques["T31TemplateQuestion"]["audio_content"],

					"ques_property_square_digit" => $ques["T31TemplateQuestion"]["square_digit"],
					"ques_property_square_audio_id" => $ques["T31TemplateQuestion"]["square_audio_id"],
					"ques_property_square_audio_name" => $ques["T31TemplateQuestion"]["square_audio_name"],
					"ques_property_square_audio_type" => $ques["T31TemplateQuestion"]["square_audio_type"],
					"ques_property_square_audio_content" => $ques["T31TemplateQuestion"]["square_audio_content"],

					"ques_property_confirm_answer_no" => $ques["T31TemplateQuestion"]["bukken_answer_no"],
					"ques_property_confirm_audio_id" => $ques["T31TemplateQuestion"]["bukken_audio_id"],
					"ques_property_confirm_audio_name" => $ques["T31TemplateQuestion"]["bukken_audio_name"],
					"ques_property_confirm_audio_type" => $ques["T31TemplateQuestion"]["bukken_audio_type"],
					"ques_property_confirm_audio_content" => $ques["T31TemplateQuestion"]["bukken_audio_content"],

					"jump_question" => $ques["T31TemplateQuestion"]["jump_question"],
					"ques_property_continue_audio_id" => $ques["T31TemplateQuestion"]["bukken_cont_audio_id"],
					"ques_property_continue_audio_name" => $ques["T31TemplateQuestion"]["bukken_cont_audio_name"],
					"ques_property_continue_audio_type" => $ques["T31TemplateQuestion"]["bukken_cont_audio_type"],
					"ques_property_continue_audio_content" => $ques["T31TemplateQuestion"]["bukken_cont_audio_content"],

					"smsPhoneNumber" => $ques["T31TemplateQuestion"]["sms_display_number"],
					"smsBodyContent" => $ques["T31TemplateQuestion"]["sms_content"],
					"sms_use_short_url" => $ques["T31TemplateQuestion"]["yuko_button_record"],
					"ques_inbound_sms_audio_type" => $ques["T31TemplateQuestion"]["sms_error_audio_type"],
					"ques_sms_inbound_audio_name" => $ques["T31TemplateQuestion"]["sms_error_audio_name"],
					"ques_sms_inbound_audio_id" => $ques["T31TemplateQuestion"]["sms_error_audio_id"],
					"ques_inbound_sms_audio_content" => $ques["T31TemplateQuestion"]["sms_error_audio_content"],
					"trans_phone_number_play_flag" => $ques["T31TemplateQuestion"]["yuko_button_record"],

					"ques_inbound_sms_input_audio_type" => $ques["T31TemplateQuestion"]["sms_error_audio_type"],
					"ques_sms_input_inbound_audio_name" => $ques["T31TemplateQuestion"]["sms_error_audio_name"],
					"ques_sms_input_inbound_audio_id" => $ques["T31TemplateQuestion"]["sms_error_audio_id"],
					"ques_inbound_sms_input_audio_content" => $ques["T31TemplateQuestion"]["sms_error_audio_content"],
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

				// その質問の回答（飛び先）などを設定する
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
					} else if($ques["T31TemplateQuestion"]["question_type"] == QUESTION_FAX){
						if($action == "update"){
							$answArr["hdAnswId".$answ_no] = $answ["T32TemplateButton"]["id"];
						}
						$answArr["txtAnswJumpFax".$answ_no] = $answ["T32TemplateButton"]["jump_question"];
					} else if($ques["T31TemplateQuestion"]["question_type"] == QUESTION_PROPERTY){
						if($action == "update"){
							$answArr["hdAnswId".$answ_no] = $answ["T32TemplateButton"]["id"];
						}

						if ($answ_no != 99) {
							$answArr["txtAnswJumpProp0"] = $answ["T32TemplateButton"]["jump_question"];
							$quesArr['bukken_cont_answer_no'] = $answ_no;
						} else {
							$answArr["txtAnswJumpProp".$answ_no] = $answ["T32TemplateButton"]["jump_question"];
						}
					} else if($ques["T31TemplateQuestion"]["question_type"] == QUESTION_PROPERTY_SEARCH){
						if($action == "update"){
							$answArr["hdAnswId".$answ_no] = $answ["T32TemplateButton"]["id"];
						}

						if ($answ_no != 99) {
							$answArr["txtAnswJumpProp0"] = $answ["T32TemplateButton"]["jump_question"];
							$quesArr['bukken_cont_answer_no'] = $answ_no;
						} else {
							$answArr["txtAnswJumpProp".$answ_no] = $answ["T32TemplateButton"]["jump_question"];
						}
					}else if($ques["T31TemplateQuestion"]["question_type"] == QUESTION_INBOUND_SMS){
						if($action == "update"){
							$answArr["hdAnswId".$answ_no] = $answ["T32TemplateButton"]["id"];
						}
						//送信不可の飛び先 (question_no = 99)
						$answArr["txtAnswJumpSms".$answ_no] = $answ["T32TemplateButton"]["jump_question"];
					}else if($ques["T31TemplateQuestion"]["question_type"] == QUESTION_INBOUND_COLLATION){
						if($action == "update"){
							$answArr["hdAnswId".$answ_no] = $answ["T32TemplateButton"]["id"];
						}
						$answArr["txtAnswJumpInboundCollation".$answ_no] = $answ["T32TemplateButton"]["jump_question"];
					}else if($ques["T31TemplateQuestion"]["question_type"] == QUESTION_INBOUND_SMS_INPUT){
						if($action == "update"){
							$answArr["hdAnswId".$answ_no] = $answ["T32TemplateButton"]["id"];
						}

						if($answ_no == 98){
							//タイムアウトの飛び先(question_no = 98)
							$answArr["txtAnswJumpSmsInputTimeOut".$answ_no] = $answ["T32TemplateButton"]["jump_question"];
						}else{
							//送信不可の飛び先 (question_no = 99)
							$answArr["txtAnswJumpSmsInput".$answ_no] = $answ["T32TemplateButton"]["jump_question"];
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
				//20160408 Update by Thai : Fix check setting inbound not FINISH when edit inbound_template - Begin
				$info_setting_inbound = $this->T25Inbound->getInboundNotFinishByTemplateId($template_id);
				if (isset($info_setting_inbound["T25Inbound"]["id"]) && !empty($info_setting_inbound["T25Inbound"]["id"])) {
					$this->set('exist_setting_inbound', true);
				}
				//20160408 Update by Thai : Fix check setting inbound not FINISH when edit inbound_template - End
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
		$arr_company_info = $this->M02Company->getCompanyByCompanyId($this->ESession->getUserCompanyId($this));
		$limit_functions = $this->M92LimitFunction->getLimitFuncByCompany($company_id, TEMPLATE_INBOUND, 'template_section');
		// ここに値を設定すると、m92で利用可能と設定していない限り
		// インバウンドのセクションの種類プルダウンに表示されない。
        $without_item_codes = array(
            QUESTION_PROPERTY,
            QUESTION_FAX,
            QUESTION_SMS,
            QUESTION_PROPERTY_SEARCH,
            QUESTION_SMS_INPUT
        );
		foreach ($without_item_codes as $key => $ques_type) {
			if (isset($limit_functions[$ques_type])) {
				unset($without_item_codes[$key]);
			}
		}
		$company_id = $this->ESession->getUserCompanyId($this);
		$ques_type = $this->M90PulldownCode->getSelectOption("template_ques", $without_item_codes);
		$audio_mix_flag = $arr_company_info["M02Company"]["audio_mix_flag"];
		$audio_mix_item = $this->T13InboundListItem->getListItemNameByCompany($this->ESession->getUserCompanyId($this));
		$auth_item = $this->T13InboundListItem->getListItemNameByCompany($this->ESession->getUserCompanyId($this));
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
			//20160418 Edit by Thai : #6722 - Validate template_name different busy - Begin
			if ($t30Template[0] == 'busy') {
				$import_flag = false;
				$message_error .= "テンプレート名は「busy」以外を指定してください。<br>";
			} else {
				$info_template = $this->T30Template->getTemplateByTemplateName($t30Template[0], $company_id, TEMPLATE_INBOUND);
				if (isset($info_template["T30Template"]["id"]) && !empty($info_template["T30Template"]["id"])) {
					$import_flag = false;
					$message_error .= "指定したテンプレート名は既に使用されています。<br>";
				} else {
					$template_name = trim(preg_replace('/\s\s+/', ' ', $t30Template[0]));
					$description = trim(preg_replace('/\s\s+/', ' ', $t30Template[1]));
				}
			}
			//20160418 Edit by Thai : #6722 - Validate template_name different busy - End
		}

		$result = Array('message_error' => $message_error, 'import_flag' => $import_flag, 'template_name' => $template_name, 'description' => $description, 'csv' => $csv);
		return $result;
	}

	function import() {
		if($this->request->is('post')) {
			//ZIP                  =====================================================================================
			$zip = new ZipArchive();
			$zip_file_tmp = $_FILES['files']['tmp_name'];
			$zip->open($zip_file_tmp);
			$this->layout = false;

			$user_id = $this->ESession->getUserId($this);
			$company_id = $this->ESession->getUserCompanyId($this);
			$info_company = $this->M02Company->getCompanyByCompanyId($this->ESession->getUserCompanyId($this));
			$audio_mix_flag = $info_company["M02Company"]["audio_mix_flag"];

			//1. get file txt, wav =====================================================================================
			$zip_array = $this->check_file_import($zip);
			$filenameArr = $zip_array['filenameArr'];
			$import_flag = $zip_array['import_flag'];
			$message_error = $zip_array['message_error'];
			$file_text_name = $zip_array['file_text_name'];

			if (!$import_flag) {
				$staArr = array(
					'code' => 501,
					'status' => 'failed',
					'message' => $message_error,
				);
				header('Content-type: text/json');
				header('Content-type: application/json');
				echo json_encode($staArr);
				exit;
			}

			//2. Read file txt =========================================================================================
			$csv = array();
			$fp = $zip->getStream($file_text_name);
			while (!feof($fp)) {
				$csv[] = fgets($fp);
			}

			$file_csv = $this->check_file_csv($csv, $company_id);
			$csv = $file_csv['csv'];
			if (!$file_csv['import_flag']) {
				$staArr = array(
					'code' => 501,
					'status' => 'failed',
					'message' => $file_csv['message_error'],
				);
				header('Content-type: text/json');
				header('Content-type: application/json');
				echo json_encode($staArr);
				exit;
			}

			//3. Get value and check  ==================================================================================
			$template = array();
			$template["T30Template"]["template_name"] = $file_csv['template_name'];
			$template["T30Template"]["template_type"] = TEMPLATE_INBOUND;
			$template["T30Template"]["description"] = $file_csv['description'];
			$template["T30Template"]["company_id"] = $company_id;
			$template["T30Template"]["entry_user"] = $user_id;
			$template["T30Template"]["entry_program"] = 'Template_import';
			$template["T30Template"]["update_user"] = $user_id;
			$template["T30Template"]["update_program"] = 'Template_import';
			$max_template_no = $this->T30Template->getMaxTemplateNoByCompanyId($company_id, TEMPLATE_INBOUND);
			if ($max_template_no) {
				$template["T30Template"]["template_no"] = $max_template_no["T30Template"]["template_no"] + 1;
			} else {
				$template["T30Template"]["template_no"] = 1;
			}

			$templateQuestions = array();
			$templateButtons = array();

			$ques_type_5 = 0;
			$ques_type_6 = 0;
			$ques_type_9 = 0;
			$count_ques_auth = 0;//20160406 Add by Thai : #6722 - Add item for QUESTION_AUTH

			$line = 1;
			$fileArray = array();
			$arr_ques_nos = array();
			foreach ($csv as $value) {
				$value_convert = mb_convert_encoding($value, "UTF-8", "SJIS");
				$templateValue = explode("|", $value_convert);
				if (isset($templateValue[1]) && $templateValue[1] != QUESTION_TIMEOUT) {
					$arr_ques_nos[] = $templateValue[0];
				}
			}

			$arr_message_error = array();
			$fileArray2 = array();
			foreach ($csv as $key => $value) {
				$line_error = "";
				$value_convert = mb_convert_encoding($value, "UTF-8", "SJIS");
				$templateValue = explode("|", $value_convert);
				$question_no = $templateValue[0];
				$question_type = $templateValue[1];

				if ($question_no != $line) {
					$import_flag = false;
					$line_error .= "質問NOが正しくありません, ";
				}
				if (!in_array($question_type, array(QUESTION_VOICE, QUESTION_BASIC, QUESTION_AUTH, QUESTION_AUTH_CHAR, QUESTION_TEL, QUESTION_TRANS, QUESTION_RECORD, QUESTION_COUNT, QUESTION_END, QUESTION_TIMEOUT, QUESTION_PROPERTY, QUESTION_FAX))) {
					$import_flag = false;
					++$line;
					$arr_message_error[$line] = '質問種類が正しくありません';
					continue;
				}
				// Company limit check
				if(in_array($question_type, array(QUESTION_PROPERTY, QUESTION_FAX))){
					$limit_functions = $this->M92LimitFunction->getLimitFuncByCompany($company_id, TEMPLATE_INBOUND, 'template_section');
					if(empty($limit_functions)){						
						$import_flag = false;
						++$line;
						$arr_message_error[$line] = '質問種類が正しくありません';
						continue;
					}					
				}
				$templateQuestion = array();
				$templateQuestion["T31TemplateQuestion"]["question_no"] = $question_no;
				$templateQuestion["T31TemplateQuestion"]["question_type"] = $question_type;
				$templateQuestion["T31TemplateQuestion"]["question_title"] = trim(preg_replace('/\s\s+/', ' ', $templateValue[2]));
				$templateQuestion["T31TemplateQuestion"]["entry_user"] = $user_id;
				$templateQuestion["T31TemplateQuestion"]["entry_program"] = 'Template_import';
				$templateQuestion["T31TemplateQuestion"]["update_user"] = $user_id;
				$templateQuestion["T31TemplateQuestion"]["update_program"] = 'Template_import';

				$ques_format = $this->get_ques_format($question_type);

				//check count element
				if (count($templateValue) != $ques_format['element_count']) {
					$import_flag = false;
					++$line;
					$arr_message_error[$line] = '質問の入力形式が正しくありません';
					continue;
				}
				//check jump_question
				if (isset($ques_format['jump_question'])) {
					$jump_question = $templateValue[$ques_format['jump_question']['position']];
					$jump_question = trim(preg_replace('/\s\s+/', ' ', $jump_question));
					if ($ques_format['jump_question']['required']) {
						if ($jump_question == '' || !in_array($jump_question, $arr_ques_nos)) {
							$import_flag = false;
							$line_error .= "飛び先は正しくありません, ";
						} else {
							$templateQuestion["T31TemplateQuestion"]["jump_question"] = $jump_question;
						}
					} else {
						if ($jump_question != '' && !in_array($jump_question, $arr_ques_nos)) {
							$import_flag = false;
							$line_error .= "飛び先は正しくありません, ";
						} else {
							$templateQuestion["T31TemplateQuestion"]["jump_question"] = $jump_question;
						}
					}
				}
				//check audio_type
				// Set default audio_type = 0
				$templateQuestion["T31TemplateQuestion"]["audio_type"] = '0';
				if (isset($ques_format['audio_type'])) {
					$audio_type_position = $ques_format['audio_type']['position'];
					$audio_type = $templateValue[$audio_type_position];
					$audio_content = $templateValue[$audio_type_position + 1];
					$audio_filename = $templateValue[$audio_type_position + 2];
					if (($audio_type != 0 && $audio_type != 1 && $audio_type != 2) || ($audio_mix_flag == 0 && ($audio_type == 1 || $audio_type == 2))){
						$import_flag = false;
						$line_error .= "音声種類が正しくありません, ";
					} else {
						$templateQuestion["T31TemplateQuestion"]["audio_type"] = $audio_type;
						if (($audio_type == 1 || $audio_type == 2) && $audio_content == '') {
							$import_flag = false;
							$line_error .= "音声内容を入力してください, ";
						} elseif ($audio_type == 0 && $audio_filename == '') {
							$import_flag = false;
							$line_error .= "音声ファイルを選択してください, ";
						} else {
							$templateQuestion["T31TemplateQuestion"]["audio_content"] = trim($audio_content);
							$audio_filename = trim(preg_replace('/\s\s+/', ' ', $audio_filename));
							if ($audio_filename) {
								if (in_array($audio_filename, $fileArray)) {
									$import_flag = false;
									$line_error .= "音声ファイル名重複があります, ";
								} elseif (!in_array($audio_filename, $filenameArr)) {
									$import_flag = false;
									$line_error .= $audio_filename."音声ファイルを選択してください, ";
								} else {
									$fileArray[$question_no] = $audio_filename;
									$fileArray2[$line+1]['audio'] = $audio_filename;
								}
							}
						}
					}
				}

				//check question_yuko
				if (isset($ques_format['question_yuko'])) {
					$question_yuko = $templateValue[$ques_format['question_yuko']['position']];
					if (($question_yuko != 0 && $question_yuko != 1)) {
						$import_flag = false;
						$line_error .= "有効質問が正しくありません, ";
					} else {
						$templateQuestion["T31TemplateQuestion"]["question_yuko"] = $question_yuko;
					}
				}
				//check question_repeat
				if (isset($ques_format['question_repeat'])) {
					$question_repeat = $templateValue[$ques_format['question_repeat']['position']];
					$templateQuestion["T31TemplateQuestion"]["question_repeat"] = $question_repeat;
				}
				//check auth_item
				if (isset($ques_format['auth_item'])) {
					$auth_item = $templateValue[$ques_format['auth_item']['position']];
					$templateQuestion["T31TemplateQuestion"]["auth_item"] = $auth_item;
				}
				//20160406 Add by Thai : #6722 - Add item for QUESTION_AUTH - Begin
				//check auth_match_flag
				//20160418 Add by Thai : #6722 - Validate auth_match_flag - Begin
				if ($question_type == QUESTION_AUTH || $question_type == QUESTION_AUTH_CHAR) {
					if ($count_ques_auth == 0) {
						if (isset($ques_format['auth_match_flag']) && $templateValue[$ques_format['auth_match_flag']['position']] == 1) {
							$templateQuestion["T31TemplateQuestion"]["auth_match_flag"] = $templateValue[$ques_format['auth_match_flag']['position']];
						} else {
							$import_flag = false;
							$line_error .= "認証項目のセクションが存在しますが、着信リスト照合のセクションが存在しないため登録できません, ";
						}
					} else {
						if (isset($ques_format['auth_match_flag']) && $templateValue[$ques_format['auth_match_flag']['position']] == 1) {
							$import_flag = false;
							$line_error .= "着信リスト照合より前に着信リストを参照するセクションが含まれているため登録できません, ";
						}
					}
					$count_ques_auth++;
				}
				//20160418 Add by Thai : #6722 - Validate auth_match_flag - End
				//20160406 Add by Thai : #6722 - Add item for QUESTION_AUTH - End
				//check digit
				if (isset($ques_format['digit'])) {
					$digit = $templateValue[$ques_format['digit']['position']];
					if (is_numeric($digit)) {
						$templateQuestion['T31TemplateQuestion']['digit'] = $digit;
					}else{
						$import_flag = false;
						$line_error .= "桁数が正しくありません, ";
					}
				}
				//check recheck_flag
				if (isset($ques_format['recheck_flag'])) {
					$recheck_flag = $templateValue[$ques_format['recheck_flag']['position']];
					if ($ques_format['recheck_flag']['required']) {
						if ($recheck_flag != 1) {
							$import_flag = false;
							$line_error .= "繰返確認フラグが正しくありません, ";
						} else {
							$templateQuestion["T31TemplateQuestion"]["recheck_flag"] = $recheck_flag;
						}
					} else {
						if ($recheck_flag != 0 && $recheck_flag != 1) {
							$import_flag = false;
							$line_error .= "繰返確認フラグが正しくありません, ";
						} else {
							$templateQuestion['T31TemplateQuestion']['recheck_flag'] = $recheck_flag;
						}
					}
				}
				//check recheck_audio_type
				if (isset($ques_format['recheck_audio_type'])) {
					if (isset($ques_format['recheck_flag']) && $templateValue[$ques_format['recheck_flag']['position']] == 1) {
						$recheck_audio_type_position = $ques_format['recheck_audio_type']['position'];
						$recheck_audio_type = $templateValue[$recheck_audio_type_position];
						$recheck_audio_content = $templateValue[$recheck_audio_type_position + 1];
						$recheck_audio_filename = $templateValue[$recheck_audio_type_position + 2];

						if (($recheck_audio_type != 0 && $recheck_audio_type != 1 && $recheck_audio_type != 2) || ($audio_mix_flag == 0 && ($recheck_audio_type == 1 || $recheck_audio_type == 2))) {
							$import_flag = false;
							$line_error .= "繰返確認音声種類が正しくありません, ";
						} else {
							$templateQuestion["T31TemplateQuestion"]["recheck_audio_type"] = $recheck_audio_type;
							if (($recheck_audio_type == 1 || $recheck_audio_type == 2) && empty($recheck_audio_content)) {
								$import_flag = false;
								$line_error .= "繰返確認音声内容を入力してください, ";
							} elseif ($recheck_audio_type == 0 && empty($recheck_audio_filename)) {
								$import_flag = false;
								$line_error .= "繰返確認音声ファイル名を入力してください, ";
							} else {
								$templateQuestion["T31TemplateQuestion"]["recheck_audio_content"] = trim($recheck_audio_content);
								$recheck_audio_filename = trim(preg_replace('/\s\s+/', ' ', $recheck_audio_filename));
								if ($recheck_audio_filename) {
									if (in_array($recheck_audio_filename, $fileArray)) {
										$import_flag = false;
										$line_error .= "繰返確認音声ファイル名重複があります, ";
									} elseif (!in_array($recheck_audio_filename, $filenameArr)) {
										$import_flag = false;
										$line_error .= $recheck_audio_filename."繰返確認音声ファイルを選択してください, ";
									} else {
										$fileArray[$question_no] = $recheck_audio_filename;
										$fileArray2[$line+1]['recheck_audio'] = $recheck_audio_filename;
									}
								}
							}
						}
					}
				}
				//check recheck_button_next
				if (isset($ques_format['recheck_button_next'])) {
					$recheck_button_next = $templateValue[$ques_format['recheck_button_next']['position']];
					if (in_array($recheck_button_next, array(0,1,2,3,4,5,6,7,8,9,51,52)))
						$templateQuestion['T31TemplateQuestion']['recheck_button_next'] = $recheck_button_next;
					else {
						$import_flag = false;
						$line_error .= "正番号が正しくありません , ";
					}
				}
				//check trans_timeout_audio_type
				if (isset($ques_format['trans_timeout_audio_type'])) {
					$trans_timeout_audio_type_position = $ques_format['trans_timeout_audio_type']['position'];
					$trans_timeout_audio_type = $templateValue[$trans_timeout_audio_type_position];
					$trans_timeout_audio_content = $templateValue[$trans_timeout_audio_type_position + 1];
					$trans_timeout_audio_filename = $templateValue[$trans_timeout_audio_type_position + 2];

					if (($trans_timeout_audio_type != 0 && $trans_timeout_audio_type != 1 && $trans_timeout_audio_type != 2) || ($audio_mix_flag == 0 && ($trans_timeout_audio_type == 1 || $trans_timeout_audio_type == 2))) {
						$import_flag = false;
						$line_error .= "転送音声種類が正しくありません, ";
					} else {
						$templateQuestion["T31TemplateQuestion"]["trans_timeout_audio_type"] = $trans_timeout_audio_type;
						if (($trans_timeout_audio_type == 1 || $trans_timeout_audio_type == 2) && empty($trans_timeout_audio_content)) {
							$import_flag = false;
							$line_error .= "転送音声内容を入力してください, ";
						} elseif ($trans_timeout_audio_type == 0 && empty($trans_timeout_audio_filename)) {
							$import_flag = false;
							$line_error .= "転送音声ファイルを選択してください, ";
						} else {
							$templateQuestion["T31TemplateQuestion"]["trans_timeout_audio_content"] = $trans_timeout_audio_content;
							$trans_timeout_audio_filename = trim(preg_replace('/\s\s+/', ' ', $trans_timeout_audio_filename));
							if ($trans_timeout_audio_filename) {
								if (in_array($trans_timeout_audio_filename, $fileArray)) {
									$import_flag = false;
									$line_error .= "転送音声ファイル名重複があります, ";
								} elseif (!in_array($trans_timeout_audio_filename, $filenameArr)) {
									$import_flag = false;
									$line_error .= $trans_timeout_audio_filename."転送音声ファイルを選択してください, ";
								} else {
									$fileArray[$question_no] = $trans_timeout_audio_filename;
									$fileArray2[$line+1]['trans_timeout_audio'] = $trans_timeout_audio_filename;
								}
							}
						}
					}
				}
				//check trans_tel
				if (isset($ques_format['trans_tel'])) {
					$trans_tel = $templateValue[$ques_format['trans_tel']['position']];
					if (!is_numeric($trans_tel) || strlen($trans_tel) < 10 || $trans_tel[0] != '0' || strlen($trans_tel) > 11){
						$import_flag = false;
						$line_error .= "転送番号が正しくありません, ";
					} else {
						$templateQuestion['T31TemplateQuestion']['trans_tel'] = $trans_tel;
					}
				}
				//check trans_seat_num
				if (isset($ques_format['trans_seat_num'])) {
					$trans_seat_num = $templateValue[$ques_format['trans_seat_num']['position']];
					if (is_numeric($trans_seat_num)) {
						$templateQuestion['T31TemplateQuestion']['trans_seat_num'] = $trans_seat_num;
					} else {
						$import_flag = false;
						$line_error .= "転送席数値が正しくありません, ";
					}
				}
				//check trans_empty_seat_flag
// 				if (isset($ques_format['trans_empty_seat_flag'])) {
// 					$trans_empty_seat_flag = $templateValue[$ques_format['trans_empty_seat_flag']['position']];
// 					if ($trans_empty_seat_flag == 0 || $trans_empty_seat_flag == 1) {
// 						$templateQuestion['T31TemplateQuestion']['trans_empty_seat_flag'] = $trans_empty_seat_flag;
// 					} else {
// 						$import_flag = false;
// 						$line_error .= "転送空き席数無し時発信停止値が正しくありません, ";
// 					}
// 				}
				//check trans_timeout
				if (isset($ques_format['trans_timeout'])) {
					$trans_timeout = $templateValue[$ques_format['trans_timeout']['position']];
					if (is_numeric(trim(preg_replace('/\s\s+/', ' ', $trans_timeout)))) {
						$templateQuestion['T31TemplateQuestion']['trans_timeout'] = $trans_timeout;
					} else {
						$import_flag = false;
						$line_error .= "転送タイムアウト値が正しくありません, ";
					}
				}

				//check trans_timeout
				if (isset($ques_format['trans_phone_number_play_flag'])) {
					$trans_timeout = $templateValue[$ques_format['trans_phone_number_play_flag']['position']];
					if ($trans_empty_seat_flag == 0 || $trans_empty_seat_flag == 1) {
						$templateQuestion['T31TemplateQuestion']['yuko_button_record'] = $trans_timeout;
					} else {
						$import_flag = false;
						$line_error .= "転送元番号再生値が正しくありません, ";
					}
				}




				//check second_record
				if (isset($ques_format['second_record'])) {
					$second_record = $templateValue[$ques_format['second_record']['position']];
					if (!empty($second_record)) {
						// second_record is integer
						preg_match_all('/\D/', $second_record, $output_array);
						if (!empty($output_array[0]) || ((int)$second_record > 30)) {
							$import_flag = false;
							$line_error .= "録音秒数値が正しくありません, ";
						} else {
							$templateQuestion["T31TemplateQuestion"]["second_record"] = (int)$second_record;
						}
					}
				}
				//check yuko_button_record
				if (isset($ques_format['yuko_button_record'])) {
					$yuko_button_record = $templateValue[$ques_format['yuko_button_record']['position']];
					if (!empty($yuko_button_record)) {
						if (($yuko_button_record != 0) && ($yuko_button_record != 1)) {
							$import_flag = false;
							$line_error .= "#終了ボタン値が正しくありません, ";
						} else {
							$templateQuestion["T31TemplateQuestion"]["yuko_button_record"] = $yuko_button_record;
						}
					}
				}


				//check bukken_audio_type
				if (isset($ques_format['bukken_audio_type'])) {
					$audio_type_position = $ques_format['bukken_audio_type']['position'];
					$audio_type = $templateValue[$audio_type_position];
					$audio_content = $templateValue[$audio_type_position + 1];
					$audio_filename = $templateValue[$audio_type_position + 2];
					if (($audio_type != 0 && $audio_type != 1 && $audio_type != 2) || ($audio_mix_flag == 0 && ($audio_type == 1 || $audio_type == 2))){
						$import_flag = false;
						$line_error .= "物件名確認音声種類が正しくありません, ";
					} else {
						$templateQuestion["T31TemplateQuestion"]["bukken_audio_type"] = $audio_type;
						if (($audio_type == 1 || $audio_type == 2) && $audio_content == '') {
							$import_flag = false;
							$line_error .= "物件名確認音声内容を入力してください, ";
						} elseif ($audio_type == 0 && $audio_filename == '') {
							$import_flag = false;
							$line_error .= "物件名確認音声ファイルを選択してください, ";
						} else {
							$templateQuestion["T31TemplateQuestion"]["bukken_audio_content"] = trim($audio_content);
							$audio_filename = trim(preg_replace('/\s\s+/', ' ', $audio_filename));
							if ($audio_filename) {
								if (in_array($audio_filename, $fileArray)) {
									$import_flag = false;
									$line_error .= "物件名確認音声ファイル名重複があります, ";
								} elseif (!in_array($audio_filename, $filenameArr)) {
									$import_flag = false;
									$line_error .= $audio_filename."物件名確認音声ファイルを選択してください, ";
								} else {
									$fileArray[$question_no] = $audio_filename;
									$fileArray2[$line+1]['bukken_audio'] = $audio_filename;
								}
							}
						}
					}
				}
				//check bukken_answer_no
				if (isset($ques_format['bukken_answer_no'])) {
					$bukken_answer_no = $templateValue[$ques_format['bukken_answer_no']['position']];
					if ($bukken_answer_no == '') {
						$import_flag = false;
						$line_error .= "物件確認回答番号が存在しません, ";
					} else {
						$templateQuestion["T31TemplateQuestion"]["bukken_answer_no"] = $bukken_answer_no;
					}
				}
				//check bukken_diagram_audio_type
				if (isset($ques_format['bukken_diagram_audio_type'])) {
					$audio_type_position = $ques_format['bukken_diagram_audio_type']['position'];
					$audio_type = $templateValue[$audio_type_position];
					$audio_content = $templateValue[$audio_type_position + 1];
					$audio_filename = $templateValue[$audio_type_position + 2];
					if (($audio_type != 0 && $audio_type != 1 && $audio_type != 2) || ($audio_mix_flag == 0 && ($audio_type == 1 || $audio_type == 2))){
						$import_flag = false;
						$line_error .= "図面希望音声種類が正しくありません, ";
					} else {
						$templateQuestion["T31TemplateQuestion"]["bukken_diagram_audio_type"] = $audio_type;
						if (($audio_type == 1 || $audio_type == 2) && $audio_content == '') {
							$import_flag = false;
							$line_error .= "図面希望音声内容を入力してください, ";
						} elseif ($audio_type == 0 && $audio_filename == '') {
							$import_flag = false;
							$line_error .= "図面希望音声ファイルを選択してください, ";
						} else {
							$templateQuestion["T31TemplateQuestion"]["bukken_diagram_audio_content"] = trim($audio_content);
							$audio_filename = trim(preg_replace('/\s\s+/', ' ', $audio_filename));
							if ($audio_filename) {
								if (in_array($audio_filename, $fileArray)) {
									$import_flag = false;
									$line_error .= "図面希望音声ファイル名重複があります, ";
								} elseif (!in_array($audio_filename, $filenameArr)) {
									$import_flag = false;
									$line_error .= $audio_filename."図面希望音声ファイルを選択してください, ";
								} else {
									$fileArray[$question_no] = $audio_filename;
									$fileArray2[$line+1]['bukken_diagram_audio'] = $audio_filename;
								}
							}
						}
					}
				}
				//check bukken_diagram_answer_no
				if (isset($ques_format['bukken_diagram_answer_no'])) {
					$bukken_diagram_answer_no = $templateValue[$ques_format['bukken_diagram_answer_no']['position']];
					if ($bukken_diagram_answer_no == '') {
						$import_flag = false;
						$line_error .= "図面希望回答番号が存在しません, ";
					} else {
						$templateQuestion["T31TemplateQuestion"]["bukken_diagram_answer_no"] = $bukken_diagram_answer_no;
					}
				}
				//check bukken_cont_audio_type
				if (isset($ques_format['bukken_cont_audio_type'])) {
					$audio_type_position = $ques_format['bukken_cont_audio_type']['position'];
					$audio_type = $templateValue[$audio_type_position];
					$audio_content = $templateValue[$audio_type_position + 1];
					$audio_filename = $templateValue[$audio_type_position + 2];
					if (($audio_type != 0 && $audio_type != 1 && $audio_type != 2) || ($audio_mix_flag == 0 && ($audio_type == 1 || $audio_type == 2))){
						$import_flag = false;
						$line_error .= "継続確認音声種類が正しくありません, ";
					} else {
						$templateQuestion["T31TemplateQuestion"]["bukken_cont_audio_type"] = $audio_type;
						if (($audio_type == 1 || $audio_type == 2) && $audio_content == '') {
							$import_flag = false;
							$line_error .= "継続確認音声内容を入力してください, ";
						} elseif ($audio_type == 0 && $audio_filename == '') {
							$import_flag = false;
							$line_error .= "継続確認音声ファイルを選択してください, ";
						} else {
							$templateQuestion["T31TemplateQuestion"]["bukken_cont_audio_content"] = trim($audio_content);
							$audio_filename = trim(preg_replace('/\s\s+/', ' ', $audio_filename));
							if ($audio_filename) {
								if (in_array($audio_filename, $fileArray)) {
									$import_flag = false;
									$line_error .= "継続確認音声ファイル名重複があります, ";
								} elseif (!in_array($audio_filename, $filenameArr)) {
									$import_flag = false;
									$line_error .= $audio_filename."継続確認音声ファイルを選択してください, ";
								} else {
									$fileArray[$question_no] = $audio_filename;
									$fileArray2[$line+1]['bukken_cont_audio'] = $audio_filename;
								}
							}
						}
					}
				}

				//check arr_ans_prop
				if (isset($ques_format['arr_ans_prop'])) {
					$answer_no_arr = $ques_format['arr_ans_prop'];
					$answer_no_arr_tmp = $answer_no_arr;
					$pos = $ques_format['arr_ans_prop_pos'];
					foreach ($answer_no_arr as $ans_no) {
						if ($pos >= $ques_format['element_count'])
							break;
						$templateButton = array();
						$templateButton["T32TemplateButton"]["question_no"] = $question_no;
						$templateButton["T32TemplateButton"]["entry_user"] = $user_id;
						$templateButton["T32TemplateButton"]["entry_program"] = 'Template_import';
						$templateButton["T32TemplateButton"]["update_user"] = $user_id;
						$templateButton["T32TemplateButton"]["update_program"] = 'Template_import';

						$answer_no = $templateValue[$pos++];
						$answer_content = $templateValue[$pos++];
						$jump_ques_tmp = trim(preg_replace('/\s\s+/', ' ', $templateValue[$pos++]));

						if (in_array($answer_no, $answer_no_arr_tmp)) {
							$templateButton['T32TemplateButton']['answer_no'] = $answer_no;
							unset($answer_no_arr_tmp[$answer_no]);
						} else {
							$import_flag = false;
							$line_error .= "回答番号が正しくありません, ";
						}

						$templateButton['T32TemplateButton']['answer_content'] = $answer_content;
						if ($jump_ques_tmp != '' && (!in_array($jump_ques_tmp, $arr_ques_nos) || !is_numeric($jump_ques_tmp))) {
							$import_flag = false;
							if ($answer_no == 99) {
								$line_error .= "タイムアウト飛び先が正しくありません, ";
							} else {
								$line_error .= "継続確認回答番号が存在しません, ";
							}
						} else {
							if ($answer_no != 99 && $jump_ques_tmp == '') {
								$import_flag = false;
								$line_error .= "継続確認回答番号が存在しません, ";
							} else {
								$templateButton['T32TemplateButton']['jump_question'] = $jump_ques_tmp;
							}
						}

						$templateButtons[] = $templateButton;
					}
				}


				//check arr_ans
				if (isset($ques_format['arr_ans'])) {
					$answer_no_arr = $ques_format['arr_ans'];
					$answer_no_arr_tmp = $answer_no_arr;
					$pos = $ques_format['arr_ans_pos'];
					$arr_jumps = array();
					foreach ($answer_no_arr as $ans_no) {
						$templateButton = array();
						$templateButton["T32TemplateButton"]["question_no"] = $question_no;
						$templateButton["T32TemplateButton"]["entry_user"] = $user_id;
						$templateButton["T32TemplateButton"]["entry_program"] = 'Template_import';
						$templateButton["T32TemplateButton"]["update_user"] = $user_id;
						$templateButton["T32TemplateButton"]["update_program"] = 'Template_import';

						$answer_no = $templateValue[$pos++];
						$answer_content = $templateValue[$pos++];
						$jump_ques_tmp = trim(preg_replace('/\s\s+/', ' ', $templateValue[$pos++]));

						if (in_array($answer_no, $answer_no_arr_tmp)) {
							$templateButton['T32TemplateButton']['answer_no'] = $answer_no;
							unset($answer_no_arr_tmp[$answer_no]);
						} else {
							$import_flag = false;
							$line_error .= "回答番号が正しくありません, ";
						}

						$templateButton['T32TemplateButton']['answer_content'] = $answer_content;
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
						if ($answer_no != 99) {
							$yuko_flag = $templateValue[$pos++];
							$yuko_flag = trim(preg_replace('/\s\s+/', ' ', $yuko_flag));
							if ($yuko_flag != 0 && $yuko_flag != 1) {
								$import_flag = false;
								$line_error .= "有効フラグ値が正しくありません, ";
							}
							$templateButton['T32TemplateButton']['yuko_flag'] = $yuko_flag;
						}
						if (!($question_type == QUESTION_BASIC && $answer_no != 99 && $answer_content === '' && $jump_ques_tmp === '' && $yuko_flag === '')) {
							$templateButtons[] = $templateButton;
						}
					}

					//20160418 Add by Thai : #6722 - Validate t31.jump_question - Begin
					if ($question_type == QUESTION_AUTH && $count_ques_auth == 1) {
						if (empty($templateQuestion["T31TemplateQuestion"]["jump_question"])) {
							$import_flag = false;
							$line_error .= "please select jump_question for question main_item, ";
						}
					} else {
						if (isset($templateQuestion["T31TemplateQuestion"]["jump_question"]) && $templateQuestion["T31TemplateQuestion"]["jump_question"] == '') {
							foreach ($answer_no_arr as $answer_no) {
								if ($answer_no != 99 && (!isset($arr_jumps[$answer_no]) || !$arr_jumps[$answer_no])) {
									$import_flag = false;
									$line_error .= "他のの場合飛び先が正しくありません, ";
									break;
								}
							}
						}
					}
					//20160418 Add by Thai : #6722 - Validate t31.jump_question - End
				}

				if ($question_type == QUESTION_TRANS) {
					$ques_type_5++;
				} elseif ($question_type == QUESTION_RECORD) {
					$ques_type_6++;
				} elseif ($question_type == QUESTION_TIMEOUT) {
					$ques_type_9++;
				}

				++$line;
				if (!empty($templateQuestion) && $import_flag) {
					$templateQuestions[$line] = $templateQuestion;
				}
				if (!empty($line_error)) {
					$arr_message_error[$line] = $line_error;
				}
			}

			$message_error_tail = '';
			if ($ques_type_5 > 1) {
				$import_flag = false;
				$message_error_tail .= "転送質問は1つのみ作成できます。<br>";
			}
			if ($ques_type_6 > 1) {
				$import_flag = false;
				$message_error_tail .= "録音質問は1つのみ作成できます。<br>";
			}
			if ($ques_type_9 > 1) {
				$import_flag = false;
				$message_error_tail .= "切断質問は1つのみ作成できます。<br>";
			}

			//4. Upload file wav to T89================================================================================
			foreach ($fileArray2 as $line => $file_names) {
				foreach ($file_names as $key => $file_name) {
					$file = $this->upload_file_wav($zip, $file_name, $zip_file_tmp);
					if (!empty($file)) {
						$templateQuestions[$line]["T31TemplateQuestion"][$key . "_id"] = $file["T89ManageFile"]["id"];
						$templateQuestions[$line]["T31TemplateQuestion"][$key . "_name"] = $file["T89ManageFile"]["file_name"];
					} else {
						if (isset($arr_message_error[$line])) {
							$arr_message_error[$line] .= "音声ファイル名が正しくありません, ";
						} else {
							$arr_message_error[$line] = "音声ファイル名が正しくありません, ";
						}
						$import_flag = false;
					}
				}
			}

			foreach ($arr_message_error as $line => $line_error) {
				$message_error .= $line . "行目: " . $line_error . "<br>";
			}
			$message_error .= $message_error_tail;
			if(!$import_flag){
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

			//5. Insert T30, T31, T32 ========================================================================
			$this->T30Template->create();

			$dsT30Template = $this->T30Template->getDataSource();
			$dsT31TemplateQuestion = $this->T31TemplateQuestion->getDataSource();
			$dsT32TemplateButton = $this->T32TemplateButton->getDataSource();

			$dsT30Template->begin($this);
			$dsT31TemplateQuestion->begin($this);
			$dsT32TemplateButton->begin($this);

			$template["T30Template"]["question_total"] = count($templateQuestions);
			$flag = $this->T30Template->save($template);
			$template_id = $this->T30Template->getLastInsertId();
			if(!$flag){
				$dsT30Template->rollback($this);
				$message_error = "アップ ファイルが失敗しました。<br>";
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
					$message_error = "アップ ファイルが失敗しました。<br>";
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
					$message_error = "アップ ファイルが失敗しました。<br>";
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

    // テンプレート新規作成、保存時に呼び出されるアクション
	function save_template(){
		$this->layout = "ajax";
		$dsT30Template = $this->T30Template->getDataSource();
		$dsT31TemplateQuestion = $this->T31TemplateQuestion->getDataSource();
		$dsT32TemplateButton = $this->T32TemplateButton->getDataSource();

		$dsT30Template->begin($this);
		$dsT31TemplateQuestion->begin($this);
		$dsT32TemplateButton->begin($this);

		// glb_arr_ques　内に、質問毎に配列で値を保存。その質問にない項目（trans_timeout_audio_id）などもキーとして存在する。
		$data = $this->data;
		if(isset($data["template_id"])){
			//20160408 Update by Thai : Fix check setting inbound not FINISH when edit inbound_template - Begin
			$template_id = $data["template_id"];
			$info_setting_inbound = $this->T25Inbound->getInboundNotFinishByTemplateId($template_id);
			if (isset($info_setting_inbound["T25Inbound"]["id"]) && !empty($info_setting_inbound["T25Inbound"]["id"])) {
				echo "err_exist_setting_inbound";
				exit;
			}
			//20160408 Update by Thai : Fix check setting inbound not FINISH when edit inbound_template - End
		}

		$company_id = $this->ESession->getUserCompanyId($this);

		//T30Template
		$T30Template = array();
		if(isset($data["template_id"])){
			$data["T30Template"]["id"] = $data["template_id"];
		}
		$data["T30Template"]["template_name"] = $data["template_name"];
		$data["T30Template"]["template_type"] = TEMPLATE_INBOUND;
		$data["T30Template"]["description"] = $data["description"];
		$data["T30Template"]["question_total"] = count($data["glb_arr_ques"]);

		if(isset($data["T30Template"]["id"]) && !empty($data["T30Template"]["id"])){
			$template_id = $data["T30Template"]["id"];
			$data["T30Template"]["update_user"] = $this->ESession->getUserId($this);
			$data["T30Template"]["update_program"] = $this->name.'_'.__FUNCTION__;
			$flag = $this->T30Template->save($data["T30Template"]);
		}else{
			$max_template_no = $this->T30Template->getMaxTemplateNoByCompanyId($company_id, TEMPLATE_INBOUND);
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

				//回答削除
				//20160229 Delete by Canh - Begin
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
		// この処理で、質問を登録する。
		foreach($data["glb_arr_ques"] as $key => $value){
			if($key > 0){
				//T31TemplateQuestion
				// すでにあればUPDATE、なければADDする。
				$this->T31TemplateQuestion->create();
				// とりあえず、すべての値をT31に保存する
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
				if($T31Question["question_type"] == QUESTION_FAX){
					$T31Question["digit"] = $T31Question["digit_fax"];
				}
				if($T31Question["question_type"] == QUESTION_PROPERTY){
					$T31Question["digit"] = $T31Question["digit_prop"];
				}
				if($T31Question["question_type"] == QUESTION_AUTH || $T31Question["question_type"] == QUESTION_AUTH_CHAR){
					$T31Question["digit"] = $T31Question["digit_auth"];
				}
				// 画面上で同一Name要素が2つあることは許されない仕組みとなっている。
				// 従って、画面上のName要素とDBに登録する値を変換する必要がある。
				if($T31Question["question_type"] == QUESTION_PROPERTY_SEARCH){
					$T31Question["audio_id"] = $T31Question["ques_property_cost_audio_id"];
					$T31Question["audio_name"] = $T31Question["ques_property_cost_audio_name"];
					$T31Question["audio_type"] = $T31Question["ques_property_cost_audio_type"];
					$T31Question["audio_content"] = $T31Question["ques_property_cost_audio_content"];
					$T31Question["digit"] = $T31Question["ques_property_cost_digit"];

					$T31Question["square_audio_id"] = $T31Question["ques_property_square_audio_id"];
					$T31Question["square_audio_name"] = $T31Question["ques_property_square_audio_name"];
					$T31Question["square_audio_type"] = $T31Question["ques_property_square_audio_type"];
					$T31Question["square_audio_content"] = $T31Question["ques_property_square_audio_content"];
					$T31Question["square_digit"] = $T31Question["ques_property_square_digit"];


					$T31Question["bukken_audio_id"] = $T31Question["ques_property_confirm_audio_id"];
					$T31Question["bukken_audio_name"] = $T31Question["ques_property_confirm_audio_name"];
					$T31Question["bukken_audio_type"] = $T31Question["ques_property_confirm_audio_type"];
					$T31Question["bukken_audio_content"] = $T31Question["ques_property_confirm_audio_content"];
					$T31Question["bukken_answer_no"] = $T31Question["ques_property_confirm_answer_no"];


					$T31Question["bukken_cont_audio_id"] = $T31Question["ques_property_continue_audio_id"];
					$T31Question["bukken_cont_audio_name"] = $T31Question["ques_property_continue_audio_name"];
					$T31Question["bukken_cont_audio_type"] = $T31Question["ques_property_continue_audio_type"];
					$T31Question["bukken_cont_audio_content"] = $T31Question["ques_property_continue_audio_content"];
//					$T31Question["bukken_cont_answer_no"] = $T31Question["ques_property_continue_answer_no"];
					$T31Question["jump_question"] = $T31Question["jump_question"];

				}
				if ($T31Question["question_type"] == QUESTION_INBOUND_SMS) {
					$T31Question["sms_display_number"] = $T31Question["smsPhoneNumber"];
					$T31Question["sms_content"] = str_replace("\r\n","\n",$T31Question["smsBodyContent"]);
					$T31Question["yuko_button_record"] = $T31Question["sms_use_short_url"];
					$T31Question["sms_error_audio_id"] = $T31Question["ques_sms_inbound_audio_id"];
					$T31Question["sms_error_audio_name"] = $T31Question["ques_sms_inbound_audio_name"];
					$T31Question["sms_error_audio_type"] = $T31Question["ques_inbound_sms_audio_type"];
					$T31Question["sms_error_audio_content"] = $T31Question["ques_inbound_sms_audio_content"];
				}

				if ($T31Question["question_type"] == QUESTION_INBOUND_SMS_INPUT) {
					$T31Question["sms_display_number"] = $T31Question["smsInputPhoneNumber"];
					$T31Question["sms_content"] = str_replace("\r\n","\n",$T31Question["smsInputBodyContent"]);
					$T31Question["yuko_button_record"] = $T31Question["sms_input_use_short_url"];
					$T31Question["sms_error_audio_id"] = $T31Question["ques_sms_input_inbound_audio_id"];
					$T31Question["sms_error_audio_name"] = $T31Question["ques_sms_input_inbound_audio_name"];
					$T31Question["sms_error_audio_type"] = $T31Question["ques_inbound_sms_input_audio_type"];
					$T31Question["sms_error_audio_content"] = $T31Question["ques_inbound_sms_input_audio_content"];
				}

/*				if(isset($value["jump_question"])){
					$T31Question["jump_question"] = $value["jump_question"];
				}*/
				$T31Question["question_no"] = $key;
				if(isset($T31Question["id"]) && !empty($T31Question["id"])){
					$T31Question["update_user"] = $this->ESession->getUserId($this);
					$T31Question["update_program"] = $this->name.'_'.__FUNCTION__;

				}else{
					$T31Question["template_id"] = $template_id;
					$T31Question["entry_user"] = $this->ESession->getUserId($this);
					$T31Question["entry_program"] = $this->name.'_'.__FUNCTION__;
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
				if (in_array($value["question_type"], array(QUESTION_BASIC, QUESTION_AUTH, QUESTION_AUTH_CHAR, QUESTION_TEL, QUESTION_PROPERTY, QUESTION_FAX, QUESTION_PROPERTY_SEARCH, QUESTION_INBOUND_SMS, QUESTION_INBOUND_COLLATION, QUESTION_INBOUND_SMS_INPUT))){
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
						$arr_answer_no = array(99);//99: timeout
					}else if($value["question_type"] == QUESTION_FAX){
						$arr_answer_no = array(99);//99: timeout
					}else if($value["question_type"] == QUESTION_PROPERTY){
						$arr_answer_no = array(0,1,2,3,4,5,6,7,8,9,51,52,99);
					}else if($value["question_type"] == QUESTION_PROPERTY_SEARCH){
						$arr_answer_no = array(0,1,2,3,4,5,6,7,8,9,51,52,99);
					}else if($value["question_type"] == QUESTION_INBOUND_SMS){
						$arr_answer_no = array(99);//99: 送信不可
					}else if($value["question_type"] == QUESTION_INBOUND_COLLATION){
						$arr_answer_no = array(1,2);
					}else if($value["question_type"] == QUESTION_INBOUND_SMS_INPUT){
						$arr_answer_no = array(98,99);//98:タイムアウト, 99: 送信不可
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
						}else if($value["question_type"] == QUESTION_FAX){
							$jump_question = isset($value["txtAnswJumpFax".$answer_no]) ? $value["txtAnswJumpFax".$answer_no] : '';
						}else if($value["question_type"] == QUESTION_PROPERTY){
							$jump_question = isset($value["txtAnswJumpProp".$answer_no]) ? $value["txtAnswJumpProp".$answer_no] : '';
							$answer_no = $answer_no != 99 ? $value["bukken_cont_answer_no"] : $answer_no;
						}else if($value["question_type"] == QUESTION_PROPERTY_SEARCH){
							// t32へセットするための仕掛け
							$jump_question = isset($value["txtAnswJumpProp".$answer_no]) ? $value["txtAnswJumpProp".$answer_no] : '';
							$answer_no = $answer_no != 99 ? $value["bukken_cont_answer_no"] : $answer_no;
						}else if($value["question_type"] == QUESTION_INBOUND_SMS){
							if(isset($value["txtAnswJumpSms".$answer_no])){
								$jump_question = $value["txtAnswJumpSms".$answer_no];
							}else $jump_question = "";
						}else if($value["question_type"] == QUESTION_INBOUND_COLLATION){
							$jump_question = isset($value["txtAnswJumpInboundCollation".$answer_no]) ? $value["txtAnswJumpInboundCollation".$answer_no] : '';
						}else if($value["question_type"] == QUESTION_INBOUND_SMS_INPUT){
							if(isset($value["txtAnswJumpSmsInput".$answer_no]) && $answer_no == 99){
								$jump_question = $value["txtAnswJumpSmsInput".$answer_no];
							}elseif(isset($value["txtAnswJumpSmsInputTimeOut".$answer_no]) && $answer_no == 98){
								$jump_question = $value["txtAnswJumpSmsInputTimeOut".$answer_no];
							}else $jump_question = "";
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
			$this->redirect(array('controller' => 'InboundTemplate', 'action' => 'index'));
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

	//エクスポート
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
			$question_type = $question['T31TemplateQuestion']["question_type"];

			// 物件入力(賃料、平米) がある場合は、エクスポートを行わない。
			if($question['T31TemplateQuestion']["question_type"] == QUESTION_PROPERTY_SEARCH){
				echo "err_exist_question_property_search";
				exit;
			}
			if($question['T31TemplateQuestion']["question_type"] == QUESTION_INBOUND_SMS || $question['T31TemplateQuestion']["question_type"] == QUESTION_INBOUND_SMS_INPUT){
				echo "err_exist_question_inbound_sms";
				exit;
			}
			if($question['T31TemplateQuestion']["question_type"] == QUESTION_INBOUND_COLLATION){
				echo "err_exist_question_inbound_collation";
				exit;
			}
			if (in_array($question_type, array(QUESTION_VOICE, QUESTION_BASIC, QUESTION_AUTH, QUESTION_AUTH_CHAR, QUESTION_TEL, QUESTION_TRANS, QUESTION_RECORD, QUESTION_COUNT, QUESTION_END, QUESTION_TIMEOUT, QUESTION_PROPERTY, QUESTION_FAX))) {
				array_push($r, $question['T31TemplateQuestion']['question_no']);
				array_push($r, $question['T31TemplateQuestion']['question_type']);
				array_push($r, $question['T31TemplateQuestion']['question_title']);
			}

			if (in_array($question_type, array(QUESTION_BASIC, QUESTION_AUTH, QUESTION_AUTH_CHAR))) {
				array_push($r, $question['T31TemplateQuestion']['question_yuko']);
			}

			if (in_array($question_type, array(QUESTION_VOICE, QUESTION_BASIC, QUESTION_AUTH, QUESTION_AUTH_CHAR, QUESTION_TEL, QUESTION_RECORD, QUESTION_COUNT, QUESTION_PROPERTY, QUESTION_FAX))) {//20160404 Edit by Thai : export jump_question for QUESTION_COUNT
				array_push($r, $question['T31TemplateQuestion']['jump_question']);
			}

			if (in_array($question_type, array(QUESTION_VOICE, QUESTION_BASIC, QUESTION_AUTH, QUESTION_AUTH_CHAR, QUESTION_TEL, QUESTION_TRANS, QUESTION_RECORD, QUESTION_TIMEOUT, QUESTION_PROPERTY, QUESTION_FAX))) {
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

			if ($question_type == QUESTION_BASIC) {
				array_push($r, $question['T31TemplateQuestion']['question_repeat']);

				$arr_ans_basic = array(0=>0,1=>1,2=>2,3=>3,4=>4,5=>5,6=>6,7=>7,8=>8,9=>9,51=>51,52=>52,99=>99);
				$template_ans_tmp = $this->T32TemplateButton->getAnwsByQuestionNo($template_id, $question['T31TemplateQuestion']['question_no']);
				$template_ans = array();
				foreach ($template_ans_tmp as $ans) {
					$template_ans[$ans['T32TemplateButton']['answer_no']] = $ans;
				}
				foreach ($arr_ans_basic as $ans_no) {
					if (isset($template_ans[$ans_no])) {
						$ans = $template_ans[$ans_no];
						array_push($r, $ans_no);
						array_push($r, $ans['T32TemplateButton']['answer_content']);
						array_push($r, $ans['T32TemplateButton']['jump_question']);
						if ($ans_no != 99) {
							array_push($r, $ans['T32TemplateButton']['yuko_flag']);
						}
					} else {
						array_push($r, $ans_no);
						array_push($r, '');
						array_push($r, '');
						if ($ans_no != 99) {
							array_push($r, '');
						}
					}
				}
			} else if ($question_type == QUESTION_AUTH || $question_type == QUESTION_AUTH_CHAR) {
				//20160420 Edit by Thai : #6722 ADD QUESTION_AUTH_CHAR - Begin
				if ($question_type == QUESTION_AUTH_CHAR) {
					array_push($r, $question['T31TemplateQuestion']['auth_match_flag']);//20160406 Add by Thai : #6722 - Add item for QUESTION_AUTH
					$arr_ans_auth = array(1=>1, 2=>2, 99=>99);
				} else {
					$arr_ans_auth = array(1=>1, 2=>2, 3=>3, 99=>99);
				}
				//20160420 Edit by Thai : #6722 ADD QUESTION_AUTH_CHAR - End
				array_push($r, $question['T31TemplateQuestion']['auth_item']);
				array_push($r, $question['T31TemplateQuestion']['digit']);

				$template_ans_tmp = $this->T32TemplateButton->getAnwsByQuestionNo($template_id, $question['T31TemplateQuestion']['question_no']);
				$template_ans = array();
				foreach ($template_ans_tmp as $ans) {
					$template_ans[$ans['T32TemplateButton']['answer_no']] = $ans;
				}
				foreach ($arr_ans_auth as $ans_no) {
					if (isset($template_ans[$ans_no])) {
						$ans = $template_ans[$ans_no];
						array_push($r, $ans_no);
						array_push($r, $ans['T32TemplateButton']['answer_content']);
						array_push($r, $ans['T32TemplateButton']['jump_question']);
						if ($ans_no != 99) {
							array_push($r, $ans['T32TemplateButton']['yuko_flag']);
						}
					} else {
						array_push($r, $ans_no);
						array_push($r, '');
						array_push($r, '');
						if ($ans_no != 99) {
							array_push($r, '');
						}
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
				array_push($r,  $question['T31TemplateQuestion']['recheck_button_next']);
			} else if ($question_type == QUESTION_TEL) {
				array_push($r, $question['T31TemplateQuestion']['digit']);

				//20160304 Add by Thai : ADD jump_question for timeout of QUESTION_TEL - Begin
				$template_ans = $this->T32TemplateButton->getAnwsByQuestionNo($template_id, $question['T31TemplateQuestion']['question_no']);
				if (count($template_ans) > 0) {
					$ans = $template_ans[0];
					array_push($r, $ans['T32TemplateButton']['answer_no']);
					array_push($r, $ans['T32TemplateButton']['answer_content']);
					array_push($r, $ans['T32TemplateButton']['jump_question']);
				} else {
					array_push($r, '99');
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
			} else if ($question_type == QUESTION_TRANS){
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
			} else if ($question_type == QUESTION_RECORD){
				array_push($r, $question['T31TemplateQuestion']['second_record']);
				array_push($r, $question['T31TemplateQuestion']['yuko_button_record']);
			} else if (in_array($question_type, array(QUESTION_FAX))){
				array_push($r, $question['T31TemplateQuestion']['digit']);

				$template_ans = $this->T32TemplateButton->getAnwsByQuestionNo($template_id, $question['T31TemplateQuestion']['question_no']);
				if (count($template_ans) > 0) {
					$ans = $template_ans[0];
					array_push($r, $ans['T32TemplateButton']['answer_no']);
					array_push($r, $ans['T32TemplateButton']['answer_content']);
					array_push($r, $ans['T32TemplateButton']['jump_question']);
				} else {
					array_push($r, '99');
					array_push($r, '');
					array_push($r, '');
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
			} else if (in_array($question_type, array(QUESTION_PROPERTY))){
				array_push($r, $question['T31TemplateQuestion']['digit']);

				array_push($r, $question['T31TemplateQuestion']['bukken_audio_type']);
				$bukken_audio_content = trim(preg_replace('/\s\s+/', ' ', $question['T31TemplateQuestion']['bukken_audio_content']));
				array_push($r, $bukken_audio_content);
				$file = $this->T89ManageFile->getFileById($question['T31TemplateQuestion']['bukken_audio_id']);
				$filename = '';
				if(!empty($file)) {
					$filename = 'q'.$question['T31TemplateQuestion']['question_no'] . '_1.wav';
					$wavfiles[$filename] = $file['T89ManageFile']['file_contents'];
				}
				array_push($r, $filename);
				array_push($r, $question['T31TemplateQuestion']['bukken_answer_no']);


				array_push($r, $question['T31TemplateQuestion']['bukken_diagram_audio_type']);
				$bukken_diagram_audio_content = trim(preg_replace('/\s\s+/', ' ', $question['T31TemplateQuestion']['bukken_diagram_audio_content']));
				array_push($r, $bukken_diagram_audio_content);
				$file = $this->T89ManageFile->getFileById($question['T31TemplateQuestion']['bukken_diagram_audio_id']);
				$filename = '';
				if(!empty($file)) {
					$filename = 'q'.$question['T31TemplateQuestion']['question_no'] . '_2.wav';
					$wavfiles[$filename] = $file['T89ManageFile']['file_contents'];
				}
				array_push($r, $filename);
				array_push($r, $question['T31TemplateQuestion']['bukken_diagram_answer_no']);


				array_push($r, $question['T31TemplateQuestion']['bukken_cont_audio_type']);
				$bukken_cont_audio_content = trim(preg_replace('/\s\s+/', ' ', $question['T31TemplateQuestion']['bukken_cont_audio_content']));
				array_push($r, $bukken_cont_audio_content);
				$file = $this->T89ManageFile->getFileById($question['T31TemplateQuestion']['bukken_cont_audio_id']);
				$filename = '';
				if(!empty($file)) {
					$filename = 'q'.$question['T31TemplateQuestion']['question_no'] . '_3.wav';
					$wavfiles[$filename] = $file['T89ManageFile']['file_contents'];
				}
				array_push($r, $filename);


				$template_ans = $this->T32TemplateButton->getAnwsByQuestionNo($template_id, $question['T31TemplateQuestion']['question_no']);
				foreach ($template_ans as $ans) {
					array_push($r, $ans['T32TemplateButton']['answer_no']);
					array_push($r, $ans['T32TemplateButton']['answer_content']);
					array_push($r, $ans['T32TemplateButton']['jump_question']);
				}

				if (count($template_ans) < 2) {
					array_push($r, '99');
					array_push($r, '');
					array_push($r, '');
				}


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
			$this->redirect(array('controller' => 'InboundTemplate', 'action' => 'index'));
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
			$info_template = $this->T30Template->getInfoTemplateById($id);

			//20160325 Edit by Thai : change check when delete inbound template - Begin
			if (!isset($info_template["T30Template"]["id"]) || empty($info_template["T30Template"]["id"])) {
				$result = array(
					'status' => 'err_not_exist',
					'template_id' => $id
				);
				echo json_encode($result);
				exit;
			}

			//20160408 Update by Thai : Fix check setting inbound not FINISH when delete inbound_template - Begin
			$info_setting_inbound = $this->T25Inbound->getInboundNotFinishByTemplateId($id);
			if (isset($info_setting_inbound["T25Inbound"]["id"]) && !empty($info_setting_inbound["T25Inbound"]["id"])) {
				$result = array(
					'status' => 'err_exist_setting_inbound',
					'template_id' => $id
				);
				echo json_encode($result);
				exit;
			}
			//20160408 Update by Thai : Fix check setting inbound not FINISH when delete inbound_template - End
			//20160325 Edit by Thai : change check when delete inbound template - End
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
		$info_template = $this->T30Template->getTemplateByTemplateName($data['template_name'], $company_id, TEMPLATE_INBOUND);
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

	function get_question_type($ques_type) {
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
				QUESTION_PROPERTY => '物件番号入力',
				QUESTION_FAX => 'FAX番号入力',
				QUESTION_PROPERTY_SEARCH => '物件入力(賃料、平米) ', // テンプレートの編集画面で、そのセクションのタイトルを表示するために設定
				QUESTION_INBOUND_SMS => '通知番号SMS送信', 
				QUESTION_INBOUND_COLLATION => '着信番号照合',
				QUESTION_INBOUND_SMS_INPUT => '番号指定SMS送信',  
		);

		return $arr_ques_type[$ques_type];
	}
	function get_ques_format($question_type) {
		$arr_ans_basic = array(0=>0,1=>1,2=>2,3=>3,4=>4,5=>5,6=>6,7=>7,8=>8,9=>9,51=>51,52=>52,99=>99);
		$arr_ans_auth = array(1=>1, 2=>2, 3=>3, 99=>99);
		$arr_ans_auth_char = array(1=>1, 2=>2, 99=>99);
		$arr_ans_tel = array(99=>99);
		$arr_ans_fax = array(99=>99);
		$arr_ans_prop = array(0=>0,1=>1,2=>2,3=>3,4=>4,5=>5,6=>6,7=>7,8=>8,9=>9,51=>51,52=>52,99=>99);
		$question_format = array(
			QUESTION_VOICE => array(
				'element_count' => 7,
				'question_no' => array('position' => 0),
				'question_type' => array('position' => 1),
				'question_title' => array('position' => 2),
				'jump_question' => array('position' => 3, 'required' => true),
				'audio_type' => array('position' => 4),
			),
			QUESTION_BASIC => array(
				'element_count' => 60,
				'question_no' => array('position' => 0),
				'question_type' => array('position' => 1),
				'question_title' => array('position' => 2),
				'question_yuko' => array('position' => 3),
				'jump_question' => array('position' => 4, 'required' => false),
				'audio_type' => array('position' => 5),
				'ques_repeate' => array('position' => 8),
				'arr_ans_pos' => 9,
				'arr_ans' => $arr_ans_basic
			),
			QUESTION_AUTH => array(
				//20160406 Update by Thai : #6722 - Add item for QUESTION_AUTH - Begin
				'element_count' => 30,
				'question_no' => array('position' => 0),
				'question_type' => array('position' => 1),
				'question_title' => array('position' => 2),
				'question_yuko' => array('position' => 3),
				'jump_question' => array('position' => 4, 'required' => false),
				'audio_type' => array('position' => 5),
				'auth_item' => array('position' => 8),
				'digit' => array('position' => 9),
				'arr_ans_pos' => 10,
				'arr_ans' => $arr_ans_auth,
				'recheck_flag' => array('position' => 25),
				'recheck_audio_type' => array('position' => 26),
				'recheck_button_next' => array('position' => 29)
				//20160406 Update by Thai : #6722 - Add item for QUESTION_AUTH - End
			),
			QUESTION_AUTH_CHAR => array(
				'element_count' => 27,
				'question_no' => array('position' => 0),
				'question_type' => array('position' => 1),
				'question_title' => array('position' => 2),
				'question_yuko' => array('position' => 3),
				'jump_question' => array('position' => 4, 'required' => false),
				'audio_type' => array('position' => 5),
				'auth_match_flag' => array('position' => 8),
				'auth_item' => array('position' => 9),
				'digit' => array('position' => 10),
				'arr_ans_pos' => 11,
				'arr_ans' => $arr_ans_auth_char,
				'recheck_flag' => array('position' => 22),
				'recheck_audio_type' => array('position' => 23),
				'recheck_button_next' => array('position' => 26)
			),
			QUESTION_TEL => array(
				'element_count' => 16,
				'question_no' => array('position' => 0),
				'question_type' => array('position' => 1),
				'question_title' => array('position' => 2),
				'jump_question' => array('position' => 3, 'required' => true),
				'audio_type' => array('position' => 4),
				'digit' => array('position' => 7),
				'arr_ans_pos' => 8,
				'arr_ans' => $arr_ans_tel,
				'recheck_flag' => array('position' => 11),
				'recheck_audio_type' => array('position' => 12),
				'recheck_button_next' => array('position' => 15)
			),
			QUESTION_TRANS => array(
				'element_count' => 14,
				'question_no' => array('position' => 0),
				'question_type' => array('position' => 1),
				'question_title' => array('position' => 2),
				'audio_type' => array('position' => 3),
				'trans_timeout_audio_type' => array('position' => 6),
				'trans_tel' => array('position' => 9),
				'trans_seat_num' => array('position' => 10),
				'trans_empty_seat_flag' => array('position' => 11),
				'trans_timeout' => array('position' => 12),
				'trans_phone_number_play_flag' => array('position' => 13),
			),
			QUESTION_RECORD => array(
				'element_count' => 9,
				'question_no' => array('position' => 0),
				'question_type' => array('position' => 1),
				'question_title' => array('position' => 2),
				'jump_question' => array('position' => 3, 'required' => true),
				'audio_type' => array('position' => 4),
				'second_record' => array('position' => 7),
				'yuko_button_record' => array('position' => 8),
			),
			QUESTION_COUNT => array(
				'element_count' => 4,
				'question_no' => array('position' => 0),
				'question_type' => array('position' => 1),
				'question_title' => array('position' => 2),
				'jump_question' => array('position' => 3, 'required' => false),
			),
			QUESTION_END => array(
				'element_count' => 3,
				'question_no' => array('position' => 0),
				'question_type' => array('position' => 1),
				'question_title' => array('position' => 2),
			),
			QUESTION_TIMEOUT => array(
				'element_count' => 6,
				'question_no' => array('position' => 0),
				'question_type' => array('position' => 1),
				'question_title' => array('position' => 2),
				'audio_type' => array('position' => 3),
			),
			QUESTION_PROPERTY => array(
				'element_count' => 25,
				'question_no' => array('position' => 0),
				'question_type' => array('position' => 1),
				'question_title' => array('position' => 2),
				'jump_question' => array('position' => 3, 'required' => true),
				'audio_type' => array('position' => 4),
				'digit' => array('position' => 7),
				'bukken_audio_type' => array('position' => 8),
				'bukken_answer_no' => array('position' => 11),
				'bukken_diagram_audio_type' => array('position' => 12),
				'bukken_diagram_answer_no' => array('position' => 15),
				'bukken_cont_audio_type' => array('position' => 16),
				'arr_ans_prop_pos' => 19,
				'arr_ans_prop' => $arr_ans_prop,
			),
			QUESTION_FAX => array(
				'element_count' => 16,
				'question_no' => array('position' => 0),
				'question_type' => array('position' => 1),
				'question_title' => array('position' => 2),
				'jump_question' => array('position' => 3, 'required' => true),
				'audio_type' => array('position' => 4),
				'digit' => array('position' => 7),
				'arr_ans_pos' => 8,
				'arr_ans' => $arr_ans_fax,
				'recheck_flag' => array('position' => 11, 'required' => true),
				'recheck_audio_type' => array('position' => 12),
				'recheck_button_next' => array('position' => 15)
			),
			
			//QUESTION_INBOUND_COLLATION => array(
			//	'element_count' => 11,
			//	'question_no' => array('position' => 0),
			//	'question_type' => array('position' => 1),
			//	'question_title' => array('position' => 2),
			//	'jump_question' => array('position' => 3, 'required' => true),
			//	'auth_item' => array('position' => 4),
			//	'digit' => array('position' => 5)
			//),
		);
		return $question_format[$question_type];
	}
}
