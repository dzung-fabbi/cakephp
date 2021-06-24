{html func=script url='view/usermanage/add_update'}
{if ($mode eq "update")}
	{html func=script url='view/usermanage/update'}
{else}
	{html func=script url='view/usermanage/add'}
{/if}

<div id="div_container">

	<div class="div_box">
	
		<div class="add_update_div">
		{*if isset($list_user)*}
			{*foreach from=$list_user item=ListUser*}
				{assign_assoc var='usermanage_url' value="controller=>UserManage,action=>add_user"}
				{assign_option var='usermanage_option' url=$usermanage_url}
				{form func='create' model='M15User' options=$usermanage_option}
					<div class="fldformat_20">
						<label class="lblformat">ID</label>
						{if ($mode eq "update")}
								<p style="padding-top: 2px; padding-left: 10px;">{$list_user.0.M15User.user_id}</p>
								<input type="hidden" id="id" name="data[M15User][id]" value="{$list_user.0.M15User.id}"/>
								<input type="hidden" id="user_id" name="data[M15User][user_id]" value="{$list_user.0.M15User.user_id}" />
						{else}
								<input type="text" id="user_id" name="data[M15User][user_id]" value="" class="input_box_new float_left"/>
						{/if}
					</div>
					<div class="err_msg_new_180">
						<label class="error cust_err" id="user_id-error" for="user_id"></label>
					</div>
					<div class="box_spacer_5"></div>
					<div class="fldformat_20">
						<label class="lblformat">ユーザー名</label>
						<input type="text" id="user_name" name="data[M15User][user_name]" value="{if $mode eq update}{$list_user.0.M15User.user_name}{/if}" class="input_box_new float_left"/>
					</div>
					<div class="err_msg_new_180">
						<label class="error cust_err" id="user_name-error" for="user_name"></label>
					</div>
					<div class="box_spacer_5"></div>
					<div class="fldformat_20">
						<label class="lblformat">パスワード</label>
						<input type="password" id="password" name="data[M15User][password]" value="" class="input_box_new float_left" {if $mode neq update}required{/if}/>
					</div>
					<div class="err_msg_new_180">
						<label class="error cust_err" id="password-error" for="password"></label>
					</div>
					<div class="box_spacer_5"></div>
					<div class="fldformat_20">
						<label class="lblformat">パスワード確認</label>
						<input type="password" id="passwordCheck" name="data[M15User][password_check]" value="" class="input_box_new float_left" {if $mode neq update}required{/if}/>
					</div>
					<div class="err_msg_new_180">
						<label class="error cust_err" id="passwordCheck-error" for="passwordCheck"></label>
					</div>
					<div class="box_spacer_5"></div>
					<div class="fldformat_20">
						<label class="lblformat">権限</label>
						<select id="post_code" name="data[M13Auth][post_code]" class="select_270 input_box_new float_left" required="false">
							<option value="">---</option>
							{foreach from=$auth item=authItem}
								{*if $authItem.M13Auth.post_code >= $post_code*}
									<option value="{$authItem.M13Auth.post_code}"
										{if $mode eq update}
											{if $list_user.0.M15User.post_code == $authItem.M13Auth.post_code}
												selected
											{/if}
										{/if}
									>
										{$authItem.M13Auth.post_name}
									</option>
								{*/if*}
							{/foreach}
						</select>
					</div>
					<div class="err_msg_new_180">
						<label class="error cust_err" id="post_code-error" for="post_code"></label>
					</div>
					{if ($mode eq "update")}
						<div>
							<input type="hidden" id="hdnCate1" value="{$list_user.0.M15User.category1}" />
							<input type="hidden" id="hdnCate2" value="{$list_user.0.M15User.category2}" />
							<input type="hidden" id="hdnCate3" value="{$list_user.0.M15User.category3}" />
							<input type="hidden" id="hdnCate4" value="{$list_user.0.M15User.category4}" />
						</div>
					{/if}
					<div class="box_spacer_5"></div>
					<div class="fldformat_20">
						<label class="lblformat">分類1</label>
						{if ($mode eq "update")}
							<!-- 編集モードまたは分類1あり -->
							{if !empty($login_cate1_code)}
								<p style="padding-left:10px;">{$login_cate1_name}</p>
								<input type="hidden" id="category1" name="data[M25Category][category1]" value={$login_cate1_code}>
							{else}
							<!-- 編集モードまたは分類1なし -->
								<select id="category1" name="data[M25Category][category1]" class="select_270 input_box_new float_left">
									<option value="">---</option>
									{foreach from=$category1_list item=category1List}
										<option value = "{$category1List.M25Category.category_code}"
											{if !empty($list_user.0.M15User.category1)}
												{if $list_user.0.M15User.category1 == $category1List.M25Category.category_code}
													selected
												{/if}
											{/if}
										>
										{$category1List.M25Category.category_name}
										</option>
									{/foreach}
								</select>
							{/if}
						{else}
						<!-- 追加モード -->
							{if !empty($login_cate1_code)}
								<p style="padding-left:10px;">{$login_cate1_name}</p>
								<input type="hidden" id="category1" name="data[M25Category][category1]" value={$login_cate1_code}>
							{else}
								<select id="category1" name="data[M25Category][category1]" class="select_270 input_box_new float_left">
									<option value="">---</option>
									{foreach from=$category1_list item=category1List}
										<option value = "{$category1List.M25Category.category_code}">{$category1List.M25Category.category_name}</option>
									{/foreach}
								</select>
							{/if}
						{/if}
					</div>
					<div class="err_msg_new_180">
						<label class="error cust_err" id="category1-error" style="display: block;" for="category1"></label>
					</div>
					<div class="box_spacer_6"></div>
					<div class="fldformat_20">
						<label class="lblformat">分類2</label>
						<div id="category2_div">
							{$view->element('usermanage/category2')}
						</div>
					</div>
					<div class="err_msg_new_180"></div>
					<div class="box_spacer_6"></div>
					<div class="fldformat_20">
						<label class="lblformat">分類3</label>
						<div id="category3_div">
							{$view->element('usermanage/category3')}
						</div>
					</div>
					<div class="err_msg_new_180"></div>
					<div class="box_spacer_6"></div>
					<div class="fldformat_20">
						<label class="lblformat">分類4</label>
						<div id="category4_div">
							{$view->element('usermanage/category4')}
						</div>
					</div>
					<div class="err_msg_new_180"></div>
					<div class="box_spacer_6"></div>
					<div class="fldformat_20">
						<label class="lblformat">メールアドレス</label>
						<input type="text" id="" name="data[M15User][mail]" value="{if $mode eq update}{$list_user.0.M15User.mail}{/if}" class="input_box_new float_left"/>
					</div>
					<div class="err_msg_new_180">
						<label class="error cust_err" id="data[M15User][mail]-error" for="data[M15User][mail]"></label>
					</div>
				</form>

				{if $mode eq 'existing'}
				<div class="err_msg_new_180">
					<label class="error" style="margin-left: 120px;">このIDはすでに使われています。</label>
				</div>
				{/if}

			{*foreach*}
		{*/if*}
		</div>
		<div class="box_spacer_5"></div>
		<div class="callnumber_div margleft_20">
			<div class="gray_buttons" style="padding-bottom:0px;">
				<div style="border:none"><a href="javascript:void(0);" id="backBtn" style="margin-left: 215px;float:left; margin-right:15px;">戻る</a></div>
			</div>
			<div class="green_buttons" style="padding-bottom:0px;">
				{if $mode eq update}
					<div style="border:none"><a href="javascript:void(0);" id="updateBtn" style="float: left;">登録</a></div>
				{else}
					<div style="border:none"><a href="javascript:void(0);" id="addBtn" style="float: left;">登録</a></div>
				{/if}
			</div>
		</div>
	</div>
	
</div>