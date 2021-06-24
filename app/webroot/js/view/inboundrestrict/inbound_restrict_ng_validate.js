var telLists = [];

$.validator.addMethod('maxline', function(value, element, param) {
	$('.alert').hide();
	var csvVal = value.split("\n");
	return this.optional( element ) || (csvVal.length <= param);
});

$.validator.addMethod('checkTel', function(value, element, param) {
	if (!check_tel_ng_list(param)) {
		return false;
	}
	return true;
});

function check_tel_ng_list(param) {
	var error_tmp = [];
	var telListTmp = [];

	for (var i = 0; i < param.length; i++) {
		if (param[i]) {
			if (param[i].length == 1 || param[i].length == 2) {
				var tel_no_tmp = param[i][0];
				var tel_no = param[i][0].replace(/\D/g,'');
				if ((tel_no.length > 8) && (tel_no.length < 11) && (tel_no.substring(0,1) != '0')) {
					tel_no = '0' + tel_no;
				}
				if (tel_no_tmp == '') {
					error_tmp['#check_tel_error_' + i] = (i + 1) + MSG_ERROR_TEL_NO_NULL;
				} else if (!/^-?(?:\d+|\d{1,3}(?:,\d{3})+)?(?:\.\d+)?$/.test(tel_no)) {
					error_tmp['#check_tel_error_' + i] = (i + 1) + MSG_ERROR_TEL_NO_NOT_NUMBERIC;
				} else if (tel_no.length > 11 || tel_no.length < 10) {
					error_tmp['#check_tel_error_' + i] = (i + 1) + MSG_ERROR_TEL_NO_LENGTH;
				} else if ((tel_no.substring(0,1) != '0') || (tel_no.substring(0,2) == '00')) {
					error_tmp['#check_tel_error_' + i] = (i + 1) + MSG_ERROR_TEL_NO_POSITION_FIRST_SECCON;
				} else if (telListTmp[tel_no]) {
					error_tmp['#check_tel_error_' + i] = (i + 1) + MSG_ERROR_TEL_NO_DUPLICATE;
				} else {
					telListTmp[tel_no] = tel_no;
					telLists[i][0] = tel_no;
				}
			} else if (param[i].length > 2) {
				error_tmp['#check_tel_error_' + i] = (i + 1) + '行に入力形式が正しくありません。';
			}
		}
	}

	if (!show_error(error_tmp)) {
		return false;
	}
	return true;
}

function show_error(error_tmp) {
	$('#copyErrorBtn').attr('data-clipboard-text', '');
	$('.data_csv_error_div').css('display', 'none');
	$('#copyErrorBtn').css('display', 'none');

	if (Object.keys(error_tmp).length < 1) {
		return true;
	}

	var str_error1 = '';
	var str_error2 = '';
	for (var key in error_tmp) {
		str_error1 = str_error1 + error_tmp[key] + '\n';
		str_error2 = str_error2 + error_tmp[key] + '<br/>';
	}
	$('#copyErrorBtn').attr('data-clipboard-text', str_error1);
	$('#error_tel').html(str_error2);
	$('.data_csv_error_div').show();
	$('#copyErrorBtn').show();
	new Clipboard('#copyErrorBtn');
	return false;
}

function append_error_div(element) {
	$(element).html('');
	var str_error = '<div class="data_csv_error_div" style="display:none;">'
		+ '<input type="text" id="check_tel" name="check_tel" style="display:none;"/>'
		+ '<p id="error_tel"></p>'
		+ '</div>'
		+ '<div>'
		+ '<a href="javascript:void(0);" id="copyErrorBtn" data-clipboard-text=" " style="display:none;">コピー</a>'
		+ '</div>';

	$(element).append(str_error);
	new Clipboard('#copyErrorBtn');
}