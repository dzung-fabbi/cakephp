const POST_CODE_U10 = 'U10';
const POST_CODE_U20 = 'U20';
const POST_CODE_U25 = 'U25';
const POST_CODE_U30 = 'U30';
const POST_CODE_G10 = 'G10';
const POST_CODE_G20 = 'G20';
const POST_CODE_G30 = 'G30';

$(document).ready(function() {
	$("#form_add_and_edit_user").validate({
		ignore: "",
		rules:{
			'company_id': {
				required : true,
			},
			'user_id': {
				required : true,
				remote: {
					type: 'post',
					url: appRoot + 'ManageUser/check_duplicate_user_id',
					async: false,
					data: {
						user_id: function() {
							return $('#form_add_and_edit_user input[name="user_id"]').val();
						},
						id: function() {
							return $('#form_add_and_edit_user input[name="id"]').val();
						}
					}
				}
			},
			'user_pass_confirm': {
				equalTo: '#user_pass'
			},
			'post_code': {
				required: true,
			},
		},
		messages: {
			'company_id': {
				required: MSG_ERROR_REQUIRED_COMPANY
			},
			'user_id': {
				required: MSG_ERROR_REQUIRED_USER,
				remote: MSG_ERROR_DUPLICATE_USER
			},
			'user_pass_confirm': {
				equalTo: MSG_ERROR_NOT_MATCH_PASS
			},
			'post_code': {
				required: MSG_ERROR_REQUIRED_POST_CODE,
			}
		}
	});

	var page = 0, column = [[5,1]];
	if(!$("#btnDelete").length){
		column = [[4,1]];
	}
	if($("#hdPageList").val()){
		page = parseInt($("#hdPageList").val());
	}
	if($("#hdSortColumnList").val() && $("#hdSortTypeList").val()){
		column = [[parseInt($("#hdSortColumnList").val()), parseInt($("#hdSortTypeList").val())]];
	}
	$("#userListTable").tablesorter({
		theme: 'gold',
		widthFixed: true,
		sortLocaleCompare: true,
		sortList: column,
		widgets: ['zebra', 'filter'],
	}).tablesorterPager({
		container: $(".pager"),
		type: "POST",
		ajaxUrl: appRoot + "ManageUser/user_list/{page}/20/{sortList:column}?{filterList:filter}",
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

	$(document).on('click', '#btnUnlock', function () {
		$('.alert').hide();
		var cbUnlocks = $('.cbUnlock').serializeArray();
		var user_ids = [];
		$.each(cbUnlocks, function(i, cbUnlock) {
			user_ids[i] = cbUnlock.value;
		});

		if (user_ids.length < 1) {
			//alert(MSG_ALERT_PLS_CHOOSE_USER);
			$('#user-error-message').find('p').text(MSG_ALERT_PLS_CHOOSE_USER);
			$('#user-error-message').show();
			return false;
		} else {
			$('#user-error-message').hide();
		}

		$.ajax({
			type: "POST",
			url: appRoot+"ManageUser/check_exist_user/",
			data: {
				user_ids: user_ids,
			},
			async: false,
			success:function(data){
				if(data == "systemerror"){
					alert(MSG_ALERT_SYSTEM_ERROR);
					location.reload();
					return;
				}else if(data == "err_user_not_exist"){
					alert(MSG_ALERT_NO_EXIST_USER);
					location.reload();
					return;
				}else{
					if (confirm(MSG_CONFIRM_UNLOCK_USER)) {
						display_load();
						$.ajax({
							type: "POST",
							url:appRoot+"ManageUser/unlock_user/",
							data: {
								user_ids: user_ids,
							},
							async: false,
							success:function(data){
								setEnabled();
								$.unblockUI();
								var results = JSON.parse(data);

								if (results['status'] == 'unlock'){
									//alert(MSG_ALERT_UNLOCK_SUCCESS);
									$('#user-success-message').find('p').text(MSG_ALERT_UNLOCK_SUCCESS);
									$('#user-success-message').show();
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
	});

	$(document).on('click', '#btnDelete', function () {
		$('.alert').hide();
		var cbDeletes = $('.cbDelete').serializeArray();
		var user_ids = [];
		$.each(cbDeletes, function(i, cbDelete) {
			user_ids[i] = cbDelete.value;
		});

		if (user_ids.length < 1) {
			//alert(MSG_ALERT_PLS_CHOOSE_USER);
			$('#user-error-message').find('p').text(MSG_ALERT_PLS_CHOOSE_USER);
			$('#user-error-message').show();
			return false;
		} else {
			$('#user-error-message').hide();
		}

		$.ajax({
			type: "POST",
			url: appRoot+"ManageUser/check_exist_user/",
			data: {
				user_ids: user_ids,
			},
			async: false,
			success:function(data){
				if(data == "systemerror"){
					alert(MSG_ALERT_SYSTEM_ERROR);
					location.reload();
					return;
				}else if(data == "err_user_not_exist"){
					alert(MSG_ALERT_NO_EXIST_USER);
					location.reload();
					return;
				}else{
					if (confirm(MSG_CONFIRM_DELETE_USER)) {
						display_load();
						$.ajax({
							type: "POST",
							url:appRoot+"ManageUser/delete_user/",
							data: {
								user_ids: user_ids,
							},
							async: false,
							success:function(data){
								setEnabled();
								$.unblockUI();
								var results = JSON.parse(data);

								if (results['status'] == 'delete'){
									$('#user-success-message').find('p').text(user_ids.length + '件' + MSG_ALERT_DELETE_SUCCESS);  /*20160311 Edit by Giang : #6695 - display the record quantity has been deleted*/
									$('#user-success-message').show();
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
	});

	$('#dialog_add_and_edit_user').on('hidden.bs.modal', function (e) {
		$('label.error').html('');
		$("#dialog_add_and_edit_user input[type!=hidden]").each(function() {
			$(this).val('');
			$(this).removeClass('error');
			$(this).removeAttr('disabled');
		});
		$('#dialog_add_and_edit_user select').val('');
		$('#dialog_add_and_edit_user select').removeClass('error');
		$('#dialog_add_and_edit_user select').removeAttr('disabled');

		$('#user_pass').rules('remove', 'required');
	});

	$('#btnAddUser').click(function() {
		$('.alert').hide();
		$('#modal_title_add_edit_user').html('新規登録');
		$('#dialog_add_and_edit_user').modal('show');
		show_permission_by_company();
	});
	$(document).on('click', '.btnEdit', function () {
		$('.alert').hide();
		var user_id = $(this).attr('user_id');
		$.ajax({
			type: "POST",
			url:appRoot+"ManageUser/check_exist_user/",
			data: {
				user_ids: user_id,
			},
			async: false,
			success:function(data){
				if(data == "systemerror"){
					alert(MSG_ALERT_SYSTEM_ERROR);
					location.reload();
					return;
				}else if(data == "err_user_not_exist"){
					alert(MSG_ALERT_NO_EXIST_USER);
					location.reload();
					return;
				}else{

					$.ajax({
						type: "POST",
						url: appRoot+"ManageUser/get_info_user/",
						data: {
							user_id: user_id
						},
						async: true,
						success:function(data){
							if (data == 'systemerror') {
								alert(MSG_ALERT_SYSTEM_ERROR);
								location.reload();
							}

							var results = JSON.parse(data);
							$('#modal_title_add_edit_user').html('編集');
							$('#dialog_add_and_edit_user').modal('show');
							$('#id').val(results.id);
							$('#company_id').val(results.company_id);
							$('#company_id').attr('disabled', 'disabled');
							$('#user_id').val(results.user_id);
							$('#user_id').attr('disabled', 'disabled');
							$('#user_name').val(results.user_name);
							$('#post_code').val(results.post_code);
							show_permission_by_company();
						}
					});
				}
			},
		});
	});

	$('#btnSave').click(function() {
		$('.alert').hide();
		if ($('#id').val() != '') {
			var action = 'edit';
			$("#user_pass_confirm").rules('add', {
				remote: {
					type: 'post',
					url: appRoot + 'ManageUser/check_change_password',
					async: false,
					data: {
						user_id: function() {
							return $('#id').val();
						},
						password_new: function() {
							return $('#form_add_and_edit_user input[name="user_pass_confirm"]').val();
						}
					}
				},
				messages: {
					remote: MSG_ERROR_PASSWORD_NOT_CHANGE,
				}
			});
		} else {
			var action = 'add';
			$("#user_pass").rules('add', {
				required: true,
				messages: {
					required: MSG_ERROR_REQUIRED_PASS,
				}
			});
		}

		if($('#form_add_and_edit_user').valid()) {

			var validator = $( "#form_add_and_edit_user" ).validate();
			validator.resetForm();

			$.ajax({
				type: "POST",
				url:appRoot+"ManageUser/check_exist_user/",
				data: {
					user_ids: $('#id').val(),
					action: action,
				},
				async: false,
				success:function(data){
					if(data == "systemerror"){
						alert(MSG_ALERT_SYSTEM_ERROR);
						location.reload();
						return;
					}else if(data == "err_user_not_exist"){
						alert(MSG_ALERT_NO_EXIST_USER);
						location.reload();
						return;
					}else{

						if(confirm(MSG_CONFIRM_CONTINUE)) {
							// disabledはPOSTパラメータに含まれない。解除して送る値を確定し、すぐにdisabledを設定する
							$('#company_id').attr('disabled', false);
							$('#user_id').attr('disabled', false);
							var data_user = $('#form_add_and_edit_user').serializeArray();
							$('#company_id').attr('disabled', 'disabled');
							$('#user_id').attr('disabled', 'disabled');
							display_load();
							$.ajax({
								type: "POST",
								url: appRoot+"ManageUser/add_and_edit_user/",
								data: {
									data_user: data_user,
								},
								async: true,
								success:function(data){
									setEnabled();
									$.unblockUI();
									var results = JSON.parse(data);

									if (results['status'] == 'insert') {
										$('#user-success-message').find('p').text(MSG_ALERT_INSERT_USER_SUCCESS);
										$('#user-success-message').show();
									} else if (results['status'] == 'update'){
										$('#user-success-message').find('p').text(MSG_ALERT_UPDATE_USER_SUCCESS);
										$('#user-success-message').show();
									} else if (results['status'] == 'validate_error'){
										//　画面遷移までボタン操作を禁止する
										setDisabled();
										alert(MSG_ALERT_FAILED_USER_MANAGE_CHECK);
										display_load();
										location.reload();
										return;
									} else {
										alert(MSG_ALERT_SYSTEM_ERROR);
										location.reload();
									}

									$('#dialog_add_and_edit_user').modal('hide');
									reload_table_tel_list(results['page'], results['sortColumn'], results['sortType']);
								},
							});
						}
					}
				},
			});
		}
	});

	$('#company_id').change(function() {
		$('#post_code').val("");
		show_permission_by_company();
	});
});

function reload_table_tel_list(page, sortColumn, sortType) {

	var url = appRoot + "ManageUser/user_list/" + page + "/20/column?filter";
	if (sortColumn != null && sortType != null) {
		url = appRoot + "ManageUser/user_list/" + page + "/20/column[" + sortColumn + "]=" + sortType + "?filter";
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
				$("#userListTable").trigger("renderAjax", json_data);
				$("#userListTable").trigger("update");
				$('#userListTable').trigger('pagerUpdate');
			}
		}
	});
}

/**
 * 権限のプルダウンを制御する
 */
function show_permission_by_company() {
	// 空白以外の選択肢を削除
	$('select#post_code option').not(':first').remove();

	if ($('#company_id').val() == ''){
		// 会社が選択されてない場合
		return;
	}

	$.ajax({
		type: "POST",
		url: appRoot + "ManageUser/get_auth_by_post_code/",
		data: {
			company_id : $('#company_id').val()
		},
		dataType: 'json',
		async: false,
		success:function(data){
			$.each(data, function(index, value){
				$('#post_code').append($('<option>').html(value.post_name).val(value.post_code));
			})
		}
	});
}
