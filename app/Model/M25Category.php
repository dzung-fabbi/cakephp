<?php

class M25Category extends AppModel {
	var $name = 'M25Category';
	/**
	 **
	 *
	 * Get server_name from server_id
	 * @param $server_id
	 */
	function getInfoCategoryByCategoryCode($category1, $category2, $category3, $category4){
		//取得項目
		$options['fields'] = array(
				'M25Category.category_code',
				'M25Category.category_name',
				'M25Category.category_level',
		);
		//検索条件
		if(isset($category1) && !empty($category1)) {
			$options['conditions']['or'][]['M25Category.category_code'] = $category1;
			if(isset($category2) && !empty($category2)) {
				$options['conditions']['or'][]['M25Category.category_code'] = $category2;
				if(isset($category3) && !empty($category3)) {
					$options['conditions']['or'][]['M25Category.category_code'] = $category3;
					if(isset($category4) && !empty($category4)) {
						$options['conditions']['or'][]['M25Category.category_code'] = $category4;
					}
				}
			}
		}
		//検索条件
		$options['conditions']['M25Category.del_flag'] = 'N';
		//ソート
		$options['order'] = array('M25Category.category_level asc');
		//検索
		return $this->find('all', $options);
	}
	
	function getInfoChildrenCategoryByCategoryCode($category_code = null, $category_level = null){
		//取得項目
		$options['fields'] = array(
				'M25Category.category_code',
				'M25Category.category_name',
				'M25Category.category_level',
		);
		//検索条件
		if (isset($category_level)) {
			$options['conditions']['M25Category.category_level'] = $category_level;
		}
		$options['conditions']['M25Category.parent_code'] = $category_code;
		$options['conditions']['M25Category.del_flag'] = 'N';
		//ソート
		$options['order'] = array('M25Category.display_select_order asc');
		//検索
		return $this->find('all', $options);
	}
	
	function getAllCategory1(){
		//取得項目
		$options['fields'] = array(
				'M25Category.category_code',
				'M25Category.category_name',
		);
		//検索条件
		$options['conditions']['M25Category.category_level'] = '1';
		$options['conditions']['M25Category.del_flag'] = 'N';
		
		//ソート
		$options['order'] = array('M25Category.display_select_order asc');
		
		//検索
		return $this->find('all', $options);
	}
	
}
?>