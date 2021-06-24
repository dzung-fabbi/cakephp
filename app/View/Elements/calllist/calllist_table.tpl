<div class="wrap">
    <table id="callListTable" class="{*tablesorter*}">
        <colgroup>
            <col span="1" width="10%">
            <col span="1" width="40%">
            <col span="1" width="10%">
            <col span="1" width="20%">
            <col span="1" width="13%">
            <col span="1" width="7%">
        </colgroup>

        <thead class="head">
        <tr>
            <th style="text-align:center;">NO</th>
            <th style="text-align:center;">リスト名</th>
            <th style="text-align:center;">件数</th>
            <th style="text-align:center;">作成日</th>
            <th class="remove sorter-false filter-false" style="text-align:center;" colspan="2">操作</th>
        </tr>
        </thead>

        <tbody class="inner_table">
        <div id="viewFormDiv" >
            {if isset($call_lists) && !empty($call_lists)}
                {foreach from=$call_lists item=call_list key=key}
                    <tr {if ($call_list.T10CallList.list_test_flag == 1)}class="call_list_test"{/if}>
                        <td>{$call_list.T10CallList.id}</td>
                        <td>
                            {if ($call_list.T10CallList.list_test_flag == 1)}
                                <span class="color-red">（テスト）</span>{$call_list.T10CallList.list_name}
                            {else}
                                {$call_list.T10CallList.list_name}
                            {/if}
                        </td>
                        <td>{$call_list.T10CallList.tel_total|number_format:0:".":","}件</td>
                        <td>{$call_list.T10CallList.created}</td>
                        <td>
                            <div class="">
                                <a href="javascript:void(0);" class="btnDownload" list_id="{$call_list.T10CallList.id}">ダウンロード</a>
                            </div>
                        </td>
                        <td>
                            <div class="">
                                <a href="javascript:void(0);" class="btnDel" list_id="{$call_list.T10CallList.id}">削除</a>
                            </div>
                        </td>
                    </tr>
                {/foreach}
            {/if}
        </div>
        </tbody>
    </table>

    <!-- pager -->
    {$view->element('pager/pager')}
</div>
