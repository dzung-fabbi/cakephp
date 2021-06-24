$(document).ready(function() {

	$.validator.addMethod('date', function(value, element, param) {
		var date_org = new Date(value);
		var date_tmp = date_org.formateCallDate("getDate");
		return this.optional( element ) || (!/Invalid|NaN/.test( new Date( value ).toString() ) && (date_tmp == value));
	});

	$("#form_update_list_info").validate({
		ignore: "",
		rules:{
			"data[T10CallList][ListName]": {
				required : true,
				remote: {
					type: 'post',
					url: appRoot + '/CallList/check_exist_listname',
					async: false,
					data: {
						list_name: function() {
							return $('input[name="data[T10CallList][ListName]"]').val();
						},
						list_name_old: list_name_old,
					}
				}
			},
		},
		messages:{
			"data[T10CallList][ListName]": {
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
				checkTel: true,
				remote: {
					type: 'post',
					url: appRoot + '/CallList/check_exist_tel_no',
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
		},
		messages: {
			'tel_number': {
				checkTel: MSG_ERROR_CHECK_TEL,
				remote: MSG_ERROR_EXIST_TEL_NO,
			},
		},
	});

	var page = 0, column = [];
	if($("#hdPageList").val()){
		page = parseInt($("#hdPageList").val());
	}
	if($("#hdSortColumnList").val() && $("#hdSortTypeList").val()){
		column = [[parseInt($("#hdSortColumnList").val()), parseInt($("#hdSortTypeList").val())]];
	} else {
		if (enable_edit_call_list) {
			column = [[1, 1]];
		} else {
			column = [[0, 1]];
		}
	}

	$("#telListTable").tablesorter({
		theme: 'gold',
		widthFixed: true,
		sortLocaleCompare: true,
		sortList: column,
		widgets: ['zebra', 'filter'],
	}).tablesorterPager({
		container: $(".pager"),
		type: "POST",
		ajaxUrl: appRoot + "CallList/tel_list/{page}/20/{sortList:column}?{filterList:filter}",
		ajaxObject: {
			cache: false,
			dataType: 'json'
		},
		ajaxProcessing: function(data){
			if (data && data.hasOwnProperty('rows')) {
				var indx, r, row, c, d = data.rows,
				total = data.total_rows,
				headers = data.headers,
				headerXref = headers.join(',').replace(/\s+/g,'').split(','),
				rows = [],
				len = d.length;
				inefficient_tel_list_ids = {};
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

	/*$('#dialog_add_tel_list').dialog({
		title: '新規登録画面',
		width: 650,
		position: {
			my: 'top',
			at: 'top+220'
		},
		modal: true,
		autoOpen: false,
		resizable: false,
		show: {
			effect: "blind",
			duration: 100
		},
		hide: {
			effect: "blind",
			duration: 100
		},
		close: function() {
			$('.error').html('');
			$("#dialog_add_tel_list input").each(function() {
				$(this).val('');
				$(this).removeClass('error');
			});
			$('select').val('');
		},
	});*/

	/*$('#btn_cancel_add_tel').click(function () {
		$('#dialog_add_tel_list').dialog('close');
	});*/
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
		setDisabled(); // 20160405 Add by Giang - #6854 - disable double-click
		$('.alert').hide();
		if($("#form_update_list_info").valid() && confirm(MSG_CONFIRM_UPDATE)) {
			display_load();
			$.ajax({
				type: "POST",
				url: appRoot+"CallList/update_tel_list_name/",
				data: {
					listName: $('#call_list_name').val(),
					listTestFlag: $('#list_test_flag').is(':checked'),
					callListId: $('#call_list_id').val(),
				},
				success:function(data){
					$.unblockUI();
					if (data == 'save') {
						$('#cl-detail-success-message').find('p').text(MSG_ALERT_UPDATE_SUCCESS);
						$('#cl-detail-success-message').show();
					} else if (data == 'systemerror') {
						alert(MSG_ALERT_SYSTEM_ERROR);
						window.location.href=appRoot+"CallList/index";
					}
				},
			});
		}
		setEnabled(); // 20160405 Add by Giang - #6854 - disable double-click
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

		var call_list_id = $(this).attr('call_list_id');
		var tel_total = $(this).attr('tel_total');

		$.ajax({
			type: "POST",
			url:appRoot+"CallList/check_info_tel/",
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
				}else if(data == "err_calling"){
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
							url:appRoot+"CallList/delete_tel/",
							data: {
								tel_list_ids: tel_list_ids,
								call_list_id: call_list_id,
								tel_total: tel_total,
							},
							success:function(data){
								$.unblockUI();
								if (data == 'systemerror') {
									alert(MSG_ALERT_SYSTEM_ERROR);
									location.reload();
								}
								$('#cl-detail-success-message').find('p').text(tel_list_ids.length + '件' + MSG_ALERT_DEL_SUCCESS);
								$('#cl-detail-success-message').show();
								var results = JSON.parse(data);
								reload_table_tel_list(results['page'], results['sortColumn'], results['sortType']);
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
			url:appRoot+"CallList/check_info_tel/",
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
							url:appRoot+"CallList/inefficient_tel/",
							data: {
								tel_list_ids: inefficient_tel_list_ids,
								list_id: $('#call_list_id').val(),
							},
							success:function(data){
								$.unblockUI();
								var data = JSON.parse(data);
								if (data.hasOwnProperty('status') && (data.status == 'update_muko' || data.status == 'existed_ch_stopped')) {
									if(data.status == "existed_ch_stopped"){
										$('#cl-detail-success-message').find('p').text(MSG_ALERT_UPDATE_MUKO_ERROR);
									}else
										$('#cl-detail-success-message').find('p').text(Object.keys(inefficient_tel_list_ids).length + '件' + MSG_ALERT_UPDATE_MUKO_SUCCESS);
									$('#cl-detail-success-message').show();
									inefficient_tel_list_ids = {};

									$('.inefficient').each(function () {
										if ($(this).is(':checked') && data.using_flag == 1) {
											$(this).prop('disabled', true);
										}
									});
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
				url:appRoot+"CallList/check_info_tel/",
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
					}else if(data == "err_calling"){
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
								url: appRoot+"CallList/add_and_edit_tel/",
								data: {
									data_tel: data_tel,
								},
								success:function(data){
									$.unblockUI();
									if (data == 'systemerror') {
										alert(MSG_ALERT_SYSTEM_ERROR);
										$('#dialog_add_tel_list').modal('hide');
										location.reload();
									}else if(data == 'err_sms_over_length'){
										alert(ADD_LIST_SMS_BODY_ITEM_REACH_LIMIT);
										$('#dialog_add_tel_list').modal('hide');
										location.reload();
									}else if(data == 'err_sms_illegal_url_string'){
										alert(ADD_LIST_SMS_BODY_ITEM_ILLEGAL_STRING);
										$('#dialog_add_tel_list').modal('hide');
										location.reload();
									}else if(data == 'err_sms_over_url_length'){
										alert(SMS_BODY_ITEM_REACH_LIMIT_SHORT_URL);
										$('#dialog_add_tel_list').modal('hide');
										location.reload();
									}

									var results = JSON.parse(data);
									if (results['status'] == 'insert') {
										$('#cl-detail-success-message').find('p').text(MSG_ALERT_INSERT_SUCCESS);
										$('#cl-detail-success-message').show();
									} else if (results['status'] == 'update') {
										$('#cl-detail-success-message').find('p').text(MSG_ALERT_UPDATE_SUCCESS);
										$('#cl-detail-success-message').show();
									}
									// $('#dialog_add_tel_list').dialog('close');
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

	var url = appRoot + "CallList/tel_list/" + page + "/20/column?filter";
	if (sortColumn != null && sortType != null) {
		url = appRoot + "CallList/tel_list/" + page + "/20/column[" + sortColumn + "]=" + sortType + "?filter";
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