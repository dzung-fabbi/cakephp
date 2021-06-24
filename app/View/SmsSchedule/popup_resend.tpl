<!-- 新規登録MODAL START -->
<div class="modal {*fade*}" id="modalEditSchedule" tabindex="-1" role="dialog" aria-labelledby="modalEditScheduleLabel" aria-hidden="true" data-backdrop="static">
	<input type="hidden" id="schedule_id" value='{if isset($schedule_id)}{$schedule_id}{/if}'>
	<div class="modal-dialog">
		<div class="modal-content">
			<!-- Modal Header -->
			<div class="modal-header">
				<button type="button" class="close"　 data-dismiss="modal">
					<span aria-hidden="true">&times;</span>
					<span class="sr-only">閉じる</span>
				</button>
				<h4 class="modal-title" id="modalEditScheduleLabel">{$title_btn}</h4>
			</div>

			<!-- Modal Body -->
			<div class="modal-body">
				<div class="form-group">
					<label class="col-sm-12 control-label temp_finish_alert" id="dialog_send-error"></label>
				</div>
				<div class="form-group">
					<label class="col-sm-3 control-label">送信開始時間</label>
					<div class="col-sm-7">
						<p class="time_now"></p>
					</div>
				</div>

				<div class="form-group">
					<label class="col-sm-3 control-label">送信終了時間</label>
					<div class="col-sm-7">
						<div class="row">
							<select name="end_hour" id="end_hour" class="set_time_end">
								<option value=""></option>
								{foreach from=$outgoing_time item=values}
									<option value="{$values.M90PulldownCode.item_code}">{$values.M90PulldownCode.item_name}</option>
								{/foreach}
							</select>
							:
							<select name="end_minute" id="end_minute" class="set_time_end">
								<option value=""></option>
								{for $i=0 to 59}
									<option value="{if ($i < 10)}0{$i}{else}{$i}{/if}">{if ($i < 10)}0{$i}{else}{$i}{/if}</option>
								{/for}
							</select>
						</div>
					</div>
				</div>

				<div class="form-group">
					<label class="col-sm-3 control-label">時間帯</label>
					<div class="col-sm-7">
						<div class="timeline_container">
							<div id="scheduler_here" class="dhx_cal_container">
								<div class="dhx_cal_navline">
									<div class="dhx_cal_date"></div>
								</div>
								<div class="dhx_cal_header">
								</div>
								<div class="dhx_cal_data">
								</div>
							</div>
							<div class="over_timeline_disabled"></div>
						</div>
						<input type="hidden" id="hdSendTimes3" name="data[T200SmsSendSchedule][send_times]" value='{if isset($data.T200SmsSendSchedule.send_times)}{$data.T200SmsSendSchedule.send_times}{/if}'>
					</div>
				</div>
				<div class="row"></div>
			</div>

			<!-- Modal Footer -->
			<div class="modal-footer">
				<div class="pull-right">
					<div class="btn btn-default" id="resetBtn" data-dismiss="modal" >閉じる</div>
					<div class="btn btn-primary" id="btnUpdateSchedule" action="{$action}" screen="{$screen}">{$title_btn}</div>
				</div>
			</div>
		</div>
	</div>
</div>
<!-- 新規登録MODAL END-->