const MAX_SCHEDULE_NAME_LENGTH = 50;
const MAX_TERM_VALID = 50000;

$(document).ready(function() {
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

    // スケジュールの新規登録・編集画面で・複製画面で「保存」を押した時の処理
    // actionで状態を切り分ける。
    //       create:新規作成時の保存ボタン
    //       update:編集画面の保存ボタン
    //       duplicate:複製ボタンからの保存ボタン
    //       call:即時発信ボタン(即時発信を実行する)
    //       popup:即時発信ボタン(即時発信のポップアプを呼び出す)
    $(document).on('click', '.btnSubmit', function () {
        //値を取る
        var action = $(this).attr("action");
        var schedule_id = $("#id").val();
        var create_date = $("#create_date").val();
        var list_ng_id = $("#list_ng_id").val();
        var template_id = $("#template_id").val();
        var list_id = $("#list_id").val();
        var proc_num = $("#proc_num").val();
        var recall_time = $('#recall_time').val();
        var term_valid_count = $('#term_valid_count').val();
        var external_number = $("#external_number").val();
        var mes_confirm = "";
        //ポップアップ確認メッセージ
        if(action == "create"){
        	mes_confirm = SCHEDULE_MSG_CONFIRM_CREATE;
        }else if(action == "update"){
        	mes_confirm = SCHEDULE_MSG_CONFIRM_UPDATE;
        }else if(action == "duplicate"){
        	mes_confirm = SCHEDULE_MSG_CONFIRM_DUPLICATE;
        }else if(action == "call"){
        	mes_confirm = SCHEDULE_MSG_CONFIRM_CALL;
        }
        if(action == "popup" || action == "call"){
        	//必須項目除外
        	$("#create_date").rules("remove");
            $('#hdCallTimes').rules('remove');
        }else{
        	//必須項目追加
        	$("#create_date").rules("add", {
        		required: true,
        		compareDateNow: true,
        		messages: {
        			required: SCHEDULE_MSG_ERROR_BLANK_CREATE_DATE
        		}
        	});
            $('#hdCallTimes').rules('add', {
                check_have_call_time: true,
                compareTimeNow: true,
            })
             $('#recall_time').rules('add', {
                required: true,
                messages: {
                    required: SCHEDULE_MSG_ERROR_BLANK_RECALL_TIME,
                }
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

        //すぐ発信場合時間更新
        if(action == "call"){
        	var current_date = new Date();
        	create_date = current_date.formateCallDate("getDate");

        	operation_time_start = current_date.formateCallDate();
        	operation_time_end = create_date + " " + $('#dialog_hour_end_call').val() + ':' + $('#dialog_minute_end_call').val();
            var list_times = {
                1: {
                    start_date: operation_time_start,
                    end_date: operation_time_end,
                }
            };

            var events = scheduler.getEvents();
            for (i=0; i<events.length; i++) {
                var times = {
                    start_date: events[i].start_date.formateCallDate(),
                    end_date: events[i].end_date.formateCallDate(),
                };
                list_times[events[i].id] = jQuery.extend({}, times);
            };
            $('#hdCallTimes2').val(JSON.stringify(list_times));
        }
        //ボタンクリック
        if ($("#OutSchedule").valid()){
            $("#dialog_end_call-error").html("");
            if (action == "popup") {
                var edit_mode = $(this).parents(".modal-footer").children(".pull-right").children(".btnSubmit").attr("action");
                $.ajax({
                    type: "POST",
                    url: appRoot + "OutSchedule/check_popup",
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
                            alert(OUTBOUND_SCHEDULE_SETTING_INTERVAL_MESSAGE);
                            return false;
                        } else {
                            //すぐ発信場合ポップアップ表示
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
                if(action == "call") {
                    if (!$("#dialog_hour_end_call").val() || !$("#dialog_minute_end_call").val()) {
                        $("#dialog_end_call-error").html(SCHEDULE_MSG_ERROR_BLANK_TIME_END);
                        return false;
                    }

                    var a = new Date(new Date().formateCallDate("getDate").replace(/-/g, '/') + ' ' + $('#dialog_hour_end_call').val() + ':' + $('#dialog_minute_end_call').val());
                    var b = new Date();

                    if (a.getTime() < b.getTime() + MIN_DISTANCE_CALL_TIME) {
                        //$("#dialog_end_call-error").html(SCHEDULE_MSG_ERROR_TIME_END_LT_NOW);
                        $("#dialog_end_call-error").html('終了時間を' + new Date(b.getTime() + MIN_DISTANCE_CALL_TIME).formateCallDate("hour_minutes") + '以降に設定してください。');
                        return false;
                    }
                }

                if (action == 'call') {
                    var list_call_times = JSON.parse($('#hdCallTimes2').val());
                } else {
                    var list_call_times = JSON.parse($('#hdCallTimes').val());
                }
        		$.ajax({
                    type: "POST",
                    url:appRoot+"OutSchedule/check_info_schedule",
                    data: {
                    	schedule_id: schedule_id,
                    	create_date: create_date,
                        list_call_times: list_call_times,
                        list_ng_id: list_ng_id,
                        template_id: template_id,
                    	list_id: list_id,
                    	proc_num: proc_num,
                    	action: action,
                        recall_time: recall_time,
                        term_valid_count: term_valid_count,
                        external_number: external_number
                    },
                    async: false,
                    success:function(data){
                    	var arr = $.parseJSON(data);
                    	var result = arr.result;
                    	if(result == "err_exist_schedule"){
                    		alert(SCHEDULE_MSG_ALERT_NOT_EXIST_SCHEDULE);
                    		window.location.href = appRoot+"OutSchedule/index/";
                        }else if(result == "err_exist_list_ng"){
                            alert(SCHEDULE_MSG_ALERT_NOT_EXIST_LIST_NG);
                            window.location.href = appRoot+"OutSchedule/index/";
                        }else if(result == "err_exist_template"){
                            alert(SCHEDULE_MSG_ALERT_NOT_EXIST_TEMPLATE);
                            window.location.href = appRoot+"OutSchedule/index/";
                    	}else if(result == "err_exist_list"){
                    		alert(SCHEDULE_MSG_ALERT_NOT_EXIST_LIST);
                    		window.location.href = appRoot+"OutSchedule/index/";
                        }else if(result == "err_lock_call_list"){
                            alert(SCHEDULE_MSG_ALERT_LIST_LOCKED);
                    	}else if(result == "err_lock_template"){
                            alert(SCHEDULE_MSG_ALERT_TEMPLATE_LOCKED);
                        } else if (result == "error_start_time") {
                            alert(OUTBOUND_SCHEDULE_SETTING_UPDATE_INTERVAL_MESSAGE);
                        }else if(result == "err_exist_item"){
                            alert(SCHEDULE_MSG_ALERT_NOT_EXIST_ITEM);
                        }else if(result == "err_max_list_item"){
                            alert(SCHEDULE_MSG_ALERT_OVER_MAX_ITEM_1 + arr.max_list_item + SCHEDULE_MSG_ALERT_OVER_MAX_ITEM_2);
                    	}else if(result == "err_over_ch"){
                    		if(arr.yuko_procnum > 0){
                    			alert(SCHEDULE_MSG_ALERT_OVER_CH_1 + arr.limit_proc_num + SCHEDULE_MSG_ALERT_OVER_CH_2 + arr.yuko_procnum + SCHEDULE_MSG_ALERT_OVER_CH_3);
                    		}else{
                    			alert(SCHEDULE_MSG_ALERT_OVER_CH_1 + arr.limit_proc_num + SCHEDULE_MSG_ALERT_OVER_CH_4);
                    		}
                    	}else if(result == "err_over_schedule"){
                           if(/^\d+$/.test(arr.limit_schedule)){
                                alert(SCHEDULE_MSG_ERR_OVER_SCHEDULE_1 + "\n" + SCHEDULE_MSG_ERR_OVER_SCHEDULE_2);
                           }else{
                                alert(SCHEDULE_MSG_ALERT_KAISEN_INVALID);
                           }
                    	}else if(result == "err_update_run"){
                    		alert(SCHEDULE_MSG_ALERT_UPDATE_SCHEDULE_RUNNING);
                        } else if (result == 'error_status') {
                            alert(arr["msg"]);
                        }else if(result == "err_editing") {
                            alert(SCHEDULE_MSG_ALERT_SCHEDULE_IS_LOCKING);
                    	}else if(result == "err_exist_yuko") {
                            alert(SCHEDULE_MSG_ALERT_EXIST_YUKO);
                    	}else if(result == "err_sms_over_length") {
                            alert(SMS_BODY_ITEM_REACH_LIMIT);
                        }else if(result == "err_sms_illegal_url_string") {
                            alert(SMS_ILLEGAL_STRING_IN_BODY_URL);
                        }else if(result == "err_sms_over_url_length") {
                            alert(SMS_BODY_ITEM_REACH_LIMIT_SHORT_URL);
                        }else if(result == "err_expired") {
                            alert(SCHEDULE_MSG_CONFIRM_EXPIRED_LIST_NG);
                        } else if (result == "err_same") {
                            alert(SCHEDULE_MSG_ALERT_SAME_OTHER_SCHEDULE);
                    	}else{
                    		if(confirm(mes_confirm)){
                    			$.ajax({
                                    type: "POST",
                                    url:appRoot+"OutSchedule/save/" + action,
                                    data: $("#OutSchedule").serialize(),
                                    beforeSend: function(){
                                    	display_load();
                                    },
                                    success: function(data){
                                    	$.unblockUI();
                                    	var arr = $.parseJSON(data);
                                    	var result = arr.result;
                                    	var schedule_id = arr.schedule_id;
                                    	if(result == "success"){
                                            // alert("発信設定が成功に保存されました");
                                    		if(action == "call"){
                                    			var input = document.createElement('input');
                                    			input.type = 'hidden';
                                    			input.name = 'schedule_id';
                                    			input.value = schedule_id;

                                    			var form = document.createElement('form');
                                                //// 詳細画面に遷移
                                    			form.action = appRoot + 'OutSchedule/status';
                                    			form.method = 'post';
                                    			form.appendChild(input);
                                    			document.body.appendChild(form);
                                    			form.submit();
                                    		}else{
                                    			window.location.href = appRoot+"OutSchedule/index/success";
                                            }
                                        } else if (result == "err_same") {
                                            alert(SCHEDULE_MSG_ALERT_SAME_OTHER_SCHEDULE);
                                    	}else{
                                    		alert (SCHEDULE_MSG_ALERT_SAVE_ERROR);
                                    	}
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

Date.prototype.formateCallDate = function(flag) {
    var yyyy = this.getFullYear().toString();
    var mm = (this.getMonth()+1).toString(); // getMonth() is zero-based
    var dd  = this.getDate().toString();
    var HH  = this.getHours().toString();
    var MM  = this.getMinutes().toString();

    mm = mm[1] ? mm : "0"+mm[0];
    dd = dd[1] ? dd : "0"+dd[0];
    HH = HH[1] ? HH : "0"+HH[0];
    MM = MM[1] ? MM : "0"+MM[0];

    if (flag == "hour_minutes") {
        return HH + ":" + MM;
    } else if (flag == "getDate") {
        return yyyy + "-" + mm + "-" + dd;
    } else {
        return yyyy + "-" + mm + "-" + dd + " " + HH + ":" + MM;
    }
};
