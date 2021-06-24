$(document).ready(function() {
	var validMaxSize = 50; // Megabytes
	var limitTelNgAdd = 100; // limit record added

	$("#form_update_call_list_ng").validate({
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
							return $('input[name="data[T14OutgoingNgList][ListName]"]').val();
						},
						list_name_old: list_name_old,
					}
				}
			},
		},
		messages:{
			"data[T14OutgoingNgList][ListName]": {
				required: MSG_ERROR_REQUIRED_LIST_NAME,
				remote: MSG_ERROR_EXIST_LIST_NAME
			},
		},
	});

	$("#form_add_file").validate({
		ignore: "",
		rules:{
			'txt-restriction': {
				required : true,
			},
		},
		messages:{
			"txt-restriction": {
				required: MSG_ERROR_REQUIRED_FILE,
			},
		},
	});

	$("#form_add_tel_ng_list").validate({
		ignore: "",
		rules:{
			"tel_lists": {
				required : true,
				maxline: 100
			},
		},
		messages:{
			"tel_lists": {
				maxline: MSG_ERROR_LIMIT_100LINE,
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
		if (enable_delete) { /* 20160311 Edit by Giang : #6538 - refactor code */
			column = [[1, 1]];
		} else {
			column = [[0, 1]];
		}
	}

	$("#telListNgTable").tablesorter({
		theme: 'gold',
		widthFixed: true,
		sortLocaleCompare: true,
		sortList: column,
		widgets: ['zebra', 'filter'],
	}).tablesorterPager({
		container: $(".pager"),
		type: "POST",
		ajaxUrl: appRoot + "CallListNg/tel_list_ng/{page}/20/{sortList:column}?{filterList:filter}",
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

	$('#dialog_add_file').on('hidden.bs.modal', function (e) {
		$('.error').html('');
		$("#dialog_add_file input").each(function() {
			$(this).val('');
			$(this).removeClass('error');
		});
		$('#data_csv_error_div').html('');
	})

	$('#btnAddFile').click(function() {
		$('#textbox_error_add_tel_ng').html('');
		$('.alert').hide();
		$('#dialog_add_file').modal('show');
	});

	$('#btnUpdate').click(function() {
		setDisabled(); // 20160405 Add by Giang - #6854 - disable double-click
		$('.alert').hide();

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

		if($("#form_update_call_list_ng").valid() && confirm(MSG_CONFIRM_UPDATE)) {
			display_load();
			$.ajax({
				type: "POST",
				url: appRoot+"CallListNg/update_call_list_ng/",
				data: {
					listName: $('#call_list_name').val(),
					callListId: $('#call_list_id').val(),
					expired_date_from: $('#expired_date_from').val(),
					expired_date_to: $('#expired_date_to').val(),
				},
				async: true,
				success:function(data){
					setEnabled();
					$.unblockUI();
					if (data == 'save') {
						$('#cl-detail-success-message').find('p').text(MSG_ALERT_UPDATE_SUCCESS);
						$('#cl-detail-success-message').show();
					} else if (data == 'systemerror') {
						alert(MSG_ALERT_SYSTEM_ERROR);
						window.location.href=appRoot+"CallListNg/index";
					}
				},
			});
		}
		setEnabled(); // 20160405 Add by Giang - #6854 - disable double-click
	});

	$(document).on('click', '#btnDelete', function () {
		setDisabled(); // 20160405 Add by Giang - #6854 - disable double-click
		$('.alert').hide();
		var cbSelects = $(".select_item:checked"); // 20160331 Edit by Giang - update tel_total schedule
		var tel_list_ids = [];
		var tel_num_list = []; // 20160331 Add by Giang - update tel_total schedule
		$.each(cbSelects, function(i, cbSelect) {
			tel_list_ids[i] = $(this).val();
			tel_num_list[i] = $(this).attr('tel_num'); // 20160331 Add by Giang - update tel_total schedule
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
			url:appRoot+"CallListNg/check_info_tel/",
			data: {
				tel_list_ids: tel_list_ids,
			},
			async: false,
			success:function(data){
				var result = JSON.parse(data);
				var data = result['status'];
				if(data == "err_list_not_exist"){
					alert(MSG_ALERT_NO_EXIST_LISTNG);
					location.reload();
				}else if(data == "err_calling"){
					alert(MSG_ALERT_CANNOT_DEL_LISTNG);
					location.reload();
				}else if(data == "err_tel_not_exist"){
					alert(MSG_ALERT_NO_EXIST_TEL);
					location.reload();
				}else{
					if (confirm(MSG_CONFIRM_DEL)) {
						display_load();
						$.ajax({
							type: "POST",
							url:appRoot+"CallListNg/delete_tel/",
							data: {
								tel_list_ids: tel_list_ids,
								call_list_id: call_list_id,
								tel_total: tel_total,
								tel_num_list: tel_num_list, // 20160331 Add by Giang - update tel_total schedule
							},
							async: false,
							success:function(data){
								setEnabled();
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

	$("#btnUpload, #txt-restriction").click(function() {
		$('#file_to_upload').val('');
		$('#file_to_upload').click();
	});

	$('#file_to_upload').change(function(e) {
		var filename = $('#file_to_upload').val().replace(/C:\\fakepath\\/i, '');
		if (filename) {
			var ext = filename.substr(filename.lastIndexOf('.') +1);
			var type = filename.substr(filename.lastIndexOf('.') +1);
			var validExt = ['csv', 'txt'];
			var validType = ['text/plain', 'application/vnd.ms-excel'];

			$('#txt-restriction').val(filename);
			$('#err_file_upload').html('');
			$('#data_csv_error_div').html('');
			telLists = [];

			if (e.target.files && $.inArray(ext, validExt) != -1 && $.inArray(e.target.files[0].type, validType) != -1) { /* 20160311 Edit by Giang : #6538 - refactor code */
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
					} else if (telListCount > limitTelNgAdd) {
						alert(MSG_ALERT_OVER_100TEL_RECORD);
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
		}
	});

	$('#btnSave').click(function() {
		setDisabled(); // 20160405 Add by Giang - #6854 - disable double-click
		if($("#form_add_file").valid()) {
			var validator = $( "#form_add_file" ).validate();
			validator.resetForm();
			$.ajax({
				type: "POST",
				url: appRoot+"CallListNg/check_info_tel/",
				data: {
					uploadData: JSON.stringify(telLists),
					action: 'add'
				},
				async: false,
				success: function(data) {
					var result = JSON.parse(data);
					if (result['status'] == 'err_list_not_exist') {
						alert(MSG_ALERT_NO_EXIST_LIST);
						location.reload();
					} else if ((result['status'] == 'tel_total_over') || (result['status'] == 'err_used')) {
						show_error(result['err_msg']);
						setEnabled(); // 20160405 Add by Giang - #6854 - disable double-click
						return;
					} else {
						display_load();
						$.ajax({
							type: "POST",
							url: appRoot+"CallListNg/add_file/",
							data: {
								uploadData: JSON.stringify(telLists)
							},
							async: true,
							success:function(data){
								setEnabled();
								$.unblockUI();
								if (data == 'systemerror') {
									alert(MSG_ALERT_SYSTEM_ERROR);
									$('#dialog_add_file').modal('hide');
									location.reload();
								}

								var results = JSON.parse(data);
								if (results['status'] == 'save') {
									$('#cl-detail-success-message').find('p').text(MSG_ALERT_INSERT_SUCCESS);
									$('#cl-detail-success-message').show();
									$('#dialog_add_file').modal('hide');
									reload_table_tel_list(results['page'], results['sortColumn'], results['sortType']);
								} else if (results['status'] == 'err_mega_prohibit') {
									alert("エラーを発生しました。");
								}
							},
						});
					}
				},
			});
		}
		setEnabled(); // 20160405 Add by Giang - #6854 - disable double-click
	});

	/* 20160311 Add by Giang : #6538 - refactor code - start */
	$(document).on('keyup', '#tel_lists', function () {
		$('.alert').hide();
		$('#textbox_error_add_tel_ng').html('');
	});
	/* 20160311 Add by Giang : #6538 - refactor code - end */

	$('#btnAddText').click(function() {
		setDisabled(); // 20160405 Add by Giang - #6854 - disable double-click
		if ($("#form_add_tel_ng_list").valid()) {
			telLists = [];
			var tel_lists = $('#tel_lists').val();
			var csvVal = tel_lists.split("\n");
			for (var i=0; i < csvVal.length; i++) {
				if (csvVal[i].length > 0 && csvVal[i] != '\r' && csvVal[i] != '') {
					telLists[i] = csvVal[i].split(',');
				}
			}

			if (telLists.length > limitTelNgAdd) {
				alert(MSG_ALERT_OVER_100TEL_RECORD);
				setEnabled(); // 20160405 Add by Giang - #6854 - disable double-click
				return false;
			}

			append_error_div('#textbox_error_add_tel_ng');
			$("#check_tel").rules('add', {
				checkTel: telLists,
				messages: {
					checkTel: '',
				}
			});

			if ($("#check_tel").valid()) {

				$.ajax({
					type: "POST",
					url:appRoot+"CallListNg/check_info_tel/",
					data: {
						uploadData: JSON.stringify(telLists),
						action: 'add'
					},
					async: false,
					success: function(data) {
						var result = JSON.parse(data);
						if (result['status'] == 'err_list_not_exist') {
							alert(MSG_ALERT_NO_EXIST_LIST);
							location.reload();
						} else if ((result['status'] == 'tel_total_over') || (result['status'] == 'err_used')) {
							show_error(result['err_msg']);
							setEnabled(); // 20160405 Add by Giang - #6854 - disable double-click
							return;
						} else {
							if (confirm(MSG_CONFIRM_CONTINUE)) {
								display_load();
								$.ajax({
									type: "POST",
									url: appRoot+"CallListNg/add_file/",
									data: {
										uploadData: JSON.stringify(telLists)
									},
									async: true,
									success:function(data){
										setEnabled();
										$.unblockUI();
										if (data == 'systemerror') {
											alert(MSG_ALERT_SYSTEM_ERROR);
											$('#dialog_add_file').modal('hide');
											location.reload();
										}

										var results = JSON.parse(data);
										if (results['status'] == 'save') {
											$('#cl-detail-success-message').find('p').text(MSG_ALERT_INSERT_SUCCESS);
											$('#cl-detail-success-message').show();
											$('#tel_lists').val('');
											reload_table_tel_list(results['page'], results['sortColumn'], results['sortType']);
										} else if (results['status'] == 'err_mega_prohibit') {
											alert("エラーを発生しました。");
										}
									},
								});
							}
						}
					},
				});
			}
			$("#check_tel").rules('remove');
			var validator = $( "#form_add_tel_ng_list" ).validate();
			validator.resetForm();
		}
		setEnabled(); // 20160405 Add by Giang - #6854 - disable double-click
	});

	init_datepicker($("#expired_date_from").val(), $("#expired_date_to").val());

	$(document).on('click', '#copyErrorBtn', function () {
		alert('コピーしました');
	});

	$('#bundleCheckbox').on('click', function() {
		toggleCheckStatus($(this));
	});
});

function reload_table_tel_list(page, sortColumn, sortType) {

	var url = appRoot + "CallListNg/tel_list_ng/" + page + "/20/column?filter";
	if (sortColumn != null && sortType != null) {
		url = appRoot + "CallListNg/tel_list_ng/" + page + "/20/column[" + sortColumn + "]=" + sortType + "?filter";
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
				$("#telListNgTable").trigger("renderAjax", json_data);
				$("#telListNgTable").trigger("update");
				$('#telListNgTable').trigger('pagerUpdate');
			}
		}
	});
}
