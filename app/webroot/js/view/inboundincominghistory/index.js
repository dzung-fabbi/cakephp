var page = 0, column = "";

$(document).ready(function() {
/*    if(!$("#cbFunction").length){
        column = [[0,1]];
    }*/

    if($("#hdPageSettingInbound").val()){
        page = parseInt($("#hdPageSettingInbound").val());
    }
    if($("#hdSortColumnSettingInbound").val() && $("#hdSortTypeSettingInbound").val()){
        column = [[parseInt($("#hdSortColumnSettingInbound").val()), parseInt($("#hdSortTypeSettingInbound").val())]];
    }
    $("#settingInboundTable").tablesorter({
        theme: 'gold',
        widthFixed: true,
        sortLocaleCompare: true,
        sortList: column,
        widgets: ['zebra', 'filter']
    }).tablesorterPager({
        container: $(".pager"),
        type: "POST",
        ajaxUrl: appRoot + "InboundIncomingHistory/arr_setting_inbound/{page}/20/{sortList:column}?{filterList:filter}",
        ajaxObject: {
            cache: false,
            dataType: 'json'
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

    $(document).on('hidden.bs.modal', '#dialogAddSettingInbound', function () {
        $("#form_add_setting_inbound").validate().resetForm();
    });

    $(document).on('click', '#add_setting_inbound', function () {
        $('.alert').hide();
        var data_ajax = {
            action: 'add'
        };
        form_create_setting_inbound(data_ajax);
    });
    $(document).on('click', '#btn_submit', function () {
        if($("#form_add_setting_inbound").valid()) {
            var action = $(this).attr("action");
            var external_number = $("#external_number").val();
            var template_id = $("#template_id").val();
            var list_ng_id = $("#list_ng_id").val();
            var list_id = $("#list_id").val();
            var msg_confirm = "";

            if(action == "create"){
                msg_confirm = INBOUND_MSG_CONFIRM_CREATE;
            } else if(action == "duplicate"){
                msg_confirm = INBOUND_MSG_CONFIRM_DUPLICATE;
            }

            if ($("#form_add_setting_inbound").valid()){
                $("#dialog_end_call-error").html("");
                $.ajax({
                    type: "POST",
                    url:appRoot+"InboundIncomingHistory/check_info_setting_inbound",
                    data: {
                        external_number: external_number,
                        template_id: template_id,
                        list_ng_id: list_ng_id,
                        list_id: list_id,
                        action: action
                    },
                    async: false,
                    success:function(data){
                        var arr = $.parseJSON(data);
                        var result = arr.result;
                        if (result == "err_lock_external_number") {
                            alert(INBOUND_MSG_ALERT_EXTERNAL_NUMBER_LOCKED);
                        } else if (result == "err_number_set_busy") {
                            alert('対象電話番号は既にbusyを設定しました。');
                        } else if (result == "err_exist_template") {
                            alert(INBOUND_MSG_ALERT_NOT_EXIST_TEMPLATE);
                            window.location.href = appRoot+"InboundIncomingHistory/index/";
                        } else if(result == "err_exist_list_ng") {
                            alert(INBOUND_MSG_ALERT_NOT_EXIST_LIST_NG);
                            window.location.href = appRoot+"InboundIncomingHistory/index/";
                        } else if(result == "err_exist_list") {
                            alert(INBOUND_MSG_ALERT_NOT_EXIST_LIST);
                            window.location.href = appRoot+"InboundIncomingHistory/index/";
                        } else if(result == "err_lock_template") {
                            alert(INBOUND_MSG_ALERT_TEMPLATE_LOCKED);
                        } else if(result == "err_lock_call_list_ng") {
                            alert(INBOUND_MSG_ALERT_LIST_NG_LOCKED);
                        } else if(result == "err_lock_call_list") {
                            alert(INBOUND_MSG_ALERT_LIST_LOCKED);
                        } else if(result == "err_exist_item") {
                            alert('指定したテンプレートは着信リストに下記のどれかの項目が存在しないため登録出来ません。\n　・音声合成読み上げ項目\n　・文字列認証項目\n　・数値認証項目\n　・SMS挿入項目');
                        } else if(result == "err_match_main_item") {
                            alert('着信リストにテンプレートの対象照合項目が存在しません。');
                        } else if(result == "err_proc_num") {
                            alert('テンプレートの転送先席数設定がch数を超えています。');
                        } else if(result == "err_set_bukken_company_id") {
                            alert('指定している発信番号では物件セクションを含んだテンプレートは設定できません。');
                        }else if(result == "err_sms_illegal_url_string") {
                            alert(SMS_ILLEGAL_STRING_IN_BODY_URL);
                        }else if(result == "err_sms_over_url_length") {
                            alert(SMS_BODY_ITEM_REACH_LIMIT_SHORT_URL);
                        } else if(result == "err_sms_over_length") {
                            alert(INBOUND_SMS_BODY_ITEM_REACH_LIMIT);
                        } else if(result == "err_inbound_collation") {
                            alert(INBOUND_COLLATION_ERROR);
                        } else if (result == "err_get_lock_external_number") {
                                alert(INBOUND_MSG_ALERT_EXTERNAL_NUMBER_GET_LOCKED);
                        }else {
                            if (confirm(msg_confirm)){
                                $.ajax({
                                    type: "POST",
                                    url:appRoot+"InboundIncomingHistory/save/" + action,
                                    data: $("#form_add_setting_inbound").serialize(),
                                    beforeSend: function(){
                                        display_load();
                                    },
                                    success: function(data){
                                        $.unblockUI();
                                        var arr = $.parseJSON(data);
                                        var result = arr.result;
                                        if(result == "success"){
                                            window.location.href = appRoot+"InboundIncomingHistory/index/success";
                                        }else if(result == "error_batch"){
                                            alert('エラーを発生しました。');
                                        }else{
                                            alert(INBOUND_MSG_ALERT_SAVE_ERROR);
                                        }
                                    }
                                });
                            } else {
                                // キャンセルが押下された場合
                                // ロック解除処理を呼び出す
                                $.ajax({
                                    type: "POST",
                                    url:appRoot+"InboundIncomingHistory/save_canceled/",
                                    data: $("#form_add_setting_inbound").serialize(),
                                    beforeSend: function(){
                                        display_load();
                                    },
                                    success: function(){
                                        $.unblockUI();
                                    }
                                });
                            }
                        }
                    }
                });
            }
            //setEnabled();
            return false;
        }
    });
    $(document).on('click', '#btn_cancel', function () {
        $('#dialogAddSettingInbound').modal('hide');
    });

    $(document).on('click', '#btn_delete', function () {
        $('.alert').hide();
        if ($('input[type="checkbox"][setting_inbound_id]:checked').size() < 1) {
            $('#setting_inbound-error-message').find('p').text(INBOUND_MSG_ALERT_PLS_CHOOSE_INBOUND);
            $('#setting_inbound-error-message').show();
            return false;
        }

        var setting_inbound_ids = [];
        $('input[type="checkbox"][setting_inbound_id]:checked').each(function(index) {
            setting_inbound_ids[index] = $(this).attr("setting_inbound_id");
        });

        $.ajax({
            type: "POST",
            url:appRoot+"InboundIncomingHistory/check_delete_setting_inbound/",
            data: {
                setting_inbound_ids: setting_inbound_ids,
            },
            async: false,
            success:function(data){
                var result = JSON.parse(data);
                var status = result['status'];

                if (status == "err_not_exist"){
                    alert(INBOUND_MSG_ALERT_NOT_EXIST_INBOUND);
                    location.reload();
                    return;
                } else if (status == "err_status_can_not_delete"){
                    $('#setting_inbound-error-message').find('p').text(INBOUND_MSG_ALERT_CANNOT_DEL_INBOUND);
                    $('#setting_inbound-error-message').show();
                    return;
                } else {
                    if (confirm(INBOUND_MSG_CONFIRM_DEL)){
                        display_load();

                        var url=appRoot+"InboundIncomingHistory/delete";
                        $("#T25SettingInboundIndexForm").attr('action', url);
                        $("#T25SettingInboundIndexForm").attr('method', 'post');
                        $("#T25SettingInboundIndexForm").attr('enctype', 'multipart/form-data');

                        $('input[name="setting_inbound_ids[]"]').remove();
                        $('input[type="checkbox"][setting_inbound_id]:checked').each(function() {
                            var setting_inbound_ids = document.createElement("input");
                            setting_inbound_ids.type = 'hidden';
                            setting_inbound_ids.name = 'setting_inbound_ids[]';
                            setting_inbound_ids.value = $(this).attr("setting_inbound_id");
                            $("#T25SettingInboundIndexForm").append(setting_inbound_ids);
                        });

                        $('input[type="checkbox"]:checked').prop('checked', false);
                        $("#T25SettingInboundIndexForm").submit();
                    } else {
                        return;
                    }
                }
            },
        });
    });

    $(document).on('change', '#select_type_download', function () {
        $('.alert').hide();
        var func_name = $(this).val();

        if (func_name == 'select_download') {
            return false;
        }

        var setting_inbound_ids = [];
        $('input[type="checkbox"][setting_inbound_id]:checked').each(function(index) {
            setting_inbound_ids[index] = $(this).attr("setting_inbound_id");
        });

        if (setting_inbound_ids.length < 1) {
            $('#setting_inbound-error-message').find('p').text(INBOUND_MSG_ALERT_PLS_CHOOSE_INBOUND);
            $('#setting_inbound-error-message').show();
            $("#select_type_download").val("select_download").trigger('chosen:updated');
            return false;
        }

		var flag_can_download = true;
		if (func_name == 'download_uncalled') {
			$.ajax({
				url: appRoot + "InboundIncomingHistory/check_download_uncall/",
				type: "post",
				data: {
					schedule_ids: setting_inbound_ids,
				},
				async: false,
				success: function(result){
					if(result != "can_download"){
						alert(INBOUND_MSG_ALERT_CANNOT_DOWNLOAD_INBOUND);
						flag_can_download = false;
						$("#select_type_download").val("select_download").trigger('chosen:updated');
						return false;
					}
				}
			});
		}

		if (flag_can_download) {
			$.ajax({
				type: "POST",
				url:appRoot+"InboundIncomingHistory/check_download_schedule/",
				data: {
					schedule_ids: setting_inbound_ids,
				},
				async: false,
				success:function(status){
					if (status == 'can_download') {
						display_load();

						var url=appRoot+"InboundIncomingHistory/buffer_schedule_data/" + func_name;
						$.ajax({
							url: url,
							type: "post",
							data: {
								schedule_ids: setting_inbound_ids,
							},
							success: function(result){
								if(result == "success"){
									window.location.href = appRoot+"InboundIncomingHistory/download_schedule";
								}else{
									window.location.href = appRoot+"InboundIncomingHistory/index";
								}
								//$(":checkbox").prop('checked', false);
								setEnabled();
								$.unblockUI();
								$("#select_type_download").val("select_download").trigger('chosen:updated');
							}
						});
					} else if (status == "err_not_exist"){
						alert(INBOUND_MSG_ALERT_NOT_EXIST_INBOUND);
						location.reload();
					} else if (status == "err_status_can_not_download"){
						$('#setting_inbound-error-message').find('p').text(INBOUND_MSG_ALERT_CANNOT_DOWNLOAD_INBOUND);
						$('#setting_inbound-error-message').show();
						$("#select_type_download").val("select_download").trigger('chosen:updated');
						return;
					} else {
						alert(MSG_ALERT_SYSTEM_ERROR);
						location.reload();
					}
				},
			});
		}
    });

    $(document).on('click', '.lnkDuplicate', function () {
        var setting_inbound_id = $(this).attr("setting_inbound_id");
        $.ajax({
            type: "POST",
            url:appRoot+"InboundIncomingHistory/check_exist_setting_inbound",
            data: {
                id: setting_inbound_id,
            },
            async: false,
            success:function(data){
                if(data == "false"){
                    alert(INBOUND_MSG_ALERT_NOT_EXIST_INBOUND);
                    window.location.href = appRoot+"InboundIncomingHistory/index/";
                } else {
                    var data_ajax = {
                        action: 'duplicate',
                        id: setting_inbound_id,
                    };
                    form_create_setting_inbound(data_ajax);
                }
            }
        });
    });

    $(document).on('click', '.lnkStatistic', function () {
        var setting_inbound_id = $(this).attr('setting_inbound_id');
        $.ajax({
            type: "POST",
            url:appRoot+"InboundIncomingHistory/check_exist_setting_inbound",
            data: {
                id: setting_inbound_id,
            },
            async: false,
            success:function(data){
                if (data == "false") {
                    alert(INBOUND_MSG_ALERT_NOT_EXIST_INBOUND);
                    window.location.href = appRoot+"InboundIncomingHistory/index/";
                } else {
                    var ip = document.createElement('input');
                    ip.type = 'hidden';
                    ip.name = 'setting_inbound_id';
                    ip.value = setting_inbound_id;
                    var url = appRoot + 'InboundIncomingHistory/detail/'; // 20160413 Edit by Giang - #6906 Inbound history screen

                    display_load();

                    $('#T25SettingInboundIndexForm').attr('action', url);
                    $('#T25SettingInboundIndexForm').attr('method', 'post');
                    $('#T25SettingInboundIndexForm').attr('enctype', 'multipart/form-data');
                    $('#T25SettingInboundIndexForm').append(ip);
                    $('#T25SettingInboundIndexForm').submit();
                }
            }
        });
    });

    $(document).on('change', '#template_id', function () {
        process_change_template();
    });

    $('#bundleCheckbox').on('click', function() {
        toggleCheckStatus($(this));
    });
});

function process_change_template() {
    if ($("#template_id").val() === '0') {
        $('#list_ng_id').prop('disabled', true);
        $('#list_id').prop('disabled', true);
        $('#list_ng_id').val('');
        $('#list_id').val('');
    } else {
        $('#list_ng_id').prop('disabled', false);
        $('#list_id').prop('disabled', false);
    }
}

function form_create_setting_inbound(data_ajax) {
    $.ajax({
        type: "POST",
        url:appRoot+"InboundIncomingHistory/create",
        data: data_ajax,
        async: false,
        success:function(data){
            $('#form_container').html(data);
            $('#dialogAddSettingInbound').modal('show');
            validate_save_setting_inbound();
        }
    });
    process_change_template();
}

function validate_save_setting_inbound() {
    $("#form_add_setting_inbound").validate({
        ignore: "",
        rules:{
            "data[T25Inbound][external_number]": {
                required : true
            },
            "data[T25Inbound][template_id]": {
                required : true
            }
        },
        messages:{
            "data[T25Inbound][external_number]": {
                required : '電話番号を選択してください。'
            },
            "data[T25Inbound][template_id]": {
                required : '通常テンプレートを選択してください。'
            }
        }
    });
}
