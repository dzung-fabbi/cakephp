$(document).ready(function() {
	$(document).on('click', '#btnSubmitQues', function (e) {
		$("#slQuesType").removeAttr("disabled");
		var ques_no = $(this).attr("ques_no");
		var ques_type= $("#slQuesType").val();
		var validAddQues = validate_form(ques_type); //20160222 Add by Giang : #6495 - Bug 160 - focus to div error when add question

		if(validAddQues){ //20160222 Edit by Giang : #6495 - Bug 160 - focus to div error when add question
			$("#popupflash-error").show();
			$("#popupflash-error").html(validAddQues); //20160222 Edit by Giang : #6495 - Bug 160 - focus to div error when add question
			//20160224 Add by Giang : #6495 - Bug 160 - focus to div error when add question - begin
			if ($('.modal-body').scrollTop() > 0) {
				$('.modal-body').animate({ scrollTop: 0 }, 'slow');
			}
			//20160224 Add by Giang : #6495 - Bug 160 - focus to div error when add question - begin
		}else{
			//SMSセクション選択時の処理
			if (ques_type == QUESTION_SMS) {
				//通知番号SMSセクション数のカウント
				sms_question_count = 0;
				sms_input_question_count = 0;
				for (var arr_ques_no in glb_arr_ques) {
					if (glb_arr_ques[arr_ques_no]["question_type"] == QUESTION_SMS) {
						sms_question_count++;
					} else if (glb_arr_ques[arr_ques_no]["question_type"] == QUESTION_SMS_INPUT) {
						sms_input_question_count++;
					}
				}

				//通知番号SMS、番号指定SMSが1つ以上設定されている場合、メッセージを表示する。(上限値を超える場合は無視する)
				if ((sms_question_count >= 1 || sms_input_question_count >= 1) && sms_question_count <= QUESTION_SMS_LIMIT_COUNT) {
					alert("以下の項目は他のSMSセクション、番号指定SMSセクションにも反映されます。\n" +
						"・通知番号\n" +
						"・短縮URL\n" +
						"・送信不可音声\n"
					);
				}
			}

			//番号指定SMSセクション選択時の処理
			if (ques_type == QUESTION_SMS_INPUT) {
				//番号指定SMSセクション数のカウント
				sms_question_count = 0;
				sms_input_question_count = 0;
				for (var arr_ques_no in glb_arr_ques) {
					if (glb_arr_ques[arr_ques_no]["question_type"] == QUESTION_SMS) {
						sms_question_count++;
					} else if (glb_arr_ques[arr_ques_no]["question_type"] == QUESTION_SMS_INPUT) {
						sms_input_question_count++;
					}
				}

				//通知番号SMS、番号指定SMSが1つ以上設定されている場合、メッセージを表示する。(上限値を超える場合は無視する)
				if ((sms_question_count >= 1 || sms_input_question_count >= 1) && sms_input_question_count <= QUESTION_SMS_INPUT_LIMIT_COUNT) {
					alert("以下の項目は他のSMSセクション、番号指定SMSセクションにも反映されます。\n" +
						"・通知番号\n" +
						"・短縮URL\n" +
						"・送信不可音声\n"
					);
				}
			}
			$("#popupflash-error").hide();
			appendQues(ques_no);
			$("#dialog").modal("hide");
		}
	});

	$(document).on('change', '#slQuesType', function (e) {
		$("#add_ques").html(originalQuestion);
		$("#popupflash-error").html("").hide();
		ques_type = $("#slQuesType").val();
		ques_no_edit = $("#btnSubmitQues").attr("ques_no");
		var sms_phone_number;
		var sms_short_url;
		var sms_audio_content;
		var sms_ques_no;

		//SMS、番号指定SMSのカウント
		//既存SMSセクションの共通項目を取得
		var sms_question_count = 0;
		var sms_input_question_count = 0;

		if (ques_type == QUESTION_SMS || ques_type == QUESTION_SMS_INPUT) {
			for (var ques_no in glb_arr_ques) {
				if (glb_arr_ques[ques_no]["question_type"] == QUESTION_SMS) {
					sms_question_count++;
					sms_phone_number = glb_arr_ques[ques_no]["smsPhoneNumber"];
					sms_short_url = glb_arr_ques[ques_no]["sms_use_short_url"];
					sms_audio_content = glb_arr_ques[ques_no]["ques_sms_audio_content"];
					sms_ques_no = ques_no;
				} else if (glb_arr_ques[ques_no]["question_type"] == QUESTION_SMS_INPUT) {
					sms_input_question_count++;
					sms_phone_number = glb_arr_ques[ques_no]["smsInputPhoneNumber"];
					sms_short_url = glb_arr_ques[ques_no]["sms_input_use_short_url"];
					sms_audio_content = glb_arr_ques[ques_no]["ques_sms_input_audio_content"];
					sms_ques_no = ques_no;

				}
			}
		}
		for (var ques_no in glb_arr_ques) {
			if(glb_arr_ques[ques_no]["question_type"] == QUESTION_TRANS &&
					ques_type == QUESTION_TRANS &&
					ques_no_edit != ques_no){
				alert("転送質問は既に存在します為登録できません。");
				showDialogQues(QUESTION_VOICE);
				return;
			}
			if(glb_arr_ques[ques_no]["question_type"] == QUESTION_END &&
					ques_type == QUESTION_END &&
					ques_no_edit != ques_no){
				alert("切断質問は既に存在します為登録できません。");
				showDialogQues(QUESTION_VOICE);
				return;
			}
			if(glb_arr_ques[ques_no]["question_type"] == QUESTION_RECORD &&
					ques_type == QUESTION_RECORD &&
					ques_no_edit != ques_no){
				alert("録音質問は既に存在します為登録できません。");
				showDialogQues(QUESTION_VOICE);
				return;
			}
			if(glb_arr_ques[ques_no]["question_type"] == QUESTION_TIMEOUT &&
					ques_type == QUESTION_TIMEOUT &&
					ques_no_edit != ques_no){
				alert("タイムアウトは既に存在します為登録できません。");
				showDialogQues(QUESTION_VOICE);
				return;
			}

			if (ques_type == QUESTION_SMS &&
				sms_question_count >= QUESTION_SMS_LIMIT_COUNT
			) {
				alert("SMS送信は" + QUESTION_SMS_LIMIT_COUNT + "セクションまで登録可能です。");
				showDialogQues(QUESTION_VOICE);
				return;
			}

			if (ques_type == QUESTION_SMS_INPUT &&
				sms_input_question_count >= QUESTION_SMS_INPUT_LIMIT_COUNT
			) {
				alert("番号指定SMS送信は" + QUESTION_SMS_INPUT_LIMIT_COUNT + "セクションまで登録可能です。");
				showDialogQues(QUESTION_VOICE);
				return;
			}

			if (ques_type == QUESTION_SMS_INPUT && (sms_question_count >= 1 || sms_input_question_count >= 1)) {

				//通知番号のセット
				$('#slSMSInputPhoneNumber').val(sms_phone_number);

				//短縮URLのセット

				if (sms_short_url == 1) {
					$("#sms_input_use_short_url").prop("checked", true);
				} else {
					$("#sms_input_use_short_url").prop("checked", false);
				}
				setSMSInputState();

				// //送信不可音声のセット
				setSectionAudioInfo(sms_ques_no, "sms-input-error-audio", "ques_sms_input_audio_type", "ques_sms_input_audio_id");
				$('#txtAudioSmsInputErrorContent').val(sms_audio_content);

			}
			if (ques_type == QUESTION_SMS && (sms_question_count >= 1 || sms_input_question_count >= 1)) {
				//通知番号のセット
				$('#slSMSPhoneNumber').val(sms_phone_number);

				//短縮URLのセット
				if (sms_short_url == 1) {
					$("#sms_use_short_url").prop("checked", true);
				} else {
					$("#sms_use_short_url").prop("checked", false);
				}
				setSMSState();

				//送信不可音声のセット
				setSectionAudioInfo(sms_ques_no, "sms-error-audio", "ques_sms_audio_type", "ques_audio_id");
				$('#txtAudioSmsErrorContent').val(sms_audio_content);
			}
		}
		showDialogQues(ques_type);
	});

	$(document).on('change', '.rdAudio', function (e) {
		if($(this).val() == "1" || $(this).val() == "2"){
			//音声合成場合
			$(this).parents(".form-audio").find(".audio_mix").show();
			$(this).parents(".form-audio").find(".audio").hide();
			$(this).parents(".form-audio").find(".hdAudioId").val("");
			$(this).parents(".form-audio").find(".hdAudioName").val("");
			$(this).parents(".form-audio").find(".btnPlay").remove();
			$(this).parents(".form-audio").find(".btnStop").remove();
		}else{
			//音声ファイル場合
			$(this).parents(".form-audio").find(".audio_mix").hide();
			$(this).parents(".form-audio").find(".audio").show();
			$(this).parents(".form-audio").find(".txtAudioContent").val("");
		}
	});

	$(document).on('click', '.btnCustInfo', function (e) {
		var item = $(this).parents(".form-audio").find(".slCustInfo option:selected").text();
		txt = $(this).parents(".form-audio").find(".txtAudioContent").val();
		$(this).parents(".form-audio").find(".txtAudioContent").val(txt + "{" + item + "}");
	});

	$(document).on('click', '.btnUpload', function (e) {
		e.preventDefault();
		$(this).parents(".upload_file").find(".ipFile").val("");
		$(this).parents(".upload_file").find(".ipFile").click();
	});

	$(document).on('change', '#cbRecheckFlag', function (e) {
		if($(this).is(':checked')) {
			$(this).parents(".tblAddQues").find(".recheckAudio").show();
			$(this).parents(".tblAddQues").find(".recheckButtonNext").show();
		} else {
			resetAudio();
			$(this).parents(".tblAddQues").find(".recheckAudio").hide();
			$(this).parents(".tblAddQues").find(".recheckButtonNext").hide();
		}
	});

});

function resetAudio(){
	$('#tblRecheck .audio').show();
	$('#tblRecheck .audio_mix').hide();
	$('#tblRecheck input[type=radio][value=0]').prop('checked', true);
	$('#slRecheckNext').val(1);
	$('#slRecheckPrev').val(1);
	$('#tblRecheck .hdAudioId').val("");
	$('#tblRecheck .hdAudioName').val("");
	$('#tblRecheck .btnPlay').remove();
	$('#tblRecheck .btnStop').remove();
	$('#tblRecheck .txtAudioContent').val("");
	$('#tblRecheck .slCustInfo').val('tel_no');
}

function appendQues(ques_no) {

	var timeout_reflush_flag = false;
	//質問NO
	if(ques_no){
		ques_no = ques_no;
		$(".row_question").parent().find('.row_question').each(function(){
			if(($(this).find('.hdQuesNo').val()) == ques_no){
				ques_edit = $(this);
				$(ques_edit).html("");
				row = ques_edit;
			}
		});
	}else{
		var counter = 0;
		for (var i in glb_arr_ques) {
			//タイムアウトがあればtimeout_reflush_flagをtrueにする
			if (glb_arr_ques[i].question_type == 9){
				timeout_reflush_flag = true;
			}
			counter ++;
		}
		row = $("<div>",{class: "row row_question", ques_no: ques_no});
		ques_no = counter + 1;
		if($('#slQuesType').val() == '9'){
			row.appendTo(".timeout");
		} else{
			row.appendTo(".template");
		}
	}
	//質問数チェック
	if(ques_no > OUT_MAX_SECTION_COUNT){
		alert("テンプレート上の最大セクション数は" + OUT_MAX_SECTION_COUNT + "の為、これ以上のセクション追加ができません。");
	}else{
		//timeout_reflush_flagがtrueだったらタイムアウトの番号を更新
		if (timeout_reflush_flag) {
			$('.timeout').find('.hdQuesNo').val(ques_no);
			glb_arr_ques[ques_no] = glb_arr_ques[ques_no - 1];
			ques_no = ques_no - 1;
		}

		//追加した質問件数
		glb_arr_ques[ques_no] = new Object();
		$($("#form_add_call_list").serializeArray()).each(function(i, v) {
			glb_arr_ques[ques_no][v.name] = v.value;
		});

		//20160407 Add by Thai : #6898 - Bug update QUESTION_BASIC - Begin
		if (glb_arr_ques[ques_no]['question_type'] == QUESTION_BASIC) {
			var arr_answ = [1,2,3,4,5,6,7,8,9,0,51,52];
			for (var i=0; i<arr_answ.length; i++) {
				if (!glb_arr_ques[ques_no]['txtAnswContent' + arr_answ[i]] && !glb_arr_ques[ques_no]['cbYukoAnsw' + arr_answ[i]]) {
					glb_arr_ques[ques_no]['txtAnswJump' + arr_answ[i]] = '';
				}
			}
		}
		//20160407 Add by Thai : #6898 - Bug update QUESTION_BASIC - End

		// console.log(glb_arr_ques);
		var question_type = glb_arr_ques[ques_no]["question_type"];
		if(question_type == QUESTION_VOICE){
			htmlQuesVoice(row, glb_arr_ques[ques_no], ques_no);
		}else if(question_type == QUESTION_BASIC){
			htmlQuesBasic(row, glb_arr_ques[ques_no], ques_no);
		}else if(question_type == QUESTION_AUTH){
			htmlQuesAuth(row, glb_arr_ques[ques_no], ques_no);
			//20160420 Add by Thai : #6722 ADD QUESTION_AUTH_CHAR - Begin
		}else if(question_type == QUESTION_AUTH_CHAR){
			htmlQuesAuthChar(row, glb_arr_ques[ques_no], ques_no);
			//20160420 Add by Thai : #6722 ADD QUESTION_AUTH_CHAR - End
		}else if(question_type == QUESTION_TEL){
			htmlQuesTel(row, glb_arr_ques[ques_no], ques_no);
		}else if(question_type == QUESTION_TRANS){
			htmlQuesTrans(row, glb_arr_ques[ques_no], ques_no);
		}else if(question_type == QUESTION_RECORD){
			htmlQuesRecord(row, glb_arr_ques[ques_no], ques_no);
		}else if(question_type == QUESTION_COUNT){
			htmlQuesCount(row, glb_arr_ques[ques_no], ques_no);
		}else if(question_type == QUESTION_END){
			htmlQuesEnd(row, glb_arr_ques[ques_no], ques_no);
		}else if(question_type == QUESTION_TIMEOUT){
			htmlQuesTimeout(row, glb_arr_ques[ques_no], ques_no);
		} else if(question_type == QUESTION_SMS){
			for (var tmp_arr in glb_arr_ques) {
				if (glb_arr_ques[tmp_arr].question_type == QUESTION_SMS || glb_arr_ques[tmp_arr].question_type == QUESTION_SMS_INPUT) {
					//SMSプロパティを更新
					glb_arr_ques[tmp_arr].smsPhoneNumber = glb_arr_ques[ques_no].smsPhoneNumber;
					glb_arr_ques[tmp_arr].ques_sms_audio_type = glb_arr_ques[ques_no].ques_sms_audio_type;
					glb_arr_ques[tmp_arr].ques_audio_id = glb_arr_ques[ques_no].ques_audio_id;
					glb_arr_ques[tmp_arr].ques_audio_name = glb_arr_ques[ques_no].ques_audio_name;
					glb_arr_ques[tmp_arr].ques_sms_audio_content = glb_arr_ques[ques_no].ques_sms_audio_content;
					glb_arr_ques[tmp_arr].sms_use_short_url = glb_arr_ques[ques_no].sms_use_short_url;

					//番号指定SMSプロパティを更新
					glb_arr_ques[tmp_arr].smsInputPhoneNumber = glb_arr_ques[ques_no].smsPhoneNumber;
					glb_arr_ques[tmp_arr].ques_sms_input_audio_type = glb_arr_ques[ques_no].ques_sms_audio_type;
					glb_arr_ques[tmp_arr].ques_sms_input_audio_id = glb_arr_ques[ques_no].ques_audio_id;
					glb_arr_ques[tmp_arr].ques_sms_input_audio_name = glb_arr_ques[ques_no].ques_audio_name;
					glb_arr_ques[tmp_arr].ques_sms_input_audio_content = glb_arr_ques[ques_no].ques_sms_audio_content;
					glb_arr_ques[tmp_arr].sms_input_use_short_url = glb_arr_ques[ques_no].sms_use_short_url;
				}
			}
			htmlSMS(row, glb_arr_ques[ques_no], ques_no);
		} else if (question_type == QUESTION_SMS_INPUT) {
			for (var tmp_arr in glb_arr_ques) {
				if (glb_arr_ques[tmp_arr].question_type == QUESTION_SMS || glb_arr_ques[tmp_arr].question_type == QUESTION_SMS_INPUT) {
					//通知番号SMSプロパティを更新
					glb_arr_ques[tmp_arr].smsPhoneNumber = glb_arr_ques[ques_no].smsInputPhoneNumber;
					glb_arr_ques[tmp_arr].ques_sms_audio_type = glb_arr_ques[ques_no].ques_sms_input_audio_type;
					glb_arr_ques[tmp_arr].ques_audio_id = glb_arr_ques[ques_no].ques_sms_input_audio_id;
					glb_arr_ques[tmp_arr].ques_audio_name = glb_arr_ques[ques_no].ques_sms_input_audio_name;
					glb_arr_ques[tmp_arr].ques_sms_audio_content = glb_arr_ques[ques_no].ques_sms_input_audio_content;
					glb_arr_ques[tmp_arr].sms_use_short_url = glb_arr_ques[ques_no].sms_input_use_short_url;

					//番号指定SMSプロパティを更新
					glb_arr_ques[tmp_arr].smsInputPhoneNumber = glb_arr_ques[ques_no].smsInputPhoneNumber;
					glb_arr_ques[tmp_arr].ques_sms_input_audio_type = glb_arr_ques[ques_no].ques_sms_input_audio_type;
					glb_arr_ques[tmp_arr].ques_sms_input_audio_id = glb_arr_ques[ques_no].ques_sms_input_audio_id;
					glb_arr_ques[tmp_arr].ques_sms_input_audio_name = glb_arr_ques[ques_no].ques_sms_input_audio_name;
					glb_arr_ques[tmp_arr].ques_sms_input_audio_content = glb_arr_ques[ques_no].ques_sms_input_audio_content;
					glb_arr_ques[tmp_arr].sms_input_use_short_url = glb_arr_ques[ques_no].sms_input_use_short_url;
				}
			}

			htmlQuesSmsInput(row, glb_arr_ques[ques_no], ques_no);
		}

		updateQuesNo();
		renderSelectJumpQues();
	}
}

function htmlAudio(audio_id, audio_type, audio_name, audio_content){
	if(audio_type == 0){
		tmp = 	'<div class="col-md-3">' +
					'<p><label>' + audio_name + '</label></p>' +
				'</div>' +
				'<div class="col-md-7">' +
					'<p>' +
						'<a class="btn btnPlay btn-default" audio_id="' + audio_id + '">' +
							'<i class="glyphicon glyphicon-play"></i>' +
						'</a> \n' +
						'<a class="btn btnStop btn-default">' +
							'<i class="glyphicon glyphicon-stop"></i>' +
						'</a>' +
					'</p>' +
				'</div>';
	}else if(audio_type == 1 || audio_type == 2){
		tmp = '<p>'+audio_content+'</p>';
	}
	return tmp;
}

function htmlRecheckAudio(recheck_flag, audio_id, audio_type, audio_name, audio_content){
	var recheck = [];
	if(recheck_flag == 0){
		recheck['tmp'] = '<p>なし</p>';
		recheck['content'] = '';
	}else{
		if(audio_type == 1 || audio_type == 2){
			recheck['tmp'] = '<p>あり</p>';
			recheck['content'] = '<div class="row">' +
										'<div class="col-md-2">' +
										'<p>繰返確認音声</p>' +
									'</div>' +
									'<div class="col-md-10">' +
										audio_content +
									'</div>' +
								'</div>';
		}else if(audio_type == 0){
			recheck['tmp'] = '<p>あり</p>';
			recheck['content'] = '<div class="row">' +
									'<div class="col-md-2">' +
										'<p>繰返確認音声</p>' +
									'</div>' +
									'<div class="col-md-10">' +
										'<div class="col-md-3">' +
											'<p><label>' + audio_name + '</label></p>' +
										'</div>' +
										'<div class="col-md-7">' +
											'<p>' +
												'<a class="btn btnPlay btn-default" audio_id="' + audio_id + '">' +
													'<i class="glyphicon glyphicon-play"></i>' +
												'</a> \n' +
												'<a class="btn btnStop btn-default">' +
													'<i class="glyphicon glyphicon-stop"></i>' +
												'</a>' +
											'</p>' +
										'</div>' +
									'</div>' +
								'</div>';
		}
	}
	return recheck;
}

function htmlAnswer(data){
	arr_answ = [1,2,3,4,5,6,7,8,9,0,51,52,99];
	var tmp = "";
	for(var i=0; i < arr_answ.length; i++){
		if(data["cbYukoAnsw"+arr_answ[i]] || data["txtAnswContent"+arr_answ[i]] != ""){
			if(arr_answ[i] != 99){
				if(data["cbYukoAnsw"+arr_answ[i]]) yuko = '<span class="label-success label label-default">〇</span>';
				else yuko = '<span class="label-default label">×</span>';
				if(arr_answ[i] == 51) answer_no = "*";
				else if(arr_answ[i] == 52) answer_no = "#";
				else answer_no = arr_answ[i];
				tmp = tmp +
							'<tr>' +
								'<td class="alignCenter">' + answer_no + '</td>' +
								'<td>' + data["txtAnswContent"+arr_answ[i]] + '</td>' +
								'<td class="alignCenter">' +
									yuko +
								'</td>' +
								'<td class="alignCenter select_jump_ques_container" jump_question="' + data['txtAnswJump' + arr_answ[i]] + '" ans_no="' + arr_answ[i] + '">' + '</td>' +
							'</tr>';
			}
		}
	}
	//20160224 Add by Thai : #6519 - Update select jump question - Begin
	tmp = tmp +
		'<tr>' +
			'<td colspan="3">タイムアウト</td>' +
			'<td class="alignCenter select_jump_ques_container" jump_question="' + data['txtAnswJump99'] + '" ans_no="99">' + '</td>' +
		'</tr>';
	tmp = tmp +
		'<tr>' +
			'<td colspan="3">他の場合</td>' +
			'<td class="alignCenter select_jump_ques_container" jump_question="' + data['jump_question'] + '">' +
			'</td>' +
		'</tr>';
	//20160224 Add by Thai : #6519 - Update select jump question - End
	return tmp;

}

function htmlAnswerAuth(data){
	arr_answ_title = ["入力値 ＜ 認証項目","入力値 ＝ 認証項目","入力値 ＞ 認証項目", 99];
	var tmp = "";
	for(var i=1; i <= arr_answ_title.length; i++){
		if(i != arr_answ_title.length){
			if(data["cbYukoAnswAuth"+i]) yuko = '<span class="label-success label label-default">〇</span>';
			else yuko = '<span class="label-default label">×</span>';
			tmp = tmp +
						'<tr>' +
							'<td>' + arr_answ_title[i-1] + '</td>' +
							'<td>' + data["txtAnswContentAuth"+i] + '</td>' +
							'<td class="alignCenter">' +
								yuko +
							'</td>' +
							'<td class="alignCenter select_jump_ques_container" jump_question="' + data['txtAnswJumpAuth' + i] + '" ans_no="' + i + '">' + '</td>' +
						'</tr>';
		}else{
			//20160224 Edit by Thai : #6519 - Update select jump question - Begin
			tmp = tmp +
				'<tr>' +
					'<td colspan="3">タイムアウト</td>' +
					'<td class="alignCenter select_jump_ques_container" jump_question="' + data['txtAnswJumpAuth99'] + '" ans_no="99">' + '</td>' +
				'</tr>';
			//20160224 Edit by Thai : #6519 - Update select jump question - End
		}
	}

	//20160224 Add by Thai : #6519 - Update select jump question - Begin
	tmp = tmp +
		'<tr>' +
			'<td colspan="3">他の場合</td>' +
			'<td class="alignCenter select_jump_ques_container" jump_question="' + data['jump_question'] + '">' +
			'</td>' +
		'</tr>';
	//20160224 Add by Thai : #6519 - Update select jump question - End
	return tmp;

}

//20160420 Add by Thai : #6722 ADD QUESTION_AUTH_CHAR - Begin
function htmlAnswerAuthChar(data){
	var arr_answ_title = ["入力値 ＝ 認証項目", "入力値 ≠ 認証項目", 99];
	var tmp = "";
	var yuko = "";
	for(var i=1; i <= arr_answ_title.length; i++){
		if(i != arr_answ_title.length){
			if (data["cbYukoAnswAuthChar"+i])
				yuko = '<span class="label-success label label-default">〇</span>';
			else
				yuko = '<span class="label-default label">×</span>';
			tmp = 	tmp +
						'<tr>' +
							'<td class="alignCenter">' + arr_answ_title[i-1] + '</td>' +
							'<td>' + data["txtAnswContentAuthChar"+i] + '</td>' +
							'<td class="alignCenter">' + yuko + '</td>' +
							'<td class="alignCenter select_jump_ques_container" jump_question="' + data['txtAnswJumpAuthChar' + i] + '" ans_no="' + i + '">' + '</td>' +
						'</tr>';
		}
	}
	tmp = 	tmp +
				'<tr>' +
					'<td colspan="3">タイムアウト</td>' +
					'<td class="alignCenter select_jump_ques_container" jump_question="' + data['txtAnswJumpAuthChar99'] + '" ans_no="99">' + '</td>' +
				'</tr>';

	return tmp;
}
//20160420 Add by Thai : #6722 ADD QUESTION_AUTH_CHAR - End

function htmlHeader(data, ques_no, ques_type_txt){
	if(data["id"]){
		ques_id = data["id"];
	}else ques_id = "";
	if(data["question_yuko"] > 0){
		var question_yuko = '<span class="label-success label label-default">有効</span>';
	}else{
		var question_yuko = "";
	}
	tmp = '<div class="box-header well" data-original-title="">' +
			'<h2><span class="ques_no">' + ques_no + '</span>. <span class="ques_type_txt">' + ques_type_txt + '</span></h2>' +
			'<span class="ques_title">&nbsp;&nbsp;&nbsp;&nbsp;'+ data["question_title"] +'</span>\n' +
			question_yuko +
			'<div class="box-icon">' +
				'<input type="text" name="id" class="hdQuesId" value="'+ques_id+'" style="display: none;">' +
				'<input type="text" class="hdQuesNo" value="'+ques_no+'" style="display: none;">' +
				'<a href="#" class="btn btnEdit btn-round btn-default" ques_no="'+ques_no+'"><i title="編集" class="glyphicon glyphicon-edit"></i></a>' +
				'<a href="#" class="btn btnDelete btn-round btn-default" ques_no="'+ques_no+'"><i title="削除" class="glyphicon glyphicon-trash"></i></a>' +
				'<a href="#" class="btn btnShowHide btn-round btn-default"><i title="最小化/最大化" class="glyphicon glyphicon-chevron-up"></i></a>';
	if(ques_type_txt != "タイムアウト") {
		tmp = tmp +	'<a href="#" class="btn btnMove btn-round btn-default"><i title="位置移動" class="glyphicon glyphicon-move"></i></a>';
	}
	tmp = tmp +
			'</div>' +
		'</div>';
	return tmp;
}

function htmlQuesVoice(row, data, ques_no){
	var audio = htmlAudio(data["audio_id"], data["audio_type"], data["audio_name"], data["audio_content"]);
	var header = htmlHeader(data, ques_no, "再生");
	var html = '<div class="box col-md-12">' +
					'<div class="box-inner">' +
						header +
						'<div class="box-content">' +
							'<div class="row">' +
								'<div class="col-md-2">' +
									'<p>飛び先</p>' +
								'</div>' +
								'<div class="col-md-2 select_jump_ques_container" jump_question="' + data['jump_question'] + '"></div>' +
							'</div>' +
							'<div class="row">' +
								'<div class="col-md-2">' +
									'<p>音声</p>' +
								'</div>' +
								'<div class="col-md-10">' +
									audio +
								'</div>' +
							'</div>' +
						'</div>' +
					'</div>' +
				'</div>'
	$(row).append(html);
}

function htmlQuesBasic(row, data, ques_no){
	var audio = htmlAudio(data["audio_id"], data["audio_type"], data["audio_name"], data["audio_content"]);
	var answer = htmlAnswer(data);
	var header = htmlHeader(data, ques_no, "質問");
	if(data["question_repeat"] > 0){
		question_repeat = data["question_repeat"] + "回";
	}else{
		question_repeat = "なし";
	}
//	if(data["question_yuko"] > 0){
//		var question_yuko = "あり";
//	}else{
//		var question_yuko = "なし";
//	}
	var html = '<div class="box col-md-12">' +
					'<div class="box-inner">' +
						header +
						'<div class="box-content">' +
//							'<div class="row">' +
//								'<div class="col-md-2"><p>有効質問</p></div>' +
//								'<div class="col-md-10">' +
//										'<p>' + question_yuko + '</p>' +
//								'</div>' +
//							'</div>' +
							'<div class="row">' +
								'<div class="col-md-2"><p>音声</p></div>' +
								'<div class="col-md-10">' +	audio +	'</div>' +
							'</div>' +
							'<div class="row">' +
								'<div class="col-md-2">' +
									'<p>繰り返し</p>' +
								'</div>' +
								'<div class="col-md-10">' +
									'<p>' + question_repeat + '</p>' +
								'</div>' +
							'</div>' +
							'<div class="row">' +
								'<div class="col-md-8">' +
									'<p>回答</p>' +
									'<table class="table table-bordered table-striped table-condensed">' +
										'<thead>' +
											'<tr>' +
												'<th class="alignCenter templateTable-60">番号</th>' +
												'<th class="alignCenter templateTable-40">テキスト</th>' +
												'<th class="alignCenter templateTable-60">有効</th>' +
												'<th class="alignCenter col-md-3">飛び先</th>' +
											'</tr>' +
										'</thead>' +
										'<tbody>' +
											answer +
										'</tbody>' +
									'</table>' +
								'</div>' +
							'</div>' +
						'</div>' +
					'</div>' +
				'</div>';
	$(row).append(html);
}

function htmlQuesAuth(row, data, ques_no){
	var audio = htmlAudio(data["audio_id"], data["audio_type"], data["audio_name"], data["audio_content"]);
	var header = htmlHeader(data, ques_no, getQuesTypeTxtByQuesType(QUESTION_AUTH));
	var answer_auth = htmlAnswerAuth(data);
	if(data["recheck_flag"]){
		var recheck_button_next = data["recheck_button_next"];
		if(recheck_button_next == '51')
			recheck_button_next = '*';
		else if(recheck_button_next == '52')
			recheck_button_next = '#';
		recheck_flag = 1;
		button_next = '<div class="row">' +
							'<div class="col-md-2">' +
								'<p>正番号</p>' +
							'</div>' +
							'<div class="col-md-10">' + recheck_button_next +
							'</div>' +
						'</div>';
	} else{
		recheck_flag = 0;
		button_next = "";
	}
	var recheck = htmlRecheckAudio(recheck_flag, data["recheck_audio_id"], data["recheck_audio_type"], data["recheck_audio_name"], data["recheck_audio_content"]);
	var auth_item = data["auth_item"];
//	if(data["question_yuko"] > 0){
//		var question_yuko = "あり";
//	}else{
//		var question_yuko = "なし";
//	}
	var html = 	'<div class="box col-md-12">' +
					'<div class="box-inner">' +
						header +
						'<div class="box-content">' +
//							'<div class="row">' +
//								'<div class="col-md-2"><p>有効質問</p></div>' +
//								'<div class="col-md-10">' +
//										'<p>' + question_yuko + '</p>' +
//								'</div>' +
//							'</div>' +
							'<div class="row">' +
								'<div class="col-md-2">' +
									'<p>音声</p>' +
								'</div>' +
								'<div class="col-md-10">' +
									audio +
								'</div>' +
							'</div>' +
							'<div class="row">' +
								'<div class="col-md-2">' +
									'<p>認証項目</p>' +
								'</div>' +
								'<div class="col-md-10">' +
								auth_item +
								'</div>' +
							'</div>' +
							'<div class="row">' +
								'<div class="col-md-2">' +
									'<p>桁数</p>' +
								'</div>' +
								'<div class="col-md-10">' + data["digit_auth"] +
								'</div>' +
							'</div>' +
							'<div class="row">' +
								'<div class="col-md-2"><p>繰返確認</p></div>' +
								'<div class="col-md-10">' + recheck['tmp'] + '</div>' +
							'</div>' +
							recheck['content'] +
							button_next +
							'<div class="row">' +
								'<div class="col-md-8">' +
									'<p>回答</p>' +
									'<table class="table table-bordered table-striped table-condensed">' +
										'<thead>' +
											'<tr>' +
												'<th class="alignCenter templateTable-140">判断</th>' +
												'<th class="alignCenter templateTable-40">テキスト</th>' +
												'<th class="alignCenter templateTable-60">有効</th>' +
												'<th class="alignCenter col-md-3">飛び先</th>' +
											'</tr>' +
										'</thead>' +
										'<tbody>' +
											answer_auth +
										'</tbody>' +
									'</table>' +
								'</div>' +
							'</div>' +
						'</div>' +
					'</div>' +
				'</div>';
	$(row).append(html);
}

//20160420 Add by Thai : #6722 ADD QUESTION_AUTH_CHAR - Begin
function htmlQuesAuthChar(row, data, ques_no){
	var audio = htmlAudio(data["audio_id"], data["audio_type"], data["audio_name"], data["audio_content"]);
	var header = htmlHeader(data, ques_no, getQuesTypeTxtByQuesType(QUESTION_AUTH_CHAR));
	var answer_auth = htmlAnswerAuthChar(data);
	var recheck_flag = 0;
	var button_next = "";
	if(data["recheck_flag"]){
		var recheck_button_next = data["recheck_button_next"];
		if(recheck_button_next == '51')
			recheck_button_next = '*';
		else if(recheck_button_next == '52')
			recheck_button_next = '#';
		recheck_flag = 1;
		button_next = 	'<div class="row">' +
							'<div class="col-md-2">' +
								'<p>正番号</p>' +
							'</div>' +
							'<div class="col-md-10">' + recheck_button_next +
							'</div>' +
						'</div>';
	}
	var recheck = htmlRecheckAudio(recheck_flag, data["recheck_audio_id"], data["recheck_audio_type"], data["recheck_audio_name"], data["recheck_audio_content"]);
	var auth_item = data["auth_item"];
	var html = 	'<div class="box col-md-12">' +
					'<div class="box-inner">' +
						header +
						'<div class="box-content">' +
							'<div class="row">' +
								'<div class="col-md-2">' +
									'<p>音声</p>' +
								'</div>' +
								'<div class="col-md-10">' +
									audio +
								'</div>' +
							'</div>' +
							'<div class="row">' +
								'<div class="col-md-2">' +
									'<p>認証項目</p>' +
								'</div>' +
								'<div class="col-md-10">' +
									auth_item +
								'</div>' +
							'</div>' +
							'<div class="row">' +
								'<div class="col-md-2">' +
									'<p>桁数</p>' +
								'</div>' +
								'<div class="col-md-10">' +
									data["digit_auth"] +
								'</div>' +
							'</div>' +
							'<div class="row">' +
								'<div class="col-md-2">' +
									'<p>繰返確認</p>' +
								'</div>' +
								'<div class="col-md-10">' +
									recheck['tmp'] +
								'</div>' +
							'</div>' +
							recheck['content'] + button_next +
							'<div class="row">' +
								'<div class="col-md-8">' +
									'<p>回答</p>' +
									'<table class="table table-bordered table-striped table-condensed">' +
										'<thead>' +
											'<tr>' +
												'<th class="alignCenter templateTable-140">判断</th>' +
												'<th class="alignCenter templateTable-40">テキスト</th>' +
												'<th class="alignCenter templateTable-60">有効</th>' +
												'<th class="alignCenter col-md-3">飛び先</th>' +
											'</tr>' +
										'</thead>' +
										'<tbody>' +
											answer_auth +
										'</tbody>' +
									'</table>' +
								'</div>' +
							'</div>' +
						'</div>' +
					'</div>' +
				'</div>';
	$(row).append(html);
}
//20160420 Add by Thai : #6722 ADD QUESTION_AUTH_CHAR - End

function htmlQuesTel(row, data, ques_no){
	var audio = htmlAudio(data["audio_id"], data["audio_type"], data["audio_name"], data["audio_content"]);
	var header = htmlHeader(data, ques_no, "番号入力");
	if(data["recheck_flag"]){
		var recheck_button_next = data["recheck_button_next"];
		if(recheck_button_next == '51')
			recheck_button_next = '*';
		else if(recheck_button_next == '52')
			recheck_button_next = '#';
		recheck_flag = 1;
		button_next = '<div class="row">' +
							'<div class="col-md-2">' +
								'<p>正番号</p>' +
							'</div>' +
							'<div class="col-md-10">' + recheck_button_next +
							'</div>' +
						'</div>';
	}
	else{
		recheck_flag = 0;
		button_next = "";
	}
	var recheck = htmlRecheckAudio(recheck_flag, data["recheck_audio_id"], data["recheck_audio_type"], data["recheck_audio_name"], data["recheck_audio_content"]);
	var html = 	'<div class="box col-md-12">' +
					'<div class="box-inner">' +
						header +
						'<div class="box-content">' +
							'<div class="row">' +
								'<div class="col-md-2">' +
									'<p>飛び先</p>' +
								'</div>' +
								'<div class="col-md-2 select_jump_ques_container" jump_question="' + data['jump_question'] + '"></div>' +
							'</div>' +
							'<div class="row">' +
								'<div class="col-md-2">' +
									'<p>タイムアウト</p>' +
								'</div>' +
								'<div class="col-md-2 select_jump_ques_container" jump_question="' + data['txtAnswJumpTel99'] + '" ans_no="99">' + '"></div>' +
							'</div>' +
							'<div class="row">' +
								'<div class="col-md-2"><p>音声</p></div>' +
								'<div class="col-md-10">' + audio + '</div>' +
							'</div>' +

							'<div class="row">' +
								'<div class="col-md-2"><p>桁数</p></div>' +
								'<div class="col-md-10">' + data["digit_tel"] + '</div>' +
							'</div>' +

							'<div class="row">' +
								'<div class="col-md-2"><p>繰返確認</p></div>' +
								'<div class="col-md-10">' + recheck['tmp'] + '</div>' +
							'</div>' +
							recheck['content'] +
							button_next +
						'</div>' +
					'</div>' +
				'</div>';
	$(row).append(html);
}

function htmlQuesTrans(row, data, ques_no){
	var header = htmlHeader(data, ques_no, "転送");
	var audio_trans = htmlAudio(data["trans_audio_id"], data["trans_audio_type"], data["trans_audio_name"], data["trans_audio_content"]);
	var audio_trans_time_out = htmlAudio(data["trans_timeout_audio_id"], data["trans_timeout_audio_type"], data["trans_timeout_audio_name"], data["trans_timeout_audio_content"]);
	var trans_empty_seat_flag = data["trans_empty_seat_flag"];
	if(trans_empty_seat_flag == 1){
		empty_seat_flag = "あり";
	}else{
		empty_seat_flag = "なし";
	}

	var trans_phone_number_play_flag = data["trans_phone_number_play_flag"];
	if(trans_phone_number_play_flag == 1){
		phone_number_play_flag = "あり";
	}else{
		phone_number_play_flag = "なし";
	}


	var html = 	'<div class="box col-md-12">' +
					'<div class="box-inner">' +
						header +
						'<div class="box-content">' +
							'<div class="row">' +
								'<div class="col-md-2"><p>転送飛び先音声</p></div>' +
								'<div class="col-md-10">' + audio_trans + '</div>' +
							'</div>' +

							'<div class="row">' +
								'<div class="col-md-2"><p>転送タイムアウト音声</p></div>' +
								'<div class="col-md-10">' + audio_trans_time_out + '</div>' +
							'</div>' +

							'<div class="row">' +
								'<div class="col-md-2"><p>転送先電話番号</p></div>' +
								'<div class="col-md-10">' + data["trans_tel"] + '</div>' +
							'</div>' +

							'<div class="row">' +
								'<div class="col-md-2"><p>転送先席数</p></div>' +
								'<div class="col-md-10">' + data["trans_seat_num"] + '</div>' +
							'</div>' +

							'<div class="row">' +
								'<div class="col-md-2"><p>空き席数無し時<br>発信停止</p></div>' +
								'<div class="col-md-10">' + empty_seat_flag + '</div>' +
							'</div>' +

							'<div class="row">' +
								'<div class="col-md-2"><p>転送タイムアウト(秒)</p></div>' +
								'<div class="col-md-10">' + data["trans_timeout"] + '</div>' +
							'</div>' +

							'<div class="row">' +
								'<div class="col-md-2"><p>転送元番号再生</p></div>' +
								'<div class="col-md-10">' + phone_number_play_flag + '</div>' +
							'</div>' +

						'</div>' +
					'</div>' +
				'</div>';
	$(row).append(html);
}

function htmlQuesRecord(row, data, ques_no){
	var header = htmlHeader(data, ques_no, "録音");
	var audio = htmlAudio(data["audio_id"], data["audio_type"], data["audio_name"], data["audio_content"]);
	if(data["yuko_button_record"] == 1){
		yuko_button_record = "あり";
	}else{
		yuko_button_record = "なし";
	}

	var html = 	'<div class="box col-md-12">' +
					'<div class="box-inner">' +
						header +
						'<div class="box-content">' +
							'<div class="row">' +
								'<div class="col-md-2">' +
								'	<p>飛び先</p>' +
								'</div>' +
								'<div class="col-md-2 select_jump_ques_container" jump_question="' + data['jump_question'] + '"></div>' +
							'</div>' +
							'<div class="row">' +
								'<div class="col-md-2">' +
									'<p>音声</p>' +
								'</div>' +
								'<div class="col-md-10">' +
									audio +
								'</div>' +
							'</div>' +
							'<div class="row">' +
								'<div class="col-md-2">' +
									'<p>秒数</p>' +
								'</div>' +
								'<div class="col-md-10">' +
									data["second_record"] +
								'</div>' +
							'</div>' +
							'<div class="row">' +
								'<div class="col-md-2">' +
									'<p>#ボタン終了</p>' +
								'</div>' +
								'<div class="col-md-10">' +
									yuko_button_record +
								'</div>' +
							'</div>' +
						'</div>' +
					'</div>' +
				'</div>';
	$(row).append(html);
}

function htmlQuesCount(row, data, ques_no){
	var header = htmlHeader(data, ques_no, "カウント");
	var html = 	'<div class="box col-md-12">' +
					'<div class="box-inner">' +
						header +
						'<div class="box-content">' +
							'<div class="row">' +
								'<div class="col-md-2">' +
									'<p>飛び先</p>' +
								'</div>' +
								'<div class="col-md-2 select_jump_ques_container" jump_question="' + data['jump_question'] + '"></div>' +
							'</div>' +
						'</div>' +
				'</div>';
	$(row).append(html);
}

function htmlQuesEnd(row, data, ques_no){
	var header = htmlHeader(data, ques_no, "切断");
	var html = 	'<div class="box col-md-12">' +
					'<div class="box-inner">' +
						header +
					'</div>' +
				'</div>';
	$(row).append(html);
}

function htmlQuesTimeout(row, data, ques_no){
	var audio = htmlAudio(data["audio_id"], data["audio_type"], data["audio_name"], data["audio_content"]);
	var header = htmlHeader(data, ques_no, "タイムアウト");
	var html = '<div class="box col-md-12">' +
					'<div class="box-inner">' +
						header +
						'<div class="box-content">' +
							'<div class="row">' +
								'<div class="col-md-2">' +
									'<p>音声</p>' +
								'</div>' +
								'<div class="col-md-10">' +
									audio +
								'</div>' +
							'</div>' +
						'</div>' +
					'</div>' +
				'</div>'
	$(row).append(html);
}

//20160224 Add by Thai : #6519 - Update select jump question - Begin
function renderSelectJumpQues() {
	var question_no = 0;
	var question_type_txt = '';
	var question_title = '';
	var label_option = '';
	var value_option = '';

	$('.select_jump_ques_container').each(function (e) {
		var select = $(this);
		var old_value;
		var set_flag = false;

		if ($(this).find('select').size() > 0) {
			old_value = $(this).find('select').first().val();
		} else if ($(this).attr('jump_question') != '') {
			old_value = $(this).attr('jump_question');
		} else {
			old_value = '';
		}

		var tmp = '<select class="form-control select_jump_ques" id="select_jump_ques_' + e + '">';
		tmp = tmp + '<option value=""></option>';

		$('.box-header').each(function (index) {
			question_no = index + 1;
			question_type_txt = $(this).find('.ques_type_txt').html();
			question_title = $(this).find('.ques_title').html();

			label_option = question_no + '.' + question_type_txt + ' ' + question_title;
			value_option = question_no;

			var question_type = getQuesTypeByQuesTypeTxt(question_type_txt);
			if (question_type != QUESTION_TIMEOUT) {
				if (value_option == old_value) {
					tmp = tmp + '<option value="' + value_option + '" selected>' + label_option + '</option>';
					set_flag = true;
				} else {
					tmp = tmp + '<option value="' + value_option + '">' + label_option + '</option>';
				}
			}
		});

		tmp = tmp + '</select>';
		select.html(tmp);

		if (old_value != '' && !set_flag) {
			updateDataWhenSelectJumpQues($('#select_jump_ques_' + e));
		}
	});
}

function getQuesTypeByQuesTypeTxt(ques_type_txt) {
	ques_type_txt = ques_type_txt.trim();
	var arr_ques_type = {
		'数値認証' : QUESTION_AUTH,
		'文字列認証' : QUESTION_AUTH_CHAR,
		'質問' : QUESTION_BASIC,
		'カウント' : QUESTION_COUNT,
		'切断' : QUESTION_END,
		'録音' : QUESTION_RECORD,
		'番号入力' : QUESTION_TEL,
		'転送' : QUESTION_TRANS,
		'再生' : QUESTION_VOICE,
		'タイムアウト': QUESTION_TIMEOUT,
		'SMS': QUESTION_SMS,
		'番号指定SMS送信': QUESTION_SMS_INPUT
	};
	return arr_ques_type[ques_type_txt];
}

//20160420 Add by Thai : #6722 ADD QUESTION_AUTH_CHAR - Begin
function getQuesTypeTxtByQuesType(ques_type) {
	var arr_ques_type_txt = [];
	arr_ques_type_txt[QUESTION_AUTH] = '数値認証';
	arr_ques_type_txt[QUESTION_AUTH_CHAR] = '文字列認証';
	arr_ques_type_txt[QUESTION_BASIC] = '質問';
	arr_ques_type_txt[QUESTION_COUNT] = 'カウント';
	arr_ques_type_txt[QUESTION_END] = '切断';
	arr_ques_type_txt[QUESTION_RECORD] = '録音';
	arr_ques_type_txt[QUESTION_TEL] = '番号入力';
	arr_ques_type_txt[QUESTION_TRANS] = '転送';
	arr_ques_type_txt[QUESTION_VOICE] = '再生';
	arr_ques_type_txt[QUESTION_TIMEOUT] = 'タイムアウト';
	arr_ques_type_txt[QUESTION_SMS] = 'SMS';
	arr_ques_type_txt[QUESTION_SMS_INPUT] = '番号指定SMS送信';

	return arr_ques_type_txt[ques_type];
}
//20160420 Add by Thai : #6722 ADD QUESTION_AUTH_CHAR - End

function updateDataWhenSelectJumpQues(element) {
	var ques_no = element.parents('.box-inner').find('.ques_no').html();
	var ques_type_txt = element.parents('.box-inner').find('.ques_type_txt').html();
	var ques_type = getQuesTypeByQuesTypeTxt(ques_type_txt);
	var ans_no = element.parent().attr('ans_no');

	if (typeof ans_no != 'undefined') {
		if (ques_type == QUESTION_BASIC) {
			glb_arr_ques[ques_no]['txtAnswJump' + ans_no] = element.val();
		} else if (ques_type == QUESTION_AUTH) {
			glb_arr_ques[ques_no]['txtAnswJumpAuth' + ans_no] = element.val();
			//20160420 Add by Thai : #6722 ADD QUESTION_AUTH_CHAR - Begin
		} else if (ques_type == QUESTION_AUTH_CHAR) {
			glb_arr_ques[ques_no]['txtAnswJumpAuthChar' + ans_no] = element.val();
			//20160420 Add by Thai : #6722 ADD QUESTION_AUTH_CHAR - End
		} else if (ques_type == QUESTION_TEL) {
			glb_arr_ques[ques_no]['txtAnswJumpTel' + ans_no] = element.val();
		} else if (ques_type == QUESTION_SMS) {
			glb_arr_ques[ques_no]['txtAnswJumpSms' + ans_no] = element.val();
		} else if (ques_type == QUESTION_SMS_INPUT) {
			if (ans_no == 98) {
				glb_arr_ques[ques_no]['txtAnswJumpSmsInputTimeOut' + ans_no] = element.val();
			} else {
				glb_arr_ques[ques_no]['txtAnswJumpSmsInput' + ans_no] = element.val();
			}
		}
	} else {
		glb_arr_ques[ques_no]['jump_question'] = element.val();
	}
}
//20160224 Add by Thai : #6519 - Update select jump question - End
// 20161121 Add By LinhNT #8551
function htmlSMS(row, data, ques_no) {
	var header = htmlHeader(data, ques_no, getQuesTypeTxtByQuesType(QUESTION_SMS));
	var sms_use_short_url_flag = data["sms_use_short_url"];
	if(sms_use_short_url_flag == 1){
		sms_use_short_url_val = "あり";
	}else{
		sms_use_short_url_val = "なし";
	}
	var audio = htmlAudio(data["ques_audio_id"], data["ques_sms_audio_type"], data["ques_audio_name"], data["ques_sms_audio_content"]);
	var html = '' +
		'<div class="box col-md-12">' +
			'<div class="box-inner">' +
				header +
				'<div class="box-content">' +
					'<div class="row">' +
						'<div class="col-md-2">' +
							'<p>飛び先</p>' +
						'</div>' +
						'<div class="col-md-2 select_jump_ques_container" jump_question="' + data['jump_question'] + '"></div>' +
					'</div>' +
					'<div class="row">' +
					'<div class="col-md-2">' +
					'<p>送信不可</p>' +
					'</div>' +
					'<div class="col-md-2 select_jump_ques_container" jump_question="' + data['txtAnswJumpSms99']+ '" ans_no="99"></div>' +
					'</div>' +
					'<div class="row">' +
						'<div class="col-md-2">' +
							'<p>通知番号</p>' +
						'</div>' +
						'<div class="col-md-10 sms-common-phonenumber">' +
							data['smsPhoneNumber'] +
						'</div>' +
					'</div>' +
					'<div class="row">' +
						'<div class="col-md-2">' +
							'<p>本文</p>' +
						'</div>' +
						'<div class="col-md-10">' + data['smsBodyContent'] + '</div>' +
					'</div>' +
					'<div class="row">' +
						'<div class="col-md-2">' +
							'<p>短縮URL</p>' +
						'</div>' +
						'<div class="col-md-10 sms-short-url">' + sms_use_short_url_val + '</div>' +
					'</div>' +
			'<div class="row">' +
						'<div class="col-md-2">' +
							'<p>送信不可音声</p>' +
						'</div>' +
						'<div class="col-md-10 sms-common-audio">' + audio + '</div>' +
					'</div>' +
			'</div>' +
			'</div>' +
		'</div>';
	$(row).append(html);
	$('.sms-common-phonenumber').text(data['smsPhoneNumber']);
	$('.sms-short-url').text(sms_use_short_url_val);
	$('.sms-common-audio').html(audio);
}
function htmlQuesSmsInput(row, data, ques_no){
	var audio = htmlAudio(data["audio_id"], data["audio_type"], data["audio_name"], data["audio_content"]);
	var header = htmlHeader(data, ques_no, getQuesTypeTxtByQuesType(QUESTION_SMS_INPUT));
	var sms_input_use_short_url_flag = data["sms_input_use_short_url"];
	var sms_input_use_short_url_val;
	if(sms_input_use_short_url_flag == 1){
		sms_input_use_short_url_val = "あり";
	}else{
		sms_input_use_short_url_val = "なし";
	}
	var recheck_button_next = data["recheck_button_next"];
	if(recheck_button_next == '51')
		recheck_button_next = '*';
	else if(recheck_button_next == '52')
		recheck_button_next = '#';
	button_next = '<div class="row">' +
			'<div class="col-md-2">' +
			'<p>正番号</p>' +
			'</div>' +
			'<div class="col-md-10">' +
			recheck_button_next +
			'</div>' +
			'</div>';
	// 繰返し確認必須のため、recheck_flagは1固定
	var recheck = htmlRecheckAudio(1, data["recheck_audio_id"], data["recheck_audio_type"], data["recheck_audio_name"], data["recheck_audio_content"]);
	var error_audio = htmlAudio(data["ques_sms_input_audio_id"], data["ques_sms_input_audio_type"], data["ques_sms_input_audio_name"], data["ques_sms_input_audio_content"]);
	var html = '' +
			'<div class="box col-md-12">' +
			'<div class="box-inner">' +
			header +
			'<div class="box-content">' +
			'<div class="row">' +
			'<div class="col-md-2">' +
			'<p>飛び先</p>' +
			'</div>' +
			'<div class="col-md-2 select_jump_ques_container" jump_question="' + data['jump_question'] + '"></div>' +
			'</div>' +
			'<div class="row">' +
			'<div class="col-md-2">' +
			'<p>送信不可</p>' +
			'</div>' +
			'<div class="col-md-2 select_jump_ques_container" jump_question="' + data['txtAnswJumpSmsInput99']+ '" ans_no="99"></div>' +
			'</div>' +
			'<div class="row">' +
			'<div class="col-md-2">' +
			'<p>タイムアウト</p>' +
			'</div>' +
			'<div class="col-md-2 select_jump_ques_container" jump_question="' + data['txtAnswJumpSmsInputTimeOut98']+ '" ans_no="98"></div>' +
			'</div>' +
			'<div class="row">' +
			'<div class="col-md-2">' +
			'<p>音声</p>' +
			'</div>' +
			'<div class="col-md-10">' +
			audio +
			'</div>' +
			'</div>' +
			recheck['content'] +
			button_next +
			'<div class="row">' +
			'<div class="col-md-2">' +
			'<p>通知番号</p>' +
			'</div>' +
			'<div class="col-md-10 sms-common-phonenumber">' +
			data['smsInputPhoneNumber'] +
			'</div>' +
			'</div>' +
			'<div class="row">' +
			'<div class="col-md-2">' +
			'<p>本文</p>' +
			'</div>' +
			'<div class="col-md-10">' + data['smsInputBodyContent'] + '</div>' +
			'</div>' +
			'<div class="row">' +
			'<div class="col-md-2">' +
			'<p>短縮URL</p>' +
			'</div>' +
			'<div class="col-md-10 sms-short-url">' + sms_input_use_short_url_val + '</div>' +
			'</div>' +
			'<div class="row">' +
			'<div class="col-md-2">' +
			'<p>送信不可音声</p>' +
			'</div>' +
			'<div class="col-md-10 sms-common-audio">' + error_audio + '</div>' +
			'</div>' +
			'</div>' +
			'</div>' +
			'</div>';
	$(row).append(html);

	//一覧画面のSMS共通項目（通知番号、送信不可音声）を更新する。
	$('.sms-common-phonenumber').text(data['smsInputPhoneNumber']);
	$('.sms-short-url').text(sms_input_use_short_url_val);
	$('.sms-common-audio').html(error_audio);

	$(this).parents(".tblAddQues").find(".recheckAudio").show();
	$(this).parents(".tblAddQues").find(".recheckButtonNext").show();

}

function setSectionAudioInfo(ques_no, terget_html_id, audio_type, audio_id) {
	var audio_type_value = 0;
	terget_html_id = "#" + terget_html_id;
	//　音声方式のラジオボタンが選択済みならば、その値を採用
	if (glb_arr_ques[ques_no][audio_type]) {
		audio_type_value = glb_arr_ques[ques_no][audio_type];
	}
	$(terget_html_id).find(".rdAudio[value=" + audio_type_value + "]").prop("checked", true);
	//　音声方式により、表示する内容を変更する
	if(audio_type_value == 1 || audio_type_value == 2){
		$(terget_html_id).find(".audio").hide();
		$(terget_html_id).find(".audio_mix").show();
	}else{
		$(terget_html_id).find(".audio").show();
		$(terget_html_id).find(".audio_mix").hide();
		$(terget_html_id).find(".btnPlay").remove();
		$(terget_html_id).find(".btnStop").remove();
		$(terget_html_id).append(generateBtnAudio(glb_arr_ques[ques_no][audio_id]));
		$(terget_html_id).find(".hdAudioId").val(glb_arr_ques[ques_no][audio_id]);
		if(terget_html_id == "#sms-error-audio"){
			$(terget_html_id).find(".hdAudioName").val(glb_arr_ques[ques_no]["ques_audio_name"]);
		}else{
			$(terget_html_id).find(".hdAudioName").val(glb_arr_ques[ques_no]["ques_sms_input_audio_name"]);
		}
	}
}

function generateBtnAudio(audio_id) {
	var audio_element =
			'<a class="btn btnPlay btn-default" audio_id="'+ audio_id +'">' +
			'<i class="glyphicon glyphicon-play" ></i>' +
			'</a> \n' +
			'<a class="btn btnStop btn-default">' +
			'<i class="glyphicon glyphicon-stop" ></i>' +
			'</a>';
	return audio_element;
}
