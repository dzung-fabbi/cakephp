var page = 0, column = [[3,1]];

$(document).ready(function() {
	{
		if(!$("#btn_delete").length){
			column = [[2,1]];
		}
	    if($("#hdPageSchedule").val()){
	        page = parseInt($("#hdPageSchedule").val());
	    }
	    if($("#hdSortColumnSchedule").val() && $("#hdSortTypeSchedule").val()){
	        column = [[parseInt($("#hdSortColumnSchedule").val()), parseInt($("#hdSortTypeSchedule").val())]];
	    }

	    $("#scheduleTable").tablesorter({
	        theme: 'gold',
	        widthFixed: true,
	        sortLocaleCompare: true,
	        sortList: column,
	        headers: {
	            3: {
	                sorter: "text"
	            },
	        },
	        widgets: ['zebra', 'filter'],
	    }).tablesorterPager({
	        container: $(".pager"),
	        type: "POST",
	        async: false,
	        ajaxUrl: appRoot + "OutSchedule/arr_schedule/{page}/20/{sortList:column}?{filterList:filter}",
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
						$("#hdSortColumnSchedule").val(data.sortColumn);
					}
					if (typeof data.sortType != 'undefined') {
						$("#hdSortTypeSchedule").val(data.sortType);
					}
					if (typeof data.page != 'undefined') {
						$("#hdPageSchedule").val(data.page);
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
	    $(".tablesorter-filter").last().addClass("disabled").attr('disabled', true);

	    var time_reload = $('#schedule_reload').val();
        if (time_reload != "0") {
        	startAutoUpdate(page, column, time_reload)
        } else {
            stopAutoUpdate();
        }
	}

    $(document).on('change', '#schedule_reload', function () {
    	var time_reload = $('#schedule_reload').val();
    	$.ajax({
            type: "POST",
            url:appRoot+"OutSchedule/sessionTimeReload",
            data: {
            	time_reload: time_reload,
            },
            async: false,
            success:function(data){
            }
        });
        stopAutoUpdate();
        if (time_reload != "0") {
        	startAutoUpdate(page, column, time_reload)
        }
    });

	$(document).on('click', '#btn_delete', function () {
		$('.alert').hide();
		if ($('input[type="checkbox"][schedule_id]:checked').size() < 1) {
			$('#outschedule-error-message').find('p').text(SCHEDULE_MSG_ALERT_PLS_CHOOSE_SCHEDULE);
			$('#outschedule-error-message').show();
			return false;
		}

		var schedule_ids = [];
		$('input[type="checkbox"][schedule_id]:checked').each(function(index) {
			schedule_ids[index] = $(this).attr("schedule_id");
		});

		$.ajax({
			type: "POST",
			url:appRoot+"OutSchedule/check_delete_schedule/",
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
				} else if (status == "err_status_can_not_delete"){
					$('#outschedule-error-message').find('p').text(SCHEDULE_MSG_ALERT_CANNOT_DEL_SCHEDULE);
					$('#outschedule-error-message').show();
				} else if (status == "error_locking"){
					$('#outschedule-error-message').find('p').text(SCHEDULE_MSG_ALERT_SCHEDULE_IS_LOCKING);
					$('#outschedule-error-message').show();
				} else if (status == "error_start_time") {
					$('#outschedule-error-message').find('p').text(OUTBOUND_SCHEDULE_SETTING_DELETE_INTERVAL_MESSAGE);
					$('#outschedule-error-message').show();
				} else {
					if (confirm(SCHEDULE_MSG_CONFIRM_DEL)){
						display_load();

						var url=appRoot+"OutSchedule/delete";
						$("#T20OutScheduleIndexForm").attr('action', url);
						$("#T20OutScheduleIndexForm").attr('method', 'post');
						$("#T20OutScheduleIndexForm").attr('enctype', 'multipart/form-data');

						$('input[name="schedule_ids[]"]').remove();
						$('input[type="checkbox"][schedule_id]:checked').each(function() {
							var schedule_ids = document.createElement("input");
							schedule_ids.type = 'hidden';
							schedule_ids.name = 'schedule_ids[]';
							schedule_ids.value = $(this).attr("schedule_id");
							$("#T20OutScheduleIndexForm").append(schedule_ids);
						});

						$('input[type="checkbox"]:checked').prop('checked', false);
						$("#T20OutScheduleIndexForm").submit();
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

		if ($('input[type="checkbox"][schedule_id]:checked').size() < 1) {
			$('#outschedule-error-message').find('p').text(SCHEDULE_MSG_ALERT_PLS_CHOOSE_SCHEDULE);
			$('#outschedule-error-message').show();
			$("#select_type_download").val("select_download").trigger('chosen:updated');
			return false;
		}

		var schedule_ids = [];
		$('input[type="checkbox"][schedule_id]:checked').each(function(index) {
			schedule_ids[index] = $(this).attr("schedule_id");
		});

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
					$('#outschedule-error-message').find('p').text(SCHEDULE_MSG_ALERT_CANNOT_DOWNLOAD_SCHEDULE);
					$('#outschedule-error-message').show();
					$("#select_type_download").val("select_download").trigger('chosen:updated');
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
							//$(":checkbox").prop('checked', false);
							setEnabled();
							$.unblockUI();
							$("#select_type_download").val("select_download").trigger('chosen:updated');
						}
					});
				}
			},
		});
	});

	$(document).on('click', '.lnkStop', function() {
		var schedule_id = $(this).attr("schedule_id");
		var btnFuncContainer = $(this).parent();

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

				if (result == 'error_status') {
					alert(arr["msg"]);
					location.reload();
				} else if (result == 'err_not_exist') {
					alert(SCHEDULE_MSG_ALERT_NOT_EXIST_SCHEDULE);
					location.reload();
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
									setEnabled();
									btnFuncContainer.html('');
									btnFuncContainer.parent().parent().find('td').css('background-color','#f2d6b1');
									btnFuncContainer.parent().parent().find('.called_total').removeClass('elereload');
								}else{
									alert(SCHEDULE_MSG_ALERT_STOP_ERROR);
									window.location.href = appRoot+"OutSchedule/index/systemerror";
								}
							}
						});
					}
				}
			}
		});
	});

	//Outのスケジュール一覧で、あるスケジュールの「状況を見る」を押した時の処理
    $(document).on('click', '.lnkStatistic', function () {
        var schedule_id = $(this).attr('schedule_id');
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
            	}else{
            		var ip = document.createElement('input');
            		ip.type = 'hidden';
            		ip.name = 'schedule_id';
            		ip.value = schedule_id;
            		//// 画面遷移をし、該当スケジュールの状況を収集します。
                    var url = appRoot + 'OutSchedule/status';

                    display_load();

                    $('#T20OutScheduleIndexForm').attr('action', url);
                    $('#T20OutScheduleIndexForm').attr('method', 'post');
                    $('#T20OutScheduleIndexForm').attr('enctype', 'multipart/form-data');
                    $('#T20OutScheduleIndexForm').append(ip);
                    $('#T20OutScheduleIndexForm').submit();
            	}
            }
        });
	});

	$('#bundleCheckbox').on('click', function() {
		toggleCheckStatus($(this));
	});
});

var autoUpdate;
function stopAutoUpdate(){
	clearInterval(autoUpdate);
}
function startAutoUpdate(page, column, time_reload){
	time_reload = parseInt(time_reload)*1000*60;
	autoUpdate = setInterval(function() {
		if($("#hdPageSchedule").val()){
			page = parseInt($("#hdPageSchedule").val());
		}
		if($("#hdSortColumnSchedule").val() && $("#hdSortTypeSchedule").val()){
			column = [[parseInt($("#hdSortColumnSchedule").val()), parseInt($("#hdSortTypeSchedule").val())]];
		}

		//テーブルリロード
		$.ajax({
            type: "POST",
            url: appRoot + "OutSchedule/arr_schedule/" + page + "/20/column[" + column[0][0] + "]=" + column[0][1] + "?",
            cache: false,
            dataType: 'json',
            beforeSend: function(){
            	$(document).find(".elereload").each(function(){
            		$(".elereload").html("<img src=\""+appRoot+"img/ajax_loader.gif\" />");
            	});
            },
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
                    $("#scheduleTable").trigger("renderAjax", json_data);
					$("#scheduleTable").trigger("update");
					$('#scheduleTable').trigger('pagerUpdate');
                }
            }
        });
		//チェックエラースケジュール
		//getScheduleError();
	}, time_reload);
}
