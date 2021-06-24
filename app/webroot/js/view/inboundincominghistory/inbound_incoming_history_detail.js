$(document).ready(function() {

	var filter_functions = {};
	$('#sort_transfer').each(function() {
		var position = $(this).attr('position');
		filter_functions[position] = {
			"ANSWER" : function(e, n, f, i, $r, c, data) { return e === f; },
			"TRANSFER" : function(e, n, f, i, $r, c, data) { return e === f; },
			"TRANSFERFULL" : function(e, n, f, i, $r, c, data) { return e === f; },
			"TRANSFERTIMEOUT" : function(e, n, f, i, $r, c, data) { return e === f; },
			"TRANSFERREJECT" : function(e, n, f, i, $r, c, data) { return e === f; }
		};
	});

    $('.auth_digit').each(function() {
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
    $('.fax_status').each(function() {
        var position = $(this).attr('position');
        filter_functions[position] = {
        	"送信なし" : function(e, n, f, i, $r, c, data) { return e === f; },
            "送信中" : function(e, n, f, i, $r, c, data) { return e === f; },
            "送達" : function(e, n, f, i, $r, c, data) { return e === f; },
            "不達" : function(e, n, f, i, $r, c, data) { return e === f; },
            "エラー" : function(e, n, f, i, $r, c, data) { return e === f; }
        };
    });
    $('.inbound_sms_status').each(function() {
        var position = $(this).attr('position');
        filter_functions[position] = {
        	"着信済み" : function(e, n, f, i, $r, c, data) { return e === f; },
            "圏外" : function(e, n, f, i, $r, c, data) { return e === f; },
            "不明" : function(e, n, f, i, $r, c, data) { return e === f; },
            "送信中" : function(e, n, f, i, $r, c, data) { return e === f; },
            "エラー" : function(e, n, f, i, $r, c, data) { return e === f; }
        };
	});
	$('.inbound_sms_input_status').each(function() {
        var position = $(this).attr('position');
        filter_functions[position] = {
        	"着信済み" : function(e, n, f, i, $r, c, data) { return e === f; },
            "圏外" : function(e, n, f, i, $r, c, data) { return e === f; },
            "不明" : function(e, n, f, i, $r, c, data) { return e === f; },
            "送信中" : function(e, n, f, i, $r, c, data) { return e === f; },
            "エラー" : function(e, n, f, i, $r, c, data) { return e === f; }
        };
    });

	init_table(false, 'InboundIncomingHistory', 'arr_incoming_result', '#t80IncomingResultTable', filter_functions);

	$(document).on('click', '.btnDownload', function() {
		var func_name = $(this).attr('func-name');
		var flag = true;
		if(func_name != 'download_uncalled'){
		if(validateDate()){
			var startDate = parseInt($('#start_date').val().replace(/-/gi,''));
			var endDate = parseInt($('#end_date').val().replace(/-/gi,''));
			var start = moment($('#start_date').val());
			var end = moment($('#end_date').val());
			var countDay = end.diff(start, 'days');
			if(startDate >  endDate){
				alert(MSG_ERROR_DATE_FROM_GREATER_THAN_DATE_TO);
					flag = false;
			}else if ((countDay + 1) > 31){
				alert('日付の最大範囲は31日になります。');
					flag = false;
				}
			}else{
				flag = false;
			}
		}
		if(flag){
		var schedule_ids = $('#schedule_id').val();
		if (!$(this).hasClass('btn_disabled') && schedule_ids) {
			$.ajax({
				type: "POST",
				url:appRoot+"InboundIncomingHistory/check_download_schedule/",
				data: {
					schedule_ids: schedule_ids,
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
								schedule_ids: schedule_ids,
										start_date 	: $('#start_date').val(),
										end_date 	: $('#end_date').val()
							},
							success: function(result){
								if(result == "success"){
									window.location.href = appRoot+"InboundIncomingHistory/download_schedule";
								}else{
									window.location.href = appRoot+"InboundIncomingHistory/index";
								}
								setEnabled();
								$.unblockUI();
										$('#dialogConditionDownload').modal('hide');
							}
						});


							}
							else if (status == "err_not_exist"){
						alert(INBOUND_MSG_ALERT_NOT_EXIST_INBOUND);
						location.reload();
					} else if (status == "err_status_can_not_download"){
						alert(INBOUND_MSG_ALERT_CANNOT_DOWNLOAD_INBOUND);
					} else {
						alert(MSG_ALERT_SYSTEM_ERROR);
						location.reload();
					}
				},
			});
		}
			}
		
	});

	$(document).on('click', '.btnShowDownload', function() {    	
		 init_datepicker();
		 var funcName = $(this).attr('func-name');
		 $('#dialogConditionDownload').modal('show');
		 
		 $('#dialogConditionDownload .btnDownload').attr('func-name',funcName);
		 $('#modalDownload').html(funcName == 'download_ans_log' ? '有効DL' : '履歴DL');
	});

	$(document).on('click', '.btnDownloadRecord', function() {
		schedule_id = $(this).attr("schedule_id");
		tel_no = $(this).attr("tel_no");
		prefix_record = $(this).attr("prefix_record");
		window.location = appRoot + 'InboundIncomingHistory/download_record/' + schedule_id + '/' + tel_no + '/' + prefix_record;
	});
});

function validateDate(){
	var flag = true;
	$('.error-date-start').text('');
	$('.error-date-end').text('');
		
	if($('#start_date').val() == ''){
		flag = false;
		$('.error-date-start').text('開始日を選択してください。');
		$('.error-date-end').text('');
	}else if($('#end_date').val() == ''){
		flag = false;
		$('.error-date-start').text('');
		$('.error-date-end').text('終了日を選択してください。');
	}

	return flag;
}


function init_datepicker() {
	$('.error-date-start').text('');
	$('.error-date-end').text('');
	$('#start_date').datepicker("destroy");
	$('#end_date').datepicker("destroy");
	initStart();
	initEnd();
	initDate();	
}

function initDate(){
	$("#end_date").datepicker('setDate', new Date());
	$("#start_date").datepicker('setDate', new Date());
}

function initEnd(date){	
	$('#end_date').datepicker({
		maxDate: 'D',
		buttonText: '開始日時選択',
		timeFormat: 'HH:mm',
		dateFormat: 'yy-mm-dd',
		closeText: 'リセット',
		showButtonPanel: true,
		onClose: function(selectedDate) {						
			if ($(window.event.srcElement).hasClass('ui-datepicker-close')) {
				$(this).val('');
			}			
			validateDate();
			if($(this).val() != ''){
				$('.error-date-end').text('');
			}
		}
	});
}

function initStart(date){	
	var end = $("#end_date").val();
	var start =  end.substring(0,7) + '-01';

	$('#start_date').datepicker({
		maxDate: 'D',
		buttonText: '開始日時選択',
		timeFormat: 'HH:mm',
		dateFormat: 'yy-mm-dd',
		closeText: 'リセット',
		showButtonPanel: true,		
		onClose: function(selectedDate) {		
			if ($(window.event.srcElement).hasClass('ui-datepicker-close')) {
				$(this).val('');
			}	
			validateDate();
			if($(this).val() != ''){
				$('.error-date-start').text('');
			}
			
		}
	});
}