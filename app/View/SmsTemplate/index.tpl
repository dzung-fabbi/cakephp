{html func=css path='smstemplate/sms_template_index'}
{html func=script url='jquery.validate'}
{html func=script url='view/smstemplate/sms_template_index' charset="UTF-8"}
{html func=script url='pager'}

{literal}
<script>
	var showCbDel = {/literal}"{$enable_delete}"{literal};
</script>
{/literal}

<div class="col-lg-10 col-sm-10">
<!-- content starts -->
	<div class="alert alert-success fade in" id="smstemplate-success-message" style="display:none;">
		<button type="button" class="close">×</button><p></p>
	</div>
	<div class="alert alert-danger fade in" id="smstemplate-error-message" style="display:none;">
		<button type="button" class="close">×</button><p></p>
	</div>
	<div class="row">
		<div class="form-group col-md-12">
			{if $enable_create}
				<a href="javascript:void(0);" title="新規作成" data-toggle="tooltip" class="btn btn-primary btn-setting" id="btnCreate">新規作成</a>
			{/if}
			{if $enable_delete}
				<a href="javascript:void(0);" title="選択項目を削除" data-toggle="tooltip" class="btn btn-default executebtn" id="btnSelectedDelete">選択項目を削除</a>
			{/if}
		</div>
	</div>

	<div class="rules_div">
		<div class="wrap">
			<form id="T300SmsTemplateIndexForm">
				<table class="table table-striped table-bordered" id="smsTemplateTable">
					<colgroup>
						{if $enable_delete}
							<col span="1" width="5%">
						{/if}
						<col span="1" width="5%">
						<col span="1" width="15%">
						<col span="1" width="40%">
						<col span="1" width="15%">
						<col span="1" width="13%">
						<col span="1" width="7%">
					</colgroup>
					<thead>
						<tr>
							{if $enable_delete}
								<th class="remove sorter-false filter-false text-center"></th>
							{/if}
							<th class="text-center">NO</th>
							<th class="text-center">名称</th>
							<th class="text-center">説明</th>
							<th class="text-center">作成日時</th>
							<th class="text-center">作成者</th>
							<th class="remove sorter-false filter-false text-center">アクション</th>
						</tr>
					</thead>
					<tbody></tbody>
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
	<div class="modal fade" id="dialog_add_sms_template" tabindex="-1" role="dialog" aria-labelledby="smsTemplateModalLabel" aria-hidden="true" data-backdrop="static">
		<div class="modal-dialog" style="width: 1022px;">
			<div class="modal-content">
				<!-- Modal Header -->
				<div class="modal-header">
					<button type="button" class="close btn_cancel">
					    <span aria-hidden="true">&times;</span>
					    <span class="sr-only">Close</span>
					</button>
					<h4 class="modal-title" id="smsTemplateModalLabel"></h4>
				</div>

				<!-- Modal Body -->
				<div class="modal-body">

					<form class="form-horizontal" role="form" id="form_add_sms_template" method="post" action="{Router::url('', true)}" accept-charset="utf-8" enctype="multipart/form-data">
						<input type="hidden" id="template_id">
						<div class="form-group" align="center">
							<label class="error" id="msg_edit"></label>
						</div>
						<div class="form-group">
							<label class="col-sm-2 control-label">テンプレート名</label>
							<div class="col-sm-7">
								<input type="text" id="template_name" name="template_name"
								data-rule-maxlength="128"
								{if !$enable_edit}disabled{/if}
								class="form-control" placeholder="テンプレート名"/>
							</div>
						</div>
						<div class="form-group">
							<label class="col-sm-2 control-label">説明</label>
							<div class="col-sm-7">
								<input type="text" id="description" name="description"
								{if !$enable_edit}disabled{/if}
								class="form-control" placeholder="説明"/>
							</div>
						</div>
						<div class="form-group form-audio">
							<label class="col-sm-2 control-label">本文</label>
							<div class="col-sm-7">
								<textarea id="content" name="content"
								{if !$enable_edit}disabled{/if}
								class="form-control" rows="4" placeholder="本文"></textarea>
								<span>※本文の文字数：<span id="count_content" style="color: red;font-weight: bolder;">0</span>文字(挿入項目は含まない)</span>
								<div class="audio_mix">
						            <select class="form-control slCustInfo" name="slCustInfo" id="tounyuu">
											{foreach from=$insert_item item=item}
												<option value="{$item.T13InboundListItem.item_name}">{$item.T102SmsListItem.item_name}</option>
											{/foreach}
										</select>
									<button type="button" name="btnCustInfo" class="btn btn-primary btnCustInfo">挿入</button>
								</div>
							</div>
						</div>

						<div class="form-group form-audio">
							<label class="col-sm-2 control-label">短縮URL</label>
								<div class="col-sm-7 ptop7">
									<input type="checkbox" name="sms_use_short_url" id="sms_use_short_url" value="1">
									<label for="sms_use_short_url" style="margin-top: 2px;"></label>
								</div>
						</div>
					</form>
				</div>

				<!-- Modal Footer -->
				<div class="modal-footer">
					<a href="javascript:void(0);" class="btn btn-default executebtn btn_cancel">閉じる</a>
					{if $enable_create}
					<a href="javascript:void(0);" id="btn_submit" class="btn btn-primary executebtn">保存</a>
					{/if}
					{if $enable_edit}
					<a href="javascript:void(0);" id="btn_update" class="btn btn-primary executebtn">更新</a>
					{/if}
				</div>
			</div>
		</div>
	</div>
<!-- 新規登録MODAL END-->

<!-- content ends -->
</div>