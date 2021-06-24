$(document).ready(function() {

	// show list sms tel get from t101
	init_table(enable_delete, 'SmsSendList', 'tel_list', '#telListTable');

	$.validator.addMethod('date', function(value, element, param) {
		var date_org = new Date(value);
		var date_tmp = date_org.formateCallDate("getDate");
		return this.optional( element ) || (!/Invalid|NaN/.test( new Date( value ).toString() ) && (date_tmp == value));
	});

	$("#form_update_list_info").validate({
		ignore: "",
		rules:{
			"data[T100SmsSendList][ListName]": {
				required : true,
				remote: {
					type: 'post',
					url: appRoot + '/SmsSendList/check_exist_listname',
					async: false,
					data: {
						list_name: function() {
							return $('input[name="data[T100SmsSendList][ListName]"]').val();
						},
						list_name_old: list_name_old,
					}
				}
			},
		},
		messages:{
			"data[T100SmsSendList][ListName]": {
				required: MSG_ERROR_REQUIRED_LIST_NAME,
				remote: MSG_ERROR_EXIST_LIST_NAME
			},
		},
	});

	$("#form_add_edit_tel").validate({
		ignore: "",
		rules:{
			'tel_number': {
				required : true,
				checkTelMob: true,
				remote: {
					type: 'post',
					url: appRoot + '/SmsSendList/check_exist_tel_no',
					async: false,
					data: {
						tel_list_id: function() {
							return $('#form_add_edit_tel input[name="id"]').val();
						},
						tel_number_col: indexTelNo,
					}
				}
			},
			'fee': {
				number: true,
			},
			'birthday_date': {
				date: true,
			},
			'consentday_date': { // #8298 add consentday
				date: true,
			},
		},
		messages: {
			'tel_number': {
				checkTelMob: MSG_ERROR_CHECK_TEL_SMS,
				remote: MSG_ERROR_EXIST_TEL_NO,
			},
		},
	});

	$('#dialog_add_tel_list').on('hidden.bs.modal', function (e) {
		$('.error').html('');
		$("#dialog_add_tel_list input").each(function() {
			$(this).val('');
			$(this).removeClass('error');
		});
		$('#dialog_add_tel_list select').val('');
	})

	$(document).on('click', '.lnkEdit', function() {
		$('.alert').hide();
		$('#myModalLabel').html('編集');
		$('#dialog_add_tel_list').modal('show');

		var tel_list_id = $(this).attr('tel_list_id');
		var column_val = $(this).closest('tr').find('td');

		$('#form_add_edit_tel input').each(function(index) {
			if ($(this).attr('id') == 'id') {
				$(this).val(tel_list_id);
			} else if ($(this).attr('name') == 'birthday_date') {
				var date_tmp = new Date(column_val[index + 1].innerHTML);
				var year = date_tmp.getFullYear() ? date_tmp.getFullYear() : '';
				var month = !isNaN(date_tmp.formateCallDate('getMonth')) ? date_tmp.formateCallDate('getMonth') : '';
				var day = !isNaN(date_tmp.formateCallDate('getDay')) ? date_tmp.formateCallDate('getDay') : '';
				$('select[name="birthdayYear"]').val(year);
				$('select[name="birthdayMonth"]').val(month);
				$('select[name="birthdayDay"]').val(day);
			} else if ($(this).attr('name') == 'consentday_date') { // #8298 add consentday
				var date_tmp = new Date(column_val[index + 1].innerHTML);
				var year = date_tmp.getFullYear() ? date_tmp.getFullYear() : '';
				var month = !isNaN(date_tmp.formateCallDate('getMonth')) ? date_tmp.formateCallDate('getMonth') : '';
				var day = !isNaN(date_tmp.formateCallDate('getDay')) ? date_tmp.formateCallDate('getDay') : '';
				$('select[name="consentdayYear"]').val(year);
				$('select[name="consentdayMonth"]').val(month);
				$('select[name="consentdayDay"]').val(day);
			} else {
				$(this).val(column_val[index + 1].textContent);
			}
		});
	});

	$('#btnAddTel').click(function() {
		$('.alert').hide();
		$('#myModalLabel').html('新規登録');
		$('#dialog_add_tel_list').modal('show');
	});

	$('#btnSaveTelList').click(function() {
		setDisabled();
		$('.alert').hide();
		if($("#form_update_list_info").valid() && confirm(MSG_CONFIRM_UPDATE)) {
			display_load();
			$.ajax({
				type: "POST",
				url: appRoot+"SmsSendList/update_tel_list_name/",
				data: {
					listName: $('#list_name').val(),
					listTestFlag: $('#list_test_flag').is(':checked'),
					listId: $('#list_id').val(),
				},
				success:function(data){
					$.unblockUI();
					if (data == 'save') {
						$('#cl-detail-success-message').find('p').text(MSG_ALERT_UPDATE_SUCCESS);
						$('#cl-detail-success-message').show();
					} else {
						alert(MSG_ALERT_SYSTEM_ERROR);
						window.location.href=appRoot+"SmsSendList/index";
					}
				},
			});
		}
		setEnabled();
	});

	$(document).on('click', '.label_select_item', function () {
		var input_name = $(this).attr('for');
		$('input[name="' + input_name + '"]').checked = true;
	});

	$(document).on('click', '#btnDelTel', function () {
		setDisabled(); // 20160405 Add by Giang - #6854 - disable double-click
		$('.alert').hide();
		var cbSelects = $(".select_item:checkbox").serializeArray();
		var tel_list_ids = [];
		$.each(cbSelects, function(i, cbSelect) {
			tel_list_ids[i] = cbSelect.value;
		});

		if (tel_list_ids.length < 1) {
			$('#cl-detail-error-message').find('p').text(MSG_ALERT_PLS_CHOOSE_TEL);
			$('#cl-detail-error-message').show();
			setEnabled(); // 20160405 Add by Giang - #6854 - disable double-click
			return false;
		}

		var list_id = $(this).attr('list_id');
		var tel_total = $(this).attr('tel_total');

		$.ajax({
			type: "POST",
			url:appRoot+"SmsSendList/check_info_tel/",
			data: {
				tel_list_ids: tel_list_ids,
			},
			async: false,
			success:function(data){
				if(data == "err_list_not_exist"){
					alert(MSG_ALERT_NO_EXIST_LIST);
					location.reload();
				}else if(data == "err_used"){
					alert(MSG_ALERT_CANNOT_DEL_LIST);
					location.reload();
				}else if(data == "err_sending"){
					alert(MSG_ALERT_LIST_CALLING_DEL_TEL);
					location.reload();
				}else if(data == "err_tel_not_exist"){
					alert(MSG_ALERT_NO_EXIST_TEL);
					location.reload();
				}else{
					if (confirm(MSG_CONFIRM_DEL)) {
						display_load();
						$.ajax({
							type: "POST",
							url:appRoot+"SmsSendList/delete_tel/",
							data: {
								tel_list_ids: tel_list_ids,
								list_id: list_id,
								tel_total: tel_total,
							},
							success:function(data){
								$.unblockUI();
								var results = JSON.parse(data);
								if (results['status'] == 'delete_success') {
									$('#cl-detail-success-message').find('p').text(tel_list_ids.length + '件' + MSG_ALERT_DEL_SUCCESS);
									$('#cl-detail-success-message').show();
									reload_table_tel_list(results['page'], results['sortColumn'], results['sortType']);
								} else {
									alert(MSG_ALERT_SYSTEM_ERROR);
									location.reload();
								}
							},
						});
					}
				}
			},
		});
		setEnabled(); // 20160405 Add by Giang - #6854 - disable double-click
	});

	var inefficient_tel_list_ids = {};
	$(document).on('change', '.inefficient', function () {
		var tel_list_id = $(this).attr('tel_list_id');
		var muko_flag = $(this).is(':checked') ? 'Y' : 'N';
		inefficient_tel_list_ids[tel_list_id] = muko_flag;
	});

	$(document).on('click', '#btnInefficient', function () {
		setDisabled(); // 20160405 Add by Giang - #6854 - disable double-click
		$('.alert').hide();
		if (Object.keys(inefficient_tel_list_ids).length < 1) {
			$('#cl-detail-error-message').find('p').text(MSG_ALERT_PLS_CHANGE_TEL);
			$('#cl-detail-error-message').show();
			setEnabled(); // 20160405 Add by Giang - #6854 - disable double-click
			return false;
		}

		var tel_list_ids = {};
		for (var id in inefficient_tel_list_ids) {
			tel_list_ids[id] = id;
		}
		$.ajax({
			type: "POST",
			url:appRoot+"SmsSendList/check_info_tel/",
			data: {
				tel_list_ids: tel_list_ids,
			},
			async: false,
			success:function(data){
				if(data == "err_list_not_exist"){
					alert(MSG_ALERT_NO_EXIST_LIST);
					location.reload();
				}else if(data == "err_tel_not_exist"){
					alert(MSG_ALERT_NO_EXIST_TEL);
					location.reload();
				}else{
					if (confirm(MSG_CONFIRM_UPDATE)) {
						display_load();
						$.ajax({
							type: "POST",
							url:appRoot+"SmsSendList/inefficient_tel/",
							data: {
								tel_list_ids: inefficient_tel_list_ids,
								list_id: $('#list_id').val(),
							},
							success:function(data){
								$.unblockUI();
								if (data == 'update_muko_success') {
									$('#cl-detail-success-message').find('p').text(Object.keys(inefficient_tel_list_ids).length + '件' + MSG_ALERT_UPDATE_MUKO_SUCCESS);
									$('#cl-detail-success-message').show();
									inefficient_tel_list_ids = {};
								} else {
									alert(MSG_ALERT_SYSTEM_ERROR);
									location.reload();
								}
							},
						});
					}
				}
			}
		});
		setEnabled(); // 20160405 Add by Giang - #6854 - disable double-click
	});

	$('#btn_add_edit_tel').click(function() {
		setDisabled(); // 20160405 Add by Giang - #6854 - disable double-click
		$('.alert').hide();
		if (($('select[name="birthdayYear"]').val() != '') || ($('select[name="birthdayMonth"]').val() != '') || ($('select[name="birthdayDay"]').val() != '')) {
			var birthday_date = $('select[name="birthdayYear"]').val() + '-' + $('select[name="birthdayMonth"]').val() + '-' + $('select[name="birthdayDay"]').val();
			$('.birthday_date').val(birthday_date);
		} else {
			$('.birthday_date').val('');
		}
		// #8298 add consentday
		if (($('select[name="consentdayYear"]').val() != '') || ($('select[name="consentdayMonth"]').val() != '') || ($('select[name="consentdayDay"]').val() != '')) {
			var consentday_date = $('select[name="consentdayYear"]').val() + '-' + $('select[name="consentdayMonth"]').val() + '-' + $('select[name="consentdayDay"]').val();
			$('.consentday_date').val(consentday_date);
		} else {
			$('.consentday_date').val('');
		}
		var action = 'add';
		if ($('#id').val() != '') {
			action = 'edit';
		}

		if($('#form_add_edit_tel').valid()) {
			var validator = $( "#form_add_edit_tel" ).validate();
			validator.resetForm();

			birthday_val = $('.birthday_date').val();
			if (birthday_val) {
				var birthday_tmp = birthday_val.replace(/\D/g, "");
				var birthday = birthday_tmp.substr(0, 4) + '年' + birthday_tmp.substr(4, 2) + '月' + birthday_tmp.substr(6, 2) + '日';
				$('.birthday_date').val(birthday);
			}

			var data_tel = {};

			// #8298 add consentday
			consentday_val = $('.consentday_date').val();
			if (consentday_val) {
				var consentday_tmp = consentday_val.replace(/\D/g, "");
				var consentday = consentday_tmp.substr(0, 4) + '年' + consentday_tmp.substr(4, 2) + '月' + consentday_tmp.substr(6, 2) + '日';
				$('.consentday_date').val(consentday);
				data_tel["consentday"] = consentday_tmp+"000000";
			} else {
				data_tel["consentday"] = null;
			}

			var name, value;
			var info_tels = $("#form_add_edit_tel input");

			$.each(info_tels, function(i, info) {
				if ($(this).attr('id') == indexTelNo) {
					data_tel[$(this).attr('id')] = $(this).val().replace(/\D/g, "");
				} else {
					data_tel[$(this).attr('id')] = $(this).val();
				}
			});

			$.ajax({
				type: "POST",
				url:appRoot+"SmsSendList/check_info_tel/",
				data: {
					tel_list_ids: $('#id').val(),
					action: action,
				},
				async: false,
				success:function(data){
					if(data == "err_list_not_exist"){
						alert(MSG_ALERT_NO_EXIST_LIST);
						location.reload();
					}else if(data == "err_used"){
						alert(MSG_ALERT_CANNOT_DEL_LIST);
						location.reload();
					}else if(data == "err_sending"){
						if (action == 'add') {
							alert(MSG_ALERT_LIST_CALLING_ADD_TEL);
						} else {
							alert(MSG_ALERT_LIST_CALLING_EDIT_TEL);
						}
						location.reload();
					}else if(data == "err_tel_not_exist"){
						alert(MSG_ALERT_NO_EXIST_TEL);
						location.reload();
					}else if(data == "err_limit_max_tel"){
						$('#cl-detail-error-message').find('p').text(MSG_ALERT_LIMIMT_MAX_TEL);
						$('#cl-detail-error-message').show();
						$('#dialog_add_tel_list').modal('hide');
					}else{

						if(confirm(MSG_CONFIRM_CONTINUE)) {
							display_load();
							$.ajax({
								type: "POST",
								url: appRoot+"SmsSendList/add_and_edit_tel/",
								data: {
									data_tel: data_tel,
								},
								success:function(data){
									$.unblockUI();
									var results = JSON.parse(data);

									if (results['status'] == 'insert') {
										$('#cl-detail-success-message').find('p').text(MSG_ALERT_INSERT_SUCCESS);
										$('#cl-detail-success-message').show();
									} else if (results['status'] == 'update') {
										$('#cl-detail-success-message').find('p').text(MSG_ALERT_UPDATE_SUCCESS);
										$('#cl-detail-success-message').show();
									}else if(results['status'] == 'err_sms_over_length'){
										alert(ADD_LIST_SMS_BODY_ITEM_REACH_LIMIT);
										$('#dialog_add_tel_list').modal('hide');
										location.reload();
										return;
									}else if(results['status'] == 'err_sms_illegal_url_string'){
										alert(SMS_ILLEGAL_STRING_IN_BODY_URL);
										$('#dialog_add_tel_list').modal('hide');
										location.reload();
										return;
									}else if(results['status'] == 'err_sms_over_url_length'){
										alert(SMS_BODY_ITEM_REACH_LIMIT_SHORT_URL);
										$('#dialog_add_tel_list').modal('hide');
										location.reload();
										return;
									} else {
										alert(MSG_ALERT_SYSTEM_ERROR);
										$('#dialog_add_tel_list').modal('hide');
										location.reload();
										return;
									}

									reload_table_tel_list(results['page'], results['sortColumn'], results['sortType']);
									$('#dialog_add_tel_list').modal('hide');
								},
							});
						}
					}
				},
			});
		}
		setEnabled(); // 20160405 Add by Giang - #6854 - disable double-click
	});

	$('#bundleCheckbox').on('click', function() {
		toggleCheckStatus($(this));
	});
});

function reload_table_tel_list(page, sortColumn, sortType) {

	var url = appRoot + "SmsSendList/tel_list/" + page + "/20/column?filter";
	if (sortColumn != null && sortType != null) {
		url = appRoot + "SmsSendList/tel_list/" + page + "/20/column[" + sortColumn + "]=" + sortType + "?filter";
	}

	$.ajax({
		type: "POST",
		url: url,
		cache: false,
		dataType: 'json',
		success:function(data){
			if (data && data.hasOwnProperty('rows')) {
				var json_data = new Object();
				json_data["headers"] = data.headers;
				json_data["total_rows"] = data.total_rows;
				json_data["rows"] = data.rows;
				$("#telListTable").trigger("renderAjax", json_data);
				$("#telListTable").trigger("update");
				$('#telListTable').trigger('pagerUpdate');
			}
		}
	});
}