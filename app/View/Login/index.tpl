{html func=script url='view/login/login'}
<div class="row">
		
	<div class="row">
		<div class="col-md-5 center login-header" style="margin-bottom:50px;margin-top:50px;">
			<div class="loginLogo"></div>
		</div>
		<div class="well col-md-5 center login-box">
			<input type="hidden" id="refreshed" value="no">
			{assign_assoc var='login_url' value="controller=>Login,action=>login"}
			{assign_option var='login_option' url=$login_url}
			{form class="form-horizontal" func='create' model='M05User' options=$login_option}
					<div class="alert alert-danger fade in" id="login-error-message" {if $mode eq ''}style="display:none;"{/if}>
						<button type="button" class="close">×</button>
						<p>
						{if $mode eq 'username_error'}
							ユーザー情報が見つかりません。 ご確認の上、再度ログインして下さい。
						{/if}
						{if $mode eq 'password_error' && isset($error_remaining)}
							パスワードが正しくないです。 後{$error_remaining}回でこのアカウントがロックされます。
						{/if}
						{if $mode eq 'systemerror'}
							ログインに失敗しました。 ユーザーIDまたはパスワードを再確認して下さい。
						{/if}
						{if $mode eq 'restore_ok'}
							メールアドレスに再発行URLを送信しました。
						{/if}
						{if $mode eq 'setpass_error'}
							新パスワード発行に失敗しました。
						{/if}
						{if $mode eq 'setpass_success'}
							新パスワードが発行されました。
						{/if}
						{if $mode eq 'expired_link'}
							時間切れで無効なリンクになりました。
						{/if}
						{if $mode eq 'invalid_link'}
							無効なリンクです。
						{/if}
						{if $mode eq 'restore_error'}
							ユーザーIDまたはメールアドレスが違います。
						{/if}
						{if $mode eq 'user_locked'}
							アカウントがロックされています。 ロック解除についてはシステム管理者までお問い合わせ下さい。
						{/if}
						{if $mode eq 'login_other_session'}
							すでにログインされているユーザーのためロックされています。 ロック解除についてはシステム管理者までお問い合わせ下さい。
					{/if}
						</p>
					</div>

					
			
				<fieldset>
					<div class="input-group input-group-lg">
						<span class="input-group-addon"><i class="glyphicon glyphicon-user"></i></span>
						<input type="text" class="form-control" placeholder="ユーザーID" required="" autofocus="" name="data[M05User][user_id]" maxLength="30">
					</div>
					<div class="clearfix"></div><br>

					<div class="input-group input-group-lg">
						<span class="input-group-addon"><i class="glyphicon glyphicon-lock"></i></span>
						<input type="password" class="form-control" placeholder="パスワード" required="" name="data[M05User][password]">
					</div>
					<div class="clearfix"></div>
					<div class="clearfix"></div>

					<p class="center col-md-5">
						<button type="button" class="btn btn-primary btn-lg" id="lnkSubmit">ログイン</button>
					</p>
				</fieldset>
			</form>
			{$view->element('footer/footer')}
		</div>
	</div><!--/row-->
</div><!--/fluid-row-->