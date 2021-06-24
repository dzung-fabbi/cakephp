<form class="form-horizontal" role="form" id="form_add_setting_inbound" method="post" accept-charset="utf-8" novalidate="novalidate">
	<!-- 新規登録MODAL START -->
	<div class="modal {*fade*}" id="dialogAddSettingInbound" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true" data-backdrop="static">
		<div class="modal-dialog" style="width: 700px;">
			<div class="modal-content">
				<!-- Modal Header -->
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">&times;</span><span class="sr-only">Close</span>
					</button>
					<h4 class="modal-title" id="modalAddSettingInboundLabel">新規登録</h4>
				</div>

				<!-- Modal Body -->
				<div class="modal-body">
					<div class="form-group">
						<label class="col-sm-4 control-label">電話番号</label>
						<div class="form-group col-sm-6">
							<select id="external_number" name="data[T25Inbound][external_number]" class="form-control">
								<option value=""></option>
								{foreach from=$external_numbers item=values}
									<option value="{$values.M06CompanyExternal.external_number}" {if isset($data) && $data.T25Inbound.external_number eq $values.M06CompanyExternal.external_number}selected{/if}>{$values.M06CompanyExternal.external_number}</option>
								{/foreach}
							</select>
						</div>
					</div>
					<div class="form-group">
						<label class="col-sm-4 control-label">テンプレート</label>
						<div class="form-group col-sm-6">
							<select id="template_id" name="data[T25Inbound][template_id]" class="form-control">
								<option value=""></option>
								{if (isset($template_busy[0]))}
									<option value="{$template_busy[0].M90PulldownCode.item_code}" {if isset($data) && $data.T25Inbound.template_id eq $template_busy[0].M90PulldownCode.item_code}selected{/if}>{$template_busy[0].M90PulldownCode.item_name}</option>
								{/if}
								{foreach from=$inbound_templates item=values}
									<option value="{$values.T30Template.id}" {if isset($data) && $data.T25Inbound.template_id eq $values.T30Template.id}selected{/if}>{$values.T30Template.template_name}</option>
								{/foreach}
							</select>
						</div>
					</div>
					<div class="form-group">
						<label class="col-sm-4 control-label">着信拒否リスト</label>
						<div class="form-group col-sm-6">
							<select id="list_ng_id" name="data[T25Inbound][list_ng_id]" class="form-control">
								<option value=""></option>
								{foreach from=$inbound_list_ngs item=values}
									<option value="{$values.T18IncomingNgList.id}" {if isset($data) && $data.T25Inbound.list_ng_id eq $values.T18IncomingNgList.id}selected{/if}>{$values.T18IncomingNgList.list_name}</option>
								{/foreach}
							</select>
						</div>
					</div>
					<div class="form-group">
						<label class="col-sm-4 control-label">着信リスト</label>
						<div class="form-group col-sm-6">
							<select id="list_id" name="data[T25Inbound][list_id]" class="form-control">
								<option value=""></option>
								{foreach from=$inbound_lists item=values}
									<option value="{$values.T16InboundCallList.id}" {if isset($data) && $data.T25Inbound.list_id eq $values.T16InboundCallList.id}selected{/if}>{if $values.T16InboundCallList.list_test_flag eq "1"}<font color='red'>(テスト){/if}{$values.T16InboundCallList.list_name}</option>
								{/foreach}
							</select>
						</div>
					</div>
				</div>

				<!-- Modal Footer -->
				<div class="modal-footer">
					<a href="javascript:void(0);" id="btn_cancel" class="btn btn-default" data-dismiss="modal">閉じる</a>
					{if (isset($id))}
						<a href="javascript:void(0);" id="btn_submit" class="btn btn-primary" action="duplicate">保存</a>
					{else}
						<a href="javascript:void(0);" id="btn_submit" class="btn btn-primary" action="create">保存</a>
					{/if}

				</div>
			</div>
		</div>
	</div>
	<!-- 新規登録MODAL END-->
</form>