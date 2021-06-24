const QUESTION_VOICE = '1';
const QUESTION_BASIC = '2';
const QUESTION_AUTH = '3';
const QUESTION_TEL = '4';
const QUESTION_TRANS = '5';
const QUESTION_RECORD = '6';
const QUESTION_COUNT = '7';
const QUESTION_END = '8';
const QUESTION_TIMEOUT = '9';
const QUESTION_AUTH_CHAR = '10';
const QUESTION_PROPERTY = '11';
const QUESTION_FAX = '12';
const QUESTION_SMS = '13';
const QUESTION_PROPERTY_SEARCH = '14';
const QUESTION_INBOUND_SMS = '16';
const QUESTION_INBOUND_COLLATION = '17';
const QUESTION_INBOUND_SMS_INPUT = '18';
const QUESTION_SMS_INPUT = '19';
const OUT_MAX_SECTION_COUNT = 40;
const IN_MAX_SECTION_COUNT = 40;

const ITEM_REGEX = /\{.*?\}/gi;
const DOLLAR_REGEX = /\$/gi;
const SMS_MAX_LENGTH = 70;
const SMS_API_V2_STRING = "api_v2";
const SMS_API_V2_VALUE = "2";
const SMS_API_V2_AFTER_TELL_STRING = "(API_V2)";
const SMS_API_V1_STRING = "api_v1";
const SMS_SHORT_URL_ALLOW_FLAG = "1";

const QUESTION_TRANS_MIN_TIME_OUT_SEC = 90;
//smsセクションの設置数制限
const QUESTION_INBOUND_SMS_LIMIT_COUNT = 5;
const QUESTION_SMS_LIMIT_COUNT = 5;
//番号指定SMSセクションの設置数制限
const QUESTION_INBOUND_SMS_INPUT_LIMIT_COUNT = 5;
const QUESTION_SMS_INPUT_LIMIT_COUNT = 5;
// SMSのURL短縮。全角文字などが入っても問題ないため、http(s):からかを判定する。
// HTTPと大文字であっても対象となるので、大文字、小文字不問で判定すること。
const SMS_URL_PATTERN_REGEX = '(https?:[^ \n\r\f]+)';
// SMSのURL短縮。APIが受け付けない禁則文字。（短縮を有効にした場合のみ、check）
const SMS_URL_NG_PATTERN_REGEX = '([　|%|\^|\\\\|\`|\[|\{|\}])';
// IEは正規表現中に/]があると正規表現がおかしくなるため、単独で確認する。
const SMS_URL_NG_PATTERN_REGEX_CLOSE = /\]/gi;

// SMSのURL短縮。API_V2の場合、改行コードを2文字とカウントする。
const SMS_URL_PATTERN_KAIGYOU_REGEX = '([\n\r\f])';
// SMSのURL短縮。「トラッキングコード１」または「トラッキングコード２」という文字列。
const SMS_URL_PATTERN_TRACKING_CODE_REGEX = '(トラッキングコード[１|1|２|2]})';


// SMSのURL短縮で置き換えられるダミー文字。(SMS本文のカウントで利用)
const SMS_URL_DUMMY_STRING = "1234567890123456789012";
const SMS_URL_DUMMY_KAIGYOU_STRING = "12";

const SMS_MAX_URL_COUNT = 2;

//スケジュール登録時の送信制御時間（分）
const SCHEDULE_SETTING_INTERVAL = 5;

//登録したスケジュールを更新/削除する際の送信制御時間（分）
const SCHEDULE_SETTING_UPD_DEL_INTERVAL = 2;

/** 数値認証項目最大桁数 */
const NUMBER_AUTH_ITEM_MAX_DIGIT = 9;

/** 文字列認証項目最大桁数 */
const CHAR_AUTH_ITEM_MAX_DIGIT = 16;

$(document).keydown(disabledCopyKey);

function disabledCopyKey(ev) {
    // capture the event for a variety of browsers
    ev = ev || window.event;
    // catpure the keyCode for a variety of browsers
    kc = ev.keyCode || ev.which;
    // check to see that either ctrl or command are being pressed along w/any other keys
    if((ev.ctrlKey || ev.metaKey) && kc && (ev.target.id != 'tel_lists')) {
    // these are the naughty keys in question. 'x', 'c', and 'c'
    // (some browsers return a key code, some return an ASCII value)
        if(kc == 99 || kc == 67 || kc == 88) {
            return false;
        }
    }
}



$(document).ready(function() {
    $(".modal").draggable({
            handle: ".modal-header"
    });
    $(document).ajaxSuccess(function (){
        $(".modal").draggable({
            handle: ".modal-header"
        });
    });

    $("a").click(function(e){
        var current_controller_action = $("#current_controller").html() + "/" + $("#current_action").html();
        var textContent = e.target.textContent;
        $.ajax({
            type: "POST",
            url:appRoot+"UserAction/index",
            data: {
                controller_action: current_controller_action,
                textContent: textContent,
            },
            success:function(data){
                if(data == "error"){
                    console.log("Write log user action is fail.");
                }
            },
            error:function(xhr){
                console.log("Write log user actions: "+xhr.messages);
            }
        });
    });

    $("button").click(function(e){
        var current_controller_action = $("#current_controller").html() + "/" + $("#current_controller").html();
        var textContent = e.target.textContent;
        $.ajax({
            type: "POST",
            url:appRoot+"UserAction/index",
            data: {
                controller_action: current_controller_action,
                textContent: textContent,
            },
            success:function(data){
                if(data == "error"){
                    console.log("Write log user action is Fail.");
                }
            },
            error:function(xhr){
                console.log("Write log user actions: "+xhr.messages);
            }
        });
    });

    $('[data-rel="searchable"]').chosen({
        search_contains: true
    });

    $('[data-rel="NotSearchable"]').chosen({
        disable_search: true
    });
});

/**
 * 一括でチェックボックスのON/OFFを切り替える
 * @param {object} element 一括選択チェックボックスのエレメント
 */
function toggleCheckStatus(element){
	var selector = 'input[id^="' + element.data('checkbox') + '"]';
	$(selector).prop('checked', element.prop('checked'));
}

function display_load() {
	$.blockUI({
		//message: "<img src=\""+appRoot+"img/common/indicator.gif\" /><span class='block-loading-span'>しばらくお待ちください...</span>"
		message: "<img src=\""+appRoot+"img/loading_green.gif\" />"
	});
	//setTimeout("$.unblockUI()", 600000);
}

function setDisabled() {
    $('.executebtn').each(function(i) {
        $(this).attr("disabled", true);
        $(this).addClass("disabled-link");

    });
}
function setEnabled() {
    $('.executebtn').each(function(i) {
        $(this).attr("disabled", false);
        $(this).removeClass("disabled-link");
    });
}

Date.prototype.formateCallDate = function(flag) {
    var yyyy = this.getFullYear().toString();
    var mm = (this.getMonth()+1).toString(); // getMonth() is zero-based
    var dd  = this.getDate().toString();
    var HH  = this.getHours().toString();
    var MM  = this.getMinutes().toString();

    mm = mm[1] ? mm : "0"+mm[0];
    dd = dd[1] ? dd : "0"+dd[0];
    HH = HH[1] ? HH : "0"+HH[0];
    MM = MM[1] ? MM : "0"+MM[0];

    if (flag == "hour_minutes") {
        return HH + ":" + MM;
    } else if (flag == "getDate") {
        return yyyy + "-" + mm + "-" + dd;
    } else if (flag == "getMonth") {
        return mm;
    } else if (flag == "getDay") {
        return dd;
    } else {
        return yyyy + "-" + mm + "-" + dd + " " + HH + ":" + MM;
    }
};
/* 20160316 Add by Giang : #6711 - Inbound Restrict index screen- start */
function init_table(showCb, controller, action, tableId, filter_functions) {
	var page = 0, column = [];
	if($("#hdPageList").val()){
		page = parseInt($("#hdPageList").val());
	}
	if($("#hdSortColumnList").val() && $("#hdSortTypeList").val()){
		column = [[parseInt($("#hdSortColumnList").val()), parseInt($("#hdSortTypeList").val())]];
	} else {
		if (action != 'arr_inbound_call_list') {
			if (showCb) {
				column = [[1, 1]];
			} else {
				column = [[0, 1]];
			}
		}
	}
	$(tableId).tablesorter({
		theme: 'gold',
		widthFixed: true,
		sortLocaleCompare: true,
		sortList: column,
		widgets: ['zebra', 'filter'],
		widgetOptions : {
			filter_functions : filter_functions
		}
	}).tablesorterPager({
		container: $(".pager"),
		type: "POST",
		ajaxUrl: appRoot + controller + '/' + action + '/' + "{page}/20/{sortList:column}?{filterList:filter}",
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
}

function reload_table(page, sortColumn, sortType, controller, action, tableId) {

	var url = appRoot + controller + '/' + action + '/' + page + "/20/column?filter";
	if (sortColumn != null && sortType != null) {
		url = appRoot + controller + '/' + action + '/' + page + "/20/column[" + sortColumn + "]=" + sortType + "?filter";
	}

	$.ajax({
		type: "POST",
		url: url,
		cache: false,
		dataType: 'json',
		success:function(data){
			if (data && data.hasOwnProperty('rows')) {
				var json_data = new Object();
				json_data["headers"] = data.headers;
				json_data["total_rows"] = data.total_rows;
				json_data["rows"] = data.rows;
				$(tableId).trigger("renderAjax", json_data);
				$(tableId).trigger("update");
				$(tableId).trigger('pagerUpdate');
			}
		}
	});
}
/* 20160316 Add by Giang : #6711 - Inbound Restrict index screen- end */

// SMS短縮機能 URLとなる文字列を22文字のダミー文字列に置き換える。
function replaceUrlFromSMSBody(SmsContent) {
	return SmsContent.replace(new RegExp(SMS_URL_PATTERN_REGEX, "gi"), SMS_URL_DUMMY_STRING);
}

// SMS短縮機能 API_V2を利用する場合、改行は2文字とカウントする。
function replaceKaigyouFromSMSBody(SmsContent) {
	return SmsContent.replace(new RegExp(SMS_URL_PATTERN_KAIGYOU_REGEX, "gi"), SMS_URL_DUMMY_KAIGYOU_STRING);
}

// SMS短縮機能 挿入項目を空欄に置き換える {a}->""  {}->{}(1文字以上無いと挿入項目としない)
function replaceInsertFromSMSBody(SmsContent) {
	return SmsContent.replace(ITEM_REGEX, "");
}

// SMS短縮機能 URLとなる文字列の中にAPIで扱えない文字がないかを確認する。
function validateSMSBodyStringInUrl(SmsContent) {
	// 挿入項目をトリミング（空欄に変換する）
	SmsContent = replaceInsertFromSMSBody(SmsContent);
	var SMSUrlContents = (SmsContent.match(new RegExp(SMS_URL_PATTERN_REGEX, "gi")) || []);
	if(SMSUrlContents.length == 0){
		return true;
	}
	for(var cnt=0; cnt < SMSUrlContents.length; cnt++){
		// URL短縮で禁則文字がURLパターン内に入る場合は、エラーとする。
		// IEは正規表現中に/]があると正規表現がおかしくなるため、単独で確認する。
		var ngItems = (SMSUrlContents[cnt].match(new RegExp(SMS_URL_NG_PATTERN_REGEX, "gi")) || []);
		var ngItemsClse = SMSUrlContents[cnt].match(SMS_URL_NG_PATTERN_REGEX_CLOSE);

		if(ngItems.length > 0 || ngItemsClse != null){
			return false;
		}
	}
	return true;
}

// SMS短縮機能 　挿入項目「トラッキングコード１」または「トラッキングコード２」はURLとなる文字列の中に存在するかをチェック。
function validateSMSBodyStringInUrlTrackingCode(SmsContent) {
	// 挿入項目「トラッキングコード１」または「トラッキングコード２」が存在するかをチェック
	var TrackingCodeContents = (SmsContent.match(new RegExp(SMS_URL_PATTERN_TRACKING_CODE_REGEX, "gi")) || []);
	if(TrackingCodeContents.length == 0){
		return true;
	}
	// SMS内のURLをチェックする
	var SMSUrlContents = (SmsContent.match(new RegExp(SMS_URL_PATTERN_REGEX, "gi")) || []);
	var trackingCodeCount = 0;
	for(var cnt=0; cnt < SMSUrlContents.length; cnt++){
		trackingCodeCount += (SMSUrlContents[cnt].match(new RegExp(SMS_URL_PATTERN_TRACKING_CODE_REGEX, "gi")) || []).length;
	}
	// 文言チェック
	if(TrackingCodeContents.length != trackingCodeCount){
		return false;
	}
	return true;
}


// SMS短縮機能 URLとなる文字列の中にAPIで扱えない文字がないかを確認する。
function validateSMSBodyMaxUrlCount(SmsContent) {
	// 挿入項目をトリミング（空欄に変換する）
	SmsContent = replaceInsertFromSMSBody(SmsContent);
	var SMSUrlContents = (SmsContent.match(new RegExp(SMS_URL_PATTERN_REGEX, "gi")) || []);
	if(SMSUrlContents.length > SMS_MAX_URL_COUNT){
		return false;
	}
	return true;
}

// SMS短縮機能 URL本文の文字をカウント用に置き換える。
// isShortは　true:短縮URLを使う　false：使わない
// callFlgは　true:インバウンドテンプレート画面からの呼び出し
function replaceUrlSMSBody(SmsContent, isShort, callFlg,quesNo) {
	// 挿入項目を空欄に置換。（0文字とカウントとするため。）
	var SmsContent = replaceInsertFromSMSBody(SmsContent);
	// URL短縮（URL部分を22文字とカウントするためURL部分を22文字の文字列に置換する。）
	if(isShort){
		SmsContent = replaceUrlFromSMSBody(SmsContent);
	}
	if(checkSMSApiVersion(callFlg, quesNo) == SMS_API_V2_STRING ){
		SmsContent = replaceKaigyouFromSMSBody(SmsContent);
	}

	return SmsContent;
}

// SMS短縮機能 URL本文の文字をカウント用に置き換える。
// isShortは　true:短縮URLを使う　false：使わない
// callFlgは　true:インバウンドテンプレート画面からの呼び出し
function replaceUrlSMSInputBody(SmsContent, isShort, callFlg,quesNo) {
	// 挿入項目を空欄に置換。（0文字とカウントとするため。）
	var SmsContent = replaceInsertFromSMSBody(SmsContent);
	// URL短縮（URL部分を22文字とカウントするためURL部分を22文字の文字列に置換する。）
	if(isShort){
		SmsContent = replaceUrlFromSMSBody(SmsContent);
	}
	if(checkSMSInputApiVersion(callFlg, quesNo) == SMS_API_V2_STRING ){
		SmsContent = replaceKaigyouFromSMSBody(SmsContent);
	}

	return SmsContent;
}

/**
 * SMS短縮機能 URL本文の文字をカウント用に置き換える
 * @param {string} SmsContent SMS本文
 * @param {boolean} isShort true:短縮URLを使う　false：使わない
 * @return {string} URL／改行を置換後のカウント用SMS本文
 */
function replaceUrlSMSBodyBulk(SmsContent, isShort) {
	// 挿入項目を空欄に置換。（0文字とカウントとするため。）
	var SmsContent = replaceInsertFromSMSBody(SmsContent);

	if (isShort) {
		// URL短縮（URL部分を22文字とカウントするためURL部分を22文字の文字列に置換する。）
		SmsContent = replaceUrlFromSMSBody(SmsContent);
	}

	//V2のみ使用する運用になったためisShortパラメータは使用せず、常に改行は2文字とする
	SmsContent = replaceKaigyouFromSMSBody(SmsContent);

	return SmsContent;
}

// SMS短縮機能 選択中の電話番号をもとに、画面状態を決める
function setSMSState() {
	IdUseShot = "#sms_use_short_url";
	if (checkSMSApiVersion() == SMS_API_V2_STRING && $("#slSMSPhoneNumber").find(":selected").data("flag") == SMS_SHORT_URL_ALLOW_FLAG) {
		//チェックボックスを利用可能とする。(状態はそのまま。選択中の電話番号がAPIｖ2かつ短縮URL利用可能であれば、OFFとする。)
		$(IdUseShot).prop("disabled", false);
	} else {
		//チェックボックスをOFFとし、利用不可とする。
		$(IdUseShot).prop("checked", false);
		$(IdUseShot).prop("disabled", true);
	}
	fillSMSBodyCount();
}

// SMS短縮機能 選択中の電話番号をもとに、画面状態を決める(番号指定SMS)
function setSMSInputState() {
	IdUseShot = "#sms_input_use_short_url";
	if (checkSMSInputApiVersion() == SMS_API_V2_STRING && $("#slSMSInputPhoneNumber").find(":selected").data("flag") == SMS_SHORT_URL_ALLOW_FLAG) {
		//チェックボックスを利用可能とする。(状態はそのまま。選択中の電話番号がAPIｖ2かつ短縮URL利用可能であれば、OFFとする。)
		$(IdUseShot).prop("disabled", false);
	} else {
		//チェックボックスをOFFとし、利用不可とする。
		$(IdUseShot).prop("checked", false);
		$(IdUseShot).prop("disabled", true);
	}
	fillSMSInputBodyCount();
}

// SMS短縮機能 電話番号のプルダウンより、利用するAPIのバージョンを取得する。
// 電話番号のプルダウンは「#sms_use_short_url」とし、
// 電話番号（<option>）はclassとしてAPIのバージョンを与えること。
// callFlgは　true:インバウンドテンプレート画面からの呼び出し
function checkSMSApiVersion(callFlg, quesNo) {
  if(callFlg){
    var smsPhoneNumber = glb_arr_ques[quesNo]["smsPhoneNumber"];
    var class_string = $('select[name="smsPhoneNumber"]').find('option[value="' + smsPhoneNumber + '"]').attr('class');
  }else{
    var class_string = $("#slSMSPhoneNumber :selected").attr('class');
  }
	var class_array = []
	// プルダウンの値が未選択（電話番号なし）の場合、class要素がないためundefinedとなる。
	if(class_string !== undefined){
		class_array = class_string.split(' ')
	}
	if($.inArray(SMS_API_V2_STRING, class_array) != -1){
		return SMS_API_V2_STRING　
	}
	return SMS_API_V1_STRING;
}

// SMS短縮機能 電話番号のプルダウンより、利用するAPIのバージョンを取得する。
// 電話番号のプルダウンは「#sms_input_use_short_url」とし、
// 電話番号（<option>）はclassとしてAPIのバージョンを与えること。
// callFlgは　true:インバウンドテンプレート画面からの呼び出し
function checkSMSInputApiVersion(callFlg, quesNo) {
	if(callFlg){
		var smsInputPhoneNumber = glb_arr_ques[quesNo]["smsInputPhoneNumber"];
		var class_string = $('select[name="smsInputPhoneNumber"]').find('option[value="' + smsInputPhoneNumber + '"]').attr('class');
	}else{
		var class_string = $("#slSMSInputPhoneNumber :selected").attr('class');
	}
	var class_array = []
	// プルダウンの値が未選択（電話番号なし）の場合、class要素がないためundefinedとなる。
	if(class_string !== undefined){
		class_array = class_string.split(' ')
	}
	if($.inArray(SMS_API_V2_STRING, class_array) != -1){
		return SMS_API_V2_STRING
	}
	return SMS_API_V1_STRING;
}

/**
 * 一括選択チェックボックスの制御
 * 制御の条件
 * チェックON：データ部のチェックボックスに全てチェックが入っている場合
 * チェックOFF：上記以外
 * @param {string} 一括選択チェックボックスのID
 */
function updateCheckStatus(id){
	var selector = 'input[id^="' + $('#' + id).data('checkbox') + '"]';
	var checkState = $(selector).filter(':checked').length == $(selector).length;
	$('#' + id).prop('checked', checkState);
}

/**
 * 認証項目桁数の最大桁数チェック
 * 引数によって比較する最大値(数値認証と文字列認証)を決定する
 * チェック出来ない値(数値でない、0以下)の場合は正常とする
 *
 * @param {number} inputDigit 認証項目桁数
 * @param {boolean} charAuthFlg 文字列認証フラグ
 * @return {boolean} true：桁数正常値／false：桁数オーバー
 */
function isMaxDigitForAuthItem(inputDigit, charAuthFlg) {
	if (!$.isNumeric(inputDigit) || 1 > inputDigit) {
		// 大小比較が出来ない場合
		return true;
	}

	if (charAuthFlg) {
		return CHAR_AUTH_ITEM_MAX_DIGIT >= inputDigit;
	}

	return NUMBER_AUTH_ITEM_MAX_DIGIT >= inputDigit;
}
