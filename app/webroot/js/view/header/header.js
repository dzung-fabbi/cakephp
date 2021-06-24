$(document).ready(function() {
	$('#lnkLogout').click(function(){
		window.location.href = appRoot+"Login/logout/";
	});
});

function changeCompany() {
	var company_id = $("#changeCompany").val();
	$.ajax({
		type: "POST",
		url:appRoot+"Company/change_company",
		async: false,
		data: {
			company_id: company_id,
		},
		success:function(data) {
			if (data.status != 200){
				alert(data.message);
				return;
			}
			display_load();
			location.reload();
			//window.location.href = appRoot+"OutSchedule/index";
		},
	});
}

function disableSelection(target){
	if (typeof target.onselectstart!="undefined") {
		target.onselectstart=function(){
			return false;
		}
	} else if (typeof target.style.MozUserSelect!="undefined") {
		target.style.MozUserSelect="none";
	}
	else {
		target.onmousedown=function(){
			return false;
		}
	}
	target.style.cursor = "default";
}

function enableSelection(target){
	if (typeof target.onselectstart!="undefined") {
		target.onselectstart=function(){
			return true;
		}
	} else if (typeof target.style.MozUserSelect!="undefined") {
		target.style.MozUserSelect="";
	}
	else {
		target.onmousedown=function(){
			return true;
		}
	}
	target.style.cursor = "default";
}

 disableSelection(document.body);