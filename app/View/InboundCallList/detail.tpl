{html func=css path='inboundcalllist/inbound_call_list_index'}
{html func=css path='inboundcalllist/inbound_call_list_detail'}
{html func=script url='jquery.validate'}
{html func=script url='view/inboundcalllist/inbound_call_list_detail'}
{html func=script url='view/inboundcalllist/inbound_call_list_validate' charset="UTF-8"}
{html func=script url='pager'}

{literal}
<script>
	var list_name_old = "{/literal}{$list['T16InboundCallList']['list_name']}{literal}";
	var enable_edit_call_list = "{/literal}{$enable_edit_call_list}{literal}";
	var item_main = "{/literal}{$item_main}{literal}";
	var item_column = "{/literal}{$item_column}{literal}";
	{/literal}
		{foreach from=$t13_list_items item=t13_list_item}
			{if $t13_list_item['T13InboundListItem']['item_code'] eq 'tel_no'}
				var indexTelNo = "{$t13_list_item['T13InboundListItem']['column']}";
			{/if}
		{/foreach}
	{literal}
</script>
{/literal}

<div class="col-lg-10 col-sm-10" id="content">
<!-- content starts -->

	{$this->Session->flash()}
	{if $mode eq "save"}
		<div class="alert alert-success">保存しました。</div>
	{/if}
	{if $mode eq "delete"}
		<div class="alert alert-success">削除しました。</div>
	{/if}
	<div class="alert alert-success fade in" id="cl-detail-success-message" style="display:none;">
		<button type="button" class="close">×</button><p></p>
	</div>
	<div class="alert alert-danger fade in" id="cl-detail-error-message" style="display:none;">
		<button type="button" class="close">×</button><p></p>
	</div>
	<div class="row">
		<form class="form-horizontal" role="form"  action="" id="form_update_list_info">
			<div class="form-group">
				<input type="hidden" value="{$list['T16InboundCallList']['id']}" name="unlockEditCallList" id="call_list_id" class="input_box_new"/>
				<label class="col-sm-2 control-label">リスト名</label>
				<div class="col-sm-4">
				  	<input type="text" class="form-control" value="{$list['T16InboundCallList']['list_name']}" name="data[T16InboundCallList][ListName]" id="call_list_name" data-rule-maxlength="100" data-msg-required="リスト名は必須項目です。" placeholder="リスト名" {if !$enable_edit_call_list}readonly{/if}/>
				</div>
				{if $enable_edit_call_list}
				<div class="col-sm-4">
					<a href="javascript:void(0);" title="保存" data-toggle="tooltip" class="btn btn-primary btn-setting executebtn" id="btnSaveTelList">保存</a> <!-- 20160405 Edit by Giang - #6854 - disable double-click -->
				</div>
				{/if}
			</div>
			<div class="form-group">
				<label class="col-sm-2 control-label">テストリスト</label>
				<div class="col-sm-4 ptop7">
					<input type="checkbox" name="data[T16InboundCallList][ListTestFlag]" id="list_test_flag" {if $list['T16InboundCallList']['list_test_flag'] eq '1'}checked{/if} {if !$enable_edit_call_list}disabled{/if}>
					<label for="list_test_flag"></label>
				</div>
			</div>
			<div class="form-group">
				<label class="col-sm-2 control-label">照合項目</label>
				<div class="col-sm-4 ptop7">
					<select name="item_main" id="item_main" class="form-control" {if !$enable_edit_call_list}disabled="disabled"{/if}>
						{foreach from=$ShowCallList item=t13_list_item}
							<option value="{$t13_list_item}" {if $t13_list_item eq $item_main}selected="selected"{else}disabled="disabled"{/if}>
								{$t13_list_item}
							</option>
						{/foreach}
					</select>
				</div>
			</div>
		</form>
	</div>

	<div class="row">
		<div class="form-group col-md-12">
			{if $enable_create}
				<a href="javascript:void(0);" title="新規登録" data-toggle="tooltip" class="btn btn-primary btn-setting" id="btnAddTel">新規登録</a>
			{/if}
			{if $enable_delete}
				<!-- 20160405 Edit by Giang - #6854 - disable double-click -->
				<a href="javascript:void(0);" title="選択項目を削除" data-toggle="tooltip" class="btn btn-default executebtn" id="btnDelTel" call_list_id="{$list['T16InboundCallList']['id']}" tel_total="{$list['T16InboundCallList']['tel_total']}">選択項目を削除</a>
			{/if}
			<!-- 20160530 Edit by Giang - Comment out muko - Begin -->
			{*if $enable_report_not_effective*}
				<!-- 20160405 Edit by Giang - #6854 - disable double-click -->
				<!-- <a href="javascript:void(0);" title="無効項目を反映" data-toggle="tooltip" class="btn btn-default executebtn" id="btnInefficient">無効項目を反映</a> -->
			{*/if*}
			<!-- 20160530 Edit by Giang - Comment out muko - End -->
		</div>
	</div>

	<div class="rules_div">
		<div class="wrap">
			<form id="T11TellListIndexForm">
			<table id="telListTable" class="table table-striped table-bordered">
				<colgroup>
					{if $enable_delete}
						<col span="1" width="5%">
					{/if}
					<col span="1" width="5%">
					{foreach from=$headers item=header}
						<col>
					{/foreach}
					<!-- <col span="1" width="5%"> --> <!-- 20160530 Edit by Giang - Comment out muko -->
					{if $enable_edit}
					<col span="1" width="5%">
					{/if}
				</colgroup>
				<thead class="head">
					<tr>
						{if $enable_delete}
							<th class="remove sorter-false filter-false alignCenter">
								<input type="checkbox" id="bundleCheckbox" data-checkbox="cbSelect">
								<label for="bundleCheckbox" class="bundleCheckbox"></label>
							</th>
						{/if}
						<th style="text-align:center;">NO</th>
						{foreach from=$headers item=header}
							<th style="text-align:center;">{$header}</th>
						{/foreach}
						<!-- <th class="remove sorter-false filter-false text-center">無効</th> --> <!-- 20160530 Edit by Giang - Comment out muko -->
						{if $enable_edit}
						<th class="remove sorter-false filter-false text-center">アクション</th>
						{/if}
					</tr>
				</thead>
				<tbody>
				</tbody>
			</table>
			<!-- pager -->
			{$view->element('pager/pager')}
			<input type="hidden" value="{if isset($sortColumn)}{$sortColumn}{/if}" id="hdSortColumnList"/>
			<input type="hidden" value="{if isset($sortType)}{$sortType}{/if}" id="hdSortTypeList"/>
			<input type="hidden" value="{if isset($page)}{$page}{/if}" id="hdPageList"/>
			</form>
		</div>
	</div>
<!-- 新規登録MODAL START -->
	<div class="modal fade" id="dialog_add_tel_list" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true" data-backdrop="static">
		<div class="modal-dialog">
			<div class="modal-content">
				<!-- Modal Header -->
				<div class="modal-header">
					<button type="button" class="close"
					   data-dismiss="modal">
						   <span aria-hidden="true">&times;</span>
						   <span class="sr-only">Close</span>
					</button>
					<h4 class="modal-title" id="myModalLabel">
						新規登録
					</h4>
				</div>

				<form id="form_add_edit_tel" method="post" action="{Router::url('', true)}" accept-charset="utf-8" enctype="multipart/form-data">
				<!-- Modal Body -->
				<div class="modal-body">

					<div class="form-group">
						<label class="col-sm-3 control-label">リスト名</label>
						<div class="col-sm-8">
							<p class="form-control-static">{$list['T16InboundCallList']['list_name']}</p>
							<input type="text" id="id" name="id" class="hide">
						</div>
					</div>
					{foreach from=$t13_list_items item=t13_list_item}
						<div class="form-group">
							<label class="col-sm-3 control-label">{$headers[$t13_list_item['T13InboundListItem']['column']]}</label>
							<div class="form-group col-sm-8">
								{if $t13_list_item['T13InboundListItem']['item_code'] eq 'birthday'}
								<div class="row">
									{html_select_date prefix='birthday' time=$time start_year='-100' year_empty="---" month_empty="---" day_empty="---" field_order="YMD" month_format="%m" day_value_format="%02d" reverse_years="true"}
								</div>
								<input type="text" id="{$t13_list_item['T13InboundListItem']['column']}" name="birthday_date" class="birthday_date hide" readonly/>
								{elseif $t13_list_item['T13InboundListItem']['item_code'] eq 'tel_no'}
									<input type="text" id="{$t13_list_item['T13InboundListItem']['column']}" name="tel_number" class="form-control input-sm"/>
								{elseif $t13_list_item['T13InboundListItem']['item_code'] eq 'money'}
									<input type="text" id="{$t13_list_item['T13InboundListItem']['column']}" name="fee" class="form-control input-sm"/>
								{else}
									<input type="text" id="{$t13_list_item['T13InboundListItem']['column']}" name="{$t13_list_item['T13InboundListItem']['column']}" class="form-control input-sm"/>
								{/if}
							</div>
						</div>
					{/foreach}

				</div>

				<!-- Modal Footer -->
				<div class="modal-footer">
					<a href="javascript:void(0);" class="btn btn-default executebtn" id="btn_cancel_add_tel" data-dismiss="modal">閉じる</a> <!-- 20160405 Edit by Giang - #6854 - disable double-click -->
					<a href="javascript:void(0);" class="btn btn-primary executebtn" id="btn_add_edit_tel">保存</a> <!-- 20160405 Edit by Giang - #6854 - disable double-click -->
				</div>
				</form>
			</div>
		</div>
	</div>
<!-- 新規登録MODAL END-->

<!-- content ends -->
</div>
