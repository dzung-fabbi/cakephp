{html func=css path='inboundrestrict/inbound_restrict_ng_index'}
{html func=css path='inboundrestrict/inbound_restrict_ng_detail'}
{html func=css path='common/jquery-ui.css'}
{html func=script url='jquery.validate'}
{html func=script url='view/inboundrestrict/inbound_restrict_ng_detail'}
{html func=script url='view/inboundrestrict/inbound_restrict_ng_validate' charset="UTF-8"}
{html func=script url='pager'}

{literal}
<script>
	var max_tel_param = {/literal}{$max_tel_param['M99SystemParameter']['parameter_value']}{literal};
	var list_name_old = "{/literal}{$list['T18IncomingNgList']['list_name']}{literal}";
	var enable_delete = "{/literal}{$enable_delete}{literal}";
</script>
{/literal}

<div class="col-lg-10 col-sm-10" id="content">
<!-- content starts -->
	{$this->Session->flash()}
	<div class="alert alert-success fade in" id="cl-detail-success-message" style="display:none;">
		<p></p>
	</div>
	<div class="alert alert-danger fade in" id="cl-detail-error-message" style="display:none;">
		<button type="button" class="close">×</button><p></p>
	</div>
	<div class="row">
		<form class="form-horizontal" role="form"  action="" id="form_update_call_list_ng">
			<div class="col-sm-6">
				<div class="form-group">
					<input type="hidden" value="{$list['T18IncomingNgList']['id']}" name="unlockEditCallList" id="call_list_id" class="input_box_new"/>
					<label class="col-sm-2 control-label">リスト名</label>
					<div class="col-sm-10">
					  	<input type="text" class="form-control" value="{$list['T18IncomingNgList']['list_name']}" name="data[T18IncomingNgList][ListName]"
					  		id="call_list_name" data-rule-maxlength="100" data-msg-required="リスト名は必須項目です。" placeholder="リスト名" {if !$enable_edit_call_list}readonly{/if}/>
					</div>
				</div>
			</div>
			{if $enable_edit_call_list}
				<div class="form-group col-md-6">
					<!-- 20160405 Edit by Giang - #6854 - disable double-click -->
					<a href="javascript:void(0);" title="更新" data-toggle="tooltip" class="btn btn-primary btn-setting executebtn" id="btnUpdate">保存</a>
				</div>
			{/if}
		</form>
	</div>

	{if $enable_create}
		<div class="row">
			<form class="form-horizontal" role="form"  action="" id="form_add_tel_ng_list">
				<div class="col-sm-6">
					<div class="form-group">
						<textarea id="tel_lists" class="form-control" name="tel_lists" rows="3"></textarea>
					</div>
					<div class="form-group" id="textbox_error_add_tel_ng">
					</div>
				</div>
					<div class="form-group col-md-6">
						<!-- 20160405 Edit by Giang - #6854 - disable double-click -->
						<a href="javascript:void(0);" title="テキスト登録" data-toggle="tooltip" class="btn btn-primary executebtn" id="btnAddText">テキスト登録</a>
					</div>
			</form>
		</div>
	{/if}

	<div class="row">
		<div class="form-group col-md-12">
			{if $enable_create}
				<a href="javascript:void(0);" title="追加登録" data-toggle="tooltip" class="btn btn-primary btn-setting" id="btnAddFile">追加登録</a>
			{/if}
			{if $enable_delete}
				<!-- 20160405 Edit by Giang - #6854 - disable double-click -->
				<a href="javascript:void(0);" title="選択項目を削除" data-toggle="tooltip" class="btn btn-default executebtn" id="btnDelete"
					call_list_id="{$list['T18IncomingNgList']['id']}" tel_total="{$list['T18IncomingNgList']['total']}">選択項目を削除</a>
			{/if}
		</div>
	</div>

	<div class="rules_div">
		<div class="wrap">
			<form id="T11TellListIndexForm">
			<table id="telIncomingNgTable" class="table table-striped table-bordered">
				<colgroup>
					{if $enable_delete}
						<col span="1" width="5%">
					{/if}
					<col span="1" width="5%">
					<col>
					<col>
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
						<th style="text-align:center;">電話番号</th>
						<th style="text-align:center;">メモ</th>
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
	<div class="modal fade" id="dialog_add_file" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true" data-backdrop="static">
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
						追加登録
					</h4>
				</div>

				<!-- Modal Body -->
				<div class="modal-body">
					<form id="form_add_file" method="post" action="{Router::url('', true)}" accept-charset="utf-8" enctype="multipart/form-data">
					<div class="form-group">
						<label class="col-sm-2 control-label">ファイル</label>
						<div class="col-sm-7">
							<input type="text" id="txt-restriction" name="txt-restriction" class="form-control" readonly/>
							<input type="file" id="file_to_upload" name="data[T15OutgoingNgTel][File]" class="hide"/>
						</div>
						<div class="col-sm-3">
							<!-- 20160405 Edit by Giang - #6854 - disable double-click -->
							<a href="#" id='btnUpload' class="btn btn-primary executebtn">ファイルを選択</a>
						</div>
						<label class="col-sm-12 col-md-offset-2 control-label uploadlbl">※CSV、TXTファイルのみ</label>
					</div>

					<hr>
					<div id="data_csv_error_div"></div>
					</form>
				</div>

				<!-- Modal Footer -->
				<div class="modal-footer">
					<a href="javascript:void(0);" class="btn btn-default executebtn" id="btnCancel" data-dismiss="modal">閉じる</a> <!-- 20160405 Edit by Giang - #6854 - disable double-click -->
					<a href="javascript:void(0);" class="btn btn-primary executebtn" id="btnSave">保存</a> <!-- 20160405 Edit by Giang - #6854 - disable double-click -->
				</div>
			</div>
		</div>
	</div>
<!-- 新規登録MODAL END-->

<!-- content ends -->
</div>