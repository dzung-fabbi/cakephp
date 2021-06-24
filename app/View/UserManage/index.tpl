{html func=script url='pager'}
{html func=script url='view/usermanage/usermanage'}

<div id="div_container">

	<div class="div_box">

		<div class="callnumber_div margleft_20">
			<div class="green_buttons" style="padding-bottom:0px;">
				<div style="border:none"><a href="javascript:void(0);" id="toAddPageBtn" style="">新規登録</a></div>
			</div>
		</div>
		
		<div class="box_spacer"></div>
		<div class="box_spacer"></div>
		
		<div class="user_div">
		
			{assign_assoc var='usermanage_url' value="controller=>UserManage,action=>delete_user"}
			{assign_option var='usermanage_option' url=$usermanage_url}
			{form func='create' model='M15User' options=$usermanage_option}
				{$view->element('usermanage/users_table')}
			</form>
		</div>
		<div>
			{if $mode eq 'add'}
				<label class="error" style="margin-left: 120px;">ユーザーが追加されました。</label>
			{/if}
			{if $mode eq 'updated'}
				<label class="error" style="margin-left: 120px;">ユーザーが編集されました。</label>
			{/if}
			{if $mode eq 'delete'}
				<label class="error" style="margin-left: 120px;">ユーザーが削除されました。</label>
			{/if}
		</div>
		
	</div>
	
</div>