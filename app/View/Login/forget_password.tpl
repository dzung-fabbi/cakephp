{html func=script url='view/login/login'}
<!-- login -->
<div id="login_container">
	<div id="login_box">
		<input type="hidden" id="refreshed" value="no">
		{assign_assoc var='login_url' value="controller=>Login,action=>login"}
		{assign_option var='login_option' url=$login_url}
		{form func='create' model='M15User' options=$login_option}
			<div class="box_spacer"></div>
			<div class="box_spacer"></div>
			<div class="login_lbl">
				ユーザーID
				<input type="text" name="data[M15User][user_id]" maxLength="30" class="input_box required"/>
				<div style="height:12px;">
					<label class="error cust_err" id="data[M15User][user_id]-error" for="data[M15User][user_id]"></label>
				</div>
			</div>
			<div class="login_lbl">
				メールアドレス
				<input type="text" id="UserPwd" name="data[M15User][mail]" maxLength="30" class="input_box required"/>
				<div style="height:12px;">
					<label class="error cust_err" id="UserPwd-error" for="UserPwd"></label>
				</div>
			</div>
			<div class="box_spacer"></div>
			<div class="login_button" style="padding-bottom:0px;">
				<div style="border:none"><a href="javascript:void(0);" id="lnkRestorePass" style="margin-left: 65px;">パスワード再発行</a></div>
			</div>
			<div class="box_spacer"></div>
			<div class="login_button" style="padding-bottom:0px;">
				<div style="border:none"><a href="javascript:void(0);" id="lnkToLogin" style="padding-right: 40px; padding-left: 40px; margin-left: 65px;">ログイン画面へ</a></div>
			</div>
		</form>
	</div>
</div>
