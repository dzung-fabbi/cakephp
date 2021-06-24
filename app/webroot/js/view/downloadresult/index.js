$(document).ready(function() {
	$("#form_download_result").validate({
		ignore: "",
		rules:{
			'division': {
				required: true,
			},
			'company_id': {
				required: true,
			}
		},
		messages: {
			'division': {
				required: MSG_ERROR_BLANK_DIVISION,
			},
			'company_id': {
				required: MSG_ERROR_BLANK_COMPANY,
			}
		},
	});

	$('#division').on('change', function () {
		var previous_selected = $(this).data('previous-selected');
		var current_selected = $(this).val();

		$('.label_tel').addClass('hidden_element');
		if ($(this).val() != '') {
			$('.label_tel.' + $(this).val()).removeClass('hidden_element');
		} else {
			$('.label_tel.outbound').removeClass('hidden_element');
		}

		switch (current_selected) {
			case 'outbound':
			case 'inbound':
				if (previous_selected == '' || previous_selected == 'sms') {
					update_select_tel($(this).val(), $('#company_id').val());
				}
				break;
			case 'sms':
				if (previous_selected == '' || previous_selected == 'outbound' || previous_selected == 'inbound') {
					update_select_tel($(this).val(), $('#company_id').val());
				}
				break;
			default:
				// 区分未選択
				$('select#tel_number option').not(':first').remove();
		}

		$(this).data('previous-selected', $(this).val());
	});

	$('#company_id').change(function() {
		update_select_tel($('#division').val(), $('#company_id').val());
	});


	$(document).on('click', '#btnDownload', function() {
		var division_code = $('#division').val();
		var company_id = $('#company_id').val();
		var tel_number = $('#tel_number').val();
		var date_from = $('#expired_date_from').val();
		var date_to = $('#expired_date_to').val();

		var error_expired = show_msg_error_expired();
		$(document).on('change', '.expired', function () {
			error_expired = show_msg_error_expired();
		});
		$(document).on('click', '.ui-datepicker-close', function () {
			error_expired = show_msg_error_expired();
		});

		if ($("#form_download_result").valid() && error_expired) {
			var count_date = (new Date($('#expired_date_to').val()).getTime() - new Date($('#expired_date_from').val()).getTime())/86400000 + 1;
			if (count_date < 1) {
				alert(MSG_ERROR_DATE_FROM_GREATER_THAN_DATE_TO);
				return;
			} else if (count_date > 31) {
				alert(MSG_ERROR_COUNT_DATE_31);
				return;
			}
			setDisabled();

			if (confirm(MSG_CONFIRM_DOWNLOAD)) {
				display_load();
				$.ajax({
					url: appRoot + "DownloadResult/buffer_download_data",
					type: "post",
					data: {
						division_code: division_code,
						company_id: company_id,
						tel_number: tel_number,
						date_from: date_from,
						date_to: date_to,
					},
					success: function (result) {
						var result = JSON.parse(result);

						if (result['status'] == 'error_limit_count') {
							alert(MSG_ERROR_LIMIT_COUNT_1 + result['count_result'] + MSG_ERROR_LIMIT_COUNT_2);
						} else if (result['status'] == "success") {
							window.location.href = appRoot + "DownloadResult/download_result";
						} else {
							window.location.href = appRoot+"DownloadResult/index";
						}
						setEnabled();
						$.unblockUI();
					}
				});
			}
		}
	});

	{
		$('.label_tel').addClass('hidden_element');
		$('.label_tel.outbound').removeClass('hidden_element');
		update_select_tel($('#division').val(), $('#company_id').val());
		init_datepicker();
	}
});

/**
 * 電話番号（通知番号）プルダウンの制御
 * @param {string} division 選択した区分
 * @param {string} company_id 選択したアカウント
 */
function update_select_tel(division, company_id) {
	$('select#tel_number option').not(':first').remove();

	if (division == '' || company_id == '') {
		return;
	}

	$.ajax({
		type: "POST",
		url: appRoot + "DownloadResult/get_number_by_division_and_company/",
		data: {
			division: division,
			company_id: company_id
		},
		dataType: 'json',
		async: false,
		success: function (data) {
			$.each(data, function (index, value) {
				if (value.division == 'sms' && value.api_id == SMS_API_V2_VALUE) {
					$('#tel_number').append($('<option>').html(value.tel_number + SMS_API_V2_AFTER_TELL_STRING).val(value.tel_number));
				} else {
					$('#tel_number').append($('<option>').html(value.tel_number).val(value.tel_number));
				}
			})
		}
	});
}

function init_datepicker() {
	$('#expired_date_from').datepicker({
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
		}
	});

	$('#expired_date_to').datepicker({
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
		}
	});

	$("#expired_date_from").datepicker('setDate', new Date());
	$("#expired_date_to").datepicker('setDate', new Date());

}
function show_msg_error_expired() {
	var expired_date_from = $('#expired_date_from').val();
	var expired_date_to = $('#expired_date_to').val();

	if (!expired_date_from) {
		$('#expired_date_from-error').show().html(MSG_ERROR_BLANK_DATE_FROM);
		$('#expired_date_to-error').show().html('');
		return false;
	} else if (!expired_date_to) {
		$('#expired_date_to-error').show().html(MSG_ERROR_BLANK_DATE_TO);
		$('#expired_date_from-error').show().html('');
		return false;
	} else {
		$('#expired_date_to-error').hide().html('');
		$('#expired_date_from-error').hide().html('');
		return true;
	}
}