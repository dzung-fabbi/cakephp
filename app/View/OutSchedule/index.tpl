{html func=script url='jquery.validate'}
{html func=css path='outschedule/dhtmlxscheduler'}
{html func=css path='outschedule/my_dhtmlxscheduler'}
{html func=css path='outschedule/style'}
{html func=css path='common/jquery-ui.css'}

{html func=script url='pager'}
{html func=script url='dhtmlxscheduler'}
{html func=script url='dhtmlxscheduler_timeline'}
{html func=script url='dhtmlxscheduler_tooltip'}
{html func=script url='view/outschedule/index'}
{html func=script url='view/outschedule/init_timeline'}
{html func=script url='view/outschedule/create'}
{html func=script url='view/outschedule/outschedule'}
{html func=script url='view/outschedule/popup_recall'}


{literal}
<script>
	var min_call_time = {/literal}{$min_distance_call_time}{literal};
</script>
{/literal}

<div class="col-lg-10 col-sm-10" id="content">
<!-- content starts -->

	<div id="alert alert-success schedule_error" class="error"></div>
	{if $mode eq "success"}
		<div class="alert alert-success fade in">
			<button type="button" class="close">×</button><p>保存しました。</p>
		</div>
	{/if}
	{if $mode eq "delete"}
		<div class="alert alert-success fade in">
			<button type="button" class="close">×</button><p>{$del_count}件削除しました。</p> <!-- 20160311 Edit by Giang : #6695 - display the record quantity has been deleted -->
		</div>
	{/if}
	<div class="alert alert-success fade in" id="outschedule-success-message" style="display:none;">
		<button type="button" class="close">×</button><p></p>
	</div>
	<div class="alert alert-danger fade in" id="outschedule-error-message" style="display:none;">
		<button type="button" class="close">×</button><p></p>
	</div>
	<div class="row">
		<div class="form-group col-md-9">
			{if $create_flag eq true}
				<a href="javascript:void(0);" title="新規登録" data-toggle="tooltip" class="btn btn-primary" id="create_schedule">新規登録</a>
			{/if}
			{if $delete_flag eq true}
				<a href="javascript:void(0);" title="選択項目を削除" data-toggle="tooltip" class="btn btn-default" id="btn_delete">選択項目を削除</a>
			{/if}
			{if $download_flag eq true}
				<select id="select_type_download" data-rel="NotSearchable">
					<option value="select_download">選択項目のDL</option>
					<option value="download_uncalled">未発信</option>
					<option value="download_all_log">全ての発信履歴</option>
					<option value="download_ans_log">有効回答のみ</option>
				</select>
			{/if}
		</div>
		<div class="form-group col-md-2 pull-right">
			<select id="schedule_reload" class="operation_time_start" style="width: 120px;" data-rel="NotSearchable">
				{foreach from=$schedule_time_reload item=values}
					<option value="{$values.M90PulldownCode.item_code}" {if isset($time_reload) && $time_reload eq $values.M90PulldownCode.item_code}selected{/if}>{$values.M90PulldownCode.item_name}</option>
				{/foreach}
			</select> 毎自動更新
		</div>
	</div>

	<div class="rules_div" style="margin-left: -1px;">
		<form id="T20OutScheduleIndexForm" method="post" accept-charset="utf-8" enctype="multipart/form-data">
			<table id="scheduleTable" class="table table-striped table-bordered tablesorter" style="margin-top: 8px;">
				<colgroup>
					{if $delete_flag}
						<col width="2%">
					{/if}
					<col width="2%">
					<col width="13%">
					<col width="7%">
					<col width="8%">
					<col width="14%">
					<col width="14%">
					<col width="6%">
					<col width="6%">
					<col width="10%">
					<col width="6%">
					<col width="10%">
				</colgroup>
				<thead class="head">
				<tr>
					{if $delete_flag}
						<th class="remove sorter-false filter-false alignCenter">
							<input type="checkbox" id="bundleCheckbox" data-checkbox="cbSelect">
							<label for="bundleCheckbox" class="bundleCheckbox"></label>
						</th>
					{/if}
					<th class="alignCenter tablesorter-headerUnSorted">NO</th>
					<th class="alignCenter tablesorter-headerUnSorted">スケジュール名</th>
					<th class="alignCenter tablesorter-headerDesc">発信日</th>
					<th class="alignCenter tablesorter-headerUnSorted">発信時間</th>
					<th class="alignCenter tablesorter-headerUnSorted">テンプレート</th>
					<th class="alignCenter tablesorter-headerUnSorted">発信リスト</th>
					<th class="alignCenter tablesorter-headerUnSorted">リスト数</th>
					<th class="alignCenter tablesorter-headerUnSorted">発信件数</th>
					<th class="alignCenter tablesorter-headerUnSorted">作成日時</th>
					<th class="alignCenter tablesorter-headerUnSorted">作成者</th>
					<th class="remove sorter-false filter-false alignCenter">アクション</th>
				</tr>
				</thead>
				<tbody class="inner_table">
				</tbody>
			</table>
			<div>
				<div style="float: left; padding: 5px;" class="textDefault">
					<div style="float: left;">
						<span style="width: 12px; height: 12px; background: #b4e3f2; float: left;margin-left: 2px;margin-right: 2px;margin-top: 3px;"></span>
						<b style="margin-right: 10px;">実行中</b>
					</div>
					<div style="float: left;">
						<span style="width: 12px; height: 12px; background: #f2d6b1; float: left;margin-left: 2px;margin-right: 2px;margin-top: 3px;"></span>
						<b style="margin-right: 10px;">停止中</b>
					</div>
					<div style="float: left;">
						<span style="width: 12px; height: 12px; background: #ed9191; float: left;margin-left: 2px;margin-right: 2px;margin-top: 3px;"></span>
						<b style="margin-right: 10px;">手動停止</b>
					</div>
					<div style="float: left;">
						<span style="width: 12px; height: 12px; background: #FBF483; float: left;margin-left: 2px;margin-right: 2px;margin-top: 3px;"></span>
						<b style="margin-right: 10px;">停止</b>
					</div>
					<div style="float: left;">
						<span style="width: 12px; height: 12px; background: #D1F18E; float: left;margin-left: 2px;margin-right: 2px;margin-top: 3px;"></span>
						<b style="margin-right: 10px;">リダイヤル待ち</b>
					</div>
					<div style="float: left;">
						<span style="width: 12px; height: 12px; background: #c3c3c3; float: left;margin-left: 2px;margin-right: 2px;margin-top: 3px;"></span>
						<b style="margin-right: 10px;">終了</b>
					</div>
				</div>
				<!-- pager -->
				{$view->element('pager/pager')}
			</div>
			<input type="hidden" value="{if isset($sortColumn)}{$sortColumn}{/if}" id="hdSortColumnSchedule"/>
			<input type="hidden" value="{if isset($sortType)}{$sortType}{/if}" id="hdSortTypeSchedule"/>
			<input type="hidden" value="{if isset($page)}{$page}{/if}" id="hdPageSchedule"/>

			<input type="hidden" value="{$min_distance_call_time}" id="hdMinDistanceCallTime">
		</form>
	</div>

	<div id="form_container"></div>
<!-- content ends -->
</div>
