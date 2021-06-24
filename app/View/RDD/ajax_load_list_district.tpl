<div class="wrap">
    <table class="list_katakana" id="list_katakana">
        <colgroup>
            {foreach from=$group_districts item=districts key=key}
                <col span="1" width="{(100)/($group_districts|count)}%">
            {/foreach}
        </colgroup>

        <thead class="head">
        <tr>
            {foreach from=$group_districts item=districts key=key}
                {if ($districts|count == 0)}
                    <th style="text-align:center;" class="district_disabled">{$key}</th>
                {else}
                    <th style="text-align:center;">{$key}</th>
                {/if}
            {/foreach}
        </tr>
        </thead>

        <tbody class="inner_table">
        </tbody>
    </table>
</div>

<div class="box_spacer"></div>
<div class="box_spacer"></div>

{$number_column = 4}
<div class="wrap select_district_area">
    <table class="" id="tbl_list_district">
        <colgroup>
            {for $i=1 to $number_column}
                <col span="1">
            {/for}
        </colgroup>

        <tbody class="inner_table">
        <div id="viewFormDiv">
            {foreach from=$group_districts item=districts key=key}
                {if ($districts|count > 0)}
                    <tr><th colspan="{$number_column}" id="{$key}">{$key}</th></tr>

                    {foreach from=$districts item=district key=key2}
                        {if ($key2 % $number_column == 0)}
                            <tr>
                        {/if}
                        <td>
                            <div style="display: flex;">
                                <input type="checkbox" name="" id="{$district.T72District.prefecture_code}_{$district.T72District.district_code}" value="{$district.T72District.district_code}" tel_no="{if ($keisai_flag)}{$district.T72District.num_keisai}{else}{$district.T72District.num}{/if}">
                                <label for="{$district.T72District.prefecture_code}_{$district.T72District.district_code}" style="margin-top: 2px;"></label>
                                <label for="{$district.T72District.prefecture_code}_{$district.T72District.district_code}" class="lbl_district_name">
                                    {$district.T72District.district_name}（{if ($keisai_flag)}{$district.T72District.num_keisai}{else}{$district.T72District.num}{/if}）
                                </label>
                            </div>
                        </td>
                        {if ($key2 % $number_column == ($number_column - 1))}
                            </tr>
                        {/if}
                    {/foreach}
                    <tr><td colspan="{$number_column}"></td></tr>
                {/if}
            {/foreach}
        </div>
        </tbody>
    </table>
    <div id="extend_tbl_list_district"></div>
</div>