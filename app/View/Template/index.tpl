{html func=css path='template/index'}
{html func=css path='../js/dropzone/css/dropzone.css'}
{html func=script url='dropzone/dropzone.js'}
{html func=script url='pager'}
{html func=script url='view/template/index'}
{html func=script url='clipboard.min'}
<div class="col-lg-10 col-sm-10" id="content">
<!-- content starts -->

	{if $mode eq "success"}
		<div class="alert alert-success fade in"><button type="button" class="close">×</button>保存しました。</div>
	{/if}
	{if $mode eq "delete"}
		<div class="alert alert-success fade in"><button type="button" class="close">×</button>{$del_count}件削除しました。</div> <!-- 20160311 Edit by Giang : #6695 - display the record quantity has been deleted -->
	{/if}
	<div class="alert alert-danger fade in" id="template-error-message" style="display:none;">
		<button type="button" class="close">×</button><p></p>
	</div>

	<div class="row">
		<div class="form-group col-md-12">
			{if $create_flag}
				<a href="javascript:void(0);" title="新規登録" data-toggle="tooltip" class="btn btn-primary" id="btnCreate">新規登録</a>
			{/if}
			{if $import_flag}
				<a href="javascript:void(0);" title="インポート" data-toggle="tooltip" class="btn btn-default" id="btnImportTemplate">インポート</a>
			{/if}
			{if $delete_flag}
				<a href="javascript:void(0);" title="選択項目を削除" data-toggle="tooltip" class="btn btn-default" id="btnDelete">選択項目を削除</a>
			{/if}
		</div>
	</div>

	<div class="rules_div">
		<div class="wrap">
			<form id="formTemplate" method="post" accept-charset="utf-8" enctype="multipart/form-data">
				<table id="tblTemplate" class="table table-striped table-bordered tablesorter">
					<colgroup>
						{if $delete_flag}
							<col width="5%">
						{/if}
						<col width="5%">
						<col width="25%">
						<col width="25%">
						<col width="15%">
						<col width="15%">
						<col width="10%">
					</colgroup>

					<thead class="head">
					<tr>
						{if $delete_flag}
							<th class="remove sorter-false filter-false alignCenter"></th>
						{/if}
						<th class="alignCenter tablesorter-headerUnSorted">NO</th>
						<th class="alignCenter tablesorter-headerDesc">名称</th>
						<th class="alignCenter tablesorter-headerUnSorted">説明</th>
						<th class="alignCenter tablesorter-headerUnSorted">作成日時</th>
						<th class="alignCenter tablesorter-headerUnSorted">作成者</th>
						<th class="remove sorter-false filter-false alignCenter">アクション</th>
					</tr>
					</thead>
					<tbody class="inner_table">
					</tbody>
				</table>
				<!-- pager -->
				{$view->element('pager/pager')}
			</form>
		</div>
	</div>

	{$sortColumnTemplate}
	{$sortTypeTemplate}
	<input type="hidden" value="{if isset($sortColumn)}{$sortColumn}{/if}" id="hdSortColumnTemplate"/>
	<input type="hidden" value="{if isset($sortType)}{$sortType}{/if}" id="hdSortTypeTemplate"/>
	<input type="hidden" value="{if isset($page)}{$page}{/if}" id="hdPageTemplate"/>

	<!-- インポートのMODAL START-->
	<div class="modal fade" id="dialog_area" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true" data-backdrop="static">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">×</button>
					<h4 class="modal-title" id="myModalLabel">インポート</h4>
				</div>
				<div class="modal-body">
					<div class="error" id="error-mgs"></div>
					<div class="success-mgs" id="success-mgs"></div>
					<form action="{Router::url('', true)}" class="dropzone" id="my-dropzone" method="post" enctype="multipart/form-data">
						<div class="dz-default dz-message"><span>ファイルをドラッグ</span></div>
						<div class="files" id="previews"></div>
						<div id="error_files" class="data_csv_error_div error" style="display:none; width:100%; height:100px; border: solid 1px black;  overflow-y: scroll;" ></div>
						<a href="javascript:void(0);" id="copyErrorBtn" style="display:none;" data-clipboard-target="#error_files">コピー</a> <!-- 20160224 Edit by Giang : add '0' before tel_num if first character isnot '0' -->
					</form>
				</div>
				<div class="modal-footer">
					<a href="#" class="btn btn-primary" id="submit-import">インポート</a>
				</div>
			</div>
		</div>
	</div>
	<!-- インポートのMODAL END-->

<!-- content ends -->
</div>