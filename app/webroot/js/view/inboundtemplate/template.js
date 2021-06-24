var glb_arr_ques = new Object();
var glb_arr_ques_del = new Array();
var originalContent;
var originalQuestion;
$(document).ready(function() {
	$(document).on('keydown mouseup keyup keypress blur change', '#smsBodyContent', function() {
		fillSMSBodyCount();
	});
	$(document).on('keydown mouseup keyup keypress blur change', '#smsInputBodyContent', function() {
		fillSMSInputBodyCount();
	});
	{
		$('.alert .close').on('click', function(e) {
			$(this).parent().hide();
			$(this).parent().find("p").remove();
		});
		$("#TemplateForm").validate({
			ignore: "",
			invalidHandler: function(form, validator) {
	            var errors = validator.numberOfInvalids();
	            if (errors) {
	                var firstInvalidElement = $(validator.errorList[0].element);
	                var id_error = $(firstInvalidElement).attr("name") + "-error";
	                if (firstInvalidElement.css("display") == "none") {
	                	firstInvalidElement.css("display","block");
	                	firstInvalidElement.focus();
	                	firstInvalidElement.css("display","none");
	            	}else {
	            		firstInvalidElement.focus();
	            	}
	            }
	        },
			rules: {
				"data[T30Template][template_name]": {
					required: true,
					nameDifferentBusy: true,//20160406 Add by Thai : #6722 - Check template_name is busy
					existTemplateName: true,
				},
			},
			messages: {
				"data[T30Template][template_name]": {
					required: "テンプレート名を入力してください。",
					nameDifferentBusy: "テンプレート名は「busy」以外を指定してください。",//20160406 Add by Thai : #6722 - Check template_name is busy
					existTemplateName: "指定したテンプレート名は既に使用されています。",
				},
			},
			//errorLabelContainer : "#messageBox",
			showErrors: function(errorMap, errorList) {
				if (errorList.length > 0) {
					$('#template-error-message').find("p").remove();

					$.each(errorList, function(index, val) {
						$('#template-error-message').append('<p>' + val.message + '</p>');
					});
					$('#template-error-message').show();
				} else {
					$('#template-error-message').hide();
				}
			}
		});
		originalContent = $("#form_add_call_list").html();
		originalQuestion = $("#add_ques").html();
		$("#dialog").on("show.bs.modal", function (e) {
		});
		$("#dialog").on("hide.bs.modal", function (e) {
    		$("#audio-player").find("audio").trigger("pause");
    		$("#audio-player").find("audio").attr("src","");
			$("#form_add_call_list").html(originalContent);
			$("#form_add_call_list")[0].reset();

		});
		//質問配置
		$(".template").sortable({
			cancel: ".item-disabled",
			handle: ".btnMove",
			update: function(event, ui) {
				update_glb_arr_ques();//20160406 Update by Thai : #6722 - Add item for QUESTION_AUTH
		        updateQuesNo();
				renderSelectJumpQues();
		    }
		});

		renderSelectJumpQues();
	}

	$(document).on("click", "#btnShowAll", function(e){
		$(".row_question").each(function(){
			$(this).find(".box-content").show();
			$(this).find(".box-header .btnShowHide i").removeClass("glyphicon-chevron-up");
			$(this).find(".box-header .btnShowHide i").addClass("glyphicon-chevron-down");
		});
	});

	$(document).on("click", "#btnHideAll", function(e){
		$(".row_question").each(function(){
			$(this).find(".box-content").hide();
			$(this).find(".box-header .btnShowHide i").removeClass("glyphicon-chevron-down");
			$(this).find(".box-header .btnShowHide i").addClass("glyphicon-chevron-up");
		});
	});

	$(document).on('click', '#btnAddQues', function (e) {
		e.preventDefault();
		showDialogQues(QUESTION_VOICE, 1);
		if(Object.keys(glb_arr_ques).length > IN_MAX_SECTION_COUNT){
			alert("セクション最大件数は" + IN_MAX_SECTION_COUNT + "問です。");
			return;
		}else{
			$("#myModalLabel").html("セクションの追加");
			$(".rdAudio").parents(".form-audio").find(".audio_mix").hide();
			$(".rdAudio").parents(".form-audio").find(".audio").show();
			$("#btnSubmitQues").attr("ques_no", "");
			$("#btnSubmitQues").attr("ques_type", "");
			$("#dialog").modal("show");
		}
	});

    // テンプレート詳細画面で、任意のセクションの編集ボタンを押したときの動作
	$(document).on('click', '.btnEdit', function (e) {
		$('#edit_flg').val(1);
		var ques_no = $(this).parents(".row_question").find(".hdQuesNo").val();
		// ここで、モーダルダイアログに現在の設定値を戻す。
    	for (var key in glb_arr_ques[ques_no]) {
    		if (glb_arr_ques[ques_no].hasOwnProperty(key)) {
    			$('#dialog').find("input[name="+key+"][type=text]").val(glb_arr_ques[ques_no][key]);
    			$('#dialog').find("select[name="+key+"]").val(glb_arr_ques[ques_no][key]);
    			$('#dialog').find("textarea[name="+key+"]").val(glb_arr_ques[ques_no][key]);
    			$('#dialog').find("input[name="+key+"][type=checkbox]").prop("checked", true);
    		}
		}
    	var ques_type = glb_arr_ques[ques_no]["question_type"];
    	var question_yuko = glb_arr_ques[ques_no]["question_yuko"];
		if (question_yuko == 1) {
			$("#question_yuko").prop("checked", true);
		} else {
			$("#question_yuko").prop("checked", false);
		}
		//20160406 Add by Thai : #6722 - Add item for QUESTION_AUTH - Begin
		var auth_match_flag = glb_arr_ques[ques_no]["auth_match_flag"];
		if (auth_match_flag == 1) {
			$("#auth_match_flag").prop("checked", true);
		} else {
			$("#auth_match_flag").prop("checked", false);
		}
		//20160406 Add by Thai : #6722 - Add item for QUESTION_AUTH - End

        //// 音声のチェックボックス（音声ファイルor合成音声）などの設定
        setSectionAudioInfo(ques_no, "basic-audio", "audio_type", "audio_id");
        setSectionAudioInfo(ques_no, "trans-audio", "trans_audio_type", "trans_audio_id");
        setSectionAudioInfo(ques_no, "trans-timeout-audio", "trans_timeout_audio_type", "trans_timeout_audio_id");
        setSectionAudioInfo(ques_no, "recheck-audio", "recheck_audio_type", "recheck_audio_id");
        setSectionAudioInfo(ques_no, "bukken-audio", "bukken_audio_type", "bukken_audio_id");
        setSectionAudioInfo(ques_no, "bukken-diagram-audio", "bukken_diagram_audio_type", "bukken_cont_audio_id");
        setSectionAudioInfo(ques_no, "bukken-cont-audio", "bukken_cont_audio_type", "bukken_cont_audio_id");
        setSectionAudioInfo(ques_no, "ques-property-cost-audio", "ques_property_cost_audio_type", "ques_property_cost_audio_id");
        setSectionAudioInfo(ques_no, "ques-property-square-audio", "ques_property_square_audio_type", "ques_property_square_audio_id");
        setSectionAudioInfo(ques_no, "ques-property-confirm-audio", "ques_property_confirm_audio_type", "ques_property_confirm_audio_id");
        setSectionAudioInfo(ques_no, "ques-property-continue-audio", "ques_property_continue_audio_type", "ques_property_continue_audio_id");
		setSectionAudioInfo(ques_no, "sms-error-audio", "ques_inbound_sms_audio_type", "ques_sms_inbound_audio_id");
		setSectionAudioInfo(ques_no, "sms-input-error-audio", "ques_inbound_sms_input_audio_type", "ques_sms_input_inbound_audio_id");
		//// 音声のチェックボックス（音声ファイルor合成音声）などの設定_ここまで
		



    	//繰り返し確認チェックボックス初期化
		var recheck_flag = glb_arr_ques[ques_no]["recheck_flag"];
		if (recheck_flag == 1) {
			$("#cbRecheckFlag").prop("checked", true);
			$("#cbRecheckFlag").change();
		} else {
			$("#cbRecheckFlag").prop("checked", false);
		}

    	//#終了ボタンチェックボックス
    	var yuko_button_record = glb_arr_ques[ques_no]["yuko_button_record"];
		if (yuko_button_record == 1) {
			$("#cbYukoButtonRecord").prop("checked", true);
		} else {
			$("#cbYukoButtonRecord").prop("checked", false);
		}
		//空き席数無しチェックボックス
		var trans_seat_flag = glb_arr_ques[ques_no]["trans_empty_seat_flag"];
		if (trans_seat_flag == 1) {
			$("#cbTransEmptySeatFlag").prop("checked", true);
		} else {
			$("#cbTransEmptySeatFlag").prop("checked", false);
		}
		
		//転送元電話番号チェックボックス
		var trans_phone_number_play_flag = glb_arr_ques[ques_no]["trans_phone_number_play_flag"];
		if (trans_phone_number_play_flag == 1) {
			$("#cbTransPhoneNumberFlag").prop("checked", true);
		} else {
			$("#cbTransPhoneNumberFlag").prop("checked", false);
		}

		var edit_flag = 2;
    	$("#slQuesType").val(ques_type);
    	if (ques_type == QUESTION_TIMEOUT) {
    		$("#slQuesType").attr("disabled", true);
    		edit_flag = 1;
    	}
    	if(ques_type == QUESTION_INBOUND_SMS){
			// チェックボックスの状態を初期化
			var sms_use_short_url = glb_arr_ques[ques_no]["sms_use_short_url"];
			if (sms_use_short_url == 1) {
				$("#sms_use_short_url").prop("checked", true);
			} else {
				$("#sms_use_short_url").prop("checked", false);
			}
            // 選択中の電話番号の状態をもとに、画面の状態を決める（文字数カウントや短縮URLチェックボックスの有効・無効など）
            setSMSState();
		}

		if(ques_type == QUESTION_INBOUND_SMS_INPUT){
			// チェックボックスの状態を初期化
			var sms_input_use_short_url = glb_arr_ques[ques_no]["sms_input_use_short_url"];
			if (sms_input_use_short_url == 1) {
				$("#sms_input_use_short_url").prop("checked", true);
			} else {
				$("#sms_input_use_short_url").prop("checked", false);
			}
            // 選択中の電話番号の状態をもとに、画面の状態を決める（文字数カウントや短縮URLチェックボックスの有効・無効など）
            setSMSInputState();
		}

		showDialogQues(ques_type, edit_flag);

		$("#myModalLabel").html("セクションの編集");
    	$("#btnSubmitQues").attr("ques_no", ques_no);
    	$("#btnSubmitQues").attr("ques_type", ques_type);
		$('#dialog').modal('show');
	});

	$(document).on('click', '.btnDelete', function (e) {
		if(confirm("削除します。よろしいですか？")){
			//画面対象質問削除
			$(this).parents(".row_question").remove();
			//objectで対象質問削除
			ques_no = $(this).parents(".row_question").find(".hdQuesNo").val();
			ques_id = $(this).parents(".row_question").find(".hdQuesId").val();
			delete glb_arr_ques[ques_no];
			var temp_glb = $.extend(true, {}, glb_arr_ques);
			var i = 1;
			glb_arr_ques = new Object();
			for(var key in temp_glb){
				glb_arr_ques[i] = temp_glb[key];
				i++;
			}
			if(ques_id){
				glb_arr_ques_del.push(ques_id);
			}
			//質問NO更新
			$(".hdQuesNo").each(function(index){
				$(this).val(index + 1);
			});
			updateQuesNo();
			renderSelectJumpQues();
		}
	});

	$(document).on('click', '.btnMove', function (e) {
		$(".row_question").addClass("item-disabled");
		$(this).parents(".row_question").removeClass("item-disabled");
	});

	$(document).on('click', '.btnShowHide', function (e) {
		$(this).parents(".row_question").find(".box-content").toggle();
		if($(this).parents(".row_question").find(".box-content").css('display') == 'none'){
			$(this).parents(".row_question").find(".box-header .btnShowHide i").removeClass("glyphicon-chevron-down");
			$(this).parents(".row_question").find(".box-header .btnShowHide i").addClass("glyphicon-chevron-up");
		}else{
			$(this).parents(".row_question").find(".box-header .btnShowHide i").removeClass("glyphicon-chevron-up");
			$(this).parents(".row_question").find(".box-header .btnShowHide i").addClass("glyphicon-chevron-down");
		}
	});

	$(document).on('click', '.btnPlay', function (e) {
		var audio_id = $(this).attr("audio_id");
		var source = appRoot + 'InboundTemplate/read_file/' + audio_id;
		$("#audio-player").find("audio").attr("src", source);
		$("#audio-player").find("audio").trigger('play');
	});

	$(document).on('click', '.btnStop', function (e) {
		$("#audio-player").find("audio").trigger('pause');
	});

	//20160224 Add by Thai : #6519 - Update select jump question - Begin
	$(document).on('change', '.select_jump_ques', function (e) {
		updateDataWhenSelectJumpQues($(this));
	});
	//20160224 Add by Thai : #6519 - Update select jump question - End

	$("#btnSubmit").click(function() {
		var message = "";
		var required_timeout = false;
		var exist_ques_end = false;
		var question_end = false;
		var question_jump = true;
		var audio_type = "0";
		var audio_check = "0";
		var audio_ng_flag = "0";
		var question_all_type = new Array();
		//$("#flash-error").hide();
		$("#template-error-message").hide();
		
		//テンプレートの全セクションを追加
		for(var tmp_question in glb_arr_ques){
			question_all_type.push(glb_arr_ques[tmp_question].question_type);
		}
		if (Object.keys(glb_arr_ques).length == 0){
			message += "セクションを追加してください。<br>";
		}else{
			var require_auth_match_flag = true;
			var isAuthCharRequired = false;
			var hadAuthErr = false;
			for(var question in glb_arr_ques){
				var ques_type = glb_arr_ques[question].question_type;
				//20160418 Add by Thai : #6722 - Validate auth_match_flag - Begin
				//20160420 Edit by Thai : #6722 validate QUESTION_AUTH_CHAR - Begin
				if (ques_type == QUESTION_AUTH || ques_type == QUESTION_AUTH_CHAR) {
					if (require_auth_match_flag) {
						if (question_all_type.indexOf(QUESTION_INBOUND_COLLATION) == -1){//着信照合がテンプレート内に存在しない場合のみチェックする。
							if (glb_arr_ques[question].auth_match_flag != 1) {
								if(glb_arr_ques[question].auth_match_flag == 0)
									message += "着信リスト照合より前に着信リストを参照するセクションが含まれているため登録できません。<br>";
								else
									message += "認証項目のセクションが存在しますが、着信リスト照合のセクションが存在しないため登録できません。<br>";
								hadAuthErr = true;
							}

						}
						require_auth_match_flag = false;
					}
//					else {
//						if (glb_arr_ques[question].auth_match_flag == 1) {
//							message += "着信リスト照合を設定した文字列認証セクションより前に、着信リストを参照するセクションが含まれているため登録できません。<br>";
//						}
//					}
				}
				//20160420 Edit by Thai : #6722 validate QUESTION_AUTH_CHAR - End
				//20160418 Add by Thai : #6722 - Validate auth_match_flag - End
				//20160225 Edit by Thai : #6519 - Validate jump question - Begin
				if(ques_type == QUESTION_BASIC || ques_type == QUESTION_AUTH){
					if (ques_type == QUESTION_BASIC) {
						var list_key_jumps = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 51, 52];
						var prefix = 'txtAnswJump';
					} else if (ques_type == QUESTION_AUTH) {
						var list_key_jumps = [1, 2, 3];
						var prefix = 'txtAnswJumpAuth';
					}

/*					if (!glb_arr_ques[question][prefix + '99']) {
						message += "質問" + question + "でタイムアウトの飛び先を選択してください。<br>";
					}*/

					for (k in list_key_jumps) {
						list_key_jumps[k] = prefix + list_key_jumps[k];
					}
					//20160418 Edit by Thai : #6722 - Validate jump_question QUESTION_AUTH - Begin
					//20160427 Edit by Thai : #6722 edit validate jump_question QUESTION_AUTH_CHAR - Begin
					if (!glb_arr_ques[question]['jump_question']) {
						for (k in list_key_jumps) {
							if (!glb_arr_ques[question][list_key_jumps[k]]) {
								message += "質問" + question + "で他の場合の飛び先を選択してください。<br>";
								break;
							}
						}
					}
					//20160427 Edit by Thai : #6722 edit validate jump_question QUESTION_AUTH_CHAR - End
					//20160418 Edit by Thai : #6722 - Validate jump_question QUESTION_AUTH - End
				}

				//20160427 Add by Thai : #6722 validate jump_question QUESTION_AUTH_CHAR - Begin
				if (ques_type == QUESTION_AUTH_CHAR) {
					if (!glb_arr_ques[question]['txtAnswJumpAuthChar1']) {
						message += "質問" + question + "で「入力値 ＝ 認証項目」の飛び先を選択してください。<br>";
					}
					if (!glb_arr_ques[question]['txtAnswJumpAuthChar2']) {
						message += "質問" + question + "で「入力値 ≠ 認証項目」の飛び先を選択してください。<br>";
					}
				}
				//20160427 Add by Thai : #6722 validate jump_question QUESTION_AUTH_CHAR - End

				if (ques_type == QUESTION_INBOUND_COLLATION) {
					if (!glb_arr_ques[question]['txtAnswJumpInboundCollation1']) {
						message += "質問" + question + "で「入力値 ＝ 認証項目」の飛び先を選択してください。<br>";
					}
					if (!glb_arr_ques[question]['txtAnswJumpInboundCollation2']) {
						message += "質問" + question + "で「入力値 ≠ 認証項目」の飛び先を選択してください。<br>";
					}
				}

				if([QUESTION_VOICE, QUESTION_TEL, QUESTION_RECORD, QUESTION_FAX, QUESTION_INBOUND_SMS, QUESTION_INBOUND_SMS_INPUT].indexOf(glb_arr_ques[question].question_type) >= 0){
					if (!glb_arr_ques[question]['jump_question']) {
						message += "質問" + question + "で飛び先を選択してください。<br>";
					}
				}
				//20160225 Edit by Thai : #6519 - Validate jump question - End

				if(glb_arr_ques[question].question_type == QUESTION_PROPERTY){
					if (!glb_arr_ques[question]['txtAnswJumpProp0']) {
						message += "質問" + question + "の「確認を続ける」で飛び先を選択してください。<br>";
					}
					if (!glb_arr_ques[question]['jump_question']) {
						message += "質問" + question + "の「確認を続けない」で飛び先を選択してください。<br>";
					}
				}
				// テンプレート詳細画面で更新をクリックしたときのバリデート
				if(glb_arr_ques[question].question_type == QUESTION_PROPERTY_SEARCH){
					if (!glb_arr_ques[question]['txtAnswJumpProp0']) {
						message += "質問" + question + "の「確認を続ける」で飛び先を選択してください。<br>";
					}
					if (!glb_arr_ques[question]['jump_question']) {
						message += "質問" + question + "の「確認を続けない」で飛び先を選択してください。<br>";
					}
				}
				// テンプレート詳細画面で更新をクリックしたときのバリデート
				if(glb_arr_ques[question].question_type == QUESTION_INBOUND_SMS){
					if (!glb_arr_ques[question]['txtAnswJumpSms99']) {
						message += "質問" + question + "の「送信不可」で飛び先を選択してください。<br>";
					}

					//全SMSセクションの文字数チェック
					if (hasLengthOverForSms(glb_arr_ques[question]['smsBodyContent'],glb_arr_ques[question]['sms_use_short_url'], question)) {
						message += "質問" + question + "のSMSセクションを確認して下さい。" + INBOUND_QUESTION_SMS_BODY_REACH_LIMIT + "<br>";
					}
				}

				// テンプレート詳細画面で更新をクリックしたときのバリデート
				if(glb_arr_ques[question].question_type == QUESTION_INBOUND_SMS_INPUT){
					if (!glb_arr_ques[question]['txtAnswJumpSmsInput99']) {
						message += "質問" + question + "の「送信不可」で飛び先を選択してください。<br>";
					}

					//全SMSセクションの文字数チェック
					if (hasLengthOverForSmsInput(glb_arr_ques[question]['smsInputBodyContent'],glb_arr_ques[question]['sms_input_use_short_url'], question)) {
						message += "質問" + question + "のSMSセクションを確認して下さい。" + INBOUND_QUESTION_SMS_BODY_REACH_LIMIT + "<br>";
					}
				}

				//20160325 Edit by Canh : 質問・認証・番号入力セクションがある場合タイムアウトセクションが必須 - Begin
				if(glb_arr_ques[question].question_type == QUESTION_BASIC
						|| glb_arr_ques[question].question_type == QUESTION_AUTH
						|| glb_arr_ques[question].question_type == QUESTION_AUTH_CHAR
						|| glb_arr_ques[question].question_type == QUESTION_TEL
						|| glb_arr_ques[question].question_type == QUESTION_PROPERTY
						|| glb_arr_ques[question].question_type == QUESTION_FAX
						|| glb_arr_ques[question].question_type == QUESTION_PROPERTY_SEARCH
						|| glb_arr_ques[question].question_type == QUESTION_INBOUND_SMS_INPUT
				){
					required_timeout = true;
				}
				//20160325 Edit by Canh : 質問・認証・番号入力セクションがある場合タイムアウトセクションが必須 - End
				//20160325 Add by Canh : 切断セクションが必須 - Begin
				if (glb_arr_ques[question].question_type == QUESTION_END){
					exist_ques_end = true;
				}
				//20160325 Add by Canh : 切断セクションが必須 - End
				
				//20161019 Add by Kato : 音声合成の音声種類は混在不可 - Begin
				if ((glb_arr_ques[question].question_type == QUESTION_VOICE
						|| glb_arr_ques[question].question_type == QUESTION_BASIC
						|| glb_arr_ques[question].question_type == QUESTION_TIMEOUT
					) && glb_arr_ques[question]["audio_type"] != "0"
				){
					audio_type = glb_arr_ques[question]["audio_type"];
					if (audio_check == "0") {
						audio_check = audio_type;
					}
				} else if (glb_arr_ques[question].question_type == QUESTION_AUTH
						|| glb_arr_ques[question].question_type == QUESTION_AUTH_CHAR
						|| glb_arr_ques[question].question_type == QUESTION_TEL
						|| glb_arr_ques[question].question_type == QUESTION_FAX){
					if (glb_arr_ques[question]["recheck_audio_type"]){
						if(glb_arr_ques[question]["audio_type"] == "0" && glb_arr_ques[question]["recheck_audio_type"] != "0") {
							audio_type = glb_arr_ques[question]["recheck_audio_type"];
						} else if ((glb_arr_ques[question]["audio_type"] != "0" && glb_arr_ques[question]["recheck_audio_type"] == "0") 
								|| (glb_arr_ques[question]["audio_type"] == glb_arr_ques[question]["recheck_audio_type"] && glb_arr_ques[question]["audio_type"] != "0" && glb_arr_ques[question]["recheck_audio_type"] != "0")) {
							audio_type = glb_arr_ques[question]["audio_type"];
						} else if (glb_arr_ques[question]["audio_type"] != glb_arr_ques[question]["recheck_audio_type"]) {
							audio_ng_flag = "1";
						}
					} else {
						audio_type = glb_arr_ques[question]["audio_type"];
					}
					if (audio_check == "0") {
						audio_check = audio_type;
					}
				} else if (glb_arr_ques[question].question_type == QUESTION_TRANS){
					if (glb_arr_ques[question]["trans_timeout_audio_type"]){
						if(glb_arr_ques[question]["trans_audio_type"] == "0" && glb_arr_ques[question]["trans_timeout_audio_type"] != "0") {
							audio_type = glb_arr_ques[question]["trans_timeout_audio_type"];
						} else if ((glb_arr_ques[question]["trans_audio_type"] != "0" && glb_arr_ques[question]["trans_timeout_audio_type"] == "0") 
								|| (glb_arr_ques[question]["trans_audio_type"] == glb_arr_ques[question]["trans_timeout_audio_type"] && glb_arr_ques[question]["trans_audio_type"] != "0" && glb_arr_ques[question]["trans_timeout_audio_type"] != "0")) {
							audio_type = glb_arr_ques[question]["trans_audio_type"];
						} else if (glb_arr_ques[question]["trans_audio_type"] != glb_arr_ques[question]["trans_timeout_audio_type"]) {
							audio_ng_flag = "1";
						}
					} else {
						audio_type = glb_arr_ques[question]["trans_audio_type"];
					}
					if (audio_check == "0") {
						audio_check = audio_type;
					}
				}else if(glb_arr_ques[question].question_type == QUESTION_PROPERTY){
					terget_keys = [
									'audio_type',
									'bukken_audio_type',
									'bukken_diagram_audio_type',
									'bukken_cont_audio_type'
								];
					result_value = voice_type_mixed_check(glb_arr_ques[question], terget_keys);
					mixed = result_value[0];
					audio_type = result_value[1];
					// 合成音声の男・女が混ざっている場合は、エラーとする。
					if(mixed){
						audio_ng_flag = "1";
					}
					if (audio_check == "0") {
						audio_check = audio_type;
					}
				}else if(glb_arr_ques[question].question_type == QUESTION_PROPERTY_SEARCH){
					terget_keys = [
									'ques_property_cost_audio_type',
									'ques_property_square_audio_type',
									'ques_property_confirm_audio_type',
									'ques_property_continue_audio_type'
								];
					result_value = voice_type_mixed_check(glb_arr_ques[question], terget_keys);
					mixed = result_value[0];
					audio_type = result_value[1];
					// 合成音声の男・女が混ざっている場合は、エラーとする。
					if(mixed){
						audio_ng_flag = "1";
					}
					// 前の質問の音声を覚えている。(0:アップロードで初期値。)
					// アップロード以外が入っている場合は、上書きしない。)
					if (audio_check == "0") {
						audio_check = audio_type;
					}
				}else if(glb_arr_ques[question].question_type == QUESTION_INBOUND_SMS){
					target_keys = [ 'ques_inbound_sms_audio_type' ];
					result_value = voice_type_mixed_check(glb_arr_ques[question], target_keys);
					mixed = result_value[0];
					audio_type = result_value[1];
					// 合成音声の男・女が混ざっている場合は、エラーとする。
					if(mixed){
						audio_ng_flag = "1";
					}
					// 前の質問の音声を覚えている。(0:アップロードで初期値。)
					// アップロード以外が入っている場合は、上書きしない。)
					if (audio_check == "0") {
						audio_check = audio_type;
					}
				}else if(glb_arr_ques[question].question_type == QUESTION_INBOUND_SMS_INPUT){
					//音声のチェック
					target_keys = [ 'audio_type' ];
					result_value = voice_type_mixed_check(glb_arr_ques[question], target_keys);
					mixed = result_value[0];
					audio_type = result_value[1];
					// 合成音声の男・女が混ざっている場合は、エラーとする。
					if(mixed){
						audio_ng_flag = "1";
					}
					// 前の質問の音声を覚えている。(0:アップロードで初期値。)
					// アップロード以外が入っている場合は、上書きしない。)
					if (audio_check == "0") {
						audio_check = audio_type;
					}

					//繰返音声のチェック
					if(glb_arr_ques[question]["audio_type"] == "0" && glb_arr_ques[question]["recheck_audio_type"] != "0") {
						audio_type = glb_arr_ques[question]["recheck_audio_type"];
					} else if ((glb_arr_ques[question]["audio_type"] != "0" && glb_arr_ques[question]["recheck_audio_type"] == "0") 
							|| (glb_arr_ques[question]["audio_type"] == glb_arr_ques[question]["recheck_audio_type"] && glb_arr_ques[question]["audio_type"] != "0" && glb_arr_ques[question]["recheck_audio_type"] != "0")) {
						audio_type = glb_arr_ques[question]["audio_type"];
					} else if (glb_arr_ques[question]["audio_type"] != glb_arr_ques[question]["recheck_audio_type"]) {
						audio_ng_flag = "1";
					}

					if (audio_check == "0") {
						audio_check = audio_type;
					}

					//送信不可の音声のチェック
					sms_target_keys = [ 'ques_inbound_sms_input_audio_type' ];
					result_value = voice_type_mixed_check(glb_arr_ques[question], sms_target_keys);
					mixed = result_value[0];
					audio_type = result_value[1];
					// 合成音声の男・女が混ざっている場合は、エラーとする。
					if(mixed){
						audio_ng_flag = "1";
					}
					// 前の質問の音声を覚えている。(0:アップロードで初期値。)
					// アップロード以外が入っている場合は、上書きしない。)
					if (audio_check == "0") {
						audio_check = audio_type;
					}
				}
				// 今回の質問が合成音声でなく、
				// 前の質問のオーディオtypeと対応と今回の質問のオーディオtypeが異なる場合は、エラーとする。
				if (audio_type != "0" && audio_check != audio_type) {
					audio_ng_flag = "1";
				}
				//20161019 Add by Kato : 音声合成の音声種類は混在不可 - End
			}
			//着信照合がテンプレート内に存在しない場合のみチェックする。
			if (question_all_type.indexOf(QUESTION_INBOUND_COLLATION) == -1){
				isAuthCharRequired = isAuthItemRequired();
				if(isAuthCharRequired && !hadAuthErr){
					message += "着信リスト照合より前に着信リストを参照するセクションが含まれているため登録できません。。<br>";
				}
			}
			// ここから下は、全てのセクションの確認をした後に表示する。
			if (audio_ng_flag == "1") {
				message += "同一テンプレート内で音声合成の[男性][女性]を混在させることはできません。<br>";
			}

			if (glb_arr_ques[Object.keys(glb_arr_ques).length].question_type != QUESTION_TIMEOUT && required_timeout){
				message += "セクションの一番最後にタイムアウトを設定してください。<br>";
			}
			//20160325 Add by Canh : 切断セクションが必須 - Begin
			if(!exist_ques_end){
				message += "切断セクションが必須です。<br>";
			}
			//20160325 Add by Canh : 切断セクションが必須 - End
		}
		if (message){
			$('#template-error-message').find("p").remove();
			$('#template-error-message').append('<p>' + message + '</p>');
			$("#template-error-message").show();
			//$("#flash-error").show();
			//$("#flash-error").html(message);
			return;
		}

		if($("#TemplateForm").valid()){
			if(confirm("保存します。よろしいですか？")){
				display_load();
				$.ajax({
					type: 'POST',
					url: appRoot + 'InboundTemplate/save_template',
					data: {
						template_id: $("#hdTemplateId").val(),
						template_name: $("#txtTemplateName").val(),
						description: $("#txtTemplateDescription").val(),
						glb_arr_ques: glb_arr_ques,
						glb_arr_ques_del: glb_arr_ques_del,
					},
					success: function(data) {
						$.unblockUI();
						if(data == "success"){
			         		window.location.href = appRoot+"InboundTemplate/index/success"
			         	}else if(data == "err_exist_setting_inbound"){
			         		alert("着信設定されているテンプレートの為編集できません。");
			         	}else{
			         		alert("エラーを発生しました。");
			         	}
					},
				});
			}
		}
	});

	// URL短縮（電話番号を替えた時、短縮URLチェックボックスの状態を切替、SMS本文を再計算する。）
	$(document).on('click', '#slSMSPhoneNumber', function (e) {
		setSMSState();
	});

	// 番号指定SMSのURL短縮（電話番号を替えた時、短縮URLチェックボックスの状態を切替、SMS本文を再計算する。）
	$(document).on('click', '#slSMSInputPhoneNumber', function (e) {
		setSMSInputState();
	});


	// URL短縮（URL短縮ボタンをおした時、SMS本文を再計算する）
	$(document).on('click', '#sms_use_short_url', function (e) {
		fillSMSBodyCount();
	});

	// 番号指定SMSのURL短縮（URL短縮ボタンをおした時、SMS本文を再計算する）
	$(document).on('click', '#sms_input_use_short_url', function (e) {
		fillSMSInputBodyCount();
	});


	//20160222 Add by Giang : #6495 - Bug 164 - enable/disable check box begin
	$(document).on('click', '#question_yuko', function (e) {
		if ($('#slQuesType').val() == QUESTION_BASIC) {
			if ($(this).is(':checked')) {
				$('#tblQuesBasic input[type="checkbox"]').attr('disabled', false);
			} else {
				$('#tblQuesBasic input[type="checkbox"]').attr('disabled', true);
				$('#tblQuesBasic input[type="checkbox"]').prop("checked", false);
			}
		} else if ($('#slQuesType').val() == QUESTION_AUTH) {
			//20160406 Update by Thai : #6722 - Add item for QUESTION_AUTH - Begin
			if ($(this).is(':checked')) {
				$('#tblQuesAuth input.cbYukoAnswAuth[type="checkbox"]').attr('disabled', false);
			} else {
				$('#tblQuesAuth input.cbYukoAnswAuth[type="checkbox"]').attr('disabled', true);
				$('#tblQuesAuth input.cbYukoAnswAuth[type="checkbox"]').prop("checked", false);
			}
			//20160406 Update by Thai : #6722 - Add item for QUESTION_AUTH - End
			//20160420 Add by Thai : #6722 add QUESTION_AUTH_CHAR - Begin
		} else if ($('#slQuesType').val() == QUESTION_AUTH_CHAR) {
			if ($(this).is(':checked')) {
				$('#tblQuesAuthChar input.cbYukoAnswAuth[type="checkbox"]').attr('disabled', false);
			} else {
				$('#tblQuesAuthChar input.cbYukoAnswAuth[type="checkbox"]').attr('disabled', true);
				$('#tblQuesAuthChar input.cbYukoAnswAuth[type="checkbox"]').prop("checked", false);
			}
			//20160420 Add by Thai : #6722 add QUESTION_AUTH_CHAR - End
		}
	});
	//20160222 Add by Giang : #6495 - Bug 164 - enable/disable check box end
});

// 男声と女声が混ざって指定されていないかをチェック
// IN
//   Array terget_values：そのセグメントの値
//   	※glb_arr_ques[question]を渡してください。
//   Array terget_keys：音声typeのキー名
//				["audio_type", "cost_audio_type"]
// OUT
//		bool mixed：	true→混ざっている
//					false→混ざっていない
//		string synthetic_audio_type：合成音声のパターン(0 or 1 or 2)
//
//　※アップロードと合成（男のみor女のみ）は許されるため、
//	 アップロードと合成が混在する場合は、合成を戻す（1or2）
//	 アップロードと合成が混在する場合は、合成を戻す（1or2）
//　※mixedがtrueとなる場合は混在しているので、"1"を戻す。
//   (このケースはエラーメッセージを表示する為、audio_ng_flag=true が行われる想定)
function voice_type_mixed_check(terget_values, terget_keys) {
	var uplode_count = 0
	var synthetic_men_count = 0
	var synthetic_women_count = 0
	var mixed = true;
	var synthetic_audio_type = "0";
	// アップロードなのか、合成（男）なのか、合成（女）なのかに分ける
	for (var i = 0; i < terget_keys.length; i++){
		if(terget_values[terget_keys[i]] == "0"){
			uplode_count +=1;
		}
		else if(terget_values[terget_keys[i]] == "1"){
			synthetic_men_count +=1;
		}
		else{
			synthetic_women_count +=1;			
		}
	}
	// 合成音声のみ
	if(uplode_count == terget_keys.length){
		mixed = false;
		synthetic_audio_type = "0";
	}
	// 男音声のみ
	else if(synthetic_men_count == terget_keys.length){
		mixed = false;
		synthetic_audio_type = "1";
	}
	// 女音声のみ
	else if(synthetic_women_count == terget_keys.length){
		mixed = false;
		synthetic_audio_type = "2";
	}
	else{
		// 混ざっている場合
		if(synthetic_men_count > 0 && synthetic_women_count> 0){
			mixed = true;
			synthetic_audio_type = "1";
		}
		// 男声と合成音声の場合
		else if(synthetic_men_count > 0){
			mixed = false;
			synthetic_audio_type = "1";
		}
		// 女声と合成音声の場合
		else{
			mixed = false;
			synthetic_audio_type = "2";
		}
	}
	return [mixed, synthetic_audio_type]
}


function upload_file(inputF){
	var maxFileSize = "50000000";
	var maxFileSizeExceeded = "ファイルサイズが50MBを超えています。";
	var checkSize = false;
	var checkFormart = false;
	var checkUpload = true;
	//size確認
	$.each(inputF.files,function(){
		if(this.size && maxFileSize && this.size > parseInt(maxFileSize)){
			checkSize = true;
			checkUpload = false;
		}
	});
	//format確認
	var parts = $(inputF).val().split('.');
	var type_file = parts[parts.length -1];
	if(type_file && type_file != "wav"){
		checkFormart = true
		checkUpload = false;
	}
	//実行
	if(checkSize){
		alert(maxFileSizeExceeded);
	}else if(checkFormart){
		alert("音声ファイルはwavファイルを指定してください。");
	}else if(checkUpload && $(inputF).val()){
		$('.btnClosePopupAddQues').attr('disabled', true); //20160222 Add by Giang : #6495 - Bug 132 - disable close popup add ques when upload wav file
		var data = new FormData();
		data.append("data[File]", inputF.files[0]);
		var url = appRoot+"InboundTemplate/upload_file";
		var file_name = inputF.files[0].name;
		setDisabled();
		$.ajax(url, {
			xhr: function () {
				var xhr = new window.XMLHttpRequest();
			    xhr.upload.addEventListener("progress", function (evt) {
				    if (evt.lengthComputable) {
		                var percentComplete = evt.loaded / evt.total;
		                $(inputF).parents(".form-audio").find(".progress").show();
		                $(inputF).parents(".form-audio").find(".btnPlay").remove();
		                $(inputF).parents(".form-audio").find(".btnStop").remove();
		                $(inputF).parents(".form-audio").find(".progress-bar").text(Math.round(percentComplete * 100) + "%");
		                $(inputF).parents(".form-audio").find(".progress-bar").width(Math.round(percentComplete * 100) + "%");
		            }
		        }, false);
		        return xhr;
		    },
		    type: "POST",
		    contentType: false,
		    data: data,
		    cache: false,
		    processData: false,
		    error: function (xhr, str) {
		        alert("ファイルアップロードに失敗しました。");
		    	$(inputF).parents("td").find(".upload_progress").hide();
		    	$('.btnClosePopupAddQues').attr('disabled', false); //20160222 Add by Giang : #6495 - Bug 132 - disable close popup add ques when upload wav file
		    },
		    success: function (data) {
		    	setEnabled();
		    	if(data=="err_db" || data=="err_pcm"){
		    		if(data=="err_db"){
		    			alert("ファイルアップロード失敗しました。");
		    		}else if(data=="err_pcm"){
		    			alert("ファイル変換に失敗しました。");
		    		}
//		    		$(inputF).parents("td").find(".file_selector").show();
//			    	$(inputF).parents("td").find(".btnDownloadFile").hide();
//			    	$(inputF).parents("td").find(".hdUploadedFileId").val("");
//			    	$(inputF).parents("td").find(".uploaded_file_name").text("");
//			    	$(inputF).parents("td").find(".upload_progress").hide();
		    	}else{
		    		$(inputF).parents(".form-audio").find(".hdAudioId").val(data);
		    		$(inputF).parents(".form-audio").find(".hdAudioName").val(file_name);
					$(inputF).parents(".form-audio").append(
						'<a class="btn btnPlay btn-default" audio_id="'+ data +'">' +
							'<i class="glyphicon glyphicon-play" ></i>' +
						'</a> \n' +
						'<a class="btn btnStop btn-default">' +
							'<i class="glyphicon glyphicon-stop" ></i>' +
						'</a>'
					);
					$(inputF).parents(".form-audio").find(".progress").hide();
		    	}
				$('.btnClosePopupAddQues').attr('disabled', false); //20160222 Add by Giang : #6495 - Bug 132 - disable close popup add ques when upload wav file
		    }
		  });
	}
}

// セグメント編集モーダルダイアログで、表示するセグメント部分を表示する。
function showDialogQues(ques_type, edit_flag){
	//編集のとき
	if (edit_flag == 2) {
		$("#slQuesType > option[value='9']").remove();
	}

	$("#slQuesType").val(ques_type);
	$(".tblAddQues").each(function(){
		$(this).hide();
	});
	var ques_type_playbacks = [
		QUESTION_VOICE,
		QUESTION_BASIC,
		QUESTION_AUTH,
		QUESTION_AUTH_CHAR,
		QUESTION_TEL,
		QUESTION_RECORD,
		QUESTION_TIMEOUT,
		QUESTION_PROPERTY,
		QUESTION_FAX,
		QUESTION_PROPERTY_SEARCH,
		QUESTION_INBOUND_SMS_INPUT
	];
	if (ques_type_playbacks.indexOf(ques_type) >= 0){
		$("#tblQuesPlayback").show();
		if(ques_type == QUESTION_BASIC){
			$("#tblQuesBasic").show();
			$("#tblYukoQues").show();
			//20160222 Add by Giang : #6495 - Bug 164 - enable/disable check box begin
			if (!$('#question_yuko').is(':checked')) {
				$('#tblQuesBasic input[type="checkbox"]').attr('disabled', true);
			}
			//20160222 Add by Giang : #6495 - Bug 164 - enable/disable check box end
		}else if(ques_type == QUESTION_AUTH){
			$("#tblYukoQues").show();
			$("#tblQuesAuthItem").show();
			$("#tblQuesAuth").show();
			$("#tblRecheck").show();
			$("#tblQuesPlayback").find(".slCustInfo").hide();
			$("#tblQuesPlayback").find(".btnCustInfo").hide();
			//20160222 Add by Giang : #6495 - Bug 164 - enable/disable check box begin
			if (!$('#question_yuko').is(':checked')) {
				$('#tblQuesAuth input.cbYukoAnswAuth[type="checkbox"]').attr('disabled', true);//20160406 Update by Thai : #6722 - Add item for QUESTION_AUTH
			}
			//20160222 Add by Giang : #6495 - Bug 164 - enable/disable check box end
			//20160420 Add by Thai : #6722 add QUESTION_AUTH_CHAR - Begin
		}else if(ques_type == QUESTION_AUTH_CHAR){
			$("#tblYukoQues").show();
			$("#tblQuesAuthMatchFlag").show();
			$("#tblQuesAuthItem").show();
			$("#tblQuesAuthChar").show();
			$("#tblRecheck").show();
			$("#tblQuesPlayback").find(".slCustInfo").hide();
			$("#tblQuesPlayback").find(".btnCustInfo").hide();
			if (!$('#question_yuko').is(':checked')) {
				$('#tblQuesAuthChar input[type="checkbox"]').attr('disabled', true);
			}
			//20160420 Add by Thai : #6722 add QUESTION_AUTH_CHAR - End
		}else if(ques_type == QUESTION_TEL){
			$("#tblQuesTel").show();
			$("#tblRecheck").show();
			$("#tblQuesPlayback").find(".slCustInfo").hide();
			$("#tblQuesPlayback").find(".btnCustInfo").hide();
		}else if(ques_type == QUESTION_RECORD){
			$("#tblQuesRecord").show();
		}else if(ques_type == QUESTION_TIMEOUT){
			$("#tblQuesPlayback").find(".slCustInfo").hide();
			$("#tblQuesPlayback").find(".btnCustInfo").hide();
		}else if(ques_type == QUESTION_PROPERTY){
			$("#tblQuesProperty").show();
			$("#tblQuesPlayback").find(".slCustInfo").hide();
			$("#tblQuesPlayback").find(".btnCustInfo").hide();
		}else if(ques_type == QUESTION_FAX){
			$("#tblQuesFax").show();
			$("#tblRecheck").show();
			$("#tblQuesPlayback").find(".slCustInfo").hide();
			$("#tblQuesPlayback").find(".btnCustInfo").hide();
			$('#cbRecheckFlag').prop('checked', true);
			$('#cbRecheckFlag').parent().parent().hide();
			$('#cbRecheckFlag').parents(".tblAddQues").find(".recheckAudio").show();
			$('#cbRecheckFlag').parents(".tblAddQues").find(".recheckButtonNext").show();
			$('#cbRecheckFlag').parents(".tblAddQues").find(".recheckAudio label").first().html('確認音声');
		}else if(ques_type == QUESTION_PROPERTY_SEARCH){
			// セグメントの作成・編集画面で、セグメント選択プルダウンを切り替えたときの動作。
			$("#tblQuesPlayback").hide();
			$("#tblQuesPropertySearch").show();
		}else if(ques_type == QUESTION_INBOUND_SMS_INPUT){
			$("#tblSMSINPUT").show();
			$("#tblRecheck").show();
			$("#tblQuesPlayback").find(".slCustInfo").hide();
			$("#tblQuesPlayback").find(".btnCustInfo").hide();

			//繰返し確認を常にオンにし、チェックボックスを非表示にする。
			$('#cbRecheckFlag').prop("checked", true);
			$("#cbRecheckFlag").change();
			$("#recheck-audio label:nth-child(1)").text("繰返確認音声")
			$('#cbRecheckFlag').closest('.form-group').hide();

		}
	}else if(ques_type == QUESTION_TRANS){//転送
		$("#tblQuesTrans").show();
	}else if(ques_type == QUESTION_INBOUND_SMS){
		$("#tblSMS").show();
	}
}

// terget_html_id = "basic-audio"
// audio_type = "audio_type"
// audio_id = "audio_id"
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
	}
}


function updateQuesNo() {
	$(".ques_no").each(function(index){
		$(this).text(index + 1);
	});
}

function generateBtnAudio(audio_id) {
	var tmp =
		'<a class="btn btnPlay btn-default" audio_id="'+ audio_id +'">' +
			'<i class="glyphicon glyphicon-play" ></i>' +
		'</a> \n' +
		'<a class="btn btnStop btn-default">' +
			'<i class="glyphicon glyphicon-stop" ></i>' +
		'</a>';
	return tmp;
}

//20160406 Add by Thai : #6722 - Add item for QUESTION_AUTH - Begin
function update_glb_arr_ques() {
	var lis = $(".template").parent().find('.row_question');
	var temp_glb = $.extend(true, {}, glb_arr_ques);
	glb_arr_ques = new Array();
	lis.each(function(index) {
		var temp = temp_glb[$(this).find('.hdQuesNo').val()];
		glb_arr_ques[index + 1] = temp;
		$(this).find('.hdQuesNo').val(index + 1);
	});
}
//20160406 Add by Thai : #6722 - Add item for QUESTION_AUTH - End

function detectIE() {
	var ua = window.navigator.userAgent;
	var msie = ua.indexOf('MSIE ');
	if (msie > 0) {
		return parseInt(ua.substring(msie + 5, ua.indexOf('.', msie)), 10);
	}
	var trident = ua.indexOf('Trident/');
	if (trident > 0) {
		var rv = ua.indexOf('rv:');
		return parseInt(ua.substring(rv + 3, ua.indexOf('.', rv)), 10);
	}
	var edge = ua.indexOf('Edge/');
	if (edge > 0) {
		return parseInt(ua.substring(edge + 5, ua.indexOf('.', edge)), 10);
	}
	return false;
}

enableSelection(document.body);
$(document).unbind("keydown", disabledCopyKey);

// SMS本文の文字数をチェックする
function fillSMSBodyCount() {
	var content = $('#smsBodyContent').val();
	var contentLength = replaceUrlSMSBody(content, $('#sms_use_short_url').prop('checked')).length;

	$('#smsBodyCount').html(contentLength);
	var errorContent = $("#popupflash-error").html().replace(INBOUND_QUESTION_SMS_BODY_REACH_LIMIT + '<br>', '');
	if(contentLength > SMS_MAX_LENGTH){
		$("#popupflash-error").show();
		$("#popupflash-error").html(errorContent + INBOUND_QUESTION_SMS_BODY_REACH_LIMIT +'<br>');
	}
}

// SMS本文の文字数をチェックする(番号指定SMS)
function fillSMSInputBodyCount() {
	var content = $('#smsInputBodyContent').val();
	var contentLength = replaceUrlSMSInputBody(content, $('#sms_input_use_short_url').prop('checked')).length;

	$('#smsInputBodyCount').html(contentLength);
	var errorContent = $("#popupflash-error").html().replace(INBOUND_QUESTION_SMS_BODY_REACH_LIMIT + '<br>', '');
	if(contentLength > SMS_MAX_LENGTH){
		$("#popupflash-error").show();
		$("#popupflash-error").html(errorContent + INBOUND_QUESTION_SMS_BODY_REACH_LIMIT +'<br>');
	}
}

// 全SMSセクションの本文の文字数をチェックする
function hasLengthOverForSms(smsBodyContent,short_url_flg, quesNo) {
	// テキストエリアからの文字数をカウントする際、改行の数分文字数がずれるので
	// 改行コードを整形してから文字数をカウントする
	var content = smsBodyContent.replace(/\r/g, '');
	var contentLength = replaceUrlSMSBody(content, short_url_flg,true,quesNo).length;

	//文字数チェック
	if(contentLength > SMS_MAX_LENGTH){
		return true;
	}
	return false;
}

// 全番号指定SMSセクションの本文の文字数をチェックする
function hasLengthOverForSmsInput(smsBodyContent,short_url_flg, quesNo) {
	// テキストエリアからの文字数をカウントする際、改行の数分文字数がずれるので
	// 改行コードを整形してから文字数をカウントする
	var content = smsBodyContent.replace(/\r/g, '');
	var contentLength = replaceUrlSMSInputBody(content, short_url_flg,true,quesNo).length;

	//文字数チェック
	if(contentLength > SMS_MAX_LENGTH){
		return true;
	}
	return false;
}
/**
* 挿入項目が入っているかどうか確認。
* @return  true: 挿入項目が存在する。false: 挿入項目が存在しない、または内容がない
*/
function hasInsertItem(content){
	if(!content) 
		return false;
	else
		return content.match(ITEM_REGEX) != null;
}

/*
* 質問ごとの飛び先を取り出す
* @param question
* @param glb_arr_ques (global 変数)
* @return array jump of question
*/
function getJump(question){
	var ques_type = glb_arr_ques[question]["question_type"];
	// jumpの深さ
	var deep = Array();
	if(ques_type == QUESTION_BASIC || ques_type == QUESTION_AUTH){
		if (ques_type == QUESTION_BASIC) {
			var list_key_jumps = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 51, 52, 99];
			var prefix = 'txtAnswJump';
		} else if (ques_type == QUESTION_AUTH) {
			var list_key_jumps = [1, 2, 3, 99];
			var prefix = 'txtAnswJumpAuth';
		}
		for (k in list_key_jumps) {
			list_key_jumps[k] = prefix + list_key_jumps[k];
		}
		// QUESTION_BASIC	[1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 51, 52] 
		// QUESTION_AUTH 	[1, 2, 3]
		for (k in list_key_jumps) {
			if (glb_arr_ques[question][list_key_jumps[k]]) {
				if(deep.indexOf(glb_arr_ques[question][list_key_jumps[k]]))
					deep.push(glb_arr_ques[question][list_key_jumps[k]]);
			}
		}
	}
	if(ques_type != QUESTION_AUTH_CHAR){
		if (glb_arr_ques[question]['jump_question']) {
			if(deep.indexOf(glb_arr_ques[question]['jump_question']) < 0)
				deep.push(glb_arr_ques[question]['jump_question']);
		}
	}
	if(ques_type == QUESTION_TEL){
		if (glb_arr_ques[question]['txtAnswJumpTel99']) {
			if(deep.indexOf(glb_arr_ques[question]['txtAnswJumpTel99']) < 0)
				deep.push(glb_arr_ques[question]['txtAnswJumpTel99']);
		}
	}
	if (ques_type == QUESTION_AUTH_CHAR) {
		if (glb_arr_ques[question]['txtAnswJumpAuthChar1']) {
			if(deep.indexOf(glb_arr_ques[question]['txtAnswJumpAuthChar1']) < 0)
				deep.push(glb_arr_ques[question]['txtAnswJumpAuthChar1']);
		}
		if (glb_arr_ques[question]['txtAnswJumpAuthChar2']) {
			if(deep.indexOf(glb_arr_ques[question]['txtAnswJumpAuthChar2']) < 0)
				deep.push(glb_arr_ques[question]['txtAnswJumpAuthChar2']);
		}
		if (glb_arr_ques[question]['txtAnswJumpAuthChar99']) {
			if(deep.indexOf(glb_arr_ques[question]['txtAnswJumpAuthChar99']) < 0)
				deep.push(glb_arr_ques[question]['txtAnswJumpAuthChar99']);
		}
	}
	if (ques_type == QUESTION_INBOUND_COLLATION) {
		if (glb_arr_ques[question]['txtAnswJumpInboundCollation1']) {
			if(deep.indexOf(glb_arr_ques[question]['txtAnswJumpInboundCollation1']) < 0)
				deep.push(glb_arr_ques[question]['txtAnswJumpInboundCollation1']);
		}
		if (glb_arr_ques[question]['txtAnswJumpInboundCollation2']) {
			if(deep.indexOf(glb_arr_ques[question]['txtAnswJumpInboundCollation2']) < 0)
				deep.push(glb_arr_ques[question]['txtAnswJumpInboundCollation2']);
		}
	}
	if(glb_arr_ques[question].question_type == QUESTION_PROPERTY || glb_arr_ques[question].question_type == QUESTION_PROPERTY_SEARCH){
		if (glb_arr_ques[question]['txtAnswJumpProp0']) {
			if(deep.indexOf(glb_arr_ques[question]['txtAnswJumpProp0']) < 0)
				deep.push(glb_arr_ques[question]['txtAnswJumpProp0']);
		}
		if (glb_arr_ques[question]['txtAnswJumpProp99']) {
			if(deep.indexOf(glb_arr_ques[question]['txtAnswJumpProp99']) < 0)
				deep.push(glb_arr_ques[question]['txtAnswJumpProp99']);
		}
	}
	if(glb_arr_ques[question].question_type == QUESTION_INBOUND_SMS){
		if (glb_arr_ques[question]['txtAnswJumpSms99']) {
			if(deep.indexOf(glb_arr_ques[question]['txtAnswJumpSms99']) < 0)
				deep.push(glb_arr_ques[question]['txtAnswJumpSms99']);
		}
	}
	if(glb_arr_ques[question].question_type == QUESTION_INBOUND_SMS_INPUT){
		if (glb_arr_ques[question]['txtAnswJumpSmsInput99']) {
			if(deep.indexOf(glb_arr_ques[question]['txtAnswJumpSmsInput99']) < 0)
				deep.push(glb_arr_ques[question]['txtAnswJumpSmsInput99']);
		}

		if (glb_arr_ques[question]['txtAnswJumpSmsInputTimeOut98']) {
			if(deep.indexOf(glb_arr_ques[question]['txtAnswJumpSmsInputTimeOut98']) < 0)
				deep.push(glb_arr_ques[question]['txtAnswJumpSmsInputTimeOut98']);
		}
	}
	return deep;
}

/*
* 深さごとに質問を取り出す
* @param glb_arr_ques (global 変数)
* @return array question for each deep lever.
* return値の例： Array{
		1:["3"]
		2:["2", "5"]
		3:["4", "5"]
		4:["1", "5", "3"]
		5:["3", "2", "5"]
		6:["2", "5", "4"]
	}
* 1:, 2:...は深さ
*/
function getDeepJump(){
	// 回した質問
	var gotDeepQues = new Array();

	//　飛び先の深さごとの質問
	var jumpDeep = new Array();
	// 質問1の飛び先を取得する
	jumpDeep[1] = getJump(1);
	gotDeepQues.push(1);

	// 質問ごとの飛び先
	var quesJump = jumpDeep[1];

	//深さごとの飛び先
	var newDeep = new Array();

	var tmpDeep = new Array();

	var idx = 1;
	var continueFlag;
	do{
		continueFlag = false;
		++idx;
		newDeep = new Array();
		for(var ques in quesJump){
			//質問ごとの飛び先を取って新しい深さの飛び先に入れる
			tmpDeep = getJump(quesJump[ques]);
			for(var q in tmpDeep){
				if(newDeep.indexOf(tmpDeep[q]) < 0){
					newDeep.push(tmpDeep[q]);
				}
			}
			// do...whileのbreak条件を設定する
			if(gotDeepQues.indexOf(quesJump[ques]) < 0){
				gotDeepQues.push(quesJump[ques]);
				continueFlag = true;
			}
		}
		quesJump = newDeep;
		jumpDeep[idx] = newDeep;
	}while(continueFlag);

	return jumpDeep;
}

/*
* 質問の初めて表される深さを取得する
* @param question
* @param jumpDeep はgetDeepJumpの戻り値
* @return deep of question(質問の深さ). 見えつけなかった０を返す
*/
function getFirstDeep(question, jumpDeep){
	var deep = 0;
	for(var d = 1; d <= jumpDeep.length; d ++){
		for(var ques in jumpDeep[d]){
			if(question == jumpDeep[d][ques]){
				deep = d;
				return deep;
			}
		}
	}
	return deep;
}
/*
* 挿入項目と認証項目チェック
*/
function isAuthItemRequired(){
	var questionDeep = 0;
	var authCharDeep = 0;
	var hasItem = false;
	var hasAuthChar = false;
	var quesAuthChar = 0;
	jumpDeep = getDeepJump();
	for(var ques in glb_arr_ques){
		if(glb_arr_ques[ques]["question_type"] == QUESTION_AUTH_CHAR){
			authCharDeep = getFirstDeep(ques, jumpDeep);
			hasAuthChar = true;
			quesAuthChar = ques;
		}
	}

	for(var ques in glb_arr_ques){
		questionDeep = 0;
		hasItem = false;
		if(glb_arr_ques[ques]["question_type"] == QUESTION_VOICE || glb_arr_ques[ques]["question_type"] == QUESTION_BASIC || 
			glb_arr_ques[ques]["question_type"] == QUESTION_RECORD){
			if(hasInsertItem(glb_arr_ques[ques]["audio_content"])){
				questionDeep = getFirstDeep(ques, jumpDeep);
				hasItem = true;
			}
		}else if(glb_arr_ques[ques]["question_type"] == QUESTION_TRANS){
			if(hasInsertItem(glb_arr_ques[ques]["trans_audio_content"])){
				questionDeep = getFirstDeep(ques, jumpDeep);
				hasItem = true;
			}
		}else if(glb_arr_ques[ques]["question_type"] == QUESTION_INBOUND_SMS){
			if(hasInsertItem(glb_arr_ques[ques]["smsBodyContent"])){
				questionDeep = getFirstDeep(ques, jumpDeep);
				hasItem = true;
			}
		}else if(glb_arr_ques[ques]["question_type"] == QUESTION_INBOUND_SMS_INPUT){
			if(hasInsertItem(glb_arr_ques[ques]["smsInputBodyContent"])){
				questionDeep = getFirstDeep(ques, jumpDeep);
				hasItem = true;
			}
		}

		if(ques == 1 && hasItem) return true;
		else{
			if(hasItem){
				if(!hasAuthChar) return true;
				else{
					if(quesAuthChar != 1){
						if((questionDeep != 0 && questionDeep <= authCharDeep) || (authCharDeep == 0 && questionDeep > 0))
							return true;
					}
				}
			}
		}
	}
	return false;
}