<form class="form-horizontal" role="form" id="OutSchedule" method="post" accept-charset="utf-8" novalidate="novalidate">
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
						<h4 class="modal-title" id="modalAddScheduleLabel">
							{if ($edit_flag == 1)}
								スケジュール編集
							{else}
								新規登録
							{/if}
						</h4>
					</div>

					<!-- Modal Body -->
					<div class="modal-body">
						{if ($msg_edit != '')}
							<label class="temp_finish_alert">{$msg_edit}</label>
						{/if}
						<div class="form-group">
							<label class="col-sm-3 control-label">スケジュール名</label>
							<div class="col-sm-7">
								<input type="text" id="ipScheduleName" maxlength="50" name="data[T20OutSchedule][schedule_name]" value="{if (($edit_flag == 1) && isset($data))}{$data.T20OutSchedule.schedule_name}{/if}" class="form-control" placeholder="スケジュール名">
							</div>
						</div>
						<!-- 発信日DESIGN START-->
						<div class="form-group">
							<label class="col-sm-3 control-label">発信日</label>
							<div class="col-sm-7">
								<div class="form-group date">
									<input name="data[T20OutSchedule][create_date]" class="form-control pull-left create_date" id="create_date" aria-invalid="false" type="text" readonly="" placeholder="YYYY-MM-DD" value="{if isset($data.T20OutSchedule.create_date)}{$data.T20OutSchedule.create_date|date_format:'%Y-%m-%d'}{/if}">
									<label class="input-group-btn" for="create_date">
										<span class="btn btn-default ui-datepicker-trigger" id="date_picker_btn">
											<span class="glyphicon glyphicon-calendar"></span>
										</span>
									</label>
								</div>
								<div><label id="create_date-error" class="error" for="create_date"></label></div>
							</div>
						</div>
						<!-- 発信日DESIGN END-->
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
								<input type="hidden" id="hdCallTimes" name="data[T20OutSchedule][call_times]" value='{if isset($data.T20OutSchedule.call_times)}{$data.T20OutSchedule.call_times}{/if}'>
							</div>
						</div>
						<div class="form-group">
							<label class="col-sm-3 control-label">番号通知</label>
							<div class="form-group col-sm-7">
								<select id="call_type" name="data[T20OutSchedule][call_type]" class="form-control">
									{foreach from=$call_type item=values}
										<option value="{$values.M90PulldownCode.item_code}" {if isset($data) && $data.T20OutSchedule.call_type eq $values.M90PulldownCode.item_code}selected{/if}>{$values.M90PulldownCode.item_name}</option>
									{/foreach}
								</select>
							</div>
						</div>
						<div class="form-group">
							<label class="col-sm-3 control-label">発信番号</label>
							<div class="form-group col-sm-7">
								<select id="external_number" name="data[T20OutSchedule][external_number]" class="form-control">
									<option value=""></option>
									{foreach from=$external_number item=values}
										<option value="{$values.M06CompanyExternal.external_number}" {if isset($data) && $data.T20OutSchedule.external_number eq $values.M06CompanyExternal.external_number}selected{/if}>{$values.M06CompanyExternal.external_number}</option>
									{/foreach}
								</select>
							</div>
						</div>
						<div class="form-group">
							<label class="col-sm-3 control-label">発信NGリスト</label>
							<div class="form-group col-sm-7">
								<select id="list_ng_id" name="data[T20OutSchedule][list_ng_id]" class="form-control">
									<option value=""></option>
									{foreach from=$list_ngs item=values}
										<option value="{$values.T14OutgoingNgList.id}" {if isset($data) && $data.T20OutSchedule.list_ng_id eq $values.T14OutgoingNgList.id}selected{/if}>{$values.T14OutgoingNgList.list_name}</option>
									{/foreach}
								</select>
							</div>
						</div>
						<div class="form-group">
							<label class="col-sm-3 control-label">テンプレート</label>
							<div class="form-group col-sm-7">
								<select id="template_id" name="data[T20OutSchedule][template_id]" class="form-control">
									<option value=""></option>
									{foreach from=$templates item=values}
										<option value="{$values.T30Template.id}" {if isset($data) && $data.T20OutSchedule.template_id eq $values.T30Template.id}selected{/if}>{$values.T30Template.template_name}</option>
									{/foreach}
								</select>
							</div>
						</div>
						<div class="form-group">
							<label class="col-sm-3 control-label">発信リスト</label>
							<div class="form-group col-sm-7">
								<select id="list_id" name="data[T20OutSchedule][list_id]" class="form-control">
									<option value=""></option>
									{foreach from=$lists item=values}
										<option tel_total="{$values.T10CallList.tel_total}" value="{$values.T10CallList.id}" {if isset($data) && $data.T20OutSchedule.list_id eq $values.T10CallList.id}selected{/if}>{if $values.T10CallList.list_test_flag eq "1"}<font color='red'>(テスト){/if}{$values.T10CallList.list_name}</option>
									{/foreach}
								</select>
							</div>
						</div>
						<div class="form-group">
							<label class="col-sm-3 control-label">ch数</label>
							<div class="form-group col-sm-7">
								<select id="proc_num" name="data[T20OutSchedule][proc_num]" class="form-control">
									<option value=""></option>
									{foreach from=$proc_num item=values}
										<option value="{$values.M90PulldownCode.item_code}" {if isset($data) && $data.T20OutSchedule.proc_num eq $values.M90PulldownCode.item_code}selected{/if}>{$values.M90PulldownCode.item_name}</option>
									{/foreach}
								</select>
							</div>
						</div>
						<div class="form-group">
							<label class="col-sm-3 control-label">呼び出し時間</label>
							<div class="form-group col-sm-7">
								<select id="dial_wait_time" name="data[T20OutSchedule][dial_wait_time]" class="form-control">
									{foreach from=$dial_wait_time item=values}
										<option value="{$values.M90PulldownCode.item_code}" {if isset($data) && $data.T20OutSchedule.dial_wait_time eq $values.M90PulldownCode.item_code}selected{/if}>{$values.M90PulldownCode.item_name}</option>
									{/foreach}
								</select>
							</div>
						</div>
						<div class="form-group">
							<label class="col-sm-3 control-label">回答待ち時間</label>
							<div class="form-group col-sm-7">
								<select id="ans_timeout" name="data[T20OutSchedule][ans_timeout]" class="form-control">
									{foreach from=$ans_timeout item=values}
										<option value="{$values.M90PulldownCode.item_code}" {if isset($data) && $data.T20OutSchedule.ans_timeout eq $values.M90PulldownCode.item_code}selected{/if}>{$values.M90PulldownCode.item_name}</option>
									{/foreach}
								</select>
							</div>
						</div>
						<div class="form-group">
							<label class="col-sm-3 control-label">自動停止有効回答数</label>
							<div class="form-group col-sm-7">
								<input type="text" id="term_valid_count" maxlength="5" name="data[T20OutSchedule][term_valid_count]" value="{if isset($data)}{$data.T20OutSchedule.term_valid_count}{/if}" class="form-control">
							</div>
						</div>
						<div class="form-group">
							<label class="col-sm-3 control-label">自動停止接続数</label>
							<div class="form-group col-sm-7">
								<input type="text" id="term_connect_count" maxlength="5" name="data[T20OutSchedule][term_connect_count]" value="{if isset($data)}{$data.T20OutSchedule.term_connect_count}{/if}" class="form-control">
							</div>
						</div>
						<div class="form-group">
							<label class="col-sm-3 control-label">リダイヤル</label>
							<div class="form-group col-sm-7">
								<select id="recall" name="data[T20OutSchedule][recall]" class="form-control">
									{foreach from=$recall item=values}
										<option value="{$values.M90PulldownCode.item_code}" {if isset($data) && $data.T20OutSchedule.recall eq $values.M90PulldownCode.item_code}selected{/if}>{$values.M90PulldownCode.item_name}</option>
									{/foreach}
								</select>
							</div>
						</div>
						<div class="form-group">
							<label class="col-sm-3 control-label">リダイヤル間隔(分)</label>
							<div class="form-group col-sm-7">
								{*
								<select id="recall_time" name="data[T20OutSchedule][recall_time]" class="form-control"
									{if !isset($data) || $data.T20OutSchedule.recall eq 0}disabled{/if}>
									<option value=""></option>
									{foreach from=$recall_time item=values}
										<option value="{$values.M90PulldownCode.item_code}" {if isset($data) && $data.T20OutSchedule.recall_time eq $values.M90PulldownCode.item_code}selected{/if}>{$values.M90PulldownCode.item_name}</option>
									{/foreach}
								</select>
								*}
								<input type="text" id="recall_time" maxlength="3" name="data[T20OutSchedule][recall_time]" value="{if isset($data)}{$data.T20OutSchedule.recall_time}{/if}" class="form-control" {if !isset($data) || $data.T20OutSchedule.recall eq 0}disabled{/if}>
							</div>
						</div>
					</div>

					<!-- Modal Footer -->
					<div class="modal-footer">
						{if ($call_right_away_flag)}
							<div class="pull-left">
								<button type="button" class="btn btn-primary btnSubmit" id="btnCallPopup" action="popup">即時発信</button>
							</div>
						{/if}
						<div class="pull-right">
							
							<button type="button" class="btn btn-default" id="resetBtn" data-dismiss="modal" >閉じる</button>
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
						<h4 class="modal-title" id="modalCallRightAwayLabel">
							発信確認
						</h4>
					</div>

					<!-- Modal Body -->
					<div class="modal-body">
						<div class="form-group">
							<label class="col-sm-12 control-label temp_finish_alert" id="dialog_end_call-error" for="dialog_end_call"></label>
						</div>

						<div class="form-group">
							<label class="col-sm-3 control-label">発信開始時間</label>
							<div class="form-group col-sm-7">
								<label class="col-sm-5 control-label dialog-start-call"></label>
							</div>
						</div>

						<div class="form-group">
							<label class="col-sm-3 control-label">発信終了時間</label>
							<div class="form-group col-sm-7">
								<select id="dialog_hour_end_call" name="data[T20OutSchedule][dialog_end_call]" class="form-control pull-left dialog_end_call">
									<option value=""></option>
									{foreach from=$outgoing_time item=values}
										<option value="{$values.M90PulldownCode.item_code}">{$values.M90PulldownCode.item_name}</option>
									{/foreach}
								</select>
								<label class="control-label pull-left">&nbsp;：&nbsp;</label>
								<select id="dialog_minute_end_call" name="data[T20OutSchedule][dialog_end_call]" class="form-control pull-left dialog_end_call">
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
										<div class="dhx_cal_header">
										</div>
										<div class="dhx_cal_data">
										</div>
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
							<button type="button" class="btn btn-primary btnSubmit" id="btnCall" action="call">発信</button> 
						</div>
					</div>
				</div>
			</div>
		</div>
		<!-- CALL RIGHT AWAY MODAL END -->
	</div>

	<div style="display:none;">
		<input type="hidden" id="id" class="hdId" name="data[T20OutSchedule][id]" value="{if (isset($id) && $edit_flag == 1)}{$id}{/if}" />
		<input type="hidden" id="hdCreateDate" name="data[T20OutSchedule][create_date2]" value="{if isset($data.T20OutSchedule.create_date)}{$data.T20OutSchedule.create_date|date_format:'%Y-%m-%d'}{/if}">
		<input type="hidden" id="hdCallTimes2" name="data[T20OutSchedule][call_times2]" value="">
		<input type="hidden" id="disable_input_flag" name="data[T20OutSchedule][disable_input_flag]" value="{if (isset($disable_input_flag))}{$disable_input_flag}{/if}">
	</div>
</form>