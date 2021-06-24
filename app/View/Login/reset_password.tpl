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
				<label class="" style="color: black; margin-left: 10px;">{if isset($userid)}{$userid}{/if}</label>
				<input type="hidden" name="data[M15User][user_id]" id="UserId" class="input_box required" value="{if isset($userid)}{$userid}{/if}"/>
				<input type="hidden" name="data[T91PassRes][id]" id="T91Id" class="input_box required" value="{if isset($pass_res_id)}{$pass_res_id}{/if}"/>
			</div>
			<div class="login_lbl">
				新パスワード
				<input type="password" id="UserNewPwd" name="data[M15User][new_password]" maxLength="30" class="input_box required"/>
				<div style="height:12px;">
					<label class="error cust_err" id="UserNewPwd-error" for="UserNewPwd"></label>
				</div>
			</div>
			<div class="login_lbl">
				新パスワード確認
				<input type="password" id="UserReNewPwd" name="data[M15User][renew_password]" maxLength="30" class="input_box required"/>
				<div style="height:12px;">
					<label class="error cust_err" id="UserReNewPwd-error" for="UserReNewPwd"></label>
				</div>
			</div>
			<div class="box_spacer"></div>
			<div class="login_button" style="padding-bottom:0px;">
				<div style="border:none"><a href="javascript:void(0);" id="lnkReset" style="margin-left: 70px;">パスワード設定</a></div>
			</div>
		</form>
	</div>
</div>
