<form class="form-horizontal" role="form" id="SmsSchedule" method="post" accept-charset="utf-8" novalidate="novalidate">
	<div>
		<!-- 新規登録MODAL START -->
		<div class="modal {*fade*}" id="modalAddSchedule" tabindex="-1" role="dialog" aria-labelledby="modalAddScheduleLabel" aria-hidden="true" data-backdrop="static">
			<div class="modal-dialog">
				<div class="modal-content">
					<!-- Modal Header -->
					<div class="modal-header">
						<button type="button" class="close"
						   data-dismiss="modal">
							   <span aria-hidden="true">&times;</span>
							   <span class="sr-only">Close</span>
						</button>
						<h4 class="modal-title" id="modalAddScheduleLabel"></h4>
					</div>

					<!-- Modal Body -->
					<div class="modal-body">
						{if ($msg_edit != '')}
							<label class="temp_finish_alert">{$msg_edit}</label>
						{/if}
						<div class="form-group">
							<label class="col-sm-3 control-label">スケジュール名</label>
							<div class="col-sm-7">
								<input
									type="text"
									id="schedule_name"
									name="data[T200SmsSendSchedule][schedule_name]"
									data-rule-maxlength="64"
									data-msg-maxlength="スケジュール名は64桁以下で入力してください。"
									value="{if isset($data.T200SmsSendSchedule.schedule_name)}{$data.T200SmsSendSchedule.schedule_name}{/if}"
									class="form-control" placeholder="スケジュール名">
							</div>
						</div>
						<!-- 送信日DESIGN START-->
						<div class="form-group">
							<label class="col-sm-3 control-label">送信日</label>
							<div class="col-sm-7">
								<div class="form-group date">
									<input
										type="text"
										id="create_date"
										name="data[T200SmsSendSchedule][create_date]"
										class="form-control pull-left create_date"
										aria-invalid="false" readonly="" placeholder="YYYY-MM-DD"
										value="{if isset($data.T200SmsSendSchedule.create_date)}{$data.T200SmsSendSchedule.create_date|date_format:'%Y-%m-%d'}{/if}">
									<label class="input-group-btn" for="create_date">
										<span class="btn btn-default ui-datepicker-trigger" id="date_picker_btn">
											<span class="glyphicon glyphicon-calendar"></span>
										</span>
									</label>
								</div>
								<div><label id="create_date-error" class="error" for="create_date"></label></div>
							</div>
						</div>
						<!-- 送信日DESIGN END-->
						<div class="form-group">
							<label class="col-sm-3 control-label">時間帯</label>
							<div class="col-sm-7">
								<div class="timeline_container">
									<div id="scheduler_here" class="dhx_cal_container">
										<div class="dhx_cal_navline">
											<div class="dhx_cal_date"></div>
										</div>
										<div class="dhx_cal_header"></div>
										<div class="dhx_cal_data"></div>
									</div>
									<div class="over_timeline_disabled"></div>
								</div>
								<input
									type="hidden"
									id="hdCallTimes"
									name="data[T200SmsSendSchedule][call_times]"
									value='{if isset($data.T200SmsSendSchedule.call_times)}{$data.T200SmsSendSchedule.call_times}{/if}'>
							</div>
						</div>

						<div class="form-group">
							<label class="col-sm-3 control-label">通知番号</label>
							<div class="form-group col-sm-7">
								<select id="service_id" name="data[T200SmsSendSchedule][display_number]" class="form-control">
									<option value=""></option>
									{foreach from=$display_number item=values}
										<option value="{$values.M08SmsApiInfo.display_number}"
											{if isset($data) && $data.T200SmsSendSchedule.display_number eq $values.M08SmsApiInfo.display_number}
												selected
											{/if}>
											{$values.M08SmsApiInfo.display_number}
											 {* API_v2は、その旨を電話番号の後ろに付与する *}
											{if $values.M08SmsApiInfo.api_id eq $smarty.const.SMS_API_V2_VALUE }
											{$smarty.const.SMS_API_V2_AFTER_TELL_STRING}
											{/if}
										</option>
									{/foreach}
								</select>
							</div>
						</div>

						<div class="form-group">
							<label class="col-sm-3 control-label">テンプレート</label>
							<div class="form-group col-sm-7">
								<select id="template_id" name="data[T200SmsSendSchedule][template_id]" class="form-control">
									<option value=""></option>
									{foreach from=$templates item=values}
										<option value="{$values.T300SmsTemplate.id}"
											{if isset($data) && $data.T200SmsSendSchedule.template_id eq $values.T300SmsTemplate.id}
												selected
											{/if}>
											{$values.T300SmsTemplate.template_name}
										</option>
									{/foreach}
								</select>
							</div>
						</div>
						<div class="form-group">
							<label class="col-sm-3 control-label">送信リスト</label>
							<div class="form-group col-sm-7">
								<select id="list_id" name="data[T200SmsSendSchedule][list_id]" class="form-control">
									<option value=""></option>
									{foreach from=$lists item=values}
										<option tel_total="{$values.T100SmsSendList.tel_total}" value="{$values.T100SmsSendList.id}"
											{if isset($data) && $data.T200SmsSendSchedule.list_id eq $values.T100SmsSendList.id}
												selected
											{/if}>
											{if $values.T100SmsSendList.list_test_flag eq "1"}<font color='red'>(テスト){/if}
											{$values.T100SmsSendList.list_name}
										</option>
									{/foreach}
								</select>
							</div>
						</div>
						{if ($accept_consent_flag.M02Company.accept_consent_flag == "1")}
							<!-- #8298 add consentday -->
							<div class="form-group">
								<label class="col-sm-3 control-label">履歴判定</label>
								<div class="form-group col-sm-7 ptop7">
								  <!--
								  <input type="checkbox" id="consent_flag" name="data[T200SmsSendSchedule][consent_flag]" class="form-control" value="1" {if $data.T200SmsSendSchedule.consent_flag eq '1'}checked{/if}>
								  -->
								  <input type="checkbox" id="consent_flag" name="data[T200SmsSendSchedule][consent_flag]" class="form-control" {if $data.T200SmsSendSchedule.consent_flag eq '1'}checked{/if}>
								  <label for="consent_flag"></label>
								</div>
							</div>
						{/if}
					</div>

					<!-- Modal Footer -->
					<div class="modal-footer">
						{if ($call_right_away_flag)}
							<div class="pull-left">
								<button type="button" class="btn btn-primary btnSubmit" id="btnCallPopup" action="popup">即時送信</button>
							</div>
						{/if}
						<div class="pull-right">
							<button type="button" class="btn btn-default" id="resetBtn" data-dismiss="modal">閉じる</button>
							{if ($edit_flag == 1)}
								{if (!$disable_input_flag)}
									<button type="button" class="btn btn-primary btnSubmit" id="btnUpdate" action="update">更新</button>
								{/if}
							{else}
								{if (isset($id))}
									<button type="button" class="btn btn-primary btnSubmit" id="btnDuplicate" action="duplicate">保存</button>
								{else}
									<button type="button" class="btn btn-primary btnSubmit" id="btnCreate" action="create">保存</button>
								{/if}
							{/if}
						</div>
					</div>
				</div>
			</div>
		</div>
		<!-- 新規登録MODAL END-->
	</div>

	<div>
		<!-- CALL RIGHT AWAY MODAL START -->
		<div class="modal {*fade*}" id="modalCallRightAway" tabindex="-1" role="dialog" aria-labelledby="modalCallRightAwayLabel" aria-hidden="true" data-backdrop="static">
			<div class="modal-dialog">
				<div class="modal-content">
					<!-- Modal Header -->
					<div class="modal-header">
						<button type="button" class="close" data-dismiss="modal">
							<span aria-hidden="true">&times;</span>
							<span class="sr-only">Close</span>
						</button>
						<h4 class="modal-title" id="modalCallRightAwayLabel">即時送信確認</h4>
					</div>

					<!-- Modal Body -->
					<div class="modal-body">
						<div class="form-group">
							<label class="col-sm-12 control-label temp_finish_alert" id="dialog_end_call-error" for="dialog_end_call"></label>
						</div>

						<div class="form-group">
							<label class="col-sm-3 control-label">送信開始時間</label>
							<div class="form-group col-sm-7">
								<label class="col-sm-5 control-label dialog-start-call"></label>
							</div>
						</div>

						<div class="form-group">
							<label class="col-sm-3 control-label">送信終了時間</label>
							<div class="form-group col-sm-7">
								<select id="dialog_hour_end_call" name="data[T200SmsSendSchedule][dialog_end_call]" class="form-control pull-left dialog_end_call">
									<option value=""></option>
									{foreach from=$outgoing_time item=values}
										<option value="{$values.M90PulldownCode.item_code}">{$values.M90PulldownCode.item_name}</option>
									{/foreach}
								</select>
								<label class="control-label pull-left">&nbsp;：&nbsp;</label>
								<select id="dialog_minute_end_call" name="data[T200SmsSendSchedule][dialog_end_call]" class="form-control pull-left dialog_end_call">
									<option value=""></option>
									{for $i=0 to 59}
										<option value="{if ($i < 10)}0{$i}{else}{$i}{/if}">{if ($i < 10)}0{$i}{else}{$i}{/if}</option>
									{/for}
								</select>
							</div>
						</div>

						<div class="form-group">
							<label class="col-sm-3 control-label">時間帯</label>
							<div class="col-sm-8">
								<div class="timeline_container">
									<div id="scheduler_here2" class="dhx_cal_container">
										<div class="dhx_cal_navline">
											<div class="dhx_cal_date"></div>
										</div>
										<div class="dhx_cal_header"></div>
										<div class="dhx_cal_data"></div>
									</div>
									<div class="over_timeline_disabled"></div>
								</div>
							</div>
						</div>
					</div>

					<!-- Modal Footer -->
					<div class="modal-footer">
						<div class="pull-right">
							<button type="button" class="btn btn-default" id="btn_cancel" data-dismiss="modal">閉じる</button>
							<button type="button" class="btn btn-primary btnSubmit" id="btnCall" action="call">送信</button>
						</div>
					</div>
				</div>
			</div>
		</div>
		<!-- CALL RIGHT AWAY MODAL END -->
	</div>

	<div style="display:none;">
		<input type="hidden" id="id" class="hdId" name="data[T200SmsSendSchedule][id]" value="{if (isset($id) && $edit_flag == 1)}{$id}{/if}" />
		<input type="hidden" id="hdCreateDate" name="data[T200SmsSendSchedule][create_date2]"
			value="{if isset($data.T200SmsSendSchedule.create_date)}{$data.T200SmsSendSchedule.create_date|date_format:'%Y-%m-%d'}{/if}">
		<input type="hidden" id="hdCallTimes2" name="data[T200SmsSendSchedule][call_times2]" value="">
		<input type="hidden" id="disable_input_flag" name="data[T200SmsSendSchedule][disable_input_flag]" value="{if (isset($disable_input_flag))}{$disable_input_flag}{/if}">
	</div>
</form>