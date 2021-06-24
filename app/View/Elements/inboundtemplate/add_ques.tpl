<!-- 有効質問 -->
<div class="form-group tblAddQues" id="tblYukoQues" style="display: none;">
	<div class="form-group">
		<label class="col-sm-2 control-label">有効質問</label>
		<div class="col-sm-7 ptop7">
			<input type="checkbox" name="question_yuko" id="question_yuko" value="1">
			<label for="question_yuko" style="margin-top: 2px;"></label>
		</div>
	</div>
</div>

<!-- 再生 -->
<div class="form-group tblAddQues" id="tblQuesPlayback" style="display: block;">
	<div id="basic-audio" class="form-group form-audio">
		<label class="col-sm-2 control-label">音声</label>
		<div class="col-sm-7">
			{if $audio_mix_flag eq '1'}
			<div class="form-audio-type">
				<input type="radio" name="audio_type" value="0" class="rdAudio" checked><span> 音声ファイル</span>
				<input type="radio" name="audio_type" value="1" class="rdAudio"><span> 音声合成(男性)</span>
				<input type="radio" name="audio_type" value="2" class="rdAudio"><span> 音声合成(女性)</span>
			</div>
			{else}
				<input type="radio" name="audio_type" value="0" class="rdAudio hidden" checked>
			{/if}
			<div class="audio" style="display: block;">
				<input type="text" name="audio_id" id="hdAudioId" class="hdAudioId" value="" style="display: none;"/>
				<input type="text" name="audio_name" class="hdAudioName" value="" style="display: none;"/>
				<input class="btnUploadAudio" type="file" accept="audio/wav" name="data[UploadFile][0]" onchange="upload_file(this);"/>
				<div class="progress" style="display: none;">
					<div class="progress-bar" role="progressbar" aria-valuenow="60" aria-valuemin="0" aria-valuemax="100" style="width: 0%;">
						0%
					</div>
				</div>
			</div>
			{if $audio_mix_flag eq '1'}
			<div class="audio_mix" style="display: none;">
				<textarea class="form-control txtAudioContent" rows="3" cols="50" id="txtAudioContent" name="audio_content"></textarea>
				<select class="form-control slCustInfo" id="tounyuu" name="slCustInfo">
					{foreach from=$audio_mix_item item=item}
						<option value="{$item.T13InboundListItem.item_name}">{$item.T13InboundListItem.item_name}</option>
					{/foreach}
				</select>
				<button type="button" name="btnCustInfo" class="btn btn-primary btnCustInfo">挿入</button>
			</div>
			{/if}
		</div>
	</div>
</div>

<!-- 質問 -->
<div class="form-group tblAddQues" id="tblQuesBasic" style="display: none;">
	<div class="form-group">
		<label class="col-sm-2 control-label">繰り返し</label>
		<div class="col-sm-7">
			<select class="form-control slQuestionRepeat" id="question_repeat" name="question_repeat">
				{foreach from=$question_repeat item=item}
					<option value="{$item.M90PulldownCode.item_code}">{$item.M90PulldownCode.item_name}</option>
				{/foreach}
			</select>
		</div>
	</div>
	<div class="form-group">
		<label class="col-sm-2 control-label">回答番号</label>
		<div class="col-sm-9">
			<label id="cbYukoAnsw1-error" class="error" for="cbYukoAnsw1"></label>
			<table class="table table-striped table-bordered bootstrap-datatable responsive">
				<colgroup>
					<col width="10%">
					<col width="10%">
					<col width="80%">
				</colgroup>
				<thead>
					<tr>
						<th class="alignCenter">有効</th>
						<th class="alignCenter">番号</th>
						<th class="alignCenter">テキスト</th>
					</tr>
				</thead>
				<tbody>
					{for $i=1 to 9}
    				<tr>
						<input type="text" name="hdAnswId{$i}" answer_no="1" id="hdAnswId{$i}" style="display: none;"/>
						<td class="alignCenter">
							<input type="checkbox" name="cbYukoAnsw{$i}" id="cbYukoAnsw{$i}" class="cbYukoAnsw" value="{$i}" answer_no="{$i}"/>
							<label for="cbYukoAnsw{$i}" style="margin-top: 2px;"></label>
						</td>
						<td class="alignCenter">{$i}</td>
						<td>
							<input type="text" maxlength="50" name="txtAnswContent{$i}" answer_no="{$i}" id="txtAnswContent{$i}" class="form-control input-xs txtAnswContent"/>
							<input type="text" name="txtAnswJump{$i}" style="display: none;"/>
						</td>
					</tr>
					{/for}
					<tr>
						<input type="text" name="hdAnswId0" answer_no="0" id="hdAnswId0" style="display: none;"/>
						<td class="alignCenter">
							<input type="checkbox" name="cbYukoAnsw0" answer_no="0" value="0" id="cbYukoAnsw0" class="cbYukoAnsw"/>
							<label for="cbYukoAnsw0" style="margin-top: 2px;"></label>
						</td>
						<td class="alignCenter">0</td>
						<td>
							<input type="text" maxlength="50" name="txtAnswContent0" answer_no="0" id="txtAnswContent0" class="form-control input-xs txtAnswContent"/>
							<input type="text" name="txtAnswJump0" style="display: none;"/>
						</td>
					</tr>
					<tr>
						<input type="text" name="hdAnswId51" answer_no="51" id="hdAnswId51" style="display: none;"/>
						<td class="alignCenter">
							<input type="checkbox" name="cbYukoAnsw51" id="cbYukoAnsw51" class="cbYukoAnsw" value="51"/>
							<label for="cbYukoAnsw51" style="margin-top: 2px;"></label>
						</td>
						<td class="alignCenter">*</td>
						<td>
							<input type="text" maxlength="50" name="txtAnswContent51" answer_no="51" id="txtAnswContent51" class="form-control input-xs txtAnswContent"/>
							<input type="text" name="txtAnswJump51" style="display: none;"/>
						</td>
					</tr>
					<tr>
						<input type="text" name="hdAnswId52" answer_no="52" id="hdAnswId52" style="display: none;"/>
						<td class="alignCenter">
							<input type="checkbox" name="cbYukoAnsw52" answer_no="52" id="cbYukoAnsw52" class="cbYukoAnsw" value="52"/>
							<label for="cbYukoAnsw52" style="margin-top: 2px;"></label>
						</td>
						<td class="alignCenter">#</td>
						<td>
							<input type="text" maxlength="50" name="txtAnswContent52" answer_no="52" id="txtAnswContent52" class="form-control input-xs txtAnswContent"/>
							<input type="text" name="txtAnswJump52" style="display: none;"/>
							<input type="text" name="hdAnswId99" answer_no="99" id="hdAnswId99" style="display: none;"/>
							<input type="text" name="txtAnswJump99" style="display: none;"/>
						</td>
					</tr>
				</tbody>
			</table>
		</div>
	</div>
</div>

<div class="form-group tblAddQues" id="tblQuesAuthMatchFlag" style="display: none;">
	<div class="form-group">
		<label class="col-sm-2 control-label">着信リスト照合</label>
		<div class="col-sm-7 ptop7">
			<input type="checkbox" name="auth_match_flag" id="auth_match_flag" value="1">
			<label for="auth_match_flag" style="margin-top: 2px;"></label>
		</div>
	</div>
</div>

<div class="form-group tblAddQues" id="tblQuesAuthItem" style="display: none;">
	<div class="form-group">
		<label class="col-sm-2 control-label">認証項目</label>
		<div class="col-sm-7">
			<select id="slAuthItem" class="form-control" name="auth_item">
				{foreach from=$auth_item item=item}
					<option value="{$item.T13InboundListItem.item_name}">{$item.T13InboundListItem.item_name}</option>
				{/foreach}
			</select>
		</div>
	</div>
	<div class="form-group">
		<label class="col-sm-2 control-label">桁数</label>
		<div class="col-sm-7">
			<input type="text" class="form-control" name="digit_auth" id="txtDigitAuth" placeholder="桁数"/>
		</div>
	</div>
</div>

<!-- 数値認証 -->
<div class="form-group tblAddQues" id="tblQuesAuth" style="display: none;">
	<div class="form-group">
		<label class="col-sm-2 control-label">回答番号</label>
		<div class="col-sm-9">
			<table class="table table-striped table-bordered bootstrap-datatable responsive">
				<colgroup>
					<col width="10%">
					<col width="25%">
					<col width="65%">
				</colgroup>
				<thead>
					<tr>
						<th class="alignCenter">有効</th>
						<th class="alignCenter">判断</th>
						<th class="alignCenter">テキスト</th>
					</tr>
				</thead>
				<tbody>
					{for $i=1 to 3}
					<tr>
						<input type="text" name="hdAnswId{$i}" answer_no="{$i}" id="hdAnswId{$i}" style="display: none;"/>
						<td class="alignCenter">
							<input type="checkbox" name="cbYukoAnswAuth{$i}" id="cbYukoAnswAuth{$i}" answer_no="{$i}" value="{$i}" class="cbYukoAnswAuth"/>
							<label for="cbYukoAnswAuth{$i}" style="margin-top: 2px;"></label>
						</td>
						{if $i==1}
						<td class="alignCenter small">入力値 ＜ 認証項目</td>
						{elseif $i==2}
						<td class="alignCenter small">入力値 ＝ 認証項目</td>
						{elseif $i==3}
						<td class="alignCenter small">入力値 ＞ 認証項目</td>
						{/if}
						<td>
							<input type="text" name="txtAnswContentAuth{$i}" id="txtAnswContentAuth{$i}" answer_no="{$i}" class="form-control input-xs txtAnswContent"/>
							<input type="text" name="txtAnswJumpAuth{$i}" style="display: none;"/>
						</td>
					</tr>
					{/for}
					<input type="text" name="txtAnswJumpAuth99" style="display: none;"/>
				</tbody>
			</table>
		</div>
	</div>
</div>

<!-- 文字列認証 -->
<div class="form-group tblAddQues" id="tblQuesAuthChar" style="display: none;">
	<div class="form-group">
		<label class="col-sm-2 control-label">回答番号</label>
		<div class="col-sm-9">
			<table class="table table-striped table-bordered bootstrap-datatable responsive">
				<colgroup>
					<col width="10%">
					<col width="25%">
					<col width="65%">
				</colgroup>
				<thead>
				<tr>
					<th class="alignCenter">有効</th>
					<th class="alignCenter">判断</th>
					<th class="alignCenter">テキスト</th>
				</tr>
				</thead>
				<tbody>
				{assign var=answer_titles value=[0=>'入力値 ＝ 認証項目', 1=>'入力値 ≠ 認証項目']}
				{foreach from=$answer_titles key=i item=answer_title}
					<tr>
						<input type="text" name="hdAnswId{$i+1}" answer_no="{$i+1}" id="hdAnswId{$i+1}" style="display: none;"/>
						<td class="alignCenter">
							<input type="checkbox" name="cbYukoAnswAuthChar{$i+1}" id="cbYukoAnswAuthChar{$i+1}" answer_no="{$i+1}" value="{$i+1}" class="cbYukoAnswAuth"/>
							<label for="cbYukoAnswAuthChar{$i+1}" style="margin-top: 2px;"></label>
						</td>
						<td class="alignCenter small">{$answer_title}</td>
						<td>
							<input type="text" name="txtAnswContentAuthChar{$i+1}" id="txtAnswContentAuthChar{$i+1}" answer_no="{$i+1}" class="form-control input-xs txtAnswContentChar"/>
							<input type="text" name="txtAnswJumpAuthChar{$i+1}" style="display: none;"/>
						</td>
					</tr>
				{/foreach}
				<input type="text" name="txtAnswJumpAuthChar99" style="display: none;"/>
				</tbody>
			</table>
		</div>
	</div>
</div>
<!-- 転送 -->
<div class="form-group tblAddQues" id="tblQuesTrans" style="display: none;">
	<div id="trans-audio" class="form-group form-audio">
		<label class="col-sm-2 control-label">転送呼び出し音声</label>
		<div class="col-sm-7">
			{if $audio_mix_flag eq '1'}
			<div class="form-audio-type">
				<input type="radio" name="trans_audio_type" value="0" checked class="rdAudio"> 音声ファイル
				<input type="radio" name="trans_audio_type" value="1" class="rdAudio"> 音声合成(男性)
				<input type="radio" name="trans_audio_type" value="2" class="rdAudio"> 音声合成(女性)
			</div>
			{else}
			<input type="radio" name="trans_audio_type" value="0" class="rdAudio hidden" checked>
			{/if}
			<div class="audio" style="display: block;">
				<input type="text" name="trans_audio_id" id="hdTransAudioId" class="hdAudioId" value="" style="display: none;"/>
				<input type="text" name="trans_audio_name" class="hdAudioName" value="" style="display: none;"/>
				<input class="btnUploadAudio" type="file" accept="audio/wav" name="data[UploadFile][0]" onchange="upload_file(this);"/>
				<div class="progress" style="display: none;">
					<div class="progress-bar" role="progressbar" aria-valuenow="60" aria-valuemin="0" aria-valuemax="100" style="width: 0%;">
						0%
					</div>
				</div>
			</div>
			<div class="audio_mix" style="display: none;">
				<textarea rows="3" cols="50" name="trans_audio_content" id="txtAudioTransContent" class="form-control txtAudioContent"></textarea>
				<select class="form-control slCustInfo" name="slCustInfo">
					{foreach from=$audio_mix_item item=item}
						<option value="{$item.T13InboundListItem.item_name}">{$item.T13InboundListItem.item_name}</option>
					{/foreach}
				</select>
				<button type="button" name="btnCustInfo" class="btn btn-primary btnCustInfo">挿入</button>
			</div>
		</div>
	</div>
	<div id="trans-timeout-audio" class="form-group form-audio">
		<label class="col-sm-2 control-label">転送タイムアウト音声</label>
		<div class="col-sm-7">
			{if $audio_mix_flag eq '1'}
			<div class="form-audio-type">
				<input type="radio" name="trans_timeout_audio_type" value="0" checked class="rdAudio"> 音声ファイル
				<input type="radio" name="trans_timeout_audio_type" value="1" class="rdAudio"> 音声合成(男性)
				<input type="radio" name="trans_timeout_audio_type" value="2" class="rdAudio"> 音声合成(女性)
			</div>
			{else}
				<input type="radio" name="trans_timeout_audio_type" value="0" class="rdAudio hidden" checked>
			{/if}
			<div class="audio" style="display: block;">
				<input type="text" name="trans_timeout_audio_id" id="hdTransTimeoutAudioId" class="hdAudioId" value="" style="display: none;"/>
				<input type="text" name="trans_timeout_audio_name" class="hdAudioName" value="" style="display: none;"/>
				<input class="btnUploadAudio" type="file" accept="audio/wav" name="data[UploadFile][0]" onchange="upload_file(this);"/>
				<div class="progress" style="display: none;">
					<div class="progress-bar" role="progressbar" aria-valuenow="60" aria-valuemin="0" aria-valuemax="100" style="width: 0%;">
						0%
					</div>
				</div>
			</div>
			{if $audio_mix_flag eq '1'}
			<div class="audio_mix" style="display: none;">
				<textarea rows="3" cols="50" id="txtAudioTransTimeoutContent" class="form-control txtAudioContent" name="trans_timeout_audio_content"></textarea>
			</div>
			{/if}
		</div>
	</div>
	<div class="form-group">
		<label class="col-sm-2 control-label">転送先電話番号</label>
		<div class="col-sm-7">
			<input type="text" class="form-control" name="trans_tel" id="txtTransTel" placeholder="転送先" maxlength="11"/>
		</div>
	</div>
	<div class="form-group">
		<label class="col-sm-2 control-label">転送先席数</label>
		<div class="col-sm-7">
			<input type="text" class="form-control" name="trans_seat_num" id="txtSeatNum" placeholder="席数"/>
		</div>
	</div>
<!-- 	<div class="form-group"> -->
<!-- 		<label class="col-sm-2 control-label">空き席数無し時<br>発信停止</label> -->
<!-- 		<div class="col-sm-7 ptop7"> -->
<!-- 			<input type="checkbox" name="trans_empty_seat_flag" id="cbTransEmptySeatFlag" class="cbSeatEmpty" value="1"/> -->
<!-- 			<label for="cbTransEmptySeatFlag" style="margin-top: 2px;"></label>
<!-- 		</div> -->
<!-- 	</div> -->
	<div class="form-group">
		<label class="col-sm-2 control-label">転送タイムアウト(秒)</label>
		<div class="col-sm-7">
			<input type="text" class="form-control" name="trans_timeout" id="txtTimeout" placeholder="タイムアウト"/>
		</div>
	</div>
	<div class="form-group">
		<label class="col-sm-2 control-label">転送元番号再生</label>
		<div class="col-sm-7 ptop7">
			<input type="checkbox" name="trans_phone_number_play_flag" id="cbTransPhoneNumberFlag" class="cbSeatEmpty" value="1"/>
			<label for="cbTransPhoneNumberFlag" style="margin-top: 2px;"></label>
		</div>
	</div>
</div>

<!-- 電話番号入力 -->
<div class="form-group tblAddQues" id="tblQuesTel" style="display: none;">
	<label class="col-sm-2 control-label">桁数</label>
	<div class="col-sm-7">
		<input type="text" class="form-control" name="digit_tel" id="txtDigitTel" placeholder="桁数"/>
	</div>
	<input type="text" name="hdAnswId99" answer_no="99" id="hdAnswId99" style="display: none;"/>
	<input type="text" name="txtAnswJumpTel99" style="display: none;"/>
</div>
<!-- 電話FAX番号入力 -->
<div class="form-group tblAddQues" id="tblQuesFax" style="display: none;">
	<label class="col-sm-2 control-label">桁数</label>
	<div class="col-sm-7">
		<input type="text" class="form-control" name="digit_fax" id="txtDigitFax" placeholder="桁数"/>
	</div>
	<input type="text" name="hdAnswId99" answer_no="99" id="hdAnswId99" style="display: none;"/>
	<input type="text" name="txtAnswJumpFax99" style="display: none;"/>
</div>
<!-- 電話物件番号入力 -->
<div class="form-group tblAddQues" id="tblQuesProperty" style="display: none;">
	<div class="form-group">
		<label class="col-sm-2 control-label">桁数</label>
		<div class="col-sm-7">
			<input type="text" class="form-control" name="digit_prop" id="txtDigitProp" placeholder="桁数"/>
		</div>
	</div>

	<div id="bukken-audio" class="form-group form-audio">
		<label class="col-sm-2 control-label">物件名確認音声</label>		
		<div class="col-sm-10">
			<div>
				<br>
				<p class="red12">物件番号が確認できない場合、「確認できませんでした。再度入力してください。」</p>
				<p class="red12">の音声が再生され、最初から繰り返します。</p>
				<br>
				<p class="red12">物件名確認の音声は、物件名読み上げ後の音声を設定してください。</p>
				<p class="red12">例）「１２３号ですね？よろしければ１を、訂正する場合は３を押してください。」の場合、</p>
				<p class="red12">「ですね？よろしければ１を、訂正する場合は３を押してください。」の音声を設定してください。</p>
				<br>
			</div>
		</div>
		<label class="col-sm-2 control-label"></label>
		<div class="col-sm-7">
			{if $audio_mix_flag eq '1'}
				<div class="form-audio-type">
					<input type="radio" name="bukken_audio_type" value="0" class="rdAudio" checked> 音声ファイル
					<input type="radio" name="bukken_audio_type" value="1" class="rdAudio"> 音声合成(男性)
					<input type="radio" name="bukken_audio_type" value="2" class="rdAudio"> 音声合成(女性)
				</div>
			{else}
				<input type="radio" name="bukken_audio_type" value="0" class="rdAudio hidden" checked>
			{/if}
			<div class="audio" style="display: block;">
				<input type="text" name="bukken_audio_id" id="hdBukkenAudioId" class="hdAudioId" value="" style="display: none;"/>
				<input type="text" name="bukken_audio_name" class="hdAudioName" value="" style="display: none;"/>
				<input class="btnUploadAudio" type="file" accept="audio/wav" name="data[UploadFile][0]" onchange="upload_file(this);"/>
				<div class="progress" style="display: none;">
					<div class="progress-bar" role="progressbar" aria-valuenow="60" aria-valuemin="0" aria-valuemax="100" style="width: 0%;">
						0%
					</div>
				</div>
			</div>
			{if $audio_mix_flag eq '1'}
				<div class="audio_mix" style="display: none;">
					<textarea rows="3" cols="50" id="txtAudioBukkenContent" class="form-control txtAudioContent" name="bukken_audio_content"></textarea>
				</div>
			{/if}
		</div>
	</div>
	<div class="form-group">
		<label class="col-sm-2 control-label">回答番号</label>
		<div class="col-sm-9">
			<table class="table table-striped table-bordered bootstrap-datatable responsive">
				<colgroup>
					<col width="70%">
					<col width="30%">
				</colgroup>
				<thead>
				<tr>
					<th class="alignCenter">説明</th>
					<th class="alignCenter">番号</th>
				</tr>
				</thead>
				<tbody>
					<tr>
						<td>物件名が正しい場合</td>
						<td class="alignCenter">
							<select id="slBukkenAnswerNo" class="form-control" name="bukken_answer_no">
								{foreach from=$answer_no item=item}
									<option value="{$item.M90PulldownCode.item_code}">{$item.M90PulldownCode.item_name}</option>
								{/foreach}
							</select>
						</td>
					</tr>
					<tr>
						<td>物件名を訂正する場合</td>
						<td class="alignCenter">その他</td>
					</tr>
				</tbody>
			</table>
		</div>
	</div>

	<div id="bukken-diagram-audio" class="form-group form-audio">
		<label class="col-sm-2 control-label">図面希望音声</label>	
		<div class="col-sm-10">
			<div>
				<br>
				<p class="red12">図面希望の音声は、物件番号が確認できた後、音声を設定してください。</p>
				<p class="red12">例）「図面を希望する場合は１を、希望しない場合は3を押してください。」</p>
				<br>
			</div>
		</div>
		<label class="col-sm-2 control-label"></label>
		<div class="col-sm-7">
			{if $audio_mix_flag eq '1'}
				<div class="form-audio-type">
					<input type="radio" name="bukken_diagram_audio_type" value="0" class="rdAudio" checked> 音声ファイル
					<input type="radio" name="bukken_diagram_audio_type" value="1" class="rdAudio"> 音声合成(男性)
					<input type="radio" name="bukken_diagram_audio_type" value="2" class="rdAudio"> 音声合成(女性)
				</div>
			{else}
				<input type="radio" name="bukken_diagram_audio_type" value="0" class="rdAudio hidden" checked>
			{/if}
			<div class="audio" style="display: block;">
				<input type="text" name="bukken_diagram_audio_id" id="hdBukkenDiagramAudioId" class="hdAudioId" value="" style="display: none;"/>
				<input type="text" name="bukken_diagram_audio_name" class="hdAudioName" value="" style="display: none;"/>
				<input class="btnUploadAudio" type="file" accept="audio/wav" name="data[UploadFile][0]" onchange="upload_file(this);"/>
				<div class="progress" style="display: none;">
					<div class="progress-bar" role="progressbar" aria-valuenow="60" aria-valuemin="0" aria-valuemax="100" style="width: 0%;">
						0%
					</div>
				</div>
			</div>
			{if $audio_mix_flag eq '1'}
				<div class="audio_mix" style="display: none;">
					<textarea rows="3" cols="50" id="txtAudioBukkenDiagramContent" class="form-control txtAudioContent" name="bukken_diagram_audio_content"></textarea>
				</div>
			{/if}
		</div>
	</div>
	<div class="form-group">
		<label class="col-sm-2 control-label">回答番号</label>
		<div class="col-sm-9">
			<table class="table table-striped table-bordered bootstrap-datatable responsive">
				<colgroup>
					<col width="70%">
					<col width="30%">
				</colgroup>
				<thead>
				<tr>
					<th class="alignCenter">説明</th>
					<th class="alignCenter">番号</th>
				</tr>
				</thead>
				<tbody>
				<tr>
					<td>図面を希望する場合</td>
					<td class="alignCenter">
						<select id="slBukkenDiagramAnswerNo" class="form-control" name="bukken_diagram_answer_no">
							{foreach from=$answer_no item=item}
								<option value="{$item.M90PulldownCode.item_code}">{$item.M90PulldownCode.item_name}</option>
							{/foreach}
						</select>
					</td>
				</tr>
				<tr>
					<td>図面を希望しない場合</td>
					<td class="alignCenter">その他</td>
				</tr>
				</tbody>
			</table>
		</div>
	</div>

	<div id="bukken-cont-audio" class="form-group form-audio">
		<label class="col-sm-2 control-label">継続確認音声</label>		
		<div class="col-sm-10">
			<div>
				<br>
				<p class="red12">継続確認の音声は、図面希望番号を入力した後、音声を設定してください。</p>
				<p class="red12">例）「確認を続ける場合は１を、これで終了される方は3を押してください。」</p>
				<br>
			</div>
		</div>
		<label class="col-sm-2 control-label"></label>
		<div class="col-sm-7">
			{if $audio_mix_flag eq '1'}
				<div class="form-audio-type">
					<input type="radio" name="bukken_cont_audio_type" value="0" class="rdAudio" checked> 音声ファイル
					<input type="radio" name="bukken_cont_audio_type" value="1" class="rdAudio"> 音声合成(男性)
					<input type="radio" name="bukken_cont_audio_type" value="2" class="rdAudio"> 音声合成(女性)
				</div>
			{else}
				<input type="radio" name="bukken_cont_audio_type" value="0" class="rdAudio hidden" checked>
			{/if}
			<div class="audio" style="display: block;">
				<input type="text" name="bukken_cont_audio_id" id="hdBukkenContAudioId" class="hdAudioId" value="" style="display: none;"/>
				<input type="text" name="bukken_cont_audio_name" class="hdAudioName" value="" style="display: none;"/>
				<input class="btnUploadAudio" type="file" accept="audio/wav" name="data[UploadFile][0]" onchange="upload_file(this);"/>
				<div class="progress" style="display: none;">
					<div class="progress-bar" role="progressbar" aria-valuenow="60" aria-valuemin="0" aria-valuemax="100" style="width: 0%;">
						0%
					</div>
				</div>
			</div>
			{if $audio_mix_flag eq '1'}
				<div class="audio_mix" style="display: none;">
					<textarea rows="3" cols="50" id="txtAudioBukkenContContent" class="form-control txtAudioContent" name="bukken_cont_audio_content"></textarea>
				</div>
			{/if}
		</div>
	</div>
	<div class="form-group">
		<label class="col-sm-2 control-label">回答番号</label>
		<div class="col-sm-9">
			<table class="table table-striped table-bordered bootstrap-datatable responsive">
				<colgroup>
					<col width="70%">
					<col width="30%">
				</colgroup>
				<thead>
				<tr>
					<th class="alignCenter">説明</th>
					<th class="alignCenter">番号</th>
				</tr>
				</thead>
				<tbody>
				<tr>
					<input type="text" name="hdAnswId0" answer_no="0" id="hdAnswId0" style="display: none;"/>
					<input type="text" name="txtAnswJumpProp0" style="display: none;"/>
					<td>確認を続ける</td>
					<td class="alignCenter">
						<select id="slBukkenContAnswerNo" class="form-control" name="bukken_cont_answer_no">
							{foreach from=$answer_no item=item}
								<option value="{$item.M90PulldownCode.item_code}">{$item.M90PulldownCode.item_name}</option>
							{/foreach}
						</select>
					</td>
				</tr>
				<tr>
					<td>確認を続けない</td>
					<td class="alignCenter">その他</td>
				</tr>
				<input type="text" name="hdAnswId99" answer_no="99" id="hdAnswId99" style="display: none;"/>
				<input type="text" name="txtAnswJumpProp99" style="display: none;"/>
				</tbody>
			</table>
		</div>
	</div>
</div>
<!-- 録音 -->
<div class="form-group tblAddQues" id="tblQuesRecord" style="display: none;">
	<div class="form-group">
		<label class="col-sm-2 control-label">秒数</label>
		<div class="col-sm-7">
			<input type="text" class="form-control" name="second_record" id="txtSecondRecord" placeholder="秒数"/>
		</div>
	</div>
	<div class="form-group">
		<label class="col-sm-2 control-label">#ボタン終了</label>
		<div class="col-sm-7 ptop7">
			<input type="checkbox" name="yuko_button_record" id="cbYukoButtonRecord" value="1"/>
			<label for="cbYukoButtonRecord" style="margin-top: 2px;"></label>
		</div>
	</div>
</div>

<div class="form-group tblAddQues" id="tblRecheck" style="display: none;">
	<div class="form-group">
		<label class="col-sm-2 control-label">繰返確認</label>
		<div class="col-sm-7 ptop7">
			<input type="checkbox" name="recheck_flag" id="cbRecheckFlag" value="1">
			<label for="cbRecheckFlag" style="margin-top: 2px;"></label>
		</div>
	</div>
	<div id="recheck-audio" class="form-group form-audio recheckAudio" style="display: none;">
		<label class="col-sm-2 control-label">音声</label>
		<div class="col-sm-10">
			<div>
				<p class="red12">
					繰返確認時の音声は、入力値読み上げ後の音声を設定してください。
				</p>
				<p class="red12">
					設定した正番号の確認も音声に入れてください。
				</p>
				<p class="red12">
					例）「012345でよろしいですか。」の場合、「でよろしければ１を、間違っていれば２を押して下さい。」
				</p>
			</div>
		</div>
		<label class="col-sm-2 control-label"></label>
		<div class="col-sm-7">
			{if $audio_mix_flag eq '1'}
			<div class="form-audio-type">
				<input type="radio" name="recheck_audio_type" value="0" checked class="rdAudio"><span> 音声ファイル</span>
				<input type="radio" name="recheck_audio_type" value="1" class="rdAudio"><span> 音声合成(男性)</span>
				<input type="radio" name="recheck_audio_type" value="2" class="rdAudio"><span> 音声合成(女性)</span>
			</div>
			{else}
				<input type="radio" name="recheck_audio_type" value="0" class="rdAudio hidden" checked>
			{/if}
			<div class="audio" style="display: block;">
				<input type="text" name="recheck_audio_id" id="hdRecheckAudioId" class="hdAudioId" value="" style="display: none;"/>
				<input type="text" name="recheck_audio_name" class="hdAudioName" value="" style="display: none;"/>
				<input class="btnUploadAudio" type="file" accept="audio/wav" name="data[UploadFile][0]" onchange="upload_file(this);"/>
				<div class="progress" style="display: none;">
					<div class="progress-bar" role="progressbar" aria-valuenow="60" aria-valuemin="0" aria-valuemax="100" style="width: 0%;">
						0%
					</div>
				</div>
			</div>
			{if $audio_mix_flag eq '1'}
			<div class="audio_mix" style="display: none;">
				<textarea rows="3" cols="50" id="txtAudioRecheckContent" class="form-control txtAudioContent" name="recheck_audio_content"></textarea>
<!-- 				<select class="form-control slCustInfo" name="slCustInfo"> -->
<!-- 					{foreach from=$audio_mix_item item=item} -->
<!-- 						<option value="{$item.T13InboundListItem.item_name}">{$item.T13InboundListItem.item_name}</option> -->
<!-- 					{/foreach} -->
<!-- 				</select> -->
<!-- 				<button type="button" name="btnCustInfo" class="btn btn-primary btnCustInfo">挿入</button> -->
			</div>
			{/if}
		</div>
	</div>
	<div class="form-group recheckButtonNext" style="display: none;">
		<label class="col-sm-2 control-label">正番号</label>
		<div class="col-sm-7">
			<select id="slRecheckNext" class="form-control" name="recheck_button_next">
				{foreach from=$answer_no item=item}
					<option value="{$item.M90PulldownCode.item_code}">{$item.M90PulldownCode.item_name}</option>
				{/foreach}
			</select>
		</div>
	</div>
</div>

{* define('QUESTION_PROPERTY_SEARCH', 14);//物件入力(賃料、平米)  *}
{* 物件入力(賃料、平米)  セグメントの追加、編集使う。（プルダウンを選ぶと、この部分が表示。） *}
{* inboundtemplate\add_ques.js　の　function htmlQuesPropertySearch　を経由して *}
{* テンプレート詳細画面に値を転送するため、idや値を間違えないように注意！ *}
{* ※nameはT31のカラム名と合わせる。（合わせられないものは、PHP側で書き換える） *}
<div class="form-group tblAddQues" id="tblQuesPropertySearch" style="display: none;">
	<div id="ques-property-cost-audio" class="form-group form-audio">
		<label class="col-sm-2 control-label">賃料音声</label>
		<div class="col-sm-7">
			{if $audio_mix_flag eq '1'}
			<div class="form-audio-type">
				<input type="radio" name="ques_property_cost_audio_type" value="0" class="rdAudio" checked><span> 音声ファイル</span>
				<input type="radio" name="ques_property_cost_audio_type" value="1" class="rdAudio"><span> 音声合成(男性)</span>
				<input type="radio" name="ques_property_cost_audio_type" value="2" class="rdAudio"><span> 音声合成(女性)</span>
			</div>
			{else}
				<input type="radio" name="ques_property_cost_audio_type" value="0" class="rdAudio hidden" checked>
			{/if}
			<div class="audio" style="display: block;">
				{* idはバリデートで使う *}
				<input type="text" name="ques_property_cost_audio_id" id="hdQuesPropertyCostAudioId" class="hdAudioId" value="" style="display: none;"/>
				<input type="text" name="ques_property_cost_audio_name" class="hdAudioName" value="" style="display: none;"/>
				<input class="btnUploadAudio" type="file" accept="audio/wav" name="data[UploadFile][0]" onchange="upload_file(this);"/>
				<div class="progress" style="display: none;">
					<div class="progress-bar" role="progressbar" aria-valuenow="60" aria-valuemin="0" aria-valuemax="100" style="width: 0%;">
						0%
					</div>
				</div>
			</div>
			{if $audio_mix_flag eq '1'}
			<div class="audio_mix" style="display: none;">
			    {* idはバリデートで使う *}
				<textarea class="form-control txtAudioContent" rows="3" cols="50" id="txtQuesPropertyCostAudioContent" name="ques_property_cost_audio_content"></textarea>
			</div>
			{/if}
		</div>
	</div>

	<div class="form-group">
		<label class="col-sm-2 control-label">桁数</label>
		<div class="col-sm-7">
		    {* idはバリデートで使う *}
			<input type="text" class="form-control" name="ques_property_cost_digit" id="txtQuesPropertyCostDigitProp" placeholder="桁数" value=7 readonly="readonly" />
		</div>
	</div>

    <div id="ques-property-square-audio" class="form-group form-audio">
        <label class="col-sm-2 control-label">平米音声</label>
        <div class="col-sm-7">
            {if $audio_mix_flag eq '1'}
            <div class="form-audio-type">
                <input type="radio" name="ques_property_square_audio_type" value="0" class="rdAudio" checked><span> 音声ファイル</span>
                <input type="radio" name="ques_property_square_audio_type" value="1" class="rdAudio"><span> 音声合成(男性)</span>
                <input type="radio" name="ques_property_square_audio_type" value="2" class="rdAudio"><span> 音声合成(女性)</span>
            </div>
            {else}
                <input type="radio" name="ques_property_square_audio_type" value="0" class="rdAudio hidden" checked>
            {/if}
            <div class="audio" style="display: block;">
                {* idはバリデートで使う *}
                <input type="text" name="ques_property_square_audio_id" id="hdQuesPropertySquareAudioId" class="hdAudioId" value="" style="display: none;"/>
                <input type="text" name="ques_property_square_audio_name" class="hdAudioName" value="" style="display: none;"/>
                <input class="btnUploadAudio" type="file" accept="audio/wav" name="data[UploadFile][0]" onchange="upload_file(this);"/>
                <div class="progress" style="display: none;">
                    <div class="progress-bar" role="progressbar" aria-valuenow="60" aria-valuemin="0" aria-valuemax="100" style="width: 0%;">
                        0%
                    </div>
                </div>
            </div>
            {if $audio_mix_flag eq '1'}
            <div class="audio_mix" style="display: none;">
                {* idはバリデートで使う *}
                <textarea class="form-control txtAudioContent" rows="3" cols="50" id="txtQuesPropertySquareAudioContent" name="ques_property_square_audio_content"></textarea>
            </div>
            {/if}
        </div>
    </div>

    <div class="form-group">
        <label class="col-sm-2 control-label">桁数</label>
        <div class="col-sm-7">
            {* idはバリデートで使う *}
            <input type="text" class="form-control" name="ques_property_square_digit" id="txtQuesPropertySquareDigitProp" placeholder="桁数" value=6 readonly="readonly"/>
        </div>
    </div>

    <div id="ques-property-confirm-audio" class="form-group form-audio">
        <label class="col-sm-2 control-label">物件名確認音声</label>        
		<div class="col-sm-10">
			<div>
				<br>
				<p class="red12">物件名確認時の音声は、物件名読み上げ後の音声を設定してください。</p>
				<p class="red12">設定した物件名が正しい場合の番号も音声に入れてください。</p>
				<p class="red12">例）「六本木マンションでよろしいですか」の場合、</p>
				<p class="red12">「でよろしければ１を、間違っていれば２を押して下さい。」</p>
				<br>
			</div>
		</div>
		<label class="col-sm-2 control-label"></label>
        <div class="col-sm-7">
            {if $audio_mix_flag eq '1'}
                <div class="form-audio-type">
                    <input type="radio" name="ques_property_confirm_audio_type" value="0" class="rdAudio" checked> 音声ファイル
                    <input type="radio" name="ques_property_confirm_audio_type" value="1" class="rdAudio"> 音声合成(男性)
                    <input type="radio" name="ques_property_confirm_audio_type" value="2" class="rdAudio"> 音声合成(女性)
                </div>
            {else}
                <input type="radio" name="ques_property_confirm_audio_type" value="0" class="rdAudio hidden" checked>
            {/if}
            <div class="audio" style="display: block;">
                <input type="text" name="ques_property_confirm_audio_id" id="hdQuesPropertyConfirmAudioId" class="hdAudioId" value="" style="display: none;"/>
                <input type="text" name="ques_property_confirm_audio_name" class="hdAudioName" value="" style="display: none;"/>
                <input class="btnUploadAudio" type="file" accept="audio/wav" name="data[UploadFile][0]" onchange="upload_file(this);"/>
                <div class="progress" style="display: none;">
                    <div class="progress-bar" role="progressbar" aria-valuenow="60" aria-valuemin="0" aria-valuemax="100" style="width: 0%;">
                        0%
                    </div>
                </div>
            </div>
            {if $audio_mix_flag eq '1'}
                <div class="audio_mix" style="display: none;">
                    <textarea rows="3" cols="50" id="txtQuesPropertyConfirmAudioContent" class="form-control txtAudioContent" name="ques_property_confirm_audio_content"></textarea>
                </div>
            {/if}
        </div>
    </div>
    <div class="form-group">
        <label class="col-sm-2 control-label">回答番号</label>
        <div class="col-sm-9">
            <table class="table table-striped table-bordered bootstrap-datatable responsive">
                <colgroup>
                    <col width="70%">
                    <col width="30%">
                </colgroup>
                <thead>
                <tr>
                    <th class="alignCenter">説明</th>
                    <th class="alignCenter">番号</th>
                </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>物件名が正しい場合</td>
                        <td class="alignCenter">
                            {* idは未使用のため削除 *}
                            <select class="form-control" name="ques_property_confirm_answer_no">
                                {foreach from=$answer_no item=item}
                                    <option value="{$item.M90PulldownCode.item_code}">{$item.M90PulldownCode.item_name}</option>
                                {/foreach}
                            </select>
                        </td>
                    </tr>
                    <tr>
                        <td>物件名を訂正する場合</td>
                        <td class="alignCenter">その他</td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>

    <div id="ques-property-continue-audio" class="form-group form-audio">
        <label class="col-sm-2 control-label">継続確認音声</label>        
		<div class="col-sm-10">
			<div>
				<br>
				<p class="red12">継続確認音声は、回答番号番号を入力した後、音声を設定してください。</p>
				<p class="red12">例）「確認を続ける場合は１を、これで終了される方は3を押してください。」</p>
				<br>
			</div>
		</div>
		<label class="col-sm-2 control-label"></label>

        <div class="col-sm-7">
            {if $audio_mix_flag eq '1'}
                <div class="form-audio-type">
                    <input type="radio" name="ques_property_continue_audio_type" value="0" class="rdAudio" checked> 音声ファイル
                    <input type="radio" name="ques_property_continue_audio_type" value="1" class="rdAudio"> 音声合成(男性)
                    <input type="radio" name="ques_property_continue_audio_type" value="2" class="rdAudio"> 音声合成(女性)
                </div>
            {else}
                <input type="radio" name="ques_property_continue_audio_type" value="0" class="rdAudio hidden" checked>
            {/if}
            <div class="audio" style="display: block;">
                <input type="text" name="ques_property_continue_audio_id" id="hdQuesPropertyContinueAudioId" class="hdAudioId" value="" style="display: none;"/>
                <input type="text" name="ques_property_continue_audio_name" class="hdAudioName" value="" style="display: none;"/>
                <input class="btnUploadAudio" type="file" accept="audio/wav" name="data[UploadFile][0]" onchange="upload_file(this);"/>
                <div class="progress" style="display: none;">
                    <div class="progress-bar" role="progressbar" aria-valuenow="60" aria-valuemin="0" aria-valuemax="100" style="width: 0%;">
                        0%
                    </div>
                </div>
            </div>
            {if $audio_mix_flag eq '1'}
                <div class="audio_mix" style="display: none;">
                    <textarea rows="3" cols="50" id="txtQuesPropertyContinueAudioContent" class="form-control txtAudioContent" name="ques_property_continue_audio_content"></textarea>
                </div>
            {/if}
        </div>
    </div>
    <div class="form-group">
        <label class="col-sm-2 control-label">回答番号</label>
        <div class="col-sm-9">
            <table class="table table-striped table-bordered bootstrap-datatable responsive">
                <colgroup>
                    <col width="70%">
                    <col width="30%">
                </colgroup>
                <thead>
                <tr>
                    <th class="alignCenter">説明</th>
                    <th class="alignCenter">番号</th>
                </tr>
                </thead>
                <tbody>
                <tr>
                    {* IDは参照していないため、削除 *}
                    <input type="text" name="hdAnswId0" answer_no="0" style="display: none;"/>
                    <input type="text" name="txtAnswJumpProp0" style="display: none;"/>
                    <td>確認を続ける</td>
                    <td class="alignCenter">{* bukken_cont_answer_no *}{* ques_property_continue_answer_no *}
                        <select id="slBukkenContAnswerNo" class="form-control" name="bukken_cont_answer_no">
                            {foreach from=$answer_no item=item}
                                <option value="{$item.M90PulldownCode.item_code}">{$item.M90PulldownCode.item_name}</option>
                            {/foreach}
                        </select>
                    </td>
                </tr>
                <tr>
                    <td>確認を続けない</td>
                    <td class="alignCenter">その他</td>
                </tr>
                {* IDは参照していないため、削除 *}
                <input type="text" name="hdAnswId99" answer_no="99" style="display: none;"/>
                <input type="text" name="txtAnswJumpProp99" style="display: none;"/>
                </tbody>
            </table>
    	</div>
    </div>



</div>
{* 物件入力(賃料、平米)_ここまで *}

<!-- 通知番号SMS送信 -->
<div class="form-group tblSMS" id="tblSMS" style="display: none;">
    <div class="form-group">
        <label class="col-sm-2 control-label">通知番号</label>
        <div class="col-sm-7">
            <select class="form-control" name="smsPhoneNumber" id="slSMSPhoneNumber">
                <option></option>
                {foreach $phoneNotifyList as $item}
                    {if $item['M08SmsApiInfo']['api_id'] eq $smarty.const.SMS_API_V2_VALUE }
                        <option class="{$smarty.const.SMS_API_V2_STRING}" value="{$item['M08SmsApiInfo']['display_number']}" data-flag="{$item['M08SmsApiInfo']['sms_short_url_allow_flag']}">{$item['M08SmsApiInfo']['display_number']}{$smarty.const.SMS_API_V2_AFTER_TELL_STRING }</option>
                    {else}
                        <option class="{$smarty.const.SMS_API_V1_STRING}" value="{$item['M08SmsApiInfo']['display_number']}" data-flag="{$item['M08SmsApiInfo']['sms_short_url_allow_flag']}">{$item['M08SmsApiInfo']['display_number']}</option>
                    {/if}
                {/foreach}
            </select>
        </div>
    </div>
    <div class="form-group form-audio">
        <label class="col-sm-2 control-label">本文</label>
        <div class="col-sm-7">
            <textarea class="form-control txtAudioContent" name="smsBodyContent" id="smsBodyContent" placeholder="本文" rows="4"></textarea>
            ※本文の文字数：<span id="smsBodyCount" style="color: red;font-weight: bold">0</span>文字(挿入項目は含まない)
            <div class="audio_mix">
	            <select class="form-control slCustInfo" name="slCustInfo">
						{foreach from=$audio_mix_item item=item}
							<option value="{$item.T13InboundListItem.item_name}">{$item.T13InboundListItem.item_name}</option>
						{/foreach}
					</select>
				<button type="button" name="btnCustInfo" class="btn btn-primary btnCustInfo">挿入</button>
			</div>
        </div>
    </div>
	<div class="form-group">
		<label class="col-sm-2 control-label">短縮URL</label>
		<div class="col-sm-7 ptop7">
			<input type="checkbox" name="sms_use_short_url" id="sms_use_short_url" value="1" disabled/>
			<label for="sms_use_short_url" style="margin-top: 2px;"></label>
		</div>
    </div>
    <div id="sms-error-audio" class="form-group form-audio">
		<label class="col-sm-2 control-label">送信不可音声</label>
		<div class="col-sm-7">
			{if $audio_mix_flag eq '1'}
			<div class="form-audio-type">
				<input type="radio" name="ques_inbound_sms_audio_type" value="0" checked class="rdAudio"> 音声ファイル
				<input type="radio" name="ques_inbound_sms_audio_type" value="1" class="rdAudio"> 音声合成(男性)
				<input type="radio" name="ques_inbound_sms_audio_type" value="2" class="rdAudio"> 音声合成(女性)
			</div>
			{else}
				<input type="radio" name="ques_inbound_sms_audio_type" value="0" class="rdAudio hidden" checked>
			{/if}
			<div class="audio" style="display: block;">
				<input type="text" name="ques_sms_inbound_audio_id" id="hdSmsErrorAudioId" class="hdAudioId" value="" style="display: none;"/>
				<input type="text" name="ques_sms_inbound_audio_name" class="hdAudioName" value="" style="display: none;"/>
				<input class="btnUploadAudio" type="file" accept="audio/wav" name="data[UploadFile][0]" onchange="upload_file(this);"/>
				<div class="progress" style="display: none;">
					<div class="progress-bar" role="progressbar" aria-valuenow="60" aria-valuemin="0" aria-valuemax="100" style="width: 0%;">
						0%
					</div>
				</div>
			</div>
			{if $audio_mix_flag eq '1'}
			<div class="audio_mix" style="display: none;">
				<textarea rows="3" cols="50" id="txtAudioSmsErrorContent" class="form-control txtAudioContent" name="ques_inbound_sms_audio_content"></textarea>
			</div>
			{/if}
		</div>
	</div>
	<input type="text" name="hdAnswId99" answer_no="99" id="hdAnswId99" style="display: none;"/>
	<input type="text" name="txtAnswJumpSms99" style="display: none;"/>
</div>

<!-- 番号指定SMS -->
<div class="form-group tblSMSINPUT" id="tblSMSINPUT" style="display: none;">
    <div class="form-group">
        <label class="col-sm-2 control-label">通知番号</label>
        <div class="col-sm-7">
            <select class="form-control" name="smsInputPhoneNumber" id="slSMSInputPhoneNumber">
                <option></option>
                {foreach $phoneNotifyList as $item}
                    {if $item['M08SmsApiInfo']['api_id'] eq $smarty.const.SMS_API_V2_VALUE }
                        <option class="{$smarty.const.SMS_API_V2_STRING}" value="{$item['M08SmsApiInfo']['display_number']}" data-flag="{$item['M08SmsApiInfo']['sms_short_url_allow_flag']}">{$item['M08SmsApiInfo']['display_number']}{$smarty.const.SMS_API_V2_AFTER_TELL_STRING }</option>
                    {else}
                        <option class="{$smarty.const.SMS_API_V1_STRING}" value="{$item['M08SmsApiInfo']['display_number']}" data-flag="{$item['M08SmsApiInfo']['sms_short_url_allow_flag']}">{$item['M08SmsApiInfo']['display_number']}</option>
                    {/if}
                {/foreach}
            </select>
        </div>
    </div>
    <div class="form-group form-audio">
        <label class="col-sm-2 control-label">本文</label>
        <div class="col-sm-7">
            <textarea class="form-control txtAudioContent" name="smsInputBodyContent" id="smsInputBodyContent" placeholder="本文" rows="4"></textarea>
            ※本文の文字数：<span id="smsInputBodyCount" style="color: red;font-weight: bold">0</span>文字(挿入項目は含まない)
            <div class="audio_mix">
	            <select class="form-control slCustInfo" name="slCustInfo">
						{foreach from=$audio_mix_item item=item}
							<option value="{$item.T13InboundListItem.item_name}">{$item.T13InboundListItem.item_name}</option>
						{/foreach}
					</select>
				<button type="button" name="btnCustInfo" class="btn btn-primary btnCustInfo">挿入</button>
			</div>
        </div>
    </div>
	<div class="form-group">
		<label class="col-sm-2 control-label">短縮URL</label>
		<div class="col-sm-7 ptop7">
			<input type="checkbox" name="sms_input_use_short_url" id="sms_input_use_short_url" value="1" disabled/>
			<label for="sms_input_use_short_url" style="margin-top: 2px;"></label>
		</div>
    </div>
    <div id="sms-input-error-audio" class="form-group form-audio">
		<label class="col-sm-2 control-label">送信不可音声</label>
		<div class="col-sm-7">
			{if $audio_mix_flag eq '1'}
			<div class="form-audio-type">
				<input type="radio" name="ques_inbound_sms_input_audio_type" value="0" checked class="rdAudio"> 音声ファイル
				<input type="radio" name="ques_inbound_sms_input_audio_type" value="1" class="rdAudio"> 音声合成(男性)
				<input type="radio" name="ques_inbound_sms_input_audio_type" value="2" class="rdAudio"> 音声合成(女性)
			</div>
			{else}
				<input type="radio" name="ques_inbound_sms_input_audio_type" value="0" class="rdAudio hidden" checked>
			{/if}
			<div class="audio" style="display: block;">
				<input type="text" name="ques_sms_input_inbound_audio_id" id="hdSmsInputErrorAudioId" class="hdAudioId" value="" style="display: none;"/>
				<input type="text" name="ques_sms_input_inbound_audio_name" class="hdAudioName" value="" style="display: none;"/>
				<input class="btnUploadAudio" type="file" accept="audio/wav" name="data[UploadFile][0]" onchange="upload_file(this);"/>
				<div class="progress" style="display: none;">
					<div class="progress-bar" role="progressbar" aria-valuenow="60" aria-valuemin="0" aria-valuemax="100" style="width: 0%;">
						0%
					</div>
				</div>
			</div>
			{if $audio_mix_flag eq '1'}
			<div class="audio_mix" style="display: none;">
				<textarea rows="3" cols="50" id="txtAudioSmsInputErrorContent" class="form-control txtAudioContent" name="ques_inbound_sms_input_audio_content"></textarea>
			</div>
			{/if}
		</div>
	</div>
	<input type="text" name="hdAnswId99" answer_no="99" id="hdAnswId99" style="display: none;"/>
	<input type="text" name="txtAnswJumpSmsInput99" style="display: none;"/>
	<input type="text" name="hdAnswId98" answer_no="98" id="hdAnswId98" style="display: none;"/>
	<input type="text" name="txtAnswJumpSmsInputTimeOut98" style="display: none;"/>
</div>

<!-- jump_ques -->
<div class="form-group tblAddQues" id="tblJumpQues" style="display: none;">
	<input type="text" name="jump_question" style="display: none;"/>
</div>