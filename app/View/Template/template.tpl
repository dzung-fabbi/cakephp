{html func=script url='pager'}
{html func=script url='view/template/template'}
{html func=script url='view/template/add_ques'}
{html func=script url='view/template/validate'}
{html func=css path='template/index'}
<script type="text/javascript">
	glb_arr_ques = {if $jsObjectkey}{$jsObjectkey}{else}{'new Object()'}{/if};
</script>
<div id="audio-player" style="display: none;">
	<audio controls class="audio_plugin" src="" type="audio/x-wav"></audio>
</div>
<div class="col-lg-10 col-sm-10" id="content">
<!-- content starts -->
	{if $exist_schedule && $post_code != "U30" && $post_code != "G30"}
		<div class="alert alert-danger fade in"><button type="button" class="close">×</button>予定されているスケジュールに存在するテンプレートの為編集できません。</div>
	{/if}

	<div class="alert alert-danger fade in" id="template-error-message" style="display:none">
		<button type="button" class="close">×</button>
	</div>

	<div class="row">
		<div class="alert alert-danger" style="display: none;" id="flash-error"></div>
		<form class="form form-inline" id="TemplateForm">
			<div class="form-group col-xs-12 col-sm-6 col-lg-4">
				<label for="txtTemplateName" class="col-xs-5">テンプレート名</label>
				<div class="col-xs-7">
					{if $action eq "update"}
					<input type="text" id="hdTemplateId" value="{if isset($template_id) && !empty($template_id)}{$template_id}{/if}" name="data[T30Template][id]" style="display: none;"/>
					{/if}
					<input type="text" class="form-control input-sm" maxlength="50" id="txtTemplateName" value="{if isset($template_name) && !empty($template_name) && $action eq 'update'}{$template_name}{/if}" name="data[T30Template][template_name]" placeholder="テンプレート名" {if !$permission_flag || $exist_schedule}disabled{/if}/>
				</div>
			</div>
			<div class="form-group col-xs-12 col-sm-6 col-lg-4">
				<label for="txtTemplateDescription" class="col-xs-5">説明</label>
				<div class="col-xs-7">
					<input type="text" class="form-control input-sm"　maxlength="200" id="txtTemplateDescription" value="{if isset($description) && !empty($description)}{$description}{/if}" name="data[T30Template][description]" placeholder="説明" {if !$permission_flag || $exist_schedule}disabled{/if}/>
				</div>
			</div>
			<div class="form-group col-xs-12 col-sm-6 col-lg-4">
				<a href="#" title="全て開く" id="btnShowAll" data-toggle="tooltip" class="btn btn-primary btn-sm col-xs-5">全て開く</a>
				<a href="#" title="全て閉じる" id="btnHideAll" data-toggle="tooltip" class="btn btn-primary btn-sm col-xs-5 col-xs-offset-1">全て閉じる</a>
			</div>
		</form>
	</div>
	<div class="row">
		<div class="form-group col-xs-12 col-sm-6 col-lg-4">
			{if $permission_flag && !$exist_schedule}
				<a href="#" title="セクションの追加" id="btnAddQues" data-toggle="tooltip" class="btn btn-primary col-xs-5">セクションの追加</a>
				{if $action eq "insert" || $action eq "duplicate"}
					<a href="#" title="保存" id="btnSubmit" data-toggle="tooltip" class="btn btn-primary col-xs-5 col-xs-offset-1">保存</a>
				{elseif $action eq "update"}
					<a href="#" title="更新" id="btnSubmit" data-toggle="tooltip" class="btn btn-primary col-xs-5 col-xs-offset-1">更新</a>
				{/if}
			{/if}
		</div>
	</div>

	<div class="template">
		{foreach from=$ques_info key=ques_no item=data}
			{if $data.question_type neq '9'}
			<div class="row row_question">
				<div class="box col-md-12">
					<div class="box-inner">
						<div class="box-header well" data-original-title="">
							<h2><span class="ques_no">{$ques_no}</span>. <span class="ques_type_txt">{$data.question_type_txt}</span></h2>
							<span class="ques_title">&nbsp;&nbsp;&nbsp;&nbsp;{$data.question_title}</span>
							{if $data.question_yuko == 1}
							    <span class="label-success label label-default">有効</span>
							{/if}
							<div class="box-icon">
								{if $permission_flag && !$exist_schedule}
									<input type="text" name="id" class="hdQuesId" value="{$data.id}" style="display: none;">
									<input type="text" class="hdQuesNo" value="{$ques_no}" style="display: none;">
									<a href="#" class="btn btnEdit btn-round btn-default">
										<i title="編集" class="glyphicon glyphicon-edit"></i>
									</a>
									<a href="#" class="btn btnDelete btn-round btn-default">
										<i title="削除" class="glyphicon glyphicon-trash"></i>
									</a>
								{/if}
									<a href="#" class="btn btnShowHide btn-round btn-default">
										<i title="最小化/最大化" class="glyphicon glyphicon-chevron-down"></i>
									</a>
								{if $permission_flag && !$exist_schedule}
									<a href="#" class="btn btnMove btn-round btn-default">
										<i title="位置移動" class="glyphicon glyphicon-move"></i>
									</a>
								{/if}
							</div>
						</div>
						{if $data.question_type == 1}<!-- 再生 -->
						<div class="box-content">
							<div class="row">
								<div class="col-md-2">
									<p>飛び先</p>
								</div>
								<div class="col-md-2 select_jump_ques_container" jump_question="{$data.jump_question}"></div>
							</div>

							<div class="row">
								<div class="col-md-2">
									<p>音声</p>
								</div>
								<div class="col-md-10">
									{if $data.audio_type == 0}
									<div class="col-md-3">
										<p><label> {$data.audio_name} </label></p>
									</div>
									<div class="col-md-7">
										<p>
											<a class="btn btnPlay btn-default" audio_id="{$data.audio_id}">
												<i class="glyphicon glyphicon-play" ></i>
											</a>
											<a class="btn btnStop btn-default">
												<i class="glyphicon glyphicon-stop" ></i>
											</a>
										</p>
									</div>
									{else}
									<p>{$data.audio_content}</p>
									{/if}
								</div>
							</div>
						</div>
						{elseif $data.question_type == 2}<!-- 質問 -->
						<div class="box-content">
<!-- 							<div class="row"> -->
<!-- 								<div class="col-md-2"> -->
<!-- 									<p>有効質問</p> -->
<!-- 								</div> -->
<!-- 								<div class="col-md-10"> -->
<!-- 									{if $data.question_yuko == 0} -->
<!-- 										<p>なし</p> -->
<!-- 									{else} -->
<!-- 										<p>あり</p> -->
<!-- 									{/if} -->
<!-- 								</div> -->
<!-- 							</div> -->
							<div class="row">
								<div class="col-md-2">
									<p>音声</p>
								</div>
								<div class="col-md-10">
									{if $data.audio_type == 0}
									<div class="col-md-3">
										<p><label> {$data.audio_name} </label></p>
									</div>
									<div class="col-md-7">
										<p>
											<a class="btn btnPlay btn-default" audio_id="{$data.audio_id}">
												<i class="glyphicon glyphicon-play" ></i>
											</a>
											<a class="btn btnStop btn-default">
												<i class="glyphicon glyphicon-stop" ></i>
											</a>
										</p>
									</div>
									{else}
									<p>{$data.audio_content}</p>
									{/if}
								</div>
							</div>
							<div class="row">
								<div class="col-md-2">
									<p>繰り返し</p>
								</div>
								<div class="col-md-10">
									<p>{if $data.question_repeat > 0}{$data.question_repeat}回{else}なし{/if}</p>
								</div>
							</div>
							<div class="row">
								<div class="col-md-8">
									<p>回答</p>
									<table class="table table-bordered table-striped table-condensed">
										<thead>
											<tr>
												<th class="alignCenter templateTable-60">番号</th>
												<th class="alignCenter templateTable-40">テキスト</th>
												<th class="alignCenter templateTable-60">有効</th>
												<th class="alignCenter col-md-3">飛び先</th>
											</tr>
										</thead>
										<tbody>
											{foreach from=$arr_answ.$ques_no key=ques_no_tmp item=answ}
												{if $answ.T32TemplateButton.answer_no != 0
													&& $answ.T32TemplateButton.answer_no != 51
													&& $answ.T32TemplateButton.answer_no != 52
													&& $answ.T32TemplateButton.answer_no != 99
												}
												<tr>
													<td class="alignCenter">
														{$answ.T32TemplateButton.answer_no}
													</td>
													<td> {$answ.T32TemplateButton.answer_content} </td>
													<td class="alignCenter">
														{if $answ.T32TemplateButton.yuko_flag == 1}
														<span class="label-success label label-default">〇</span>
														{else}
														<span class="label-default label">×</span>
														{/if}
													</td>
													<td class="alignCenter select_jump_ques_container" jump_question="{$answ.T32TemplateButton.jump_question}" ans_no="{$answ.T32TemplateButton.answer_no}"></td>
												</tr>
												{/if}
											{/foreach}

											{foreach from=$arr_answ.$ques_no key=ques_no_tmp item=answ}
												{if $answ.T32TemplateButton.answer_no == 0}
												<tr>
													<td class="alignCenter">
														{$answ.T32TemplateButton.answer_no}
													</td>
													<td> {$answ.T32TemplateButton.answer_content} </td>
													<td class="alignCenter">
														{if $answ.T32TemplateButton.yuko_flag == 1}
														<span class="label-success label label-default">〇</span>
														{else}
														<span class="label-default label">×</span>
														{/if}
													</td>
													<td class="alignCenter select_jump_ques_container" jump_question="{$answ.T32TemplateButton.jump_question}" ans_no="{$answ.T32TemplateButton.answer_no}"></td>
												</tr>
												{/if}
											{/foreach}

											{foreach from=$arr_answ.$ques_no key=ques_no_tmp item=answ}
												{if $answ.T32TemplateButton.answer_no == 51 || $answ.T32TemplateButton.answer_no == 52}
												<tr>
													<td class="alignCenter">
														{if $answ.T32TemplateButton.answer_no == 51}
															*
														{elseif $answ.T32TemplateButton.answer_no == 52}
															#
														{/if}
													</td>
													<td> {$answ.T32TemplateButton.answer_content} </td>
													<td class="alignCenter">
														{if $answ.T32TemplateButton.yuko_flag == 1}
														<span class="label-success label label-default">〇</span>
														{else}
														<span class="label-default label">×</span>
														{/if}
													</td>
													<td class="alignCenter select_jump_ques_container" jump_question="{$answ.T32TemplateButton.jump_question}" ans_no="{$answ.T32TemplateButton.answer_no}"></td>
												</tr>
												{/if}
											{/foreach}
											<tr>
												<td colspan="3">タイムアウト</td>
												{$jump_ques = ''}
												{foreach from=$arr_answ.$ques_no key=ques_no_tmp item=answ}
													{if $answ.T32TemplateButton.answer_no == 99}
														{$jump_ques = $answ.T32TemplateButton.jump_question}
													{/if}
												{/foreach}
												<td class="alignCenter select_jump_ques_container" jump_question="{$jump_ques}" ans_no="99"></td>
											</tr>
											<tr>
												<td colspan="3">他の場合</td>
												<td class="alignCenter select_jump_ques_container" jump_question="{$data.jump_question}"></td>
											</tr>
										</tbody>
									</table>
								</div>
							</div>
						</div>
						{elseif ($data.question_type == 3 || $data.question_type == 10)}<!-- 数値認証 or 文字列認証 -->
						<div class="box-content">
							<div class="row">
								<div class="col-md-2">
									<p>音声</p>
								</div>
								<div class="col-md-10">
									{if $data.audio_type == 0}
									<div class="col-md-3">
										<p><label> {$data.audio_name} </label></p>
									</div>
									<div class="col-md-7">
										<p>
											<a class="btn btnPlay btn-default" audio_id="{$data.audio_id}">
												<i class="glyphicon glyphicon-play" ></i>
											</a>
											<a class="btn btnStop btn-default">
												<i class="glyphicon glyphicon-stop" ></i>
											</a>
										</p>
									</div>
									{else}
									<p>{$data.audio_content}</p>
									{/if}
								</div>
							</div>
							<div class="row">
								<div class="col-md-2">
									<p>認証項目</p>
								</div>
								<div class="col-md-10">
									{$data.auth_item_name}
								</div>
							</div>
							<div class="row">
								<div class="col-md-2">
									<p>桁数</p>
								</div>
								<div class="col-md-10">
									{$data.digit_auth}
								</div>
							</div>
							<div class="row">
								<div class="col-md-2"><p>繰返確認</p></div>
								<div class="col-md-10">
									{if $data.recheck_flag == 0}
										<p>なし</p>
									{else}
										<p>あり</p>
									{/if}
								</div>
							</div>
							{if $data.recheck_flag == 1}
								<div class="row">
									<div class="col-md-2">
										<p>繰返確認音声</p>
									</div>
									<div class="col-md-10">
										{if ($data.recheck_audio_type == 1 || $data.recheck_audio_type == 2)}
											{$data.recheck_audio_content}
										{else}
										<div class="col-md-3">
											<p><label>{$data.recheck_audio_name}</label></p>
										</div>
										<div class="col-md-7">
											<p>
												<a class="btn btnPlay btn-default" audio_id="{$data.recheck_audio_id}">
													<i class="glyphicon glyphicon-play" ></i>
												</a>
												<a class="btn btnStop btn-default">
													<i class="glyphicon glyphicon-stop" ></i>
												</a>
											</p>
										</div>
										{/if}
									</div>
								</div>
							{/if}
							{if $data.recheck_flag == 1}
							<div class="row">
								<div class="col-md-2">
									<p>正番号</p>
								</div>
								<div class="col-md-10">
									{if $data.recheck_button_next == 51}*
									{elseif $data.recheck_button_next == 52}#
									{else} {$data.recheck_button_next}
									{/if}
								</div>
							</div>
							{/if}
							<div class="row">
								<div class="col-md-8">
									<p>回答</p>
									<table class="table table-bordered table-striped table-condensed">
										<thead>
											<tr>
												<th class="alignCenter" style="width:40px;min-width:140px;">判断</th>
												<th class="alignCenter" style="min-width:40px;">テキスト</th>
												<th class="alignCenter" style="width:60px;min-width:60px;">有効</th>
												<th class="alignCenter col-md-3">飛び先</th>
											</tr>
										</thead>
										{if ($data.question_type == 3)}
											{assign var=answer_titles value=[0=>'入力値 ＜ 認証項目', 1=>'入力値 ＝ 認証項目', 2=>'入力値 ＞ 認証項目']}
										{else}
											{assign var=answer_titles value=[0=>'入力値 ＝ 認証項目', 1=>'入力値 ≠ 認証項目']}
										{/if}
										<tbody>
											{foreach from=$answer_titles key=key item=answer_title}
												<tr>
													<td class="alignCenter">{$answer_title}</td>
													<td> {$arr_answ.$ques_no[$key].T32TemplateButton.answer_content} </td>
													<td class="alignCenter">
														{if $arr_answ.$ques_no[$key].T32TemplateButton.yuko_flag == 1}
															<span class="label-success label label-default">〇</span>
														{else}
															<span class="label-default label">×</span>
														{/if}
													</td>
													<td class="alignCenter select_jump_ques_container" jump_question="{$arr_answ.$ques_no[$key].T32TemplateButton.jump_question}" ans_no="{$arr_answ.$ques_no[$key].T32TemplateButton.answer_no}"></td>
												</tr>
											{/foreach}
											<tr>
												<td colspan="3">
													タイムアウト
												</td>
												<td class="alignCenter select_jump_ques_container" jump_question="{$arr_answ.$ques_no[$key+1].T32TemplateButton.jump_question}" ans_no="{$arr_answ.$ques_no[$key+1].T32TemplateButton.answer_no}"></td>
											</tr>
											{if ($data.question_type == 3)}
												<tr>
													<td colspan="3">
														他の場合
													</td>
													<td class="alignCenter select_jump_ques_container" jump_question="{$data.jump_question}"></td>
												</tr>
											{/if}
										</tbody>
									</table>
								</div>
							</div>
						</div>
						{elseif $data.question_type == 4}<!-- 番号入力 -->
						<div class="box-content">
							<div class="row">
								<div class="col-md-2">
									<p>飛び先</p>
								</div>
								<div class="col-md-2 select_jump_ques_container" jump_question="{$data.jump_question}"></div>
							</div>
							<div class="row">
								<div class="col-md-2">
									<p>タイムアウト</p>
								</div>
								{if (isset($arr_answ.$ques_no[0]))}
									<div class="col-md-2 select_jump_ques_container" jump_question="{$arr_answ.$ques_no[0].T32TemplateButton.jump_question}" ans_no="{$arr_answ.$ques_no[0].T32TemplateButton.answer_no}"></div>
								{else}
									<div class="col-md-2 select_jump_ques_container" jump_question="" ans_no="99"></div>
								{/if}
							</div>
							<div class="row">
								<div class="col-md-2"><p>音声</p></div>
								<div class="col-md-10">
									{if $data.audio_type == 0}
									<div class="col-md-3">
										<p><label> {$data.audio_name} </label></p>
									</div>
									<div class="col-md-7">
										<p>
											<a class="btn btnPlay btn-default" audio_id="{$data.audio_id}">
												<i class="glyphicon glyphicon-play" ></i>
											</a>
											<a class="btn btnStop btn-default">
												<i class="glyphicon glyphicon-stop" ></i>
											</a>
										</p>
									</div>
									{else}
									<p>{$data.audio_content}</p>
									{/if}
								</div>
							</div>
							<div class="row">
								<div class="col-md-2"><p>桁数</p></div>
								<div class="col-md-10">{$data.digit_tel}</div>
							</div>

							<div class="row">
								<div class="col-md-2"><p>繰返確認</p></div>
								<div class="col-md-10">
									{if $data.recheck_flag == 0}
										<p>なし</p>
									{else}
										<p>あり</p>
									{/if}
								</div>
							</div>
							{if $data.recheck_flag == 1}
							<div class="row">
								<div class="col-md-2">
									<p>繰返確認音声</p>
								</div>
								<div class="col-md-10">
									{if ($data.recheck_audio_type == 1 || $data.recheck_audio_type == 2)}
										{$data.recheck_audio_content}
									{else}
									<div class="col-md-3">
										<p><label>{$data.recheck_audio_name}</label></p>
									</div>
									<div class="col-md-7">
										<p>
											<a class="btn btnPlay btn-default" audio_id="{$data.recheck_audio_id}">
												<i class="glyphicon glyphicon-play" ></i>
											</a>
											<a class="btn btnStop btn-default">
												<i class="glyphicon glyphicon-stop" ></i>
											</a>
										</p>
									</div>
									{/if}
								</div>
							</div>
							<div class="row">
								<div class="col-md-2">
									<p>正番号</p>
								</div>
								<div class="col-md-10">
									{if $data.recheck_button_next == 51}*
									{elseif $data.recheck_button_next == 52}#
									{else} {$data.recheck_button_next}
									{/if}
								</div>
							</div>
							{/if}
						</div>
						{elseif $data.question_type == 5}<!-- 転送 -->
						<div class="box-content">
							<div class="row">
								<div class="col-md-2">
									<p>転送飛び先音声</p>
								</div>
								<div class="col-md-10">
									{if $data.audio_type == 0}
									<div class="col-md-3">
										<p><label> {$data.audio_name} </label></p>
									</div>
									<div class="col-md-7">
										<p>
											<a class="btn btnPlay btn-default" audio_id="{$data.audio_id}">
												<i class="glyphicon glyphicon-play" ></i>
											</a>
											<a class="btn btnStop btn-default">
												<i class="glyphicon glyphicon-stop" ></i>
											</a>
										</p>
									</div>
									{else}
									<p>{$data.audio_content}</p>
									{/if}
								</div>
							</div>

							<div class="row">
								<div class="col-md-2">
									<p>転送タイムアウト音声</p>
								</div>
								<div class="col-md-10">
									{if $data.trans_timeout_audio_type == 0}
									<div class="col-md-3">
										<p><label> {$data.trans_timeout_audio_name} </label></p>
									</div>
									<div class="col-md-7">
										<p>
											<a class="btn btnPlay btn-default" audio_id="{$data.trans_timeout_audio_id}">
												<i class="glyphicon glyphicon-play" ></i>
											</a>
											<a class="btn btnStop btn-default">
												<i class="glyphicon glyphicon-stop" ></i>
											</a>
										</p>
									</div>
									{else}
									<p>{$data.trans_timeout_audio_content}</p>
									{/if}
								</div>
							</div>
							<div class="row">
								<div class="col-md-2"><p>転送先電話番号</p></div>
								<div class="col-md-10">{$data.trans_tel}</div>
							</div>
							<div class="row">
								<div class="col-md-2"><p>転送先席数</p></div>
								<div class="col-md-10">{$data.trans_seat_num}</div>
							</div>
							<div class="row">
								<div class="col-md-2"><p>空き席数無し時<br>発信停止</p></div>
								<div class="col-md-10">
									{if $data.trans_empty_seat_flag == 0}
										なし
									{else}
										あり
									{/if}
								</div>
							</div>
							<div class="row">
								<div class="col-md-2"><p>転送タイムアウト(秒)</p></div>
								<div class="col-md-10">{$data.trans_timeout}</div>
							</div>
							<div class="row">
								<div class="col-md-2"><p>転送元番号再生</p></div>
								<div class="col-md-10">
									{if $data.trans_phone_number_play_flag == 0}
										なし
									{else}
										あり
									{/if}
								</div>
							</div>
						</div>
						{elseif $data.question_type == 6}<!-- 録音 -->
						<div class="box-content">
							<div class="row">
								<div class="col-md-2">
									<p>飛び先</p>
								</div>
								<div class="col-md-2 select_jump_ques_container" jump_question="{$data.jump_question}">
								</div>
							</div>
							<div class="row">
								<div class="col-md-2">
									<p>音声</p>
								</div>
								<div class="col-md-10">
									{if $data.audio_type == 0}
									<div class="col-md-3">
										<p><label> {$data.audio_name} </label></p>
									</div>
									<div class="col-md-7">
										<p>
											<a class="btn btnPlay btn-default" audio_id="{$data.audio_id}">
												<i class="glyphicon glyphicon-play" ></i>
											</a>
											<a class="btn btnStop btn-default">
												<i class="glyphicon glyphicon-stop" ></i>
											</a>
										</p>
									</div>
									{else}
									<p>{$data.audio_content}</p>
									{/if}
								</div>
							</div>
							<div class="row">
								<div class="col-md-2">
									<p>秒数</p>
								</div>
								<div class="col-md-10">
									{$data.second_record}
								</div>
							</div>
							<div class="row">
								<div class="col-md-2">
									<p>#ボタン終了</p>
								</div>
								<div class="col-md-10">
									{if $data.yuko_button_record eq '1'}あり{else}なし{/if}
								</div>
							</div>
						</div>
						{elseif $data.question_type == 7}<!-- カウント -->
						<div class="box-content">
							<div class="row">
								<div class="col-md-2">
									<p>飛び先</p>
								</div>
								<div class="col-md-2 select_jump_ques_container" jump_question="{$data.jump_question}"></div>
							</div>
						</div>
						{elseif $data.question_type == 8}<!-- 切断 -->
						{elseif $data.question_type == 9}
						{elseif $data.question_type == 13}
						<div class="box-content">
							<div class="row">
								<div class="col-md-2">
									<p>飛び先</p>
								</div>
								<div class="col-md-2 select_jump_ques_container"
									 jump_question="{$data.jump_question}"></div>
							</div>
							<div class="row">
								<div class="col-md-2">
									<p>送信不可</p>
								</div>
                                {if (isset($arr_answ.$ques_no[0]))}
									<div class="col-md-2 select_jump_ques_container" jump_question="{$arr_answ.$ques_no[0].T32TemplateButton.jump_question}" ans_no="{$arr_answ.$ques_no[0].T32TemplateButton.answer_no}"></div>
                                {else}
									<div class="col-md-2 select_jump_ques_container" jump_question="" ans_no="99"></div>
                                {/if}
							</div>
							<div class="row">
								<div class="col-md-2">
									<p>通知番号</p>
								</div>
								<div class="col-md-10 sms-common-phonenumber">{$data.smsPhoneNumber}</div>
							</div>
							<div class="row">
								<div class="col-md-2"><p>本文</p></div>
								<div class="col-md-10">{$data.smsBodyContent}</div>
							</div>
							<div class="row">
								<div class="col-md-2"><p>短縮URL</p></div>
								<!---   -->
								<div class="col-md-10 sms-short-url">{if $data.sms_use_short_url eq '1'}あり{else}なし{/if}</div>
							</div>
							<div class="row">
								<div class="col-md-2"><p>送信不可音声</p></div>
								<div class="col-md-10 sms-common-audio">
									{if $data.ques_sms_audio_type == 0}
										<div class="col-md-3">
											<p><label> {$data.ques_sms_audio_name} </label></p>
										</div>
										<div class="col-md-7">
											<p>
												<a class="btn btnPlay btn-default" audio_id="{$data.ques_sms_audio_id}">
													<i class="glyphicon glyphicon-play" ></i>
												</a>
												<a class="btn btnStop btn-default">
													<i class="glyphicon glyphicon-stop" ></i>
												</a>
											</p>
										</div>
									{else}
										<p>{$data.ques_sms_audio_content}</p>
									{/if}
								</div>
							</div>
						</div>
						{elseif $data.question_type == 19}<!-- 番号指定SMS -->
						<div class="box-content">
							<div class="row">
								<div class="col-md-2">
									<p>飛び先</p>
								</div>
								<div class="col-md-2 select_jump_ques_container" jump_question="{$data.jump_question}"></div>
							</div>
							<div class="row">
								<div class="col-md-2">
									<p>送信不可</p>
								</div>
								{* タイムアウトの設定有無で取得する要素数がことなるための調整*}
								{* タイムアウトありの場合$ques_no[0]（タイムアウト）,$ques_no[1]（送信不可）*}
								{* タイムアウトなしの場合$ques_no[0]（送信不可）*}
								{if (isset($arr_answ.$ques_no[1]))}
									<div class="col-md-2 select_jump_ques_container" jump_question="{$arr_answ.$ques_no[1].T32TemplateButton.jump_question}" ans_no="{$arr_answ.$ques_no[1].T32TemplateButton.answer_no}"></div>
								{elseif (isset($arr_answ.$ques_no[0]))}
									<div class="col-md-2 select_jump_ques_container" jump_question="{$arr_answ.$ques_no[0].T32TemplateButton.jump_question}" ans_no="{$arr_answ.$ques_no[0].T32TemplateButton.answer_no}"></div>
								{else}
									<div class="col-md-2 select_jump_ques_container" jump_question="" ans_no="99"></div>
								{/if}
							</div>
							<div class="row">
								<div class="col-md-2">
									<p>タイムアウト</p>
								</div>
								{if (isset($arr_answ.$ques_no[0]) && isset($arr_answ.$ques_no[1])) }
									<div class="col-md-2 select_jump_ques_container" jump_question="{$arr_answ.$ques_no[0].T32TemplateButton.jump_question}" ans_no="{$arr_answ.$ques_no[0].T32TemplateButton.answer_no}"></div>
								{else}
									<div class="col-md-2 select_jump_ques_container" jump_question="" ans_no="98"></div>
								{/if}
							</div>
							<div class="row">
								<div class="col-md-2">
									<p>音声</p>
								</div>
								<div class="col-md-10">
									{if $data.audio_type == 0}
										<div class="col-md-3">
											<p><label> {$data.audio_name} </label></p>
										</div>
										<div class="col-md-7">
											<p>
												<a class="btn btnPlay btn-default" audio_id="{$data.audio_id}">
													<i class="glyphicon glyphicon-play" ></i>
												</a>
												<a class="btn btnStop btn-default">
													<i class="glyphicon glyphicon-stop" ></i>
												</a>
											</p>
										</div>
									{else}
										<p>{$data.audio_content}</p>
									{/if}
								</div>
							</div>
							<div class="row">
								<div class="col-md-2">
									<p>繰返確認音声</p>
								</div>
								<div class="col-md-10">
									{if ($data.recheck_audio_type == 1 || $data.recheck_audio_type == 2)}
										{$data.recheck_audio_content}
									{else}
										<div class="col-md-3">
											<p><label>{$data.recheck_audio_name}</label></p>
										</div>
										<div class="col-md-7">
											<p>
												<a class="btn btnPlay btn-default" audio_id="{$data.recheck_audio_id}">
													<i class="glyphicon glyphicon-play" ></i>
												</a>
												<a class="btn btnStop btn-default">
													<i class="glyphicon glyphicon-stop" ></i>
												</a>
											</p>
										</div>
									{/if}
								</div>
							</div>
							<div class="row">
								<div class="col-md-2">
									<p>正番号</p>
								</div>
								<div class="col-md-10">
									{if $data.recheck_button_next == 51}*
									{elseif $data.recheck_button_next == 52}#
									{else}
										{$data.recheck_button_next}
									{/if}
								</div>
							</div>
							<div class="row">
								<div class="col-md-2"><p>通知番号</p></div>
								<div class="col-md-10 sms-common-phonenumber">{$data.smsInputPhoneNumber}</div>
							</div>
							<div class="row">
								<div class="col-md-2"><p>本文</p></div>
								<div class="col-md-10">{$data.smsInputBodyContent}</div>
							</div>
							<div class="row">
								<div class="col-md-2"><p>短縮URL</p></div>
								<div class="col-md-10 sms-short-url">{if $data.sms_input_use_short_url eq '1'}あり{else}なし{/if}</div>
							</div>
							<div class="row">
								<div class="col-md-2"><p>送信不可音声</p></div>
								<div class="col-md-10 sms-common-audio">
									{if $data.ques_sms_input_audio_type == 0}
										<div class="col-md-3">
											<p><label> {$data.ques_sms_input_audio_name} </label></p>
										</div>
										<div class="col-md-7">
											<p>
												<a class="btn btnPlay btn-default" audio_id="{$data.ques_sms_input_audio_id}">
													<i class="glyphicon glyphicon-play" ></i>
												</a>
												<a class="btn btnStop btn-default">
													<i class="glyphicon glyphicon-stop" ></i>
												</a>
											</p>
										</div>
									{else}
										<p>{$data.ques_sms_input_audio_content}</p>
									{/if}
								</div>
							</div>
						</div>
						{/if}
					</div>
				</div>
			</div>
			{/if}
		{/foreach}
	</div>
	<div class="timeout">
		{foreach from=$ques_info key=ques_no item=data}
		{if $data.question_type eq '9'}
		<div class="row row_question">
			<div class="box col-md-12">
				<div class="box-inner">
					<div class="box-header well" data-original-title="">
						<h2><span class="ques_no">{$ques_no}</span>. <span class="ques_type_txt">{$data.question_type_txt}</span></h2>
						<span class="ques_title">&nbsp;&nbsp;&nbsp;&nbsp;{$data.question_title}</span>
						<div class="box-icon">
							{if $permission_flag && !$exist_schedule}
								<input type="text" name="id" class="hdQuesId" value="{$data.id}" style="display: none;">
								<input type="text" class="hdQuesNo" value="{$ques_no}" style="display: none;">
								<a href="#" class="btn btnEdit btn-round btn-default">
									<i title="編集" class="glyphicon glyphicon-edit"></i>
								</a>
								<a href="#" class="btn btnDelete btn-round btn-default">
									<i title="削除" class="glyphicon glyphicon-trash"></i>
								</a>
							{/if}
								<a href="#" class="btn btnShowHide btn-round btn-default">
									<i title="最小化/最大化" class="glyphicon glyphicon-chevron-down"></i>
								</a>
						</div>
					</div>
					<div class="box-content">
						<div class="row">
							<div class="col-md-2">
								<p>音声</p>
							</div>
							<div class="col-md-10">
								{if $data.audio_type == 0}
								<div class="col-md-3">
									<p><label> {$data.audio_name} </label></p>
								</div>
								<div class="col-md-7">
									<p>
										<a class="btn btnPlay btn-default" audio_id="{$data.audio_id}">
											<i class="glyphicon glyphicon-play" ></i>
										</a>
										<a class="btn btnStop btn-default">
											<i class="glyphicon glyphicon-stop" ></i>
										</a>
									</p>
								</div>
								{else}
								<p>{$data.audio_content}</p>
								{/if}
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
		{/if}
		{/foreach}
	</div>
	<!-- セクションの追加のMODAL START-->
	<!-- 20160222 Edit by Giang : #6495 - Bug 132 - disable close popup add ques when upload wav file -->
	<div class="modal" id="dialog" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true" data-backdrop="static" data-keyboard="false">
		<div class="modal-dialog" style="width: 800px;">
			<div class="modal-content">
				<!-- Modal Header -->
				<div class="modal-header">
					<!-- 20160222 Edit by Giang : #6495 - Bug 132 - disable close popup add ques when upload wav file -->
					<button type="button" class="close btnClosePopupAddQues" data-dismiss="modal">
						   <span aria-hidden="true">&times;</span>
						   <span class="sr-only">Close</span>
					</button>
					<h4 class="modal-title" id="myModalLabel">
						セクションの追加
					</h4>
				</div>

				<!-- Modal Body -->
				<div class="modal-body" style="height:600px;">
					<form class="form-horizontal" role="form" id="form_add_call_list" method="post" action="{Router::url('', true)}" accept-charset="utf-8" enctype="multipart/form-data">
						<div class="alert alert-danger fade in" id="popupflash-error" style="display:none;">
							<button type="button" class="close">×</button>
						</div>
						<input type="text" name="id" value="" style="display: none;"/>
						<input type="text" name="question_no" value="" style="display: none;"/>
						<input type="hidden" id ="edit_flg">
						<div class="form-group">
							<div class="form-group">
								<label class="col-sm-2 control-label">種類</label>
								<div class="form-group col-sm-7">
									<select id="slQuesType" name="question_type" class="form-control">
									{foreach from=$ques_types item=ques_type}
										<option value="{$ques_type.M90PulldownCode.item_code}">{$ques_type.M90PulldownCode.item_name}</option>
									{/foreach}
								  	</select>
								</div>
							</div>
						</div>
						<div class="form-group">
							<div class="form-group">
								<label class="col-sm-2 control-label">タイトル</label>
								<div class="col-sm-7">
									<input type="text" maxlength="50" class="form-control" name="question_title" id="txtQuesTitle" placeholder="タイトル"/>
								</div>
							</div>
						</div>
						<div id="add_ques">
						{$view->element('template/add_ques')}
						</div>
					</form>
				</div>
				<!-- Modal Footer -->
				<div class="modal-footer">
					<!-- 20160222 Edit by Giang : #6495 - Bug 132 - disable close popup add ques when upload wav file -->
					<button type="button" class="btn btn-default btnClosePopupAddQues" data-dismiss="modal">閉じる</button>
					<button type="button" id="btnSubmitQues" class="btn btn-primary" ques_no="">保存</button>
				</div>
			</div>
		</div>
	</div>
	<!-- セクションの追加のMODAL END-->

<!-- content ends -->
</div>