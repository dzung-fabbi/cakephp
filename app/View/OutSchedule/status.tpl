{html func=script url='jquery.validate'}
{html func=css path='outschedule/dhtmlxscheduler'}
{html func=css path='outschedule/my_dhtmlxscheduler'}
{html func=css path='common/jquery-ui.css'}
{html func=css path='outschedule/status'}

{html func=script url='dhtmlxscheduler'}
{html func=script url='dhtmlxscheduler_timeline'}
{html func=script url='dhtmlxscheduler_tooltip'}
{html func=script url='Chart'}
{html func=script url='view/outschedule/init_timeline'}
{html func=script url='view/outschedule/status'}
{html func=script url='view/outschedule/popup_recall'}

{literal}
<script>
	var min_call_time = {/literal}{$min_distance_call_time}{literal};
</script>
{/literal}

<div id="audio-player" style="display: none;">
	<audio controls class="audio_plugin" src="" type="audio/x-wav"></audio>
</div>

<div class="col-lg-10 col-sm-10" id="content">
	<!-- content starts -->
	{$view->element('outschedule/status_view')}
</div>

<div class="col-lg-10 col-sm-10">
	{$width_table = 165 + 150 + 150 + 150}
	{for $i=1 to $headers|count}
		{$width_table = $width_table + 80}
	{/for}

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
					<form id="T20OutScheduleDetailForm" method="post" accept-charset="utf-8" enctype="multipart/form-data">
						<div style="width: {$width_table}px; max-width: 1250px; overflow-x: auto; overflow-y:auto;max-height: 77vh;">
							<table id="scheduleDetailTable" class="tablesorter" style="margin-top: 8px; width: {$width_table}px;">
								<!--colgroup>
									<col width="10%">
									<col width="15.5%">
									<col width="15.5%">
									<col width="15.5%">
									<col width="11%">
									{for $i=1 to $headers|count}
										<col width="6.5%">
									{/for}
								</colgroup-->
								<thead class="head">
								<tr>
									<th class="alignCenter tablesorter-headerDesc" style="min-width:165px;">発信日時</th>
									<th class="alignCenter tablesorter-headerUnSorted" style="min-width:150px;">発信先</th>
									<th class="alignCenter tablesorter-headerUnSorted" style="min-width:150px;">接続時間</th>
{*									{if ($have_tran_ques)}
										<th class="alignCenter tablesorter-headerUnSorted" style="min-width:150px;">転送時間</th>
									{/if}*}
									<th id="sort_transfer" class="alignCenter tablesorter-headerUnSorted" position="3" style="min-wid-th:150px;">ステータス</th>
									{foreach from=$headers key=key item=header}
										{if ($sort_flags.$key == 1)}
											<th class="alignCenter tablesorter-headerUnSorted" style="min-width:80px;">{$header}</th>
										{elseif ($sort_flags.$key == 2)}
											<th class="alignCenter tablesorter-headerUnSorted sort_select" position="{$key + 4}" style="min-width:80px;">{$header}</th>
										{elseif ($sort_flags.$key == 3)}
											<th class="alignCenter tablesorter-headerUnSorted auth_char" position="{$key + 4}" style="min-width:80px;">{$header}</th>
										{else}
											<th class="remove sorter-false filter-false alignCenter" style="min-width:80px;">{$header}</th>
										{/if}
									{/foreach}
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