$(document).ready(function() {
	init_table(showCbDel, 'SmsTemplate', 'arr_sms_template_list', '#smsTemplateTable');

	{/*add sms template*/

		$.validator.addMethod('myRequired', function(value, element, param) {
			if (value.length == 0){
				return false;
			}
			return true;
		});

		// API_v2で短縮時に利用できない禁則文字が入っているかの確認。
		// 短縮URLチェックボックスがONならば、反応する。
		$.validator.addMethod('checkSmsIllegalString', function(value, element, param) {
			if($('#sms_use_short_url').prop('checked')){
				if (validateSMSBodyStringInUrl(value)) {
					return true;
				}
				return false;
			}
			return true;
		});

		// SMS本文中にURLパターンが３つ以上ないかの確認。
		// 短縮URLチェックボックスがONならば、反応する。
		$.validator.addMethod('checkSmsMaxUrlCount', function(value, element, param) {
			if($('#sms_use_short_url').prop('checked')){
				if (validateSMSBodyMaxUrlCount(value)) {
					return true;
				}
				return false;
			}
			return true;
		});

		// SMS本文中にURLパターンが３つ以上ないかの確認。
		// 短縮URLチェックボックスがONならば、反応する。
		$.validator.addMethod('checkSmsIllegalPositionTrackingCode', function(value, element, param) {
			if($('#sms_use_short_url').prop('checked')){
				if (validateSMSBodyStringInUrlTrackingCode(value)) {
					return true;
				}
				return false;
			}
			return true;
		});


		// 文字数カウント
		$.validator.addMethod('myMaxLength', function(value, element, param) {
			count = replaceUrlSMSBodyBulk(value, $('#sms_use_short_url').prop('checked')).length;
			if (count > param){
				return false;
			}
			return true;
		});
		$.validator.addMethod('checkDollar', function(value, element, param) {
			if (value.match(DOLLAR_REGEX) != null) {
				return false;
			}
			return true;
		});

		// SMS本文内の利用する挿入項目が、挿入項目プルダウン内にあるかを判定。
		$.validator.addMethod('checkValidItem', function(value, element, param) {
			if ($.trim(value)) {
				var option_arr = [];
				$('#tounyuu option').each(function(){
					option_arr.push($(this).html());
				});

				var flag = true;
				var start_flag = false;
				var end_flag = false;
				var sub_content = "";
				for (var i = 0; i < $.trim(value).length; i++) {
					if (start_flag) {
						if ($.trim(value)[i] == '}') {
							if (sub_content == '') {
								flag = false;
							}else{
								if($.inArray(sub_content, option_arr) < 0){
									flag = false;
								}
								sub_content = '';
							}
							start_flag = false;
						}else{
							sub_content = sub_content + $.trim(value)[i];
						}
					}else{
						if ($.trim(value)[i] == '{'){
							start_flag = true;
						}else if ($.trim(value)[i] == '}') {
							flag = false;
						}
					}
					if (!flag) {
						return false;
					}
				}
				if(start_flag == true){
					return false;
				}
			}
			return true;
		});

		$("#form_add_sms_template").validate({
			ignore: "",
			rules:{
				"template_name": {
					required : true,
					remote: {
						type: 'post',
						url: appRoot + 'SmsTemplate/check_exist_template_name',
						async: false,
						data: {
							templateName: function() {
								return $("#template_name").val();
							},
							templateId: function() {
								return $("#template_id").val();
							}
						}
					}
				},
				"content": {
					myRequired : true,
					myMaxLength: SMS_MAX_LENGTH,
					checkDollar: true,
					checkSmsIllegalString: true,
					checkSmsMaxUrlCount: true,
					checkSmsIllegalPositionTrackingCode: true,
					checkValidItem: true
				}
			},
			messages:{
				"template_name": {
					required: MSG_ERROR_REQUIRED_SMS_TEMPLATE_NAME,
					remote: MSG_ERROR_EXIST_SMS_TEMPLATE_NAME
				},
				"content": {
					myRequired: MSG_ERROR_REQUIRED_SMS_TEM_CONTENT,
					myMaxLength: '本文は' + SMS_MAX_LENGTH + '文字以下を入力してください。',
					checkDollar: SMS_MSG_BODY_INVALID,
					checkSmsIllegalString: SMS_ILLEGAL_STRING_IN_BODY_URL,
					checkSmsMaxUrlCount: SMS_OVER_COUNT_IN_BODY_URL,
					checkSmsIllegalPositionTrackingCode: SMS_ILLEGAL_POSITION_TRACKING_CODE,
					checkValidItem: '挿入項目の内容以外を入力できません。'
				},
			},
		});

		$('#btnCreate').click(function () {
			$('.alert').hide();
			$('#smsTemplateModalLabel').html('SMS新規登録画面');
			$('#btn_submit').css('display', '');
			$('#btn_update').css('display', 'none');
			$('#dialog_add_sms_template').modal('show');
			var content = $("#content").val();
			var count = content.length;		
			$("#count_content").text(count);
		});

		$('#dialog_add_sms_template').on('hidden.bs.modal', function (e) {
			$('#dialog_add_sms_template .error').html('');
			$('#dialog_add_sms_template input').val('');
			$('#dialog_add_sms_template textarea').val('');
		});

		$('#btn_submit').click(function() {
			setDisabled();
			if($("#form_add_sms_template").valid() && confirm(MSG_CONFIRM_SMS_TEM_ADD)) {
				display_load();
				$.ajax({
					type: "POST",
					url: appRoot + "SmsTemplate/add_sms_template/",
					data: {
						templateName: $('#template_name').val(),
						description: $('#description').val(),
						content: $('#content').val(),
						// .val()だと、稀に値が取れないので、チェックON-OFFで状態を確認する。（ON＝DBには1を、OFF＝空欄を設定）
						sms_use_short_url: $('#sms_use_short_url').prop('checked') ? 1 : ""
					},
					async: true,
					success:function(data){
						setEnabled();
						$.unblockUI();
						if (data == 'systemerror') {
							alert(MSG_ALERT_SYSTEM_ERROR);
							location.reload();
						}

						var results = JSON.parse(data);
						if (results['status'] == 'save') {
							$('#smstemplate-success-message').find('p').text(MSG_ALERT_SMS_TEM_ADD_SUCCESS);
							$('#smstemplate-success-message').show();
							$('#dialog_add_sms_template').modal('hide');
							reload_table(results['page'], results['sortColumn'], results['sortType'], 'SmsTemplate', 'arr_sms_template_list', '#smsTemplateTable');
						}
					},
				});
			}
			setEnabled();
		});

		// SMSのテンプレートの「編集」または「複製」ボタンを押したときの動作。
		$(document).on('click', '.btnEdit, .btnDuplicate', function() {
			var action = 'duplicate';
			if ($(this).hasClass('btnEdit')) {
				action = 'edit';
			}
			$.ajax({
				type: "POST",
				url: appRoot + "SmsTemplate/check_edit_sms_template/",
				data: {
					templateId: $(this).attr('sms_template_id'),
					action: action
				},
				async: true,
				success:function(data){
					setEnabled();
					$.unblockUI();
					if (data == 'systemerror') {
						alert(MSG_ALERT_SYSTEM_ERROR);
						location.reload();
					} else if (data == 'err_not_exist') {
						alert(MSG_ALERT_NO_EXIST_SMS_TEMPLATE);
						location.reload();
					}
					// そのテンプレートの値を、ポップアップに当てる。
					var results = JSON.parse(data);
					if (results['status'] == 'can_edit') {
						if (action == 'edit') {
							$('#template_id').val(results['template_id']);
							$('#template_name').val(results['template_name']);
							$('#smsTemplateModalLabel').html('SMS編集画面');
							$('#btn_submit').css('display', 'none');
							$('#btn_update').css('display', '');
							if(!results['enable_edit']){
								$("#form_add_sms_template input,textarea").attr('disabled',true);
								$("#btn_update").hide();
							}else{
								$("#form_add_sms_template input,textarea").attr('disabled',false);
								$("#btn_update").show();
							}
						} else {
							$('#smsTemplateModalLabel').html('SMS複製画面');
							$('#btn_submit').css('display', '');
							$('#btn_update').css('display', 'none');
							$("#form_add_sms_template input,textarea").attr('disabled',false);
						}
						$('#description').val(results['description']);
						$('#content').val(results['content']);
						var sms_use_short_url = results['sms_use_short_url'] ? true : false
						console.log(sms_use_short_url)
						$('#sms_use_short_url').prop("checked", sms_use_short_url);
						$("#msg_edit").html(results['msg_edit']);
						$('#dialog_add_sms_template').modal('show');
						$("#content").keydown();
					}
				},
			});
		});

		$('#btn_update').click(function() {
			setDisabled();
			if($("#form_add_sms_template").valid() && confirm(MSG_CONFIRM_SMS_TEM_UPDATE)) {
				display_load();
				$.ajax({
					type: "POST",
					url: appRoot + "SmsTemplate/update_sms_template/",
					data: {
						templateId: $('#template_id').val(),
						templateName: $('#template_name').val(),
						description: $('#description').val(),
						content: $('#content').val(),
						// .val()だと、稀に値が取れないので、チェックON-OFFで状態を確認する。（ON＝DBには1を、OFF＝空欄を設定）
						sms_use_short_url: $('#sms_use_short_url').prop('checked') ? 1 : ""
					},
					async: true,
					success:function(data){
						setEnabled();
						$.unblockUI();
						if (data == 'systemerror') {
							alert(MSG_ALERT_SYSTEM_ERROR);
							location.reload();
						}

						var results = JSON.parse(data);
						if (results['status'] == 'save') {
							$('#smstemplate-success-message').find('p').text(MSG_ALERT_SMS_TEM_UPDATE_SUCCESS);
							$('#smstemplate-success-message').show();
							$('#dialog_add_sms_template').modal('hide');
							reload_table(results['page'], results['sortColumn'], results['sortType'], 'SmsTemplate', 'arr_sms_template_list', '#smsTemplateTable');
						}
					},
				});
			}
			setEnabled();
		});

		$('.btn_cancel').click(function() {
			if (confirm(MSG_CONFIRM_SMS_TEM_UPDATE_CLOSE_POPUP)) {
				$('#dialog_add_sms_template').modal('hide');
			}
		});
	}

	$(document).on('click', '#btnSelectedDelete', function () {
		setDisabled();
		$('.alert').hide();
		var cbSelects = $(":checkbox").serializeArray();
		var sms_template_ids = [];
		$.each(cbSelects, function(i, cbSelect) {
			sms_template_ids[i] = cbSelect.value;
		});

		if (sms_template_ids.length < 1) {
			$('#smstemplate-error-message').find('p').text(MSG_ALERT_PLS_CHOOSE_SMS_TEMPLATE);
			$('#smstemplate-error-message').show();
			setEnabled();
			return false;
		}

		$.ajax({
			type: "POST",
			url:appRoot+"SmsTemplate/check_info_smstemplate/",
			data: {
				sms_template_ids: sms_template_ids,
			},
			async: false,
			success:function(data){
				if(data == "systemerror"){
					alert(MSG_ALERT_SYSTEM_ERROR);
					location.reload();
				} else if(data == "err_not_exist"){
					alert(MSG_ALERT_NO_EXIST_SMS_TEMPLATE);
					location.reload();
				} else if(data == "err_used"){
					alert(MSG_ALERT_USED_TEMPLATE);
				} else {
					if(confirm(MSG_CONFIRM_DEL)){
						display_load();
						$.ajax({
							type: "POST",
							url: appRoot + "SmsTemplate/delete/",
							data: {
								sms_template_ids: sms_template_ids
							},
							async: false,
							success:function(data){
								setEnabled();
								$.unblockUI();
								if (data == 'systemerror') {
									alert(MSG_ALERT_SYSTEM_ERROR);
									location.reload();
								}

								var results = JSON.parse(data);
								if (results['status'] == 'can_del') {
									$('#smstemplate-success-message').find('p').text(sms_template_ids.length + '件' + MSG_ALERT_SMS_TEM_DEL_SUCCESS);
									$('#smstemplate-success-message').show();
									reload_table(results['page'], results['sortColumn'], results['sortType'], 'SmsTemplate', 'arr_sms_template_list', '#smsTemplateTable');
								}
							},
						});
					}
				}
			},
		});
		setEnabled();
	});
	// SMS本文になんらかの文字を入れた場合、文字数をカウントする
	$(document).on('keydown mouseup keyup keypress blur change', '#content', function() {
		var content = $('#content').val();
		contentLength = replaceUrlSMSBodyBulk(content, $('#sms_use_short_url').prop('checked')).length;
		$("#count_content").text(contentLength);	
	});
	$(document).on('click', '.btnCustInfo', function (e) {
		var item = $(this).parents(".form-audio").find(".slCustInfo option:selected").text();
		txt = $("#content").val();
		$("#content").val(txt + "{" + item + "}");
	});

	// URL短縮（電話番号を替えた時、短縮URLチェックボックスの状態を切替、SMS本文を再計算する。）
	$(document).on('click', '#sms_use_short_url', function (e) {
		// エラーを制御するため、バリデートを発火
		$("#form_add_sms_template").valid();
		// 文字数を更新する
		var content = $('#content').val();
		contentLength = replaceUrlSMSBodyBulk(content, $('#sms_use_short_url').prop('checked')).length;
		$("#count_content").text(contentLength);	
	});

});
