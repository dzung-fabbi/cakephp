<!DOCTYPE html>
<html>
<head>
	<meta charset = "UTF-8">
	<meta http-equiv="X-UA-Compatible" content="IE=Edge">
	<meta name="robots" content="noindex, nofollow">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<title>ロボットコールセンター</title>
	<script type='text/javascript'>
		var appRoot = "{$appRoot}/";
	</script>
	
	<!-- CSS -->
	{html func=css path='common/bootstrap'}
	{html func=css path='common/charisma-app'}
	{*html func=css path='chosen/chosen.min'*}
	{html func=css path='chosen/chosen'}
	{html func=css path='colorbox/example3/colorbox'}
	{html func=css path='responsive-tables/responsive-tables'}
	{html func=css path='common/jquery.noty'}
	{html func=css path='common/noty_theme_default'}
	{html func=css path='common/elfinder.min'}
	{html func=css path='common/elfinder.theme'}
	{html func=css path='common/jquery.iphone.toggle'}
	{html func=css path='common/uploadify'}
	{html func=css path='common/animate.min'}
	{html func=css path='common/style'}
	<!-- jQuery -->
	{*html func=script url='jquery.min'*}
	{html func=script url='jquery-1.11.2'}
	{html func=script url='jquery-ui'}
	
	<!-- external javascript -->
	{html func=script url='bootstrap.min'}
	<!-- library for cookie management -->
	{html func=script url='jquery.cookie'}
	<!-- calender plugin -->
	{html func=script url='moment/min/moment.min'}
	{html func=script url='fullcalendar/dist/fullcalendar.min'}
	<!-- data table plugin -->
	{html func=script url='jquery.dataTables.min'}
	<!-- select or dropdown enhancer -->
	{html func=script url='chosen/chosen.jquery.min'}
	<!-- plugin for gallery image view -->
	{html func=script url='colorbox/jquery.colorbox-min'}
	<!-- notification plugin -->
	{html func=script url='jquery.noty'}
	<!-- library for making tables responsive -->
	{html func=script url='responsive-tables/responsive-tables'}
	<!-- tour plugin -->
	{html func=script url='bootstrap-tour/build/js/bootstrap-tour.min'}
	<!-- star rating plugin -->
	{html func=script url='jquery.raty.min'}
	<!-- for iOS style toggle switch -->
	{html func=script url='jquery.iphone.toggle'}
	<!-- autogrowing textarea plugin -->
	{html func=script url='jquery.autogrow-textarea'}
	<!-- multiple file upload plugin -->
	{html func=script url='jquery.uploadify-3.1.min'}
	<!-- history.js for cross-browser state change on ajax -->
	{html func=script url='jquery.history'}
	<!-- application script for Charisma demo -->
	{html func=script url='charisma'}
	
	{html func=script url='jquery-ui-timepicker-addon'}
	{*html func=script url='jquery.multiselect'*}
	{html func=script url='jquery-ui-datetimepicker-localization'}
	{*html func=script url='date'*}
	{*html func=script url='jquery-ui.multidatespicker.js'*}

	{html func=script url='jquery.blockUI'}
	{html func=script url='common/util'}
	{html func=script url='common/messages'}

	<!-- Tablesorter -->
	{html func=css path='common/theme.gold.css'}
	{html func=script url='jquery.tablesorter'}
	{html func=script url='jquery.tablesorter.widgets'}
	{html func=script url='jquery.tablesorter.widget-cssStickyHeaders'}

	<!-- Tablesorter pager -->
	{html func=css path='common/jquery.tablesorter.pager.css'}
	{html func=script url='jquery.tablesorter.pager'}

	<!-- clipboard.min.js -->
	{html func=script url='clipboard.min'}
	
	{html func=css path='menu/menu'}
	{html func=script url='view/menu/menu'}
</head>

<body>
	{if $controller neq 'login'}
		<div class="navbar navbar-default" role="navigation">
			{$view->element('header/header')}
		</div>
	{/if}
	<div class="ch-container">
		{if $controller neq 'login'}
			{if (isset($hide_menu_flag) && $hide_menu_flag)}
				<div id="menu_blank"></div>
			{else}
				{$view->element('menu/menu')}
			{/if}
		{/if}
		{$content_for_layout}
		{$view->element('debug/sql_dump')}
		<div id="current_controller" style="display:none;">{$controller}</div>
		<div id="current_action" style="display:none;">{$current_action}</div>
	</div><!--/.fluid-container-->
	{if $controller neq 'login'}
		<div id="footer">
			{$view->element('footer/footer')}
		</div>
	{/if}
</body>

</html>
