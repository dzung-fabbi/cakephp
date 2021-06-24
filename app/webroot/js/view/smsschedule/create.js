var scheduler_inited = false;

$(document).ready(function() {
    MIN_DISTANCE_CALL_TIME = min_call_time * 1000; //millisecond

    $.validator.addMethod('check_max_value', function(value, element, param) {
        if (value){
            var i = parseInt(value);
            return (i >= 1 && i <= param);
        }
        return true;
    });
    $.validator.addMethod('check_have_call_time', function(value) {
        if (value == '{}' || value == '') {
            return false;
        }
        return true;
    }, SCHEDULE_MSG_ERROR_BLANK_CALL_TIME);

    $.validator.addMethod("compareTimeNow", function(value) {
        var current_date = new Date();
        var date_now = current_date.formateCallDate("getDate");
        var time_now = current_date.formateCallDate("hour_minutes");

        var create_date = $("#create_date").val();
        var list_dates = JSON.parse(value);

        for (i=0; i<Object.keys(list_dates).length; i++) {
            var start_time = list_dates[Object.keys(list_dates)[i]].start_date;
            if (create_date == date_now && start_time < time_now) {
                return false;
            }
        }

        return true;
    }, SCHEDULE_MSG_ERROR_DATETIME_LT_NOW);

    $.validator.addMethod("compareDateNow", function() {
	    var create_date = $("#create_date").val();
	    var current_date = new Date();
	    var date_now = current_date.formateCallDate("getDate");

        if(create_date < date_now) {
            return false;
        }
	    return true;
    }, SCHEDULE_MSG_ERROR_DATETIME_LT_NOW);

    $.validator.setDefaults({
        ignore: [],
    });


    $(document).on('hidden.bs.modal', '#modalAddSchedule', function () {
        $("#SmsSchedule").validate().resetForm();
        reset_timeline("#hdCallTimes");
    });

    $(document).on('shown.bs.modal', '#modalCallRightAway', function () {
        $('#hdCallTimes').val(JSON.stringify(list_events));
        list_events = {};
        scheduler.init('scheduler_here2', new Date(), "timeline");
        scheduler.clearAll();
        bottom_limit_time = '24:00';

        $('#scheduler_here2').addClass('timeline_disabled');
        $('#scheduler_here2').parent().find('.over_timeline_disabled').show();
    });

    $(document).on('hidden.bs.modal', '#modalCallRightAway', function () {
        if ($('#hdCreateDate').val() != '') {
            var date_timeline = new Date($('#hdCreateDate').val());
        } else {
            var date_timeline = new Date();
        }

        list_events = JSON.parse($('#hdCallTimes').val());
        var new_list_ev = [];
        var index = 0;
        for (var key in list_events) {
            var ev = {
                'start_date': new Date(list_events[key].start_date).formateCallDate(),
                'end_date': new Date(list_events[key].end_date).formateCallDate(),
                'text': list_events[key].text,
                'id': list_events[key].id,
                'section_id': list_events[key].section_id,
            };
            new_list_ev[index++] = jQuery.extend({}, ev);
        }
        scheduler.init('scheduler_here', date_timeline, "timeline");
        scheduler.clearAll();
        scheduler.parse(new_list_ev, 'json');

        bottom_limit_time = '00:00';
    });

    $(document).on('click', '.lnkEdit', function () {
        var schedule_id = $(this).attr("schedule_id");
        $.ajax({
            type: "POST",
            url:appRoot + "SmsSchedule/check_exist_schedule",
            data: {
                id: schedule_id,
            },
            async: false,
            success:function(data) {
                if (data == "false") {
                    alert(SCHEDULE_MSG_ALERT_NOT_EXIST_SCHEDULE);
                    window.location.href = appRoot + "SmsSchedule/index/";
                }
                var data_ajax = {
                    action: 'edit',
                    title: '編集',
                    id: schedule_id,
                };
                form_create_schedule(data_ajax);
            }
        });
    });

    $(document).on('click', '.lnkDuplicate', function () {
        var schedule_id = $(this).attr("schedule_id");
        $.ajax({
            type: "POST",
            url:appRoot + "SmsSchedule/check_exist_schedule",
            data: {
                id: schedule_id,
            },
            async: false,
            success:function(data) {
                if (data == "false") {
                    alert(SCHEDULE_MSG_ALERT_NOT_EXIST_SCHEDULE);
                    window.location.href = appRoot + "SmsSchedule/index/";
                }

                var data_ajax = {
                    action: 'duplicate',
                    title: '複製',
                    id: schedule_id,
                };
                form_create_schedule(data_ajax);
            }
        });
    });

    $("#create_schedule").click(function() {
        $('.alert').hide();
        var data_ajax = {
            action: 'add',
            title: '新規登録'
        };
        form_create_schedule(data_ajax);
    });

    $(document).on('change', '.dialog_end_call', function () {
        if ($('#dialog_hour_end_call').val() != '' && $('#dialog_minute_end_call').val() != '') {
            bottom_limit_time = $('#dialog_hour_end_call').val() + ':' + $('#dialog_minute_end_call').val();
            $('#scheduler_here2').removeClass('timeline_disabled');
            $('#scheduler_here2').parent().find('.over_timeline_disabled').hide();
            $("#dialog_end_call-error").html("");
        } else {
            bottom_limit_time = '24:00';
            $('#scheduler_here2').addClass('timeline_disabled');
            $('#scheduler_here2').parent().find('.over_timeline_disabled').show();
        }

        var limit_datetime = new Date(new Date().formateCallDate("getDate").replace(/-/g, '/') + ' ' + bottom_limit_time);
        var events = scheduler.getEvents();

        for (i=0; i<events.length; i++) {
            if (events[i].start_date.getTime() < limit_datetime.getTime() + MIN_DISTANCE_CALL_TIME) {
                scheduler.deleteEvent(events[i].id);
            }
        }
    });

    $(document).on('click', '.btnSubmit', function () {
        var action = $(this).attr("action");
        var schedule_id = $("#id").val();
        var create_date = $("#create_date").val();
        var display_number = $("#service_id").val();
        var template_id = $("#template_id").val();
        var list_id = $("#list_id").val();
        var mes_confirm = "";
        var consent_flag = $('#consent_flag').is(':checked'); // #8298 add consentday

        if (action == "create") {
        	mes_confirm = SCHEDULE_MSG_CONFIRM_CREATE;
        } else if (action == "update") {
        	mes_confirm = SCHEDULE_MSG_CONFIRM_UPDATE;
        } else if (action == "duplicate") {
        	mes_confirm = SCHEDULE_MSG_CONFIRM_DUPLICATE;
        } else if (action == "call") {
        	mes_confirm = SMS_SCHEDULE_MSG_CONFIRM_CALL;
        }

        if (action == "popup" || action == "call") {
        	//必須項目除外
        	$("#create_date").rules("remove");
            $('#hdCallTimes').rules('remove');
        } else {
        	//必須項目追加

            $('#create_date').rules('add', {
                required: true,
                compareDateNow: true,
            });
            $('#hdCallTimes').rules('add', {
                check_have_call_time: true,
                compareTimeNow: true,
            });
        }

        if (action == "create" || action == "update" || action == "duplicate") {
            var list_times = {};
            var events = scheduler.getEvents();
            for (i=0; i<events.length; i++) {
                var times = {
                    start_date: events[i].start_date.formateCallDate("hour_minutes"),
                    end_date: events[i].end_date.formateCallDate("hour_minutes"),
                };
                list_times[events[i].id] = jQuery.extend({}, times);
            };
            $('#hdCallTimes').val(JSON.stringify(list_times));
        }

        //すぐ送信場合時間更新
        if (action == "call") {
        	var current_date = new Date();
        	create_date = current_date.formateCallDate("getDate");
        	$('#create_date').val(create_date);

        	operation_time_start = current_date.formateCallDate('hour_minutes');
        	operation_time_end = $('#dialog_hour_end_call').val() + ':' + $('#dialog_minute_end_call').val();
            var list_times = {
                1: {
                    start_date: operation_time_start,
                    end_date: operation_time_end,
                }
            };

            var events = scheduler.getEvents();
            for (i=0; i<events.length; i++) {
                var times = {
                    start_date: events[i].start_date.formateCallDate('hour_minutes'),
                    end_date: events[i].end_date.formateCallDate('hour_minutes'),
                };
                list_times[events[i].id] = jQuery.extend({}, times);
            };
            $('#hdCallTimes2').val(JSON.stringify(list_times));
        }
        //ボタンクリック
        if ($("#SmsSchedule").valid()) {
            $("#dialog_end_call-error").html("");
            if (action == "popup") {
                var edit_mode = $(this).parents(".modal-footer").children(".pull-right").children(".btnSubmit").attr("action");
                $.ajax({
                    type: "POST",
                    url: appRoot + "SmsSchedule/check_popup",
                    data: {
                        schedule_id: schedule_id,
                        action: action,
                        edit_mode: edit_mode
                    },
                    async: false,
                    success: function (data) {
                        var arr = $.parseJSON(data);
                        var result = arr.result;

                        if (result == "error_start_time") {
                            alert(SMS_SCHEDULE_SETTING_INTERVAL_MESSAGE);
                            return false;
                        } else {
                            //すぐ送信場合ポップアップ表示
                            var current_date = new Date();
                            var hour_minutes = current_date.getTime() + MIN_DISTANCE_CALL_TIME;

                            $("#dialog_hour_end_call").children('option').each(function () {
                                var date = new Date(current_date.formateCallDate('getDate').replace(/-/g, '/') + ' ' + (parseInt($(this).val()) + 1) + ':00');
                                if ($(this).val() == '' || date.getTime() < hour_minutes) {
                                    $(this).attr('disabled', true);
                                } else {
                                    $(this).attr('disabled', false);
                                }
                            });
                            $("#dialog_hour_end_call").val("");
                            $("#dialog_minute_end_call").val("");
                            $(".dialog-start-call").html(current_date.formateCallDate());
                            $('#modalCallRightAway').modal('show');
                        }
                    }
                });
        	} else {
                if (action == "call") {
                    if (!$("#dialog_hour_end_call").val() || !$("#dialog_minute_end_call").val()) {
                        $("#dialog_end_call-error").html(SMS_SCHEDULE_MSG_ERROR_BLANK_TIME_END);
                        return false;
                    }

                    var a = new Date(new Date().formateCallDate("getDate").replace(/-/g, '/') + ' ' + $('#dialog_hour_end_call').val() + ':' + $('#dialog_minute_end_call').val());
                    var b = new Date();

                    if (a.getTime() < b.getTime() + MIN_DISTANCE_CALL_TIME) {
                        //$("#dialog_end_call-error").html(SCHEDULE_MSG_ERROR_TIME_END_LT_NOW);
                        $("#dialog_end_call-error").html('終了時間を' + new Date(b.getTime() + MIN_DISTANCE_CALL_TIME).formateCallDate("hour_minutes") + '以降に設定してください。');
                        return false;
                    }

                    var list_call_times = JSON.parse($('#hdCallTimes2').val());
                } else {
                    var list_call_times = JSON.parse($('#hdCallTimes').val());
                }

        		$.ajax({
                    type: "POST",
                    url: appRoot + "SmsSchedule/check_info_schedule",
                    data: {
                    	schedule_id: schedule_id,
                    	create_date: create_date,
                        list_call_times: list_call_times,
                        display_number: display_number,
                        template_id: template_id,
                    	list_id: list_id,
                    	action: action,
                    	consent_flag: consent_flag, // #8298 add consentday
                    },
                    async: false,
                    success: function(data) {
                    	var arr = $.parseJSON(data);
                    	var result = arr.result;
                    	if (result == "err_exist_schedule") {
                    		alert(SCHEDULE_MSG_ALERT_NOT_EXIST_SCHEDULE);
                    		window.location.href = appRoot + "SmsSchedule/index/";
                        } else if (result == "err_exist_template") {
                            alert(SMS_SCHEDULE_MSG_ALERT_NOT_EXIST_TEMPLATE);
                            window.location.href = appRoot + "SmsSchedule/index/";
                    	} else if (result == "err_exist_list") {
                    		alert(SMS_SCHEDULE_MSG_ALERT_NOT_EXIST_LIST);
                    		window.location.href = appRoot + "SmsSchedule/index/";
                        } else if (result == "err_lock_call_list") {
                            alert(SMS_SCHEDULE_MSG_ALERT_LIST_LOCKED);
                    	} else if (result == "err_lock_template") {
                            alert(SMS_SCHEDULE_MSG_ALERT_TEMPLATE_LOCKED);
                        } else if (result == "error_start_time") {
                            alert(SMS_SCHEDULE_SETTING_UPDATE_INTERVAL_MESSAGE);
                    	} else if (result == "err_service_id_used") {
                    		var time_start = new Date(arr.time_start).formateCallDate('hour_minutes');
                    		var time_end = new Date(arr.time_end).formateCallDate('hour_minutes');
                    		alert(time_start + '～' + time_end + ' ' + SMS_SCHEDULE_MSG_ALERT_SERVICE_USED);
                    	} else if (result == "err_over_schedule") {
                    		alert(SCHEDULE_MSG_ALERT_OVER_SCHEDULE_1 + arr.limit_schedule + SCHEDULE_MSG_ALERT_OVER_SCHEDULE_2);
                    	} else if (result == "err_update_run") {
                    		alert(SCHEDULE_MSG_ALERT_UPDATE_SCHEDULE_RUNNING);
                        }  else if  (result == 'error_status') {
                            alert(arr["msg"]);
                        } else if (result == "err_editing") {
                            alert(SCHEDULE_MSG_ALERT_SCHEDULE_IS_LOCKING);
                        } else if (result == "err_consentday") { // #8298 add consentday
                            alert(SCHEDULE_MSG_ERROR_CONSENTDAY_NOT_FOUND);
                    	} else if (result == "err_not_exit_item") {
                            alert(SMS_MSG_ALERT_NOT_EXIST_ITEM);
                        } else if (result == "err_sms_over_length") {
                            alert(SMS_MSG_BODY_ITEM_REACH_LIMIT);
                        } else if (result == "err_sms_illegal_url_string") {
                            alert(SMS_ILLEGAL_STRING_IN_BODY_URL);
                        } else if (result == "err_sms_over_url_length") {
                            alert(SMS_BODY_ITEM_REACH_LIMIT_SHORT_URL);
                        } else if (result == "err_sms_illegal_use_short_url") {
                            alert(SMS_ILLEGAL_USE_SHORT_URL);
                        } else if (result == "err_sms_invalid_use_short_url") {
                            alert(SMS_INVALID_USE_SHORT_URL);
                        } else if (result == "err_list_and_template_used") {
                            alert(SMS_SCHEDULE_MSG_ALERT_LIST_TEMPLATE_USED);
                        } else {
                    		if (confirm(mes_confirm)) {
                    			$.ajax({
                                    type: "POST",
                                    url:appRoot + "SmsSchedule/save/" + action,
                                    data: $("#SmsSchedule").serialize(),
                                    beforeSend: function() {
                                    	display_load();
                                    },
                                    success: function(data) {
                                    	$.unblockUI();
                                    	var arr = $.parseJSON(data);
                                    	var result = arr.result;
                                    	var schedule_id = arr.schedule_id;
                                    	if (result != "success") {
                                            if (result == "err_list_and_template_used") {
                                                alert(SMS_SCHEDULE_MSG_ALERT_LIST_TEMPLATE_USED);
                                            } else {
                                                alert(SCHEDULE_MSG_ALERT_SAVE_ERROR);
                                            }

                                            location.reload();
                                            return;
                                        }

                                		$('#modalCallRightAway').modal('hide');
                                		$('#modalAddSchedule').modal('hide');
                                		if (action == "call") { // Move to status screen after run schedule
                                			var ip = document.createElement('input');
                                    		ip.type = 'hidden';
                                    		ip.name = 'schedule_id';
                                    		ip.value = schedule_id;
                                            var url = appRoot + 'SmsSchedule/status';
                                            display_load();
                                            $('#T200SmsSendScheduleIndexForm').attr('action', url);
                                            $('#T200SmsSendScheduleIndexForm').attr('method', 'post');
                                            $('#T200SmsSendScheduleIndexForm').attr('enctype', 'multipart/form-data');
                                            $('#T200SmsSendScheduleIndexForm').append(ip);
                                            $('#T200SmsSendScheduleIndexForm').submit();
                                		}else
                                			window.location.href = appRoot + "SmsSchedule/index/success";
                                    }
                                });
                    		}
                    	}
                    }
                });
        	}
        }
    });
});

function form_create_schedule(data_ajax) {
    $.ajax({
        type: "POST",
        url: appRoot + "SmsSchedule/create",
        data: data_ajax,
        async: false,
        success: function(data) {
            $('#form_container').html(data);
            $('#modalAddScheduleLabel').html(data_ajax.title);
            $('#modalAddSchedule').modal('show');
            var action = data_ajax.action;

            if ((action == 'edit' || action == 'duplicate') && $('#create_date').val() != '') {
                var timeline_date = new Date($('#create_date').val());
            } else {
                var timeline_date = new Date();
            }

            if (!scheduler_inited) {
                init_schedule("scheduler_here", timeline_date);
                scheduler_inited = true;
            } else {
                scheduler.init('scheduler_here', timeline_date, "timeline");
            }

            if (action == 'edit' || action == 'duplicate') {
                scheduler.parse(JSON.parse($('#hdCallTimes').val()), "json");

                var events = scheduler.getEvents();
                for (i = 0; i < events.length; i++) {
                    list_events[events[i].id] = jQuery.extend({}, events[i]);
                };

                $('#hdCallTimes').val(JSON.stringify(list_events));
            }

            if (action == 'duplicate') {
            	$('#schedule_name').val('');
            }

            init_datepicker();
            if (action == 'edit') {
                var edit_flag = true;
            } else {
                var edit_flag = false;
            }

            if (action == 'edit' && $('#disable_input_flag').val() == 1) {
                $('#modalAddSchedule input').attr('disabled', true);
                $('#modalAddSchedule select').attr('disabled', true);
                $('#scheduler_here').addClass('timeline_disabled');
                $('#scheduler_here').parent().find('.over_timeline_disabled').show();
            }

            validate_save_schedule(edit_flag);
        }
    });
}

function init_datepicker() {
    $('#create_date').datepicker({
        minDate: new Date(),
        buttonText: '開始日時選択',
        timeFormat: 'HH:mm',
        dateFormat: 'yy-mm-dd',
        onSelect: function () {
            $("#create_date").valid();
        }
    });

    $(document).on('click', '#date_picker_btn', function () {
        $('#create_date').click();
    });
}

function validate_save_schedule(edit_flag) {
    $("#SmsSchedule").validate({
        // ingore:"",
        rules: {
            "data[T200SmsSendSchedule][schedule_name]": {
                required: true,
                remote: {
                    type: 'post',
                    url: appRoot + '/SmsSchedule/check_exist_schedule_name',
                    async: false,
                    data: {
                        schedule_name: function() {
                            return $("#schedule_name").val();
                        },
                        schedule_id: function() {
                            if (edit_flag) {
                                return $('#id').val();
                            } else {
                                return '';
                            }
                        }
                    }
                }
            },
            "data[T200SmsSendSchedule][create_date]": {
            	required: true,
            	compareDateNow: true,
            },
            "data[T200SmsSendSchedule][display_number]": {
                required: true,
            },
            "data[T200SmsSendSchedule][template_id]": {
                required: true,
            },
            "data[T200SmsSendSchedule][list_id]": {
                required: true,
            },
        },
        messages: {
            "data[T200SmsSendSchedule][schedule_name]": {
                required: SCHEDULE_MSG_ERROR_BLANK_NAME,
                remote: SMS_SCHEDULE_MSG_ERROR_NAME_EXIST
            },
            "data[T200SmsSendSchedule][create_date]": {
                required: SMS_SCHEDULE_MSG_ERROR_BLANK_CREATE_DATE,
            },
            "data[T200SmsSendSchedule][display_number]": {
                required: SMS_SCHEDULE_MSG_ERROR_BLANK_SERVICE_ID,
            },
            "data[T200SmsSendSchedule][template_id]": {
                required: SMS_SCHEDULE_MSG_ERROR_BLANK_TEMPLATE,
            },
            "data[T200SmsSendSchedule][list_id]": {
                required: SMS_SCHEDULE_MSG_ERROR_BLANK_LIST,
            },
        },
    });
}
