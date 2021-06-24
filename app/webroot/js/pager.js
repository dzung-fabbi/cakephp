var pagerOptions = {
	ajaxUrl: null,
	customAjaxUrl: function(table, url) { return url; },
	ajaxProcessing: function(ajax){
		if (ajax && ajax.hasOwnProperty('data')) {
			return [ ajax.total_rows, ajax.data ];
		}
	},
	output: '全 {totalRows} レコード　{startRow:input} ～ {endRow}',
	updateArrows: true,
	page: 0,
	size: 20,
	savePages : true,
	storageKey:'tablesorter-pager',
	fixedHeight: true,
	removeRows: false,
	cssNext: '.next',
	cssPrev: '.prev',
	cssFirst: '.first',
	cssLast: '.last',
	cssGoto: '.gotoPage',
	cssPageDisplay: '.pagedisplay',
	cssPageSize: '.pagesize',
	cssDisabled: 'disabled',
	cssErrorRow: 'tablesorter-errorRow'
};