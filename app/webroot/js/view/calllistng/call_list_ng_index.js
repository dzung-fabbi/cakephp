$(document).ready(function() {
	var validMaxSize = 50; // Megabytes

	$("#form_add_call_list_ng").validate({
		ignore: "",
		rules:{
			"data[T14OutgoingNgList][ListName]": {
				required : true,
				remote: {
					type: 'post',
					url: appRoot + '/CallListNg/check_exist_listname',
					async: false,
					data: {
						list_name: function() {
							return $("#call_list_ng_name").val();
						},
					}
				}
			},
			"data[T14OutgoingNgList][File]": {
				required : true,
			},
			"data[T14OutgoingNgList][expired_date_from]": {
				date: true,
			},
			"data[T14OutgoingNgList][expired_date_to]": {
				date: true,
			},
		},
		messages:{
			"data[T14OutgoingNgList][ListName]": {
				required: MSG_ERROR_REQUIRED_LIST_NAME,
				remote: MSG_ERROR_EXIST_LIST_NAME
			},
			"data[T14OutgoingNgList][File]": {
				required: MSG_ERROR_PLS_CHOOSE_FILE,
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
		if (enable_download_or_delete) {
			column = [[1, 1]];
		} else {
			column = [[0, 1]];
		}
	}
	$("#callListNgTable").tablesorter({
		theme: 'gold',
		widthFixed: true,
		sortLocaleCompare: true,
		sortList: column,
		widgets: ['zebra', 'filter'],
	}).tablesorterPager({
		container: $(".pager"),
		type: "POST",
		ajaxUrl: appRoot + "CallListNg/arr_ng_list/{page}/20/{sortList:column}?{filterList:filter}",
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

	$('#dialog_add_call_list_ng').on('hidden.bs.modal', function (e) {
		$('.error').html('');
		$('#data_csv_error_div').html('');
		$('#form_add_call_list_ng input').each(function() {
			$(this).val('');
		});
		$('#expired_error').html('');
	})

	$('#btnCreate').click(function () {
		$('.alert').hide();
		$('#dialog_add_call_list_ng').modal('show');
	});

	$('#btnCancel').click(function () {
		$('#dialog_add_call_list_ng').modal('hide');
	});

	$(document).on('click', '#btnDownload', function () {
		setDisabled(); // 20160405 Add by Giang - #6854 - disable double-click
		$('.alert').hide();
		var cbSelects = $(":checkbox").serializeArray();
		var call_list_ids = [];
		$.each(cbSelects, function(i, cbSelect) {
			call_list_ids[i] = cbSelect.value;
		});

		if (call_list_ids.length < 1) {
			$('#calllist-error-message').find('p').text(MSG_ALERT_PLS_CHOOSE_LIST);
			$('#calllist-error-message').show();
			setEnabled(); // 20160405 Add by Giang - #6854 - disable double-click
			return false;
		}

		$.blockUI({
			message: "<img src=\""+appRoot+"img/loading_green.gif\" />"
		});
		var url=appRoot+"CallListNg/buffer_csv_data";
		$.ajax({
			url: url,
			type: "post",
			data: {
				call_list_ids: call_list_ids,
			},
			success: function(result){
				if(result == "success"){
					window.location.href = appRoot+"CallListNg/download_csv_file";
				}else{
					window.location.href = appRoot+"CallListNg/index";
				}
				$(":checkbox").prop('checked', false);
				setEnabled();
				$.unblockUI();
			}
		});
		setEnabled(); // 20160405 Add by Giang - #6854 - disable double-click
	});

	$(document).on('click', '#btnDelete', function () {
		setDisabled(); // 20160405 Add by Giang - #6854 - disable double-click
		$('.alert').hide();
		var cbSelects = $(":checkbox").serializeArray();
		var call_list_ids = [];
		$.each(cbSelects, function(i, cbSelect) {
			call_list_ids[i] = cbSelect.value;
		});

		if (call_list_ids.length < 1) {
			$('#calllist-error-message').find('p').text(MSG_ALERT_PLS_CHOOSE_LIST);
			$('#calllist-error-message').show();
			setEnabled(); // 20160405 Add by Giang - #6854 - disable double-click
			return false;
		}

		$.ajax({
			type: "POST",
			url:appRoot+"CallListNg/check_info_list/",
			data: {
				call_list_ids: call_list_ids,
			},
			async: false,
			success:function(data){
				if (data == "err_not_exist"){
					alert(MSG_ALERT_NO_EXIST_LIST);
					location.reload();
				} else if (data == "err_used"){
					alert(MSG_ALERT_CANNOT_DEL_LISTNG);
				} else {
					if(confirm(MSG_CONFIRM_DEL)){
						display_load();

						var url=appRoot+"CallListNg/delete";
						$("#T14CallListNgIndexForm").attr('action', url);
						$("#T14CallListNgIndexForm").attr('method', 'post');
						$("#T14CallListNgIndexForm").attr('enctype', 'multipart/form-data');

						$("#T14CallListNgIndexForm").submit();
					}
				}
			},
		});
		setEnabled(); // 20160405 Add by Giang - #6854 - disable double-click
	});


	$("#btnUpload, #txt-restriction").click(function() {
		$('#file_to_upload').val('');
		$('#file_to_upload').click();
	});

	$('#file_to_upload').change(function(e) {
		var filename = $('#file_to_upload').val().replace(/C:\\fakepath\\/i, '');
		var ext = filename.substr(filename.lastIndexOf('.') +1);
		var type = filename.substr(filename.lastIndexOf('.') +1);
		var validExt = ['csv', 'txt'];
		var validType = ['text/plain', 'application/vnd.ms-excel'];

		$('#txt-restriction').val(filename);
		$('#err_file_upload').html('');
		$('#data_csv_error_div').html('');
		telLists = [];

		if (e.target.files && $.inArray(ext, validExt) != -1 && $.inArray(e.target.files[0].type, validType) != -1) {
			if (!$(this).valid()) {
				return false;
			}

			if (e.target.files[0].size >= (validMaxSize * 1024 * 1024)) {
				alert('ファイルサイズが' + validMaxSize + 'MBを超えています。');
				$('#file_to_upload').val('');
				$('#txt-restriction').val('');
				return false;
			}

			var reader = new FileReader();
			reader.onload = function(e) {
				var csvVal = e.target.result.split("\n");

				for (var i=0; i< csvVal.length; i++) {
					if (csvVal[i].length > 0 && csvVal[i] != '\r' && csvVal[i] != '') {
						var csvValue = csvVal[i].replace(/["' 　\r]/g,'').split(',');
						telLists[i] = csvValue;
					}
				}

				var telListCount = telLists.length;
				if (telListCount < 1) {
					alert(MSG_ALERT_NO_TEL_RECORD);
					$('#file_to_upload').val('');
					$('#txt-restriction').val('');
					return false;
				} else 	if (telListCount > max_tel_param) {
					alert(MSG_ALERT_OVER_TEL_NG_RECORD);
					$('#file_to_upload').val('');
					$('#txt-restriction').val('');
					return false;
				}
				append_error_div('#data_csv_error_div');
				$("#check_tel").rules('add', {
					checkTel: telLists,
					messages: {
						checkTel: '',
					}
				});
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


	$('#btnSave').click(function() {
		setDisabled(); // 20160405 Add by Giang - #6854 - disable double-click
		var error_expired = show_msg_error_expired();
		$(document).on('change', '.expired', function () {
			error_expired = show_msg_error_expired();
		});
		$(document).on('click', '.ui-datepicker-close', function () {
			error_expired = show_msg_error_expired();
		});
		if (!error_expired) {
			setEnabled(); // 20160405 Add by Giang - #6854 - disable double-click
			return;
		}
		if($("#form_add_call_list_ng").valid() && confirm(MSG_CONFIRM_UPLOAD)) {
			var validator = $( "#form_add_call_list_ng" ).validate();
			validator.resetForm();
			display_load();
			$.ajax({
				type: "POST",
				url: appRoot+"CallListNg/upload_file/",
				data: {
					listName: $('#call_list_ng_name').val(),
					uploadData: JSON.stringify(telLists),
					expiredDateFrom: $('#expired_date_from').val(),
					expiredDateTo: $('#expired_date_to').val()
				},
				async: true,
				success:function(data){
					if (data == 'save') {
						window.location.href=appRoot+"CallListNg/index/save";
					} else if (data == 'systemerror') {
						window.location.href=appRoot+"CallListNg/index/systemerror";
					}
				},
			});
		}
		setEnabled(); // 20160405 Add by Giang - #6854 - disable double-click
	});

	if ($('#err_create_call_list').html() != '') {
		$('#dialog_add_call_list_ng').modal('show');
	}

	$(document).on('click', '.lnkDetail', function () {
		list_detail(this);
	})

	$(document).on('click', '#copyErrorBtn', function () {
		alert('コピーしました');
	});

	init_datepicker();

	$('#bundleCheckbox').on('click', function() {
		toggleCheckStatus($(this));
	});
});

function list_detail(ctrl) {
	var call_list_id = $(ctrl).attr('call_list_id');
	$.ajax({
		type: "POST",
		url:appRoot+"CallListNg/check_info_list/",
		data: {
			call_list_ids: call_list_id,
		},
		async: false,
		success:function(data){
			if(data == "err_not_exist"){
				alert(MSG_ALERT_NO_EXIST_LIST);
				location.reload();
				return;
			}else{
				display_load();

				var url=appRoot+"CallListNg/detail";
				$("#T14CallListNgIndexForm").attr('action', url);
				$("#T14CallListNgIndexForm").attr('method', 'post');
				$("#T14CallListNgIndexForm").attr('enctype', 'multipart/form-data');

				var list_detail_input = document.createElement("input");
				list_detail_input.type = 'hidden';
				list_detail_input.name = 'edit_call_list_id';
				list_detail_input.value = $(ctrl).attr("call_list_id");
				$("#T14CallListNgIndexForm").append(list_detail_input);

				$("#T14CallListNgIndexForm").submit();
			}
		},
	});
}
