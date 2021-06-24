<?php
App::uses('AppController', 'Controller');

class UserManageController extends AppController {
	var $name = 'UserManage';
	var $uses = Array('M13Auth', 'TUser', 'M25Category');
	
	function index($mode = null) {
		$category1 = $this->ESession->getCategory1($this);
		$category2 = $this->ESession->getCategory2($this);
		$category3 = $this->ESession->getCategory3($this);
		$category4 = $this->ESession->getCategory4($this);
		$post_code = $this->ESession->getPostCode($this);
		//カテゴリごとの全ユーザー情報取得	
		$resultAllUser = $this->TUser->getAllUser($category1, $category2, $category3, $category4);
		$this->set('mode',$mode);
		$this->set('user_manage',$resultAllUser);
	}
	
	function add_update_user($mode = null) {

		//全分類を取得
		$resultAllCategory1 = $this->M25Category->getAllCategory1();
		//ログインユーザーの権限を取得
		$post_code = $this->ESession->getPostCode($this);
		
		//全権限を取得
		$resultAllAuth = $this->M13Auth->getAllAuth($post_code);

		if ($mode == 'update') {
			$data = $this->data;
			if (empty($data)) {
				$this->redirect(array('controller' => 'UserManage', 'action' => 'index'));
			}
			$listUserInfo = $this->TUser->getUserById($data['id']);
			$id = $data['id'];
			if(count($listUserInfo) == 0){
				$this->log("ユーザー更新：失敗", "debug");
				$this->redirect(array('controller' => 'Login', 'action' => 'index/systemerror'));
			}
			
			$this->set('list_user',$listUserInfo);
		}
		
		//画面にセットする
		$this->set('login_cate1_code',$this->ESession->getCategory1($this));
		$this->set('login_cate2_code',$this->ESession->getCategory2($this));
		$this->set('login_cate3_code',$this->ESession->getCategory3($this));
		$this->set('login_cate4_code',$this->ESession->getCategory4($this));
		$this->set('login_cate1_name',$this->ESession->getCategory1Name($this));
		$this->set('login_cate2_name',$this->ESession->getCategory2Name($this));
		$this->set('login_cate3_name',$this->ESession->getCategory3Name($this));
		$this->set('login_cate4_name',$this->ESession->getCategory4Name($this));
		$this->set('category1_list',$resultAllCategory1);
		$this->set('auth',$resultAllAuth);
		$this->set('post_code',$post_code);
		$this->set('mode',$mode);
		
	}
	
	function init_category2($category1_code = null, $category2_code = null) {
		$this->layout = "ajax";
		
		if (!empty($category1_code)) {
			$resultAllCategory2 = $this->M25Category->getInfoChildrenCategoryByCategoryCode($category1_code, 2);
			$this->set('category2_list', $resultAllCategory2);
			$this->set('category2_code', $category2_code);
		}
		$this->set('login_cate2_code',$this->ESession->getCategory2($this));
		$this->set('login_cate2_name',$this->ESession->getCategory2Name($this));
	}
	function init_category3($category2_code = null, $category3_code = null) {
		$this->layout = "ajax";
		
		if (!empty($category2_code)) {
			$resultAllCategory3 = $this->M25Category->getInfoChildrenCategoryByCategoryCode($category2_code, 3);
			$this->set('category3_list', $resultAllCategory3);
			$this->set('category3_code', $category3_code);
		}
		$this->set('login_cate3_code',$this->ESession->getCategory3($this));
		$this->set('login_cate3_name',$this->ESession->getCategory3Name($this));
	}
	function init_category4($category3_code = null, $category4_code = null) {
		$this->layout = "ajax";
		
		if (!empty($category3_code)) {
			$resultAllCategory4 = $this->M25Category->getInfoChildrenCategoryByCategoryCode($category3_code, 4);
			$this->set('category4_list', $resultAllCategory4);
			$this->set('category4_code', $category4_code);
		}
		$this->set('login_cate4_code',$this->ESession->getCategory4($this));
		$this->set('login_cate4_name',$this->ESession->getCategory4Name($this));
	}
	
	function add_user() {
		$data = $this->data;
		
		//ID重複確認
		$resultInfoByUserId = $this->TUser->getInfoByUserId($data['TUser']['user_id']);
		
		if (count($resultInfoByUserId) != 0) {
			$this->redirect(array('controller' => 'UserManage', 'action' => 'add_update_user/existing'));
		}
		$data['TUser']['password'] = Security::hash($data['TUser']['password'],'sha256',true);
		
		if (isset($data['M25Category']['category1']) && $data['M25Category']['category1'] != '') {
			$data['TUser']['category1'] = $data['M25Category']['category1'];
		}
		if (isset($data['M25Category']['category2']) && $data['M25Category']['category2'] != '') {
			$data['TUser']['category2'] = $data['M25Category']['category2'];
		}
		if (isset($data['M25Category']['category3']) && $data['M25Category']['category3'] != '') {
			$data['TUser']['category3'] = $data['M25Category']['category3'];
		}
		if (isset($data['M25Category']['category4']) && $data['M25Category']['category4'] != '') {
			$data['TUser']['category4'] = $data['M25Category']['category4'];
		}
		$data['TUser']['post_code'] = $data['M13Auth']['post_code'];
		$data['TUser']['entry_user'] = $this->ESession->getUserId($this);
		$data['TUser']['entry_program'] = $this->name.'_'.__FUNCTION__;
		$data['TUser']['update_user'] = $this->ESession->getUserId($this);
		$data['TUser']['update_program'] = $this->name.'_'.__FUNCTION__;
		
		$flag = $this->TUser->save($data);
		if(!$flag){
			$this->log("ユーザー登録：失敗");
			$this->redirect(array('controller' => 'Login', 'action' => 'index/systemerror'));
		}
		$this->redirect(array('controller' => 'UserManage', 'action' => 'index/add'));
	}
	
	function update_user() {
		$data = $this->data;

		if (empty($data)) {
			$this->redirect(array('controller' => 'OutSchedule', 'action' => 'index'));
		}
		$resultUserById = $this->TUser->getUserById($data['TUser']['id']);
		
		if(count($resultUserById) == 0) {
			$this->log("ユーザー更新：失敗", "debug");
			$this->redirect(array('controller' => 'Login', 'action' => 'index/systemerror'));
		}
		$M15Update = array();
		
		$M15Update['id'] = $data['TUser']['id'];
		$M15Update['user_name'] = $data['TUser']['user_name'];
		if(!empty($data['TUser']['password'])) {
			$M15Update['password'] = Security::hash($data['TUser']['password'],'sha256',true);
		}
		if (isset($data['M25Category']['category1']) && $data['M25Category']['category1'] != '') {
			$M15Update['category1'] = $data['M25Category']['category1'];
		} else {
			$M15Update['category1'] = '';
		}
		if (isset($data['M25Category']['category2']) && $data['M25Category']['category2'] != '') {
			$M15Update['category2'] = $data['M25Category']['category2'];
		} else {
			$M15Update['category2'] = '';
		}
		if (isset($data['M25Category']['category3']) && $data['M25Category']['category3'] != '') {
			$M15Update['category3'] = $data['M25Category']['category3'];
		} else {
			$M15Update['category3'] = '';
		}
		if (isset($data['M25Category']['category4']) && $data['M25Category']['category4'] != '') {
			$M15Update['category4'] = $data['M25Category']['category4'];
		} else {
			$M15Update['category4'] = '';
		}
		$M15Update['mail'] = $data['TUser']['mail'];
		$M15Update['post_code'] = $data['M13Auth']['post_code'];
		$M15Update['update_user'] = $this->ESession->getUserId($this);
		$M15Update['update_program'] = $this->name.'_'.__FUNCTION__;
		$flag = $this->TUser->save($M15Update);
		if(!$flag){
			$this->log("ユーザー編集：失敗");
			$this->redirect(array('controller' => 'Login', 'action' => 'index/systemerror'));
		}
		$this->redirect(array('controller' => 'UserManage', 'action' => 'index/updated'));
	}
	
	function delete_user() {
		$data = $this->data;
		if (empty($data)) {
			$this->redirect(array('controller' => 'UserManage', 'action' => 'index'));
		}
		$resultUserById = $this->TUser->getUserById($data['id']);
		$id = $data['id'];
		if(count($resultUserById) == 0){
			$this->log("ユーザー削除：失敗", "debug");
			$this->redirect(array('controller' => 'Login', 'action' => 'index/systemerror'));
		}
		$M15Delete = array();
		$M15Delete['id'] = $id;
		$M15Delete['del_flag'] = 'Y';
		$M15Delete['update_program'] = $this->name.'_'.__FUNCTION__;
		
		$flag = $this->TUser->save($M15Delete);
		if(!$flag){
			$this->log("ユーザー削除：失敗", "debug");
			$this->redirect(array('controller' => 'Login', 'action' => 'index/systemerror'));
		}
		$this->redirect(array('controller' => 'UserManage', 'action' => 'index/delete'));
	}
}