$(document).ready(function() {
	{
		var page = 0, column = [[1,1]];
		if(!$("#btnDelete").length){
			column = [[0,1]];
		}
		if($("#hdPageTemplate").val()){
			page = parseInt($("#hdPageTemplate").val());
		}
		if($("#hdSortColumnTemplate").val() && $("#hdSortTypeTemplate").val()){
			column = [[parseInt($("#hdSortColumnTemplate").val()), parseInt($("#hdSortTypeTemplate").val())]];
		}
		$("#tblTemplate").tablesorter({
			theme: 'gold',
			widthFixed: true,
			sortLocaleCompare: true,
			sortList: column,
			widgets: ['zebra', 'filter'],
			sortMultiSortKey: null
		}).tablesorterPager({
			container: $(".pager"),
			type: "POST",
            async: false,
			ajaxUrl: appRoot + "InboundTemplate/arr_template/{page}/20/{sortList:column}?{filterList:filter}",
			ajaxObject: {
				cache: false,
				dataType: 'json',
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
			processAjaxOnInit: true,
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
	    // $('.tablesorter-filter').last().addClass('disabled').attr('disabled', true);
	}

    if($("#hdPageTemplate").val()){
        page = parseInt($("#hdPageTemplate").val());
    }

    if($("#hdSortColumnTemplate").val() && $("#hdSortTypeTemplate").val()){
        column = [[parseInt($("#hdSortColumnTemplate").val()), parseInt($("#hdSortTypeTemplate").val())]];
    }

	$("#btnCreate").click(function() {
		window.location.href = appRoot+"InboundTemplate/template/"
	});
	$("#btnUpdate").click(function() {
		window.location.href = appRoot+"InboundTemplate/index/"
	});
	$(document).on('click', '.btnEdit', function () {
		var template_id = $(this).attr("template_id");
		$.ajax({
			type: "POST",
	        url:appRoot+"InboundTemplate/check_exist_template/",
	        async: false,
	        data: {
	        	template_id: template_id,
	        },
	        success:function(data){
	         	if(data == "err_not_exist"){
	         		alert("対象テンプレートは削除されています。")
	           		location.reload();
	         		return;
	           	}else{
	           		$("<input>",{type: "hidden",name: "template_id",value: template_id}).appendTo("#formTemplate");
	           		$("<input>",{type: "hidden",name: "action",value: "update"}).appendTo("#formTemplate");
	        		var url=appRoot+"InboundTemplate/template";
	        		display_load();
	        		$("#formTemplate").attr('action', url);
	        		$("#formTemplate").attr('method', 'post');
	        		$("#formTemplate").attr('enctype', 'multipart/form-data');
	        		$("#formTemplate").submit();
	           	}
	        },
	    });
	});

	$(document).on('click', '.btnDuplicate', function () {
		var template_id = $(this).attr("template_id");
		$.ajax({
			type: "POST",
	        url:appRoot+"InboundTemplate/check_exist_template/",
	        async: false,
	        data: {
	        	template_id: template_id,
	        },
	        success:function(data){
	         	if(data == "err_not_exist"){
	         		alert("対象テンプレートは削除されています。")
	           		location.reload();
	         		return;
	           	}else{
	           		$("<input>",{type: "hidden",name: "template_id",value: template_id}).appendTo("#formTemplate");
	           		$("<input>",{type: "hidden",name: "action",value: "duplicate"}).appendTo("#formTemplate");
	        		var url=appRoot+"InboundTemplate/template";
	        		display_load();
	        		$("#formTemplate").attr('action', url);
	        		$("#formTemplate").attr('method', 'post');
	        		$("#formTemplate").attr('enctype', 'multipart/form-data');
	        		$("#formTemplate").submit();
	           	}
	        },
	    });
	});

	$(document).on('click', '#btnDelete', function () {
		if ($('input[type="checkbox"]:checked').size() < 1) {
			//alert(MSG_ALERT_PLS_CHOOSE_TEMPLATE);
			$('#template-error-message').find('p').text(MSG_ALERT_PLS_CHOOSE_TEMPLATE);
			$('#template-error-message').show();
			return false;
		}
		var template_ids = new Array();
		$('input[type="checkbox"]:checked' ).each(function(){
			template_ids.push($(this).attr("template_id"));
		});

		$.ajax({
			type: "POST",
			url:appRoot+"InboundTemplate/check_delete_template/",
	        data: {
	        	template_ids: template_ids,
	        },
	        async: false,
	        success:function(data){
	        	var result = JSON.parse(data);
				var status = result['status'];

				if(status == "err_not_exist"){
					//20160325 Edit by Thai : change check when delete inbound template - Begin
					$('#template-error-message').find('p').text("対象テンプレートは存在していません。");
					$('#template-error-message').show();
					return;
				} else if (status == "err_exist_setting_inbound"){
	           		//alert("選択したテンプレートは予定されているスケジュールに使用される為、削除できません。")
					$('#template-error-message').find('p').text("現在、設定されているテンプレートのため、削除できません。");
					//20160325 Edit by Thai : change check when delete inbound template - End
					$('#template-error-message').show();
	         		return;
	           	}else{
	           		if(confirm("テンプレートを削除します。よろしいですか？")){
		    			display_load();

		    			var url=appRoot+"InboundTemplate/delete";
		    			$("#formTemplate").attr('action', url);
		    			$("#formTemplate").attr('method', 'post');
		    			$("#formTemplate").attr('enctype', 'multipart/form-data');

		    			$('input[type="checkbox"]:checked').each(function() {
							var template_ids = document.createElement("input");
							template_ids.type = 'hidden';
							template_ids.name = 'template_ids[]';
							template_ids.value = $(this).attr("template_id");
							$("#formTemplate").append(template_ids);
						});
		    			$("#formTemplate").submit();
	        		} else {
	        			return;
	        		}
	           	}
	        },
	    });
	});

	/*$('#dialog_area').dialog({
		title: 'インポート',
		height:500,
		width: 930,
		modal: true,
		autoOpen: false,
		resizable: false,
	});*/

	Dropzone.options.myDropzone = {
		url: appRoot + 'InboundTemplate/import',
		paramName: "files",
		autoProcessQueue: false,
		uploadMultiple: false,
		parallelUploads: 50,
		maxFiles: 1,
		maxFilesize: 30,
		previewsContainer: "#previews",
		dictDefaultMessage: 'Add files to upload by clicking or dropping them here.',
		addRemoveLinks: true,
		dictRemoveFile: 'ファイル削除',
		maxfilesexceeded: function(file) {
			this.removeAllFiles();
			this.addFile(file);
			$('.error').html('');
			$('.success-mgs').html('');
			$('#copyErrorBtn').css('display', 'none');
			$('#error_files').css('display', 'none');
		},
		accept: function(file, done) {
			var re = /(?:\.([^.]+))?$/;
			var ext = re.exec(file.name)[1];
			var type = ["zip"];
			var validType = ['application/zip', 'application/octet-stream', 'application/x-zip-compressed'];
            if (validType.indexOf(file.type) == -1 && file.type != '' ||  type.indexOf(ext) == -1) {
                done("Error! Files of this type are not accepted");
            } else {
     			done();
            }
        },
		init: function() {
			myDropzone = this;
			var submitButton = document.querySelector("#submit-import");
			submitButton.addEventListener("click", function(e) {
				e.preventDefault();
				e.stopPropagation();

				if (!beforeSubmit(myDropzone)) {
					return false;
				}
			});

			this.on("sending", function(file, xhr, formData) {
				console.log("Attach data start");
			});

			this.on("addedfile", function(file) {
	        	if (this.files.length > 1) {
	        		this.removeFile(this.files[0]);

					$('.error').html('');
					$('.success-mgs').html('');
					$('#copyErrorBtn').css('display', 'none');
					$('#error_files').css('display', 'none');
	        	}
			});

			this.on("removedfile", function(file) {
				$('.error').html('');
				$('.success-mgs').html('');
				$('#copyErrorBtn').css('display', 'none');
				$('#error_files').css('display', 'none');
			});
		},
		success: function(file, response) {
			if(response.code == 200) {
				return location.reload();
			} else {
				$('.success-mgs').html('');
				$('#error_files').html(response.message);
				$('#error_files').show();
				$('#copyErrorBtn').attr("data-clipboard-text", response.message.replace(/\<br\\?>/g, "\n"));
				new Clipboard('#copyErrorBtn');
				$('#copyErrorBtn').show();
			}
		}
	};

	$(document).on('click', '#copyErrorBtn', function () {
		alert('コピーしました');
	});

	function clear_form_data(response){
		if(response.status == 'success'){
			$('.success-mgs').html(response.message);
			$('.error').html('');

			$('#previews').html('');
		} else if(response.status == 'error'){
			$('.success-mgs').html('');
			$('.error').html(response.message);
		}
	}

	function beforeSubmit(myDropzone) {
		if (myDropzone.files.length) {
			if (myDropzone.files.length == 1) {
				myDropzone.processQueue();
				return true;
			} else {
				alert('1回に2つのファイルがアップロードできません。');
			}
		} else {
			alert('ファイルが選択されていません。');
		}
		return false;
	}

	$('#btnImportTemplate').click(function (e) {
		//$('#dialog_area').dialog('open');
		e.preventDefault();
		//$('#importModal').modal('show');
		$('#dialog_area').modal('show');
	});

	$(document).on('click', '.btnDownload', function () {
		var template_id = $(this).attr('template_id');
		$.ajax({
			type: "POST",
			url: appRoot+"InboundTemplate/check_exist_template/",
			data: {
				template_id: template_id,
			},
			async: false,
			success:function(data){
				console.log(data);
				if(data == "err_not_exist"){
					alert(MSG_ALERT_NO_EXIST_TEMPLATE);
					location.reload();
					return;
				}else{
					display_load();
					var url=appRoot+"InboundTemplate/buffer_template_data";
					$.ajax({
						url: url,
						type: "post",
						data: {
							template_id: template_id,
						},
						success: function(result){
							if(result == "success"){
								window.location.href = appRoot + "InboundTemplate/download_file/" + template_id;
							} else if (result == 'err_exist_question_inbound_sms') {
								alert(INBOUND_EXPORT_EXIST_QUESTION_SMS);
								location.reload();
								return;
							} else if (result == 'err_exist_question_inbound_collation') {
								alert(INBOUND_EXPORT_EXIST_QUESTION_INBOUND_COLLATION);
								location.reload();
								return;
							} else if (result == 'err_exist_question_property_search') {
								alert(INBOUND_EXPORT_EXIST_QUESTION_PROPERTY_SEARCH);
								location.reload();
								return;
							}else{
								window.location.href = appRoot + "InboundTemplate/index";
							}
							setEnabled();
							$.unblockUI();
						}
					});
				}
			},
		});
	});

	$('#dialog_area').on('hidden.bs.modal', function (e) {
		$('#previews').html('');
		$('.error').html('');
		$('.success-mgs').html('');
		$('#copyErrorBtn').css('display', 'none');
		$('#error_files').css('display', 'none');
		myDropzone.files = {};
		myDropzone.removeFile(true);
	});
});
