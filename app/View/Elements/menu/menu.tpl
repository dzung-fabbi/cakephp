{html func=script url='view/menu/menu'}
{html func=script url='jquery.validate'}
<!-- left menu starts -->
<div class="row">
	<div class="col-sm-2 col-lg-2">
		<div class="sidebar-nav">
			<div class="nav-canvas">
				<div class="nav-sm nav nav-stacked">

				</div>
				{if !(isset($data_hide_menu['outbound']) && $data_hide_menu['outbound'] == 1)}
				<ul class="nav nav-pills nav-stacked main-menu">
					<li class="nav-header"><i class="glyphicon glyphicon-circle-arrow-right"></i><span>アウトバウンド</li>
					<li {if $controller eq "template"}class="active"{/if}><a class="ajax-link" href="javascript:void(0);" id="lnkOutboundTemplate"><i class="glyphicon glyphicon-list-alt"></i><span> テンプレート</span></a></li>
					<li {if $controller eq "calllist"}class="active"{/if}><a class="ajax-link" href="javascript:void(0);" id="lnkCallList"><i class="glyphicon glyphicon-list"></i><span> 発信リスト</span></a></li>
					<!-- 20160226 Add by Giang : #6532 - add menu call_list_ng -->
					<li {if $controller eq "calllistng"}class="active"{/if}><a class="ajax-link" href="javascript:void(0);" id="lnkCallListNg"><i class="glyphicon glyphicon-list"></i><span> 発信NGリスト</span></a></li>
					<li {if $controller eq "outschedule"}class="active"{/if}><a class="ajax-link" href="javascript:void(0);" id="lnkOutSchedule"><i class="glyphicon glyphicon-calendar"></i><span> スケジュール</span></a></li>
				</ul>
				{/if}
				{if !(isset($data_hide_menu['inbound']) && $data_hide_menu['inbound'] == 1)}
				<ul class="nav nav-pills nav-stacked main-menu">
					<li class="nav-header"><i class="glyphicon glyphicon-circle-arrow-left"></i>インバウンド</li>
					<li {if $controller eq "inboundtemplate"}class="active"{/if}><a class="ajax-link" href="javascript:void(0);" id="lnkInboundTemplate"><i class="glyphicon glyphicon-list-alt"></i><span> テンプレート</span></a></li>
					<li {if $controller eq "inboundcalllist"}class="active"{/if}><a class="ajax-link" href="javascript:void(0);" id="lnkInboundCallList"><i class="glyphicon glyphicon-list"></i><span> 着信リスト</span></a></li>
					<li {if $controller eq "inboundincominghistory"}class="active"{/if}><a class="ajax-link" href="javascript:void(0);" id="lnkInboundIncomingHistory"><i class="glyphicon glyphicon-book"></i><span> 着信設定</span></a></li>
					<li {if $controller eq "inboundrestrict"}class="active"{/if}><a class="ajax-link" href="javascript:void(0);" id="lnkInboundRestrictIncoming"><i class="glyphicon glyphicon-list"></i><span> 着信拒否リスト</span></a></li>
				</ul>
				{/if}
				{if !(isset($data_hide_menu['sms']) && $data_hide_menu['sms'] == 1)}
				<!-- 20160420 Add by Ascend-Hung : #7017 - Add SMS Menu -->
				<ul class="nav nav-pills nav-stacked main-menu">
					<li class="nav-header"><i class="glyphicon glyphicon-circle-arrow-right"></i><span>SMS</li>
					<li {if $controller eq "smstemplate"}class="active"{/if}><a class="ajax-link" href="javascript:void(0);" id="lnkSmsTemplate"><i class="glyphicon glyphicon-list-alt"></i><span> テンプレート</span></a></li>
					<li {if $controller eq "smssendlist"}class="active"{/if}><a class="ajax-link" href="javascript:void(0);" id="lnkSmsSendList"><i class="glyphicon glyphicon-book"></i><span> 送信リスト</span></a></li>	
					<li {if $controller eq "smsschedule"}class="active"{/if}><a class="ajax-link" href="javascript:void(0);" id="lnkSmsSchedule"><i class="glyphicon glyphicon-calendar"></i><span> スケジュール</span></a></li>
				</ul>
				{/if}
				{if $enable_manage_account || $enable_list_manageuser || $enable_manage_menu || enable_download_result}
					<ul class="nav nav-pills nav-stacked main-menu">
						<li class="nav-header"><i class="glyphicon glyphicon-cog"></i>管理</li>
						{if $enable_manage_account}
							<li {if $controller eq "manageaccount"}class="active"{/if}><a class="ajax-link" href="javascript:void(0);" id="lnkManageAccount"><i class="glyphicon glyphicon-wrench"></i><span> アカウント管理</span></a></li>
						{/if}
						{if $enable_list_manageuser}
							<li {if $controller eq "manageuser"}class="active"{/if}><a class="ajax-link" href="javascript:void(0);" id="lnkManageUser"><i class="glyphicon glyphicon-user"></i><span> ユーザー管理</span></a></li>
						{/if}
						{if $enable_manage_menu}
							<li {if $controller eq "managemenu"}class="active"{/if}><a class="ajax-link" href="javascript:void(0);" id="lnkManageMenu"><i class="glyphicon glyphicon-menu-hamburger"></i><span> メニュー管理</span></a></li>
						{/if}
						{if $enable_download_result}
							<li {if $controller eq "downloadresult"}class="active"{/if}><a class="ajax-link" href="javascript:void(0);" id="lnkDownloadResult"><i class="glyphicon glyphicon glyphicon-download"></i><span> 結果ログ一括DL</span></a></li>
						{/if}
						{*
						<li {if $controller eq "manageratedetails"}class="active"{/if}><a class="ajax-link" href="javascript:void(0);" id="lnkManageRateDetails"><i class="glyphicon glyphicon-briefcase"></i><span> 料金明細</span></a></li>
						<li {if $controller eq "managenews"}class="active"{/if}><a class="ajax-link" href="javascript:void(0);" id="lnkManageNews"><i class="glyphicon glyphicon-lock"></i><span> ニュース管理</span></a></li>
						<li {if $controller eq "managepassword"}class="active"{/if}><a class="ajax-link" href="javascript:void(0);" id="lnkManagePassword"><i class="glyphicon glyphicon-lock"></i><span> パスワード変更</span></a></li>
						*}
					</ul>
				{/if}
				<ul class="nav nav-pills nav-stacked main-menu">
					<li class="nav-header"><i class="glyphicon glyphicon-cog"></i>マニュアルダウンロード</li>
					<li><a class="ajax-link" href="javascript:void(0);" id="lnkDownloadManual"><i class="glyphicon glyphicon-file"></i><span> 操作マニュアル</span></a></li>
					<li><a class="ajax-link" href="javascript:void(0);" id="lnkDownloadClearCacheGuide"><i class="glyphicon glyphicon-file"></i><span> キャッシュ削除マニュアル</span></a></li>
				</ul>
			</div>
		</div>
	</div>
	<!--/span-->
	<!-- left menu ends -->
