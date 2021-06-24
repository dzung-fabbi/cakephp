<?php
App::uses('AppController', 'Controller');

class ManageMenuController extends AppController {
	var $uses = Array(
		'M03Auth',
		'M91MenuManageItem'
	);

	function beforeFilter() {
		parent::beforeFilter();

		$company_id = $this->ESession->getUserCompanyId($this);
		$gs_company = $this->M99SystemParameter->getByFunctionIdAndParameterId('COMPANY', 'GS_COMPANY_ID');
		$gs_company_id = $gs_company['M99SystemParameter']['parameter_value'];

		if ($company_id != $gs_company_id) {
			$this->redirect(array('controller' => ''));
		}
	}

	function index($mode = null) {
		$enable_edit = $this->M04ControllerAction->check_permission($this->post_code, 'ManageMenu', 'edit');
		$menu_manage_items = $this->M91MenuManageItem->getAll();

		$this->set('mode', $mode);
		$this->set('enable_edit', $enable_edit);
		$this->set('menu_manage_items', $menu_manage_items);
		$this->set("mode", $mode);
	}

	function hide_menu_list($js_page, $limit, $column) {
		$this->layout = 'ajax';
		$filter = $_GET["filter"];
		$page = $js_page + 1;
		$json_data = Array();

		$enable_edit = $this->M04ControllerAction->check_permission($this->post_code, 'ManageMenu', 'edit');
		$headers = Array('No', 'アカウント', '企業名');
		$json_data["rows"] = Array();

		if(isset($column) && !empty($column) && $column != "column"){
			$sort_order = $this->Util->getManageMenuSortOrder($column);
		}
		$tmp_company_hide_menus = $this->M02Company->getAllCompanyHideMenuInfo(isset($sort_order[0]) ? $sort_order[0] : null, $filter);
		$json_data["total_rows"] = $this->M02Company->getCompanyCount($filter);
		$menu_manage_items = $this->M91MenuManageItem->getAll();
		foreach ($menu_manage_items as $menu_manage_item) {
			$headers[] = $menu_manage_item['M91MenuManageItem']['menu_item_name'];
		}

		//group by company
		$company_hide_menus = array();
		foreach ($tmp_company_hide_menus as $tmp_user) {
			$index = $tmp_user['M02Company']['id'];
			if (!isset($company_hide_menus[$index])) {
				$company_hide_menus[$index]['M02Company'] = $tmp_user['M02Company'];
			}

			if (isset($tmp_user['T94CompanyHideMenu']['menu_item_code'])) {
				$menu_item_code = $tmp_user['T94CompanyHideMenu']['menu_item_code'];
				$company_hide_menus[$index]['data_hide_menu'][$menu_item_code] = $tmp_user['T94CompanyHideMenu']['id'];
			}
		}

		//slice array data
		$company_hide_menus = array_slice($company_hide_menus, ($page-1)*$limit, $limit);

		foreach ($company_hide_menus as $arr_list) {
			$json_row = array();
			$json_row['No'] = $arr_list['M02Company']['id'];
			$json_row['アカウント'] = $arr_list['M02Company']['company_code'] ? $arr_list['M02Company']['company_code'] : '';
			$json_row['企業名'] = $arr_list['M02Company']['company_name'] ? $arr_list['M02Company']['company_name'] : '';

			foreach ($menu_manage_items as $menu_item) {
				$menu_item_code = $menu_item['M91MenuManageItem']['menu_item_code'];
				$checked = isset($arr_list['data_hide_menu']) && isset($arr_list['data_hide_menu'][$menu_item_code]) ? '' : 'checked';
				$t94_id = isset($arr_list['data_hide_menu']) && isset($arr_list['data_hide_menu'][$menu_item_code]) ? 't94_id="' . $arr_list['data_hide_menu'][$menu_item_code] . '"'  : '';
				$disabled = $enable_edit ? '' : 'disabled';

				$json_row[$menu_item['M91MenuManageItem']['menu_item_name']] =
					'<input class="cbHide" type="checkbox" id="' . $arr_list['M02Company']['company_id'] . '_' . $menu_item_code . '" company_id="' . $arr_list['M02Company']['company_id'] . '" item_id="' . $menu_item_code . '" ' . $t94_id . $checked . ' ' . $disabled . '>'
					. '<label for="' . $arr_list['M02Company']['company_id'] . '_' . $menu_item_code . '" style="margin-top: 2px;"></label>';
			}
			$json_data["rows"][] = (object) $json_row;
		}
		$json_data["headers"] = $headers;
		$json_string = json_encode($json_data);
		echo $json_string;
		if(isset($sort_order)){
			$this->ESession->setSortColumn($sort_order[1], $this);
			$this->ESession->setSortType($sort_order[2], $this);
		}else{
			$this->ESession->setSortColumn(null, $this);
			$this->ESession->setSortType(null, $this);
		}
		$this->ESession->setPage($js_page, $this);
		exit;
	}

	public function save() {
		if (empty($this->data)) {
			$this->redirect(array('controller' => 'ManageMenu', 'action' => 'index'));
		}
		$entry_user_id = $this->ESession->getUserId($this);
		$program = $this->name.'_'.__FUNCTION__;

		$dsT94CompanyHideMenu = $this->T94CompanyHideMenu->getDataSource();
		$dsT94CompanyHideMenu->begin($this);

		if (isset($this->data['delete_items']) && !empty($this->data['delete_items'])) {
			$delete_items = $this->data['delete_items'];
			$query_str = 'UPDATE t94_company_hide_menus SET del_flag="Y", modified=NOW(), update_user="' . $entry_user_id . '", update_program="' . $program . '" WHERE id IN (' . implode($delete_items, ',') . ')';
			if ($this->T94CompanyHideMenu->query($query_str)) {
				$dsT94CompanyHideMenu->rollback($this);
				echo 'err_db';
				exit;
			}
		}

		if (isset($this->data['add_items']) && !empty($this->data['add_items'])) {
			$add_items = $this->data['add_items'];
			foreach ($add_items as $company_id => $menu_item_codes) {
				foreach ($menu_item_codes as $menu_item_code) {
					$this->T94CompanyHideMenu->create();
					$data['T94CompanyHideMenu'] = array();
					$data['T94CompanyHideMenu']['company_id'] = $company_id;
					$data['T94CompanyHideMenu']['menu_item_code'] = $menu_item_code;
					$data['T94CompanyHideMenu']['created'] = date('Y-m-d H:i:s a', time());
					$data['T94CompanyHideMenu']['entry_user'] = $entry_user_id;
					$data['T94CompanyHideMenu']['entry_program'] = $program;
					if (!$this->T94CompanyHideMenu->save($data)) {
						$dsT94CompanyHideMenu->rollback($this);
						echo 'err_db';
						exit;
					}
				}
			}
		}
		$dsT94CompanyHideMenu->commit($this);

		echo 'true';
		exit;
	}
}
