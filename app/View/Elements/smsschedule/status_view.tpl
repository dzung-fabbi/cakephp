<form id="T200SmsSendScheduleIndexForm">
    <input type="hidden" name="schedule_id" id="schedule_id" value="{$schedule.T200SmsSendSchedule.id}">
    <input type="hidden" name="status" id="status" value="{$schedule.T200SmsSendSchedule.status}">
    <div class="row">
        <div class="form-group col-xs-12 col-sm-6 col-lg-6">
            <label for="txtTemplateName" class="col-xs-3">テンプレート</label>
            <div class="col-xs-9">
                <p class="col-xs-12">{$schedule.T600SmsTemplateHistory.template_name}</p>
            </div>
        </div>
        <div class="form-group col-xs-12 col-sm-6 col-lg-6">
            <label for="txtTemplateDescription" class="col-xs-3">送信予定日時</label>
            <div class="col-xs-9">
                {foreach from=$send_times key=key item=send_time}
                    {if ($key==0)}
                        <p class="col-xs-4">{$send_time.T201SmsSendTime.time_start|date_format:"%Y-%m-%d"}</p>
                    {else}
                        <p class="col-xs-4"></p>
                    {/if}
                    <p class="col-xs-8">{$send_time.T201SmsSendTime.time_start|date_format:"%H:%M"}～{$send_time.T201SmsSendTime.time_end|date_format:"%H:%M"}</p>
                {/foreach}
            </div>
        </div>
    </div>
    <div class="row">
        <div class="form-group col-xs-12 col-sm-6 col-lg-6">
            <label for="txtTemplateName" class="col-xs-3">送信リスト</label>
            <div class="col-xs-9">
                <p class="col-xs-12">{$schedule.T500SmsListHistory.list_name}</p>
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
        </div>
    </div>
    <div class="row">
        <div class="form-group col-xs-12 col-sm-6 col-lg-6"></div>

        <div class="form-group col-xs-12 col-sm-6 col-lg-6">
            {if (!$show_btn)}
                <div class="col-xs-3 pull-right none_padding">
                    {if ($resend_flag)}
                        <div title="再開" title_btn="再開" id="btn_resend" data-toggle="tooltip" screen="status" action="resend" schedule_id="{$schedule.T200SmsSendSchedule.id}" class="lnkRestart btn btn-primary btn-sm col-xs-{if ($show_btn_resend)}6{else}12{/if}" style="{if (!$show_btn_resend)}display:none;{/if}">再開</div>
                    {/if}
                    {if ($send_now_flag)}
                        <div title="即時送信" title_btn="即時送信" id="btn_send_now" data-toggle="tooltip" screen="status" action="send_now" schedule_id="{$schedule.T200SmsSendSchedule.id}" class="lnkRestart btn btn-primary btn-sm col-xs-6" style="{if (!$show_btn_send_now)}display:none;{/if}">即時送信</div>
                    {/if}
                    {if ($finish_flag)}
                        <div title="{$btn_finish_name}" id="btn_finish" data-toggle="tooltip" class="btn btn-primary btn-sm col-xs-6" style="{if (!$show_btn_finish)}display:none;{/if}" data-msgconfirm="{$msg_confirm_finish}">{$btn_finish_name}</div>
                    {/if}
                    {if ($stop_flag)}
                        <div title="停止" id="btn_stop_send" data-toggle="tooltip" class="btn btn-primary btn-sm col-xs-6" style="{if (!$show_btn_stop)}display:none;{/if}">停止</div>
                    {/if}
                    <button type="button" title="停止中" id="btn_stoping" data-toggle="tooltip" class="btn btn-primary btn-sm col-xs-6" style="{if (!$show_btn_stoping)}display:none;{/if}" disabled>停止中</button>
                </div>
            {/if}
        </div>
    </div>

    <div class="row">
        <div class="form-group col-xs-12 col-sm-6 col-lg-6 pull-right">
            <button title="" class="btn btn-primary col-xs-2 col-sm-6 col-lg-4" id="btnDetail" type="button" data-original-title="詳細" data-toggle="tooltip">詳細</button>
            {if ($download_flag)}
                <div class="btn btnDownload btn-primary col-xs-2 col-sm-6 col-lg-4" func-name="download_unsend" id="btnDownloadUnSend" data-original-title="未送信DL" data-toggle="tooltip">未送信DL</div>
                <div class="btn btnDownload btn-primary col-xs-2 col-sm-6 col-lg-4" func-name="download_all_log" id="btnDownloadLog" data-original-title="送信済みDL" data-toggle="tooltip">送信済みDL</div>
            {/if}
        </div>
    </div>
    <div class="row">
        <div id="auto_reload" class="form-group col-xs-12 col-sm-3 col-lg-3 pull-right">
            <p class="form-control-static pull-right">
                毎自動更新
            </p>
            <div class="col-xs-6 pull-right">
                <select class="form-control pull-right" id="schedule_reload" {*data-rel="chosen"*} {if (!$show_reload)}disabled{/if}>
                    {foreach from=$schedule_time_reload item=values}
                        <option value="{$values.M90PulldownCode.item_code}" {if ((isset($time_reload) && $values.M90PulldownCode.item_code == $time_reload) || $values.M90PulldownCode.item_code eq "1")}selected{/if}>{$values.M90PulldownCode.item_name}</option>
                    {/foreach}
                </select>
            </div>
        </div>
    </div>
</form>

{$total = $num_send_success + $num_send_not_success + $num_send_unknown}
<div class=" row">
    <div class="col-md-2 col-sm-2 col-xs-6 col-md-offset-1 col-sm-offset-1">
        <div title="" class="well top-block" href="#" data-original-title="" data-toggle="tooltip">
            <i class="glyphicon glyphicon-list red"></i>
            <div style="color: #25B29C">リスト件数</div>
            <div style="color: #25B29C">{$tel_total|number_format:0:'.':','}件</div>
        </div>
    </div>

    <div class="col-md-2 col-sm-2 col-xs-6">
        <div title="" class="well top-block" href="#" data-original-title="" data-toggle="tooltip">
            <i class="glyphicon glyphicon-earphone green"></i>
            <div style="color: #25B29C">送信件数</div>
            <div style="color: #25B29C" class="elereload">{$num_send|number_format:0:'.':','}件</div>
        </div>
    </div>

    <div class="col-md-2 col-sm-2 col-xs-6">
        <div title="" class="well top-block" href="#" data-original-title="" data-toggle="tooltip">
            <i class="glyphicon glyphicon-signal yellow"></i>
            <div style="color: #25B29C">到達件数</div>
            <div style="color: #25B29C" class="elereload">{$num_send_success|number_format:0:'.':','}件</div>
        </div>
    </div>

    <div class="col-md-2 col-sm-2 col-xs-6">
        <div title="" class="well top-block" href="#" data-original-title="" data-toggle="tooltip">
            <i class="glyphicon glyphicon-stats green"></i>
            <div style="color: #25B29C">到達率</div>
            <div style="color: #25B29C; height: 22px;" class="elereload">
                {if ($total > 0)}
                    {($num_send_success/$total*100)|number_format:1:'.':','}%
                {/if}
            </div>
        </div>
    </div>
</div>

<div class="row">
    <label class="col-sm-offset-1 col-xs-4">到達状況（{$total}件）</label>
</div>
<div class="row">
    <div class="col-sm-offset-1 col-xs-10">
        <div class="progress">
            {if ($total > 0)}
                {$value = $num_send_success}
                {if ($value > 0)}
                    {$percent1 = ($value/$total*100)|number_format:1:'.':','}
                    <div class="progress-bar progress-bar-success" role="progressbar" style="width:{$percent1}%;" data-original-title="着信済み:{$value|number_format:0:'.':','}件({$percent1}%)" data-toggle="tooltip">
                        <div>着信済み</div>
                        <div class="elereload">{$value|number_format:0:'.':','}件({$percent1}%)</div>
                    </div>
                {/if}

                {$value = $num_send_outside}
                {if ($value > 0)}
                    {$percent2 = ($value/$total*100)|number_format:1:'.':','}
                    {if ($percent2 > 100 - $percent1)}
                        {$percent2 = 100 - $percent1}
                    {/if}
                    <div class="progress-bar progress-bar-warning" role="progressbar" style="width:{$percent2}%" data-original-title="圏外:{$value|number_format:0:'.':','}件({$percent2}%)" data-toggle="tooltip">
                        <div>圏外</div>
                        <div class="elereload">{$value|number_format:0:'.':','}件({$percent2}%)</div>
                    </div>
                {/if}
                
                {$value = $num_send_fail}
                {if ($value > 0)}
                    {$percent3 = ($value/$total*100)|number_format:1:'.':','}
                    {if ($percent3 > 100 - $percent1  - $percent2)}
                        {$percent3 = 100 - $percent1 -  $percent2}
                    {/if}
                    <div class="progress-bar progress-bar-danger" role="progressbar" style="width:{$percent3}%" data-original-title="エラー:{$value|number_format:0:'.':','}件({$percent3}%)" data-toggle="tooltip">
                        <div>エラー</div>
                        <div class="elereload">{$value|number_format:0:'.':','}件({$percent3}%)</div>
                    </div>
                {/if}
                {$value = $num_send_unknown}
                {if ($value > 0)}
                    {$percent4 = ($value/$total*100)|number_format:1:'.':','}
                    {if ($percent4 > 100 - $percent1 - $percent2 - $percent3)}
                        {$percent4 = 100 - $percent1 - $percent2 - $percent3}
                    {/if}
                    <div class="progress-bar progress-bar-info" role="progressbar" style="width:{$percent4}%; background-color: #E0F000;" data-original-title="不明:{$value|number_format:0:'.':','}件({$percent4}%)" data-toggle="tooltip">
                        <div>不明</div>
                        <div class="elereload">{$value|number_format:0:'.':','}件({$percent4}%)</div>
                    </div>
                {/if}
                <!-- #8298 add consentday -->
                {$value = $num_send_history_judgement_ng}
                {if ($value > 0)}
                    {$percent5 = ($value/$total*100)|number_format:1:'.':','}
                    {if ($percent5 > 100 - $percent1 - $percent2 - $percent3 - $percent4)}
                        {$percent5 = 100 - $percent1 - $percent2 - $percent3 - $percent4}
                    {/if}
                    <div class="progress-bar progress-bar-info" role="progressbar" style="width:{$percent5}%; background-color: #6495ed;" data-original-title="履歴判定NG:{$value|number_format:0:'.':','}件({$percent5}%)" data-toggle="tooltip">
                        <div>履歴判定NG</div>
                        <div class="elereload">{$value|number_format:0:'.':','}件({$percent5}%)</div>
                    </div>
                {/if}
            {else}
                <label class="col-xs-12" style="text-align: center; padding-top: 25px;">到達件数がありません。</label>
            {/if}
        </div>
    </div>
</div>

<div class="row" style="display: none">
    <label class="col-sm-offset-1 col-xs-4">キャリア内訳</label>
</div>
<div class="row" style="display: none">
    <div class="col-sm-offset-1 col-xs-10">
        <div class="progress">
            {$total_by_carrier = $num_send_dcm + $num_send_au + $num_send_sb + $num_send_other}
            {if ($total_by_carrier > 0)}
                {$value = $num_send_dcm}
                {$percent1 = ($value/$total_by_carrier*100)|number_format:1:'.':','}
                <div class="progress-bar progress-bar-success" role="progressbar" style="width:{$percent1}%; background-color: #3AFB97;" data-original-title="docomo:{$value|number_format:0:'.':','}件({$percent1}%)" data-toggle="tooltip">
                    <div>docomo</div>
                    <div class="elereload">{$value|number_format:0:'.':','}件({$percent1}%)</div>
                </div>

                {$value = $num_send_au}
                {$percent2 = ($value/$total_by_carrier*100)|number_format:1:'.':','}
                {if ($percent2 > 100 - $percent1)}
                    {$percent2 = 100 - $percent1}
                {/if}
                <div class="progress-bar progress-bar-warning" role="progressbar" style="width:{$percent2}%; background-color: #0068B7;" data-original-title="au:{$value|number_format:0:'.':','}件({$percent2}%)" data-toggle="tooltip">
                    <div>au</div>
                    <div class="elereload">{$value|number_format:0:'.':','}件({$percent2}%)</div>
                </div>

                {$value = $num_send_sb}
                {$percent3 = ($value/$total_by_carrier*100)|number_format:1:'.':','}
                {if ($percent3 > 100 - $percent1 - $percent2)}
                    {$percent3 = 100 - $percent1 - $percent2}
                {/if}
                <div class="progress-bar progress-bar-danger" role="progressbar" style="width:{$percent3}%; background-color: #FF99FF;" data-original-title="softbank:{$value|number_format:0:'.':','}件({$percent3}%)" data-toggle="tooltip">
                    <div>softbank</div>
                    <div class="elereload">{$value|number_format:0:'.':','}件({$percent3}%)</div>
                </div>

                {$value = $num_send_other}
                {$percent4 = ($value/$total_by_carrier*100)|number_format:1:'.':','}
                {if ($percent4 > 100 - $percent1 - $percent2 - $percent3)}
                    {$percent4 = 100 - $percent1 - $percent2 - $percent3}
                {/if}
                <div class="progress-bar progress-bar-info" role="progressbar" style="width:{$percent4}%; background-color: #FFF100;" data-original-title="その他:{$value|number_format:0:'.':','}件({$percent4}%)" data-toggle="tooltip">
                    <div>その他</div>
                    <div class="elereload">{$value|number_format:0:'.':','}件({$percent4}%)</div>
                </div>
            {else}
                <label class="col-xs-12" style="text-align: center; padding-top: 25px;">キャリア別件数がありません。</label>
            {/if}
        </div>
    </div>
</div>


<div class="row">
    <label class="col-sm-offset-1 col-xs-4">SMS内容</label>
</div>
<div class="row">
    <div class="col-sm-offset-1 col-xs-10">
        <div class="progress" style="height: auto; min-height: 70px;">
            <label class="col-xs-12" style="padding-top: 5px;">{$schedule.T600SmsTemplateHistory.content|replace:" ":"&nbsp;"|nl2br}</label>
        </div>
    </div>
</div>