var indexTelNo = -1;
var indexFee = -1;
var indexBirthday = -1;
var indexTelNoTmp = 0;
var indexFeeTmp = 0;
var indexBirthdayTmp = 0;
var fieldImport = '';
var listItemData = '';
var telLists = [];

$.validator.addMethod('date', function(value, element, param) {
	var date_org = new Date(value);
	var date_tmp = date_org.formateCallDate("getDate");
	return this.optional( element ) || (!/Invalid|NaN/.test( new Date( value ).toString() ) && (date_tmp == value));
});

$.validator.addMethod('checkCSVColumnSame', function(value, element, param) {
	var fieldLists = [];
	var title_text;
	var item_main_text;//照合項目
	var item_main_index;//照合項目のインデックス
	var item_index = 0;
	indexBirthdayTmp = -1;
	indexFeeTmp = -1;
	fieldImport = '{';
	listItemData = '{';
	item_main_text = $('#item_main option:selected').text();

	// 照合項目の取得
	$(".sl_csv_column").each(function(index) {
		if ($(this).children('option:selected').text() == item_main_text) {
			item_main_index = $(this).val();
			return false;
		}
	});

	//一番目のカラムセット
	//照合項目のセット
	fieldImport = fieldImport + '"' + '0' + '":"' + item_main_index + '"';
	listItemData = listItemData + '"' + '1' + '":"' + item_main_text + '"';
	fieldLists[item_index] = item_main_index;
	item_index ++;

	$(".sl_csv_column").each(function(index) {
		if ($(this).val() != '') {
			if($(this).val() == item_main_index){
				//照合項目は先頭に設置しているため、スキップする
				return true;
			}

			fieldLists[item_index] = $(this).val();
			title_text = $('.sl_csv_column option[value="'+$(this).val()+'"]:selected').text();
			fieldImport = fieldImport + ',"' + item_index + '":"' + $(this).val() + '"';
			listItemData = listItemData + ',"' + (item_index + 1) + '":"' + title_text + '"';

			if (title_text == TITLE_BIRTHDAY) {
				indexBirthdayTmp = indexBirthday;
			} else if (title_text == TITLE_FEE) {
				indexFeeTmp = indexFee;
			} else if (title_text == TITLE_TEL_NUMBER) {
				indexTelNoTmp = indexTelNo;
			}
		}
		item_index ++;
	});
	fieldImport = fieldImport + '}';
	listItemData = listItemData + '}';

	showErrorTelBirthdayFee(param);

	fieldLists = fieldLists.sort();
	for (var i = 0; i < fieldLists.length - 1, fieldLists[i + 1]; i++) {
		if (fieldLists[i + 1] == fieldLists[i]) {
			return false;
		}
	}
	return true;
});

$.validator.addMethod('checkItemMain', function(value, element, param) {
	var item_main = $('#item_main').val();
	var item_main_flag = false;
	var msg_item_main = '';
	if (item_main) {
		$(".sl_csv_column").each(function(index) {
			if ($(this).val() != '') {
				var title_text = $('#field_' + index + ' option[value="'+$(this).val()+'"]:selected').text();
				msg_item_main += title_text + '、';
				if (title_text == item_main) {
					item_main_flag = true;
				}
			}
		});
	}

	if (!item_main_flag) {
		msg_item_main = msg_item_main.slice(0, -1) + ' ' + INBOUND_ITEM_MAIN_INVALID;
		$(param).html(msg_item_main);
		return false;
	}
	$(param).html('');
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
	var itemMainTmp = [];

	for (var i = 0; i < param.length; i++) {
		if (param[i]) {
			if (indexTelNo >= 0 && typeof param[i][indexTelNo] != 'undefined') {
				var tel_no = param[i][indexTelNo].replace(/\D/g,'');

				if ((tel_no.length > 8) && (tel_no.length < 11) && (tel_no.substring(0,1) != '0')) {
					tel_no = '0' + tel_no;
				}
				if (tel_no == '') {
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
					telLists[i][indexTelNo] = tel_no;
				}
			}

			if ((indexFee >= 0) && (indexFeeTmp >= 0)) {
				var fee = param[i][indexFee];
				var isnumber = /^-?(?:\d+|\d{1,3}(?:,\d{3})+)?(?:\.\d+)?$/.test(fee);

				if (!isnumber) {
					error_tmp['#check_fee_error_' + i] = (i + 1) + MSG_ERROR_FEE_NOT_NUMBERIC;
				}
			}

			if ((indexBirthday >= 0) && (indexBirthdayTmp >= 0)) {
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
			// 20160404 Add by Giang - #6740: check item main unique - Begin
			if ($('.item_main_error').html() == '') {
				var item_main = $('#item_main').val();
				var indexItemMain = $("#field_0 option:contains('" + item_main + "')").val();
				// if (indexItemMain && (indexItemMain != indexTelNo)) { /*20160425 Delete by Giang - #6740 - Remove valid tel_no*/
				if (indexItemMain) {
					var item_main_val = param[i][indexItemMain];
					if (!item_main_val) {
						error_tmp['#check_item_main_error_' + i] = INBOUND_ITEM_MAIN_EMPTY1 + (i + 1) + INBOUND_ITEM_MAIN_EMPTY2;
					} else if (itemMainTmp[item_main_val]) {
						error_tmp['#check_item_main_error_' + i] = INBOUND_ITEM_MAIN_DUPLICATE1 + (i + 1) + INBOUND_ITEM_MAIN_DUPLICATE2;
					} else {
						itemMainTmp[item_main_val] = item_main_val;
					}
				}
			}
			// 20160404 Add by Giang - #6740: check item main unique - End
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