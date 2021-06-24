$(document).ready(function() {
	{
		$('.alert .close').on('click', function(e) {
			$(this).parent().hide();
			$(this).parent().find("p").remove();
		});
		$.validator.addMethod('notEqualTo', function(value, element, param){
			var target = $(param);
			target.unbind().bind("blur", function() {
				$(element).valid();
			});
			return value !== target.val();
		}, '');

		var validator = $("#M05UserPwordChangeIndexForm").validate({
			rules: {
				"old_pword": {
				  required: true
				},
				"new_pword": {
				  required: true,
				  notEqualTo: '#old_pword'
				},
				"new_pword_check": {
				  required: true,
				  equalTo: "#new_pword"
				}
			},
			messages: {
				"old_pword": {
				  required: "旧パスワードを入力して下さい。"
				},
				"new_pword": {
				  required: "新パスワードを入力して下さい。",
				  notEqualTo: '新しいパスワードは旧パスワードと同じには出来ません。'
				},
				"new_pword_check": {
				  required: "新パスワード確認を入力して下さい。",
				  equalTo: "新パスワード確認が一致しません。"
				}
			},
			showErrors: function(errorMap, errorList) {
				if (errorList.length > 0) {
					$('#pass-error-message').find("p").remove();

					$.each(errorList, function(index, val) {
						$('#pass-error-message').append('<p>' + val.message + '</p>');
					});
					$('#pass-error-message').show();
				} else {
					$('#pass-error-message').hide();
				}
			}
		});
	}

	$('#btnChangePassWord').click(function(){
		//alert();
		if($("#M05UserPwordChangeIndexForm").valid()) {
			var pass_data = $('#M05UserPwordChangeIndexForm').serializeArray();
			display_load();
			$.ajax({
				type: "POST",
		        url:appRoot + "PasswordChange/change_password/",
		        async: false,
		        data: {
		        	pass_data: pass_data,
		        },
		        async: true,
		        success: function(data){
		        	setEnabled();
                    $.unblockUI();
                    if (data == 'systemerror') {
                    	alert(MSG_ALERT_SYSTEM_ERROR);
                    	location.reload();
                    }else if (data == 'invalid') {
                    	$('#M05UserPwordChangeIndexForm input').val('');
                    	$('#pass-error-message').find("p").remove();
		        		$('#pass-error-message').append('<p>正しくないパスワードです。</p>');
		        		$('#pass-error-message').show();
		        	} else{
		        		alert(MSG_ALERT_CHANGE_PASS_SUCCESS);
		        		window.location.href = appRoot+"OutSchedule/index";
		        	}
		        },
    		});
		}
	});

	$("#M05UserPwordChangeIndexForm :input").keydown(function(e){
		if(e.keyCode == 13){
			$("#btnChangePassWord").click();
		}
	});

});