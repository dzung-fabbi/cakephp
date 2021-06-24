$(document).ready(function() {
	{
		$('.alert .close').on('click', function(e) {
			$(this).parent().hide();
		});
		onload=function(){
		var e=document.getElementById("refreshed");
		if(e.value=="no")e.value="yes";
		else{e.value="no";location.reload();}
		}
	}
	$('#lnkSubmit').click(function(){
		if ($(this).attr("disabled") != "disabled" && $(this).attr("disabled") != true) {
			if($("input[name='data[M05User][user_id]']").val() == '') {
				$('#login-error-message').find('p').text("ユーザーIDを入力して下さい。");
				$('#login-error-message').show();
				$("input[name='data[M05User][user_id]']").focus();
			} else if($("input[name='data[M05User][password]']").val() == ''){
				$('#login-error-message').find('p').text("パスワードを入力して下さい。");
				$('#login-error-message').show();
				$("input[name='data[M05User][password]']").focus();
			} else {
				$("#M05UserIndexForm").submit();
				$(this).attr("disabled","disabled");
			}
		}
	});
	$("#M05UserIndexForm :input").keydown(function(e){
		if(e.keyCode == 13){
			$("#lnkSubmit").click();
		}
	});
	$("#UserPwd").keydown(function(e){
		if (e.keyCode == 32 || (e.keyCode == 86 && e.ctrlKey == true)) {
			e.preventDefault();
		}
	});
	$("#lnkForgetPass").click(function(){
		window.location.href = appRoot+"Login/forget_password";
	});
	$("#lnkToLogin").click(function(){
		window.location.href = appRoot+"Login/index";
	});
	$("#lnkRestorePass").click(function(){
		//alert("restore pass");
		if ($(this).attr("disabled") != "disabled" && $(this).attr("disabled") != true) {
			if($("#M05UserForgetPasswordForm").valid()) {
				var url = appRoot + "Login/send_reset_link/";
				$("#M05UserForgetPasswordForm").attr('action',url);
				$("#M05UserForgetPasswordForm").submit();
				$(this).attr("disabled","disabled");
			}
		}
	});
	$("#lnkReset").click(function(){
		//alert("aaaa");
		if ($(this).attr("disabled") != "disabled" && $(this).attr("disabled") != true) {
			if ($("#M05UserResetPasswordForm").valid()) {
				if ($("#UserNewPwd").val() == $("#UserReNewPwd").val()) {
					//alert("パスワードが一致する");
					var url = appRoot + "Login/set_new_password/";
					$("#M05UserResetPasswordForm").attr('action',url);
					$("#M05UserResetPasswordForm").submit();
					$(this).attr("disabled","disabled");
				} else {
					alert("パスワードが一致しません。");
					return;
				}
			}
		}
	});
	
});