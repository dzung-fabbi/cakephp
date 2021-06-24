{html func=script url='jquery.validate'}
{html func=css path='outschedule/dhtmlxscheduler'}
{html func=css path='smsschedule/my_dhtmlxscheduler'}
{html func=css path='common/jquery-ui.css'}
{html func=css path='smsschedule/status'}

{html func=script url='dhtmlxscheduler'}
{html func=script url='dhtmlxscheduler_timeline'}
{html func=script url='dhtmlxscheduler_tooltip'}
{html func=script url='view/smsschedule/init_timeline'}
{html func=script url='view/smsschedule/status'}
{html func=script url='view/smsschedule/popup_resend'}

{literal}
<script>
	var min_call_time = {/literal}{$min_distance_send_time}{literal};
	MIN_DISTANCE_CALL_TIME = min_call_time * 1000;
</script>
{/literal}

<div id="audio-player" style="display: none;">
	<audio controls class="audio_plugin" src="" type="audio/x-wav"></audio>
</div>

<div class="col-lg-10 col-sm-10" id="content">
	<!-- content starts -->
	{$view->element('smsschedule/status_view')}
</div>

<div class="col-lg-10 col-sm-10">
	{$width_table = 180 + 150 + 150 + 150}

	<div class="modal fade" id="dialog_schedule_detail" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true" data-backdrop="static" style="overflow-y:hidden;">
		<div class="modal-dialog" style="width: {$width_table + 50}px; max-width: 1300px;">
			<div class="modal-content">
				<!-- Modal Header -->
				<div class="modal-header">
					<button type="button" class="close"	data-dismiss="modal">
						<span aria-hidden="true">&times;</span>
						<span class="sr-only">閉じる</span>
					</button>
					<h4 class="modal-title" id="myModalLabel">
						詳細
					</h4>
				</div>
				<div class="rules_div" style="margin-left: 25px;">
					<form id="T200SmsSendScheduleDetailForm" method="post" accept-charset="utf-8" enctype="multipart/form-data">
						<div style="width: {$width_table + 25}px; max-width: 1250px; overflow-x: auto; overflow-y:auto;max-height: 77vh;">
							<table id="scheduleDetailTable" class="tablesorter" style="margin-top: 8px; width: {$width_table}px;">
								<thead class="head">
								<tr>
									<th class="alignCenter tablesorter-headerDesc" style="min-width:180px;">送信日時</th>
									<th class="alignCenter tablesorter-headerUnSorted" style="min-width:150px;">電話番号</th>
									<th class="alignCenter tablesorter-headerUnSorted" id="search_by_carrier" position="2" style="min-width:150px;">携帯キャリア</th>
									<th class="alignCenter tablesorter-headerUnSorted" id="search_by_result" position="3" style="min-width:150px;">到達結果</th>
								</tr>
								</thead>
								<tbody class="inner_table">
								</tbody>
							</table>
						</div>
						<div>
							<!-- pager -->
							{$view->element('pager/pager')}
						</div>
						<input type="hidden" value="{if isset($sortColumn)}{$sortColumn}{/if}" id="hdSortColumnScheduleDetail"/>
						<input type="hidden" value="{if isset($sortType)}{$sortType}{/if}" id="hdSortTypeScheduleDetail"/>
						<input type="hidden" value="{if isset($page)}{$page}{/if}" id="hdPageScheduleDetail"/>
					</form>
				</div>
			</div>
		</div>
	</div>
</div>

<div id="form_container"></div>