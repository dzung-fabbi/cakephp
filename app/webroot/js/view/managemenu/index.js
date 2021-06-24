$(document).ready(function() {

	var page = 0, column = [[0,0]];

	if($("#hdPageList").val()){
		page = parseInt($("#hdPageList").val());
	}
	if($("#hdSortColumnList").val() && $("#hdSortTypeList").val()){
		column = [[parseInt($("#hdSortColumnList").val()), parseInt($("#hdSortTypeList").val())]];
	}
	$("#userListTable").tablesorter({
		theme: 'gold',
		widthFixed: true,
		sortLocaleCompare: true,
		sortList: column,
		widgets: ['zebra', 'filter'],
	}).tablesorterPager({
		container: $(".pager"),
		type: "POST",
		ajaxUrl: appRoot + "ManageMenu/hide_menu_list/{page}/20/{sortList:column}?{filterList:filter}",
		ajaxObject: {
			cache: false,
			dataType: 'json'
		},
		ajaxProcessing: function(data){
			if (data && data.hasOwnProperty('rows')) {
				var indx, r, row, c, d = data.rows,
				total = data.total_rows,
				headers = data.headers,
				headerXref = headers.join(',').replace(/\s+/g,'').split(','),
				rows = [],
				len = d.length;
				for ( r=0; r < len; r++ ) {
					row = [];
					for ( c in d[r] ) {
						if (typeof(c) === "string") {
							indx = $.inArray( c, headerXref );
							if (indx >= 0) {
								row[indx] = d[r][c];
							}
						}
					}
					rows.push(row);
				}
				return [ total, rows ];
			}
		},
		output: '全 {totalRows} レコード　{startRow} ～ {endRow}',
		updateArrows: true,
		page: page,
		savePages: false,
		size: 20,
		fixedHeight: false,
		removeRows: false,
		cssNext        : '.next',
		cssPrev        : '.prev',
		cssFirst       : '.first',
		cssLast        : '.last',
		cssPageDisplay : '.pagedisplay',
		cssPageSize    : '.pagesize',
		cssErrorRow    : 'tablesorter-errorRow',
		cssDisabled    : 'disabled'
	});

	$('#btnSave').click(function() {
		var err_flag = false;
		$('#userListTable tbody tr').each(function(){
			if ($(this).find('.cbHide:checked').size() == 0) {
				err_flag = true;
			}
		});

		if (err_flag) {
			alert(MSG_ERROR_MUST_CHECK);
			return;
		}

		if (confirm(MSG_CONFIRM_SAVE)) {
			display_load();
			var delete_items = [];
			$('.cbHide:checked').each(function () {
				if (typeof $(this).attr('t94_id') !== 'undefined') {
					delete_items.push($(this).attr('t94_id'));
				}
			});

			var add_items = {};
			$('.cbHide:not(:checked)').each(function () {
				var company_id = $(this).attr('company_id');
				var item_id = $(this).attr('item_id');
				if (typeof $(this).attr('t94_id') == 'undefined') {
					if (typeof add_items[company_id] == 'undefined') {
						add_items[company_id] = [];
					}
					add_items[company_id].push(item_id);
				}
			});

			$.ajax({
				type: "POST",
				url: appRoot + "ManageMenu/save",
				data: {
					type: 'ajax',
					delete_items: delete_items,
					add_items: add_items
				},
				success: function (data) {
					$.unblockUI();
					if (data == "true") {
						window.location.href = appRoot+"ManageMenu/index/success";
					} else {
						alert(MSG_ALERT_SYSTEM_ERROR);
						window.location.href = appRoot + "ManageMenu/index/";
					}
				}
			});
		}
	});
});