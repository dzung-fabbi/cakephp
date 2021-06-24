function validate_form(ques_type){
	var error_msg = "";
	var ques_title = $("#dialog").find("#txtQuesTitle").val();
	var audio_type = $("#dialog").find("input[name=audio_type]:checked").val();
	var audio_id = $("#dialog").find("#hdAudioId").val();
	var audio_content = $("#dialog").find("#txtAudioContent").val();

//	if(!ques_title.trim()){
//		error_msg = error_msg + "タイトルを入力してください。<br/>";
//	}
	if(ques_type == QUESTION_VOICE){
		msg = check_audio(audio_type,audio_id,audio_content);
		error_msg = error_msg + msg;
		msg = validate_audio_content(audio_content);
		error_msg = error_msg + msg;
	}else if(ques_type == QUESTION_BASIC){
		msg = check_audio(audio_type,audio_id,audio_content);
		error_msg = error_msg + msg;
		msg = validate_audio_content(audio_content);
		error_msg = error_msg + msg;
		$("#dialog").find(".txtAnswJump").each(function(){
			var jump = $(this).val();
			if(jump && !isInteger(jump)){
				if($(this).attr("answer_no") != 99){
					error_msg = error_msg + "回答"+$(this).attr("answer_no")+"の飛び先項目で数字を入力してください。<br/>";
				}else{
					error_msg = error_msg + "タイムアウトの飛び先項目で数字を入力してください。<br/>";
				}
			}
		});
		//20160302 Edited by Canh : #6552 - 回答ボタンが必須じゃないように begin
		if($("#question_yuko").prop("checked") && $("#dialog").find(".cbYukoAnsw:checked").length == 0){
			error_msg = error_msg + "有効回答を選択してください。<br/>";
		}
		//20160302 Edited by Canh : #6552 - 回答ボタンが必須じゃないように end
	}else if(ques_type == QUESTION_AUTH || ques_type == QUESTION_AUTH_CHAR){ //20160420 Edit by Thai : #6722 ADD QUESTION_AUTH_CHAR
		var digit_auth = $("#dialog").find("#txtDigitAuth").val();
		//音声
		msg = check_audio(audio_type,audio_id,audio_content);
		error_msg = error_msg + msg;
		//挿入ボタンがない手入にチェック
		msg = check_audio_content(1, audio_content);
		error_msg = error_msg + msg;
		//桁数
		if(!digit_auth || !isInteger(digit_auth) || digit_auth <= 0){
			error_msg = error_msg + "桁数項目には数字を入力してください。<br/>";
		}

		var char_auth_flg = ques_type == QUESTION_AUTH_CHAR;

		if (!isMaxDigitForAuthItem(digit_auth, char_auth_flg)) {
			if (char_auth_flg) {
				error_msg = error_msg + MSG_ERROR_CHAR_AUTH_DIGIT_OVER + '<br/>';
			} else {
				error_msg = error_msg + MSG_ERROR_NUMBER_AUTH_DIGIT_OVER + '<br/>';
			}
		}

		//有効回答
		//20160302 Edited by Canh : #6552 - 回答ボタンが必須じゃないように begin
		if($("#question_yuko").prop("checked") && $("#dialog").find(".cbYukoAnswAuth:checked").length == 0){
			error_msg = error_msg + "有効回答を選択してください。<br/>";
		}
		//20160302 Edited by Canh : #6552 - 回答ボタンが必須じゃないように end
		//飛び先
		//20160302 Deleted by Canh : Begin
//		$("#dialog").find(".txtAnswJumpAuth").each(function(){
//			var jump = $(this).val();
//			if(jump && !isInteger(jump)){
//				if($(this).attr("answer_no") == 1){
//					error_msg = error_msg + "入力値 ＜ 認証の飛び先項目で数字を入力してください。<br/>";
//				}else if($(this).attr("answer_no") == 2){
//					error_msg = error_msg + "入力値 ＝ 認証の飛び先項目で数字を入力してください。<br/>";
//				}else if($(this).attr("answer_no") == 3){
//					error_msg = error_msg + "入力値 ＞ 認証の飛び先項目で数字を入力してください。<br/>";
//				}else if($(this).attr("answer_no") == 99){
//					error_msg = error_msg + "タイムアウトの飛び先項目で数字を入力してください。<br/>";
//				}
//			}
//		});
		//20160302 Deleted by Canh : End
		//繰返確認
		if($("#dialog").find("#cbRecheckFlag:checked").length > 0){
			var recheck_audio_type = $("#dialog").find("input[name=recheck_audio_type]:checked").val();
			var recheck_audio_id = $("#dialog").find("#hdRecheckAudioId").val();
			var recheck_audio_content = $("#dialog").find("#txtAudioRecheckContent").val();
			//音声
			msg = recheck_audio(recheck_audio_type, recheck_audio_id, recheck_audio_content);
			error_msg = error_msg + msg;
			//挿入ボタンがない手入にチェック
			msg = check_audio_content(2, recheck_audio_content);
			error_msg = error_msg + msg;
			//訂正と正
			var next = $("#dialog").find("#slRecheckNext").val();
			var pre = $("#dialog").find("#slRecheckPrev").val();
			if(next == pre){
				error_msg = error_msg + "訂正番号と正番号が重複できません。<br/>";
			}
		}
	}else if(ques_type == QUESTION_TEL){
		var digit_tel = $("#dialog").find("#txtDigitTel").val();
		//音声
		msg = check_audio(audio_type,audio_id,audio_content);
		error_msg = error_msg + msg;
		//挿入ボタンがない手入にチェック
		msg = check_audio_content(1, audio_content);
		error_msg = error_msg + msg;
		//桁数
		if(!digit_tel || !isInteger(digit_tel) || digit_tel <= 0){
			error_msg = error_msg + "桁数項目には数字を入力してください。<br/>";
		}
		//繰返確認
		if($("#dialog").find("#cbRecheckFlag:checked").length > 0){
			var recheck_audio_type = $("#dialog").find("input[name=recheck_audio_type]:checked").val();
			var recheck_audio_id = $("#dialog").find("#hdRecheckAudioId").val();
			var recheck_audio_content = $("#dialog").find("#txtAudioRecheckContent").val();
			//音声
			msg = recheck_audio(recheck_audio_type, recheck_audio_id, recheck_audio_content);
			error_msg = error_msg + msg;
			//挿入ボタンがない手入にチェック
			msg = check_audio_content(2, recheck_audio_content);
			error_msg = error_msg + msg;
			//訂正と正
			var next = $("#dialog").find("#slRecheckNext").val();
			var pre = $("#dialog").find("#slRecheckPrev").val();
			if(next == pre){
				error_msg = error_msg + "訂正番号と正番号が重複できません。<br/>";
			}
		}
	}else if(ques_type == QUESTION_TRANS){
		var trans_audio_type = $("#dialog").find("input[name=trans_audio_type]:checked").val();
		var trans_audio_id = $("#dialog").find("#hdTransAudioId").val();
		var trans_audio_content = $("#dialog").find("#txtAudioTransContent").val();
		var trans_timeout_audio_type = $("#dialog").find("input[name=trans_timeout_audio_type]:checked").val();
		var trans_timeout_audio_id = $("#dialog").find("#hdTransTimeoutAudioId").val();
		var trans_timeout_audio_content = $("#dialog").find("#txtAudioTransTimeoutContent").val();
		var seat_num = $("#dialog").find("#txtSeatNum").val();
		var time_out = $("#dialog").find("#txtTimeout").val();
		var trans_tel = $("#dialog").find("#txtTransTel").val();
		//転送音声
		msg = check_audio(trans_audio_type,trans_audio_id,trans_audio_content);
		error_msg = error_msg + msg;
		msg = validate_audio_content(trans_audio_content);
		error_msg = error_msg + msg;
		//転送タイムアウト
		msg = check_audio(trans_timeout_audio_type,trans_timeout_audio_id,trans_timeout_audio_content);
		error_msg = error_msg + msg;
		//挿入ボタンがない手入にチェック
		if ($.trim(trans_timeout_audio_content) != '' && !/^[^{}]*$/.test($.trim(trans_timeout_audio_content))) {
			error_msg = error_msg + "転送タイムアウト音声に「{}」を含めない内容を入力してください。<br/>";
		}
		//飛び先

		var filter = /^0[0-9]+$/;
	    if (!filter.test(trans_tel) || trans_tel.length < 10) {
	    	error_msg = error_msg + "電話番号の入力形式が正しくありません。<br/>";
	    }
		//席数
		if(!seat_num || !isInteger(seat_num) || seat_num <= 0){
			error_msg = error_msg + "席数項目で1以上の数字を入力してください。<br/>";
		}
		//タイムアウト
		if(!time_out || !isInteger(time_out) || time_out <= 0){
			error_msg = error_msg + "タイムアウト項目で1以上の数字を入力してください。<br/>";
		}
		// 転送元番号再生時に、90秒以上のタイムアウト秒を指定しない場合
		else if($('#cbTransPhoneNumberFlag').prop('checked') && QUESTION_TRANS_MIN_TIME_OUT_SEC > time_out){
			error_msg = error_msg + "転送元番号再生時は、" + QUESTION_TRANS_MIN_TIME_OUT_SEC + "秒以上のタイムアウト秒を指定してください。<br/>";
		}


	}else if(ques_type == QUESTION_RECORD){
		msg = check_audio(audio_type,audio_id,audio_content);
		error_msg = error_msg + msg;
		msg = validate_audio_content(audio_content);
		error_msg = error_msg + msg;
		var second_record = $("#dialog").find("#txtSecondRecord").val();
		if(!second_record || !isInteger(second_record) || second_record > 30 || second_record <= 0){
			error_msg = error_msg + "数秒項目で30以下の数字を入力してください。<br/>";
		}
	}else if(ques_type == QUESTION_TIMEOUT){
		msg = check_audio(audio_type,audio_id,audio_content);
		error_msg = error_msg + msg;
		//挿入ボタンがない手入にチェック
		msg = check_audio_content(1, audio_content);
		error_msg = error_msg + msg;
		if (error_msg && $('#edit_flg').val() == 1) {
			$("#slQuesType").attr('disabled', true);
		}
	} else if (ques_type == QUESTION_SMS) {
		//20161121 Add by LinhNT: #8851
		var phoneNumber = $("#dialog").find("#slSMSPhoneNumber").val();
		var bodyContent = $("#dialog").find("#smsBodyContent").val();

		if (!phoneNumber) {
			error_msg += OUTBOUND_QUESTION_SMS_PHONE_EMPTY + '<br>';
		}
		if (!bodyContent) {
			error_msg += OUTBOUND_QUESTION_SMS_BODY_EMPTY + '<br>';
		}

		// SMS本文の文字数チェック
		if(replaceUrlSMSBody(bodyContent, $('#sms_use_short_url').prop('checked')).length > SMS_MAX_LENGTH){
			error_msg += OUTBOUND_QUESTION_SMS_BODY_REACH_LIMIT + '<br>';
		}

		// SMS本文のurl禁則確認(短縮機能を使わない場合は、禁則でなくなる。)
		if($('#sms_use_short_url').prop('checked')){
			if(validateSMSBodyStringInUrl(bodyContent) == false){
				error_msg += SMS_ILLEGAL_STRING_IN_BODY_URL + '<br>';
			}
			if(validateSMSBodyMaxUrlCount(bodyContent) == false){
				error_msg += SMS_OVER_COUNT_IN_BODY_URL + '<br>';
			}
			// 「トラッキングコード１」または「トラッキングコード２」より前にURLパターンがあるかを判定。
			if(validateSMSBodyStringInUrlTrackingCode(bodyContent) == false){
				error_msg += SMS_ILLEGAL_POSITION_TRACKING_CODE + '<br>';
			}
		}

		if (bodyContent.match(DOLLAR_REGEX) != null) {
			error_msg += OUTBOUND_QUESTION_SMS_BODY_INVALID + '<br>';
		}
		msg = validate_audio_content(bodyContent);
		error_msg = error_msg + msg;
		error_msg = run_audio_validate(error_msg,
				"ques_sms_audio_type",
				"hdSmsErrorAudioId",
				"txtAudioSmsErrorContent",
				"送信不可音声"
		);
	}else if (ques_type == QUESTION_SMS_INPUT) {
		var phoneNumber = $("#dialog").find("#slSMSInputPhoneNumber").val();
		var bodyContent = $("#dialog").find("#smsInputBodyContent").val();
		if (!phoneNumber) {
			error_msg += OUTBOUND_QUESTION_SMS_PHONE_EMPTY + '<br>';
		}
		if (!bodyContent) {
			error_msg += OUTBOUND_QUESTION_SMS_BODY_EMPTY + '<br>';
		}

		//音声確認
		error_msg = error_msg + check_audio(audio_type,audio_id,audio_content);

		//繰返確認
		var recheck_audio_type = $("#dialog").find("input[name=recheck_audio_type]:checked").val();
		var recheck_audio_id = $("#dialog").find("#hdRecheckAudioId").val();
		var recheck_audio_content = $("#dialog").find("#txtAudioRecheckContent").val();
		//音声
		error_msg = error_msg + recheck_audio(recheck_audio_type, recheck_audio_id, recheck_audio_content);

		// SMS本文の文字数チェック
		if(replaceUrlSMSInputBody(bodyContent, $('#sms_input_use_short_url').prop('checked')).length > SMS_MAX_LENGTH){
			error_msg += OUTBOUND_QUESTION_SMS_BODY_REACH_LIMIT + '<br>';
		}

		// SMS本文のurl禁則確認(短縮機能を使わない場合は、禁則でなくなる。)
		if($('#sms_input_use_short_url').prop('checked')){
			if(validateSMSBodyStringInUrl(bodyContent) == false){
				error_msg += SMS_ILLEGAL_STRING_IN_BODY_URL + '<br>';
			}
			if(validateSMSBodyMaxUrlCount(bodyContent) == false){
				error_msg += SMS_OVER_COUNT_IN_BODY_URL + '<br>';
			}
			// 「トラッキングコード１」または「トラッキングコード２」より前にURLパターンがあるかを判定。
			if(validateSMSBodyStringInUrlTrackingCode(bodyContent) == false){
				error_msg += SMS_ILLEGAL_POSITION_TRACKING_CODE + '<br>';
			}
		}
		if (bodyContent.match(DOLLAR_REGEX) != null) {
			error_msg += OUTBOUND_QUESTION_SMS_BODY_INVALID + '<br>';
		}
		msg = validate_audio_content(bodyContent);
		error_msg = error_msg + msg;

		// 継続確認音声部分
		error_msg = run_audio_validate(error_msg,
				"ques_sms_input_audio_type",
				"hdSmsInputErrorAudioId",
				"txtAudioSmsInputErrorContent",
				"送信不可音声"
		);
	}

	return error_msg;
}
function run_audio_validate(error_msg, audio_type, audio_id, audio_content, item_title){
	var audio_type_value = $("#dialog").find("input[name=" + audio_type + "]:checked").val();
	var audio_id_value = $("#dialog").find("#" + audio_id).val();
	var audio_content_value = $("#dialog").find("#" + audio_content).val();

	var msg = check_audio_2(audio_type_value,
			audio_id_value,
			audio_content_value,
			item_title);
	error_msg = error_msg + msg;
	msg = check_audio_content(1, audio_content_value);
	error_msg = error_msg + msg;

	return error_msg;
}

function check_audio_2(audio_type,audio_id, audio_content, item_title){
	if(audio_type == 0 && !audio_id){
		return item_title + "ファイルを選択してください。<br/>";
	}else if((audio_type == 1 || audio_type == 2) && !$.trim(audio_content)){
		return item_title + "内容を入力してください。<br/>";
	}
	return "";
}

function check_audio(audio_type,audio_id,audio_content){
	if(audio_type == 0 && !audio_id){
		return "音声ファイルを選択してください。<br/>";
	}else if((audio_type == 1 || audio_type == 2) && !$.trim(audio_content)){
		return "音声内容を入力してください。<br/>";
	}
	return "";
}
function recheck_audio(recheck_audio_type, recheck_audio_id, recheck_audio_content){
	if (recheck_audio_type == 0 && !recheck_audio_id) {
		return "繰返し音声ファイルを選択してください。<br/>";
	}
	if ((recheck_audio_type == 1 || recheck_audio_type == 2) && !$.trim(recheck_audio_content)) {
		return "繰返し確認の音声内容を入力してください。<br/>";
	}
	return "";
}
function check_audio_content(type, audio_content){
	if ($.trim(audio_content) != '' && !/^[^{}]*$/.test($.trim(audio_content))) {
		if (type == 1) {
			return "「{}」を含めない音声内容を入力してください。<br/>";
		}else{
			return "「{}」を含めない繰返し確認の音声内容を入力してください。<br/>";
		}
	}
	return "";
}

// {xxxx} xxxxに入る文字が挿入項目としてプルダウンに存在しなければNG。
// また　{　のみや } みもNGと扱う。
function validate_audio_content(audio_content){
	if ($.trim(audio_content)) {
		var option_arr = [];
		$('#tounyuu option').each(function(){
			option_arr.push($(this).html());
		});

		var flag = true;
		var mes = '';
		var start_flag = false;
		var end_flag = false;
		var sub_content = "";
		for (var i = 0; i < $.trim(audio_content).length; i++) {
			if (start_flag) {
				if ($.trim(audio_content)[i] == '}') {
					if (sub_content == '') {
						flag = false;
					}else{
						if($.inArray(sub_content, option_arr) < 0){
							flag = false;
						}
						sub_content = '';
					}
					start_flag = false;
				}else{
					sub_content = sub_content + $.trim(audio_content)[i];
				}
			}else{
				if ($.trim(audio_content)[i] == '{'){
					start_flag = true;
				}else if ($.trim(audio_content)[i] == '}') {
					flag = false;
				}
			}
			if (!flag) {
				mes = '挿入項目の内容以外を入力できません。<br/>';
				break;
			}
		}
		if(start_flag == true){
			mes = '挿入項目の内容以外を入力できません。<br/>';
		}
		return mes;
	}
	return "";
}

function isInteger(x) {
    return x % 1 === 0;
}

//method作成
$.validator.addMethod('existTemplateName', function(value, element, param) {
	var check = true
	$.ajax({
		type: 'post',
        url: appRoot + 'Template/check_exist_templatename',
        async: false,
        data: {
            template_name: function() {
            	return $("#txtTemplateName").val();
            },
            template_id: function() {
            	return $("#hdTemplateId").val();
            },
        },
        success:function(data){
        	if(data == "false"){
        		check = false;
        	}
        },
    });
	return check;
}, "指定されたテンプレート名はすでに登録されています。");