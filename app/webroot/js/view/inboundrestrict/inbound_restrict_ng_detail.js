$(document).ready(function() {
	var validMaxSize = 50; // Megabytes
	var limitTelNgAdd = 100; // limit record added

	init_table(enable_delete, 'InboundRestrict', 'tel_list_ng', '#telIncomingNgTable');

	{ /*update t18_incoming_ng_lists*/
		$("#form_update_call_list_ng").validate({
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
								return $('input[name="data[T18IncomingNgList][ListName]"]').val();
							},
							list_name_old: list_name_old,
						}
					}
				},
			},
			messages:{
				"data[T18IncomingNgList][ListName]": {
					required: MSG_ERROR_REQUIRED_LIST_NAME,
					remote: MSG_ERROR_EXIST_LIST_NAME
				},
			},
		});

		$('#btnUpdate').click(function() {
			setDisabled(); // 20160405 Add by Giang - #6854 - disable double-click
			$('.alert').hide();

			if($("#form_update_call_list_ng").valid() && confirm(MSG_CONFIRM_UPDATE)) {
				display_load();
				$.ajax({
					type: "POST",
					url: appRoot+"InboundRestrict/update_incoming_ng_list/",
					data: {
						listName: $('#call_list_name').val(),
						callListId: $('#call_list_id').val(),
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
							window.location.href=appRoot+"InboundRestrict/index";
						}
					},
				});
			}
			setEnabled(); // 20160405 Add by Giang - #6854 - disable double-click
		});
	}

	{ /*add text*/
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

		$(document).on('keyup', '#tel_lists', function () {
			$('.alert').hide();
			$('#textbox_error_add_tel_ng').html('');
		});

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
						url:appRoot+"InboundRestrict/check_info_tel/",
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
								return;
							} else if ((result['status'] == 'tel_total_over') || (result['status'] == 'err_used')) {
								show_error(result['err_msg']);
								setEnabled(); // 20160405 Add by Giang - #6854 - disable double-click
								return;
							} else {
								if (confirm(MSG_CONFIRM_CONTINUE)) {
									display_load();
									$.ajax({
										type: "POST",
										url: appRoot+"InboundRestrict/add_file/",
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
												return;
											}

											var results = JSON.parse(data);
											if (results['status'] == 'save') {
												$('#cl-detail-success-message').find('p').text(MSG_ALERT_INSERT_SUCCESS);
												$('#cl-detail-success-message').show();
												$('#tel_lists').val('');
												reload_table(results['page'], results['sortColumn'], results['sortType'], 'InboundRestrict', 'tel_list_ng', '#telIncomingNgTable');
											}
										}
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
	}

	{ /*add file*/
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

			return false;
		});

		$('#btnSave').click(function() {
			setDisabled(); // 20160405 Add by Giang - #6854 - disable double-click
			if($("#form_add_file").valid()) {
				var validator = $( "#form_add_file" ).validate();
				validator.resetForm();
				$.ajax({
					type: "POST",
					url: appRoot+"InboundRestrict/check_info_tel/",
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
							return;
						} else if ((result['status'] == 'tel_total_over') || (result['status'] == 'err_used')) {
							show_error(result['err_msg']);
							setEnabled(); // 20160405 Add by Giang - #6854 - disable double-click
							return;
						} else {
							display_load();
							$.ajax({
								type: "POST",
								url: appRoot+"InboundRestrict/add_file/",
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
										return;
									}

									var results = JSON.parse(data);
									if (results['status'] == 'save') {
										$('#cl-detail-success-message').find('p').text(MSG_ALERT_INSERT_SUCCESS);
										$('#cl-detail-success-message').show();
										$('#dialog_add_file').modal('hide');
										reload_table(results['page'], results['sortColumn'], results['sortType'], 'InboundRestrict', 'tel_list_ng', '#telIncomingNgTable');
									}
								},
							});
						}
					},
				});
			}
			setEnabled(); // 20160405 Add by Giang - #6854 - disable double-click
		});
	}

	$(document).on('click', '#btnDelete', function () {
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
		display_load();
		$.ajax({
			type: "POST",
			url:appRoot+"InboundRestrict/check_info_tel/",
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
					return;
				}else if(data == "err_tel_not_exist"){
					alert(MSG_ALERT_NO_EXIST_TEL);
					location.reload();
					return;
				}else{
					if (confirm(MSG_CONFIRM_DEL)) {
						display_load();
						$.ajax({
							type: "POST",
							url:appRoot+"InboundRestrict/delete_tel/",
							data: {
								tel_list_ids: tel_list_ids,
								call_list_id: call_list_id,
								tel_total: tel_total,
							},
							async: true,
							success:function(data){
								setEnabled();
								$.unblockUI();
								if (data == 'systemerror') {
									alert(MSG_ALERT_SYSTEM_ERROR);
									location.reload();
									return;
								}
								$('#cl-detail-success-message').find('p').text(tel_list_ids.length + '件' + MSG_ALERT_DEL_SUCCESS);
								$('#cl-detail-success-message').show();
								var results = JSON.parse(data);
								reload_table(results['page'], results['sortColumn'], results['sortType'], 'InboundRestrict', 'tel_list_ng', '#telIncomingNgTable');
							},
						});
					}
				}
			},
		});
		setEnabled(); // 20160405 Add by Giang - #6854 - disable double-click
	});

	$(document).on('click', '#copyErrorBtn', function () {
		alert('コピーしました');
	});

	$('#bundleCheckbox').on('click', function() {
		toggleCheckStatus($(this));
	});
});