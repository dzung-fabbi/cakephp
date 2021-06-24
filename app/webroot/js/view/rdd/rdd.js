$(document).ready(function(){
    const DEFAULT_ROW_NUM = 10;

    const SWITCHBOARD_LENGTH = 6;
    const MAX_QUANTITY_SWITCHBOARD = 10000;

    const MAX_LIST_NAME_LENGTH = 50;
    const MAX_LIST_NO = parseInt($('#hd_max_list_no').val());
    const MAX_TEL_NO = parseInt($('#hd_max_tel_no').val());
    const MAX_LENGTH_OF_QUANTITY = MAX_TEL_NO.toString().length;

    var position_katakana = [];
    var checkbox_checked = [];

    var msg_error_switchboard = '6桁数字を入力してください。';

    var six_digit_old = [];
    var num_input_sixdigit = DEFAULT_ROW_NUM;

    $.validator.addMethod('myDigits', function(value, element, param) {
        return /*this.optional(element) ||*/ value == '' || /^\d+$/.test(value);
    }, '該当するデータが存在しません。');

    $.validator.addMethod('checkSwitchboardFormat', function(value, element, param) {
        return this.optional(element) || /\d+$/.test(value) && value.length == SWITCHBOARD_LENGTH;
    }, msg_error_switchboard);

    $.validator.addMethod('checkSwitchboardExist', function(value, element, param) {
        if (value){
            var class_compare_element = param;
            var result = true;
            $('.' + class_compare_element).each(function() {
                if ($(this).attr('id') != element.id && value == $(this).val()) {
                    result = false;
                }
            });
            return result;
        }
        return true;
    }, '');

    $.validator.addMethod('checkMustInput', function(value, element, param) {
        var id_compare_element = param;
        if (value == '' && $('#' + id_compare_element).val() != '' && $('label[for="' + id_compare_element + '"]').html() == '') {
            return false;
        }
        return true;
    }, '');

    $.validator.addMethod('checkQuantityItem', function(value, element, param) {
        if (value){
            var i = parseInt(value);
            return (i >= 1 && i <= MAX_TEL_NO);
        }
        return true;
    }, '' + MAX_QUANTITY_SWITCHBOARD + '以下の数字を入力してください。');

    $.validator.addMethod('checkQuantityItemByParam', function(value, element, param) {
        var quantity_list = getQuantityList();

        if (value){
            var i = parseInt(value) * quantity_list;
            return (i >= 1 && i <= param);
        }
        return true;
    }, '' + MAX_TEL_NO + '以下の数字を入力してください。');

    $.validator.addMethod('checkHadTel', function(value, element, param) {
        return param > 0;
    }, '該当するデータが存在しません。');

    $.validator.addMethod('myRequired', function(value, element, param) {
        if (value == ''){
            var class_input = param;
            var result = false;
            $('.' + class_input).each(function () {
                if ($(this).val() != '') {
                    result = true;
                }
            });
            return result;
        }
        return true;
    }, '' + MAX_TEL_NO + '以下の数字を入力してください。');

    $.validator.addMethod('checkMinNumPrefecture', function(value, element, param) {
//        var bottom_limit = parseInt($(element).attr('bottom_limit'));
    	var bottom_limit = 5000;

        if (value) {
            return (value >= bottom_limit);
        }
        return true;
    }, '');

    $.validator.addMethod('checkMaxNumPrefecture', function(value, element, param) {
        var quantity_list = getQuantityList();
        var top_limit = parseInt($(element).attr('top_limit'));

        if (value) {
            return (value * quantity_list <= top_limit);
        }
        return true;
    }, '');

    $('#RDDCreateForm').validate({
        invalidHandler: function(form, validator) {
            var errors = validator.numberOfInvalids();
            if (errors) {
                var firstInvalidElement = $(validator.errorList[0].element);
                if (firstInvalidElement.css("display") == "none") {
                    firstInvalidElement.css("display","block");
                    firstInvalidElement.focus();
                    firstInvalidElement.css("display","none");
                }else {
                    firstInvalidElement.focus();
                }
            }
        },
        rules: {
            "data[RDD][list_name]": {
                required: true,
                maxlength: MAX_LIST_NAME_LENGTH,
                remote: {
                    type: 'post',
                    url: appRoot + '/RDD/check_exist_listname',
                    async: false,
                    data: {
                        list_name: function() {
                            return $("#ipListName").val();
                        },
                        quantity_list: function() {
                            return $("#ipNumList").val();
                        }
                    }
                }
            },
            "data[RDD][quantity_item_total]": {
                myRequired: 'ipNumItem',
                min: 1,
                max: MAX_TEL_NO,
            },
            "data[RDD][quantity_list]": {
                required: true,
                number: true,
                min: 1,
                max: MAX_LIST_NO,
            },
            "data[RDD][prefecture_code]": {
                required: {
                    depends: function(element) {
                        return $('#drop_select_prefecture').val() == '';
                    }
                }
            },
        },
        messages: {
            "data[RDD][list_name]": {
                required: 'リスト名を入力してください。',
                maxlength: 'リスト名は' + MAX_LIST_NAME_LENGTH + '桁以下で入力してください。',
                remote: '指定されたリスト名はすでに登録されています。'
            },
            "data[RDD][quantity_item_total]": {
                myRequired: '必要件数を入力してくだい。',
                min: 'トータル件数は' + MAX_TEL_NO + '件以下になるように設定してください。',
                max: 'トータル件数は' + MAX_TEL_NO + '件以下になるように設定してください。',
            },
            "data[RDD][quantity_list]": {
                required: '' + MAX_LIST_NO + '以下の数字を入力してください。',
                number: '' + MAX_LIST_NO + '以下の数字を入力してください。',
                min: '' + MAX_LIST_NO + '以下の数字を入力してください。',
                max: '' + MAX_LIST_NO + '以下の数字を入力してください。',
            },
            "data[RDD][prefecture_code]": {
                required: '都道府県を選択してください。'
            },
        }
    });

    $('#dialog_choose_district').dialog({
        title: '',
        height:650,
        width: 930,
        modal: true,
        autoOpen: false,
        resizable: false,
        show: {
            effect: "blind",
            duration: 100
        },
        hide: {
            effect: "blind",
            duration: 100
        },
    });

    $(".ipSixDigit").each(function() {
        $(this).rules("add", {
            myDigits: true,
            maxlength: SWITCHBOARD_LENGTH,
            checkSwitchboardFormat: true,
            checkSwitchboardExist: 'ipSixDigit',
            checkMustInput: $(this).parent().parent().find('.ipNumSixDigit').first().attr('id'),
            messages: {
                myDigits: msg_error_switchboard,
                maxlength: msg_error_switchboard,
                checkSwitchboardFormat: msg_error_switchboard,
                checkSwitchboardExist: '同じ数字が入力されています。',
                checkMustInput: msg_error_switchboard,
            }
        });
    });

    $(".ipNumSixDigit").each(function() {
        $(this).attr('max_value', MAX_QUANTITY_SWITCHBOARD);
        validateNumSixDigit($(this), MAX_QUANTITY_SWITCHBOARD)
    });

    $(".ipNumPrefecture").each(function() {
        validateNumPrefecture($(this), MAX_TEL_NO);
    });

    $('#dropTypeCreate').change(function() {
        setTypeCreate();

        $('.wrap input[type=text]').val('');
        if ($('#create_by_switchboard .inner_table tr').size() > DEFAULT_ROW_NUM) {
            $('#create_by_switchboard .inner_table tr').each(function(index) {
                if (index >= DEFAULT_ROW_NUM) {
                    $(this).remove();
                }
            });
        }

        $('.wrap input[type=checkbox]').prop('checked', false);
        $('#drop_select_prefecture').val('');

        resetTblDistrict();

        if ($(this).val() == 'type_switchboard') {
            $('#btnUploadCSVContainer').removeClass('green_buttons_disable');
            $('#btnUploadCSVContainer').addClass('green_buttons');
            $('#btnUploadCSVContainer').show();
        } else {
            $('#btnUploadCSVContainer').removeClass('green_buttons');
            $('#btnUploadCSVContainer').addClass('green_buttons_disable');
            $('#btnUploadCSVContainer').hide();
        }

        $('#create_by_switchboard span').html('');

        $("#RDDCreateForm").validate().resetForm();
    });

    $('#drop_select_prefecture').change(function() {
        resetTblDistrict();
        var keisai_flag = getKeisaiFlag();

        $('#btnChooseDistrictContainer').removeClass('green_buttons');
        $('#btnChooseDistrictContainer').addClass('green_buttons_disable');

        loadDistrictNum(keisai_flag);

        checkbox_checked = [];
    });

    $('#btnChooseDistrictContainer').click(function() {
        if (!$(this).hasClass('green_buttons_disable')) {
            $('#dialog_choose_district').dialog('open');

            position_katakana = [];
            $('#list_katakana th').each(function() {
                var id = $(this).html();
                if (typeof $('#' + id).position() != 'undefined') {
                    position_katakana[id] = $('#' + id).position().top;
                }
            });

            recheckCheckboxDistrict();
        }
    });

    $('#btnCloseDialog').click(function() {
        $('#dialog_choose_district').dialog('close');
        processCloseDialog();
    });

    $('#btnCancelDialog').click(function() {
        $('#dialog_choose_district').dialog('close');
    });

    $('#btnOK').click(function() {
        $('.flash_msg').html('');
        setDisabled();
        if ($('#RDDCreateForm').valid()) {
            $.ajax({
                type: 'POST',
                url: appRoot + 'RDD/check_exist_listname',
                async: false,
                data: {
                    list_name: function() {
                        return $("#ipListName").val();
                    },
                    quantity_list: function() {
                        return $("#ipNumList").val();
                    }
                },
                error: function () {},
                success: function (data1) {
                    if (data1 == 'false') {
                        $('#ipListName-error').html('指定されたリスト名はすでに登録されています。');
                        $('#ipListName-error').show();
                        $('#ipListName').focus();
                    } else {
                        if (confirm('作成します。よろしいですか？')) {
                            var data = $('form').serialize();

                            display_load();

                            $.ajax({
                                type: 'POST',
                                url: appRoot + 'RDD/create_call_list',
                                //async: false,
                                data: data,
                                error: function () {
                                    $.unblockUI();
                                    alert('作成が失敗しました。');
                                    $('#right_content').animate({scrollTop : 0}, 'slow');
                                },
                                success: function (data) {
                                    $.unblockUI();
                                    if (data == 'success') {
                                        alert('作成が完了しました。');
                                        $('#right_content').animate({scrollTop : 0}, 'slow');
                                    } else if (data == 'error') {
                                        alert('作成が失敗しました。');
                                        $('#right_content').animate({scrollTop : 0}, 'slow');
                                    }
                                }
                            });
                        }
                    }
                }
            });
        }
        setEnabled();
    });

    $('#btnUploadCSV').click(function() {
        $('#file_to_upload').val('');
        $('#file_to_upload').click();
    });

    $('#file_to_upload').change(function(e) {
        var keisai_flag = getKeisaiFlag();

        if ($('#file_to_upload').val() == '') {
            return false;
        }
        var ext = $("#file_to_upload").val().split(".").pop().toLowerCase();

        if ($.inArray(ext, ["csv", "txt"]) == -1) {
            alert('ファイル形式が正しくありません。CSV形式でアップロードしてください。');
            $('#right_content').animate({scrollTop : 0}, 'slow');
            return false;
        }

        if (e.target.files != undefined) {
            var count_row_input = $('#create_by_switchboard .inner_table tr').size();

            if ($('#create_by_switchboard input[type=text]').size() > 0) {
                $('#create_by_switchboard input[type=text]').val('').valid();
            }

            $('#create_by_switchboard .inner_table tr').each(function(index) {
                $(this).remove();
            });

            var reader = new FileReader();
            reader.onload = function(e) {
                display_load();
                var csvval = e.target.result.split("\n");
                var index = 0;
                var data_csv = [];
                for (var i=0; i<csvval.length; i++) {
                    if (csvval[i].length > 0 && csvval[i] != '\r' && csvval[i] != '') {
                        var csvvalue = csvval[i].replace(/["' 　\r]/g,'').split(',');

                        if (csvvalue[0] != '' || csvvalue[1] != ''){
                            index = index + 1;
                            data_csv[index] = csvvalue;
                        }
                    }
                }

                if (data_csv.length > 0) {
                    var listSixDigit = [];
                    for (var i = 1; i < data_csv.length; i++) {
                        addRowForSwitchboard(i);

                        $('#create_by_switchboard').find('.inner_table').find('tr').eq(i-1).find('.ipSixDigit').first().val(data_csv[i][0]);
                        $('#create_by_switchboard').find('.inner_table').find('tr').eq(i-1).find('.ipNumSixDigit').first().val(data_csv[i][1]);
                        $('#ipTotal').valid();

                        var selector = $('#create_by_switchboard').find('.inner_table').find('tr').eq(i-1).find('.ipSixDigit').first();
                        selector.parent().children('span').first().html('');
                        selector.rules('remove', 'checkHadTel');

                        if (selector.val() != '' && selector.valid()) {
                            listSixDigit[i] = selector.val();
                        }
                    }

                    if (listSixDigit.length > 0) {
                        $.ajax({
                            type: 'POST',
                            url: appRoot + 'RDD/get_tel_num2',
                            data: {
                                listSixDigit: listSixDigit,
                                keisai_flag: keisai_flag
                            },
                            success: function(data) {
                                var results = JSON.parse(data);

                                for (var i = 1; i < data_csv.length; i++) {
                                    if (typeof results[i] != 'undefined') {
                                        var selector = $('#create_by_switchboard').find('.inner_table').find('tr').eq(i-1).find('.ipSixDigit').first();
                                        var limit = parseInt(results[i]);
                                        selector.rules("add", {checkHadTel: limit});
                                        if(limit > 0) {
                                            selector.parent().children('span').first().html('(' + limit + ')');
                                        } else {
                                            selector.parent().children('span').first().html('');
                                        }

                                        if (limit > 0) {
                                            selector = $('#create_by_switchboard').find('.inner_table').find('tr').eq(i-1).find('.ipNumSixDigit').first();
                                            selector.attr('max_value', limit);
                                            validateNumSixDigit(selector, MAX_QUANTITY_SWITCHBOARD);
                                        }
                                    }
                                    $('#create_by_switchboard').find('.inner_table').find('tr').eq(i-1).find('.ipSixDigit').first().valid();
                                    $('#create_by_switchboard').find('.inner_table').find('tr').eq(i-1).find('.ipNumSixDigit').first().valid();
                                }

                                $.unblockUI();
                                alert('ファイルアップしました。');
                                $('#right_content').animate({scrollTop : 0}, 'slow');
                            },
                        });
                    } else {
                        $.unblockUI();
                        alert('ファイルアップしました。');
                        $('#right_content').animate({scrollTop : 0}, 'slow');
                    }

                    changeTotalItem();
                } else {
                    $.unblockUI();
                    alert('ファイルアップしました。');
                    $('#right_content').animate({scrollTop : 0}, 'slow');
                }

/*                if ($('#create_by_switchboard .inner_table tr').size() < count_row_input) {
                    for (i=$('#create_by_switchboard .inner_table tr').size(); i < count_row_input; i++) {
                        addRowForSwitchboard(i + 1);
                    }
                }*/
            };
            reader.readAsText(e.target.files.item(0));
        }
        return false;
    });

    $('#btnAddSixDigit').click(function() {
        if ($('#create_by_switchboard').find('.inner_table').find('tr').size() > 0) {
            var index = parseInt($('#create_by_switchboard').find('tr').last().children('td').first().html()) + 1;
        } else {
            var index = 1;
        }

        addRowForSwitchboard(index);
    });

    bindInputSwitchboard();
    bindClickRemoveInput();
    bindInputNumItem();

    function getTelNum(selector, keisai_flag) {
        selector.rules('remove', 'checkHadTel');
        selector.valid();
        if (selector.val() != '' && selector.valid() && selector.val().length == 6) {
            $.ajax({
                type: 'POST',
                url: appRoot + 'RDD/get_tel_num',
                data: {
                    switchboard: selector.val(),
                    keisai_flag: keisai_flag,
                },
                success: function(data) {
                    var limit = parseInt(data);

                    selector.rules("add", {checkHadTel: limit});
                    selector.valid();
                    if(limit > 0) {
                        selector.parent().children('span').first().html('(' + limit + ')');
                    } else {
                        selector.parent().children('span').first().html('');
                    }
                    selector = selector.parent().parent().find('.ipNumSixDigit').first();
                    if (limit > 0) {
                        selector.attr('max_value', limit);
                        validateNumSixDigit(selector, MAX_QUANTITY_SWITCHBOARD);
                    }
                    if (selector.val() != '') {
                        selector.valid();
                    }
                },
            });
        } else {
            selector.parent().children('span').first().html('');
            selector = selector.parent().parent().find('.ipNumSixDigit').first();
            selector.attr('max_value', MAX_QUANTITY_SWITCHBOARD);
            validateNumSixDigit(selector, MAX_QUANTITY_SWITCHBOARD);
            selector.valid();
        }
    }

    function getPrefecture(keisai_flag) {
        display_load();
        $.ajax({
            type: 'POST',
            url: appRoot + 'RDD/getPrefecture',
            // async: false,
            data: {keisai_flag: keisai_flag},
            success: function(data) {
                prefecture_data = $.parseJSON(data);
                for (var i = 0; i < prefecture_data.length; i++) {
                    tel_num = 0;
                    if (keisai_flag) {
                        if(prefecture_data[i].T71Prefecture.num_keisai > 0){
                            tel_num = prefecture_data[i].T71Prefecture.num_keisai;
                        }
                    } else {
                        if(prefecture_data[i].T71Prefecture.num > 0){
                            tel_num = prefecture_data[i].T71Prefecture.num;
                        }
                    }
                    $("#prefecture_num_"+i).html('（'+tel_num+'）')
                    selector = $("#prefecture_num_"+i).parent().parent().find('.ipNumItem').first();
                    selector.attr('max_value', tel_num);
                    selector.attr('top_limit', prefecture_data[i][0].top_limit);
                    validateNumPrefecture(selector, MAX_TEL_NO);

                    if (selector.val() != '') {
                        selector.valid();
                    }
                }
                $.unblockUI();
            }
        });
    }

    function loadDistrictNum(keisai_flag) {
        if ($('#drop_select_prefecture').val() != '') {
            display_load();
            $.ajax({
                type: 'POST',
                url: appRoot + 'RDD/load_list_district',
                // async: false,
                data: {
                    prefecture_code: $('#drop_select_prefecture').val(),
                    keisai_flag: keisai_flag
                },
                error: function (XHR, status, errorThrown) {
                    $.unblockUI();
                },
                success: function (data) {
                    $('#list_checkbox_district').html(data);
                    $('#btnChooseDistrictContainer').removeClass('green_buttons_disable');
                    $('#btnChooseDistrictContainer').addClass('green_buttons');
                    $.unblockUI();
                }
            });

            $('#dialog_choose_district').dialog('option', 'title', $('#drop_select_prefecture option:selected').html());
        }
    }

    function getDistrictNum(district_code_arr, keisai_flag) {
        display_load();
        $.ajax({
            type: 'POST',
            url: appRoot + 'RDD/getDistrictNum',
            // async: false,
            data: {
                district_code_arr: district_code_arr,
            },
            error: function (XHR, status, errorThrown) {
                $.unblockUI();
            },
            success: function (data) {
                district_data = $.parseJSON(data);
                for (var i = 0; i < district_data.length; i++) {
                    tel_num = 0;
                    str = "";
                    str += district_data[i].T72District.district_name + '（';
                    if (keisai_flag == "1") {
                        tel_num = district_data[i].T72District.num_keisai;
                    } else {
                        tel_num = district_data[i].T72District.num;
                    }
                    str += tel_num + '）';

                    $("#td_district_"+district_data[i].T72District.district_code).html(str);

                    selector = $("#district_"+district_data[i].T72District.district_code);
                    selector.attr('max_value', tel_num);
                    validateNumSixDigit(selector, MAX_TEL_NO);

                    if (selector.val() != '') {
                        selector.valid();
                    }
                };
                $.unblockUI();
            }
        });

    }

    $(document).on('click', '#list_katakana th', function() {
        if (!$(this).hasClass('district_disabled')) {
            var id = $(this).html();
            var first_th_kata = $('#tbl_list_district th').first().attr('id');
            var sroll_height = position_katakana[id] - position_katakana[first_th_kata];

            $('html, .select_district_area').animate({scrollTop : sroll_height}, 'slow');
        }
    });

    $(document).on('change', '#ipNumList', function() {
        $('.ipNumDistrict').each(function() {
            validateNumDistrict($(this), MAX_TEL_NO);
        });

        $('.ipNumPrefecture').each(function() {
            validateNumPrefecture($(this), MAX_TEL_NO);
        });

        $('.ipNumSixDigit').each(function() {
            validateNumSixDigit($(this), MAX_QUANTITY_SWITCHBOARD);
        });

        $('.ipNumItem').each(function() {
            if ($(this).val() != '') {
                $(this).valid();
            }
        });
    });

    $('#cbKeisai').change(function() {
        var keisai_flag = getKeisaiFlag();
        var district_code_arr = [];

        $(".ipSixDigit").each(function(i) {
            selector = $(this);
            getTelNum(selector, keisai_flag);
        });
        getPrefecture(keisai_flag);
        loadDistrictNum(keisai_flag);
        if ($('#dropTypeCreate').val() == 'type_district') {
            $(".ipNumDistrict").each(function(i) {
                str = "";
                tel_num = 0;
                if ($(this).attr("id") != "") {
                    district_code = $(this).attr("id").split("district_")[1];
                    if (district_code != "") {
                        district_code_arr.push(district_code);
                    }
                }
            })
            if(district_code_arr.length > 0){
                getDistrictNum(district_code_arr, keisai_flag);
            }
        }
    });

    setTypeCreate();

    function addRowForSwitchboard(index) {
        num_input_sixdigit = num_input_sixdigit + 1;
        var id_input = num_input_sixdigit;

        var str_ipSixDigit = '<tr>'
            + '<td>' + index + '</td>'
            + '<td>'
            + '<input type="text" name="data[data_switchboard][' + id_input + '][switchboard]" class="input_box_new input_120 ipSixDigit" id="switchboard_' + id_input + '" maxlength="' + SWITCHBOARD_LENGTH + '">'
            + ' <span></span>'
            + '<div class="err-mesg-20">'
            + '<label id="switchboard_' + id_input + '-error" class="error switchboard_error" for="switchboard_' + id_input + '"></label>'
            + '</div>'
            + '</td>'
            + '<td>'
            + '<input type="text" name="data[data_switchboard][' + id_input + '][quantity]" class="input_box_new input_120 ipNumItem ipNumSixDigit" id="ipNumSixDigit_' + id_input + '" maxlength="' + MAX_QUANTITY_SWITCHBOARD.toString().length + '">'
            + ' 件'
            + '<div style="float: right;">'
            + '<a href="#" class="btnRemoveInput"></a>'
            + '</div>'
            + '<div class="err-mesg-20">'
            + '<label id="ipNumSixDigit_' + id_input + '-error" class="error ipNumSixDigit_error" for="ipNumSixDigit_' + id_input + '"></label>'
            + '</div>'
            + '</td>'
            + '</tr>';

        $('#create_by_switchboard .inner_table').append(str_ipSixDigit);

        bindInputSwitchboard();
        bindClickRemoveInput();
        bindInputNumItem();

        $('#switchboard_' + id_input).rules("add", {
            myDigits: true,
            maxlength: SWITCHBOARD_LENGTH,
            checkSwitchboardFormat: true,
            checkSwitchboardExist: 'ipSixDigit',
            checkMustInput: 'ipNumSixDigit_' + id_input,
            messages: {
                myDigits: msg_error_switchboard,
                maxlength: msg_error_switchboard,
                checkSwitchboardFormat: msg_error_switchboard,
                checkSwitchboardExist: '同じ数字が入力されています。',
                checkMustInput: msg_error_switchboard,
            }
        });

        $('#ipNumSixDigit_' + id_input).attr('max_value', MAX_QUANTITY_SWITCHBOARD);

        validateNumSixDigit($('#ipNumSixDigit_' + id_input), MAX_QUANTITY_SWITCHBOARD);
    }

    function changeTotalItem() {
        var total_item_current = 0;

        $('.ipNumItem').each(function() {
            var number_item = 0;

            if ($(this).val() != '' && parseInt($(this).val())) {
                number_item = parseInt($(this).val());
            }

            if (number_item > 0) {
                total_item_current = total_item_current + number_item;
            }
        });

        if (total_item_current > 0) {
            $('#ipTotal').val(total_item_current);
        } else {
            $('#ipTotal').val('');
        }

        if ($('#ipTotal').val() != '') {
            $('#ipTotal').valid();
        }
    }

    function setTypeCreate() {
        var value = $('#dropTypeCreate').val();

        $('.type_create').hide();
        $('.' + value).show();
    }

    function resetTblDistrict() {
        $('#create_by_district .inner_table tr').each(function() {
            $(this).children('td').each(function(index) {
                if (index > 0) {
                    $(this).html('');
                }
            })
        })

        $('#ipTotal').val('');

        if ($('#drop_select_prefecture').val() != '') {
            $('#btnChooseDistrictContainer').removeClass('green_buttons_disable');
            $('#btnChooseDistrictContainer').addClass('green_buttons');
        } else {
            $('#list_checkbox_district').html('');
            $('#btnChooseDistrictContainer').removeClass('green_buttons');
            $('#btnChooseDistrictContainer').addClass('green_buttons_disable');
        }
    }

    function processCloseDialog() {
        var checkbox_checkeds = $('#tbl_list_district :checkbox:checked');
        var str= '';
        var district_name = '';
        var str_input = '';
        var str_hidden = '';
        var str_label = '';
        var total_item = 0;

        checkbox_checked = [];
        checkbox_checkeds.each(function(index) {
            checkbox_checked[$(this).val()] = 1;

            district_name = $(this).parent().children('.lbl_district_name').html();

            var value_old = '';
            var name = 'data[data_district][' + $(this).val() + '][quantity]';
            if (typeof $('input[name="' + name + '"]').val() != 'undefined' && $('input[name="' + name + '"]').val() != '') {
                value_old = $('input[name="' + name + '"]').val();
                total_item = total_item + parseInt(value_old);
            }

            str_hidden = '<input '
                + 'type="hidden" '
                + 'name="data[data_district][' + $(this).val() + '][district_code]" '
                + 'value="' + $(this).val() + '">';

            str_input = '<input '
                + 'type="text" '
                + 'name="data[data_district][' + $(this).val() + '][quantity]" '
                + 'value="' + value_old + '" '
                + 'max_value="' + $(this).attr('tel_no') + '" '
                + 'class="input_box_new input_120 ipNumItem ipNumDistrict" '
                + 'id="district_' + $(this).val() +'" maxlength="' + MAX_LENGTH_OF_QUANTITY + '"> 件';

            str_label = '<div class="err-mesg-20">'
                + '<label id="district_' + $(this).val() + '-error" class="error" for="district_' + $(this).val() + '"></label>'
                + '</div>';

            str = str
                + '<tr>'
                + '<td>' + (index + 1) +  '</td>'
                + '<td id="td_district_' + $(this).val() + '">' + district_name + '</td>'
                + '<td>' + str_hidden + str_input + str_label + '</td>'
                + '</tr>';
        });

        $('#create_by_district .inner_table tr').remove();
        $('#create_by_district .inner_table').append(str);

        $(".ipNumDistrict").each(function() {
            validateNumDistrict($(this), MAX_TEL_NO);
        });

        if (checkbox_checkeds.size() < DEFAULT_ROW_NUM) {
            for (index=checkbox_checkeds.size(); index < DEFAULT_ROW_NUM; index++) {
                str = '<tr>'
                    + '<td>' + (index + 1) +  '</td>'
                    + '<td></td>'
                    + '<td></td>'
                    + '</tr>';
                $('#create_by_district .inner_table').append(str)
            }
        }

        if (total_item > 0) {
            $('#ipTotal').val(total_item);
        } else {
            $('#ipTotal').val('');
        }

        bindInputNumItem();
    }

    function recheckCheckboxDistrict() {
        $('#tbl_list_district :checkbox:checked').each(function() {
            $(this).prop('checked', false);
        });

        $('#tbl_list_district :checkbox').each(function() {
            if (typeof checkbox_checked[$(this).val()] != 'undefined') {
                $(this).prop('checked', true);
            }
        });
    }

    function validateNumSixDigit(selector, max_default) {
        var quantity_list = getQuantityList();
        var max_value = parseInt((selector.attr('max_value')) / quantity_list);

        if (quantity_list > 1 && max_value < max_default) {
            var limit = max_value;
            var msg_err = quantity_list + 'リストの為' + limit + '以下の数字を入力してください。';
        } else {
            var limit = max_value < max_default ? max_value : max_default;
            var msg_err = '' + limit + '以下の数字を入力してください。';
        }

        selector.rules("add", {
            myDigits: true,
            maxlength: max_default.toString().length,
            checkQuantityItemByParam: selector.attr('max_value'),
            checkMustInput: selector.parent().parent().find('.ipSixDigit').first().attr('id'),
            messages: {
                myDigits: msg_err,
                maxlength: msg_err,
                checkQuantityItemByParam: msg_err,
                checkMustInput: msg_err,
            }
        });
    }

    function validateNumDistrict(selector, max_default) {
        var quantity_list = getQuantityList();
        var max_value = parseInt((selector.attr('max_value')) / quantity_list);

        if (quantity_list > 1 && max_value < max_default) {
            var limit = max_value;
            var msg_err = quantity_list + 'リストの為' + limit + '以下の数字を入力してください。';
        } else {
            var limit = max_value < max_default ? max_value : max_default;
            var msg_err = '' + limit + '以下の数字を入力してください。';
        }

        selector.rules("add", {
            myDigits: true,
            maxlength: max_default.toString().length,
            checkQuantityItemByParam: selector.attr('max_value'),
            checkQuantityItem: max_default,
            messages: {
                myDigits: msg_err,
                maxlength: msg_err,
                checkQuantityItemByParam: msg_err,
                checkQuantityItem: '' + max_default + '以下の数字を入力してください。'
            }
        });
    }

    function validateNumPrefecture(selector, max_default) {
        var quantity_list = getQuantityList();
        var max_value = parseInt((selector.attr('max_value')) / quantity_list);

        if (quantity_list > 1 && max_value < max_default) {
            var limit = max_value;
            var msg_err = quantity_list + 'リストの為' + limit + '以下の数字を入力してください。';
        } else {
            var limit = max_value < max_default ? max_value : max_default;
            var msg_err = '' + limit + '以下の数字を入力してください。';
        }

        var min = selector.attr('bottom_limit');
        var max = Math.floor(selector.attr('top_limit')/quantity_list);

        selector.rules("add", {
            myDigits: true,
            maxlength: max_default.toString().length,
            checkQuantityItem: max_default,
            checkMinNumPrefecture: true,
            checkMaxNumPrefecture: true,
            messages: {
                myDigits: msg_err,
                maxlength: msg_err,
                checkQuantityItem: max_default + '以下の数字を入力してください。',
                checkMinNumPrefecture: '5000以上の数字を入力してください。',
                checkMaxNumPrefecture: max + '以下の数字を入力してください。'
            }
        });
    }

    function getQuantityList() {
        var quantity_list = 1;
        if (/[1-9][0-9]*$/.test($('#ipNumList').val())) {
            quantity_list = parseInt($('#ipNumList').val());
        }

        return quantity_list;
    }

    function getKeisaiFlag() {
        var keisai_flag = 0;
        if (document.getElementById('cbKeisai').checked) {
            keisai_flag = 1;
        }

        return keisai_flag;
    }

    function bindInputSwitchboard() {
        $('.ipSixDigit').unbind();
        $('.ipSixDigit').bind('input', function() {
            if ($(this).val() != six_digit_old[$(this).attr('id')]) {
                six_digit_old[$(this).attr('id')] = $(this).val();

                var selector = $(this);
                var keisai_flag = getKeisaiFlag();
                getTelNum(selector, keisai_flag);
                $('.ipSixDigit').each(function () {
                    if ($(this).val() != '' && $('label[for="' + $(this).attr('id') + '"]').html() == '同じ数字が入力されています。') {
                        var selector = $(this);
                        if (selector.valid()) {
                            $.ajax({
                                type: 'POST',
                                url: appRoot + 'RDD/get_tel_num',
                                async: false,
                                data: {
                                    switchboard: selector.val(),
                                    keisai_flag: keisai_flag,
                                },
                                success: function (data) {
                                    var limit = parseInt(data);

                                    selector.rules("add", {checkHadTel: limit});
                                    selector.valid();
                                    if (limit > 0) {
                                        selector.parent().children('span').first().html('(' + limit + ')');
                                    } else {
                                        selector.parent().children('span').first().html('');
                                    }

                                    selector = selector.parent().parent().find('.ipNumSixDigit').first();
                                    if (limit > 0) {
                                        selector.attr('max_value', limit);
                                        validateNumSixDigit(selector, MAX_QUANTITY_SWITCHBOARD);
                                    }
                                    if (selector.val() != '') {
                                        selector.valid();
                                    }
                                },
                            });
                        }
                    }
                })
            }
        });
    }

    function bindInputNumItem() {
        $('.ipNumItem').unbind();
        $('.ipNumItem').bind('input', function() {
            $(this).valid();
            changeTotalItem();
            $('#ipTotal').valid();

            if ($(this).hasClass('ipNumSixDigit') && $(this).val() == '') {
                var selector = $(this).parent().parent().find('.ipSixDigit').first();
                selector.valid();
            }
        });
    }

    function bindClickRemoveInput() {
        $('.btnRemoveInput').unbind();
        $('.btnRemoveInput').bind('click', function () {
            var ipSixDigit = $(this).parent().parent().parent().find('.ipSixDigit').first();
            var ipNumSixDigit = $(this).parent().parent().parent().find('.ipNumSixDigit').first();

            if (ipSixDigit.val() != '' && $('label[for=' + ipSixDigit.attr('id')).html() == ''
                && ipNumSixDigit.val() != '' && $('label[for=' + ipNumSixDigit.attr('id')).html() == ''
                && !confirm('削除します。よろしいですか？')) {
                return false;
            }

            $(this).parent().parent().parent().remove();
            var index = parseInt($(this).parent().parent().parent().children('td').first().html());

            $('#create_by_switchboard').find('.inner_table').find('tr').each(function () {
                if (parseInt($(this).find('td').first().html()) > index) {
                    $(this).find('td').first().html(index);
                    index++;
                }
            });

            var sixDigit = $(this).parent().parent().parent().find('.ipSixDigit').first().val();
            var keisai_flag = getKeisaiFlag();

            $('.ipSixDigit').each(function () {
                if ($(this).val() != '' && $(this).val() == sixDigit) {
                    var selector = $(this);
                    if (selector.valid()) {
                        $.ajax({
                            type: 'POST',
                            url: appRoot + 'RDD/get_tel_num',
                            async: false,
                            data: {
                                switchboard: selector.val(),
                                keisai_flag: keisai_flag,
                            },
                            success: function (data) {
                                var limit = parseInt(data);

                                selector.rules("add", {checkHadTel: limit});
                                selector.valid();
                                if (limit > 0) {
                                    selector.parent().children('span').first().html('(' + limit + ')');
                                } else {
                                    selector.parent().children('span').first().html('');
                                }

                                selector = selector.parent().parent().find('.ipNumSixDigit').first();
                                if (limit > 0) {
                                    selector.attr('max_value', limit);
                                    validateNumSixDigit(selector, MAX_QUANTITY_SWITCHBOARD);
                                }
                                if (selector.val() != '') {
                                    selector.valid();
                                }
                            },
                        });
                    }
                }
            })

            changeTotalItem();
            $('#ipTotal').valid();
        });
    }
});