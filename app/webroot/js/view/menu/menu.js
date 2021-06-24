$(document).ready(function() {
	{
		$('.alert .close').on('click', function(e) {
			$(this).parent().hide();
		});
	}
	$('#lnkOutgoingNumber').click(function(){
		window.location.href = appRoot+"OutgoingNumber/index/";
	});
	$('#lnkNumberManage').click(function(){
		window.location.href = appRoot+"NumberManage/index/";
	});
	$('#lnOutSchedule').click(function(){
		window.location.href = appRoot+"OutSchedule/index/";
	});
	$('#lnkRejectIncomingCall').click(function(){
		window.location.href = appRoot+"RejectIncomingCall/index/";
	});
	$('#lnkCallRecord').click(function(){
		window.location.href = appRoot+"CallRecord/index/";
	});
	$('#lnkUserManage').click(function(){
		window.location.href = appRoot+"UserManage/index/";
	});
	$('#lnkCallList').click(function(){
		window.location.href = appRoot+"CallList/index/";
	});
	/* 20160226 Add by Giang : #6532 - menu call list ng - start */
	$('#lnkCallListNg').click(function(){
		window.location.href = appRoot+"CallListNg/index/";
	});
	/* 20160226 Add by Giang : #6532 - menu call list ng - end */
	$('#lnkScript').click(function(){
		window.location.href = appRoot+"Template/index/";
	});
	$('#lnkOutSchedule').click(function(){
		window.location.href = appRoot+"OutSchedule/index/";
	});
	$('#lnkCallBack').click(function(){
		window.location.href = appRoot+"CallBack/index/";
	});
	$('#lnkRDD').click(function(){
		window.location.href = appRoot+"RDD/index";
	});
	$('#lnkPasswordChange').click(function(){
		window.location.href = appRoot+"PasswordChange/index/";
	});

	/*** 新デザインリンク ***/
	// ホーム
	/*$('#lnkHome, #lnkHeadHome').click(function(){
		window.location.href = appRoot+"Menu/index/";
	});*/
	/*** アウトバウンド ***/
	// テンプレート
	$('#lnkOutboundTemplate').click(function(){
		window.location.href = appRoot+"Template/index/";
	});
	// リスト作成
	$('#lnkOutboundCreateList').click(function(){
		window.location.href = appRoot+"OutboundCreateList/index/";
	});
	// スケジュール
	$('#lnkOutboundSchedule').click(function(){
		window.location.href = appRoot+"OutboundSchedule/index/";
	});
	// 発信NGリスト
	$('#lnkOutboundRestrictList').click(function(){
		window.location.href = appRoot+"OutboundRestrictList/index/";
	});
	/*** インバウンド ***/
	// テンプレート
	$('#lnkInboundTemplate').click(function(){
		window.location.href = appRoot+"InboundTemplate/index/";
	});
	$('#lnkInboundCallList').click(function(){
		window.location.href = appRoot+"InboundCallList/index/";
	});
	// 着信拒否リスト
	$('#lnkInboundRestrictIncoming').click(function(){
		window.location.href = appRoot+"InboundRestrict/index/";
	});
	// 着信履歴
	$('#lnkInboundIncomingHistory').click(function(){
		window.location.href = appRoot+"InboundIncomingHistory/index/";
	});
	/*** 管理 ***/
	// アカウント管理
	$('#lnkManageAccount').click(function(){
		window.location.href = appRoot+"ManageAccount/index/";
	});
	// ユーザー管理
	$('#lnkManageUser').click(function(){
		window.location.href = appRoot+"ManageUser/index/";
	});
	// メニュー管理
	$('#lnkManageMenu').click(function(){
		window.location.href = appRoot+"ManageMenu/index/";
	});
	// 結果ログ一括DL
	$('#lnkDownloadResult').click(function(){
		window.location.href = appRoot+"DownloadResult/index/";
	});
	// 料金明細
	$('#lnkManageRateDetails').click(function(){
		window.location.href = appRoot+"ManageRateDetails/index/";
	});
	// ニュース管理
	$('#lnkManageNews').click(function(){
		window.location.href = appRoot+"ManageNews/index/";
	});
	// パスワード変更
	$('#lnkManagePassword').click(function(){
		window.location.href = appRoot+"ManagePassword/index/";
	});

	$('#lnkDownloadManual').click(function(){
		window.location.href = appRoot+"Menu/download_manual/";
	});
	$('#lnkDownloadClearCacheGuide').click(function(){
		window.location.href = appRoot+"Menu/download_clear_cache_guide/";
	});

	$('#lnkSmsTemplate').click(function() {
		window.location.href = appRoot + "SmsTemplate/index/";
	});

	$('#lnkSmsSendList').click(function(){
		window.location.href = appRoot+"SmsSendList/index/";
	});

	$('#lnkSmsSchedule').click(function(){
		window.location.href = appRoot+"SmsSchedule/index/";
	});


	$(".rightBox").css({height:($(window).height()-110)+"px"});
	$("#menu_container").css({height:($(window).height()-110)+"px"});

	$(window).resize(function(){
		$(".rightBox").css({height:($(window).height()-110)+"px"});
		$("#menu_container").css({height:($(window).height()-110)+"px"});
	});
});