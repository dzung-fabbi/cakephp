$(document).ready(function() {

	init_table(enable_edit_call_list, 'InboundCallList', 'tel_list', '#telListTable');

	{/*update t16*/
		$("#form_update_list_info").validate({
			ignore: "",
			rules:{
				"data[T16InboundCallList][ListName]": {
					required : true,
					remote: {
						type: 'post',
						url: appRoot + '/InboundCallList/check_exist_listname',
						async: false,
						data: {
							list_name: function() {
								return $('input[name="data[T16InboundCallList][ListName]"]').val();
							},
							list_name_old: list_name_old,
						}
					}
				},
				// 20160404 Add by Giang - #6740: check item main unique - Begin
				"item_main": {
					remote: {
						type: 'post',
						url: appRoot + '/InboundCallList/check_item_main_valid',
						async: false,
						data: {
							item_main: function() {
								return $('#item_main').val();
							},
						}
					}
				},
				// 20160404 Add by Giang - #6740: check item main unique - End
			},
			messages:{
				"data[T16InboundCallList][ListName]": {
					required: MSG_ERROR_REQUIRED_LIST_NAME,
					remote: MSG_ERROR_EXIST_LIST_NAME
				},
				// 20160404 Add by Giang - #6740: check item main unique - Begin
				"item_main": {
					remote: INBOUND_DETAIL_ITEM_MAIN_INVALID
				},
				// 20160404 Add by Giang - #6740: check item main unique - End
			},
		});

		$('#btnSaveTelList').click(function() {
			setDisabled(); // 20160405 Add by Giang - #6854 - disable double-click
			$('.alert').hide();
			if($("#form_update_list_info").valid() && confirm(MSG_CONFIRM_UPDATE)) {
				var item_main_id = "#" + item_column;
				display_load();
				$.ajax({
					type: "POST",
					url: appRoot+"InboundCallList/update_tel_list_name/",
					data: {
						listName: $('#call_list_name').val(),
						listTestFlag: $('#list_test_flag').is(':checked'),
						callListId: $('#call_list_id').val(),
						item_main: $('#item_main').val(),
					},
					success:function(data){
						setEnabled();
						$.unblockUI();
						if (data == 'systemerror') {
							alert(MSG_ALERT_SYSTEM_ERROR);
							window.location.href=appRoot+"InboundCallList/index";
						} else if (data == "err_not_exist") {
							alert(MSG_ALERT_NO_EXIST_LIST);
							window.location.href=appRoot+"InboundCallList/index";
						} else {
							var results = JSON.parse(data);
							$('#cl-detail-success-message').find('p').text(MSG_ALERT_UPDATE_SUCCESS);
							$('#cl-detail-success-message').show();
							$(item_main_id).rules('remove', 'required');
							item_main = $('#item_main').val();
							item_column = results['item_column'];
						}
					},
				});
			}
			setEnabled(); // 20160405 Add by Giang - #6854 - disable double-click
		});
	}

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

		$.ajax({
			type: "POST",
			url: appRoot + "InboundCallList/check_info_tel/",
			data: {
				tel_list_ids: tel_list_ids,
			},
			async: false,
			success:function(data){
				if (data == "err_list_not_exist") {
					alert(MSG_ALERT_NO_EXIST_LIST);
					location.reload();
				} else if (data == 'systemerror') {
					alert(MSG_ALERT_SYSTEM_ERROR);
					location.reload();
				} else if (data == "err_used") {
					alert(INBOUND_CANNOT_DEL_LIST);
					location.reload();
				} else if (data == "err_tel_not_exist") {
					alert(MSG_ALERT_NO_EXIST_TEL);
					location.reload();
				} else {
					if (confirm(MSG_CONFIRM_DEL)) {
						display_load();
						$.ajax({
							type: "POST",
							url: appRoot + "InboundCallList/delete_tel/",
							data: {
								tel_list_ids: tel_list_ids
							},
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
								reload_table(results['page'], results['sortColumn'], results['sortType'], 'InboundCallList', 'tel_list', '#telListTable');
							},
						});
					}
				}
			},
		});
		setEnabled(); // 20160405 Add by Giang - #6854 - disable double-click
	});

	{/*update muko*/
		// 20160530 Edit by Giang - Comment out muko - Begin
		/*var inefficient_tel_list_ids = {};
		$('#telListTable').bind('pagerChange', function(){
			inefficient_tel_list_ids = {};
		});

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
				url:appRoot+"InboundCallList/check_info_tel/",
				data: {
					tel_list_ids: tel_list_ids,
				},
				async: false,
				success:function(data){
					if(data == "err_list_not_exist") {
						alert(MSG_ALERT_NO_EXIST_LIST);
						location.reload();
					} else if (data == 'systemerror') {
						alert(MSG_ALERT_SYSTEM_ERROR);
						location.reload();
					} else if (data == "err_tel_not_exist") {
						alert(MSG_ALERT_NO_EXIST_TEL);
						location.reload();
					} else {
						if (confirm(MSG_CONFIRM_UPDATE)) {
							display_load();
							$.ajax({
								type: "POST",
								url:appRoot+"InboundCallList/inefficient_tel/",
								data: {
									tel_list_ids: inefficient_tel_list_ids,
									list_id: $('#call_list_id').val(),
								},
								success:function(data){
									setEnabled();
									$.unblockUI();
									var data = JSON.parse(data);
									if (data.hasOwnProperty('status') && data.status == 'update_muko') {
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
		});*/
	// 20160530 Edit by Giang - Comment out muko - End
	}

	{/*edit t17*/
		$("#form_add_edit_tel").validate({
			ignore: "",
			rules:{
				/*20160425 Delete by Giang - #6740 - Remove valid tel_no - Begin*/
				'tel_number': {
					required : true,
					checkTel: true,
					remote: {
						type: 'post',
						url: appRoot + '/InboundCallList/check_exist_tel_no',
						async: false,
						data: {
							tel_list_id: function() {
								return $('#form_add_edit_tel input[name="id"]').val();
							},
							tel_number_col: indexTelNo,
						}
					}
				},
				/*20160425 Delete by Giang - #6740 - Remove valid tel_no - End*/
				'fee': {
					number: true,
				},
				'birthday_date': {
					date: true,
				},
			},
			/*20160425 Delete by Giang - #6740 - Remove valid tel_no - Begin*/
			messages: {
				'tel_number': {
					checkTel: MSG_ERROR_CHECK_TEL,
					remote: MSG_ERROR_EXIST_TEL_NO,
				},
			},
			/*20160425 Delete by Giang - #6740 - Remove valid tel_no - End*/
		});

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

		$('#btn_add_edit_tel').click(function() {
			setDisabled(); // 20160405 Add by Giang - #6854 - disable double-click
			$('.alert').hide();
			if ($('select[name="birthdayYear"]').val() || $('select[name="birthdayMonth"]').val() || $('select[name="birthdayDay"]').val()) {
				var birthday_date = $('select[name="birthdayYear"]').val() + '-' + $('select[name="birthdayMonth"]').val() + '-' + $('select[name="birthdayDay"]').val();
				$('.birthday_date').val(birthday_date);
			} else {
				$('.birthday_date').val('');
			}

			var item_main_id = "#" + item_column;
			var action = 'add';
			var t17_tel_id = '';
			if ($('#id').val()) {
				action = 'edit';
				t17_tel_id = $('#id').val(); // 20160406 Edit by Giang - #6740: check item main unique - End
			}

			$(item_main_id).rules('add', {
				required: true,
				// 20160404 Add by Giang - #6740: check item main unique - Begin
				remote: {
					type: 'post',
					url: appRoot + '/InboundCallList/check_insert_update_item_main',
					async: false,
					data: {
						t17_tel_id: function() { // 20160406 Edit by Giang - #6740: check item main unique - End
							return t17_tel_id;
						}
					}
				},
				messages: {
					remote: INBOUND_DETAIL_ITEM_MAIN_INVALID,
				}
				// 20160404 Add by Giang - #6740: check item main unique - End
			});

			if($('#form_add_edit_tel').valid()) {
				var validator = $( "#form_add_edit_tel" ).validate();
				validator.resetForm();
				$(item_main_id).rules('remove', 'required');


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
					/*20160425 Delete by Giang - #6740 - Remove valid tel_no*/
					/*if ($(this).attr('id') == indexTelNo) {
						data_tel[$(this).attr('id')] = $(this).val().replace(/\D/g, "");
					} else {*/
						data_tel[$(this).attr('id')] = $(this).val();
					// }
				});

				$.ajax({
					type: "POST",
					url: appRoot + "InboundCallList/check_info_tel/",
					data: {
						tel_list_ids: $('#id').val(),
						action: action,
					},
					async: false,
					success:function(data){
						if(data == "err_list_not_exist"){
							alert(MSG_ALERT_NO_EXIST_LIST);
							location.reload();
						}else if (data == 'systemerror') {
							alert(MSG_ALERT_SYSTEM_ERROR);
							location.reload();
						}else if(data == "err_used"){
							alert(INBOUND_CANNOT_DEL_LIST);
							location.reload();
						}else if(data == "err_tel_not_exist"){
							alert(MSG_ALERT_NO_EXIST_TEL);
							location.reload();
						}else if(data == "err_limit_max_tel"){
							$('#cl-detail-error-message').find('p').text(MSG_ALERT_LIMIMT_MAX_TEL_INBOUND_CALL_LIST);
							$('#cl-detail-error-message').show();
							$('#dialog_add_tel_list').modal('hide');
							setEnabled(); // 20160405 Add by Giang - #6854 - disable double-click
							return;
						}else{

							if(confirm(MSG_CONFIRM_CONTINUE)) {
								display_load();
								$.ajax({
									type: "POST",
									url: appRoot + "InboundCallList/add_and_edit_tel/",
									data: {
										data_tel: data_tel,
									},
									success:function(data){
										$.unblockUI();
										if (data == 'systemerror') {
											alert(MSG_ALERT_SYSTEM_ERROR);
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
										reload_table(results['page'], results['sortColumn'], results['sortType'], 'InboundCallList', 'tel_list', '#telListTable');
										$('#dialog_add_tel_list').modal('hide');
									},
								});
							}
						}
					},
				});
			}
			$(item_main_id).rules('remove'); // 20160406 Add by Giang - #6740: check item main unique - End
			setEnabled(); // 20160405 Add by Giang - #6854 - disable double-click
		});

		$('#dialog_add_tel_list').on('hidden.bs.modal', function (e) {
			$('#dialog_add_tel_list .error').html(''); // 20160406 Edit by Giang - #6740: check item main unique - End
			$("#dialog_add_tel_list input").each(function() {
				$(this).val('');
				$(this).removeClass('error');
			});
			$('#dialog_add_tel_list select').val('');
		});
	}

	$(document).on('click', '.label_select_item', function () {
		var input_name = $(this).attr('for');
		$('input[name="' + input_name + '"]').checked = true;
	});

	$('#bundleCheckbox').on('click', function() {
		toggleCheckStatus($(this));
	});
});
