<?php
App::uses('AppController', 'Controller');

class InboundIncomingHistoryController extends AppController {
	var $uses = Array(
		'M01Server',
		'M02Company',
		'M15User',
		'T25Inbound',
		'M06CompanyExternal',
		'M90PulldownCode',
		'T30Template',
		'T31TemplateQuestion',
		'T18IncomingNgList',
		'T16InboundCallList',
		'T13InboundListItem',
		'T92Lock',
		'T64InboundQuestionHistory',
		'T81IncomingResult',
		'T56InboundListHistory',
		'T57InboundTelHistory',
		'M07ServerExternal',
		'M99SystemParameter',
		'T82BukkenFaxStatus',
		'T86InboundSmsStatus',
		'M08SmsApiInfo',
		'T17InboundTelList',
		'T19IncomingNgTel',
	);

	var $components = array('SendMail', 'Util');

	const ITEM_REGEX = '/{.*?}/';
	const LEFT_BRACE_REGEX = '/{/';
	const RIGHT_BRACE_REGEX = '/}/';

	/**
	 * 「Inbound template」ページ初期表示のアクション
	 * @param string $mode
	 */
	function index($mode = null, $del_count=null) {
		if ($mode == "delete") {
			$sortColumn = $this->ESession->getSortColumn($this);
			$sortType = $this->ESession->getSortType($this);
			$page = $this->ESession->getPage($this);
			$this->set("sortColumn", $sortColumn);
			$this->set("sortType", $sortType);
			$this->set("page", $page);
			$this->set('del_count', $del_count);
		}

		$post_code = $this->ESession->getUserPostCode($this);
		$create_flag = $this->M04ControllerAction->check_permission($post_code, 'SettingInbound', 'create');
		$delete_flag = $this->M04ControllerAction->check_permission($post_code, 'SettingInbound', 'delete');
		$download_flag = $this->M04ControllerAction->check_permission($post_code, 'SettingInbound', 'download');

		$this->set("mode", $mode);
		$this->set('create_flag', $create_flag);
		$this->set('delete_flag', $delete_flag);
		$this->set('download_flag', $download_flag);

	}

	function create() {
		$data = $this->data;
		if (empty($data)) {
			$this->redirect(array('controller' => 'InboundIncomingHistory', 'action' => 'index'));
		}

		$this->layout = false;
		$this->view = 'ajax_form_create';

		if (isset($data['id']) && $data['id']) {
			$inbound_id = $data['id'];
			$data_inbound = $this->T25Inbound->getInboundById($inbound_id);
			if (!$data_inbound['T25Inbound']['template_id']) {
				$data_inbound['T25Inbound']['template_id'] = '0';
			}
			$this->set('data', $data_inbound);
		}

		$external_numbers = $this->M06CompanyExternal->getExternalNumberByCompanyId($this->ESession->getUserCompanyId($this));
		$inbound_templates = $this->T30Template->getTemplateByCompanyId($this->ESession->getUserCompanyId($this), TEMPLATE_INBOUND);
		$template_busy = $this->M90PulldownCode->getSelectOption('inbound_template_busy');
		$inbound_lists = $this->T16InboundCallList->getListByCompanyId($this->ESession->getUserCompanyId($this));
		$inbound_list_ngs = $this->T18IncomingNgList->getListNgByCompanyId($this->ESession->getUserCompanyId($this));

		$this->set('external_numbers', $external_numbers);
		$this->set('template_busy', $template_busy);
		$this->set('inbound_templates', $inbound_templates);
		$this->set('inbound_lists', $inbound_lists);
		$this->set('inbound_list_ngs', $inbound_list_ngs);
	}

	function save($type = null) {
		//step 1: insert data to T25
		$data = $this->data;
		if (empty($data)) {
			$this->redirect(array('controller' => 'InboundIncomingHistory', 'action' => 'index'));
		}

		$this->layout = "ajax";
		$user_id = $this->ESession->getUserId($this);
		$company_id = $this->ESession->getUserCompanyId($this);

		$dsInbound = $this->T25Inbound->getDataSource();
		$dsInbound->begin($this);

		$T25Inbound = $data["T25Inbound"];
		$T25Inbound['time_start'] = date('Y-m-d H:i:s', time());
		$T25Inbound["id"] = "";
		$T25Inbound["company_id"] = $company_id;
		$T25Inbound["entry_user"] = $user_id;

		$exist_fax_flag = false;

		if ($data["T25Inbound"]['template_id'] === '0') {
			$T25Inbound["status"] = STATUS_INBOUND_BUSY;
			$T25Inbound['template_id'] = '';
		} else {
			$T25Inbound["status"] = STATUS_INBOUND_MESSAGE;
			$exist_fax_flag = $this->T31TemplateQuestion->checkExistQuestionType($data["T25Inbound"]['template_id'], QUESTION_FAX);
		}

		$max_inbound_no = $this->T25Inbound->getMaxInboundNoByCompanyId($company_id);
		if ($max_inbound_no["0"]["max_inbound_no"]) {
			$inbound_no = $max_inbound_no["0"]["max_inbound_no"] + 1;
		} else {
			$inbound_no = 1;
		}
		$T25Inbound["inbound_no"] = $inbound_no;
		$T25Inbound["entry_user"] = $user_id;
		if ($type == "duplicate") {
			$program_name = $this->name.'_Duplicate_SettingInbound';
		} else {
			$program_name = $this->name.'_Create_SettingInbound';
		}
		$T25Inbound["entry_program"] =  $program_name;
		$T25Inbound["del_flag"] = 'Y';

		/*$inbound_not_finish = $this->T25Inbound->getInboundNotFinishByExtNumber($T25Inbound['external_number']);
		if (count($inbound_not_finish) > 0) {
			$query = "UPDATE t25_inbounds
			SET
				time_end='" . date('Y-m-d H:i:s') . "',
				status='" . STATUS_INBOUND_END . "',
				update_user='" . $user_id . "',
				update_program='" . $program_name . "',
				modified='" . date('Y-m-d H:i:s') . "'
			WHERE
				external_number = '" . $T25Inbound['external_number'] . "' AND
				status <> '" . STATUS_INBOUND_END . "' AND
				del_flag = 'N';
			";

			$flag = $this->T25Inbound->query($query);
			if ($flag) {
				$dsInbound->rollback($this);
				$this->log("スケジュール画面でDBの操作：失敗");
				$result = array(
					"result" => "err_db"
				);
				echo json_encode($result);
				exit;
			}
		}*/


		$flag = $this->T25Inbound->save($T25Inbound);
		if ($flag) {
			$dsInbound->commit($this);
		} else {
			//DB更新失敗の場合
			$dsInbound->rollback($this);
			$this->log("スケジュール画面でDBの操作：失敗");
			$result = array(
				"result" => "err_db",
			);
			// ロック解除
			$this->unlock_external_number($T25Inbound['external_number'], __FUNCTION__);
			echo json_encode($result);
			exit;
		}

		//step 2: get value parameter for run batch
		$inbound = $flag;

		$inbound_id = $inbound['T25Inbound']['id'];
		$status = $inbound['T25Inbound']['status'];
		$external_number = $inbound['T25Inbound']['external_number'];
		$template_id = $inbound['T25Inbound']['template_id'];
		$list_ng_id = isset($inbound['T25Inbound']['list_ng_id']) ? $inbound['T25Inbound']['list_ng_id'] : NULL;
		$list_id = isset($inbound['T25Inbound']['list_id']) ? $inbound['T25Inbound']['list_id'] : NULL;

		$inbound_prev = $this->T25Inbound->getInboundPrev($external_number, $inbound_id);
		if (!empty($inbound_prev)) {
			$inbound_prev_id = $inbound_prev['T25Inbound']['id'];
			$inbound_prev_status = $inbound_prev['T25Inbound']['status'];
		} else {
			$inbound_prev_id = null;
			$inbound_prev_status = null;
		}

		$external_info = $this->M07ServerExternal->getServerExternalByTel($external_number);
		if (!empty($external_info)) {
			$server_id = $external_info['M07ServerExternal']['in_server_id'];
			$external_prefix = $external_info['M07ServerExternal']['external_prefix'];
			$enosip_port = $external_info['M07ServerExternal']['enosip_port'];
			//step 3: run batch
			$batch_result = $this->batch_create_inbound($server_id, $inbound_id, $status, $external_number, $template_id, $list_ng_id, $list_id, $inbound_prev_id, $inbound_prev_status, $external_prefix, $enosip_port);
			if ($batch_result == 'success') {
				$inbound['T25Inbound']['del_flag'] = 'N';
				if($exist_fax_flag){
					$inbound['T25Inbound']['bukken_fax_flag'] = '1';
				}
				$flag = $this->T25Inbound->save($inbound);
				if ($flag) {
					$dsInbound->commit($this);
					if (!empty($inbound_prev)) {
						$inbound_prev = $this->T25Inbound->getInboundPrev($external_number, $inbound_id);
						$inbound_prev['T25Inbound']['status'] = STATUS_INBOUND_END;
						$inbound_prev['T25Inbound']['time_end'] = date('Y-m-d H:i:s');
						$inbound_prev['T25Inbound']['update_user'] = $user_id;
						$inbound_prev['T25Inbound']['update_program'] = $program_name;
						$inbound_prev['T25Inbound']['modified'] = date('Y-m-d H:i:s');

						$flag = $this->T25Inbound->save($inbound_prev);
						if ($flag) {
							$dsInbound->commit($this);
						} else {
							//DB更新失敗の場合
							$dsInbound->rollback($this);
							$this->log("スケジュール画面でDBの操作：失敗");
							$result = array(
								"result" => "err_db",
							);
							// ロック解除
							$this->unlock_external_number($external_number, __FUNCTION__);

							echo json_encode($result);
							exit;
						}
					}
				} else {
					//DB更新失敗の場合
					$dsInbound->rollback($this);
					$this->log("スケジュール画面でDBの操作：失敗");
					$result = array(
						"result" => "err_db",
					);
					// ロック解除
					$this->unlock_external_number($external_number, __FUNCTION__);

					echo json_encode($result);
					exit;
				}

				$result = array(
					"result" => "success",
				);
			} else {
				$result = array(
					"result" => "error_batch"
				);
			}
		} else {
			$result = array(
				"result" => "success",
			);
		}

		// ロック解除
		$this->unlock_external_number($external_number, __FUNCTION__);

		echo json_encode($result);
		exit;
	}

	/**
	 * 保存確認メッセージで「キャンセル」押下時の後処理
	 */
	function save_canceled() {
		// データ取得
		$data = $this->data;
		if (empty($data)) {
			$this->redirect(array('controller' => 'InboundIncomingHistory', 'action' => 'index'));
		}

		// 電話番号ロック解除
		$this->unlock_external_number($data["T25Inbound"]['external_number'], __FUNCTION__);

		exit;
	}

	/**
	 * 電話番号のロックを解除する
	 *
	 * @param string $external_number 電話番号
	 * @param string $function メインのファンクション名
	 */
	function unlock_external_number($external_number, $function) {
		// ロック情報取得
		$lockInfo = $this->T92Lock->getInfoLock('incoming_history', $external_number);

		if (empty($lockInfo)) {
			// Lock情報が取得できなかった場合
			$this->log("【ロック解除処理失敗】ロック情報なし 対象電話番号：" . $external_number);
			$subject = "【はやぶさ】ロック解除処理エラー_ロック情報なし";
			$arr_company_info = $this->M02Company->getCompanyByCompanyId($this->ESession->getUserCompanyId($this));
			$company_id = $arr_company_info["M02Company"]["company_id"];
			$company_name = $arr_company_info["M02Company"]["company_name"];
			$this->SendMail->sendErrorMail($subject, $company_id, $company_name, $external_number);
			return;
		}

		//T92Lock解除
		$lockInfo['T92Lock']["del_flag"] = "Y";
		$lockInfo['T92Lock']["update_user"] = $this->ESession->getUserId($this);
		$lockInfo['T92Lock']["update_program"] = $this->name.'_'.$function.'_end';

		$dsT92Lock = $this->T92Lock->getDataSource();
		$dsT92Lock->begin($this);
		$result = $this->T92Lock->save($lockInfo);

		if (!$result) {
			// ロック解除失敗
			$dsT92Lock->rollback($this);
			$this->log("【ロック解除処理失敗】対象電話番号：" . $external_number);
			$subject = "【はやぶさ】ロック解除処理エラー_DB更新失敗";
			$arr_company_info = $this->M02Company->getCompanyByCompanyId($this->ESession->getUserCompanyId($this));
			$company_id = $arr_company_info["M02Company"]["company_id"];
			$company_name = $arr_company_info["M02Company"]["company_name"];
			$this->SendMail->sendErrorMail($subject, $company_id, $company_name, $external_number);
			return;
		}

		$dsT92Lock->commit($this);
	}

	function delete() {
		$data = $this->data;
		if (empty($data)) {
			$this->redirect(array('controller' => 'InboundIncomingHistory', 'action' => 'index'));
		}

		$dsInbound = $this->T25Inbound->getDataSource();
		$dsInbound->begin($this);

		$setting_inbound_ids = $data['setting_inbound_ids'];
		$update_user = $this->ESession->getUserId($this);
		$update_program = $this->name.'_'.__FUNCTION__;
		$time = date('Y-m-d H:i:s a', time());

		foreach ($setting_inbound_ids as $id) {
			$arr_inbound_info = $this->T25Inbound->getInboundById($id);

			$arr_inbound_info['T25Inbound']['del_flag'] = "Y";
			$arr_inbound_info["T25Inbound"]["update_user"] = $update_user;
			$arr_inbound_info["T25Inbound"]["update_program"] = $update_program;
			$arr_inbound_info["T25Inbound"]["modified"] = $time;

			if (!$this->T25Inbound->save($arr_inbound_info)) {
				$dsInbound->rollback($this);
				$this->log("スケジュール削除：失敗");
				$this->redirect(array('controller' => 'Login', 'action' => 'index/systemerror'));
			}
		}

		$dsInbound->commit($this);
		$this->redirect(array('controller' => 'InboundIncomingHistory', 'action' => 'index/delete/' . count($setting_inbound_ids)));
	}

	function download() {}
	function status() {}

	function arr_setting_inbound($js_page, $limit, $column) {
		$this->layout = 'ajax';
		$filter = $_GET["filter"];
		$page = $js_page + 1;
		$json_data = Array();
		$json_data["headers"] = Array("NO","電話番号","適用日","テンプレート","着信拒否リスト","着信リスト","作成日時","作成者","アクション");
		$json_data["rows"] = Array();
		$company_id = $this->ESession->getUserCompanyId($this);

		$post_code = $this->ESession->getUserPostCode($this);
		$enable_create = $this->M04ControllerAction->check_permission($post_code, 'SettingInbound', 'create');
		$enable_delete = $this->M04ControllerAction->check_permission($post_code, 'SettingInbound', 'delete');
		$enable_download = $this->M04ControllerAction->check_permission($post_code, 'SettingInbound', 'download');
		$enable_statistic = $this->M04ControllerAction->check_permission($post_code, 'SettingInbound', 'statistic');

		if ($enable_delete || $enable_download) {
			array_unshift($json_data["headers"], "checkbox");
		} else {
			$keyArr = array();
			if ($filter != null) {
				while (current($filter)) {
					$keyArr[] = key($filter) + 1;
					next($filter);
				}
				$filter = array_combine($keyArr, array_values($filter));
			}
		}

		if (isset($column) && !empty($column) && $column != "column") {
			$sort_order = $this->Util->getSettingInboundSortOrder($column,$enable_delete || $enable_download ? 1 : 0);
			$sort_order_col = isset($sort_order[0]) ? $sort_order[0] : null;
		}else{
			$sort_order_col = array("T25Inbound.status ASC, T25Inbound.inbound_no DESC");
		}
		$arr_inbounds = $this->T25Inbound->getInboundByCompanyId($company_id, $limit, $page, $sort_order_col, $filter);
		$json_data["total_rows"] = $this->T25Inbound->getInboundByCompanyIdCount($company_id, $filter);

		foreach ($arr_inbounds as $arr_inbound) {
			$i = 0;
			$json_row = array();
			$status = $arr_inbound['T25Inbound']['status'];

			if ($status == STATUS_INBOUND_END && isset($arr_inbound['T25Inbound']['time_end']) && $arr_inbound['T25Inbound']['time_end']) {
				$color = '#c3c3c3';
			} else {
				$color = 'white';
			}
			$str_time = date('Y-m-d', strtotime($arr_inbound['T25Inbound']['time_start']))
				. '～'
				. ($arr_inbound['T25Inbound']['time_end'] ? date('Y-m-d', strtotime($arr_inbound['T25Inbound']['time_end'])) : '');

			if ($enable_delete || $enable_download) {
				$json_row[$json_data["headers"][$i++]] = '<td style="background-color: '.$color.'">'
					. '<input type="checkbox" name="cbSelect['
					. $arr_inbound['T25Inbound']['id'] . ']" id="cbSelect['
					. $arr_inbound['T25Inbound']['id'] . ']" setting_inbound_id="'
					. $arr_inbound['T25Inbound']['id'] . '" onclick="updateCheckStatus(\'bundleCheckbox\');">'
					. '<label for="cbSelect[' . $arr_inbound['T25Inbound']['id'] . ']" style="margin-top: 2px;"></label>'
					. '</td>';
			}

			$json_row[$json_data["headers"][$i++]] = '<td style="background-color: '.$color.'">'.$arr_inbound['T25Inbound']['inbound_no'].'</td>';
			$json_row[$json_data["headers"][$i++]] = '<td style="background-color: '.$color.'">'.$arr_inbound['T25Inbound']['external_number'].'</td>';
			$json_row[$json_data["headers"][$i++]] = '<td style="background-color: '.$color.'">'.$str_time.'</td>';
			$json_row[$json_data["headers"][$i++]] = '<td style="background-color: '.$color.'" class="break_word">'.$arr_inbound[0]['template_name'].'</td>';
			$json_row[$json_data["headers"][$i++]] = '<td style="background-color: '.$color.'" class="break_word">'.$arr_inbound[0]['list_ng_name'].'</td>';
			$json_row[$json_data["headers"][$i++]] = '<td style="background-color: '.$color.'" class="break_word">'.$arr_inbound[0]['list_name'].'</td>';
			$json_row[$json_data["headers"][$i++]] = '<td style="background-color: '.$color.'">'.date('Y-m-d H:i', strtotime($arr_inbound['T25Inbound']['created'])).'</td>';
			$json_row[$json_data["headers"][$i++]] = '<td style="background-color: '.$color.'" class="break_word">'.$arr_inbound['M05User']['user_name'].'</td>';

			$str_btn_duplicate = '<div class="iconFormat"></div>';
			$str_btn_statistic = '<div class="iconFormat"></div>';
			if ($enable_create) {
				$str_btn_duplicate = '<div class="iconFormat"><a href="javascript:void(0);" class="lnkDuplicate" setting_inbound_id="'.$arr_inbound['T25Inbound']['id'].'"><i title="複製" data-toggle="tooltip" class="glyphicon glyphicon-duplicate icon-white" ></i></a></div>';
			}
			if ($enable_statistic && ($status == STATUS_INBOUND_MESSAGE || $status == STATUS_INBOUND_END) && $arr_inbound['T25Inbound']['template_id']) {
				$str_btn_statistic = '<div class="iconFormat"><a href="javascript:void(0);" class="lnkStatistic" setting_inbound_id="'.$arr_inbound['T25Inbound']['id'].'"><i title="状況をみる" data-toggle="tooltip" class="glyphicon glyphicon-stats icon-white" ></i></a></div>';
			}

			$str_btn_func = $str_btn_duplicate . $str_btn_statistic;

			$json_row[$json_data["headers"][$i++]] = '<td style="background-color: '.$color.'">'.$str_btn_func.'</td>';
			$json_data["rows"][] = (object) $json_row;
		}
		$json_string = json_encode($json_data);
		echo $json_string;
		if (isset($sort_order)) {
			$this->ESession->setSortColumn($sort_order[1], $this);
			$this->ESession->setSortType($sort_order[2], $this);
		} else {
			$this->ESession->setSortColumn(null, $this);
			$this->ESession->setSortType(null, $this);
		}
		$this->ESession->setPage($js_page, $this);
		exit;
	}

	// インバウンドの着信設定を行ったときに実行する
	function check_info_setting_inbound() {
		$data = $this->data;

		// 更新対象の電話番号が着信設定中によりロックされていないかチェック
		if (!$this->check_unlock_external_number('incoming_history', $data['external_number'])) {
			$result = array(
				"result" => "err_lock_external_number",
			);
			echo json_encode($result);
			exit;
		}

		if ($data['template_id'] === '0' && !$this->check_number_set_busy($data)) {
			$result = array(
				"result" => "err_number_set_busy",
			);
			echo json_encode($result);
			exit;
		}
		if ($data['template_id'] !== '0' && !$this->check_exist_template($data)) {
			$result = array(
				"result" => "err_exist_template",
			);
			echo json_encode($result);
			exit;
		}
		if (isset($data['list_ng_id']) && !empty($data['list_ng_id']) && !$this->check_exist_list_ng($data)) {
			$result = array(
				"result" => "err_exist_list_ng",
			);
			echo json_encode($result);
			exit;
		}
		if (isset($data['list_id']) && !empty($data['list_id']) && !$this->check_exist_list($data)) {
			$result = array(
				"result" => "err_exist_list",
			);
			echo json_encode($result);
			exit;
		}
		if (!$this->check_unlock_template($data)) {
			$result = array(
				"result" => "err_lock_template",
			);
			echo json_encode($result);
			exit;
		}
		if (!$this->check_unlock_call_list_ng($data)) {
			$result = array(
				"result" => "err_lock_call_list_ng",
			);
			echo json_encode($result);
			exit;
		}
		if (!$this->check_unlock_call_list($data)) {
			$result = array(
				"result" => "err_lock_call_list",
			);
			echo json_encode($result);
			exit;
		}
		if (!$this->check_exist_item($data)) {
			$result = array(
				"result" => "err_exist_item",
			);
			echo json_encode($result);
			exit;
		}
		if (!$this->check_match_main_item($data)) {
			$result = array(
				"result" => "err_match_main_item",
			);
			echo json_encode($result);
			exit;
		}
		if(!$this->check_ch_num($data)){
			$result = array(
					"result" => "err_proc_num",
			);
			echo json_encode($result);
			exit;
		}

		if(!$this->check_set_bukken_company_id($data)){
			$result = array(
					"result" => "err_set_bukken_company_id",
			);
			echo json_encode($result);
			exit;
		}

		if(!$this->check_set_sms_account($data)){
			$result = array(
					"result" => "err_not_exist_sms_account",
			);
			echo json_encode($result);
			exit;
		}

		//SMS本文をチェックする
		$check_message = $this->check_sms_content($data);
		if ($check_message) {
			$result = array(
				"result" => $check_message,
			);
			echo json_encode($result);
			exit;
		}

		//着信照合の存在するテンプレートの場合は着信リストに電話番号の存在を必須とする
		if(!$this->check_inbound_collation($data)){
			$result = array(
					"result" => "err_inbound_collation",
			);
			echo json_encode($result);
			exit;
		}

		// 全てのチェックがOKの場合、電話番号でロックを取得
		if (!$this->get_lock_external_number($data['external_number'], __FUNCTION__)) {
			// ロック取得エラー
			$result = array(
				"result" => "err_get_lock_external_number",
			);
			echo json_encode($result);
			exit;
		}

		$result = array(
			"result" => "true",
		);
		echo json_encode($result);
		exit;
	}

	/**
	 * 対象電話番号がロックされているか確認する
	 * @param $lock_flag ロックフラグ
	 * @param $lock_id ロックID
	 * @return boolean true:ロックなし／false:ロック中
	 */
	function check_unlock_external_number($lock_flag, $lock_id) {
		$info_lock = $this->T92Lock->getInfoLock($lock_flag, $lock_id);
		if (!empty($info_lock)) {
			// ロックあり
			return false;
		} else {
			// ロックなし
			return true;
		}
	}

	/*
	* SMS内容は70文字をチェックする
	* InboundのSMSセクションは１つのみ
	*/
	function check_sms_content($data){
		$arr_ques = $this->T31TemplateQuestion->getQuesByTemplateId($data['template_id']);
		$list_id = $data['list_id'];
		$ng_list_id = $data['list_ng_id'];
		$sms_use_short_url = 0;

		// $arr_ques＝そのテンプレート上の全てのセクション
		// 通知番号SMS、番号指定SMSをチェック
		foreach ($arr_ques as $question) {
			if ($question['T31TemplateQuestion']['question_type'] == QUESTION_INBOUND_SMS
			|| $question['T31TemplateQuestion']['question_type'] == QUESTION_INBOUND_SMS_INPUT) {
				$sms_content = $question['T31TemplateQuestion']['sms_content'];
				$sms_use_short_url = $question['T31TemplateQuestion']['yuko_button_record'];
				$M08SmsApiInfo = $this->M08SmsApiInfo->getApiInfoByDisplayNumber($question['T31TemplateQuestion']['sms_display_number']);
				$api_id = $M08SmsApiInfo['M08SmsApiInfo']['api_id'];

				$had_item = false;
				//sms本文が空白の場合、FALSEを返す
				//sms本文が空白の場合、文字数オーバーとみなす（セクション編集で本文空欄はNGとしているが、念のために。）
				if(empty($sms_content)){
					return "err_sms_over_length";
				}

				////挿入項目の洗い出し。
				$arr_items = array();
				preg_match_all($this::ITEM_REGEX, $sms_content, $items);
				foreach ($items[0] as $item) {
					$item_name = preg_replace($this::LEFT_BRACE_REGEX, "",preg_replace($this::RIGHT_BRACE_REGEX, "", $item,1),1);
					if (!empty($item_name)) {
						$had_item = true;
						//SMS本文の中に挿入項目を洗い出してarrayに入れる
						if(!in_array($item_name, $arr_items))
							array_push($arr_items, $item_name);
					}
				}

				//挿入項目あり　または　APIV2を使うなら文字数の再確認が必要
				// 短縮URL有効・無効は$api_id == SMS_API_V2_VALUEの時にOnになる。（画面で制御）
				if($had_item || $api_id == SMS_API_V2_VALUE){ //挿入項目があった場合、挿入項目値を含めて本文の長さをチェックする
					$tel_column = "";
					$list_items = $this->T13InboundListItem->getTitleByListId($list_id);
					$list_columns = array();
					//リストの付加項目を取得する
					foreach ($list_items as $list_item) {
						$list_columns[$list_item['T13InboundListItem']['item_name']] = $list_item['T13InboundListItem']['column'];
						if($list_item['T13InboundListItem']["item_code"] == 'tel_no')
							$tel_column = $list_item['T13InboundListItem']['column'];
					}
					//リストの項目の中に挿入項目が存在しない場合、FALSEを返す(別の箇所でエラーとするため。)
					foreach ($arr_items as $item_name) {
						if (!isset($list_columns[$item_name])){
							return "err_sms_over_length";
						}
					}

					$arrNgTelList = array();
					//NGリストが存在する場合、電話番号を取得してその一覧を発信リストに除外する
					if(isset($ng_list_id) && !empty($ng_list_id)){
						$ngTelList = $this->T19IncomingNgTel->getTelListByCallListNgId($ng_list_id);
						foreach ($ngTelList as $ngTel) {
							$arrNgTelList[] = $ngTel["T19IncomingNgTel"]["tel_no"];
						}
					}
					$telList = $this->T17InboundTelList->getAllByListId($list_id, $tel_column, $arrNgTelList);

					//// 発信リスト毎に、SMS本文の長さをチェックする。
					// 挿入項目を置き換える。
					foreach ($telList as $tel) {
						$tmp_sms_content = $sms_content;
						foreach ($arr_items as $item_name) {
							$tmp_item = "{".$item_name."}";
							//挿入項目を実際値を入れ替えて長さをチェックする
							$tmp_sms_content = str_replace($tmp_item, $tel["T17InboundTelList"][$list_columns[$item_name]], $tmp_sms_content);
						}

						// API_v2の場合は、改行を2文字とカウントする
						if($api_id == SMS_API_V2_VALUE){
							$error_message = "";
							list($error_message, $tmp_sms_content) = $this->Util->checkSmsBodyValueForApiV2($sms_use_short_url, $tmp_sms_content);
							if($error_message){
								return $error_message;
							}
						}

						if(mb_strlen($tmp_sms_content) > MAX_LEN_SMS_CONTENT){
							return "err_sms_over_length";
						}
						//// 発信リスト毎に、SMS本文の長さをチェックする。_ここまで
					}
				}

			}
		}
		return "";
	}
	function check_delete_setting_inbound() {
		$data = $this->data;
		if (empty($data)) {
			$this->redirect(array('controller' => 'InboundIncomingHistory', 'action' => 'index'));
		}

		$setting_inbound_ids = $data['setting_inbound_ids'];
		foreach ($setting_inbound_ids as $id) {
			$arr_inbound_info = $this->T25Inbound->getInboundById($id);
			if (count($arr_inbound_info) < 1) {
				$result = array(
					'status' => 'err_not_exist',
					'setting_inbound_id' => $id
				);
				echo json_encode($result);
				exit;
			}

			if ($arr_inbound_info['T25Inbound']['status'] != STATUS_INBOUND_END) {
				$result = array(
					'status' => 'err_status_can_not_delete',
					'setting_inbound_id' => $id
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

	function check_ch_num($data) {
		if(isset($data['template_id']) && !empty($data['template_id'])){
			$template_id = $data['template_id'];
			$trans_info = $this->T31TemplateQuestion->getTransQuesByTemplateId($template_id);
			if(isset($trans_info["T31TemplateQuestion"]["trans_seat_num"]) && !empty($trans_info["T31TemplateQuestion"]["trans_seat_num"])){
				$trans_seat_num = $trans_info["T31TemplateQuestion"]["trans_seat_num"];
				$external_number = $data['external_number'];
				$proc_inbound_info = $this->M07ServerExternal->getInProcNumByExternalNumber($external_number);
				$proc_num = $proc_inbound_info["M07ServerExternal"]["in_proc_num"];
				if ($trans_seat_num >= $proc_num){
					return false;
				}
			}
		}
		return true;
	}

	/**
	 * 電話番号をLOCK_IDに使用して、LOCKを取得する
	 *
	 * @param string $external_number 電話番号
	 * @param string $function メインのファンクション名
	 * @return boolean true：LOCK取得成功／false：LOCK取得失敗
	 */
	function get_lock_external_number($external_number, $function) {
		// パラメータ設定
		$T92Lock = array();
		$T92Lock["lock_flag"] = "incoming_history";
		$T92Lock["lock_id"] = $external_number;
		$T92Lock["use_user_id"] = $this->ESession->getUserId($this);
		$T92Lock["session_id"] = $this->Session->id();
		$T92Lock["entry_user"] = $this->ESession->getUserId($this);
		$T92Lock["entry_program"] = $this->name.'_'.$function.'_start';
		// 保存処理実行
		$dsT92Lock = $this->T92Lock->getDataSource();
		$dsT92Lock->begin($this);
		$invokeResult = $this->T92Lock->save($T92Lock);
		if(!$invokeResult){
			// 処理失敗
			$dsT92Lock->rollback($this);
			$this->log("【ロック取得失敗】対象電話番号：" . $external_number);
			return false;
		}
		$dsT92Lock->commit($this);
		return $invokeResult;
	}

	function check_number_set_busy($data) {
		if ($data['template_id'] === '0') {
			$arr_inbound_info = $this->T25Inbound->getInboundBusyByNumber($data['external_number']);
			if (count($arr_inbound_info) > 0) {
				return false;
			}
		}
		return true;
	}
	function check_exist_template($data) {
		$arr_template_info = $this->T30Template->getInfoTemplateById($data['template_id']);
		if (count($arr_template_info) < 1) {
			return false;
		}
		return true;
	}
	function check_exist_list_ng($data) {
		$arr_list_ng_info = $this->T18IncomingNgList->getListNgInfoById($data['list_ng_id']);
		if (count($arr_list_ng_info) < 1) {
			return false;
		}
		return true;
	}
	function check_exist_list($data) {
		$arr_list_info = $this->T16InboundCallList->getListInfoById($data['list_id']);
		if (count($arr_list_info) < 1) {
			return false;
		}
		return true;
	}
	function check_unlock_template($data) {
		$lock_flag = 'template';
		$lock_id = $data['template_id'];
		return $this->check_unlock($lock_flag, $lock_id);
	}
	function check_unlock_call_list_ng($data) {
		$lock_flag = 'inbound_call_list_ng';
		$lock_id = $data['list_ng_id'];
		return $this->check_unlock($lock_flag, $lock_id);
	}
	function check_unlock_call_list($data) {
		$lock_flag = 'inbound_call_list';
		$lock_id = $data['list_id'];
		return $this->check_unlock($lock_flag, $lock_id);
	}
	function check_exist_item($data) {
		$arr_ques = $this->T31TemplateQuestion->getQuesByTemplateId($data['template_id']);
		$list_id = $data['list_id'];

		$list_items = $this->T13InboundListItem->getTitleByListId($list_id);
		$list_columns = array();
		foreach ($list_items as $list_item) {
			$list_columns[$list_item['T13InboundListItem']['item_name']] = $list_item['T13InboundListItem']['column'];
		}

		$tel_lists = $this->T17InboundTelList->getAllByListId($list_id);

		foreach ($arr_ques as $question) {
			//音声内容チェック
			if ($question['T31TemplateQuestion']['audio_type'] == 1 || $question['T31TemplateQuestion']['audio_type'] == 2) {
				$str_content = $question['T31TemplateQuestion']['audio_content'];
				preg_match_all($this::ITEM_REGEX, $str_content, $items);
				foreach ($items[0] as $item) {
					$item_name = preg_replace($this::LEFT_BRACE_REGEX, "",preg_replace($this::RIGHT_BRACE_REGEX, "", $item,1),1);
					if (!isset($list_columns[$item_name])) {
						return false;
					}
				}
			}

			if ($question['T31TemplateQuestion']['question_type'] == QUESTION_TRANS && ($question['T31TemplateQuestion']['trans_timeout_audio_type'] == 1 || $question['T31TemplateQuestion']['trans_timeout_audio_type'] == 2)) {
				$str_content = $question['T31TemplateQuestion']['trans_timeout_audio_content'];
				preg_match_all($this::ITEM_REGEX, $str_content, $items);
				foreach ($items[0] as $item) {
					$item_name = preg_replace($this::LEFT_BRACE_REGEX, "",preg_replace($this::RIGHT_BRACE_REGEX, "", $item,1),1);
					if (!isset($list_columns[$item_name])) {
						return false;
					}
				}
			}
			if ($question['T31TemplateQuestion']['question_type'] == QUESTION_INBOUND_SMS
			|| $question['T31TemplateQuestion']['question_type'] == QUESTION_INBOUND_SMS_INPUT) {
				$str_content = $question['T31TemplateQuestion']['sms_content'];
				preg_match_all($this::ITEM_REGEX, $str_content, $items);
				foreach ($items[0] as $item) {
					$item_name = preg_replace($this::LEFT_BRACE_REGEX, "",preg_replace($this::RIGHT_BRACE_REGEX, "", $item,1),1);
					if (!isset($list_columns[$item_name])) {
						return false;
					}
				}
			}

			if ($question['T31TemplateQuestion']['recheck_flag'] == 1 && ($question['T31TemplateQuestion']['recheck_audio_type'] == 1 || $question['T31TemplateQuestion']['recheck_audio_type'] == 2)) {
				$str_content = $question['T31TemplateQuestion']['recheck_audio_content'];
				preg_match_all($this::ITEM_REGEX, $str_content, $items);
				foreach ($items[0] as $item) {
					$item_name = preg_replace($this::LEFT_BRACE_REGEX, "",preg_replace($this::RIGHT_BRACE_REGEX, "", $item,1),1);
					if (!isset($list_columns[$item_name])) {
						return false;
					}
				}
			}
			//認証項目チェック
			if ($question['T31TemplateQuestion']['question_type'] == QUESTION_AUTH ) {
				$auth_item = $question['T31TemplateQuestion']['auth_item'];
				if (!isset($list_columns[$auth_item])) {
					return false;
				}

				foreach ($tel_lists as $tel_list) {
					if ($this->Util->isNullOrWhitespace($tel_list['T17InboundTelList'][$list_columns[$auth_item]])) {
						return false;
					}
				}
			}
		}
		return true;
	}

	function check_inbound_collation($data) {
		$check_flg = false;//着信照合のチェックを行うフラグ
		$arr_ques = $this->T31TemplateQuestion->getQuesByTemplateId($data['template_id']);
		foreach ($arr_ques as $question) {//設定テンプレートに着信照合が存在するか判断
			if ($question['T31TemplateQuestion']['question_type'] == QUESTION_INBOUND_COLLATION){
				$check_flg = true;
			}
		}

		$list_id = $data['list_id'];
		if($check_flg){//着信照合チェック
			//着信照合の存在するテンプレートの場合は着信リストの設定を必須とする
			if(!isset($list_id) || $list_id == ''){
				return false;
			}

			//着信照合の存在するテンプレートの場合は着信リストに電話番号の存在を必須とする
			$call_item_cnt = $this->T13InboundListItem->SearchItemName($list_id,"電話番号");
			if($call_item_cnt == 0){
				return false;
			}
		}

		return true;
	}

	function check_match_main_item($data) {
		$arr_ques = $this->T31TemplateQuestion->getQuesByTemplateId($data['template_id']);
		$arr_list_info = $this->T16InboundCallList->getListInfoById($data['list_id']);

		foreach ($arr_ques as $question) {
			if ($question['T31TemplateQuestion']['question_type'] == QUESTION_AUTH_CHAR && $question['T31TemplateQuestion']['auth_match_flag'] == 1) {
				$auth_item = $question['T31TemplateQuestion']['auth_item'];
				$main_item = isset($arr_list_info['T16InboundCallList']['item_main']) ? $arr_list_info['T16InboundCallList']['item_main'] : '';
				if ($auth_item != $main_item) {
					return false;
				} else {
					return true;
				}
			}
		}
		return true;
	}
	function check_exist_setting_inbound() {
		$data = $this->data;
		$arr_inbound_info = $this->T25Inbound->getInboundById($data['id']);
		if (count($arr_inbound_info) < 1) {
			echo "false";
			exit;
		}
		echo "true";
		exit;
	}
	function check_unlock($lock_flag, $lock_id) {
		$user_id = $this->ESession->getUserId($this);
		$session_id = $this->Session->id();

		$info_lock = $this->T92Lock->getInfoLock($lock_flag, $lock_id);
		if (count($info_lock) > 0 && ($info_lock['T92Lock']['use_user_id'] != $user_id || $info_lock['T92Lock']['session_id'] != $session_id)) {
			return false;
		} else {
			return true;
		}
	}

	/* そのスケジュールの結果をまとめ、セッションに保存する
	 * @param $data['schedule_ids']： T25Inbound.id　（着信設定一覧画面でチェックした分のid）
	 * @return string of result
	 * 		can_download		:未発信DL
	 * 		false				:ダウンロードできないを表す
	 */
	function check_download_uncall() {
		$inbound_ids = $this->data['schedule_ids'];
		foreach ($inbound_ids as $id) {
			$schedule = $this->T25Inbound->getInboundInfoById($id);
			$list_id = (isset($schedule['T25Inbound']['list_id']) && !empty($schedule['T25Inbound']['list_id'])) ? $schedule['T25Inbound']['list_id'] : NULL;
			if ($list_id) {
				$tel_no_item = $this->T13InboundListItem->getTelNumColumn($list_id);
				if (empty($tel_no_item)) {
					echo 'false';
					exit;
				}
			} else {
				echo 'false';
				exit;
			}
		}
		echo 'can_download';
		exit;
	}

    // 利用するテンプレートにQUESTION_PROPERTY_SEARCH（物件入力(賃料、平米) ）がある場合、
    // 利用する電話番号に「bukken_company_id　（物件ID）」の登録有無の判定を行う。
    // return  false：利用するテンプレートにQUESTION_PROPERTY_SEARCH（物件入力(賃料、平米) ）があり、
    //               利用する電話番号に「bukken_company_id　（物件ID）」に値がない
    //               ※例外として、M07ServerExternalより値が取れない場合も含む。
    //         true：上記以外
	function check_set_bukken_company_id($data) {
		$external_info = $this->M07ServerExternal->getServerExternalByTel($data["external_number"]);
		$set_bukken_info = false;
		if (!empty($external_info)) {
			$bukken_company_id = $external_info['M07ServerExternal']['bukken_company_id'];
			$bukken_shop_id = $external_info['M07ServerExternal']['bukken_shop_id'];
			if($bukken_company_id && $bukken_shop_id){
				$set_bukken_info = true;
			}
		}
		else{
			$this->log("check_set_bukken_company_id failed. empty external_info.");
			$this->log($data["external_number"]);
			$this->log(print_r($external_info, 1));
			return false;
		}
		$arr_ques = $this->T31TemplateQuestion->getQuesByTemplateId($data['template_id']);
		foreach ($arr_ques as $question) {
			if ($question['T31TemplateQuestion']['question_type'] == QUESTION_PROPERTY_SEARCH && $set_bukken_info === false){
    			return false;
			}
		}
		return true;
	}

	/* アカウントのSMSアカウントが存在するかどうかを確認する
	*
	*/
	function check_set_sms_account($data){
		$hasSms = false;
		$arr_ques = $this->T31TemplateQuestion->getQuesByTemplateId($data['template_id']);
		foreach ($arr_ques as $question) {
			if ($question['T31TemplateQuestion']['question_type'] == QUESTION_INBOUND_SMS
			|| $question['T31TemplateQuestion']['question_type'] == QUESTION_INBOUND_SMS_INPUT) {
				$hasSms = true;
				break;
			}
		}

		if(!$hasSms){
			return true;
		}

		$company_id = $this->ESession->getUserCompanyId($this);
		$phoneNotifyList = $this->M08SmsApiInfo->getServiceIdByCompanyId($company_id);
		if(empty($phoneNotifyList))
			return false;
		else return true;
	}


	// 20160413 Add by Giang - #6906 Inbound history screen - Begin
	// 着信設定の状況を見るボタンクリック
	function detail() {
		if (!isset($this->data['setting_inbound_id']) || empty($this->data['setting_inbound_id'])) {
			$this->redirect(array('controller' => 'InboundIncomingHistory', 'action' => 'index'));
		}
		$inbound_id = $this->data['setting_inbound_id'];
		$this->ESession->setInboundId($inbound_id, $this);
		$schedule = $this->T25Inbound->getInboundInfoById($inbound_id);
		$list_id = (isset($schedule['T25Inbound']['list_id']) && !empty($schedule['T25Inbound']['list_id'])) ? $schedule['T25Inbound']['list_id'] : NULL;

		$question_types = array(
			QUESTION_BASIC,
			QUESTION_AUTH,
			QUESTION_TEL,
			QUESTION_TRANS,
			QUESTION_RECORD,
			QUESTION_COUNT,
			QUESTION_AUTH_CHAR,
			QUESTION_PROPERTY,
			QUESTION_FAX,
			QUESTION_PROPERTY_SEARCH,
			QUESTION_INBOUND_SMS,
			QUESTION_INBOUND_COLLATION,
			QUESTION_INBOUND_SMS_INPUT,
		);
		$enable_download = $this->M04ControllerAction->check_permission($this->post_code, 'SettingInbound', 'download');

		$enable_download_uncalled = $enable_download;
		if ($list_id) {
			$tel_no_item = $this->T13InboundListItem->getTelNumColumn($list_id);
			$enable_download_uncalled = !empty($tel_no_item) ? true : false;
		} else {
			$enable_download_uncalled = false;
		}

		$data_headers = $this->get_data_header_schedule($inbound_id, $question_types);
		$headers = $data_headers['headers'];
		$sort_flags = $data_headers['sort_flags'];

		$this->set('headers', $headers);
		$this->set('sort_flags', $sort_flags);

		$this->set('enable_download', $enable_download);
		$this->set('schedule', $schedule);
		$this->set('enable_download_uncalled', $enable_download_uncalled);
	}

	function arr_incoming_result($js_page, $limit, $column) {
		$schedule_id = $this->ESession->getInboundId($this);
		$arr_operator = array('<', '=', '>', '≠');
		$question_types = array(
			QUESTION_BASIC,
			QUESTION_AUTH,
			QUESTION_TEL,
			QUESTION_TRANS,
			QUESTION_RECORD,
			QUESTION_COUNT,
			QUESTION_AUTH_CHAR,
			QUESTION_PROPERTY,
			QUESTION_FAX,
			QUESTION_PROPERTY_SEARCH,
			QUESTION_INBOUND_SMS,
			QUESTION_INBOUND_COLLATION,
			QUESTION_INBOUND_SMS_INPUT,
		);
		$smsStatusTitle = array(
            INBOUND_SMS_STATUS_SUCCESS => '着信済み',
            INBOUND_SMS_STATUS_OUTSIDE => '圏外',
            INBOUND_SMS_STATUS_UNKNOWN => '不明',
            INBOUND_SMS_STATUS_SENDING => '送信中',
            INBOUND_SMS_STATUS_ERROR => 'エラー',
            INBOUND_SMS_STATUS_NO_SEND => '',
        );
		$this->layout = 'ajax';
		if (isset($_GET["filter"]) && !empty($_GET["filter"])) {
			$filter = $_GET["filter"];
		} else {
			$filter = NULL;
		}
		$schedule = $this->T25Inbound->getHistoryInfoById($schedule_id);
		$list_id = (isset($schedule['T25Inbound']['list_id']) && !empty($schedule['T25Inbound']['list_id'])) ? $schedule['T25Inbound']['list_id'] : NULL;

		$arr_answer_pos = $this->get_answer_pos($schedule_id);
		$arr_ques_pos = $this->get_ques_pos_in_header_detail($schedule_id, $question_types);

		$page = $js_page + 1;
		$json_data = array();
		$json_data['headers'] = Array('着信日時', '着信元', '接続時間', 'ステータス');

		$questions = array();
		$answer_pos_auth_character = NULL;
		$question_temps = $this->T64InboundQuestionHistory->getInfoQuesAnswByScheduleId($schedule_id, $question_types);

		//テンプレートの全タイプを保持
		$tmp_question_all_type = $this->T64InboundQuestionHistory->getQuesNumByScheduleId($schedule_id, $question_types);
		foreach ($tmp_question_all_type as $tmp) {
			$question_all_type[] = $tmp['T64InboundQuestionHistory']['question_type'];
		}

		foreach ($question_temps as $ques) {
			$ques_no = $ques['T64InboundQuestionHistory']['question_no'];
			$questions[$ques_no]['T64InboundQuestionHistory'] = $ques['T64InboundQuestionHistory'];
			$questions[$ques_no]['T65InboundButtonHistory'][$ques['T65InboundButtonHistory']['answer_no']] = $ques['T65InboundButtonHistory'];
			if ($ques['T64InboundQuestionHistory']['auth_match_flag'] == 1){//リスト認証ありの項目を取得
				$auth_item = $ques['T64InboundQuestionHistory']['auth_item'];
				$answer_pos_auth_character = $arr_answer_pos[$ques_no];
			}
 		}
		//着信リストを取得
		if (!empty($list_id)) {
			$Incomingcolumn = $this->T13InboundListItem->getTelNumColumn($list_id);
			if (!empty($Incomingcolumn)) {
				$IncomingList = $this->T57InboundTelHistory->getDataItemMainByIdAndItemMain($schedule_id, $Incomingcolumn['T13InboundListItem']['column']);
			}
		}

		$data_headers = $this->get_data_header_schedule($schedule_id, $question_types, true);
		$get_list_tel_flag = $data_headers['get_list_tel_flag'];
		$json_data['headers'] = array_merge($json_data['headers'], $data_headers['headers']);
		$arr_list_items = Array();
		$arr_auth_column = array();
		$item_main_column = NULL;
		$join_col = NULL;
		if ($list_id) {
			$inbound_list = $this->T56InboundListHistory->getItemMainByInboundId($schedule_id);
			$item_main_name = $inbound_list['T56InboundListHistory']['item_main'];

	 		$t13_list_items = $this->T13InboundListItem->getTitleByListId($list_id);
			foreach ($t13_list_items as $list_item) {
				if ($list_item['T13InboundListItem']['item_name'] == $item_main_name) {
					$item_main_column = $list_item['T13InboundListItem']['column'];
				}

				$arr_list_items[$list_item['T13InboundListItem']['item_name']] = array(
					'item_code' => $list_item['T13InboundListItem']['item_code'],
					'column' => $list_item['T13InboundListItem']['column']
				);
			}
			if ($answer_pos_auth_character) {
				$join_col = 'answer' . $answer_pos_auth_character;
			} elseif ($arr_list_items[$item_main_name]['item_code'] == 'tel_no') {
				$join_col = 'tel_no';
			}

			if ($get_list_tel_flag) {
				foreach ($questions as $question) {
					if (($question['T64InboundQuestionHistory']['question_type'] == QUESTION_AUTH) || ($question['T64InboundQuestionHistory']['question_type'] == QUESTION_AUTH_CHAR)) {
						$arr_auth_column[$question['T64InboundQuestionHistory']['question_no']] = $arr_list_items[$question['T64InboundQuestionHistory']['auth_item']];
					}
				}
			}
		}

		//着信番号照合の認証結果は実際にかかってきた番号で判断する
		if (in_array(QUESTION_INBOUND_COLLATION,$question_all_type)){
			//着信番号照合の場合は、memoから照合項目を取得する
			$join_col = 'memo';
		}

		$has_inbound_sms = false;
		$referents = array();			//position_in_header => answer_position_in_t81
		$arr_pos_ques_basic = array();	//position_in_header => question_no
		$arr_pos_ques_auth = array();	//position_in_header => question_no
		foreach ($arr_ques_pos as $question_no => $ques_pos) {
			$referents[$ques_pos] = $arr_answer_pos[$question_no];
			if (($questions[$question_no]['T64InboundQuestionHistory']['question_type'] == QUESTION_AUTH) || ($questions[$question_no]['T64InboundQuestionHistory']['question_type'] == QUESTION_AUTH_CHAR)) {
				$referents[$ques_pos + 1] = $arr_answer_pos[$question_no];
				$arr_pos_ques_auth[$ques_pos + 1] = array(
					'question_no' => $question_no,
					'auth_item_code' => $arr_auth_column[$question_no]['item_code'],
					'auth_item_column' => $arr_auth_column[$question_no]['column']
				);

				if ($questions[$question_no]['T64InboundQuestionHistory']['recheck_flag'] == 1) {
					$referents[$ques_pos + 2] = $arr_answer_pos[$question_no] + 1;
					$arr_pos_ques_auth[$ques_pos + 2] = array(
						'question_no' => $question_no,
						'recheck_button_next' => $questions[$question_no]['T64InboundQuestionHistory']['recheck_button_next']
					);
				}
			}

			if ($questions[$question_no]['T64InboundQuestionHistory']['question_type'] == QUESTION_BASIC) {
				$arr_pos_ques_basic[$ques_pos] = $question_no;
			}
			if($questions[$question_no]['T64InboundQuestionHistory']['question_type'] == QUESTION_PROPERTY){
				$referents[$ques_pos + 1] = $arr_answer_pos[$question_no] + 2;
				$referents[$ques_pos + 2] = $arr_answer_pos[$question_no] + 4;
				$referents[$ques_pos + 3] = $arr_answer_pos[$question_no] + 6;
			}
			if($questions[$question_no]['T64InboundQuestionHistory']['question_type'] == QUESTION_FAX){
				$referents[$ques_pos] = $arr_answer_pos[$question_no] + 1;
				$referents[$ques_pos + 1] = $arr_answer_pos[$question_no] + 3;
				$referents[$ques_pos + 2] = 'fax_status';
				$referents['fax_ques_no_' . ($ques_pos + 2)] = $question_no;
			}
			if($questions[$question_no]['T64InboundQuestionHistory']['question_type'] == QUESTION_PROPERTY_SEARCH){
				$referents[$ques_pos + 1] = $arr_answer_pos[$question_no] + 2;
				$referents[$ques_pos + 2] = $arr_answer_pos[$question_no] + 10;
				$referents[$ques_pos + 3] = $arr_answer_pos[$question_no] + 11;
				$referents[$ques_pos + 4] = $arr_answer_pos[$question_no] + 12;
			}
			if($questions[$question_no]['T64InboundQuestionHistory']['question_type'] == QUESTION_INBOUND_SMS){
				$referents[$ques_pos] = 'inbound_sms_status';
				$referents['inbound_sms_'.$ques_pos] = $question_no;
				$has_inbound_sms = true;
			}
			if($questions[$question_no]['T64InboundQuestionHistory']['question_type'] == QUESTION_INBOUND_SMS_INPUT){
				$referents[$ques_pos + 1] = $arr_answer_pos[$question_no] + 1;
				$referents[$ques_pos + 2] = 'inbound_sms_input_status';
				$referents['inbound_sms_input_'.($ques_pos + 2)] = $question_no;
				$has_inbound_sms = true;
			}
		}
		if (isset($column) && !empty($column) && $column != "column") {
			$sort_order = $this->Util->getInboundDetailSortOrder($column, $referents, $arr_pos_ques_basic, $arr_pos_ques_auth);
		}

		//get data to result
		//t81とt57を結合し、スケジュールすべてのデータを取得
		$logs = $this->T81IncomingResult->getResultByScheduleId($schedule_id, $item_main_column, $limit, $page, $sort_order[0], $filter, $referents, $arr_pos_ques_basic, $arr_pos_ques_auth, $join_col);

		$json_data['total_rows'] = $this->T81IncomingResult->getCountByScheduleId($schedule_id, $item_main_column, $filter, $referents, $arr_pos_ques_basic, $arr_pos_ques_auth, $join_col);
		$json_data['rows'] = Array();

		$inbound_sms_logs = Array();
		if($has_inbound_sms){
			$tmp_sms_log = $this->T86InboundSmsStatus->getSmsLogByInboundId($schedule_id);
			foreach ($tmp_sms_log as $log) {
				$inbound_sms_logs[$log['T86InboundSmsStatus']['log_id']][$log['T86InboundSmsStatus']['sms_question_no']] = $log;
			}
		}
		foreach ($logs as $log) {
			if ($log['T81IncomingResult']['status'] != 'recover') {
				$i = 0;
				$tel_num = !empty($log['T81IncomingResult']['tel_no']) ? $log['T81IncomingResult']['tel_no'] : 'anonymous';
				$json_row[$json_data['headers'][$i++]] = '<td>' . $log['T81IncomingResult']['call_datetime'] . '</td>';
				$json_row[$json_data['headers'][$i++]] = '<td>' . $tel_num . '</td>';

				$call_time = Date('i:s', strtotime($log['T81IncomingResult']['cut_datetime']) - strtotime($log['T81IncomingResult']['connect_datetime']));


				if (in_array($log['T81IncomingResult']['status'], $this->Util->getCallResultNoConvertArray())) {
					$status = strtoupper($log['T81IncomingResult']['status']);
				}
				else if(in_array($log['T81IncomingResult']['status'] , $this->Util->getCallResultConvertTFRejectArray())){
					$status = 'TRANSFERREJECT';
				}
				else {
					$status = 'ANSWER';
				}
				$json_row[$json_data['headers'][$i++]] = '<td>' . $call_time . '</td>';
				$json_row[$json_data['headers'][$i++]] = '<td>' . $status . '</td>';

				foreach ($questions as $question) {
					$question_no = $question['T64InboundQuestionHistory']['question_no'];
					$answer_pos = $arr_answer_pos[$question_no];
					$question_type = $question['T64InboundQuestionHistory']['question_type'];
					if($question_type == QUESTION_INBOUND_SMS){
						$sms = $inbound_sms_logs[$log['T81IncomingResult']['id']][$question_no];
						$inbound_sms_status = !empty($sms['T86InboundSmsStatus']['sms_status'])?$smsStatusTitle[$sms['T86InboundSmsStatus']['sms_status']]:'';
						// FAX　ステータス
						$json_row[$json_data['headers'][$i++]] = '<td>' . $inbound_sms_status . '</td>';
						continue;
					}
					if(isset($question_type) && $question_type == QUESTION_FAX){
						$value = $log['T81IncomingResult']['answer' . ($answer_pos + 1)];
					}else
						$value = isset($answer_pos) && $question['T64InboundQuestionHistory']['question_type'] != QUESTION_TRANS ? $log['T81IncomingResult']['answer' . $answer_pos] : '';
					// 先頭カラム
					$json_row[$json_data['headers'][$i++]] = '<td>' . $value . '</td>';

					if ($question['T64InboundQuestionHistory']['question_type'] == QUESTION_BASIC) {
						if (isset($question['T65InboundButtonHistory'][$value]) && !empty($question['T65InboundButtonHistory'][$value]['answer_content'])) {
							$json_row[$json_data['headers'][$i - 1]] = '<td>' . $question['T65InboundButtonHistory'][$value]['answer_content'] . '</td>';
						}
					} elseif ($question['T64InboundQuestionHistory']['question_type'] == QUESTION_AUTH) {
						$auth_column = $arr_auth_column[$question_no]['column'];
						$auth_value = $log['T57InboundTelHistory'][$auth_column];
						if (isset($auth_value) && $auth_value !== '' && isset($value) && $value !== '') {
							$auth_item_code = $arr_auth_column[$question_no]['item_code'];
							if ($auth_item_code == 'birthday') {
								$auth_value = DateTime::createFromFormat('Y年m月d日', $auth_value)->format('Ymd');
							} else {
								$auth_value = preg_replace('/[^\d]/', '', $auth_value);
							}

							if ($value < $auth_value) {
								$auth_operator = $arr_operator[0];
							} elseif ($value == $auth_value) {
								$auth_operator = $arr_operator[1];
							} else {
								$auth_operator = $arr_operator[2];
							}
						} else {
							$auth_operator = '';
						}
						$json_row[$json_data['headers'][$i++]] = '<td>' . $auth_operator . '</td>';

						if ($question['T64InboundQuestionHistory']['recheck_flag'] == 1) {
							$pos_input = -1;
							for ($k=0; $k<3; $k++) {
								if ($log['T81IncomingResult']['answer' . ($answer_pos + $k + 1)] != '' && $pos_input < 0) {
									$pos_input = $k;
								}
								if ($log['T81IncomingResult']['answer' . ($answer_pos + $k + 1)] == $question['T64InboundQuestionHistory']['recheck_button_next']) {
									$pos_input = $k;
									break;
								}
							}
							if ($pos_input >= 0) {
								$json_row[$json_data['headers'][$i++]] = '<td>' . $log['T81IncomingResult']['answer' . ($answer_pos + $pos_input + 1)] . '</td>';
							} else {
								$json_row[$json_data['headers'][$i++]] = '<td></td>';
							}
						}
					} elseif ($question['T64InboundQuestionHistory']['question_type'] == QUESTION_AUTH_CHAR) {//文字列認証結果の結果出力
						$auth_column = $arr_auth_column[$question_no]['column'];
						$auth_value = $log['T57InboundTelHistory'][$auth_column];
						if (isset($auth_value) && $auth_value !== '' && isset($value) && $value !== '') {

							$auth_item_code = $arr_auth_column[$question_no]['item_code'];
							if ($auth_item_code == 'birthday') {
								$auth_value = DateTime::createFromFormat('Y年m月d日', $auth_value)->format('Ymd');
							} else {
								$auth_value = preg_replace('/[^\d]/', '', $auth_value);
							}

							if ($value === $auth_value) {
								$auth_operator = $arr_operator[1];
							} else {
								//着信リスト照合なしの不一致
								$auth_operator = $arr_operator[3];
							}
						}elseif (isset($value) && $value !== ''){
							//着信リスト照合ありの不一致
							$auth_operator = $arr_operator[3];
						} else {
							$auth_operator = '';
						}

						$json_row[$json_data['headers'][$i++]] = '<td>' . $auth_operator . '</td>';

						if ($question['T64InboundQuestionHistory']['recheck_flag'] == 1) {
							if (($log['T81IncomingResult']['answer' . ($answer_pos_auth_character + 1)] == $question['T64InboundQuestionHistory']['recheck_button_next'])
								|| ($log['T81IncomingResult']['answer' . ($answer_pos_auth_character + 2)] == $question['T64InboundQuestionHistory']['recheck_button_next'])) {
								$auth_input = $question['T64InboundQuestionHistory']['recheck_button_next'];
							} elseif (!empty($log['T81IncomingResult']['answer' . ($answer_pos_auth_character + 1)])) {
								$auth_input = $log['T81IncomingResult']['answer' . ($answer_pos_auth_character + 1)];
							} elseif (!empty($log['T81IncomingResult']['answer' . ($answer_pos_auth_character + 2)])) {
								$auth_input = $log['T81IncomingResult']['answer' . ($answer_pos_auth_character + 2)];
							} else {
								$auth_input = '';
							}
							$json_row[$json_data['headers'][$i++]] = '<td>' . $auth_input . '</td>';
						}
					} elseif ($question['T64InboundQuestionHistory']['question_type'] == QUESTION_RECORD) {
						$date_now = Date('Y-m-d');
						$date_call = Date('Y-m-d', strtotime('+1 day', strtotime($log['T81IncomingResult']['call_datetime'])));
						if (!empty($log['T81IncomingResult']['valid_count']) && ($date_now >= $date_call)) {
							$str_btn_wav = '<p>'
								. '<a class="btn btn_wav btnDownloadRecord btn-default" schedule_id = "'.$schedule_id.'" tel_no="'.$log['T81IncomingResult']['tel_no'].'" prefix_record="'.$log['T81IncomingResult']['prefix'].'">'
								. '<i class="glyphicon glyphicon-download-alt" ></i>'
								. '</a>'
								. '</p>';
							$json_row[$json_data['headers'][$i - 1]] = '<td>' . $str_btn_wav . '</td>';
							$json_row[$json_data['headers'][$i++]] = '<td>' . $log['T81IncomingResult']['valid_count'] . '</td>';
						} else {
							$json_row[$json_data['headers'][$i - 1]] = '<td></td>';
							$json_row[$json_data['headers'][$i++]] = '<td></td>';
						}
					} elseif ($question['T64InboundQuestionHistory']['question_type'] == QUESTION_TRANS) {
						$tranfer_time = strtotime($log['T81IncomingResult']['trans_cut_datetime']) - strtotime($log['T81IncomingResult']['trans_connect_datetime']);
						$json_row[$json_data['headers'][$i-1]] = $tranfer_time > 0 ? Date('i:s', $tranfer_time) : '';
					} elseif ($question['T64InboundQuestionHistory']['question_type'] == QUESTION_TEL && $question['T64InboundQuestionHistory']['recheck_flag'] == 1) {
						$json_row[$json_data['headers'][$i++]] = '<td>' . $log['T81IncomingResult']['answer' . ($answer_pos + 1)] . '</td>';
					} elseif ($question_type == QUESTION_FAX) {
						$bukken_fax = $this->T82BukkenFaxStatus->getFaxStatus($log['T81IncomingResult']['id'], $question_no);
						$fax_status = !empty($bukken_fax['T82BukkenFaxStatus']['fax_status'])?$bukken_fax['T82BukkenFaxStatus']['fax_status']:'';
						// FAX入力　繰返し確認番号
						$json_row[$json_data['headers'][$i++]] = '<td>' . $log['T81IncomingResult']['answer' . ($answer_pos + 3)] . '</td>';
						// FAX　ステータス
						$json_row[$json_data['headers'][$i++]] = '<td>' . $fax_status . '</td>';
					} elseif ($question_type == QUESTION_PROPERTY) {
						// 物件番号入力　繰返し確認番号
						$json_row[$json_data['headers'][$i++]] = '<td>' . $log['T81IncomingResult']['answer' . ($answer_pos + 2)] . '</td>';
						// 物件番号入力　図面希望番号
						$json_row[$json_data['headers'][$i++]] = '<td>' . $log['T81IncomingResult']['answer' . ($answer_pos + 4)] . '</td>';
						// 物件番号入力　継続入力番号
						$json_row[$json_data['headers'][$i++]] = '<td>' . $log['T81IncomingResult']['answer' . ($answer_pos + 6)] . '</td>';
					} elseif ($question_type == QUESTION_PROPERTY_SEARCH) {
						$json_row[$json_data['headers'][$i++]] = '<td>' . $log['T81IncomingResult']['answer' . ($answer_pos + 2)] . '</td>';
						$json_row[$json_data['headers'][$i++]] = '<td>' . $log['T81IncomingResult']['answer' . ($answer_pos + 10)] . '</td>';
						// 回答内容を変換する(rental2.Decideの戻り値が1ならば「有」、それ以外なら「無」)
						// 回答なしは空欄のままにする
						if($log['T81IncomingResult']['answer' . ($answer_pos + 11)] != ""){
							$massage = $log['T81IncomingResult']['answer' . ($answer_pos + 11)]  == 1 ? "有" : "無";
						}
						else{
							$massage = $log['T81IncomingResult']['answer' . ($answer_pos + 11)] ;
						}
						$json_row[$json_data['headers'][$i++]] = '<td>' . $massage . '</td>';
						$json_row[$json_data['headers'][$i++]] = '<td>' . $log['T81IncomingResult']['answer' . ($answer_pos + 12)] . '</td>';
					} elseif ($question_type == QUESTION_INBOUND_COLLATION) {	//着信照合の結果出力

						//着信照合（True）、文字列認証（リスト照合あり）にてTrueの場合、着信リストの行が入れ替わった場合の対応
						//※着信照合通過できていない場合は失敗（≠）を表示
						//最終的に保持している行で照合結果を表示する。
						if (in_array(QUESTION_AUTH_CHAR,$question_all_type) && in_array($tel_num,$IncomingList)){
							$auth_item = explode(':',$log['T81IncomingResult']['memo']);//着信照合の認証結果判断
							$auth_result = $this->T57InboundTelHistory->getByMatchitem($schedule_id, $item_main_column, $auth_item[0]);

							if ($auth_result >= 1 && isset($value) && $value !== ''){
								$auth_operator = $arr_operator[1];
							} elseif ($auth_result == 0 && isset($value) && $value !== ''){
								$auth_operator = $arr_operator[3];
							} else {
								$auth_operator = '';
							}
						}else{
							if (in_array($tel_num,$IncomingList)){
								$auth_operator = $arr_operator[1];
							}else {
								$auth_operator = $arr_operator[3];
							}
						}
						$json_row[$json_data['headers'][$i - 1]] = '<td>' . $auth_operator . '</td>';	
					}elseif ($question_type == QUESTION_INBOUND_SMS_INPUT){
						$sms = $inbound_sms_logs[$log['T81IncomingResult']['id']][$question_no];
						$inbound_sms_input_status = !empty($sms['T86InboundSmsStatus']['sms_status'])?$smsStatusTitle[$sms['T86InboundSmsStatus']['sms_status']]:'';
						// SMS　ステータス
						$json_row[$json_data['headers'][$i++]] = '<td>' . $log['T81IncomingResult']['answer' . ($answer_pos + 1)] . '</td>';
						$json_row[$json_data['headers'][$i++]] = '<td>' . $inbound_sms_input_status . '</td>';
						
					}
				}

				$json_data['rows'][] = (object) $json_row;
			}
		}

		$json_data['sortColumn'] = $sort_order[1];
		$json_data['sortType'] = $sort_order[2];
		$json_data['page'] = $js_page;

		$this->ESession->setSortColumn($sort_order[1], $this);
		$this->ESession->setSortType($sort_order[2], $this);
		$this->ESession->setPage($js_page, $this);
		echo json_encode($json_data);
		exit;
	}

	/* Get answer position in t81. example: answer1
	 * @param: $schedule_id is inbound id
	 * @return : array answer position
	 */
	function get_answer_pos($schedule_id) {
		$arr_answer_pos = array();
		$current_pos = 1;
		// 質問毎の回答数を定義
		$arr_count_column = array(
			QUESTION_VOICE => 0,
			QUESTION_BASIC => 1,
			QUESTION_AUTH => array(
				0 => 1,
				1 => 4
			),
			QUESTION_TEL => array(
				0 => 1,
				1 => 2
			),
			QUESTION_TRANS => 0,
			QUESTION_RECORD => 0,
			QUESTION_COUNT => 1,
			QUESTION_END => 0,
			QUESTION_TIMEOUT => 0,
			QUESTION_AUTH_CHAR => array(
				0 => 1,
				1 => 3
			),
			QUESTION_FAX => 5,
			QUESTION_PROPERTY => 7,
			// spリストのqまたはobjの数を書く。
			QUESTION_PROPERTY_SEARCH => 13,
			QUESTION_INBOUND_SMS => 1,
			QUESTION_INBOUND_COLLATION => 1,
			QUESTION_INBOUND_SMS_INPUT => 3,
		);

		// 実際に使用した質問内容を取得(templateは変更サれるため、t64を採用)
		$questions = $this->T64InboundQuestionHistory->getQuesNumByScheduleId($schedule_id);

		foreach ($questions as $question) {
			$question_no = $question['T64InboundQuestionHistory']['question_no'];
			$question_type = $question['T64InboundQuestionHistory']['question_type'];
			if (in_array($question_type, array(QUESTION_AUTH, QUESTION_TEL, QUESTION_AUTH_CHAR))) {
				$count_column = $arr_count_column[$question_type][$question['T64InboundQuestionHistory']['recheck_flag']];
			} else {
				$count_column = $arr_count_column[$question_type];
			}

			if ($count_column > 0) {
				$arr_answer_pos[$question_no] = $current_pos;
				$current_pos += $count_column;
			} elseif ($question_type == QUESTION_TRANS) {
				$arr_answer_pos[$question_no] = 'trans_call_time';
			} else {
				$arr_answer_pos[$question_no] = NULL;
			}
		}

		return $arr_answer_pos;
	}

	/* Get position of question in header of inbound detail screen
	 * @param $schedule_id is inbound id
	 * @param $question_type is array question types of template be setup by $schedule_id
	 * @return array postion of question in header
	 */
	function get_ques_pos_in_header_detail($schedule_id, $question_types=array()) {
		$arr_ques_pos = array();
		$current_pos = 1;
		// Number column of question be displayed
		$arr_count_column = array(
			QUESTION_VOICE => 0,
			QUESTION_BASIC => 1,
			QUESTION_AUTH => array(
				0 => 2,
				1 => 3
			),
			QUESTION_TEL => array(
				0 => 1,
				1 => 2
			),
			QUESTION_TRANS => 1,
			QUESTION_RECORD => 2,
			QUESTION_COUNT => 1,
			QUESTION_END => 0,
			QUESTION_TIMEOUT => 0,
			QUESTION_AUTH_CHAR => array(
				0 => 2,
				1 => 3
			),
			QUESTION_PROPERTY => 4,
			QUESTION_FAX => 3,
			QUESTION_PROPERTY_SEARCH => 6,
			QUESTION_INBOUND_SMS => 1,
			QUESTION_INBOUND_COLLATION => 1,
			QUESTION_INBOUND_SMS_INPUT => 3,
		);
		$questions = $this->T64InboundQuestionHistory->getQuesNumByScheduleId($schedule_id, $question_types);

		foreach ($questions as $question) {
			$question_no = $question['T64InboundQuestionHistory']['question_no'];
			$question_type = $question['T64InboundQuestionHistory']['question_type'];
			if (in_array($question_type, array(QUESTION_AUTH, QUESTION_TEL, QUESTION_AUTH_CHAR))) {
				$count_column = $arr_count_column[$question_type][$question['T64InboundQuestionHistory']['recheck_flag']];
			} else {
				$count_column = $arr_count_column[$question_type];
			}

			if ($count_column > 0) {
				$arr_ques_pos[$question_no] = $current_pos;
				$current_pos += $count_column;
			} else {
				$arr_ques_pos[$question_no] = NULL;
			}
		}

		return $arr_ques_pos;
	}

	// そのセクションのヘッダーを作成
	function get_data_header_schedule($schedule_id, $question_types = array(), $contain_question_no = false, $download_flag = false) {
		$questions = $this->T64InboundQuestionHistory->getQuesNumByScheduleId($schedule_id, $question_types);

		$data['get_list_tel_flag'] = false;
		$data['headers'] = array();
		$data['sort_flags'] = array();
		foreach ($questions as $question) {
			$question_no = $contain_question_no ? $question['T64InboundQuestionHistory']['question_no'] : '';
			$question_type = $question['T64InboundQuestionHistory']['question_type'];
			$question_title = $this->get_question_type($question_type);
			$enter = $download_flag ? '' : '<br/>';
			if ($question_type == QUESTION_AUTH) {
				$auth_item = $question['T64InboundQuestionHistory']['auth_item'];
				$enter = $download_flag ? '' : '<br/>';
				$data['get_list_tel_flag'] = true;
				$data['headers'][] = $question_no . $this->getQuestionTitle($question['T64InboundQuestionHistory']['question_title']) . $question_title . '入力' . $enter . '(' . $auth_item . ')';
				$data['headers'][] = $question_no . $this->getQuestionTitle($question['T64InboundQuestionHistory']['question_title']) . $question_title . '結果';
				$data['sort_flags'][] = 1;
				$data['sort_flags'][] = 2;
				if ($question['T64InboundQuestionHistory']['recheck_flag'] == 1) {
					$data['headers'][] = $question_no . $this->getQuestionTitle($question['T64InboundQuestionHistory']['question_title']) . $question_title;
					$data['sort_flags'][] = 1;
				}
			} elseif ($question_type == QUESTION_AUTH_CHAR) {
				$auth_item = $question['T64InboundQuestionHistory']['auth_item'];
				$enter = $download_flag ? '' : '<br/>';
				$data['get_list_tel_flag'] = true;
				$data['headers'][] = $question_no . $this->getQuestionTitle($question['T64InboundQuestionHistory']['question_title']) . $question_title . '入力' . $enter . '(' . $auth_item . ')';
				$data['headers'][] = $question_no . $this->getQuestionTitle($question['T64InboundQuestionHistory']['question_title']) . $question_title . '結果';
				$data['sort_flags'][] = 1;
				$data['sort_flags'][] = 3;
				if ($question['T64InboundQuestionHistory']['recheck_flag'] == 1) {
					$data['headers'][] = $question_no . $this->getQuestionTitle($question['T64InboundQuestionHistory']['question_title']) . $question_title;
					$data['sort_flags'][] = 1;
				}
			} elseif ($question_type == QUESTION_TEL) {
				$data['headers'][] = $question_no . $this->getQuestionTitle($question['T64InboundQuestionHistory']['question_title']) . $question_title;
				$data['sort_flags'][] = 0;
				if ($question['T64InboundQuestionHistory']['recheck_flag'] == 1) {
					$data['headers'][] = $question_no . $this->getQuestionTitle($question['T64InboundQuestionHistory']['question_title']) . $question_title . 'ボタン';
					$data['sort_flags'][] = 0;
				}
			} elseif ($question_type == QUESTION_RECORD) {
				$data['headers'][] = $question_no . $this->getQuestionTitle($question['T64InboundQuestionHistory']['question_title']) . $question_title;
				$data['headers'][] = $question_no . $this->getQuestionTitle($question['T64InboundQuestionHistory']['question_title']) . $question_title . '時間';
				$data['sort_flags'][] = 0;
				$data['sort_flags'][] = 0;
			} elseif ($question_type == QUESTION_BASIC) {
				$data['headers'][] = $question_no . $this->getQuestionTitle($question['T64InboundQuestionHistory']['question_title']) . $question_title;
				$data['sort_flags'][] = 1;
			} elseif ($question_type == QUESTION_TRANS) {
				$data['headers'][] = $question_no . $this->getQuestionTitle($question['T64InboundQuestionHistory']['question_title']) . $question_title;
				$data['sort_flags'][] = 1;
			} elseif ($question_type == QUESTION_PROPERTY) {
				$data['headers'][] = $question_no . $question_title;
				$data['headers'][] = $question_no . $question_title. $enter .'繰返し確認ボタン';
				$data['headers'][] = $question_no . $question_title. $enter .'図面希望ボタン';
				$data['headers'][] = $question_no . $question_title. $enter .'継続確認ボタン';
				$data['sort_flags'][] = 1;
				$data['sort_flags'][] = 1;
				$data['sort_flags'][] = 1;
				$data['sort_flags'][] = 1;
			} elseif ($question_type == QUESTION_FAX) {
				$data['headers'][] = $question_no . $question_title;
				$data['headers'][] = $question_no . $question_title. $enter .'繰返し確認ボタン';
				$data['headers'][] = $question_no . $question_title. $enter .'FAX送信状態';
				$data['sort_flags'][] = 1;
				$data['sort_flags'][] = 1;
				$data['sort_flags'][] = 4;
			// 着信設定のヘッダ部分
			} elseif ($question_type == QUESTION_PROPERTY_SEARCH) {
				$data['headers'][] = $question_no . $question_title. $enter .'賃料';
				$data['headers'][] = $question_no . $question_title. $enter .'平米数';
				$data['headers'][] = $question_no . $question_title. $enter .'物件選択';
				$data['headers'][] = $question_no . $question_title. $enter .'空きの有無';
				$data['headers'][] = $question_no . $question_title. $enter .'継続確認ボタン';
				$data['sort_flags'][] = 1;
				$data['sort_flags'][] = 1;
				$data['sort_flags'][] = 1;
				$data['sort_flags'][] = 1;
				$data['sort_flags'][] = 1;
			} elseif($question_type == QUESTION_INBOUND_SMS){
				if($download_flag){
					$data['headers'][] = $question_no . $this->getQuestionTitle($question['T64InboundQuestionHistory']['question_title']) . $question_title. $enter .'(送達状態)';
					$data['headers'][] = $question_no . $this->getQuestionTitle($question['T64InboundQuestionHistory']['question_title']) . $question_title. $enter .'(送達警告情報)';
					$data['headers'][] = $question_no . $this->getQuestionTitle($question['T64InboundQuestionHistory']['question_title']) . $question_title. $enter .'(短縮URLキー)';
				} else {
					$data['headers'][] = $question_no . $this->getQuestionTitle($question['T64InboundQuestionHistory']['question_title']) . $question_title;
					$data['sort_flags'][] = 5;
				}
			} elseif($question_type == QUESTION_INBOUND_SMS_INPUT){
				if($download_flag){
					$data['headers'][] = $question_no . $this->getQuestionTitle($question['T64InboundQuestionHistory']['question_title']) . $question_title . $enter . '先入力';
					$data['headers'][] = $question_no . $this->getQuestionTitle($question['T64InboundQuestionHistory']['question_title']) . $question_title . $enter . '先確認ボタン';
					$data['headers'][] = $question_no . $this->getQuestionTitle($question['T64InboundQuestionHistory']['question_title']) . $question_title . $enter . '(送達状態)';
					$data['headers'][] = $question_no . $this->getQuestionTitle($question['T64InboundQuestionHistory']['question_title']) . $question_title . $enter . '(送達警告情報)';
					$data['headers'][] = $question_no . $this->getQuestionTitle($question['T64InboundQuestionHistory']['question_title']) . $question_title . $enter . '(短縮URLキー)';
				}else{
					$data['headers'][] = $question_no . $this->getQuestionTitle($question['T64InboundQuestionHistory']['question_title']) . $question_title . '先入力';
					$data['headers'][] = $question_no . $this->getQuestionTitle($question['T64InboundQuestionHistory']['question_title']) . $question_title . '先確認ボタン';
					$data['headers'][] = $question_no . $this->getQuestionTitle($question['T64InboundQuestionHistory']['question_title']) . $question_title;
					$data['sort_flags'][] = 1;
					$data['sort_flags'][] = 1;
					$data['sort_flags'][] = 5;
				}
			} else {
				$data['headers'][] = $question_no . $question_title;
				$data['sort_flags'][] = 0;
			}
		}

		return $data;
	}

	/* Convert question type code to string
	 * @param $ques_type is question type code
	 * @return string of question type
	 */
	function get_question_type($ques_type) {
		$arr_ques_type = array(
			QUESTION_AUTH => '数値認証',
			QUESTION_BASIC => '質問',
			QUESTION_COUNT => 'カウント',
			QUESTION_END => '切断',
			QUESTION_RECORD => '録音',
			QUESTION_TEL => '番号入力',
			QUESTION_TRANS => '転送',
			QUESTION_VOICE => '再生',
			QUESTION_TIMEOUT => 'タイムアウト',
			QUESTION_AUTH_CHAR => '文字列認証',
			QUESTION_PROPERTY => '物件番号入力',
			QUESTION_FAX => '物件FAX送信',
			QUESTION_PROPERTY_SEARCH => '物件入力',
			QUESTION_INBOUND_SMS => '通知番号SMS送信',
			QUESTION_INBOUND_COLLATION => '着信番号照合',
			QUESTION_INBOUND_SMS_INPUT => '番号指定SMS送信',
		);

		return $arr_ques_type[$ques_type];
	}

	/* セクションのタイトルの入力の有無によって、結果のヘッダを変更する
	 * @param $question_input : $question['T64InboundQuestionHistory']['question_title']
	 * 入力あり…「セクションタイトル＋セクション名」
	 * 入力なし…「セクション名」
	 */
	private function getQuestionTitle($question_input){
		if (empty($question_input)){
			return "";
		} 
		return preg_replace('/ |　|"|,/', "",$question_input);
	}

	/* そのスケジュールの結果CSVがダウンロード可能かを判定する
	 * @param $data['schedule_ids']： T25Inbound.id
	 * @return string of result
	 * 		err_not_exist		:Javascript側でその旨を通知
	 * 		can_download		:ダウンロード可能（Javascript側で、action buffer_schedule_data を実行）
	 */
	function check_download_schedule() {
		$data = $this->data;
		if (empty($data)) {
			$this->redirect(array('controller' => 'InboundIncomingHistory', 'action' => 'index'));
		}

		$schedule_ids = $data['schedule_ids'];
		if (!is_array($schedule_ids)) {
			$schedule_ids = explode(' ', $schedule_ids);
		}
		foreach ($schedule_ids as $id) {
			$arr_schedule_info = $this->T25Inbound->getScheduleById($id);
			if (count($arr_schedule_info) < 1) {
				echo 'err_not_exist';
				exit;
			}

			if ($arr_schedule_info['T25Inbound']['status'] == STATUS_INBOUND_BUSY) {
				echo 'err_status_can_not_download';
				exit;
			}
		}

		echo 'can_download';
		exit;
	}

	/* そのスケジュールの結果をまとめ、セッションに保存する。
	 * @param $data['schedule_ids']： T25Inbound.id
	 * @param $action： ダウンロードする内容
	 * 		download_uncalled	:未着信DL
	 * 		download_all_log	:履歴DL
	 * 		上記以外				:有効DL
	 * @return string of result
	 * 		systemerror			:Javascript側でその旨を通知
	 * 		success				:ダウンロード可能（Javascript側で、action download_schedule を実行）
	 */
	function buffer_schedule_data($action) {
		$data = $this->data;
		if (empty($data)) {
			echo 'systemerror';
			exit;
		}

		$schedule_ids = $data['schedule_ids'];

		$download_multi = true;
		if (!is_array($schedule_ids)) {
			$schedule_ids = explode(' ', $schedule_ids);
			$download_multi = false;
		}

		$schedule_data = Array();
		// $schedule_data['schedule_data']=DLするCSVの内容。CSVファイル名にも使用する。
		// $schedule_data['action_name']=DLするCSVの内容。CSVファイル名にも使用する。
		if ($action == 'download_uncalled') {
			$schedule_data['schedule_data'] = $this->download_uncalled($schedule_ids);
			$schedule_data['action_name'] = '未着信';
		} elseif ($action == 'download_all_log') {
			$start_date = $data['start_date'];
			$end_date = $data['end_date'];
			$schedule_data['schedule_data'] = $this->download_log($schedule_ids, 'all_log' , $start_date, $end_date);
			$schedule_data['action_name'] = '履歴DL';
		} else {
			$start_date = $data['start_date'];
			$end_date = $data['end_date'];
			$schedule_data['schedule_data'] = $this->download_log($schedule_ids, 'ans_log' , $start_date, $end_date);
			$schedule_data['action_name'] = '有効DL';
		}

		$schedule_data['download_multi'] = $download_multi;
		$this->ESession->setScheduleDataDownload($schedule_data, $this);
		echo 'success';
		exit;
	}


	/* CSVダウンロード本体。SESSIONに積み込んだCSVの内容をダウンロードする。
	 * @param なし
	 * @return Zip file
	 */
	function download_schedule() {
		$schedule_data = $this->ESession->getScheduleDataDownload($this);
		if (!isset($schedule_data)) {
			$this->redirect(array('controller' => 'InboundIncomingHistory', 'action' => 'index'));
		}
		// download_multi == true は、着信設定一覧画面で複数の着信設定を選択したとき。
		if ($schedule_data['download_multi']) {
			$file_out_name = date('YmdHis', time()) . '_' . $schedule_data['action_name'] . '.zip';
			$file_out_name = mb_convert_encoding($file_out_name, "SJIS-win", "UTF-8");
			$this->Csv->createZip($file_out_name);
		}
		// $data＝ある着信設定の結果
		foreach ($schedule_data['schedule_data'] as $schedule_id => $data) {

			// その着信設定があるかを確認
			$schedule = $this->T25Inbound->getScheduleById($schedule_id);
			if (!empty($schedule)) {
				// csvファイル名作成のため、検索する
				$schedule_info = $this->T25Inbound->getHistoryInfoById($schedule_id);
				// 実行中はnow
				$time_end = isset($schedule_info['T25Inbound']['time_end']) ? date('Ymd', strtotime($schedule_info['T25Inbound']['time_end'])) : 'now';

				foreach ($data as $row) {
					$this->Csv->addRow($row);
				}

				// csvファイル名の生成
				// <生成日時>_<アクション>_<実行日時（T25Inbound.time_start）>_<終了日時（T25Inbound.time_end）>
				// 20170215121200_有効DL_05031016200_20170201_20170208.csv
				// 20170215121200_有効DL_05031016200_20170208_now.csv
				$systemTitle = date('YmdHis', time()) . '_' . $schedule_data['action_name'] . '_' . $schedule_info['T25Inbound']['external_number']
					. '_' . date('Ymd', strtotime($schedule_info['T25Inbound']['time_start'])) . '_' . $time_end . '.csv';
				$title = mb_convert_encoding($systemTitle, "SJIS-win", "UTF-8");

				// csv一つならば、そのままダウンロード、複数ならZipでダウンロード
				if ($schedule_data['download_multi']) {
					$this->Csv->addToZip($title, 'SJIS-win');
					$this->Csv->clear();
				} else {
					echo $this->Csv->render($title,'SJIS-win');
					$this->Session->delete('schedule_data_download');
					exit;
				}
			}
		}
		echo $this->Csv->renderZip('SJIS-win');
		$this->Session->delete('schedule_data_download');
		exit;
	}


	/* 未着信のデータを集める。
	 * @param array $schedule_ids： T25Inbound.idのリスト
	 * @return array $schedule_data： csv出力する内容のリスト
	 *		$schedule_data[$schedule_id][0] = ヘッダ行
	 *		$schedule_data[$schedule_id][1] = データ
	 * Memo
	 * 	t81(着信結果)の無いt13(着信リスト)のレコードを集め、csvに出力する。
	 */
	function download_uncalled($schedule_ids) {

		$schedule_data = Array();
		foreach ($schedule_ids as $schedule_id) {
			// その着信設定があるかを確認
			$schedule = $this->T25Inbound->getScheduleById($schedule_id);
			if (!empty($schedule)) {
				// csvファイル名作成のため、検索する
				$schedule_info = $this->T25Inbound->getHistoryInfoById($schedule_id);
				//get format csv from t13
				$list_id = $schedule_info["T56InboundListHistory"]["list_id"];
				// 着信リストのIDより、着信リストのカラムを取得
				$list_items = $this->T13InboundListItem->getTitleByListId($list_id);

				//add header for csv file
				$header_arr = array();
				$list_columns = array();

				// ヘッダー部分の作成
				foreach ($list_items as $list_item) {
					// 値を格納するカラム名(T57でのカラム名)
					$list_columns[] = $list_item['T13InboundListItem']['column'];
					$header_arr[] = $list_item['T13InboundListItem']['item_name'];
					if ($list_item['T13InboundListItem']['item_code'] == 'tel_no') {
						$tel_column = $list_item['T13InboundListItem']['column'];
					}
				}
				// $this->Csv->addRow($header_arr);
				$schedule_data[$schedule_id][] = $header_arr;
				//get data from db to create csv file
				// データ部分の部分の作成
				$tel_no_not_calls = $this->T57InboundTelHistory->getTelNotCalls($schedule_id, $tel_column);
				if (sizeof($tel_no_not_calls) > 0) {
					// $tel_no = T57のレコード1行
					foreach ($tel_no_not_calls as $tel_no) {
						$r = array();
						// ヘッダ行に合わせて、その値を取得
						foreach ($list_columns as $column) {
							array_push($r, $tel_no['T57InboundTelHistory'][$column]);
						}
						// $this->Csv->addRow($r);
						$schedule_data[$schedule_id][] = $r;
					}
				} else {
					// $this->Csv->addRow(array());
					$schedule_data[$schedule_id][] = Array();
				}
			}
		}

		return $schedule_data;
	}

	/* 着信のログのデータ集める。
	 * @param array 	$schedule_ids： T25Inbound.idのリスト
	 * @param string 	$download_type 何をダウンロードするか
	 * 								all_log：履歴DL
	 * 								ans_log：有効DL
	 * @return array 	$schedule_data： csv出力する内容のリスト
	 *		$schedule_data[$schedule_id][0] = ヘッダ行
	 *		$schedule_data[$schedule_id][1] = データ
	 *
	 * Memo
	 * 	t81(着信結果)のレコードを集め、csvに出力する。
	 */
	function download_log($schedule_ids, $download_type , $start_date = null , $end_date = null ) {
		$schedule_data = Array();
		$question_types = array(
			QUESTION_BASIC,
			QUESTION_AUTH,
			QUESTION_TEL,
			QUESTION_TRANS,
			QUESTION_RECORD,
			QUESTION_COUNT,
			QUESTION_AUTH_CHAR,
			QUESTION_PROPERTY,
			QUESTION_FAX,
			QUESTION_PROPERTY_SEARCH,
			QUESTION_INBOUND_SMS,
			QUESTION_INBOUND_COLLATION,
			QUESTION_INBOUND_SMS_INPUT,
		);
		$smsStatusTitle = array(
            INBOUND_SMS_STATUS_SUCCESS => '着信済み',
            INBOUND_SMS_STATUS_OUTSIDE => '圏外',
            INBOUND_SMS_STATUS_UNKNOWN => '不明',
            INBOUND_SMS_STATUS_SENDING => '送信中',
            INBOUND_SMS_STATUS_ERROR => 'エラー',
            INBOUND_SMS_STATUS_NO_SEND => '',
        );
		$header_logs = array(
			'call_datetime' => '着信日時',
			'tel_no' => '電話番号',
		);
		$header_status = array(
			'connect_datetime' => '接続日時',
			'cut_datetime' => '切断日時',
			'count_second_connect' => '接続秒数',
			'status' => 'ステータス',
		);
		$arr_operator = array('<', '=', '>', '≠');
		$listitem_count = $this->M90PulldownCode->getCountSelectOptionByTypeCode("list_item");

		foreach ($schedule_ids as $schedule_id) {
			// その着信設定があるかを確認
			$schedule = $this->T25Inbound->getScheduleById($schedule_id);
			if (!empty($schedule)) {
				// 着信リストIDを、検索する
				$schedule_info = $this->T25Inbound->getHistoryInfoById($schedule_id);
				$list_id = isset($schedule_info['T25Inbound']['list_id']) && !empty($schedule_info['T25Inbound']['list_id']) ? $schedule_info['T25Inbound']['list_id'] : NULL;
				$id = $schedule_info['T25Inbound']['id'];
				$arr_answer_pos = $this->get_answer_pos($schedule_id);

				$questions = array();
				$answer_pos_auth_character = NULL;

				//テンプレートの全タイプを保持
				$download_log_tmp_question_all_type = $this->T64InboundQuestionHistory->getQuesNumByScheduleId($id, $question_types);
				foreach ($download_log_tmp_question_all_type as $download_log_tmp) {
					$download_log_question_all_type[] = $download_log_tmp['T64InboundQuestionHistory']['question_type'];
				}

				//着信リストを取得
				$download_log_list_id = isset($schedule_info['T25Inbound']['list_id']) && !empty($schedule_info['T25Inbound']['list_id']) ? $schedule_info['T25Inbound']['list_id'] : NULL;
				if (!empty($download_log_list_id)) {//着信リストが登録されている場合のみ着信リストデータを取得
					$download_log_Incomingcolumn = $this->T13InboundListItem->getTelNumColumn($download_log_list_id);
					if (!empty($download_log_Incomingcolumn)) {
						$download_log_IncomingList = $this->T57InboundTelHistory->getDataItemMainByIdAndItemMain($id, $download_log_Incomingcolumn['T13InboundListItem']['column']);
					}
				}

				$question_temps = $this->T64InboundQuestionHistory->getInfoQuesAnswByScheduleId($schedule_id, $question_types);
				foreach ($question_temps as $ques) {
					$ques_no = $ques['T64InboundQuestionHistory']['question_no'];
					$questions[$ques_no]['T64InboundQuestionHistory'] = $ques['T64InboundQuestionHistory'];
					$questions[$ques_no]['T65InboundButtonHistory'][$ques['T65InboundButtonHistory']['answer_no']] = $ques['T65InboundButtonHistory'];
					if ($ques['T64InboundQuestionHistory']['auth_match_flag'] == 1) {
						$auth_item = $ques['T64InboundQuestionHistory']['auth_item'];
						$answer_pos_auth_character = $arr_answer_pos[$ques_no];
					}
				}

				$data_headers = $this->get_data_header_schedule($schedule_id, $question_types, false, true);
				$get_list_tel_flag = $data_headers['get_list_tel_flag'];
				$header_ques = $data_headers['headers'];

				//add header for csv file
				$header_lists = array();
				$arr_list_items = Array();
				$arr_auth_column = array();
				$item_main_column = NULL;
				$join_col = NULL;

				// 着信リストに対応する部分を作成
				if ($list_id) {
					$inbound_list = $this->T56InboundListHistory->getItemMainByInboundId($schedule_id);
					$item_main_name = $inbound_list['T56InboundListHistory']['item_main'];

					$list_items = $this->T13InboundListItem->getTitleByListId($list_id);
					foreach ($list_items as $list_item) {
						if ($list_item['T13InboundListItem']['item_code'] != 'tel_no') {
							$header_lists[$list_item['T13InboundListItem']['column']] = $list_item['T13InboundListItem']['item_name'];
						}

						if ($list_item['T13InboundListItem']['item_name'] == $item_main_name) {
							$item_main_column = $list_item['T13InboundListItem']['column'];
						}

						$arr_list_items[$list_item['T13InboundListItem']['item_name']] = array(
							'item_code' => $list_item['T13InboundListItem']['item_code'],
							'column' => $list_item['T13InboundListItem']['column']
						);
					}

					if ($answer_pos_auth_character) {
						$join_col = 'answer' . $answer_pos_auth_character;
					} elseif ($arr_list_items[$item_main_name]['item_code'] == 'tel_no') {
						$join_col = 'tel_no';
					}

					if ($get_list_tel_flag) {
						foreach ($questions as $question) {
							if (($question['T64InboundQuestionHistory']['question_type'] == QUESTION_AUTH) || ($question['T64InboundQuestionHistory']['question_type'] == QUESTION_AUTH_CHAR)) {
								$arr_auth_column[$question['T64InboundQuestionHistory']['question_no']] = $arr_list_items[$question['T64InboundQuestionHistory']['auth_item']];
							}
						}
					}

					$num_header_loss = $listitem_count - count($list_items);
					for ($i = 1; $i <= ($num_header_loss); $i++) {
						array_push($header_lists, "備考" . $i);
					}
				}

				$header_csv_files = array_merge(
					$header_logs,
					$header_lists,
					$header_status,
					$header_ques
				);

				//add header for csv file
				$header_arr = array();
				foreach ($header_csv_files as $header_csv_file) {
					$header_arr[] = $header_csv_file;
				}
				$schedule_data[$schedule_id][] = $header_arr;
				//着信番号照合のみ（文字列認証なし）の場合は電話番号のカラムをセットする。
				if(!in_array(QUESTION_AUTH_CHAR,$download_log_question_all_type) && in_array(QUESTION_INBOUND_COLLATION,$download_log_question_all_type)){
					$tmp_item_main_column = $this->T13InboundListItem->getTelNumColumn($list_id);
					$item_main_column = $tmp_item_main_column['T13InboundListItem']['column'];
				}
				//get data from db to create csv file
				//download all_log
				if ((in_array(QUESTION_AUTH_CHAR,$download_log_question_all_type) && in_array(QUESTION_INBOUND_COLLATION,$download_log_question_all_type))
							|| in_array(QUESTION_INBOUND_COLLATION,$download_log_question_all_type)){
					$join_col = 'memo';
					$logs = $this->T81IncomingResult->getallbyscheduleid_inboundcollation($schedule_id, $item_main_column, $join_col , null , $start_date , $end_date);
				} else{
					$logs = $this->T81IncomingResult->getAllByScheduleId($schedule_id, $item_main_column, $join_col , null , $start_date , $end_date);
				}


				// 20171003 Update by Hungnv
				$sms_logs = $this->T86InboundSmsStatus->getSmsLogByInboundId($schedule_id);
				$sms_logs = $this->_organizeSmsData($sms_logs);
				// 有効DLの場合は、間引く
				if ($download_type == 'ans_log') {
					$logs = $this->get_yuko_logs($schedule_id, $logs, $arr_answer_pos, $arr_list_items, $item_main_column);
				}

				if (sizeof($logs) > 0) {
					// $log == t81の1レコード
					foreach ($logs as $log) {
						$r = array();
						if ($log['T81IncomingResult']['status'] != "recover") {
							foreach ($header_logs as $key => $header_log) {
								if (($key == 'tel_no') && empty($log['T81IncomingResult'][$key])) {
									$r[] = 'anonymous';
									$download_log_tel_num = 'anonymous';
								} else {
									$r[] = $log['T81IncomingResult'][$key];
									$download_log_tel_num = $log['T81IncomingResult'][$key];
								}
							}

							foreach ($header_lists as $key => $header_list) {
								if (isset($log['T57InboundTelHistory'][$key])) {
									$r[] = $log['T57InboundTelHistory'][$key];
								} else {
									$r[] = '';
								}
							}

							$r[] = $log['T81IncomingResult']['connect_datetime'] == '0000-00-00 00:00:00' ? '' : $log['T81IncomingResult']['connect_datetime'];
							$r[] = $log['T81IncomingResult']['cut_datetime'] == '0000-00-00 00:00:00' ? '' : $log['T81IncomingResult']['cut_datetime'];
							$r[] = strtotime($log['T81IncomingResult']['cut_datetime']) - strtotime($log['T81IncomingResult']['connect_datetime']);

							if (in_array($log['T81IncomingResult']['status'], $this->Util->getCallResultNoConvertArray())) {
								$r[] = strtoupper($log['T81IncomingResult']['status']);
							} else if(in_array($log['T81IncomingResult']['status'] , $this->Util->getCallResultConvertTFRejectArray())){
								$r[] = 'TRANSFERREJECT';
							} else {
								$r[] = 'ANSWER';
							}

							foreach ($questions as $question) {
								$question_no = $question['T64InboundQuestionHistory']['question_no'];
								$answer_pos = $arr_answer_pos[$question_no];
								$question_type = $question['T64InboundQuestionHistory']['question_type'];
								if($question_type == QUESTION_INBOUND_SMS){
									$idx = $log['T81IncomingResult']['id'] . "_" .$schedule_id . "_" . $question['T64InboundQuestionHistory']['question_no'];
                                    $smsData = $sms_logs[$idx];
                                	if(empty($smsData)){
                                		$r[] = $smsStatusTitle[INBOUND_SMS_STATUS_NO_SEND];
                                		$r[] = "";
                                		$r[] = "";
                                	}else{
                                		$r[] = $smsStatusTitle[$smsData['T86InboundSmsStatus']['sms_status']];
                                    	$r[] = $smsData['T86InboundSmsStatus']['message'];
                                    	$r[] = $smsData['T86InboundSmsStatus']['sms_short_url_key'];
                                	}
                                    continue;
								}
								if($question_type == QUESTION_INBOUND_SMS_INPUT){
									$idx = $log['T81IncomingResult']['id'] . "_" .$schedule_id . "_" . $question['T64InboundQuestionHistory']['question_no'];
                                    $smsData = $sms_logs[$idx];
                                	if(empty($smsData)){
										$r[] = "";
										$r[] = "";
                                		$r[] = $smsStatusTitle[INBOUND_SMS_STATUS_NO_SEND];
										$r[] = "";
										$r[] = "";
                                	}else{
										$r[] = $log['T81IncomingResult']['answer' . ($answer_pos)];
										$r[] = $log['T81IncomingResult']['answer' . ($answer_pos + 1)];
                                		$r[] = $smsStatusTitle[$smsData['T86InboundSmsStatus']['sms_status']];
                                    	$r[] = $smsData['T86InboundSmsStatus']['message'];
                                    	$r[] = $smsData['T86InboundSmsStatus']['sms_short_url_key'];
                                	}
                                    continue;
								}
								if(isset($question_type) && $question_type == QUESTION_FAX){
									$value = $log['T81IncomingResult']['answer' . ($answer_pos + 1)];
								}else
									$value = isset($answer_pos) && ($question['T64InboundQuestionHistory']['question_type'] != QUESTION_TRANS || $question['T64InboundQuestionHistory']['question_type'] != QUESTION_INBOUND_COLLATION) ? $log['T81IncomingResult']['answer' . $answer_pos] : '';

								// 共通部分（先頭カラム）
								//着信照合は照合結果を編集して表示する
								if($question['T64InboundQuestionHistory']['question_type'] != QUESTION_INBOUND_COLLATION){
									$r[] = $value;
								}
								if ($question['T64InboundQuestionHistory']['question_type'] == QUESTION_BASIC) {
									if ($value == '*') {
										$value = 51;
									} elseif ($value == '#') {
										$value = 52;
									}
									if (isset($question['T65InboundButtonHistory'][$value]) && !empty($question['T65InboundButtonHistory'][$value]['answer_content'])) {
										$r[sizeof($r) - 1] = $question['T65InboundButtonHistory'][$value]['answer_content'];
									}
								} elseif ($question['T64InboundQuestionHistory']['question_type'] == QUESTION_AUTH) {
									$auth_column = $arr_auth_column[$question_no]['column'];
									$auth_value = $log['T57InboundTelHistory'][$auth_column];
									if (isset($auth_value) && $auth_value !== '' && isset($value) && $value !== '') {
										$auth_item_code = $arr_auth_column[$question_no]['item_code'];
										if ($auth_item_code == 'birthday') {
											$auth_value = DateTime::createFromFormat('Y年m月d日', $auth_value)->format('Ymd');
										} else {
											$auth_value = preg_replace('/[^\d]/', '', $auth_value);
										}

										if ($value < $auth_value) {
											$r[] = $arr_operator[0];
										} elseif ($value == $auth_value) {
											$r[] = $arr_operator[1];
										} else {
											$r[] = $arr_operator[2];
										}
									} else {
										$r[] = '';
									}

									if ($question['T64InboundQuestionHistory']['recheck_flag'] == 1) {
										$pos_input = -1;
										for ($k=0; $k<3; $k++) {
											if ($log['T81IncomingResult']['answer' . ($answer_pos + $k + 1)] != '' && $pos_input < 0) {
												$pos_input = $k;
											}
											if ($log['T81IncomingResult']['answer' . ($answer_pos + $k + 1)] == $question['T64InboundQuestionHistory']['recheck_button_next']) {
												$pos_input = $k;
												break;
											}
										}
										if ($pos_input >= 0) {
											$r[] = $log['T81IncomingResult']['answer' . ($answer_pos + $pos_input + 1)];
										} else {
											$r[] = '';
										}
									}
								} elseif ($question['T64InboundQuestionHistory']['question_type'] == QUESTION_AUTH_CHAR) {

									$auth_column = $arr_auth_column[$question_no]['column'];
									$auth_value = $log['T57InboundTelHistory'][$auth_column];
									if (isset($auth_value) && $auth_value !== '' && isset($value) && $value !== '') {
										$auth_item_code = $arr_auth_column[$question_no]['item_code'];
										if ($auth_item_code == 'birthday') {
											$auth_value = DateTime::createFromFormat('Y年m月d日', $auth_value)->format('Ymd');
										} else {
											$auth_value = preg_replace('/[^\d]/', '', $auth_value);
										}

										if ($value === $auth_value) {
											$r[] = $arr_operator[1];
										} else {
											//着信リスト照合なしの不一致
											$r[] = $arr_operator[3];
										}
									}elseif (isset($value) && $value !== ''){
										//着信リスト照合ありの不一致
										$r[] = $arr_operator[3];
									} else {
										$r[] = '';
									}

									if ($question['T64InboundQuestionHistory']['recheck_flag'] == 1) {

										if (($log['T81IncomingResult']['answer' . ($answer_pos_auth_character + 1)] == $question['T64InboundQuestionHistory']['recheck_button_next'])
											|| ($log['T81IncomingResult']['answer' . ($answer_pos_auth_character + 2)] == $question['T64InboundQuestionHistory']['recheck_button_next'])) {
											$auth_input = $question['T64InboundQuestionHistory']['recheck_button_next'];
										} elseif (!empty($log['T81IncomingResult']['answer' . ($answer_pos_auth_character + 1)])) {
											$auth_input = $log['T81IncomingResult']['answer' . ($answer_pos_auth_character + 1)];
										} elseif (!empty($log['T81IncomingResult']['answer' . ($answer_pos_auth_character + 2)])) {
											$auth_input = $log['T81IncomingResult']['answer' . ($answer_pos_auth_character + 2)];
										} else {
											$auth_input = '';
										}
										$r[] = $auth_input;
									}
								} elseif ($question['T64InboundQuestionHistory']['question_type'] == QUESTION_RECORD) {
									if (!empty($log['T81IncomingResult']['valid_count'])) {
										$r[sizeof($r) - 1] = 1;
										$r[] = $log['T81IncomingResult']['valid_count'];
									} else {
										$r[sizeof($r) - 1] = '';
										$r[] = '';
									}
								} elseif ($question['T64InboundQuestionHistory']['question_type'] == QUESTION_TRANS) {
									$count_second_tranfer = strtotime($log['T81IncomingResult']['trans_cut_datetime']) - strtotime($log['T81IncomingResult']['trans_connect_datetime']);
									$r[sizeof($r) - 1] = $count_second_tranfer > 0 ? $count_second_tranfer : '';
								} elseif ($question['T64InboundQuestionHistory']['question_type'] == QUESTION_TEL && $question['T64InboundQuestionHistory']['recheck_flag'] == 1) {
									$r[] = $log['T81IncomingResult']['answer' . ($answer_pos + 1)];
								} elseif ($question_type == QUESTION_FAX) {
									$bukken_fax = $this->T82BukkenFaxStatus->getFaxStatus($log['T81IncomingResult']['id'], $question_no);
									$fax_status = !empty($bukken_fax['T82BukkenFaxStatus']['fax_status'])?$bukken_fax['T82BukkenFaxStatus']['fax_status']:'';
									// FAX入力　繰返し確認番号
									$r[] = $log['T81IncomingResult']['answer' . ($answer_pos + 3)];
									// FAX　ステータス
									$r[] = $fax_status;
								} elseif ($question_type == QUESTION_PROPERTY) {
									// 物件番号入力　繰返し確認番号
									$r[] = $log['T81IncomingResult']['answer' . ($answer_pos + 2)];
									// 物件番号入力　図面希望番号
									$r[] = $log['T81IncomingResult']['answer' . ($answer_pos + 4)];
									// 物件番号入力　継続入力番号
									$r[] = $log['T81IncomingResult']['answer' . ($answer_pos + 6)];
								} elseif ($question_type == QUESTION_PROPERTY_SEARCH) {
									// 賃料(質問：賃料音声（q _ul.pcm）の戻り値)は、共通部分（先頭カラム）で行う
									// 平米数(質問：平米音声（q bukken_square.pcm）の戻り値)
									$r[] = $log['T81IncomingResult']['answer' . ($answer_pos + 2)];
									// 物件選択(OBJECT：選択物件確定（物件名出力）（object rental2.confirm）の戻り値)
									$r[] = $log['T81IncomingResult']['answer' . ($answer_pos + 10)];
									// 空きの有無(OBJECT：物件空き判断（object rental2.decide）の戻り値)
									// 回答内容を変換する(rental2.Decideの戻り値が1ならば「有」、それ以外なら「無」)
									// 回答なしは空欄のままにする
									if($log['T81IncomingResult']['answer' . ($answer_pos + 11)] != ""){
										$massage = $log['T81IncomingResult']['answer' . ($answer_pos + 11)]  == 1 ? "有" : "無";
									}
									else{
										$massage = $log['T81IncomingResult']['answer' . ($answer_pos + 11)] ;
									}
									$r[] = $massage;
									// 質問：継続音声（q bukken_cont.pcm）の戻り値)
									$r[] = $log['T81IncomingResult']['answer' . ($answer_pos + 12)];
								}elseif ($question_type == QUESTION_INBOUND_COLLATION) {	//着信照合の結果出力
									//着信照合（True）、文字列認証（リスト照合あり）にてTrueの場合、着信リストの行が入れ替わった場合の対応
									//※着信照合通過できていない場合は失敗（≠）を表示
									//最終的に保持している行で照合結果を表示する。
									if (in_array(QUESTION_AUTH_CHAR,$download_log_question_all_type) && in_array($download_log_tel_num,$download_log_IncomingList)){
										$download_log_auth_item = explode(':',$log['T81IncomingResult']['memo']);//着信照合の認証結果判断
										$download_log_auth_result = $this->T57InboundTelHistory->getByMatchitem($schedule_id, $item_main_column, $download_log_auth_item[0]);
										if ($download_log_auth_result >= 1 && isset($value) && $value !== ''){
											$download_log_auth_operator = $arr_operator[1];
										} elseif ($download_log_auth_result == 0 && isset($value) && $value !== ''){
											$download_log_auth_operator = $arr_operator[3];
										} else {
											$download_log_auth_operator = '';
										}
									}else{
										if (in_array($download_log_tel_num,$download_log_IncomingList)){
											$download_log_auth_operator = $arr_operator[1];
										}else {
											$download_log_auth_operator = $arr_operator[3];
										}
									}
									$r[] = $download_log_auth_operator;

								}
							}

							$schedule_data[$schedule_id][] = $r;
						}
					}
				}
			}
		}

		return $schedule_data;
	}

	function download_record($schedule_id, $tel_no, $prefix) {
		$schedule_no = substr("000000", strlen($schedule_id)) . $schedule_id;
		$path_base = $this->M99SystemParameter->getByFunctionIdAndParameterId('INBOUND', 'PATH_QUESTION_RECORD');
		$path_base = $path_base['M99SystemParameter']['parameter_value'];
		$file_path = $path_base.$schedule_no."/rec/".$tel_no."_".$prefix."_1.wav";
		if (file_exists($file_path)) {
			$fp = fopen($file_path, "rb");
			$this->layout = "ajax";
			header('Content-Description: File Transfer');
			header('Content-Type: application/octet-stream');
			header('Content-Disposition: attachment; filename='.$tel_no.'.wav; charset=SJIS-win');
			header('Content-Transfer-Encoding: binary');
			header('Expires: 0');
			header('Cache-Control: must-revalidate');
			header('Pragma: public');
			header('Content-Length: ' . filesize($file_path));
			echo file_get_contents($file_path);
		}
		exit;
	}

	function get_yuko_logs($schedule_id, $logs, $arr_answer_pos, $arr_list_items, $item_main_column) {
		$results = array();
		$yuko_ques_temp = $this->T64InboundQuestionHistory->getInfoQuesAnswYukoByScheduleId($schedule_id);
		if (sizeof($yuko_ques_temp) == 0) {
			return $results;
		}

		$yuko_ques_arr = array();
		$arr_auth_column = array();
		foreach ($yuko_ques_temp as $ques) {
			$ques_no = $ques['T64InboundQuestionHistory']['question_no'];
			$yuko_ques_arr[$ques_no]['T64InboundQuestionHistory'] = $ques['T64InboundQuestionHistory'];
			$yuko_ques_arr[$ques_no]['T65InboundButtonHistory'][] = $ques['T65InboundButtonHistory'];

			if ($ques['T64InboundQuestionHistory']['question_type'] == QUESTION_AUTH) {
				$arr_auth_column[$ques_no] = $arr_list_items[$ques['T64InboundQuestionHistory']['auth_item']];
			}
		}

		if (!empty($logs)) {
			foreach ($logs as $log) {
				if ($log['T81IncomingResult']['status'] != "recover") {
					$yuko_flag = true;
					foreach ($yuko_ques_arr as $question) {
						$yuko_ques_flag = false;

						$question_no = $question['T64InboundQuestionHistory']['question_no'];
						$answer_pos = $arr_answer_pos[$question_no];
						$value = isset($answer_pos) ? $log['T81IncomingResult']['answer' . $answer_pos] : '';

						if ($question['T64InboundQuestionHistory']['question_type'] == QUESTION_AUTH) {
							$auth_column = $arr_auth_column[$question_no]['column'];
							$auth_value = $log['T57InboundTelHistory'][$auth_column];
							if (isset($auth_value) && $auth_value !== '' && isset($value) && $value !== '') {
								$auth_item_code = $arr_auth_column[$question_no]['item_code'];
								if ($auth_item_code == 'birthday') {
									$auth_value = DateTime::createFromFormat('Y年m月d日', $auth_value)->format('Ymd');
								} else {
									$auth_value = preg_replace('/[^\d]/', '', $auth_value);
								}

								foreach ($question['T65InboundButtonHistory'] as $button) {
									$yuko_ans = $button['answer_no'];
									if (($yuko_ans == 1 && ($value < $auth_value))
										|| ($yuko_ans == 2 && ($value == $auth_value))
										|| ($yuko_ans == 3 && ($value > $auth_value))
									) {
										$yuko_ques_flag = true;
										break;
									}
								}
							} else {
								$yuko_flag = false;
								break;
							}
						} elseif ($question['T64InboundQuestionHistory']['question_type'] == QUESTION_AUTH_CHAR) {

							if (isset($item_main_column) && isset($log['T57InboundTelHistory'][$item_main_column])) {

								foreach ($question['T65InboundButtonHistory'] as $button) {
									$yuko_ans = $button['answer_no'];
									if (($yuko_ans == 1) || ($yuko_ans == 2)) {
										$yuko_ques_flag = true;
										break;
									}
								}
							} else {
								$yuko_flag = false;
								break;
							}
						} elseif ($question['T64InboundQuestionHistory']['question_type'] == QUESTION_BASIC) {
							if ($value == '*') {
								$value = 51;
							} elseif ($value == '#') {
								$value = 52;
							}
							foreach ($question['T65InboundButtonHistory'] as $button) {
								$yuko_ans = $button['answer_no'];
								if ($value == $yuko_ans) {
									$yuko_ques_flag = true;
									break;
								}
							}
						}

						if (!$yuko_ques_flag) {
							$yuko_flag = false;
							break;
						}
					}

					if ($yuko_flag) {
						$results[] = $log;
					}
				}
			}
		}

		return $results;
	}

	/* Reorganize sms data from log
	* @param $arrSmsData data is selected by schedule id from T86InboundSmsStatus
	* @return array
	*/
	function _organizeSmsData($arrSmsData){
		$rs = array();
		if(empty($arrSmsData))
			return $rs;
		foreach ($arrSmsData as $data) {
			//Create unique key for sms log record
			$idx = $data['T86InboundSmsStatus']['log_id'] . "_" .$data['T86InboundSmsStatus']['inbound_id'] . "_" . $data['T86InboundSmsStatus']['sms_question_no'];
			$rs[$idx] = $data;
		}
		return $rs;
	}
	/*
	* smsステータス取得
	*/
    private function _getSmsStatusData($inboundId, $templateId)
    {
        $smsStatusTitle = array(
            INBOUND_SMS_STATUS_SUCCESS => '着信済み',
            INBOUND_SMS_STATUS_OUTSIDE => '圏外',
            INBOUND_SMS_STATUS_UNKNOWN => '不明',
            INBOUND_SMS_STATUS_SENDING => '送信中',
            INBOUND_SMS_STATUS_ERROR => 'エラー',
            INBOUND_SMS_STATUS_NO_SEND => '',
        );
        $smsStatusCount = array();
        $result = array();
        $telTmp = array(); // 送信件数
        $smsStatus = $this->T86InboundSmsStatus->getSmsByScheduleId($inboundId, $templateId);

        foreach ($smsStatus as $sms) {
            $t86 = $sms['T86InboundSmsStatus'];
            if($t86['sms_status'] == INBOUND_SMS_STATUS_NO_SEND){
                continue;
            }
            $t31 = $sms['T61'];
            $telTmp[$t86['sms_question_no']] += 1;
            if (!isset($result[$t86['sms_question_no']])) {
                $result[$t86['sms_question_no']]['sms_content'] = $t31['sms_content'];
            }
            if ($t86['sms_status'] == INBOUND_SMS_STATUS_SUCCESS) {
                $smsStatusCount[$t86['sms_question_no']][INBOUND_SMS_STATUS_SUCCESS] += 1;
            } else if ($t86['sms_status'] == INBOUND_SMS_STATUS_OUTSIDE) {
                $smsStatusCount[$t86['sms_question_no']][INBOUND_SMS_STATUS_OUTSIDE] += 1;
            } else if ($t86['sms_status'] == INBOUND_SMS_STATUS_UNKNOWN) {
                $smsStatusCount[$t86['sms_question_no']][INBOUND_SMS_STATUS_UNKNOWN] += 1;
            } else if ($t86['sms_status'] == INBOUND_SMS_STATUS_ERROR) {
                $smsStatusCount[$t86['sms_question_no']][INBOUND_SMS_STATUS_ERROR] += 1;
            }
        }

        foreach ($result as $questionNo => $question) {
            $success = $outside = $unknown = $error = 0;
            $result[$questionNo]['total_tel_send'] = $telTmp[$questionNo];
            $result[$questionNo]['send_complete'] = $smsStatusCount[$questionNo][INBOUND_SMS_STATUS_SUCCESS];
        }

        return $result;
    }
    //20161129 Update by Linh : process and get SMS data - END



	// 20160413 Add by Giang - #6906 Inbound history screen - End

	function batch_create_inbound($server_id, $inbound_id, $status, $external_number, $template_id, $list_ng_id, $list_id, $inbound_prev_id, $inbound_prev_status, $external_prefix, $enosip_port) {
		$company_id = $this->ESession->getUserCompanyId($this);
		$result = "success";
		$info_server = $this->M01Server->getInfoServerByServerId($server_id);
		$local_path = $info_server["M01Server"]["local_path"];
		if($status == STATUS_INBOUND_MESSAGE){
			//1-フォルダ作成・転送
			$cmd = "/usr/local/bin/ruby ".$local_path."create_send_folder.rb '".$company_id."' '".$server_id."' '".$inbound_id."' '".$external_number."' '".$template_id."' '".$list_ng_id."' '".$list_id."' '".$enosip_port."' '".$external_prefix."'";
			exec($cmd, $shell_result, $shell_result_status);
			if($shell_result_status != 0){
				$result = $shell_result[0];
				$this->log($cmd);
				$this->log($shell_result);
				$this->log($shell_result_status);
				$this->log("BATCHでフォルダ作成・転送：失敗");
			}
		}
		//2-設定
		if($result == "success"){
			$cmd = "/usr/local/bin/ruby ".$local_path."inbound_setup.rb '".$server_id."' '".$inbound_id."' '".$inbound_prev_id."' '".$external_prefix."' '".$status."' '".$inbound_prev_status."'";
			exec($cmd, $shell_result, $shell_result_status);
			if($shell_result_status != 0){
				$result = $shell_result[0];
				$this->log($cmd);
				$this->log($shell_result);
				$this->log($shell_result_status);
				$this->log("BATCHでフォルダ作成：失敗");
			}
		}
		return $result;
	}
}
