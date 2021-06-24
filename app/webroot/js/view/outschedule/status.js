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

        drawPieChart();

        {
            if($("#hdPageScheduleDetail").val()){
                page = parseInt($("#hdPageScheduleDetail").val());
            }
            if($("#hdSortColumnScheduleDetail").val() && $("#hdSortTypeScheduleDetail").val()){
                column = [[parseInt($("#hdSortColumnScheduleDetail").val()), parseInt($("#hdSortTypeScheduleDetail").val())]];
            }

            //20160222 Edit by Thai : #6464 - update search by status result - Begin
            var filter_functions = {};
            // 詳細ポップアップのステータスプルダウン
            $('#sort_transfer').each(function() {
                var position = $(this).attr('position');
                filter_functions[position] = {
                    "ANSWER" : function(e, n, f, i, $r, c, data) { return e === f; },
                    "NOANSWER" : function(e, n, f, i, $r, c, data) { return e === f; },
                    "REJECT" : function(e, n, f, i, $r, c, data) { return e === f; },
                    "TRANSFER" : function(e, n, f, i, $r, c, data) { return e === f; },
                    "TRANSFERFULL" : function(e, n, f, i, $r, c, data) { return e === f; },
                    "TRANSFERTIMEOUT" : function(e, n, f, i, $r, c, data) { return e === f; },
                    "TRANSFERREJECT" : function(e, n, f, i, $r, c, data) { return e === f; },
                    "SKIP" : function(e, n, f, i, $r, c, data) { return e === f; },
                };
            });
            /*
            var filter_functions = {
                4: {
                    "ANSWER" : function(e, n, f, i, $r, c, data) { return e === f; },
                    "NOANSWER" : function(e, n, f, i, $r, c, data) { return e === f; },
                    "REJECT" : function(e, n, f, i, $r, c, data) { return e === f; },
                    "TRANSFER" : function(e, n, f, i, $r, c, data) { return e === f; },
                    "TRANSFERFULL" : function(e, n, f, i, $r, c, data) { return e === f; },
                    "TRANSFERTIMEOUT" : function(e, n, f, i, $r, c, data) { return e === f; }
                }
            };
            */
            //20160222 Edit by Thai : #6464 - update search by status result - End

            $('.sort_select').each(function() {
                var position = $(this).attr('position');
                filter_functions[position] = {
                    ">" : function(e, n, f, i, $r, c, data) { return e === f; },
                    "=" : function(e, n, f, i, $r, c, data) { return e === f; },
                    "<" : function(e, n, f, i, $r, c, data) { return e === f; }
                };
            });

            $('.auth_char').each(function() {
                var position = $(this).attr('position');
                filter_functions[position] = {
                    "=" : function(e, n, f, i, $r, c, data) { return e === f; },
                    "≠" : function(e, n, f, i, $r, c, data) { return e === f; }
                };
            });

            $("#scheduleDetailTable").tablesorter({
                theme: 'gold',
                widthFixed: true,
                sortLocaleCompare: true,
                sortList: column,
                headers: {
                    4: {
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
                ajaxUrl: appRoot + "OutSchedule/arr_schedule_detail/{page}/20/" + schedule_id + "/{sortList:column}?{filterList:filter}",
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
            //$(".tablesorter-filter").last().addClass("disabled").attr('disabled', true);
        }

        $("#dialog_schedule_detail").on("hide.bs.modal", function (e) {
    		$("#audio-player").find("audio").trigger("pause");
    		$("#audio-player").find("audio").attr("src","");

		});
    }


	$(document).on('click', '.btnDownload', function() {
		var schedule_ids = $('#schedule_id').val();

		if (!$(this).hasClass('btn_disabled') && schedule_ids) {
            if ($('#num_skip').val() > 0 && $(this).attr('id') == 'btnDownloadLog') {
                if (!confirm('スキップステータスは' + $('#num_skip').val() + '件があります。\n履歴をダウンロードします。宜しいでしょうか？')) {
                    return false;
                }
            }

			var func_name = $(this).attr('func-name');

			$.ajax({
				type: "POST",
				url:appRoot+"OutSchedule/check_download_schedule/",
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
					} else if (status == "err_status_can_not_download"){
						alert(SCHEDULE_MSG_ALERT_CANNOT_DOWNLOAD_SCHEDULE);
						return;
					} else {
						display_load();

						var url=appRoot+"OutSchedule/buffer_schedule_data/" + func_name;
						$.ajax({
							url: url,
							type: "post",
							data: {
								schedule_ids: schedule_ids,
							},
							success: function(result){
								if(result == "success"){
									window.location.href = appRoot+"OutSchedule/download_schedule";
								}else{
									window.location.href = appRoot+"OutSchedule/index";
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

    $(document).on('click', '#btnDetail', function() {
        $('#dialog_schedule_detail').modal('show');
    });

    $(document).on('click', '#btn_stop_call', function() {
        var schedule_id = $('#schedule_id').val();

        $.ajax({
            type: "POST",
            url: appRoot+"OutSchedule/check_stop_schedule/",
            async: false,
            data: {
                schedule_id: schedule_id
            },
            success:function(data){
            	 var arr = JSON.parse(data);
                 var result = arr["result"];

                if (result == 'err_not_exist') {
                    alert(SCHEDULE_MSG_ALERT_NOT_EXIST_SCHEDULE);
                } else if (result == 'error_status') {
                     alert(arr["msg"]);
                } else if (result == 'error_locking') {
                    alert(SCHEDULE_MSG_ALERT_SCHEDULE_IS_LOCKING);
                } else if (result == 'success'){
                    if (confirm(SCHEDULE_MSG_CONFIRM_STOP)) {
                        $.ajax({
                            type: 'POST',
                            url: appRoot + 'OutSchedule/stop_call',
                            data: {
                                schedule_id: schedule_id,
                            },
                            beforeSend: function(){
                                display_load();
                            },
                            success: function (data) {
                                $.unblockUI();
                                if(data == "success"){
                                    //change view
                                    $('#btn_stop_call').hide();
                                    $('#btn_stoping').show();
                                    $("#change_proc_num").attr('disabled', true).trigger("chosen:updated");
                                    $('#schedule_reload').attr('disabled', true).trigger("chosen:updated");
                                    //$('.btnDownload').attr('disabled', true);
                                    //$('#btnDetail').attr('disabled', true);
                                }else{
                                    alert(SCHEDULE_MSG_ALERT_STOP_ERROR);
                                    //window.location.href = appRoot+"OutSchedule/index/systemerror";
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
            url: appRoot + "OutSchedule/check_finish_schedule/",
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
                            url: appRoot + 'OutSchedule/finish_schedule',
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

    $(document).on('change', '#schedule_reload', function () {
    	var schedule_id = $('#schedule_id').val();
    	var time_reload = $('#schedule_reload').val();

        $.ajax({
            type: "POST",
            url:appRoot+"OutSchedule/sessionTimeReloadStatus",
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

    $(document).on('click', '.btnPlay', function (e) {
        var tel_no = $(this).attr("tel_no");
        var schedule_id = $(this).attr("schedule_id");
        var source = appRoot + 'OutSchedule/read_file/' + schedule_id + '/' + tel_no;
        $("#audio-player").find("audio").attr("src", source);
        $("#audio-player").find("audio").trigger('play');
    });

    $(document).on('click', '.btnStop', function (e) {
        $("#audio-player").find("audio").trigger('pause');
    });
    $(document).on('click', '.btnDownloadRecord', function (e) {
        var tel_no = $(this).attr("tel_no");
        var schedule_id = $(this).attr("schedule_id");
        window.location = appRoot + 'OutSchedule/read_file/' + schedule_id + '/' + tel_no;
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
            url:appRoot + 'OutSchedule/status_autoupdate',
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
                    drawPieChart();
                    updateDetail(schedule_id);
                }
            }
        });
	}, time_reload);
}
function drawPieChart() {
    var colors = {
        0: {
            color: "#E60012",
            highlight: "#E60012"
        },
        1: {
            color: "#00A0E9",
            highlight: "#00A0E9"
        },
        2: {
            color: "#F39800",
            highlight: "#F39800"
        },
        3: {
            color: "#52B638",
            highlight: "#52B638"
        },
        4: {
            color: "#FFF100",
            highlight: "#FFF100"
        },
        5: {
            color: "#009E96",
            highlight: "#009E96"
        },
        6: {
            color: "#FF99FF",
            highlight: "#FF99FF"
        },
        7: {
            color: "#0068B7",
            highlight: "#0068B7"
        },
        8: {
            color: "#3AFB97",
            highlight: "#3AFB97"
        },
        9: {
            color: "#E5004F",
            highlight: "#E5004F"
        },
        51: {
            color: "#1D2088",
            highlight: "#1D2088"
        },
        52: {
            color: "#B322AB",
            highlight: "#B322AB"
        }
    };
    $('.chart_area').each(function() {
        var chart_area = $(this);
        var dataCharts = [];

        var list_trs = $(this).parent().parent().find('tr');
        list_trs.each(function () {
            if ($(this).find('.data_chart-value').size() > 0) {
                var answer_no = $(this).find('.data_chart-value').first().attr('answer_no');
                var value = $(this).find('.data_chart-value').first().html();
                var title = $(this).find('.data_chart-title').first().html();

                if(answer_no != 99 && value > 0){
                	dataCharts.push({
	                    value: value,
	                    label: title,
	                    color: colors[answer_no].color,
	                    highlight: colors[answer_no].highlight
	                });
                }
                $(this).find('.color_element').first().css('background-color', colors[answer_no].color);
            }
        });

        var ctx = $(this).children().get(0).getContext("2d");
        window.myPie = new Chart(ctx).Pie(dataCharts, {
            customTooltips: function (tooltip) {
                var tooltipEl = chart_area.parent().find('.chartjs-tooltip');

                if (!tooltip) {
                    tooltipEl.css({
                        opacity: 0
                    });
                    return;
                }

                tooltipEl.removeClass('above below');
                tooltipEl.addClass(tooltip.yAlign);

                // split out the label and value and make your own tooltip here
                var parts = tooltip.text.split(":");
                var innerHtml = '<span>' + parts[0].trim() + '</span> : <span><b>' + parts[1].trim() + '</b></span>';
                tooltipEl.html(innerHtml);

                tooltipEl.css({
                    opacity: 1,
                    left: (tooltip.chart.canvas.offsetLeft + tooltip.x) + 'px',
                    top: (tooltip.chart.canvas.offsetTop + tooltip.y - /*tooltip.fontSize*2*/ 26 - 4) + 'px',
                    fontFamily: tooltip.fontFamily,
                    fontSize: tooltip.fontSize,
                    fontStyle: tooltip.fontStyle,
                });
            }
        });
    });
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
        url: appRoot + "OutSchedule/arr_schedule_detail/" + page + "/20/" + schedule_id + "/column[" + column[0][0] + "]=" + column[0][1] + "?",
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
function detectIE() {
    var ua = window.navigator.userAgent;

    var msie = ua.indexOf('MSIE ');
    if (msie > 0) {
        return parseInt(ua.substring(msie + 5, ua.indexOf('.', msie)), 10);
    }
    var trident = ua.indexOf('Trident/');
    if (trident > 0) {
        var rv = ua.indexOf('rv:');
        return parseInt(ua.substring(rv + 3, ua.indexOf('.', rv)), 10);
    }
    var edge = ua.indexOf('Edge/');
    if (edge > 0) {
        return parseInt(ua.substring(edge + 5, ua.indexOf('.', edge)), 10);
    }
    return false;
}