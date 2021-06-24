$(document).ready(function() {
	var validMaxSize = 50; // Megabytes

	init_table(enable_download_or_delete, 'InboundRestrict', 'arr_incoming_ng_list', '#incomingNgTable');

	{ /* upload file */
		$("#form_incoming_ng_list").validate({
			ignore: "",
			rules:{
				"data[T18IncomingNgList][ListName]": {
					required : true,
					remote: {
						type: 'post',
						url: appRoot + '/InboundRestrict/check_exist_listname',
						async: false,
						data: {
							list_name: function() {
								return $("#call_list_ng_name").val();
							},
						}
					}
				},
				"data[T18IncomingNgList][File]": {
					required : true,
				},
			},
			messages:{
				"data[T18IncomingNgList][ListName]": {
					required: MSG_ERROR_REQUIRED_LIST_NAME,
					remote: MSG_ERROR_EXIST_LIST_NAME
				},
				"data[T18IncomingNgList][File]": {
					required: MSG_ERROR_PLS_CHOOSE_FILE,
				},
			},
		});

		$('#btnCreate').click(function () {
			$('.alert').hide();
			$('#dialog_add_incoming_ng_list').modal('show');
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
						alert(MSG_ALERT_OVER_INBOUND_TEL_NG_RECORD);
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
			if($("#form_incoming_ng_list").valid() && confirm(MSG_CONFIRM_UPLOAD)) {
				var validator = $( "#form_incoming_ng_list" ).validate();
				validator.resetForm();
				display_load();
				$.ajax({
					type: "POST",
					url: appRoot+"InboundRestrict/upload_file/",
					data: {
						listName: $('#call_list_ng_name').val(),
						uploadData: JSON.stringify(telLists)
					},
					async: true,
					success:function(data){
						setEnabled();
						$.unblockUI();
						if (data == 'systemerror') {
							alert(MSG_ALERT_SYSTEM_ERROR);
							$('#dialog_add_incoming_ng_list').modal('hide');
							location.reload();
						}

						var results = JSON.parse(data);
						if (results['status'] == 'save') {
							$('#calllist-success-message').find('p').text(MSG_ALERT_INSERT_SUCCESS);
							$('#calllist-success-message').show();
							$('#dialog_add_incoming_ng_list').modal('hide');
							reload_table(results['page'], results['sortColumn'], results['sortType'], 'InboundRestrict', 'arr_incoming_ng_list', '#incomingNgTable');
						}
					}
				});
			}
			setEnabled(); // 20160405 Add by Giang - #6854 - disable double-click
		});

		if ($('#err_create_call_list').html() != '') {
			$('#dialog_add_incoming_ng_list').modal('show');
		}

		$(document).on('click', '#copyErrorBtn', function () {
			alert('コピーしました');
		});

		$('#dialog_add_incoming_ng_list').on('hidden.bs.modal', function (e) {
			$('.error').html('');
			$('#data_csv_error_div').html('');
			$('#form_incoming_ng_list input').each(function() {
				$(this).val('');
			});
		});
	}

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
		var url=appRoot+"InboundRestrict/buffer_csv_data";
		$.ajax({
			url: url,
			type: "post",
			data: {
				call_list_ids: call_list_ids,
			},
			success: function(result){
				if(result == "success"){
					window.location.href = appRoot+"InboundRestrict/download_csv_file";
				}else{
					alert(MSG_ALERT_SYSTEM_ERROR);
					location.reload();
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
			url:appRoot+"InboundRestrict/check_info_list/",
			data: {
				call_list_ids: call_list_ids,
			},
			async: false,
			success:function(data){
				if (data == 'systemerror') {
					alert(MSG_ALERT_SYSTEM_ERROR);
					location.reload();
				}else if (data == "err_not_exist"){
					alert(MSG_ALERT_NO_EXIST_LIST);
					location.reload();
				} else if (data == "err_used"){
					alert(MSG_ALERT_CANNOT_DEL_LIST_INCOMING_NG);
					setEnabled(); // 20160405 Add by Giang - #6854 - disable double-click
					return;
				} else {
					if(confirm(MSG_CONFIRM_DEL)){
						display_load();
						$.ajax({
							type: "POST",
							url:appRoot+"InboundRestrict/delete/",
							data: {
								call_list_ids: call_list_ids
							},
							async: false,
							success:function(data){
								setEnabled();
								$.unblockUI();
								if (data == 'systemerror') {
									alert(MSG_ALERT_SYSTEM_ERROR);
									location.reload();
								}
								$('#calllist-success-message').find('p').text(call_list_ids.length + '件' + MSG_ALERT_DEL_SUCCESS);
								$('#calllist-success-message').show();
								var results = JSON.parse(data);
								reload_table(results['page'], results['sortColumn'], results['sortType'], 'InboundRestrict', 'arr_incoming_ng_list', '#incomingNgTable');
							},
						});
					}
				}
			},
		});
		setEnabled(); // 20160405 Add by Giang - #6854 - disable double-click
	});

	$(document).on('click', '.lnkDetail', function () {
		list_detail(this);
	});

	$('#bundleCheckbox').on('click', function() {
		toggleCheckStatus($(this));
	});
});

function list_detail(ctrl) {
	var call_list_id = $(ctrl).attr('call_list_id');
	$.ajax({
		type: "POST",
		url:appRoot+"InboundRestrict/check_info_list/",
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

				var url=appRoot+"InboundRestrict/detail";
				$("#T18IncomingNgIndexForm").attr('action', url);
				$("#T18IncomingNgIndexForm").attr('method', 'post');
				$("#T18IncomingNgIndexForm").attr('enctype', 'multipart/form-data');

				var list_detail_input = document.createElement("input");
				list_detail_input.type = 'hidden';
				list_detail_input.name = 'edit_call_list_id';
				list_detail_input.value = $(ctrl).attr("call_list_id");
				$("#T18IncomingNgIndexForm").append(list_detail_input);

				$("#T18IncomingNgIndexForm").submit();
			}
		},
	});
}
