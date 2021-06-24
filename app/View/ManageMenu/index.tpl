{html func=css path='managemenu/index'}
{html func=script url='view/managemenu/index'}
{html func=script url='pager'}

<div class="col-lg-10 col-sm-10" id="content">
<!-- content starts -->
	{if $mode eq "success"}
		<div class="alert alert-success fade in">
			<button type="button" class="close">×</button><p>更新しました。</p>
		</div>
	{/if}
	<div class="row">
		<div class="form-group col-md-12">
			{if $enable_edit}
				<a href="javascript:void(0);" class="btn btn-primary" id="btnSave">保存</a>
			{/if}
		</div>
	</div>

	<div class="rules_div">
		<div class="wrap">
			<table id="userListTable">
				<colgroup>
					<col width="5%">
					<col width="25%">
					<col width="25%">
				</colgroup>
				<thead class="head">
					<tr>
						<th class="alignCenter tablesorter-headerUnSorted" rowspan="2">No</th>
						<th class="alignCenter tablesorter-headerUnSorted" rowspan="2">アカウント</th>
						<th class="alignCenter tablesorter-headerUnSorted" rowspan="2">企業名</th>
						<th class="remove sorter-false filter-false text-center"colspan="{$menu_manage_items|count}">メニュー</th>
					</tr>
					<tr>
						{foreach from=$menu_manage_items item=menu_manage_item}
							<th class="remove sorter-false filter-false text-center">{$menu_manage_item.M91MenuManageItem.menu_item_name}</th>
						{/foreach}
					</tr>
				</thead>
				<tbody class="inner_table">
				</tbody>
			</table>
			<!-- pager -->
			{$view->element('pager/pager')}
			<input type="hidden" value="{if isset($sortColumn)}{$sortColumn}{/if}" id="hdSortColumnList"/>
			<input type="hidden" value="{if isset($sortType)}{$sortType}{/if}" id="hdSortTypeList"/>
			<input type="hidden" value="{if isset($page)}{$page}{/if}" id="hdPageList"/>
		</div>
	</div>
<!-- content ends -->
</div>