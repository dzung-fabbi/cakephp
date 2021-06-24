$(document).ready(function() {
	// var telLists = [];
	var validMaxSize = 80; // Megabytes

	$("#form_add_list").validate({
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
							return $("#list_name").val();
						},
					}
				}
			},
			"data[T100SmsSendList][File]": {
				required : true,
				limitedMaxSize: validMaxSize
			}
		},
		messages:{
			"data[T100SmsSendList][ListName]": {
				required: MSG_ERROR_REQUIRED_LIST_NAME,
				remote: MSG_ERROR_EXIST_LIST_NAME
			},
			"data[T100SmsSendList][File]": {
				required: MSG_ERROR_PLS_CHOOSE_FILE,
				limitedMaxSize: MSG_ERROR_LIMITED_MAX_SIZE
			},
		},
		errorPlacement: function(error, element) {
			if (element.attr('class').indexOf('sl_csv_column') != -1) {
				if ($('.data_csv_error').html() == '') {
					error.appendTo('.data_csv_error');
				}
			} else {
				error.insertAfter(element);
			}
		}
	});

	var page = 0, column = [];
	if($("#hdPageList").val()){
		page = parseInt($("#hdPageList").val());
	}
	if($("#hdSortColumnList").val() && $("#hdSortTypeList").val()){
		column = [[parseInt($("#hdSortColumnList").val()), parseInt($("#hdSortTypeList").val())]];
	}
	$("#listTable").tablesorter({
		theme: 'gold',
		widthFixed: true,
		sortLocaleCompare: true,
		sortList: column,
		widgets: ['zebra', 'filter'],
	}).tablesorterPager({
		container: $(".pager"),
		type: "POST",
		ajaxUrl: appRoot + "SmsSendList/arr_list/{page}/20/{sortList:column}?{filterList:filter}",
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
	$('#dialog_add_list').on('hidden.bs.modal', function (e) {
		$('#list_name').val('');
		$('#file_to_upload').val('');
		$('#txt-restriction').val('');
		$('#list_test_flag').attr('checked', false);
		$('.error').html('');
		$('#preview_div').html('');
		$('#data_csv_error_div').html('');
		indexFeeTmp = 0;
		indexBirthdayTmp = 0;
	})

	$('#add_list').click(function () {
		$('.alert').hide();
		$('#dialog_add_list').modal('show');
	});

	$('#btn_cancel').click(function () {
		$('#dialog_add_list').modal('hide');
	});

	$('#list_name').keyup(function() {
		$('#err_list_name').html('');
	});
	$('#list_name').change(function() {
		$('#err_list_name').html('');
	});

	$(document).on('click', '#btn_download', function () {
		setDisabled();
		$('.alert').hide();
		var cbSelects = $(":checkbox").serializeArray();
		var list_ids = [];
		$.each(cbSelects, function(i, cbSelect) {
			list_ids[i] = cbSelect.value;
		});

		if (list_ids.length < 1) {
			$('#list-error-message').find('p').text(MSG_ALERT_PLS_CHOOSE_LIST);
			$('#list-error-message').show();
			setEnabled();
			return false;
		}

		$.blockUI({
			message: "<img src=\""+appRoot+"img/loading_green.gif\" />"
		});
		var url=appRoot+"SmsSendList/buffer_csv_data";
		$.ajax({
			url: url,
			type: "post",
			data: {
				list_ids: list_ids,
			},
			success: function(result){
				if(result == "success"){
					window.location.href = appRoot+"SmsSendList/download_csv_file";
				}else{
					window.location.href = appRoot+"SmsSendList/index";
				}
				$(":checkbox").prop('checked', false);
				$.unblockUI();
			}
		});
		setEnabled(); // 20160405 Add by Giang - #6854 - disable double-click
	});

	$(document).on('click', '#btn_delete', function () {
		setDisabled();
		$('.alert').hide();
		var cbSelects = $(":checkbox").serializeArray();
		var list_ids = [];
		$.each(cbSelects, function(i, cbSelect) {
			list_ids[i] = cbSelect.value;
		});

		if (list_ids.length < 1) {
			$('#list-error-message').find('p').text(MSG_ALERT_PLS_CHOOSE_LIST);
			$('#list-error-message').show();
			setEnabled();
			return false;
		}

		$.ajax({
			type: "POST",
			url:appRoot+"SmsSendList/check_info_list/",
			data: {
				list_ids: list_ids,
			},
			async: false,
			success:function(data){
				if(data == "err_not_exist"){
					alert(MSG_ALERT_NO_EXIST_LIST);
					location.reload();
				}else if(data == "err_used"){
					alert(MSG_ALERT_CANNOT_DEL_LIST);
					location.reload();
				}else{
					if(confirm(MSG_CONFIRM_DEL)){
						display_load();

						var url=appRoot+"SmsSendList/delete";
						$("#ListIndexForm").attr('action', url);
						$("#ListIndexForm").attr('method', 'post');
						$("#ListIndexForm").attr('enctype', 'multipart/form-data');

						$("#ListIndexForm").submit();
					}
				}
			},
		});
		setEnabled();
	});


	$("#btn_upload").click(function() {
		$('#file_to_upload').val('');
		$('#file_to_upload').click();
	});
	
	/**
	 * Read file upload on client side.
	 */
	$('#file_to_upload').change(function(e) {
		var filename = $('#file_to_upload').val().replace(/C:\\fakepath\\/i, '');
		var ext = filename.substr(filename.lastIndexOf('.') +1);
		var type = filename.substr(filename.lastIndexOf('.') +1);
		var validExt = ['csv', 'txt'];
		var validType = ['text/plain', 'application/vnd.ms-excel'];

		$('#txt-restriction').val(filename);
		$('#err_file_upload').html('');
		$('#preview_div').html('');
		$('#data_csv_error_div').html('');
		telLists = [];

		if (e.target.files != undefined && $.inArray(ext, validExt) != -1 && $.inArray(e.target.files[0].type, validType) != -1) {
			if (!$(this).valid()) {
				return false;
			}

			var reader = new FileReader();
			reader.onload = function(e) {
				var csvVal = e.target.result.split("\n");
				var index = 0;

				for (var i=0; i<csvVal.length; i++) {
					if (csvVal[i].length > 0 && csvVal[i] != '\r' && csvVal[i] != '') {
						var csvValue = csvVal[i].replace(/["' 　\r]/g,'').split(',');
						//if (csvValue[0] != '' || csvValue[1] != ''){
							telLists[index] = csvValue;
							index = index + 1;
						//}
					}
				}

				var telListHead = telLists.shift();
				var telListCount = telLists.length;
				if (check_csv_data(telListHead, telListCount)) {
					telList = telLists.slice(0, 5);
					append_preview_upload(telListHead, telList);

					$("#check_tel_birthday_fee").rules('add', {
						checkTelBirthdayFee: telLists,
						messages: {
							checkTelBirthdayFee: '',
						}
					});
					$(".sl_csv_column").each(function() {
						$(this).rules("add", {
							checkCSVColumnSame: telLists,
							checkCSVColumnTel: TITLE_TEL_NUMBER,
							messages: {
								checkCSVColumnSame: MSG_ERROR_CSV_COLUMN_SAME,
								checkCSVColumnTel: MSG_ERROR_CSV_COLUMN_TEL,
							}
						});
					});
				} else {
					$('#file_to_upload').val('');
					$('#txt-restriction').val('');
					return false;
				}

			};
			reader.readAsText(e.target.files.item(0), 'sjis');
		} else {
			alert(MSG_ALERT_TYPE_FILE_UPLOAD);
			$('#err_file_upload').css('display', '');
			$('#file_to_upload').val('');
			$('#txt-restriction').val('');
		}

		return false;
	});


	$('#btn_submit').click(function() {
		setDisabled(); 
		if($("#form_add_list").valid() && confirm(MSG_CONFIRM_UPLOAD)) {
			display_load();
			$.ajax({
				type: "POST",
				url: appRoot+"SmsSendList/upload_file/",
				data: {
					listName: $('#list_name').val(),
					listTestFlag: $('#list_test_flag').is(':checked'),
					uploadData: JSON.stringify(telLists),
					fieldImport: $.parseJSON(fieldImport),  // fieldImport is defined in smssend_list_validate.js
					listItemData: $.parseJSON(listItemData) // listItemData is defined in smssend_list_validate.js
				},
				async: true,
				success:function(data){
					if (data == 'save') {
						window.location.href=appRoot+"SmsSendList/index/save";
					} else if (data == 'systemerror') {
						window.location.href=appRoot+"SmsSendList/index/systemerror";
					}
				},
			});
		}
		setEnabled();
	});

	if ($('#err_create_list').html() != '') {
		// $('#dialog_add_list').dialog('open');
		$('#dialog_add_list').modal('show');
		var input = document.getElementById("list_name");
		input.focus();
		input.setSelectionRange(input.value.length, input.value.length);
	}

	$(document).on('click', '.lnkDetail', function () {
		list_detail(this);
	})

	$(document).on('click', '#copyErrorBtn', function () {
		alert('コピーしました');
	});

	$('#bundleCheckbox').on('click', function() {
		toggleCheckStatus($(this));
	});
});

function append_preview_upload(telListHead, telList) {
	var headerKey = [TITLE_TEL_NUMBER, TITLE_CUSTOMER_NAME, TITLE_ADDRESS, TITLE_BIRTHDAY, TITLE_FEE, TITLE_CONSENTDAY];
	var str = '<div class="text-bold clear-both float_left">アップロードデータ</div>'
		+ '<table class="table table-striped table-bordered tablesorter tablesorter-gold">'
			+ '<thead>'
				+ '<tr>';
					for (var i = 0; i < telListHead.length; i++) {
						str = str + '<th style="text-align:center;">' + telListHead[i] + '</th>';
					}
			str = str + '</tr>'
			+ '</thead>'
			+ '<tbody>';
				for (var i = 0; i < telList.length; i++) {
					str = str + '<tr>';
						for (var j = 0; j < telList[i].length; j++) {
							if (telListHead[j] == TITLE_TEL_NUMBER) {
								str = str + '<td>' + telList[i][j].replace(/\D/g, '') + '</td>';
							} else if (telListHead[j] == TITLE_BIRTHDAY) {
								str = str + '<td>' + show_birthday(telList[i][j].replace(/\D/g, '')) + '</td>';
							} else if (telListHead[j] == TITLE_CONSENTDAY) { // #8298 add consentday
								str = str + '<td>' + show_consentday(telList[i][j].replace(/\D/g, '')) + '</td>';
							} else {
								str = str + '<td>' + telList[i][j] + '</td>';
							}
						}
					str = str + '</tr>';
				}
			str = str + '<tr class="box_spacer_20"></tr><tr><td colspan="' + telListHead.length + '" class="import_field">インポート先項目<span class="data_csv_error"></span></td></tr>'
			+ '</tbody>'
		+ '<thead>'
			+ '<tr>';
				for (var col = 0; col < telListHead.length; col++) {
					if (telListHead[col] == TITLE_TEL_NUMBER) {
						indexTelNo = col;
					} else if (telListHead[col] == TITLE_FEE) {
						indexFee = col;
					} else if (telListHead[col] == TITLE_BIRTHDAY) {
						indexBirthday = col;
					} else if (telListHead[col] == TITLE_CONSENTDAY) { // #8298 add consentday
						indexConsentday = col;
					}
					str = str + '<th style="text-align:center;" class="fieldImport">'
						+ '<select id="field_' + col + '" name="listFields[' + col + ']" class="form-control input-sm sl_csv_column"><option value="">---</option>';
					for (var j = 0; j < telListHead.length; j++) {
						str = str + '<option value="' + j + '" >' + telListHead[j] + '</option>';
					}
					str = str + '</select></th>';
				}
			+ '</tr>'
		+ '</thead>'
		+ '</table>';
	var str_error = '<div class="data_csv_error_div" style="display:none;">'
		+ '<input type="text" id="check_tel_birthday_fee" name="check_tel_birthday_fee" style="display:none;"/>'
		+ '<p id="error_tel_birthday_fee"></p>'
		+ '</div>'
		+ '<div>'
		+ '<a href="javascript:void(0);" id="copyErrorBtn" data-clipboard-text=" " style="display:none;">コピー</a>' //20160224 Edit by Giang : add '0' before tel_num if first character isnot '0'
		+ '</div>';

	$('#data_csv_error_div').append(str_error);
	$('#preview_div').append(str);
	new Clipboard('#copyErrorBtn');

/*	var start = 0;
	for (i=0; i<headerKey.length; i++) {
		if (telListHead.indexOf(headerKey[i]) >= 0) {
			$('#field_' + start).val(telListHead.indexOf(headerKey[i]));
			start++;
		}
	}*/

	for (i=0; i<telListHead.length; i++) {
		if (headerKey.indexOf(telListHead[i]) >= 0) {
			$('#field_' + i).val(i);
		}
	}
}

function list_detail(ctrl) {
	var list_id = $(ctrl).attr('list_id');
	$.ajax({
		type: "POST",
		url:appRoot+"SmsSendList/check_info_list/",
		data: {
			list_ids: list_id,
		},
		async: false,
		success:function(data){
			if(data == "err_not_exist"){
				alert(MSG_ALERT_NO_EXIST_LIST);
				location.reload();
				return;
			}else{
				display_load();

				var url=appRoot+"SmsSendList/detail";
				$("#ListIndexForm").attr('action', url);
				$("#ListIndexForm").attr('method', 'post');
				$("#ListIndexForm").attr('enctype', 'multipart/form-data');

				var list_detail_input = document.createElement("input");
				list_detail_input.type = 'hidden';
				list_detail_input.name = 'edit_list_id';
				list_detail_input.value = $(ctrl).attr("list_id");
				$("#ListIndexForm").append(list_detail_input);

				$("#ListIndexForm").submit();
			}
		},
	});
}

function check_csv_data(headers, telListCount) {
	/*if (telListCount < 1) {
		alert(MSG_ALERT_NO_TEL_RECORD);
		return false;
	} else */
	if (telListCount > max_tel_param) {
		alert(MSG_ALERT_OVER_TEL_RECORD);
		return false;
	}

	if (headers.indexOf(TITLE_TEL_NUMBER) < 0) {
		alert(MSG_ALERT_HEADER_NO_TEL_NO);
		return false;
	} else if (headers.length > 11) {
		alert(MSG_ALERT_LIMIT_CSV_COLUMN);
		return false;
	} else if (headers.indexOf('') >= 0) {
		alert(MSG_ALERT_HEADER_NOT_NULL);
		return false;
	}

	var headerTmp = [];
	for (var i = 0; i < headers.length; i++) {
		if (headerTmp.indexOf(headers[i]) >= 0) {
			alert(MSG_ALERT_DUPLICATE_CSV_COLUMN);
			return false;
		}
		headerTmp[i] = headers[i];
	}

	return true;
}

function show_birthday(birthday) {
	var year = birthday.substr(0, 4);
	var month = birthday.substr(4, 2);
	var day = birthday.substr(6, 2);

	if (birthday.length == 6) {
		return year + '-' + month;
	} else if (birthday.length == 8) {
		return year + '-' + month + '-' + day;
	}
	return birthday;
}

// #8298 add consentday
function show_consentday(consentday) {
	var year = consentday.substr(0, 4);
	var month = consentday.substr(4, 2);
	var day = consentday.substr(6, 2);

	if (consentday.length == 6) {
		return year + '-' + month;
	} else if (consentday.length == 8) {
		return year + '-' + month + '-' + day;
	}
	return consentday;
}
