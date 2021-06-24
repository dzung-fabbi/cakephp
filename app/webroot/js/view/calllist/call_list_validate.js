var indexTelNo = -1;
var indexFee = -1;
var indexBirthday = -1;
var indexFeeTmp = 0;
var indexBirthdayTmp = 0;
var fieldImport = '';
var listItemData = '';
var telLists = [];

$.validator.addMethod('checkCSVColumnSame', function(value, element, param) {
	var fieldLists = [];
	var title_text;
	indexBirthdayTmp = -1;
	indexFeeTmp = -1;
	fieldImport = '{';
	listItemData = '{';
	$(".sl_csv_column").each(function(index) {
		if ($(this).val() != '') {
			fieldLists[index] = $(this).val();
			title_text = $('.sl_csv_column option[value="'+$(this).val()+'"]:selected').text();
			if (fieldImport != '{') {
				fieldImport = fieldImport + ',"' + index + '":"' + $(this).val() + '"';
				listItemData = listItemData + ',"' + (index + 1) + '":"' + title_text + '"';
			} else {
				fieldImport = fieldImport + '"' + index + '":"' + $(this).val() + '"';
				listItemData = listItemData + '"' + (index + 1) + '":"' + title_text + '"';
			}

			if (title_text == TITLE_BIRTHDAY) {
				indexBirthdayTmp = indexBirthday;
			} else if (title_text == TITLE_FEE) {
				indexFeeTmp = indexFee;
			}
		}
	});
	fieldImport = fieldImport + '}';
	listItemData = listItemData + '}';

	showErrorTelBirthdayFee(param);

	fieldLists = fieldLists.sort();
	for (var i = 0; i < fieldLists.length - 1, typeof(fieldLists[i + 1]) != 'undefined'; i++) {
		if (fieldLists[i + 1] == fieldLists[i]) {
			return false;
		}
	}
	return true;
});

$.validator.addMethod('checkCSVColumnTel', function(value, element, param) {
	var tel_no = false;
	$(".sl_csv_column").each(function(index) {
		var title_text = $('.sl_csv_column option[value="'+$(this).val()+'"]:selected').text();
		if (title_text == param) {
			tel_no = true;
		}
	});

	if (!tel_no) {
		return false;
	}
	return true;
});

$.validator.addMethod('checkTelBirthdayFee', function(value, element, param) {
	if (!showErrorTelBirthdayFee(param)) {
		return false;
	}
	return true;
});

$.validator.addMethod('limitedMaxSize', function(value, element, param) {
	return this.optional(element) || (element.files[0].size <= param * 1024 * 1024);
});

function showErrorTelBirthdayFee(param) {
	var error_tmp = [];
	var telListTmp = [];

	for (var i = 0; i < param.length; i++) {
		if (param[i]) {
			if (typeof param[i][indexTelNo] != 'undefined') {
				var tel_no = param[i][indexTelNo].replace(/\D/g, '');

				if ((tel_no.length > 8) && (tel_no.length < 11) && (tel_no.substring(0, 1) != '0')) { //20160224 Edit by Giang : add '0' before tel_num if first character isnot '0'
					tel_no = '0' + tel_no;
				}
				if (tel_no == '') {
					error_tmp['#check_tel_error_' + i] = (i + 1) + MSG_ERROR_TEL_NO_NULL;
				} else if (!/^-?(?:\d+|\d{1,3}(?:,\d{3})+)?(?:\.\d+)?$/.test(tel_no)) {
					error_tmp['#check_tel_error_' + i] = (i + 1) + MSG_ERROR_TEL_NO_NOT_NUMBERIC;
				} else if (tel_no.length > 11 || tel_no.length < 10) {
					error_tmp['#check_tel_error_' + i] = (i + 1) + MSG_ERROR_TEL_NO_LENGTH;
				} else if ((tel_no.substring(0, 1) != '0') || (tel_no.substring(0, 2) == '00')) { //20160224 Edit by Giang : add '0' before tel_num if first character isnot '0'
					error_tmp['#check_tel_error_' + i] = (i + 1) + MSG_ERROR_TEL_NO_POSITION_FIRST_SECCON;
				} else if (typeof(telListTmp[tel_no]) != 'undefined') {
					error_tmp['#check_tel_error_' + i] = (i + 1) + MSG_ERROR_TEL_NO_DUPLICATE;
				} else {
					telListTmp[tel_no] = tel_no;
					telLists[i][indexTelNo] = tel_no;
				}
			} else {
				error_tmp['#check_tel_error_' + i] = (i + 1) + MSG_ERROR_TEL_NO_NULL;
			}

			if (indexFee >= 0 && indexFeeTmp >= 0 && typeof param[i][indexFee] != 'undefined') {
				var fee = param[i][indexFee];
				var isnumber = /^-?(?:\d+|\d{1,3}(?:,\d{3})+)?(?:\.\d+)?$/.test(fee);

				if (!isnumber) {
					error_tmp['#check_fee_error_' + i] = (i + 1) + MSG_ERROR_FEE_NOT_NUMBERIC;
				}
			}

			if (indexBirthday >= 0 && indexBirthdayTmp >= 0 && typeof param[i][indexBirthday] != 'undefined') {
				var birthday = param[i][indexBirthday];
				if (birthday != '') {
					birthday = birthday.replace( /\D/g, "" );
					birthday_tmp = checkBirthdayValid(birthday);
					if (birthday_tmp === false) {
						error_tmp['#check_birthday_error_' + i] = (i + 1) + MSG_ERROR_BIRTHDAY_INVALID;
					} else {
						telLists[i][indexBirthday] = birthday_tmp;
					}
				}
			}
		}
	}

	$('#copyErrorBtn').attr('data-clipboard-text', '');
	$('.data_csv_error_div').css('display', 'none');
	$('#copyErrorBtn').css('display', 'none');

	if (Object.keys(error_tmp).length > 0) {
		var str_error1 = '';
		var str_error2 = '';
		for (var key in error_tmp) {
			str_error1 = str_error1 + error_tmp[key] + '\n';
			str_error2 = str_error2 + error_tmp[key] + '<br/>';
		}
		$('#copyErrorBtn').attr('data-clipboard-text', str_error1);
		$('#error_tel_birthday_fee').html(str_error2);
		$('.data_csv_error_div').show();
		$('#copyErrorBtn').show();
		return false;
	}
	return true;
}

function checkBirthdayValid(birthday) {
	if (birthday.length != 8) {
		return false;
	}

	var year = birthday.substr(0, 4);
	var month = birthday.substr(4, 2);
	var day = birthday.substr(6, 2);
	birthday_tmp = year + '-' + month + '-' + day;

	var isdate = !/Invalid|NaN/.test( new Date( birthday_tmp ).toString() );
	if (!isdate || (new Date(birthday_tmp).formateCallDate("getDate")) != birthday_tmp) {
		return false;
	}

	return year + '年' + month + '月' + day + '日';
}