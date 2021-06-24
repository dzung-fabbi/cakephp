{html func=css path='common/jquery-ui.css'}
{html func=css path='inboundincominghistory/setting_inbound'}
{html func=script url='jquery.validate'}
{html func=script url='view/inboundincominghistory/moment-with-locales.min.js' charset="UTF-8"}
{html func=script url='view/inboundincominghistory/inbound_incoming_history_detail' charset="UTF-8"}
{html func=script url='pager'}



<div class="col-lg-10 col-sm-10" id="content">
<!-- content starts -->
	<div class="alert alert-success fade in" id="calllist-success-message" style="display:none;">
		<button type="button" class="close">×</button><p></p>
	</div>
	<div class="alert alert-danger fade in" id="calllist-error-message" style="display:none;">
		<button type="button" class="close">×</button><p></p>
	</div>

	<div class="row">
		<div class="form-group col-md-4">
			<div class="col-md-4">着信番号</div>
			<div class="col-md-8">{$schedule['T25Inbound']['external_number']}</div>
		</div>
	</div>
	{if (isset($schedule[0]['template_name']) && !empty($schedule[0]['template_name']))}
	<div class="row">
		<div class="form-group col-md-4">
			<div class="col-md-4">テンプレート名</div>
			<div class="col-md-8">{$schedule[0]['template_name']}</div>
		</div>
	</div>
	{/if}
	{if (isset($schedule[0]['list_name']) && !empty($schedule[0]['list_name']))}
	<div class="row">
		<div class="form-group col-md-4">
			<div class="col-md-4">着信リスト名</div>
			<div class="col-md-8">{$schedule[0]['list_name']}</div>
		</div>
	</div>
	{/if}
	{if (isset($schedule[0]['list_ng_name']) && !empty($schedule[0]['list_ng_name']))}
	<div class="row">
		<div class="form-group col-md-4">
			<div class="col-md-4">着信拒否リスト名</div>
			<div class="col-md-8">{$schedule[0]['list_ng_name']}</div>
		</div>
	</div>
	{/if}
	<div class="row">
		<div class="form-group col-md-4">
			<div class="col-md-4">適用日</div>
			<div class="col-md-8">
				{if $schedule['T25Inbound']['time_start']}{date('Y-m-d', strtotime($schedule['T25Inbound']['time_start']))}{/if}
				{if $schedule['T25Inbound']['time_end']}
					 ～ 
					{date('Y-m-d', strtotime($schedule['T25Inbound']['time_end']))}
				{/if}
			</div>
		</div>
	</div>
	{if $enable_download}
	<div class="row">
		<div class="form-group col-xs-12 col-sm-6 col-lg-6 pull-right">
			<div title="有効DL" data-toggle="tooltip" class="btn btn-primary col-xs-2 col-sm-6 col-lg-3 executebtn pull-right btnShowDownload" func-name="download_ans_log" id="btnDownloadLogAns">有効DL</div>
			<div title="履歴DL" data-toggle="tooltip" class="btn btn-primary col-xs-2 col-sm-6 col-lg-3 executebtn pull-right btnShowDownload" func-name="download_all_log" id="btnDownloadLog">履歴DL</div>
			{if $enable_download_uncalled}
			<div title="未着信DL" data-toggle="tooltip" class="btn btn-primary col-xs-2 col-sm-6 col-lg-3 executebtn btnDownload pull-right" func-name="download_uncalled" id="btnDownloadUnCalled">未着信DL</div>
			{/if}
		</div>
	</div>
	{/if}

	<div class="rules_div">
		<div class="wrap">
			<div style="overflow-y:auto;">
				<table class="table table-striped table-bordered" id="t80IncomingResultTable">

					<thead>
						<tr>
							<th class="alignCenter tablesorter-headerDesc" style="min-width:165px;">着信日時</th>
							<th class="alignCenter tablesorter-headerUnSorted" style="min-width:150px;">着信元</th>
							<th class="alignCenter tablesorter-headerUnSorted" style="min-width:150px;">接続時間</th>
							<th id="sort_transfer" class="alignCenter tablesorter-headerUnSorted" position="3" style="min-wid-th:150px;">ステータス</th>
							{foreach from=$headers key=key item=header}
								{if ($sort_flags.$key == 1)}
									<th class="alignCenter tablesorter-headerUnSorted">{$header}</th>
								{elseif ($sort_flags.$key == 2)}
									<th class="alignCenter tablesorter-headerUnSorted auth_digit" position="{$key + 4}">{$header}</th>
								{elseif ($sort_flags.$key == 3)}
									<th class="alignCenter tablesorter-headerUnSorted auth_char" position="{$key + 4}">{$header}</th>
								{elseif ($sort_flags.$key == 4)}
									<th class="alignCenter tablesorter-headerUnSorted fax_status" position="{$key + 4}">{$header}</th>
								{elseif ($sort_flags.$key == 5)}
									<th class="alignCenter tablesorter-headerUnSorted inbound_sms_status" position="{$key + 4}">{$header}</th>
								{else}
									<th class="remove sorter-false filter-false alignCenter">{$header}</th>
								{/if}
							{/foreach}
						</tr>
					</thead>
					<tbody></tbody>
				</table>
			</div>
			<!-- pager -->
			{$view->element('pager/pager')}
			<input type="hidden" value="{if isset($sortColumn)}{$sortColumn}{/if}" id="hdSortColumnList"/>
			<input type="hidden" value="{if isset($sortType)}{$sortType}{/if}" id="hdSortTypeList"/>
			<input type="hidden" value="{if isset($page)}{$page}{/if}" id="hdPageList"/>
			<input type="hidden" value="{$schedule['T25Inbound']['id']}" id="schedule_id"/>
		</div>
	</div>

<!-- content ends -->
</div>


<!-- 新規登録MODAL START -->
	<div class="modal {*fade*}" id="dialogConditionDownload" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true" data-backdrop="static">
		<div class="modal-dialog" style="width: 700px;">
			<div class="modal-content">
				<!-- Modal Header -->
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">&times;</span><span class="sr-only">Close</span>
					</button>
					<h4 class="modal-title" id="modalDownload"></h4>
				</div>

				<!-- Modal Body -->
				<div class="modal-body">
					<div class="form-group">
					<label class="col-sm-3 control-label">日付</label>
					<div class="col-sm-3">
						<div class="form-group date">
							<input type="text" id="start_date" name="start_date"
								   class="form-control expired datepicker start_date" placeholder="yyyy-mm-dd" readonly aria-invalid="false"/>
							<label class="input-group-btn" for="start_date">
								<span class="btn btn-default ui-datepicker-trigger date_picker_btn" id="date_picker_btn1">
									<span class="glyphicon glyphicon-calendar"></span>
								</span>
							</label>
						</div>
						
					</div>
					<div class="col-sm-1 ptop7" style="text-align:center;">～</div>
					<div class="col-sm-3">
						<div class="form-group date">
							<input type="text" id="end_date" name="end_date"
								   class="form-control expired datepicker end_date" placeholder="yyyy-mm-dd" readonly aria-invalid="false"/>
							<label class="input-group-btn" for="end_date">
								<span class="btn btn-default ui-datepicker-trigger date_picker_btn" id="date_picker_btn2">
									<span class="glyphicon glyphicon-calendar"></span>
								</span>
							</label>
						</div>
					</div>
					<label class="col-sm-3"></label>
					<div class="col-sm-9 txt-desc-date">
						<span class="error-date-start"></span>
						<div class="clearfix"></div>
						<span class="error-date-end"></span>
						<div class="clearfix"></div>
						<span>※日付の最大範囲は31日になります。</span>
					</div>
				</div>
					
				
				</div>

				<!-- Modal Footer -->
				<div class="modal-footer">
					<a href="javascript:void(0);" id="btn_cancel" class="btn btn-default" data-dismiss="modal">閉じる</a>
					{if (isset($id))}
						<a href="javascript:void(0);" id="btn_submit" class="btn btn-primary" action="duplicate">保存</a>
					{else}
						<a href="javascript:void(0);" id="" class="btn btn-primary btnDownload" action="create">ダウンロード</a>
					{/if}

				</div>
			</div>
		</div>
</div>