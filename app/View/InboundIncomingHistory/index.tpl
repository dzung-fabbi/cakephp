{html func=css path='inboundincominghistory/setting_inbound'}
{html func=script url='jquery.validate'}
{html func=script url='pager'}
{html func=script url='view/inboundincominghistory/index'}

<div class="col-lg-10 col-sm-10" id="content">
    <!-- content starts -->

    <!-- {$this->Session->flash()} -->
    {if $mode eq "save"}
        <div class="alert alert-success fade in">
            <button type="button" class="close">×</button><p>リストのアップロードが完了しました。</p>
        </div>
    {/if}
    {if $mode eq "delete"}
        <div class="alert alert-success fade in">
            <button type="button" class="close">×</button><p>{$del_count}件削除しました。</p>
        </div>
    {/if}
    <div class="alert alert-success fade in" id="setting_inbound-success-message" style="display:none;">
        <button type="button" class="close">×</button><p></p>
    </div>
    <div class="alert alert-danger fade in" id="setting_inbound-error-message" style="display:none;">
        <button type="button" class="close">×</button><p></p>
    </div>


    <div class="row">
        <div class="form-group col-md-12">
            {if $create_flag}
                <a href="javascript:void(0);" title="新規登録" data-toggle="tooltip" class="btn btn-primary btn-setting" id="add_setting_inbound">新規登録</a>
            {/if}
            {if $delete_flag eq true}
                <a href="javascript:void(0);" title="選択項目を削除" data-toggle="tooltip" class="btn btn-default" id="btn_delete">選択項目を削除</a>
            {/if}
            {if $download_flag eq true}
                <select id="select_type_download" data-rel="NotSearchable">
                    <option value="select_download">選択項目のDL</option>
                    <option value="download_uncalled">未着信</option>
                    <option value="download_all_log">全ての着信履歴</option>
                    <option value="download_ans_log">有効回答のみ</option>
                </select>
            {/if}
        </div>
    </div>

    <div class="rules_div">
        <div class="wrap">
            <form id="T25SettingInboundIndexForm" method="post" accept-charset="utf-8" enctype="multipart/form-data">
                <table class="table table-striped table-bordered" id="settingInboundTable">
                    <colgroup>
                        {if $delete_flag || $download_flag}
                            <col span="1" width="3%">
                        {/if}
                        <col span="1" width="3%">
                        <col span="1" width="8%">
                        <col span="1" width="17%">
                        <col span="1" width="13%">
                        <col span="1" width="13%">
                        <col span="1" width="13%">
                        <col span="1" width="13%">
                        <col span="1" width="10%">
                        <col span="1" width="7%">
                    </colgroup>
                    <thead>
                        <tr>
                            {if $delete_flag || $download_flag}
                                <th class="remove sorter-false filter-false alignCenter">
                                    <input type="checkbox" id="bundleCheckbox" data-checkbox="cbSelect">
                                    <label for="bundleCheckbox" class="bundleCheckbox"></label>
                                </th>
                            {/if}
                            <th class="text-center">NO.</th>
                            <th class="text-center">電話番号</th>
                            <th class="text-center">適用日</th>
                            <th class="text-center">テンプレート</th>
                            <th class="text-center">着信拒否リスト</th>
                            <th class="text-center">着信リスト</th>
                            <th class="text-center">作成日時</th>
                            <th class="text-center">作成者</th>
                            <th class="remove sorter-false filter-false text-center">アクション</th>
                        </tr>
                    </thead>
                    <tbody></tbody>
                </table>
                <!-- pager -->
                {$view->element('pager/pager')}
                <input type="hidden" value="{if isset($sortColumn)}{$sortColumn}{/if}" id="hdSortColumnSettingInbound"/>
                <input type="hidden" value="{if isset($sortType)}{$sortType}{/if}" id="hdSortTypeSettingInbound"/>
                <input type="hidden" value="{if isset($page)}{$page}{/if}" id="hdPageSettingInbound"/>
            </form>
        </div>
    </div>

    <div id="form_container"></div>
    <!-- content ends -->
</div>