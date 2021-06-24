{html func=script url='view/header/header'}
<div class="navbar-inner">
	<button type="button" class="navbar-toggle pull-left animated flip">
		<span class="sr-only">Toggle navigation</span>
		<span class="icon-bar"></span>
		<span class="icon-bar"></span>
		<span class="icon-bar"></span>
	</button>
	
	<a class="navbar-brand" href="javascript:void(0);" {*id="lnkHeadHome"*} style="cursor:default;"><div class="headerLogo"></div></a>
	
	<!-- ユーザー プルダウン starts -->
	<div class="btn-group pull-right">
		<button class="btn btn-default dropdown-toggle" data-toggle="dropdown">
			<i class="glyphicon glyphicon-user"></i><span class="hidden-sm hidden-xs">{$userName}</span>
			<span class="caret"></span>
		</button>
		<ul class="dropdown-menu">
			<!--li class="divider"></li-->
			<li><a href="javascript:void(0);" id="lnkLogout">ログアウト</a></li>
		</ul>
	</div>
	<!-- ユーザー プルダウン ends -->
	
	<!-- 会社名 starts -->
		<div class="btn-group pull-right">
			{if ($companies
				&& ($controller eq "menu"
					|| ($controller eq 'template' && $current_action neq 'template')
					|| ($controller eq 'calllist' && $current_action neq 'detail')
					|| ($controller eq 'outschedule' && $current_action neq 'status')
					|| ($controller eq 'calllistng' && $current_action neq 'detail')
					|| ($controller eq 'inboundrestrict' && $current_action neq 'detail')
					|| ($controller eq 'inboundtemplate' && $current_action eq 'index')
					|| ($controller eq 'inboundcalllist' && $current_action eq 'index')
					|| ($controller eq 'inboundincominghistory' && $current_action eq 'index')
					|| ($controller eq 'smstemplate' && $current_action eq 'index')
					|| ($controller eq 'smssendlist' && $current_action eq 'index')
					|| ($controller eq 'smsschedule' && $current_action eq 'index')
				)
			)}
				<select id="changeCompany" class="form-control btn btn-default pull-right" onchange="changeCompany();" data-rel="searchable">
					{foreach from=$companies item=company}
						<option value={$company['M02Company']['company_id']} {if $this->Session->read('company_id') == $company['M02Company']['company_id']}selected{/if}>{$company['M02Company']['company_name']}</option>
					{/foreach}
				</select>
			{else}
				<span class="header-span">{$company_name['M02Company']['company_name']}</span>
			{/if}
			<span class="header-span">{$postName}</span>
		</div>
	<!-- 会社名 ends -->

	<div class="collapse navbar-collapse nav navbar-nav top-menu">
	</div>
	
</div>