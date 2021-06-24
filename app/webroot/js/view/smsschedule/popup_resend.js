$(document).ready(function() {
    $(document).on('change', '.set_time_end', function() {
    	var schedule_id = $('#schedule_id').val();
        var minute = $('#end_minute').val();
        var hour = $('#end_hour').val();
        if (hour != '' && minute != '') {
            bottom_limit_time = hour + ':' + minute;
            $('#scheduler_here').removeClass('timeline_disabled');
            $('#scheduler_here').parent().find('.over_timeline_disabled').hide();
            $('#dialog_send-error').html('');

			var end_datetime = new Date().formateCallDate("getDate") + ' ' + bottom_limit_time + ':00';
			reset_timeline("#hdSendTimes3");
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
        reset_timeline("#hdSendTimes3");
        $('.set_time_end').val('');
        $('#dialog_send-error').html('');
		bottom_limit_time = '00:00';
    });

    $(document).on('click', '#btnUpdateSchedule', function() {
		$('.alert').hide();
		if (!$("#end_hour").val() || !$("#end_minute").val()) {
            $("#dialog_send-error").html(SMS_SCHEDULE_MSG_ERROR_BLANK_TIME_END);
            return false;
        }

    	var current_date = new Date();
    	var create_date = current_date.formateCallDate("getDate");

        var a = new Date(create_date.replace(/-/g, '/') + ' ' + $('#end_hour').val() + ':' + $('#end_minute').val());
        var b = new Date();

        if (a.getTime() < b.getTime() + MIN_DISTANCE_CALL_TIME - 60*1000) {
        	$('.time_now').html(b.formateCallDate('getDate') + ' ' + b.formateCallDate('hour_minutes'))
            //$("#dialog_send-error").html(SCHEDULE_MSG_ERROR_TIME_END_LT_NOW);
			$("#dialog_send-error").html('終了時間を' + new Date(b.getTime() + MIN_DISTANCE_CALL_TIME/* - 60*1000*/).formateCallDate("hour_minutes") + '以降に設定してください。');
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
        $('#hdSendTimes3').val(JSON.stringify(list_times));

		var schedule_id = $('#schedule_id').val();
		var list_send_times = JSON.parse($('#hdSendTimes3').val());

		if ($(this).attr('action') == 'resend') {
			var action = 'resend';
			var msg_confirm = SCHEDULE_MSG_CONFIRM_RESTART;
		} else {
			var action = 'send_now';
			var msg_confirm = SMS_SCHEDULE_MSG_CONFIRM_CALL;
		}

		$.ajax({
			type: "POST",
			url: appRoot + "SmsSchedule/check_resend_schedule/",
			async: false,
			data: {
				schedule_id: schedule_id,
				create_date: create_date,
				list_send_times: list_send_times,
				action: action
			},
			success:function(data){
				var arr = JSON.parse(data);
				var result = arr["result"];

				if (result == 'err_exist_schedule') {
					alert(SCHEDULE_MSG_ALERT_NOT_EXIST_SCHEDULE);
					window.location.href = appRoot+"SmsSchedule/index/";
				} else if (result == 'err_status') {
					alert(arr["msg"]);
				} else if (result == "err_over_schedule") {
					alert(SCHEDULE_MSG_ALERT_OVER_SCHEDULE_1 + arr.limit_schedule + SCHEDULE_MSG_ALERT_OVER_SCHEDULE_2);
				} else if (result == 'error_locking') {
					alert(SCHEDULE_MSG_ALERT_SCHEDULE_IS_LOCKING);
				} else if (result == "err_service_id_used") {
            		var time_start = new Date(arr.time_start).formateCallDate('hour_minutes');
            		var time_end = new Date(arr.time_end).formateCallDate('hour_minutes');
            		alert(time_start + '～' + time_end + ' ' + SMS_SCHEDULE_MSG_ALERT_SERVICE_USED);
				} else if (result == 'success'){
					if (confirm(msg_confirm)) {
						$.ajax({
							type: 'POST',
							url: appRoot + 'SmsSchedule/re_send',
							data: {
								schedule_id: schedule_id,
								list_send_times: list_send_times,
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
			url: appRoot + "SmsSchedule/show_popup_resend/",
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
        url: appRoot + "SmsSchedule/get_send_time/",
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

	        $('#hdSendTimes3').val(JSON.stringify(list_events));
        }
    });
}