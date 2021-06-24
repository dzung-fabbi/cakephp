{html func=script url='view/passwordchange/passwordchange'}
{html func=script url='jquery.validate'}
<div class='row'>
	<div class='row'>
		<div class="well col-md-5 center login-box">
			<div class="alert alert-danger fade in" id="pass-error-message" style="display:none">
				<button type="button" class="close">×</button>
			</div>
			<form class="form-horizontal" role="form" id="M05UserPwordChangeIndexForm" method="post" action="{Router::url('', true)}" accept-charset="utf-8">
				<fieldset>
					<div class="clearfix"></div><br>
					<div class="input-group input-group-lg">
						<span class="input-group-addon"><i class="glyphicon glyphicon-lock"></i></span>
						<input type="password" class="form-control" placeholder="旧パスワード" required="" autofocus="" id="old_pword" name="old_pword">
					</div>
					<div class="clearfix"></div><br>
					<div class="input-group input-group-lg">
						<span class="input-group-addon"><i class="glyphicon glyphicon-log-in"></i></span>
						<input type="password" autocomplete='off' class="form-control" placeholder="新パスワード" required="" id="new_pword" name="new_pword">
					</div>
					<div class="clearfix"></div><br>
					<div class="input-group input-group-lg">
						<span class="input-group-addon"><i class="glyphicon glyphicon-log-in"></i></span>
						<input type="password" autocomplete='off' class="form-control" placeholder="新パスワード確認" required="" id="new_pword_check" name="new_pword_check">
					</div>
					<div class="clearfix"></div><br>
					<p class="center col-md-5">
						<button type="button" class="btn btn-primary btn-lg" id="btnChangePassWord">パスワードを更新</button>
					</p>

				</fieldset>
			</form>
		</div>
	</div>
</div>