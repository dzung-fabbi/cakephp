{html func=css path='downloadresult/index'}
{html func=css path='common/jquery-ui.css'}
{html func=script url='view/downloadresult/index'}

<div class="col-lg-10 col-sm-10" id="content">
<!-- content starts -->
	<div class="rules_div">
		<div class="wrap">
			<form id="form_download_result" method="post" action="{Router::url('', true)}" accept-charset="utf-8" enctype="multipart/form-data">
				<div class="form-group">
					<label class="col-sm-3 control-label">区分</label>
					<div class="form-group col-sm-7">
						<select id="division" name="division" class="form-control" data-previous-selected="">
							<option value=""></option>
							{foreach from=$divisions key=division_code item=division_name}
								<option value="{$division_code}">{$division_name}</option>
							{/foreach}
						</select>
					</div>
				</div>
				<div class="form-group">
					<label class="col-sm-3 control-label">アカウント</label>
					<div class="form-group col-sm-7">
						<select id="company_id" name="company_id" class="form-control">
							<option value=""></option>
							{foreach from=$accounts item=values}
								<option value="{$values.M02Company.company_id}">{$values.M02Company.company_name}</option>
							{/foreach}
						</select>
					</div>
				</div>
				<div class="form-group">
					<label class="col-sm-3 control-label label_tel outbound inbound">電話番号</label>
					<label class="col-sm-3 control-label label_tel sms">通知番号</label>
					<div class="form-group col-sm-7">
						<select id="tel_number" name="tel_number" class="form-control">
							<option value=""></option>
						</select>
					</div>
				</div>


				<div class="form-group">
					<label class="col-sm-3 control-label">日付</label>
					<div class="col-sm-3">
						<div class="form-group date">
							<input type="text" id="expired_date_from" name="expired_date_from"
								   class="form-control expired" placeholder="yyyy-mm-dd" readonly aria-invalid="false"/>
							<label class="input-group-btn" for="expired_date_from">
								<span class="btn btn-default ui-datepicker-trigger date_picker_btn" id="date_picker_btn1">
									<span class="glyphicon glyphicon-calendar"></span>
								</span>
							</label>
						</div>
						<div>
							<label id="expired_date_from-error" class="my_error" for="expired_date_from"></label>
							<label id="expired_error" style="color:red;"></label>
						</div>
					</div>

					<div class="col-sm-1 ptop7" style="text-align:center;">～</div>
					<div class="col-sm-3">
						<div class="form-group date">
							<input type="text" id="expired_date_to" name="expired_date_to"
								   class="form-control expired" placeholder="yyyy-mm-dd" readonly aria-invalid="false"/>
							<label class="input-group-btn" for="expired_date_to">
								<span class="btn btn-default ui-datepicker-trigger date_picker_btn" id="date_picker_btn2">
									<span class="glyphicon glyphicon-calendar"></span>
								</span>
							</label>
						</div>
						<div><label id="expired_date_to-error" class="my_error" for="expired_date_to"></label></div>
					</div>
				</div>
				<div class="form-group">
					<div class="form-group col-sm-10">
						<button type="button" class="btn btn-primary pull-right" id="btnDownload">ダウンロード</button>
					</div>
				</div>
			</form>
		</div>
	</div>
<!-- content ends -->
</div>