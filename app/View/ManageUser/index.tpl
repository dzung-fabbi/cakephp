{html func=css path='manageuser/manage_user_index'}
{html func=script url='jquery.validate'}
{html func=script url='view/manageuser/manage_user_index'}
{html func=script url='pager'}


<div class="col-lg-10 col-sm-10" id="content">
<!-- content starts -->
	<div class="alert alert-success fade in" id="user-success-message" style="display:none;">
		<button type="button" class="close">×</button><p></p>
	</div>
	<div class="alert alert-danger fade in" id="user-error-message" style="display:none;">
		<button type="button" class="close">×</button><p></p>
	</div>
	<div class="row">
		<div class="form-group col-md-12">
			{if $enable_create}
				<a href="javascript:void(0);" class="btn btn-primary" id="btnAddUser">新規登録</a>
			{/if}
			{if $enable_delete}
				<a href="javascript:void(0);" class="btn btn-default" id="btnDelete">選択項目を削除</a>
			{/if}
			{if $enable_unlock}
				<a href="javascript:void(0);" class="btn btn-default" id="btnUnlock">選択項目をロック解除</a>
			{/if}
		</div>
	</div>

	<div class="rules_div">
		<div class="wrap">
			<table id="userListTable">
				<thead class="head">
					<tr>
						{if $enable_delete}
							<th class="remove sorter-false filter-false alignCenter"></th>
						{/if}
						<!-- <th style="text-align:center;">No</th> -->
						<th class="alignCenter tablesorter-headerUnSorted">企業名</th>
						<th class="alignCenter tablesorter-headerUnSorted">ユーザーID</th>
						<th class="alignCenter tablesorter-headerUnSorted">ユーザー名</th>
						<th class="alignCenter tablesorter-headerUnSorted">権限</th>
						<th class="alignCenter tablesorter-headerUnSorted">作成日時</th>
						{if $enable_unlock}
						<th class="remove sorter-false filter-false text-center">ロック</th>
						{/if}
						{if $enable_edit}
						<th class="remove sorter-false filter-false text-center">アクション</th>
						{/if}
					</tr>
				</thead>
				<tbody class="inner_table">
				</tbody>
			</table>
			<!-- pager -->
			{$view->element('pager/pager')}
			<input type="hidden" value="{if isset($sortColumn)}{$sortColumn}{/if}" id="hdSortColumnList"/>
			<input type="hidden" value="{if isset($sortType)}{$sortType}{/if}" id="hdSortTypeList"/>
			<input type="hidden" value="{if isset($page)}{$page}{/if}" id="hdPageList"/>
		</div>
	</div>

	<!-- 新規登録MODAL START -->
	<div class="modal fade" id="dialog_add_and_edit_user" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true" data-backdrop="static">
		<div class="modal-dialog" style="width:650px;">
			<div class="modal-content">
				<!-- Modal Header -->
				<div class="modal-header">
					<button type="button" class="close"
					   data-dismiss="modal">
						   <span aria-hidden="true">&times;</span>
						   <span class="sr-only">Close</span>
					</button>
					<h4 class="modal-title" id="modal_title_add_edit_user"></h4>
				</div>

				<form class="form-horizontal" role="form" id="form_add_and_edit_user" method="post" action="{Router::url('', true)}" accept-charset="utf-8" enctype="multipart/form-data">
				<input type="text" id="id" name="id" hidden="hidden">
				<!-- Modal Body -->
				<div class="modal-body">

					<div class="form-group">
						<label class="col-sm-3 control-label">アカウント</label>
						<div class="col-sm-7">
							{if $m02companies|@count > 1}
								<select id="company_id" name="company_id" class="form-control">
									<option value="">---</option>
									{foreach from=$m02companies item=company}
										<option value="{$company.M02Company.company_id}">{$company.M02Company.company_name}</option>
									{/foreach}
								</select>
							{elseif $m02companies|@count == 1}
								<label class="control-label">{$m02companies.M02Company.company_name}</label>
								<input type="hidden" value="{$m02companies.M02Company.company_id}" id="company_id" name="company_id">
							{/if}
						</div>
					</div>
					<div class="form-group">
						<label class="col-sm-3 control-label">ユーザーID</label>
						<div class="col-sm-7">
							<input type="text" id="user_id" name="user_id"
							data-rule-maxlength="20"
							class="form-control" placeholder="ユーザーID"/>
						</div>
					</div>
					<div class="form-group">
						<label class="col-sm-3 control-label">ユーザー名</label>
						<div class="col-sm-7">
							<input type="text" id="user_name" name="user_name"
							data-rule-maxlength="64"
							class="form-control" placeholder="ユーザー名"/>
						</div>
					</div>
					<div class="form-group">
						<label class="col-sm-3 control-label">パスワード</label>
						<div class="col-sm-7">
							<input type="password" id="user_pass" name="user_pass"
							data-rule-maxlength="128"
							data-rule-minlength="6"
							class="form-control" placeholder="パスワード"/>
						</div>
					</div>
					<div class="form-group">
						<label class="col-sm-3 control-label">確認用パスワード</label>
						<div class="col-sm-7">
							<input type="password" id="user_pass_confirm" name="user_pass_confirm"
							data-rule-maxlength="128"
							data-rule-minlength="6"
							class="form-control" placeholder="確認用パスワード"/>
						</div>
					</div>
					<div class="form-group">
						<label class="col-sm-3 control-label">権限</label>
						<div class="col-sm-7">
							<select id="post_code" name="post_code" class="form-control">
								<option value="">---</option>
							</select>
						</div>
					</div>

				</div>

				<!-- Modal Footer -->
				<div class="modal-footer">
					<a href="javascript:void(0);" class="btn btn-default executebtn" id="btnCancel" data-dismiss="modal">閉じる</a>
					<a href="javascript:void(0);" class="btn btn-primary executebtn" id="btnSave">保存</a>
				</div>
				</form>
			</div>
		</div>
	</div>
	<!-- 新規登録MODAL END-->

<!-- content ends -->
</div>