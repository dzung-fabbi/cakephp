var list_events = {};
var bottom_limit_time = '00:00';
var MIN_DISTANCE_CALL_TIME = 0;

function init_schedule(id_timeline_container, timeline_date) {
    //===============
    //Configuration
    //===============
    scheduler.locale.labels.timeline_tab = "Timeline";
    scheduler.locale.labels.section_custom = "Section";
    scheduler.locale.labels.icon_save = "保存";
    scheduler.locale.labels.icon_cancel = "キャンセル";
    scheduler.locale.labels.icon_delete = "削除";
    scheduler.locale.labels.confirm_deleting = SCHEDULE_MSG_CONFIRM_DEL_EVENT;
    scheduler.locale.labels.message_ok = "OK";
    scheduler.locale.labels.message_cancel = "キャンセル";

    scheduler.config.details_on_dblclick = true;
    scheduler.config.xml_date = "%Y-%m-%d %H:%i";
    scheduler.config.limit_drag_out = true;
    scheduler.config.dblclick_create = false;
    scheduler.config.time_step = 5;
    scheduler.config.first_hour = 6;
    scheduler.config.last_hour = 24;
    scheduler.config.limit_time_select = true;
    //scheduler.config.event_duration = 30;
    scheduler.config.auto_end_date = true;

    var format_hour_minute = scheduler.date.date_to_str("%H:%i");
    var format_date = scheduler.date.date_to_str("%Y/%m/%d");
    var resize_date_format = scheduler.date.date_to_str(scheduler.config.hour_date);
    var durations = {
        day: 24 * 60 * 60 * 1000,
        hour: 60 * 60 * 1000,
        minute: 60 * 1000
    };

    var days = [{key:1, label:"Time execute"}];
    var x_step = 30;

    var get_formatted_duration = function(start, end) {
        var diff = end - start;

        var days = Math.floor(diff / durations.day);
        diff -= days * durations.day;
        var hours = Math.floor(diff / durations.hour);
        diff -= hours * durations.hour;
        var minutes = Math.floor(diff / durations.minute);

        var results = [];
        if (days) results.push(days + " days");
        if (hours) results.push(hours + " hours");
        if (minutes) results.push(minutes + " minutes");
        return results.join(", ");
    };
    var check_call_time = function(id, ev, check_same_time) {
        var start_time = ev.start_date.getTime();
        var end_time = ev.end_date.getTime();
        var events = scheduler.getEvents();
        var botton_limit_datetime = new Date(format_date(scheduler.getState().date) + ' ' + bottom_limit_time);
        var first_hour = new Date(format_date(scheduler.getState().date) + ' ' + scheduler.config.first_hour + ':00');
        if (scheduler.config.last_hour < 24) {
            var last_hour = new Date(format_date(scheduler.getState().date) + ' ' + scheduler.config.last_hour + ':00');
        } else {
            var last_hour = new Date(format_date(scheduler.getState().date) + ' ' + '23:59');
        }

        if (start_time < first_hour.getTime() || end_time > last_hour.getTime()) {
            return false;
        }

        if (bottom_limit_time != '' && start_time - MIN_DISTANCE_CALL_TIME < botton_limit_datetime.getTime()) {
            //return false;
            return '開始時間を' + format_hour_minute(new Date(botton_limit_datetime.getTime() + MIN_DISTANCE_CALL_TIME)) + '以降に設定してください。';
        }

        if (start_time + MIN_DISTANCE_CALL_TIME > end_time) {
            //return false;
            return '終了時間を' + format_hour_minute(new Date(start_time + MIN_DISTANCE_CALL_TIME)) + '以降に設定してください。';
        }

        if (check_same_time && start_time == end_time) {
            //return false;
            return '終了時間を' + format_hour_minute(new Date(start_time + MIN_DISTANCE_CALL_TIME)) + '以降に設定してください。';
        }

        for (i=0; i<events.length; i++) {
            if (events[i].id != id) {
                var evt_start_date = events[i].start_date.getTime();
                var evt_end_date = events[i].end_date.getTime();

                if ((start_time < evt_start_date - MIN_DISTANCE_CALL_TIME && end_time > evt_start_date - MIN_DISTANCE_CALL_TIME)
                    || (start_time >= evt_start_date - MIN_DISTANCE_CALL_TIME && start_time < evt_end_date + MIN_DISTANCE_CALL_TIME)) {
                    //return false;
                    return '開始時間を' + format_hour_minute(new Date(evt_end_date + MIN_DISTANCE_CALL_TIME)) + '以降に設定してください。';
                }
            }
        };

        return true;
    };

    scheduler.form_blocks["my_time"]={
        render:function(sns){
            var str_drop_hour_start = "<select class='dropTime' id='dropHourStart'>";
            var str_drop_hour_end = "<select class='dropTime' id='dropHourEnd'>";
            for (i=scheduler.config.first_hour; i<=(scheduler.config.last_hour < 24 ? scheduler.config.last_hour : 23); i++) {
                if (i < 10) {
                    str_drop_hour_start += "<option value='0" + i + "'>0" + i + "</option>";
                    str_drop_hour_end += "<option value='0" + i + "'>0" + i + "</option>";
                } else {
                    str_drop_hour_start += "<option value='" + i + "'>" + i + "</option>";
                    str_drop_hour_end += "<option value='" + i + "'>" + i + "</option>";
                }
            }
            str_drop_hour_start += "</select>";
            str_drop_hour_end += "</select>";


            var str_drop_minute_start = "<select class='dropTime' id='dropMinuteStart'>";
            var str_drop_minute_end = "<select class='dropTime' id='dropMinuteEnd'>";
            for (i=0; i<60; i++) {
                if (i < 10) {
                    str_drop_minute_start += "<option value='0" + i + "'>0" + i + "</option>";
                    str_drop_minute_end += "<option value='0" + i + "'>0" + i + "</option>";
                } else {
                    str_drop_minute_start += "<option value='" + i + "'>" + i + "</option>";
                    str_drop_minute_end += "<option value='" + i + "'>" + i + "</option>";
                }
            }
            str_drop_minute_start += "</select>";
            str_drop_minute_end += "</select>";


            return "<div class='dhx_section_time' style='height:60px;'>"
                + str_drop_hour_start
                + ":"
                + str_drop_minute_start
                + '<span style="font-weight:normal; font-size:10pt;"> &nbsp;–&nbsp; </span>'
                + str_drop_hour_end
                + ":"
                + str_drop_minute_end
                +"</div>";
        },

        set_value:function(node,value,ev){
            var time_start = resize_date_format(ev.start_date);
            var time_end = resize_date_format(ev.end_date);
            var hour_start = time_start.substr(0, 2);
            var minute_start = time_start.substr(3, 2);
            var hour_end = time_end.substr(0, 2);
            var minute_end = time_end.substr(3, 2);

            node.childNodes[0].value = hour_start || "";
            node.childNodes[2].value = minute_start || "";
            node.childNodes[4].value = hour_end || "";
            node.childNodes[6].value = minute_end || "";
        },
        get_value:function(node,ev){
            var str_start_date = format_date(scheduler.getState().date) + " " + node.childNodes[0].value + ":" + node.childNodes[2].value;
            var str_end_date = format_date(scheduler.getState().date) + " " + node.childNodes[4].value + ":" + node.childNodes[6].value;

            ev.start_date = new Date(str_start_date);
            ev.end_date = new Date(str_end_date);
            return {start_date: ev.start_date, end_date: ev.end_date};
        },
        focus:function(node){
            var a=node.childNodes[0]; /*a.select();*/ a.focus();
        }
    };
    scheduler.config.lightbox.sections = [{name:"送信時間", height:1120, type:"my_time", map_to:"auto", focus: true}];
    scheduler.templates.lightbox_header = function(start,end,ev) {
        return "送信時間編集";
    };
    scheduler.templates.tooltip_text = function(start,end,event) {
        return "<b>"+format_hour_minute(start)+"</b> - <b>"+format_hour_minute(end)+"</b>";
    };
    scheduler.templates.event_bar_text = function(start, end, ev) {
        var state = scheduler.getState();
        if (state.drag_id == ev.id) {
            return resize_date_format(start) + " - " + resize_date_format(end) + " (" + get_formatted_duration(start, end) + ")";
        }
        var str = resize_date_format(start) + " - " + resize_date_format(end);
        return str;
    };

    scheduler.attachEvent("onBeforeDrag",function(id, mode, e){
        if (id) {
            var event = scheduler.getEvent(id);
            if (event.hasOwnProperty('disable_edit') && event.disable_edit == 1) {
                return false;
            }
        }
        return true;
    });
    scheduler.attachEvent("onEventDrag",function(id, mode){
        var ev = scheduler.getEvent(id);
        if (check_call_time(id, ev) !== true) {
            if (typeof list_events[id] == 'undefined') {
                scheduler.getEvent(id).start_date = scheduler.getState().date;
                scheduler.getEvent(id).end_date = scheduler.getState().date;
                scheduler.updateEvent(id);
            } else {
                scheduler.getEvent(id).start_date = list_events[id].start_date;
                scheduler.getEvent(id).end_date = list_events[id].end_date;
                scheduler.updateEvent(id);
            }
        } else {
            var eventObj = scheduler.getEvent(id);
            list_events[id] = jQuery.extend({}, eventObj);
        }
    });
    scheduler.attachEvent("onBeforeEventChanged",function(ev, e, is_new, original){
        if (check_call_time(ev.id, ev, true) !== true) {
            return false;
        }

        return true;
    });
    scheduler.attachEvent("onBeforeLightbox",function(id){
        if (id) {
            var event = scheduler.getEvent(id);
            if (event.hasOwnProperty('disable_edit') && event.disable_edit == 1) {
                return false;
            }
        }
        return true;
    });
    scheduler.attachEvent("onEventSave",function(id,ev){
        var result_check_call_time = check_call_time(id, ev);
        if (result_check_call_time !== true) {
            if (typeof list_events[id] != 'undefined') {
                scheduler.getEvent(id).start_date = list_events[id].start_date;
                scheduler.getEvent(id).end_date = list_events[id].end_date;
                scheduler.updateEvent(id);
            }
            if (result_check_call_time === false) {
                alert(SCHEDULE_MSG_ERROR_TIME_END_LT_NOW);
            } else {
                alert(result_check_call_time);
            }
            return false;
        }

        return true;
    });
    scheduler.attachEvent("onEventChanged",function(id,ev){
        list_events[id] = jQuery.extend({}, ev);
    });
    scheduler.attachEvent("onEventDeleted",function(id){
        delete list_events[id];
    });
    scheduler.createTimelineView({
        name:	"timeline",
        x_unit:	"minute",
        x_date:	"%i",
        x_step: x_step,
        x_size: (scheduler.config.last_hour - scheduler.config.first_hour)*60/x_step,
        x_start: scheduler.config.first_hour*60/x_step,
        x_length: 24*60/x_step,
        y_unit:	days,
        y_property:	"section_id",
        render:"bar",
        second_scale:{
            x_unit: "hour", // unit which should be used for second scale
            x_date: "%H時" // date format which should be used for second scale, "July 01"
        },
        round_position: false,
        // event_dy: "full",
    });

    scheduler.init(id_timeline_container, timeline_date, "timeline");
}

function reset_timeline(id_hd_container) {
    scheduler.clearAll();
    list_events = {};
    $(id_hd_container).val(JSON.stringify(list_events));
}