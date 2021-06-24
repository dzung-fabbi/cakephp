{html func=css path='rdd/rdd'}
{html func=script url='view/rdd/rdd'}

<div id="div_container">
    <div class="div_box">
        <div class="margleft_20 " style="margin: 20px;margin-bottom:5px;">
            <div class="flash_msg"></div>
        </div>
        <form id="RDDCreateForm" method="post" action="{Router::url('', true)}" accept-charset="utf-8" enctype="multipart/form-data">
            <input type="hidden" name="max_tel_no" id="hd_max_tel_no" value="{$max_item}">
            <input type="hidden" name="max_list_no" id="hd_max_list_no" value="{$max_list}">
            <div class="" id="input_list_name_area">
                <div>
                    <label class="label_left">リスト名設定</label>
                    <input type="text" id="ipListName" name="data[RDD][list_name]" value="" class="input_box_new input_190" maxlength="50">
                </div>
                <div class="err_msg input_err_msg">
                    <label id="ipListName-error" class="error" for="ipListName"></label>
                </div>
                <div>
                    <label class="label_left">トータル件数</label>
                    <input type="text" id="ipTotal" name="data[RDD][quantity_item_total]" value="" readonly class="input_box_new input_90" style="background-color:rgb(167, 184, 200);">
                    <span class="textDefault">件 ×</span>
                    <input type="text" id="ipNumList" name="data[RDD][quantity_list]" value="1" class="input_box_new" maxlength="2" style="width: 25px; text-align: center;">
                    <span class="textDefault">本</span>
                </div>
                <div class="err_msg input_err_msg">
                	<label id="" class="error" for="ipTotal"></label>
                    <label id="ipNumList-error" class="error" for="ipNumList"></label>
                </div>
                <div>
                    <label class="label_left">作成方法</label>
                    <select name="data[RDD][type_create]" class="select_154 input_box_new input_210" id="dropTypeCreate">
                        <option value="type_switchboard">市外局番で作る</option>
                        <option value="type_prefecture">都道府県で作る</option>
                        <option value="type_district">市区郡から作る</option>
                    </select>
                </div>
                <div style="margin-top: 20px;">
                    <label class="label_left">掲載データのみで作成</label>
                    <input type="checkbox" name="data[RDD][only_use_data_posted_flag]" id="cbKeisai" value="1">
                    <label for="cbKeisai" style="margin-top: 6px;"></label>
                </div>
            </div>

            <div class="list_input" style="width: 550px;">
                <div class="wrap type_create type_switchboard" id="create_by_switchboard">
                    <div class="box_spacer_20"></div>

                    <table class="table_532">
                        <colgroup>
                           <col span="1" width="7%">
                           <col span="1" width="45%">
                           <col span="1" width="53%">
                        </colgroup>

                        <thead class="head">
                        <tr>
                            <th colspan="2" style="text-align:center;">市外局番+市内番号</th>
                            <th style="text-align:center;">
                                必要件数
                                <div style="float: right; margin-right: 5px;">
                                    <a href="#" class="btnAddInput" id="btnAddSixDigit"></a>
                                </div>
                            </th>
                        </tr>
                        </thead>

                        <tbody class="inner_table">
                        <div id="viewFormDivSwitchboard" >
                            {for $i=1 to 10}
                                <tr>
                                    <td>{$i}</td>
                                    <td>
                                        <input type="text" name="data[data_switchboard][{$i}][switchboard]" class="input_box_new input_120 ipSixDigit" id="switchboard_{$i}" maxlength="6">
                                        <span></span>
                                        <div class="err-mesg-20">
                                            <label id="switchboard_{$i}-error" class="error switchboard_error" for="switchboard_{$i}"></label>
                                        </div>
                                    </td>
                                    <td>
                                        <input type="text" name="data[data_switchboard][{$i}][quantity]" class="input_box_new input_120 ipNumItem ipNumSixDigit" id="ipNumSixDigit_{$i}" maxlength="5">
                                        件
                                        <div style="float: right;">
                                            <a href="#" class="btnRemoveInput"></a>
                                        </div>
                                        <div class="err-mesg-20">
                                            <label id="ipNumSixDigit_{$i}-error" class="error ipNumSixDigit_error" for="ipNumSixDigit_{$i}"></label>
                                        </div>
                                    </td>
                                </tr>
                            {/for}
                        </div>
                        </tbody>
                    </table>
                </div>

                <div class="wrap type_create type_prefecture" id="create_by_prefecture">
                    <div class="box_spacer_20"></div>

                    <div id="create_by_prefecture_scroll">
                        <table class="table_532">
                            <colgroup>
                                <col span="1" width="7%">
                                <col span="1" width="45%">
                                <col span="1" width="53%">
                            </colgroup>

                            <thead class="head">
                            <tr>
                                <th colspan="2" style="text-align:center;">都道府県</th>
                                <th style="text-align:center;">必要件数</th>
                            </tr>
                            </thead>

                            <tbody class="inner_table">
                            <div id="viewFormDivPrefecture" >
                                {foreach from=$prefectures item=prefecture key=key}
                                    <tr>
                                        <td>{$key + 1}</td>
                                        <td>
                                            {$prefecture.T71Prefecture.prefecture_name}<span id="prefecture_num_{$key}">（{($prefecture.T71Prefecture.num > 0) ? $prefecture.T71Prefecture.num : 0}）</span>
                                            <input type="hidden" name="data[data_prefecture][{$key}][prefecture_code]" value="{$prefecture.T71Prefecture.prefecture_code}">
                                        </td>
                                        <td>
                                            <input type="text" name="data[data_prefecture][{$key}][quantity]" value=""
                                                   {*min_percent="{$prefecture.0.min_percent}"*}
                                                   bottom_limit="{$prefecture[0]['bottom_limit']}"
                                                   top_limit="{$prefecture[0]['top_limit']}"
                                                   max_value="{($prefecture.T71Prefecture.num > 0) ? $prefecture.T71Prefecture.num : 0}"
                                                   class="input_box_new input_120 ipNumItem ipNumPrefecture"
                                                   id="ipNumPrefecture_{$key}" maxlength="5"
                                                   prefecture_code="{$prefecture.T71Prefecture.prefecture_code}">
                                            件
                                            <div class="err-mesg-20">
                                                <label id="ipNumPrefecture_{$key}-error" class="error" for="ipNumPrefecture_{$key}"></label>
                                            </div>
                                        </td>
                                    </tr>
                                {/foreach}
                            </div>
                            </tbody>
                        </table>
                    </div>
                </div>

                <div class="type_create type_district"{* id="create_from_cannot_choose_data_posted"*}>
                    <div style="margin-top: 15px;">
                        <label class="label_left">都道府県を指定</label>
                        <select name="data[RDD][prefecture_code]" class="select_154 input_box_new float_left select_130" id="drop_select_prefecture">
                            <option value="">---</option>
                            {foreach from=$prefectures item=prefecture}
                                <option value="{$prefecture.T71Prefecture.prefecture_code}">{$prefecture.T71Prefecture.prefecture_name}</option>
                            {/foreach}
                        </select>
                        <div class="green_buttons_disable" id="btnChooseDistrictContainer">
                            <a href="javascript:void(0);" id="btnChooseDistrict">市区郡選択</a>
                        </div>
                    </div>
                    {*<div class="box_spacer"></div>*}
                    <div class="err_msg input_err_msg" style="margin-top: 2px;float: left;width: 100%;margin-bottom: 10px;">
                        <label id="drop_select_prefecture-error" class="error" for="drop_select_prefecture"></label>
                    </div>

                    <div class="wrap" id="create_by_district">
                        <div>
                            <table class="table_532">
                            <colgroup>
                                <col span="1" width="7%">
                                <col span="1" width="40%">
                                <col span="1" width="53%">
                            </colgroup>

                            <thead class="head">
                            <tr>
                                <th colspan="2" style="text-align:center;">郡市区名</th>
                                <th style="text-align:center;">必要件数</th>
                            </tr>
                            </thead>

                            <tbody class="inner_table">
                            <div id="viewFormDivDistrict" >
                                {for $i=1 to 10}
                                    <tr>
                                        <td>{$i}</td>
                                        <td></td>
                                        <td></td>
                                    </tr>
                                {/for}
                            </div>
                            </tbody>
                        </table>
                        </div>
                    </div>
                </div>
            </div>

            <div class="box_spacer"></div>
            <div class="box_spacer"></div>

            <div class="">
                <div class="green_buttons" style="margin-left: 80px;">
                    <a href="javascript:void(0);" class="btn_80 executebtn" id="btnOK">作成</a>
                </div>
                <div class="green_buttons" id="btnUploadCSVContainer" style="margin-left: 32px;">
                    <input type="file" id="file_to_upload" name="data[RDD][File]" class="" style="width: 0px; height: 0px; display: none;"/>
                    <a href="javascript:void(0);" class="btn_135" id="btnUploadCSV">CSVでアップロード</a>
                </div>
            </div>

            <div class="district_choose_div" id="dialog_choose_district">
                <div id="list_checkbox_district">
                </div>

                <div class="box_spacer"></div>
                <div class="box_spacer"></div>

                <div class="" style="margin-left: 18px; width: 750px; text-align: center;">
                    <div class="green_buttons" style="margin-left: 255px; float: left;">
                        <a href="javascript:void(0);" class="btn_50" id="btnCloseDialog">決定</a>
                    </div>
                    <div class="gray_buttons" style="margin-left: 32px; float: left;">
                        <a href="javascript:void(0);" class="btn_50" id="btnCancelDialog">閉じる</a>
                    </div>
                </div>
            </div>
        </form>
    </div>
</div>