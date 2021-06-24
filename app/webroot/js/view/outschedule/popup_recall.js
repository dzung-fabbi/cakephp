$(document).ready(function() {
	MIN_DISTANCE_CALL_TIME = min_call_time * 1000; //millisecond

    $(document).on('change', '.set_time_end', function() {
    	var schedule_id = $('#schedule_id').val();
        var minute = $('#end_minute').val();
        var hour = $('#end_hour').val();
        if (hour != '' && minute != '') {
            bottom_limit_time = hour + ':' + minute;
            $('#scheduler_here').removeClass('timeline_disabled');
            $('#scheduler_here').parent().find('.over_timeline_disabled').hide();
            $('#dialog_end_call-error').html('');

			var end_datetime = new Date().formateCallDate("getDate") + ' ' + bottom_limit_time + ':00';
			reset_timeline("#hdCallTimes3");
			show_timeline(schedule_id, end_datetime);

            var current_date = new Date();
	        var limit_datetime = new Date(current_date.formateCallDate("getDate").replace(/-/g, '/') + ' ' + bottom_limit_time);
	        var events = scheduler.getEvents();

	        for (i=0; i<events.length; i++) {
	        	var start_date = (events[i].start_date.getTime() - MIN_DISTANCE_CALL_TIME);
	            if ((start_date > current_date.getTime()) && (start_date < limit_datetime.getTime())) {
	                scheduler.deleteEvent(events[i].id);
	            }
	        }
        } else {
            bottom_limit_time = '24:00';
            $('#scheduler_here').addClass('timeline_disabled');
            $('#scheduler_here').parent().find('.over_timeline_disabled').show();
        }
    });

    $(document).on('hidden.bs.modal', '#modalEditSchedule', function () {
        reset_timeline("#hdCallTimes3");
        $('.set_time_end').val('');
        $('#dialog_end_call-error').html('');
		bottom_limit_time = '00:00';
    });

    $(document).on('click', '#btnUpdateSchedule', function() {
		$('.alert').hide();
		if (!$("#end_hour").val() || !$("#end_minute").val()) {
            $("#dialog_end_call-error").html(SCHEDULE_MSG_ERROR_BLANK_TIME_END);
            return false;
        }

    	var current_date = new Date();
    	var create_date = current_date.formateCallDate("getDate");

        var a = new Date(create_date.replace(/-/g, '/') + ' ' + $('#end_hour').val() + ':' + $('#end_minute').val());
        var b = new Date();

        if (a.getTime() < b.getTime() + MIN_DISTANCE_CALL_TIME - 60*1000) {
        	$('.time_now').html(b.formateCallDate('getDate') + ' ' + b.formateCallDate('hour_minutes'))
            //$("#dialog_end_call-error").html(SCHEDULE_MSG_ERROR_TIME_END_LT_NOW);
			$("#dialog_end_call-error").html('終了時間を' + new Date(b.getTime() + MIN_DISTANCE_CALL_TIME - 60*1000).formateCallDate("hour_minutes") + '以降に設定してください。');
            return false;
        }

    	operation_time_start = current_date.formateCallDate();
    	operation_time_end = create_date + " " + $('#end_hour').val() + ':' + $('#end_minute').val();
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
        $('#hdCallTimes3').val(JSON.stringify(list_times));

		var schedule_id = $('#schedule_id').val();
		var proc_num = $('#proc_num').val();
		var list_call_times = JSON.parse($('#hdCallTimes3').val());

		if ($(this).attr('action') == 'recall') {
			var action = 'recall';
			var msg_confirm = SCHEDULE_MSG_CONFIRM_RESTART;
		} else {
			var action = 'call';
			var msg_confirm = SCHEDULE_MSG_CONFIRM_CALL;//20160323 - Edit by Canh
		}

		$.ajax({
			type: "POST",
			url: appRoot + "OutSchedule/check_recall_schedule/",
			async: false,
			data: {
				schedule_id: schedule_id,
				create_date: create_date,
				list_call_times: list_call_times,
				proc_num: proc_num,
				action: action,
			},
			success:function(data){
				var arr = JSON.parse(data);
				var result = arr["result"];

				if (result == 'err_exist_schedule') {
					alert(SCHEDULE_MSG_ALERT_NOT_EXIST_SCHEDULE);
					window.location.href = appRoot+"OutSchedule/index/";
				} else if (result == 'error_status') {
					alert(arr["msg"]);
				} else if (result == "err_over_ch") {
					if(arr.yuko_procnum > 0){
						alert(SCHEDULE_MSG_ALERT_OVER_CH_1 + arr.limit_proc_num + SCHEDULE_MSG_ALERT_OVER_CH_2 + arr.yuko_procnum + SCHEDULE_MSG_ALERT_OVER_CH_3);
					}else{
						alert(SCHEDULE_MSG_ALERT_OVER_CH_1 + arr.limit_proc_num + SCHEDULE_MSG_ALERT_OVER_CH_4);
					}
				} else if (result == "err_over_schedule") {
					if(/^\d+$/.test(arr.limit_schedule)){
						alert(SCHEDULE_MSG_ERR_OVER_SCHEDULE_1 + "\n" + SCHEDULE_MSG_ERR_OVER_SCHEDULE_2);
					}else{
						alert(SCHEDULE_MSG_ALERT_KAISEN_INVALID);
					}
				} else if (result == 'error_locking') {
					alert(SCHEDULE_MSG_ALERT_SCHEDULE_IS_LOCKING);
				} else if (result == 'success'){
					if (confirm(msg_confirm)) {
						$.ajax({
							type: 'POST',
							url: appRoot + 'OutSchedule/re_call',
							data: {
								schedule_id: schedule_id,
								proc_num: proc_num,
								list_call_times: list_call_times,
								action: action
							},
							beforeSend: function () {
								display_load();
							},
							success: function (data) {
								setEnabled();
								$.unblockUI();
								var arr = $.parseJSON(data);
								var result = arr.result;

								if (result == "err_db") {
									window.location.href = appRoot + "Login/index/systemerror";
								} else if (result == "success") {
									/*var current_screen = $(this).attr('screen');
									 if (current_screen == 'index') {
									 var btnFuncContainer = $(".btnRestartContainer a[schedule_id=" + schedule_id + "]").parent();
									 btnFuncContainer.html('');
									 btnFuncContainer.parent().find('.btnStopContainer').html('<a href="javascript:void(0);" class="iconFormat lnkStop" schedule_id="' + schedule_id + '"><i title="停止" data-toggle="tooltip" class="glyphicon glyphicon-pause icon-white" ></i></a>');
									 btnFuncContainer.parent().parent().find('td').css('background-color','#b4e3f2');
									 btnFuncContainer.parent().parent().find('.called_total').addClass('elereload');
									 } else {
									 $('#btn_recall').hide();
									 $('#btn_finish').hide();
									 $('#btn_stop_call').show();
									 $("#change_proc_num").attr('disabled', true).trigger("chosen:updated");
									 $('#schedule_reload').attr('disabled', false).trigger("chosen:updated");
									 startAutoUpdate(schedule_id, $('#schedule_reload').val());
									 }
									alert('success!');
									*/
								} else {
									alert(SCHEDULE_MSG_ALERT_SAVE_ERROR);
								}

								$('#modalEditSchedule').modal('hide');
								location.reload();
							}
						});
					}
				}
			}
		});
	});

	$(document).on('click', '.lnkRestart', function() {
		var schedule_id = $(this).attr("schedule_id");
		var action = $(this).attr("action");
		var title_btn = $(this).attr("title_btn");
		var screen = $(this).attr("screen");

		$.ajax({
			type: "POST",
			url: appRoot + "OutSchedule/show_popup_recall/",
			data: {
				schedule_id: schedule_id,
				action: action,
				title_btn: title_btn,
				screen: screen,
			},
			async: false,
			success: function(data){
				$('#form_container').html('');
				$('#form_container').html(data);
				$('#modalEditSchedule').modal('show');

				var current_date = new Date();
				var time_now = current_date.formateCallDate();

				$('.time_now').html(time_now);

				var hour_minutes = current_date.getTime() + MIN_DISTANCE_CALL_TIME;
				$("#end_hour").children('option').each(function() {
					var date = new Date(current_date.formateCallDate('getDate').replace(/-/g, '/') + ' ' + (parseInt($(this).val()) + 1) + ':00');
					if (date.getTime() < hour_minutes) {
						$(this).attr('disabled', true);
					} else {
						$(this).attr('disabled', false);
					}
				});

				var timeline_date = current_date;
				if (!scheduler_inited) {
					init_schedule("scheduler_here", timeline_date);
					scheduler_inited = true;
				} else {
					scheduler.init('scheduler_here', timeline_date, "timeline");
				}
				$('#scheduler_here').addClass('timeline_disabled');
				$('#scheduler_here').parent().find('.over_timeline_disabled').show();

				show_timeline(schedule_id, time_now);
			}
		});
	});
});

function show_timeline(schedule_id, limit_datetime) {
    $.ajax({
        type: "POST",
        url: appRoot + "OutSchedule/get_calltime/",
        async: false,
        data: {
			schedule_id: schedule_id,
			limit_datetime: limit_datetime,
        },
        success:function(data){
			if (data == 'systemerror') {
				alert(MSG_ALERT_SYSTEM_ERROR);
				location.reload();
			}
			scheduler.parse(JSON.parse(data), "json");

	        var events = scheduler.getEvents();
	        for (i=0; i<events.length; i++) {
	            list_events[events[i].id] = jQuery.extend({}, events[i]);
	        };

	        $('#hdCallTimes3').val(JSON.stringify(list_events));
        }
    });
}