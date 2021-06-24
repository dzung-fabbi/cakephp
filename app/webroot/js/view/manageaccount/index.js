$(document).ready(function() {
    var pulldown_data = {};
    $.ajax({
        type: "POST",
        url: appRoot + "ManageAccount/get_pull_down/",
        data: '',
        async: true,
        success: function (data) {
            pulldown_data = JSON.parse(data);
        }
    });
    jQuery.validator.addMethod("check_select", function(value, element){
        return value != '0';
    }, function(params, element) {
        return $(element).attr('data-msg-required');
    });
    jQuery.validator.addMethod("check_select_audio", function(value, element){
        return value != '';
    }, function(params, element) {
        return $(element).attr('data-msg-required');
    });
    jQuery.validator.addMethod("check_price", function(value, element){
        return this.optional(element) || /^[0-9]\d*(.\d{0,2})?$/.test(value);
    }, '数字を入力して、小数部は第2位まで入力してください。例：2.1、2.12');

    jQuery.validator.addMethod("check_exist_number", function(value, element){
        var result = true;
        all_numbers.forEach(function(val){
            if (val.M06CompanyExternal.external_number == value.replace(/\D/g, '')){
                result = false;
            }
        });
        return result;

    }, function(params, element) {
        return $(element).attr('data-msg-remote');
    });

    $('#form_add_edit_account').validate({
        ignore: "",
        rules: {
            'company_code':{
                required : true,
                remote: {
                    type: 'post',
                    url: appRoot + 'ManageAccount/check_duplicate_company_code',
                    async: false,
                    data: {
                        company_code: function() {
                            return $('#form_add_edit_account input[name="company_code"]').val();
                        }
                    }
                }

            },
            'audio_mix_flag':{
                check_select_audio : true
            }

        }
    });

    $('#form_add_edit_number').validate({
        ignore: "",
        rules:{
            'external_number': {
                required : true,
                checkTel: true,
                check_exist_number: true,
                remote: {
                    type: 'post',
                    url: appRoot + 'ManageAccount/check_duplicate_number',
                    async: false,
                    data: {
                        number: function() {
                            return $('#form_add_edit_number input[name="external_number"]').val().replace(/\D/g, '');
                        }
                    }
                }
            },
            'out_setup_sys': {
                check_select : true
            },
            'out_price': {
                required : true,
                check_price : true
            },
            'out_unit': {
                check_select : true
            },
            'out_phone': {
                required : true,
                check_price: true
            },
            'out_mobile': {
                required : true,
                check_price: true
            },
            /*'out_voice': {
                check_select : true
            },*/
            'in_setup_sys': {
                check_select : true
            },
            'in_price': {
                required : true,
                check_price: true
            },
            'in_unit': {
                check_select : true
            },
            'in_phone': {
                required : true,
                check_price: true
            },
            'in_mobile': {
                required : true,
                check_price: true
            },
            /*'in_voice': {
                check_select : true
            }*/
        },
        messages: {
            'external_number': {
                checkTel: '電話番号の形式が｢0｣で始まる半角「0-9」と「-」のみ使用できます。また、10または11桁を入力してください。'
            }
        }
    });

    {
        var page = 0, column = [[7,1]];
        if(!$("#btnDelete").length){
            column = [[6,1]];
        }
        if($("#hdPageAccount").val()){
            page = parseInt($("#hdPageAccount").val());
        }
        if($("#hdSortColumnAccount").val() && $("#hdSortTypeAccount").val()){
            column = [[parseInt($("#hdSortColumnAccount").val()), parseInt($("#hdSortTypeAccount").val())]];
        }
        $("#tblManageAccount").tablesorter({
            theme: 'gold',
            widthFixed: true,
            sortLocaleCompare: true,
            sortList: column,
            widgets: ['zebra', 'filter'],
            sortMultiSortKey: null
        }).tablesorterPager({
            container: $(".pager"),
            type: "POST",
            async: false,
            ajaxUrl: appRoot + "ManageAccount/arr_account/{page}/20/{sortList:column}?{filterList:filter}",
            ajaxObject: {
                cache: false,
                dataType: 'json',
            },
            ajaxProcessing: function(data){
                if (data && data.hasOwnProperty('rows')) {
                    var indx, r, row, c, d = data.rows,
                        total = data.total_rows,
                        headers = data.headers,
                        headerXref = headers.join(',').replace(/\s+/g,'').split(','),
                        rows = [],
                        len = d.length;
                    for ( r=0; r < len; r++ ) {
                        row = [];
                        for ( c in d[r] ) {
                            if (typeof(c) === "string") {
                                indx = $.inArray( c, headerXref );
                                if (indx >= 0) {
                                    row[indx] = d[r][c];
                                }
                            }
                        }
                        rows.push(row);
                    }
                    return [ total, rows ];
                }
            },
            processAjaxOnInit: true,
            output: '全 {totalRows} レコード　{startRow} ～ {endRow}',
            updateArrows: true,
            page: page,
            savePages: false,
            size: 20,
            fixedHeight: false,
            removeRows: false,
            cssNext        : '.next',
            cssPrev        : '.prev',
            cssFirst       : '.first',
            cssLast        : '.last',
            cssPageDisplay : '.pagedisplay',
            cssPageSize    : '.pagesize',
            cssErrorRow    : 'tablesorter-errorRow',
            cssDisabled    : 'disabled'
        });
        // $('.tablesorter-filter').last().addClass('disabled').attr('disabled', true);
    }

    if($("#hdPageAccount").val()){
        page = parseInt($("#hdPageAccount").val());
    }

    if($("#hdSortColumnAccount").val() && $("#hdSortTypeAccount").val()){
        column = [[parseInt($("#hdSortColumnAccount").val()), parseInt($("#hdSortTypeAccount").val())]];
    }
    //アカウント新規登録ボタン処理
    var max_number_id = 0;
    $('#btnCreateAccount').click(function() {
        $('.alert').hide();
        all_numbers = [];
        $.ajax({
            type: "POST",
            url: appRoot + "ManageAccount/get_max_id/",
            data: '',
            async: true,
            success: function (data) {
                $('#max_id').val(data);
            }
        });

        $('#dialog_add_edit_account').modal('show');
    });

    $('#dialog_add_edit_account').on('hidden.bs.modal', function (e) {
        if (on_show_flag) {
            $('#lbl_account_form').html('新規登録');
            $('#number_data').html('');
            $('#tblListNumber').addClass('hidden');
            $('label.error').html('');
            $("#dialog_add_edit_account input").each(function () {
                $(this).val('');
                $(this).removeClass('error');
                $(this).removeAttr('disabled');
            });
            $('#audio_mix_flag').val('');
            $('#audio_mix_flag').removeClass('error');
            $('#div_account').css('width', '600px');
        }
    });

    $('#btnCreateNumber').click(function() {
        $('#dialog_add_edit_number').modal('show');
    });
    var on_show_flag = true;
    $('#dialog_add_edit_number').on('show.bs.modal', function (e) {
        on_show_flag = false;
        $('#dialog_add_edit_account').modal('hide');
    });
    $('#dialog_add_edit_number').on('hidden.bs.modal', function (e) {
        on_show_flag = true;
        $('#dialog_add_edit_account').modal('show');
        $('#lbl_number_form').html('新規登録');
        $('label.error').html('');
        $("#dialog_add_edit_number input").each(function() {
            $(this).val('');
            $(this).removeClass('error');
            $(this).removeAttr('disabled');
        });
        $('#dialog_add_edit_number select').val(0);
        $('.error').removeClass('error');
    });

    var all_numbers = [];
    //アカウント保存処理
    $('#btnSave').click(function(){
        $('.alert').hide();
        if($('#form_add_edit_account').valid()) {
            var account_data = $('#form_add_edit_account').serializeArray();
            display_load();
            $.ajax({
                type: "POST",
                url: appRoot + "ManageAccount/add_edit_account/",
                data: {
                    data_account: account_data,
                    data_number: all_numbers,
                    delete: deleted_numbers
                },
                async: true,
                success: function (data) {
                    setEnabled();
                    $.unblockUI();
                    var results = JSON.parse(data);
                    if (results['status'] == 'insert') {
                        $('#account-success-message').find('p').text(MSG_ALERT_INSERT_ACCOUNT_SUCCESS);
                        $('#account-success-message').show();
                    } else if (results['status'] == 'update') {
                        $('#account-success-message').find('p').text(MSG_ALERT_UPDATE_ACCOUNT_SUCCESS);
                        $('#account-success-message').show();
                    } else {
                        alert(MSG_ALERT_SYSTEM_ERROR);
                        location.reload();
                    }

                    $('#dialog_add_edit_account').modal('hide');
                    reload_page(results['page'], results['sortColumn'], results['sortType']);
                    var validator = $("#form_add_edit_account").validate();
                    validator.resetForm();
                }
            });
            all_numbers = [];
        }

    });
    $(document).on('click', '#btnSaveNumber', function () {
        if($('#form_add_edit_number').valid()) {
            if ($('#post_code').val() == 'G30') {
                $('#div_add_number input').removeAttr('disabled');
                $('#div_add_number select').removeAttr('disabled');
            };
            var form_data = $('#form_add_edit_number').serializeArray();
            var number_data = {};
            $.each(form_data, function(i, item){
            	if (item.name == 'external_number') {
            		item.value = item.value.replace(/\D/g, '');
            	}
                number_data[item.name] = item.value;
            });

            if (number_data.id != null && number_data.id != ''){
                var ext_number = $('#external_number').val().replace(/\D/g, '');
                all_numbers.forEach(function(val, index){
                    if (val.M06CompanyExternal.external_number == ext_number){
                        var act;
                        if ('action' in all_numbers[index] && all_numbers[index]['action'] == 'create'){
                            act = 'create';
                        } else{
                            act = 'edit';
                        }
                        var company_id = $('#company_id').val();
                        all_numbers[index] = {
                            M06CompanyExternal: {
                                "id": number_data.id,
                                "company_id": company_id,
                                "external_number": ext_number,
                                "out_system": number_data.out_setup_sys,
                                "out_price": number_data.out_price,
                                "out_unit": number_data.out_unit,
                                "out_phone": number_data.out_phone,
                                "out_mobile": number_data.out_mobile,
                                // "out_voice": number_data.out_voice,
                                "in_system": number_data.in_setup_sys,
                                "in_price": number_data.in_price,
                                "in_unit": number_data.in_unit,
                                "in_phone": number_data.in_phone,
                                "in_mobile": number_data.in_mobile,
                                // "in_voice": number_data.in_voice
                            },
                            "action": act
                        };

                    }
                });
            } else {
                max_number_id = parseInt($('#max_id').val()) + 1;
                $('#max_id').val(max_number_id);
                var company_id = $('#company_id').val();
                var new_number = {
                    M06CompanyExternal: {
                        "id": max_number_id,
                        "company_id": company_id,
                        "external_number": number_data.external_number,
                        "out_system": number_data.out_setup_sys,
                        "out_price": number_data.out_price,
                        "out_unit": number_data.out_unit,
                        "out_phone": number_data.out_phone,
                        "out_mobile": number_data.out_mobile,
                        // "out_voice": number_data.out_voice,
                        "in_system": number_data.in_setup_sys,
                        "in_price": number_data.in_price,
                        "in_unit": number_data.in_unit,
                        "in_phone": number_data.in_phone,
                        "in_mobile": number_data.in_mobile,
                        // "in_voice": number_data.in_voice
                    },
                    "action": 'create'
                };
                all_numbers.push(new_number);
            }
            reload_number_data(all_numbers, pulldown_data);

            $('#tblListNumber').removeClass('hidden');
            $('#dialog_add_edit_number').modal('hide');

        }
    });

    $(document).on('click', '.btnEdit', function () {
        $('.alert').hide();
        $.ajax({
            type: "POST",
            url: appRoot + "ManageAccount/get_max_id/",
            data: '',
            async: true,
            success: function (data) {
                $('#max_id').val(data);
            }
        });
        var company_id = $(this).attr("company_id");
        $.ajax({
            type: "POST",
            url:appRoot+"ManageAccount/get_account_info/",
            async: false,
            data: {
                company_id: company_id
            },
            success:function(data){
                var results = JSON.parse(data);
                if(results.message == "not_exist"){
                    alert(MSG_ALERT_ACCOUNT_NOT_EXIST);
                    location.reload();
                }else{
                    $('#lbl_account_form').html('編集');
                    $('#id').val(results.data[0].M02Company.id);
                    $('#company_id').val(results.data[0].M02Company.company_id);
                    $('#company_code').val(results.data[0].M02Company.company_code);
                    $('#company_code').attr('disabled', 'disabled');
                    $('#company_name').val(results.data[0].M02Company.company_name);
                    $('#audio_mix_flag').val(results.data[0].M02Company.audio_mix_flag);
                    $('#max_redial').val(results.data[0].M02Company.max_redial);
                    all_numbers = results.data[1];
                    if (all_numbers.length > 0){
                        reload_number_data(all_numbers, pulldown_data);
                        $('#tblListNumber').removeClass('hidden');
                    }
                    if ($('#post_code').val() == 'G30'){
                        $('#company_name').attr('disabled', 'disabled');
                        $('#audio_mix_flag').attr('disabled', 'disabled');
                        $('#max_redial').attr('disabled', 'disabled');
                        $('#btnCreateNumber').hide();
                    }
                    $('#dialog_add_edit_account').modal('show');
                }
            }
        });
    });

    $(document).on('click', '#btnDelete', function () {
        $('.alert').hide();
        var cbDeletes = $('.cbDelete').serializeArray();
        var company_ids = [];
        $.each(cbDeletes, function(i, cbDelete) {
            company_ids[i] = cbDelete.value;
        });

        if (company_ids.length < 1) {
            $('#account-error-message').find('p').text(MSG_ALERT_PLS_CHOOSE_ACCOUNT);
            $('#account-error-message').show();
            return false;
        }else{
            $('#account-error-message').hide();
            if (confirm(MSG_CONFIRM_DELETE_ACCOUNT)) {
                $.ajax({
                    type: "POST",
                    url: appRoot + "ManageAccount/delete_account/",
                    async: false,
                    data: {
                        company_ids: company_ids
                    },
                    success: function (data) {
                        var results = JSON.parse(data);
                        if(results['message'] == 'company_not_exist'){
                            alert(MSG_ALERT_ACCOUNT_NOT_EXIST);
                            location.reload();
                        } else if (results['message'] == 'deleted') {
                            $('#account-success-message').find('p').text(company_ids.length + '件' + MSG_ALERT_DELETE_ACCOUNT_SUCCESS); /*20160311 Edit by Giang : #6695 - display the record quantity has been deleted*/
                            $('#account-success-message').show();
                        } else {
                            alert(MSG_ALERT_SYSTEM_ERROR);
                            location.reload();
                        }
                        reload_page(results['page'], results['sortColumn'], results['sortType']);
                    }
                });
            }
        }
    });

    //電話番号を編集ボタンクリック処理
    $(document).on('click', '.btnEditNumber', function () {
        var ext_number = $(this).attr('extnumber');
        var company_id = $('#company_id').val();
        $('#lbl_number_form').html('編集');
        all_numbers.forEach(function(val, index) {
            if (val.M06CompanyExternal.external_number == ext_number) {
                $('#number_id').val(all_numbers[index].M06CompanyExternal.id);
                $('#external_number').val(all_numbers[index].M06CompanyExternal.external_number);
                $('#external_number').attr('disabled', 'disabled');
                if (all_numbers[index].M06CompanyExternal.out_system != null && all_numbers[index].M06CompanyExternal.out_system != '') {
                    $('#out_setup_sys').val(all_numbers[index].M06CompanyExternal.out_system);
                }
                if (all_numbers[index].M06CompanyExternal.out_price != null && all_numbers[index].M06CompanyExternal.out_price != '') {
                    $('#out_price').val(all_numbers[index].M06CompanyExternal.out_price);
                }
                if (all_numbers[index].M06CompanyExternal.out_unit != null && all_numbers[index].M06CompanyExternal.out_unit != '') {
                    $('#out_unit').val(all_numbers[index].M06CompanyExternal.out_unit);
                }
                if (all_numbers[index].M06CompanyExternal.out_phone != null && all_numbers[index].M06CompanyExternal.out_phone != '') {
                    $('#out_phone').val(all_numbers[index].M06CompanyExternal.out_phone);
                }
                if (all_numbers[index].M06CompanyExternal.out_mobile != null && all_numbers[index].M06CompanyExternal.out_mobile != '') {
                    $('#out_mobile').val(all_numbers[index].M06CompanyExternal.out_mobile);
                }
                /*if (all_numbers[index].M06CompanyExternal.out_voice != null && all_numbers[index].M06CompanyExternal.out_voice != '') {
                    $('#out_voice').val(all_numbers[index].M06CompanyExternal.out_voice);
                }*/
                if (all_numbers[index].M06CompanyExternal.in_system != null && all_numbers[index].M06CompanyExternal.in_system != '') {
                    $('#in_setup_sys').val(all_numbers[index].M06CompanyExternal.in_system);
                }
                if (all_numbers[index].M06CompanyExternal.in_system != null && all_numbers[index].M06CompanyExternal.in_system != '') {
                    $('#in_price').val(all_numbers[index].M06CompanyExternal.in_price);
                }
                if (all_numbers[index].M06CompanyExternal.in_unit != null && all_numbers[index].M06CompanyExternal.in_unit != '') {
                    $('#in_unit').val(all_numbers[index].M06CompanyExternal.in_unit);
                }
                if (all_numbers[index].M06CompanyExternal.in_phone != null && all_numbers[index].M06CompanyExternal.in_phone != '') {
                    $('#in_phone').val(all_numbers[index].M06CompanyExternal.in_phone);
                }
                if (all_numbers[index].M06CompanyExternal.in_mobile != null && all_numbers[index].M06CompanyExternal.in_mobile != '' ) {
                    $('#in_mobile').val(all_numbers[index].M06CompanyExternal.in_mobile);
                }
                /*if (all_numbers[index].M06CompanyExternal.in_voice != null && all_numbers[index].M06CompanyExternal.in_voice != '') {
                    $('#in_voice').val(all_numbers[index].M06CompanyExternal.in_voice);
                }*/
            }
        });
        if($('#post_code').val() == 'G30'){
            $('#div_add_number input').attr('disabled', 'disabled');
            $('#div_add_number select').attr('disabled', 'disabled');
            $('#out_price').removeAttr('disabled');
            $('#in_price').removeAttr('disabled');
        }
        $('#dialog_add_edit_number').modal('show');

    });

    var deleted_numbers = [];
    $(document).on('click', '.btnDeleteNumber', function () {
        var ext_number = $(this).attr('extnumber');
        var company_id = $('#company_id').val();
        if (confirm(MSG_CONFIRM_DELETE_NUMBER)) {

            all_numbers.forEach(function(val, index) {
                if (val.M06CompanyExternal.external_number == ext_number) {
                    if ( !('action' in all_numbers[index]) || all_numbers[index].action != 'create'){
                        var deleted_number = {
                            "company_id": company_id,
                            "number": ext_number
                        };
                        deleted_numbers.push(deleted_number);
                    }
                    delete all_numbers[index];
                    return true;
                }
            });
            reload_number_data(all_numbers, pulldown_data);
        }

    });


});
function reload_page(page,sortColumn,sortType){
    var url = appRoot + "ManageAccount/arr_account/" + page + "/20/column?filter";
    if (sortColumn != null && sortType != null) {
        url = appRoot + "ManageAccount/arr_account/" + page + "/20/column[" + sortColumn + "]=" + sortType + "?filter";
    }

    $.ajax({
        type: "POST",
        url: url,
        cache: false,
        dataType: 'json',
        success:function(data){
            if (data && data.hasOwnProperty('rows')) {
                var json_data = new Object();
                json_data["headers"] = data.headers;
                json_data["total_rows"] = data.total_rows;
                json_data["rows"] = data.rows;
                $("#tblManageAccount").trigger("renderAjax", json_data);
                $("#tblManageAccount").trigger("update");
                $('#tblManageAccount').trigger('pagerUpdate');
            }
        }
    });
}

function reload_number_data(data, pulldown_data){
    $('#number_data').html('');
    if (data.length > 0){
        $('#div_account').css('width', '1100px');
    }

    data.forEach(function(val){
        var out_system, out_unit, in_system, in_unit;
        pulldown_data['out_system'].forEach(function(value){
            if (value.M90PulldownCode.item_code == val.M06CompanyExternal.out_system) {
                out_system = value.M90PulldownCode.item_name;
            };
        });
        pulldown_data['out_unit'].forEach(function(value){
            if (value.M90PulldownCode.item_code == val.M06CompanyExternal.out_unit) {
                out_unit = value.M90PulldownCode.item_name;
            };
        });
        /*pulldown_data['out_voice'].forEach(function(value){
            if (value.M90PulldownCode.item_code == val.M06CompanyExternal.out_voice) {
                out_voice = value.M90PulldownCode.item_name;
            };
        });*/
        pulldown_data['in_system'].forEach(function(value){
            if (value.M90PulldownCode.item_code == val.M06CompanyExternal.in_system) {
                in_system = value.M90PulldownCode.item_name;
            };
        });
        pulldown_data['in_unit'].forEach(function(value){
            if (value.M90PulldownCode.item_code == val.M06CompanyExternal.in_unit) {
                in_unit = value.M90PulldownCode.item_name;
            };
        });
       /*pulldown_data['in_voice'].forEach(function(value){
            if (value.M90PulldownCode.item_code == val.M06CompanyExternal.in_voice) {
                in_voice = value.M90PulldownCode.item_name;
            };
        });*/

        var append_data = '<tr>';
        append_data += '<td rowspan="2" class="text-center">'+val.M06CompanyExternal.id+'</td>';
        append_data += '<td rowspan="2" class="text-center">'+val.M06CompanyExternal.external_number+'</td>';
        append_data += '<td class="text-center">out</td>';
        append_data += '<td class="text-center">'+out_system+'</td>';
        append_data += '<td class="text-center">'+val.M06CompanyExternal.out_price+'</td>';
        append_data += '<td class="text-center">'+out_unit+'</td>';
        append_data += '<td class="text-center">'+val.M06CompanyExternal.out_phone+'</td>';
        append_data += '<td class="text-center">'+val.M06CompanyExternal.out_mobile+'</td>';
        // append_data += '<td class="text-center">'+out_voice+'</td>';
        append_data += '<td rowspan="2" class="text-center"><div><a href="javascript:void(0);" ' +
            'class="iconFormat lnkEdit btnEditNumber" extnumber="'+val.M06CompanyExternal.external_number+'" >' +
            '<i title="編集" data-toggle="tooltip" class="glyphicon glyphicon-edit icon-white" ></i></a>' +
            '<a href="javascript:void(0);" class="iconFormat lnkEdit btnDeleteNumber" ' +
            'extnumber="'+val.M06CompanyExternal.external_number+'">' +
            '<i title="削除" data-toggle="tooltip" class="glyphicon glyphicon-trash icon-white" ></i></a>' +
            '</div></td>';

        append_data += '</tr><tr>';
        append_data += '<td class="text-center">in</td>';
        append_data += '<td class="text-center">'+in_system+'</td>';
        append_data += '<td class="text-center">'+val.M06CompanyExternal.in_price+'</td>';
        append_data += '<td class="text-center">'+in_unit+'</td>';
        append_data += '<td class="text-center">'+val.M06CompanyExternal.in_phone+'</td>';
        append_data += '<td class="text-center">'+val.M06CompanyExternal.in_mobile+'</td>';
        // append_data += '<td class="text-center">'+in_voice+'</td>';
        append_data += '</tr>';
        $('#number_data').append(append_data);

    });
    if ($('#post_code').val() == 'G30'){
        $('.btnDeleteNumber').hide();
    }
}