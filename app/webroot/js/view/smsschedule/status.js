var page = 0, column = [[0,1]];
var scheduler_inited = false;

$(document).ready(function() {
    {
    	bottom_limit_time = '24:00';
        var schedule_id = $('#schedule_id').val();

    	if($('#status').val() == "1" || $('#status').val() == "5" || $('#status').val() == "6"){
    		//実行中・停止中場合
    		var schedule_id = $('#schedule_id').val();
    		var time_reload = $('#schedule_reload').val();
    		startAutoUpdate(schedule_id, time_reload);
    	}else{
    		//停止・終了場合
    		stopAutoUpdate();
    	}

        {
            if($("#hdPageScheduleDetail").val()){
                page = parseInt($("#hdPageScheduleDetail").val());
            }
            if($("#hdSortColumnScheduleDetail").val() && $("#hdSortTypeScheduleDetail").val()){
                column = [[parseInt($("#hdSortColumnScheduleDetail").val()), parseInt($("#hdSortTypeScheduleDetail").val())]];
            }

            var filter_functions = {};
            var position = $('#search_by_carrier').attr('position');
            filter_functions[position] = {
                "au" : function(e, n, f, i, $r, c, data) { return e === f; },
                "docomo" : function(e, n, f, i, $r, c, data) { return e === f; },
                "softbank" : function(e, n, f, i, $r, c, data) { return e === f; },
                "その他" : function(e, n, f, i, $r, c, data) { return e === f; }
            };

            position = $('#search_by_result').attr('position');
            filter_functions[position] = {
                "着信済み" : function(e, n, f, i, $r, c, data) { return e === f; },
                "圏外" : function(e, n, f, i, $r, c, data) { return e === f; },
                "不明" : function(e, n, f, i, $r, c, data) { return e === f; },
                "エラー" : function(e, n, f, i, $r, c, data) { return e === f; },
                "履歴判定NG" : function(e, n, f, i, $r, c, data) { return e === f; } // #8298 add consentday
            };

            $("#scheduleDetailTable").tablesorter({
                theme: 'gold',
                widthFixed: true,
                sortLocaleCompare: true,
                sortList: column,
                headers: {
                    1: {
                        sorter: "text"
                    },
                },
                widgets: ['zebra', 'filter'],
                widgetOptions : {
                    filter_cssFilter   : '',
                    filter_childRows   : false,
                    filter_hideFilters : false,
                    filter_ignoreCase  : true,
                    filter_reset : '.reset',
                    filter_saveFilters : false,
                    filter_searchDelay : 300,
                    filter_startsWith  : false,
                    filter_functions : filter_functions
                }
            }).tablesorterPager({
                container: $(".pager"),
                type: "POST",
                async: false,
                ajaxUrl: appRoot + "SmsSchedule/arr_schedule_detail/{page}/20/" + schedule_id + "/{sortList:column}?{filterList:filter}",
                ajaxObject: {
                    cache: false,
                    dataType: 'json',
                },
                ajaxProcessing: function(data){
                    if (data && data.hasOwnProperty('status') && data.status == 'error_login') {
                        stopAutoUpdate();
                        window.location.href = appRoot + 'Login';
                    }

                    if (data && data.hasOwnProperty('rows')) {
                        if (typeof data.sortColumn != 'undefined') {
                            $("#hdSortColumnScheduleDetail").val(data.sortColumn);
                        }
                        if (typeof data.sortType != 'undefined') {
                            $("#hdSortTypeScheduleDetail").val(data.sortType);
                        }
                        if (typeof data.page != 'undefined') {
                            $("#hdPageScheduleDetail").val(data.page);
                        }

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
        }
    }

    $(document).on('click', '#btn_stop_send', function() {
        var schedule_id = $('#schedule_id').val();

        $.ajax({
            type: "POST",
            url: appRoot+"SmsSchedule/check_stop_schedule/",
            async: false,
            data: {
                schedule_id: schedule_id
            },
            success:function(data){
                var arr = JSON.parse(data);
                var result = arr["result"];

                if (result == 'err_not_exist') {
                    alert(SCHEDULE_MSG_ALERT_NOT_EXIST_SCHEDULE);
                } else if (result == 'err_status') {
                    alert(arr["msg"]);
                } else if (result == 'error_locking') {
                    alert(SCHEDULE_MSG_ALERT_SCHEDULE_IS_LOCKING);
                } else if (result == 'success'){
                    if (confirm(SCHEDULE_MSG_CONFIRM_STOP)) {
                        $.ajax({
                            type: 'POST',
                            url: appRoot + 'SmsSchedule/stop_send',
                            data: {
                                schedule_id: schedule_id,
                            },
                            beforeSend: function(){
                                display_load();
                            },
                            success: function (data) {
                                $.unblockUI();
                                if (data == "success"){
                                    //change view
                                    $('#btn_stop_send').hide();
                                    $('#btn_finish').hide();
                                    $('#btn_stoping').show();
                                    $('#schedule_reload').attr('disabled', true).trigger("chosen:updated");
                                    //$('.btnDownload').attr('disabled', true);
                                    //$('#btnDetail').attr('disabled', true);
                                }else{
                                    alert(SCHEDULE_MSG_ALERT_STOP_ERROR);
                                    //window.location.href = appRoot+"SmsSchedule/index/systemerror";
                                }
                            }
                        });
                    }
                }
            }
        });
    });

    $(document).on('click', '#btn_finish', function() {
        var schedule_id = $('#schedule_id').val();
        var msg_confirm = $(this).data('msgconfirm');

        $.ajax({
            type: "POST",
            url: appRoot + "SmsSchedule/check_finish_schedule/",
            async: false,
            data: {
                schedule_id: schedule_id,
            },
            success:function(data){
                if (data == 'systemerror') {
                    alert(MSG_ALERT_SYSTEM_ERROR);
                    location.reload();
                } else if (data == 'err_not_exist') {
                    alert(SCHEDULE_MSG_ALERT_NOT_EXIST_SCHEDULE);
                } else if (data == 'err_status') {
                    alert(SCHEDULE_MSG_ALERT_NOSTOP_NOWAIT);
                } else {
                    if (confirm(msg_confirm)) {
                        $.ajax({
                            type: 'POST',
                            url: appRoot + 'SmsSchedule/finish_schedule',
                            data: {
                                schedule_id: schedule_id,
                            },
                            beforeSend: function () {
                                display_load();
                            },
                            success: function (result) {
                                if (result == 'systemerror') {
                                    alert(MSG_ALERT_SYSTEM_ERROR);
                                    location.reload();
                                } else if (result == "err_db") {
                                    window.location.href = appRoot + "Login/index/systemerror";
                                } else if (result == "success") {
                                    setEnabled();
                                    stopAutoUpdate();
                                    location.reload();
                                } else {
                                    alert(SCHEDULE_MSG_ALERT_SAVE_ERROR);
                                }
                            }
                        });
                    }
                }
                return;
            }
        });
    });

    $(document).on('click', '#btnDetail', function() {
        $('#dialog_schedule_detail').modal('show');
    });

	$(document).on('click', '.btnDownload', function() {
		var schedule_ids = $('#schedule_id').val();

		if (!$(this).hasClass('btn_disabled') && schedule_ids) {
			var func_name = $(this).attr('func-name');

			$.ajax({
				type: "POST",
				url:appRoot+"SmsSchedule/check_download_schedule/",
				data: {
					schedule_ids: schedule_ids,
				},
				async: false,
				success:function(data){
					var result = JSON.parse(data);
					var status = result['status'];

					if (status == "err_not_exist"){
						alert(SCHEDULE_MSG_ALERT_NOT_EXIST_SCHEDULE);
						location.reload();
						return;
					} else if (status == "err_status"){
						alert(SCHEDULE_MSG_ALERT_CANNOT_DOWNLOAD_SCHEDULE);
						return;
					} else {
						display_load();

						var url=appRoot+"SmsSchedule/buffer_schedule_data/" + func_name;
						$.ajax({
							url: url,
							type: "post",
							data: {
								schedule_ids: schedule_ids,
							},
							success: function(result){
								if(result == "success"){
									window.location.href = appRoot+"SmsSchedule/download_schedule";
								}else{
									//window.location.href = appRoot+"SmsSchedule/index";
								}
								setEnabled();
								$.unblockUI();
							}
						});
					}
				},
			});
		}
	});

    $(document).on('change', '#schedule_reload', function () {
    	var schedule_id = $('#schedule_id').val();
    	var time_reload = $('#schedule_reload').val();

        $.ajax({
            type: "POST",
            url:appRoot+"SmsSchedule/sessionTimeReloadStatus",
            data: {
                time_reload: time_reload
            },
            async: false,
            success:function(data){
            }
        });

    	stopAutoUpdate();
        if (time_reload != "0") {
        	startAutoUpdate(schedule_id, time_reload)
        }
    });

});

var autoUpdate;
function stopAutoUpdate(){
	clearInterval(autoUpdate);
}
function startAutoUpdate(schedule_id, time_reload){
	time_reload = parseInt(time_reload)*1000*60;
	autoUpdate = setInterval(function() {
		$.ajax({
			type: 'POST',
            url:appRoot + 'SmsSchedule/status_autoupdate',
            data: {
                schedule_id: schedule_id,
                request_type: 'ajax'
            },
            beforeSend: function(){
            	$(".elereload").each(function(){
            		$(".elereload").html("<img src=\""+appRoot+"img/ajax_loader.gif\" />");
            	});
            },
            success: function(data) {
                if (data == 'error_login') {
                    stopAutoUpdate();
                    window.location.href = appRoot + 'Login';
                } else {
                    $('#content').html(data);
                    if ($(data).find("#status").val() == 2 || $(data).find("#status").val() == 3) {
                        stopAutoUpdate();
                    }
                    updateDetail(schedule_id);
                }
            }
        });
	}, time_reload);
}

function updateDetail(schedule_id){
    if($("#hdPageScheduleDetail").val()){
        page = parseInt($("#hdPageScheduleDetail").val());
    }
    if($("#hdSortColumnScheduleDetail").val() && $("#hdSortTypeScheduleDetail").val()){
        column = [[parseInt($("#hdSortColumnScheduleDetail").val()), parseInt($("#hdSortTypeScheduleDetail").val())]];
    }

    $.ajax({
        type: "POST",
        url: appRoot + "SmsSchedule/arr_schedule_detail/" + page + "/20/" + schedule_id + "/column[" + column[0][0] + "]=" + column[0][1] + "?",
        cache: false,
        dataType: 'json',
        success:function(data){
            if (data && data.hasOwnProperty('status') && data.status == 'error_login') {
                stopAutoUpdate();
                window.location.href = appRoot + 'Login';
            }
            if (data && data.hasOwnProperty('rows')) {
                var json_data = new Object();
                json_data["headers"] = data.headers;
                json_data["total_rows"] = data.total_rows;
                json_data["rows"] = data.rows;
                $("#scheduleDetailTable").trigger("renderAjax", json_data);
                $("#scheduleDetailTable").trigger("update");
                $('#scheduleDetailTable').trigger('pagerUpdate');
            }
        }
    });
}