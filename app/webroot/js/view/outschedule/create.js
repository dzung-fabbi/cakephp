var scheduler_inited = false;

$(document).ready(function() {
    MIN_DISTANCE_CALL_TIME = parseInt($('#hdMinDistanceCallTime').val()) * 1000; //millisecond

    $(document).on('hidden.bs.modal', '#modalAddSchedule', function () {
        $("#OutSchedule").validate().resetForm();
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
            url:appRoot+"OutSchedule/check_exist_schedule",
            data: {
                id: schedule_id,
            },
            async: false,
            success:function(data){
                if(data == "false"){
                    alert(SCHEDULE_MSG_ALERT_NOT_EXIST_SCHEDULE);
                    window.location.href = appRoot+"OutSchedule/index/";
                } else {
                    var data_ajax = {
                        action: 'edit',
                        id: schedule_id,
                    };
                    form_create_schedule(data_ajax);
                }
            }
        });
    });

    $(document).on('click', '.lnkDuplicate', function () {
        var schedule_id = $(this).attr("schedule_id");
        $.ajax({
            type: "POST",
            url:appRoot+"OutSchedule/check_exist_schedule",
            data: {
                id: schedule_id,
            },
            async: false,
            success:function(data){
                if(data == "false"){
                    alert(SCHEDULE_MSG_ALERT_NOT_EXIST_SCHEDULE);
                    window.location.href = appRoot+"OutSchedule/index/";
                } else {
                    var data_ajax = {
                        action: 'duplicate',
                        id: schedule_id,
                    };
                    form_create_schedule(data_ajax);
                }
            }
        });
    });

    $("#create_schedule").click(function() {
        $('.alert').hide();
        var data_ajax = {
            action: 'add',
        };
        form_create_schedule(data_ajax);
    });

    $(document).on('change', '#recall', function () {
        if ($(this).val() == 0) {
            $('#recall_time').val('');
            $('#recall_time').prop('disabled', true);
            $('#recall_time').rules('remove');
            $('#recall_time').valid();
        } else {
            $('#recall_time').prop('disabled', false);
            $('#recall_time').rules('add', {
                required: true,
                digits: true,
                messages: {
                    required: SCHEDULE_MSG_ERROR_BLANK_RECALL_TIME,
                    digits: SCHEDULE_MSG_ERROR_NOT_DIGIT_RECALL_TIME,
                }
            });
        }
    });

    $(document).on('change', '#list_id', function () {
        if ($(this).val() != '') {
            var limit_value = $(this).find(":selected").attr('tel_total');
        } else {
            var limit_value = MAX_TERM_VALID;
        }

        $('#term_valid_count').rules('remove');
        $('#term_valid_count').rules('add', {
            digits: true,
            check_max_value: limit_value,
            messages: {
                digits: limit_value + SCHEDULE_MSG_ERROR_TERM_VALID,
                check_max_value: limit_value + SCHEDULE_MSG_ERROR_TERM_VALID,
            }
        });
        $('#term_valid_count').valid();

        $('#term_connect_count').rules('remove');
        $('#term_connect_count').rules('add', {
            digits: true,
            check_max_value: limit_value,
            messages: {
                digits: limit_value + SCHEDULE_MSG_ERROR_TERM_CONNECT,
                check_max_value: limit_value + SCHEDULE_MSG_ERROR_TERM_CONNECT,
            }
        });
        $('#term_connect_count').valid();
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
});

function form_create_schedule(data_ajax) {
    $.ajax({
        type: "POST",
        url:appRoot+"OutSchedule/create",
        data: data_ajax,
        async: false,
        success:function(data){
            $('#form_container').html(data);
            $('#modalAddSchedule').modal('show');

            if ((data_ajax.action == 'edit' || data_ajax.action == 'duplicate') && $('#create_date').val() != '') {
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

            if (data_ajax.action == 'edit' || data_ajax.action == 'duplicate') {
                scheduler.parse(JSON.parse($('#hdCallTimes').val()), "json");

                var events = scheduler.getEvents();
                for (i=0; i<events.length; i++) {
                    list_events[events[i].id] = jQuery.extend({}, events[i]);
                };

                $('#hdCallTimes').val(JSON.stringify(list_events));
            }

            init_datepicker();
            if (data_ajax.action == 'edit') {
                var edit_flag = true;
            } else {
                var edit_flag = false;
            }

            if (data_ajax.action == 'edit' && $('#disable_input_flag').val() == 1) {
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
        dateFormat: 'yy-mm-dd'
    });

    $(document).on('click', '#date_picker_btn', function () {
        $('#create_date').click();
    });
}

function validate_save_schedule(edit_flag) {
    $("#OutSchedule").validate({
        // ingore:"",
        rules: {
            "data[T20OutSchedule][schedule_name]": {
                required: true,
                maxlength: MAX_SCHEDULE_NAME_LENGTH,
                remote: {
                    type: 'post',
                    url: appRoot + '/OutSchedule/check_exist_schedule_name',
                    async: false,
                    data: {
                        schedule_name: function() {
                            return $("#ipScheduleName").val();
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
            "data[T20OutSchedule][call_type]": {
                required: true,
            },
            "data[T20OutSchedule][external_number]": {
                required: true,
            },
            "data[T20OutSchedule][template_id]": {
                required: true,
            },
            "data[T20OutSchedule][list_id]": {
                required: true,
            },
            "data[T20OutSchedule][proc_num]": {
                required: true,
            },
            "data[T20OutSchedule][term_valid_count]": {
            	digits: true,
                check_max_value: MAX_TERM_VALID,
            },
            "data[T20OutSchedule][term_connect_count]": {
                digits: true,
                check_max_value: MAX_TERM_VALID,
            },
            "data[T20OutSchedule][recall_time]": {
                digits: true,
                required: true,
            },
        },
        messages: {
            "data[T20OutSchedule][schedule_name]": {
                required: SCHEDULE_MSG_ERROR_BLANK_NAME,
                maxlength: SCHEDULE_MSG_ERROR_OVER_LENGTH_1 + MAX_SCHEDULE_NAME_LENGTH + SCHEDULE_MSG_ERROR_OVER_LENGTH_2,
                remote: SCHEDULE_MSG_ERROR_NAME_EXIST
            },
            "data[T20OutSchedule][call_type]": {
                required: SCHEDULE_MSG_ERROR_BLANK_CALL_TYPE,
            },
            "data[T20OutSchedule][external_number]": {
                required: SCHEDULE_MSG_ERROR_BLANK_EXTERNAL_NUMBER,
            },
            "data[T20OutSchedule][template_id]": {
                required: SCHEDULE_MSG_ERROR_BLANK_TEMPLATE,
            },
            "data[T20OutSchedule][list_id]": {
                required: SCHEDULE_MSG_ERROR_BLANK_LIST,
            },
            "data[T20OutSchedule][proc_num]": {
                required: SCHEDULE_MSG_ERROR_BLANK_PROCNUM
            },
            "data[T20OutSchedule][term_valid_count]": {
            	digits: MAX_TERM_VALID + SCHEDULE_MSG_ERROR_TERM_VALID,
                check_max_value: MAX_TERM_VALID + SCHEDULE_MSG_ERROR_TERM_VALID,
            },
            "data[T20OutSchedule][term_connect_count]": {
                digits: MAX_TERM_VALID + SCHEDULE_MSG_ERROR_TERM_CONNECT,
                check_max_value: MAX_TERM_VALID + SCHEDULE_MSG_ERROR_TERM_CONNECT,
            },
            "data[T20OutSchedule][recall_time]": {
                digits: SCHEDULE_MSG_ERROR_NOT_DIGIT_RECALL_TIME,
				required: SCHEDULE_MSG_ERROR_BLANK_RECALL_TIME,
            }
        },
    });
}