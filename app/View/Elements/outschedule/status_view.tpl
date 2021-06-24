<form id="T20OutScheduleIndexForm">
	<input type="hidden" name="schedule_id" id="schedule_id" value="{$schedule.T20OutSchedule.id}">
	<input type="hidden" name="status" id="status" value="{$schedule.T20OutSchedule.status}">
	<div class="row">
		<div class="form-group col-xs-12 col-sm-6 col-lg-6">
			<label for="txtTemplateName" class="col-xs-3">テンプレート</label>
			<div class="col-xs-9">
				<p class="col-xs-12">{$schedule.T60TemplateHistory.template_name}</p>
			</div>
		</div>
		<div class="form-group col-xs-12 col-sm-6 col-lg-6">
			<label for="txtTemplateDescription" class="col-xs-3">発信予定日時</label>
			<div class="col-xs-9 t21_out_time_date">
				{foreach from=$call_times key=key item=call_time}
					{if ($key==0)}
						<p class="col-xs-4">{$call_time.T21OutTime.time_start|date_format:"%Y-%m-%d"}</p>
					{else}
						<p class="col-xs-4"></p>
					{/if}
					<p class="col-xs-8">{$call_time.T21OutTime.time_start|date_format:"%H:%M"}～{$call_time.T21OutTime.time_end|date_format:"%H:%M"}</p>
				{/foreach}
			</div>
		</div>
	</div>
	<div class="row">
		<div class="form-group col-xs-12 col-sm-6 col-lg-6">
			<label for="txtTemplateName" class="col-xs-3">発信リスト</label>
			<div class="col-xs-9">
				<p class="col-xs-12">{$schedule.T50ListHistory.list_name}</p>
			</div>
		</div>
		<div class="form-group col-xs-12 col-sm-6 col-lg-6">
			{if (isset($time_end_expect) && !empty($time_end_expect))}
				<label for="txtTemplateDescription" class="col-xs-3">終了見込み日時</label>
				<div class="col-xs-3">
					<p class="col-xs-12 elereload">{$time_end_expect|date_format:"%Y-%m-%d %H:%M"}</p>
				</div>
			{/if}
			{if $show_time_end}
				<label for="txtTemplateDescription" class="col-xs-3">終了日時</label>
				<div class="col-xs-3">
					<p class="col-xs-12">{$time_end|date_format:"%Y-%m-%d %H:%M"}</p>
				</div>
			{/if}
			{if $show_redial_time}
				<label for="txtTemplateDescription" class="col-xs-3">リダイヤル開始時間</label>
				<div class="col-xs-3">
					<p class="col-xs-12">{$time_redial|date_format:"%Y-%m-%d %H:%M"}</p>
				</div>
			{/if}
			{if $show_redial_num}
				<label for="txtTemplateDescription" class="col-xs-3">リダイヤル回数</label>
				<div class="col-xs-3">
					<p class="col-xs-12">{$recall_num}</p>
				</div>
			{/if}
		</div>
	</div>
	<div class="row">
		<div class="form-group col-xs-12 col-sm-6 col-lg-6">
			<label for="txtTemplateName" class="col-xs-3">発信番号</label>
			<div class="col-xs-9">
				<p class="col-xs-12">
					{$schedule.T20OutSchedule.external_number}
				</p>
			</div>
		</div>

		<div class="form-group col-xs-12 col-sm-6 col-lg-6">
			{if ($recall_flag)}
				<label class="col-xs-3">ch数</label>
				<div class="col-xs-5 change_proc_num_container">
					{if (isset($schedule))} {$schedule['T20OutSchedule']['proc_num']} ch {/if}
				</div>
			{/if}
			{if (!$show_btn)}
				<div class="col-xs-3 pull-right none_padding">
					{if ($recall_flag)}
						<div title="再開" title_btn="再開" id="btn_recall" data-toggle="tooltip" screen="status" action="recall" schedule_id="{$schedule.T20OutSchedule.id}" class="lnkRestart btn btn-primary btn-sm col-xs-{if ($show_btn_recall)}6{else}12{/if}" style="{if (!$show_btn_recall)}display:none;{/if}">再開</div>
					{/if}
					{if ($call_now_flag)}
						<div title="即時発信" title_btn="即時発信" id="btn_call_now" data-toggle="tooltip" screen="status" action="call" schedule_id="{$schedule.T20OutSchedule.id}" class="lnkRestart btn btn-primary btn-sm col-xs-6" style="{if (!$show_btn_call_now)}display:none;{/if}">即時発信</div>
					{/if}
					{if ($finish_flag)}
						<div title="{$btn_finish_name}" id="btn_finish" data-toggle="tooltip" class="btn btn-primary btn-sm col-xs-6" style="{if (!$show_btn_finish)}display:none;{/if}" data-msgconfirm="{$msg_confirm_finish}">{$btn_finish_name}</div>
					{/if}
					{if ($stop_flag)}
						<div title="停止" id="btn_stop_call" data-toggle="tooltip" class="btn btn-primary btn-sm col-xs-12" style="{if (!$show_btn_stop)}display:none;{/if}">停止</div>
					{/if}
					<button type="button" title="停止中" id="btn_stoping" data-toggle="tooltip" class="btn btn-primary btn-sm col-xs-12" style="{if (!$show_btn_stoping)}display:none;{/if}" disabled>停止中</button>
					<button type="button" title="終了中" id="btn_finishing" data-toggle="tooltip" class="btn btn-primary btn-sm col-xs-12" style="{if (!$show_btn_finishing)}display:none;{/if}" disabled>終了中</button>
				</div>
			{/if}
		</div>
	</div>

	<div class="row">
		<div class="form-group col-xs-12 col-sm-6 col-lg-6 pull-right">
			<button title="" class="btn btn-primary col-xs-2 col-sm-6 col-lg-3" id="btnDetail" type="button" data-original-title="詳細" data-toggle="tooltip">詳細</button>
			{if ($download_flag)}
				<div class="btn btnDownload btn-primary col-xs-2 col-sm-6 col-lg-3" func-name="download_uncalled" id="btnDownloadUnCalled" data-original-title="未処理DL" data-toggle="tooltip">未処理DL</div>
				<div class="btn btnDownload btn-primary col-xs-2 col-sm-6 col-lg-3" func-name="download_all_log" id="btnDownloadLog" data-original-title="履歴DL" data-toggle="tooltip">履歴DL</div>
				<div class="btn btnDownload btn-primary col-xs-2 col-sm-6 col-lg-3" func-name="download_ans_log" id="btnDownloadLogAns" data-original-title="有効DL" data-toggle="tooltip">有効DL</div>
			{/if}
		</div>
	</div>
	<div class="row">
		<div id="auto_reload" class="form-group col-xs-12 pull-right">
			<p class="form-control-static pull-right">
				毎自動更新
			</p>
			<div class="col-xs-1 pull-right">
				<select class="form-control pull-right" id="schedule_reload" {*data-rel="chosen"*} {if (!$show_reload)}disabled{/if}>
					{foreach from=$schedule_time_reload item=values}
						<option value="{$values.M90PulldownCode.item_code}" {if ((isset($time_reload) && $values.M90PulldownCode.item_code == $time_reload) || $values.M90PulldownCode.item_code eq "1")}selected{/if}>{$values.M90PulldownCode.item_name}</option>
					{/foreach}
				</select>
			</div>
			{if $num_skip > 0}
				<div class="col-xs-6">
					<label class="col-sm-offset-2 error" style="font-size: 20px;">スキップ件数：　{$num_skip}件</label>
				</div>
			{/if}
		</div>
	</div>
</form>

<input type="hidden" id="num_skip" value="{$num_skip}">
<div class=" row">
	<div class="col-md-2 col-sm-2 col-xs-6 col-md-offset-1 col-sm-offset-1">
		<div title="" class="well top-block" href="#" data-original-title="" data-toggle="tooltip">
			<i class="glyphicon glyphicon-list red"></i>
			<div style="color: #25B29C">リスト件数</div>
			<div style="color: #25B29C">{$tel_total|number_format:0:'.':','}件</div>
			{*<span class="notification">56</span>*}
		</div>
	</div>

	<div class="col-md-2 col-sm-2 col-xs-6">
		<div title="" class="well top-block" href="#" data-original-title="" data-toggle="tooltip">
			<i class="glyphicon glyphicon-earphone green"></i>
			<div style="color: #25B29C">発信件数</div>
			<div style="color: #25B29C" class="elereload">{$num_called|number_format:0:'.':','}件</div>
			{*<span class="notification green">4</span>*}
		</div>
	</div>

	<div class="col-md-2 col-sm-2 col-xs-6">
		<div title="" class="well top-block" href="#" data-original-title="" data-toggle="tooltip">
			<i class="glyphicon glyphicon-signal yellow"></i>
			<div style="color: #25B29C">接続件数</div>
			<div style="color: #25B29C" class="elereload">{$num_connected|number_format:0:'.':','}件</div>
			{*<span class="notification yellow">1</span>*}
		</div>
	</div>

	 <div class="col-md-2 col-sm-2 col-xs-6">
		<div title="" class="well top-block" href="#" data-original-title="" data-toggle="tooltip">
			<i class="glyphicon glyphicon-stats red"></i>
			<div style="color: #25B29C">接続率</div>
			<div style="color: #25B29C" class="elereload">{($num_connected/$num_called*100)|number_format:1:'.':','}%</div>
			{*<span class="notification red">12</span>*}
		</div>
	</div>

	 <div class="col-md-2 col-sm-2 col-xs-6">
		<div title="" class="well top-block" href="#" data-original-title="" data-toggle="tooltip">
			<i class="glyphicon glyphicon-ok green"></i>
			<div style="color: #25B29C">有効回答数</div>
			<div style="color: #25B29C" class="elereload">{$num_yuko|number_format:0:'.':','}件</div>
			{*<span class="notification red">10</span>*}
		</div>
	</div>
</div>

<div class="row">
	<div class="form-group col-xs-12">
		<div class="col-xs-6">
			<label class="col-sm-offset-2">リスト状況（リスト件数{$tel_total}件）</label>
		</div>
	</div>
</div>
<div class="row">
	<div class="col-sm-offset-1 col-xs-10">
		<div class="progress">

			{$value = $num_yuko}
			{$percent1 = ($value/$num_called*100)|number_format:1:'.':','}
			<div class="progress-bar progress-bar-success" role="progressbar" style="width:{$percent1}%;" data-original-title="有効回答:{$value|number_format:0:'.':','}件({$percent1}%)" data-toggle="tooltip">
				<div>有効回答</div>
				<div class="elereload">{$value|number_format:0:'.':','}件({$percent1}%)</div>
			</div>

			{$value = $num_connected - $num_yuko}
			{$percent2 = ($value/$num_called*100)|number_format:1:'.':','}
			<div class="progress-bar progress-bar-warning" role="progressbar" style="width:{$percent2}%" data-original-title="接続（無効回答）:{$value|number_format:0:'.':','}件({$percent2}%)" data-toggle="tooltip">
				<div>接続（無効回答）</div>
				<div class="elereload">{$value|number_format:0:'.':','}件({$percent2}%)</div>
			</div>

			{$value = $num_called - $num_connected}
			{$percent3 = 100 - $percent1 - $percent2}
			<div class="progress-bar progress-bar-danger" role="progressbar" style="width:{$percent3}%" data-original-title="未接続:{$value|number_format:0:'.':','}件({$percent3}%)" data-toggle="tooltip">
				<div>未接続</div>
				<div class="elereload">{$value|number_format:0:'.':','}件({$percent3}%)</div>
			</div>
		</div>
	</div>
</div>

{foreach from=$data_questions item=question}
<div class="row">
	<div class="box col-md-12">
		<div class="box-inner">
			{if (isset($question.ques_count_flag))}
				<div class="box-header well" data-original-title="">
					<h2><span class="ques_no">{$question.T61QuestionHistory.question_no}</span>. {$question.question_type_txt}</h2>
					<span>&nbsp;&nbsp;&nbsp;&nbsp;{$question.T61QuestionHistory.question_title}</span>
					<span>&nbsp;&nbsp;&nbsp;&nbsp;{$question.statistic_ans.0}</span>
					<div class="box-icon">
						<a href="#" class="btn btn-minimize btn-round btn-default"><i title="最小化/最大化" data-toggle="tooltip" class="glyphicon glyphicon-chevron-up"></i></a>
					</div>
				</div>
			{elseif $question.question_type == '13'}
				<div class="box-header well" data-original-title="">
					<h2><span class="ques_no">{$question.T61QuestionHistory.question_no}</span>. {$question.question_type_txt}&nbsp;&nbsp;&nbsp;&nbsp;{$question.T61QuestionHistory.question_title}</h2>
					<div class="box-icon">
						<a href="#" class="btn btn-minimize btn-round btn-default"><i title="最小化/最大化" data-toggle="tooltip" class="glyphicon glyphicon-chevron-up"></i></a>
					</div>
				</div>
				<div class="box-content">
					<div class="row {$question.T61QuestionHistory.question_no}">
						<div class="col-md-4">
							<table style="width: 100%;">
								<tr>
									<td>SMS内容</td>
								</tr>
								<tr style="background-color:#f5f5f5">
									<td>{$question.T61QuestionHistory.sms_content|replace:" ":"&nbsp;"|nl2br}</td>
								</tr>
							</table>
						</div>
						<div class="col-md-8">
							<table style="width: 100%;">
								<tr>
									<td>
										送信件数： {if (!empty($smsData[$question.T61QuestionHistory.question_no]['total_tel_send']))}
										{$smsData[$question.T61QuestionHistory.question_no]['total_tel_send']}
										{else}0
										{/if}件</td>
								</tr>
								<tr>
									<td>
										到達件数： {if (!empty($smsData[$question.T61QuestionHistory.question_no]['send_complete']))}
										{$smsData[$question.T61QuestionHistory.question_no]['send_complete']}
										{else}0
										{/if}件
									</td>
								</tr>
								{if (!empty($smsData[$question.T61QuestionHistory.question_no]['progress']))}
								<tr>
									<td>
										<div class="progress">
											{foreach $smsData[$question.T61QuestionHistory.question_no]['progress'] as $title => $progressData}
												<div class="progress-bar {$progressData['class']}" role="progressbar"
													 aria-valuenow="{$progressData['percent']}" aria-valuemin="0"
													 aria-valuemax="100" style="width:{$progressData['percent']}%;" title="{$title}{$progressData['value']}件({($progressData['percent'])|number_format:1:'.':','}%)">
													{$title}<br>
													{$progressData['value']}
													件({($progressData['percent'])|number_format:1:'.':','}%)
												</div>
											{/foreach}
										</div>
									</td>
								</tr>
									{/if}
							</table>
						</div>
					</div>
				</div>
			{elseif $question.question_type == '19'}
				<div class="box-header well" data-original-title="">
					<h2><span class="ques_no">{$question.T61QuestionHistory.question_no}</span>. {$question.question_type_txt}&nbsp;&nbsp;&nbsp;&nbsp;{$question.T61QuestionHistory.question_title}</h2>
					<div class="box-icon">
						<a href="#" class="btn btn-minimize btn-round btn-default"><i title="最小化/最大化" data-toggle="tooltip" class="glyphicon glyphicon-chevron-up"></i></a>
					</div>
				</div>
				<div class="box-content">
					<div class="row {$question.T61QuestionHistory.question_no}">
						<div class="col-md-4">
							<table style="width: 100%;">
								<tr>
									<td>SMS内容</td>
								</tr>
								<tr style="background-color:#f5f5f5">
									<td>{$question.T61QuestionHistory.sms_content|replace:" ":"&nbsp;"|nl2br}</td>
								</tr>
							</table>
						</div>
						<div class="col-md-8">
							<table style="width: 100%;">
								<tr>
									<td>
										送信件数： {if (!empty($smsData[$question.T61QuestionHistory.question_no]['total_tel_send']))}
										{$smsData[$question.T61QuestionHistory.question_no]['total_tel_send']}
										{else}0
										{/if}件</td>
								</tr>
								<tr>
									<td>
										到達件数： {if (!empty($smsData[$question.T61QuestionHistory.question_no]['send_complete']))}
										{$smsData[$question.T61QuestionHistory.question_no]['send_complete']}
										{else}0
										{/if}件
									</td>
								</tr>
								{if (!empty($smsData[$question.T61QuestionHistory.question_no]['progress']))}
									<tr>
										<td>
											<div class="progress">
												{foreach $smsData[$question.T61QuestionHistory.question_no]['progress'] as $title => $progressData}
													<div class="progress-bar {$progressData['class']}" role="progressbar"
														 aria-valuenow="{$progressData['percent']}" aria-valuemin="0"
														 aria-valuemax="100" style="width:{$progressData['percent']}%;" title="{$title}{$progressData['value']}件({($progressData['percent'])|number_format:1:'.':','}%)">
														{$title}<br>
														{$progressData['value']}
														件({($progressData['percent'])|number_format:1:'.':','}%)
													</div>
												{/foreach}
											</div>
										</td>
									</tr>
								{/if}
							</table>
						</div>
					</div>
				</div>
			{else}
			<div class="box-header well" data-original-title="">
				<h2><span class="ques_no">{$question.T61QuestionHistory.question_no}</span>. {$question.question_type_txt}</h2>
				<span>&nbsp;&nbsp;&nbsp;&nbsp;{$question.T61QuestionHistory.question_title}</span>
				{if $question.T61QuestionHistory.question_yuko == 1}
				<span class="label-success label label-default">有効</span>
				{/if}
				<div class="box-icon">
					<a href="#" class="btn btn-minimize btn-round btn-default"><i title="最小化/最大化" data-toggle="tooltip" class="glyphicon glyphicon-chevron-up"></i></a>
				</div>
			</div>
			<div class="box-content">
				<div class="row">
					<div class="col-md-6">
						<table class="table table-bordered table-striped table-condensed">
							<thead>
							<tr>
								<th class="alignCenter templateTable-60">色</th>
								<th class="alignCenter templateTable-60">番号</th>
								<th class="alignCenter templateTable-40">テキスト</th>
								<th class="alignCenter templateTable-60">件数</th>
							</tr>
							</thead>
							<tbody>
							{$total = 0}
							{foreach from=$question.list_answers item=answer}
								{$anws_no = $answer.answer_no}
								{if $anws_no != 0 && $anws_no != 51 && $anws_no != 52 && $anws_no != 99}
									{$total = $total + $question.statistic_ans.$anws_no}
									<tr>
										<td class="alignCenter">
											<span class="color_element"></span>
										</td>
										<td class="alignCenter">{$anws_no}</td>
										<td class="data_chart-title">{$answer.answer_content}</td>
										<td class="alignRight data_chart-value elereload" answer_no="{$anws_no}">{if isset($question.statistic_ans.$anws_no)}{$question.statistic_ans.$anws_no}{else}0{/if}</td>
									</tr>
								{/if}
							{/foreach}
							{foreach from=$question.list_answers item=answer}
								{$anws_no = $answer.answer_no}
								{if $anws_no == 0}
									{$total = $total + $question.statistic_ans.$anws_no}
									<tr>
										<td class="alignCenter">
											<span class="color_element"></span>
										</td>
										<td class="alignCenter">{$anws_no}</td>
										<td class="data_chart-title">{$answer.answer_content}</td>
										<td class="alignRight data_chart-value elereload" answer_no="{$anws_no}">{if isset($question.statistic_ans.$anws_no)}{$question.statistic_ans.$anws_no}{else}0{/if}</td>
									</tr>
								{/if}
							{/foreach}
							{foreach from=$question.list_answers item=answer}
								{$anws_no = $answer.answer_no}
								{if $anws_no == 51 || $anws_no == 52}
									{$total = $total + $question.statistic_ans.$anws_no}
									<tr>
										<td class="alignCenter">
											<span class="color_element"></span>
										</td>
										<td class="alignCenter">
											{if $anws_no == 51}
												*
											{elseif $anws_no == 52}
												#
											{/if}
										</td>
										<td class="data_chart-title">{$answer.answer_content}</td>
										<td class="alignRight data_chart-value elereload" answer_no="{$anws_no}">{if isset($question.statistic_ans.$anws_no)}{$question.statistic_ans.$anws_no}{else}0{/if}</td>
									</tr>
								{/if}
							{/foreach}
							<tr>
								<td colspan="2">合計</td>
								<td></td>
								<td class="alignRight elereload">{$total}</td>
							</tr>
							</tbody>
						</table>
					</div>
					<div class="col-md-6">
						<div class="chart_area alignCenter elereload" id="canvas-holder-{$question.T61QuestionHistory.question_no}">
							<canvas id="chart-area-{$question.T61QuestionHistory.question_no}" width="180" height="180"/>
						</div>
						<div class="chartjs-tooltip"></div>
					</div>
				</div>
			</div>
			{/if}
		</div>
	</div>
</div>
{/foreach}