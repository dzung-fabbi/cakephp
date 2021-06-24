{html func=script url='pager'}
{html func=script url='view/inboundtemplate/template'}
{html func=script url='view/inboundtemplate/add_ques'}
{html func=script url='view/inboundtemplate/validate'}
{html func=css path='inboundtemplate/index'}
<script type="text/javascript">
	glb_arr_ques = {if $jsObjectkey}{$jsObjectkey}{else}{'new Object()'}{/if};
</script>
<div id="audio-player" style="display: none;">
	<audio controls class="audio_plugin" src="" type="audio/x-wav"></audio>
</div>
<div class="col-lg-10 col-sm-10" id="content">
	<!-- content starts -->
	{if $exist_setting_inbound && $post_code != "U30" && $post_code != "G30"}
		<div class="alert alert-danger fade in"><button type="button" class="close">×</button>着信設定されているテンプレートの為編集できません。</div>
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
					<input type="text" class="form-control input-sm" maxlength="50" id="txtTemplateName" value="{if isset($template_name) && !empty($template_name) && $action eq 'update'}{$template_name}{/if}" name="data[T30Template][template_name]" placeholder="テンプレート名" {if !$permission_flag || $exist_setting_inbound}disabled{/if}/>
				</div>
			</div>
			<div class="form-group col-xs-12 col-sm-6 col-lg-4">
				<label for="txtTemplateDescription" class="col-xs-5">説明</label>
				<div class="col-xs-7">
					<input type="text" class="form-control input-sm"　maxlength="200" id="txtTemplateDescription" value="{if isset($description) && !empty($description)}{$description}{/if}" name="data[T30Template][description]" placeholder="説明" {if !$permission_flag || $exist_setting_inbound}disabled{/if}/>
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
			{if $permission_flag && !$exist_setting_inbound}
				<a href="#" title="セクションの追加" id="btnAddQues" data-toggle="tooltip" class="btn btn-primary col-xs-5">セクションの追加</a>
				{if $action eq "insert" || $action eq "duplicate"}
					<a href="#" title="保存"" id="btnSubmit" data-toggle="tooltip" class="btn btn-primary col-xs-5 col-xs-offset-1">保存</a>
				{elseif $action eq "update"}
					<a href="#" title="更新"" id="btnSubmit" data-toggle="tooltip" class="btn btn-primary col-xs-5 col-xs-offset-1">更新</a>
				{/if}
			{/if}
		</div>
	</div>

	<div class="inbound_collation">
		{foreach from=$ques_info key=ques_no item=data}
			{if $data.question_type eq '17'}
				<div class="row row_question">
					<div class="box col-md-12">
						<div class="box-inner">
							<div class="box-header well" data-original-title="">
								<h2><span class="ques_no">{$ques_no}</span>. <span class="ques_type_txt">{$data.question_type_txt}</span></h2>
								<span class="ques_title">&nbsp;&nbsp;&nbsp;&nbsp;{$data.question_title}</span>
								<div class="box-icon">
									{if $permission_flag && !$exist_setting_inbound}
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
										<p>認証項目</p>
									</div>
									<div class="col-md-10">
										電話番号<b>（固定）</b>
									</div>
								</div>
								<div class="row">
									<div class="col-md-2">
										<p>桁数</p>
									</div>
									<div class="col-md-10">
										<b>10 or 11（固定）</b>
									</div>
								</div>
								<div class="row">
									<div class="col-md-8">
										<table class="table table-bordered table-striped table-condensed">
											<thead>
											<tr>
												<th class="alignCenter" style="width:240px;min-width:240px;">結果</th>
												<th class="alignCenter col-md-3">飛び先</th>
											</tr>
											</thead>
											{assign var=answer_titles value=[0=>'通知番号 ＝ 認証項目', 1=>'通知番号 ≠ 認証項目']}
											<tbody>
												{foreach from=$answer_titles key=key item=answer_title}
													<tr>
														<td class="alignCenter">{$answer_title}</td>
														<td class="alignCenter select_jump_ques_container" jump_question="{$arr_answ.$ques_no[$key].T32TemplateButton.jump_question}" ans_no="{$arr_answ.$ques_no[$key].T32TemplateButton.answer_no}"></td>
												</tr>
												{/foreach}
											</tbody>
										</table>
									</div>
								</div>
							</div>
						</div>
					</div>
				</div>
			{/if}
		{/foreach}
	</div>

	{* テンプレート詳細画面、質問毎に画面を作成する *}
	<div class="template">
		{foreach from=$ques_info key=ques_no item=data}
			{if $data.question_type neq '9' && $data.question_type neq '17'}
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
									{if $permission_flag && !$exist_setting_inbound}
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
									{if $permission_flag && !$exist_setting_inbound}
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
							{elseif ($data.question_type == 3|| $data.question_type == 10)}<!-- 数値認証 or 文字列認証 -->
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
								{if ($data.question_type == 10)}
									<div class="row">
										<div class="col-md-2">
											<p>着信リスト照合</p>
										</div>
										<div class="col-md-10">
											{if $data.auth_match_flag == 0}
												<p>なし</p>
											{else}
												<p>あり</p>
											{/if}
										</div>
									</div>
								{/if}
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
											{else}
												{$data.recheck_button_next}
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
											{else}
												{$data.recheck_button_next}
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
<!-- 								<div class="row"> -->
<!-- 									<div class="col-md-2"><p>空き席数無し時<br>発信停止</p></div> -->
<!-- 									<div class="col-md-10"> -->
<!-- 										{if $data.trans_empty_seat_flag == 0} -->
<!-- 											なし -->
<!-- 										{else} -->
<!-- 											あり -->
<!-- 										{/if} -->
<!-- 									</div> -->
<!-- 								</div> -->
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
							{elseif $data.question_type == 11}<!-- 物件番号入力 -->
							<div class="box-content">
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
									<div class="col-md-10">{$data.digit_prop}</div>
								</div>

								<div class="row">
									<div class="col-md-2"><p>物件名確認音声</p></div>
									<div class="col-md-10">
										{if $data.bukken_audio_type == 0}
											<div class="col-md-3">
												<p><label> {$data.bukken_audio_name} </label></p>
											</div>
											<div class="col-md-7">
												<p>
													<a class="btn btnPlay btn-default" audio_id="{$data.bukken_audio_id}">
														<i class="glyphicon glyphicon-play" ></i>
													</a>
													<a class="btn btnStop btn-default">
														<i class="glyphicon glyphicon-stop" ></i>
													</a>
												</p>
											</div>
										{else}
											<p>{$data.bukken_audio_content}</p>
										{/if}
									</div>
								</div>
								<div class="row">
									<div class="col-md-8">
										<p>回答</p>
										<table class="table table-bordered table-striped table-condensed">
											<thead>
											<tr>
												<th class="alignCenter templateTable-40">説明</th>
												<th class="alignCenter templateTable-140">番号</th>
												</tr>
											</thead>
											<tbody>
											<tr>
												<td>物件名が正しい場合</td>
												<td class="alignCenter">{if $data.bukken_answer_no == '51'}*
													{elseif $data.bukken_answer_no == '52'}#
													{else}{$data.bukken_answer_no}
													{/if}</td>
												</tr>
											<tr>
												<td>物件名を訂正する場合</td>
												<td class="alignCenter">その他</td>
												</tr>
											</tbody>
										</table>
									</div>
								</div>

								<div class="row">
									<div class="col-md-2"><p>図面希望音声</p></div>
									<div class="col-md-10">
										{if $data.bukken_diagram_audio_type == 0}
											<div class="col-md-3">
												<p><label> {$data.bukken_diagram_audio_name} </label></p>
											</div>
											<div class="col-md-7">
												<p>
													<a class="btn btnPlay btn-default" audio_id="{$data.bukken_diagram_audio_id}">
														<i class="glyphicon glyphicon-play" ></i>
													</a>
													<a class="btn btnStop btn-default">
														<i class="glyphicon glyphicon-stop" ></i>
													</a>
												</p>
											</div>
										{else}
											<p>{$data.bukken_diagram_audio_content}</p>
										{/if}
									</div>
								</div>
								<div class="row">
									<div class="col-md-8">
										<p>回答</p>
										<table class="table table-bordered table-striped table-condensed">
											<thead>
											<tr>
												<th class="alignCenter templateTable-40">説明</th>
												<th class="alignCenter templateTable-140">番号</th>
												</tr>
											</thead>
											<tbody>
											<tr>
												<td>図面を希望する場合</td>
												<td class="alignCenter">{if $data.bukken_diagram_answer_no == 51}*
													{elseif $data.bukken_diagram_answer_no == 52}#
													{else}{$data.bukken_diagram_answer_no}
													{/if}</td>
												</tr>
											<tr>
												<td>図面を希望しない場合</td>
												<td class="alignCenter">その他</td>
												</tr>
											</tbody>
										</table>
									</div>
								</div>

								<div class="row">
									<div class="col-md-2"><p>継続確認音声</p></div>
									<div class="col-md-10">
										{if $data.bukken_cont_audio_type == 0}
											<div class="col-md-3">
												<p><label> {$data.bukken_cont_audio_name} </label></p>
											</div>
											<div class="col-md-7">
												<p>
													<a class="btn btnPlay btn-default" audio_id="{$data.bukken_cont_audio_id}">
														<i class="glyphicon glyphicon-play" ></i>
													</a>
													<a class="btn btnStop btn-default">
														<i class="glyphicon glyphicon-stop" ></i>
													</a>
												</p>
											</div>
										{else}
											<p>{$data.bukken_cont_audio_content}</p>
										{/if}
									</div>
								</div>
								<div class="row">
									<div class="col-md-8">
										<p>回答</p>
										<table class="table table-bordered table-striped table-condensed">
											<thead>
											<tr>
												<th class="alignCenter templateTable-40">説明</th>
												<th class="alignCenter templateTable-140">番号</th>
												<th class="alignCenter col-md-3">飛び先</th>
												</tr>
											</thead>
											<tbody>
												<tr>
													{foreach from=$arr_answ.$ques_no key=ques_no_tmp item=answ}
														{if $answ.T32TemplateButton.answer_no != 99}
															{$answer_no = $answ.T32TemplateButton.answer_no}
															{if $answer_no == 51}
																{$answer_no = '*'}
															{elseif $answer_no == 52}
																{$answer_no = '#'}
															{/if}
															{$answer_content = $answ.T32TemplateButton.answer_content}
															{$jump_ques = $answ.T32TemplateButton.jump_question}
														{/if}
													{/foreach}
													<td>確認を続ける</td>
													<td class="alignCenter">{$answer_no}</td>
													<td class="alignCenter select_jump_ques_container" jump_question="{$jump_ques}" ans_no="0"></td>
												</tr>
												<tr>
													<td>確認を続けない</td>
													<td class="alignCenter">その他</td>
													<td class="alignCenter select_jump_ques_container" jump_question="{$data.jump_question}"></td>
												</tr>
												<tr class="fixHeight" style='height:50px;'></tr>
												<tr>
													<td colspan="2">共通タイムアウト設定</td>
													{$jump_ques = ''}
													{foreach from=$arr_answ.$ques_no key=ques_no_tmp item=answ}
														{if $answ.T32TemplateButton.answer_no == 99}
															{$jump_ques = $answ.T32TemplateButton.jump_question}
														{/if}
													{/foreach}
													<td class="alignCenter select_jump_ques_container" jump_question="{$jump_ques}" ans_no="99"></td>
												</tr>
											</tbody>
										</table>
									</div>
								</div>
							</div>
							{elseif $data.question_type == 12}<!-- FAX番号入力 -->
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
									<div class="col-md-2"><p>桁数</p></div>
									<div class="col-md-10">{$data.digit_tel}</div>
								</div>
								{if $data.recheck_flag == 1}
									<div class="row">
										<div class="col-md-2">
											<p>確認音声</p>
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
								{/if}
							</div>
							{* セグメントの値は、DBから取得した値を利用する。 *}
							{* ※セグメント編集時や追加時は下記Javascriptにて作成するので注意！ *}
							{* inboundtemplate\add_ques.js　の　function htmlQuesPropertySearch　を経由して描画する。 *}
							{elseif $data.question_type == 14}<!-- 物件番号入力 -->
							<div class="box-content">
								<div class="row">
									<div class="col-md-2"><p>賃料音声</p></div>
									<div class="col-md-10">
										{if $data.ques_property_cost_audio_type == 0}
											<div class="col-md-3">
												<p><label> {$data.ques_property_cost_audio_name} </label></p>
											</div>
											<div class="col-md-7">
												<p>
													<a class="btn btnPlay btn-default" audio_id="{$data.ques_property_cost_audio_id}">
														<i class="glyphicon glyphicon-play" ></i>
													</a>
													<a class="btn btnStop btn-default">
														<i class="glyphicon glyphicon-stop" ></i>
													</a>
												</p>
											</div>
										{else}
											<p>{$data.ques_property_cost_audio_content}</p>
										{/if}
									</div>
								</div>
								<div class="row">
									<div class="col-md-2"><p>桁数</p></div>
									<div class="col-md-10">{$data.ques_property_cost_digit}</div>
								</div>

                                <div class="row">
                                    <div class="col-md-2"><p>平米音声</p></div>
                                    <div class="col-md-10">
                                        {if $data.ques_property_square_audio_type == 0}
                                            <div class="col-md-3">
                                                <p><label> {$data.ques_property_square_audio_name} </label></p>
                                            </div>
                                            <div class="col-md-7">
                                                <p>
                                                    <a class="btn btnPlay btn-default" audio_id="{$data.ques_property_square_audio_id}">
                                                        <i class="glyphicon glyphicon-play" ></i>
                                                    </a>
                                                    <a class="btn btnStop btn-default">
                                                        <i class="glyphicon glyphicon-stop" ></i>
                                                    </a>
                                                </p>
                                            </div>
                                        {else}
                                            <p>{$data.ques_property_square_audio_content}</p>
                                        {/if}
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-2"><p>桁数</p></div>
                                    <div class="col-md-10">{$data.ques_property_square_digit}</div>
                                </div>

                                <div class="row">
                                    <div class="col-md-2"><p>物件名確認音声</p></div>
                                    <div class="col-md-10">
                                        {if $data.ques_property_confirm_audio_type == 0}
                                            <div class="col-md-3">
                                                <p><label> {$data.ques_property_confirm_audio_name} </label></p>
                                            </div>
                                            <div class="col-md-7">
                                                <p>
                                                    <a class="btn btnPlay btn-default" audio_id="{$data.ques_property_confirm_audio_id}">
                                                        <i class="glyphicon glyphicon-play" ></i>
                                                    </a>
                                                    <a class="btn btnStop btn-default">
                                                        <i class="glyphicon glyphicon-stop" ></i>
                                                    </a>
                                                </p>
                                            </div>
                                        {else}
                                            <p>{$data.ques_property_confirm_audio_content}</p>
                                        {/if}
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-8">
                                        <p>回答</p>
                                        <table class="table table-bordered table-striped table-condensed">
                                            <thead>
                                            <tr>
                                                <th class="alignCenter templateTable-40">説明</th>
                                                <th class="alignCenter templateTable-140">番号</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                            <tr>
                                                <td>物件名が正しい場合</td>
                                                <td class="alignCenter">{if $data.ques_property_confirm_answer_no == '51'}*
                                                    {elseif $data.ques_property_confirm_answer_no == '52'}#
                                                    {else}{$data.ques_property_confirm_answer_no}
                                                    {/if}</td>
                                                </tr>
                                            <tr>
                                                <td>物件名を訂正する場合</td>
                                                <td class="alignCenter">その他</td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>



                                <div class="row">
                                    <div class="col-md-2"><p>継続確認音声</p></div>
                                    <div class="col-md-10">
                                        {if $data.ques_property_continue_audio_type == 0}
                                            <div class="col-md-3">
                                                <p><label> {$data.ques_property_continue_audio_name} </label></p>
                                            </div>
                                            <div class="col-md-7">
                                                <p>
                                                    <a class="btn btnPlay btn-default" audio_id="{$data.ques_property_continue_audio_id}">
                                                        <i class="glyphicon glyphicon-play" ></i>
                                                    </a>
                                                    <a class="btn btnStop btn-default">
                                                        <i class="glyphicon glyphicon-stop" ></i>
                                                    </a>
                                                </p>
                                            </div>
                                        {else}
                                            <p>{$data.ques_property_continue_audio_content}</p>
                                        {/if}
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-8">
                                        <p>回答</p>
                                        <table class="table table-bordered table-striped table-condensed">
                                            <thead>
                                            <tr>
                                                <th class="alignCenter templateTable-40">説明</th>
                                                <th class="alignCenter templateTable-140">番号</th>
                                                <th class="alignCenter col-md-3">飛び先</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <tr>
                                                    {foreach from=$arr_answ.$ques_no key=ques_no_tmp item=answ}
                                                        {if $answ.T32TemplateButton.answer_no != 99}
                                                            {$answer_no = $answ.T32TemplateButton.answer_no}
                                                            {if $answer_no == 51}
                                                                {$answer_no = '*'}
                                                            {elseif $answer_no == 52}
                                                                {$answer_no = '#'}
                                                            {/if}
                                                            {$answer_content = $answ.T32TemplateButton.answer_content}
                                                            {$jump_ques = $answ.T32TemplateButton.jump_question}
                                                        {/if}
                                                    {/foreach}
                                                    <td>確認を続ける</td>
                                                    <td class="alignCenter">{$answer_no}</td>
                                                    <td class="alignCenter select_jump_ques_container" jump_question="{$jump_ques}" ans_no="0"></td>
                                                </tr>
                                                <tr>
                                                    <td>確認を続けない</td>
                                                    <td class="alignCenter">その他</td>
                                                    <td class="alignCenter select_jump_ques_container" jump_question="{$data.jump_question}"></td>
                                                </tr>
                                                <tr class="fixHeight" style='height:50px;'></tr>
                                                <tr>
                                                    <td colspan="2">共通タイムアウト設定</td>
                                                    {$jump_ques = ''}
                                                    {foreach from=$arr_answ.$ques_no key=ques_no_tmp item=answ}
                                                        {if $answ.T32TemplateButton.answer_no == 99}
                                                            {$jump_ques = $answ.T32TemplateButton.jump_question}
                                                        {/if}
                                                    {/foreach}
                                                    <td class="alignCenter select_jump_ques_container" jump_question="{$jump_ques}" ans_no="99"></td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>


							</div>
							{* ここまで*}
							{elseif $data.question_type == 16}
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
										{if (isset($arr_answ.$ques_no[0]))}
											<div class="col-md-2 select_jump_ques_container" jump_question="{$arr_answ.$ques_no[0].T32TemplateButton.jump_question}" ans_no="{$arr_answ.$ques_no[0].T32TemplateButton.answer_no}"></div>
										{else}
											<div class="col-md-2 select_jump_ques_container" jump_question="" ans_no="99"></div>
										{/if}
									</div>
									<div class="row">
										<div class="col-md-2"><p>通知番号</p></div>
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
											{if $data.ques_inbound_sms_audio_type == 0}
												<div class="col-md-3">
													<p><label> {$data.ques_sms_inbound_audio_name} </label></p>
												</div>
												<div class="col-md-7">
													<p>
														<a class="btn btnPlay btn-default" audio_id="{$data.ques_sms_inbound_audio_id}">
															<i class="glyphicon glyphicon-play" ></i>
														</a>
														<a class="btn btnStop btn-default">
															<i class="glyphicon glyphicon-stop" ></i>
														</a>
													</p>
												</div>
											{else}
												<p>{$data.ques_inbound_sms_audio_content}</p>
											{/if}
										</div>
									</div>
								</div>
							{* ここまで*}
							{elseif $data.question_type == 18}<!-- 番号指定SMS -->
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
											{if $data.ques_inbound_sms_input_audio_type == 0}
												<div class="col-md-3">
													<p><label> {$data.ques_sms_input_inbound_audio_name} </label></p>
												</div>
												<div class="col-md-7">
													<p>
														<a class="btn btnPlay btn-default" audio_id="{$data.ques_sms_input_inbound_audio_id}">
															<i class="glyphicon glyphicon-play" ></i>
														</a>
														<a class="btn btnStop btn-default">
															<i class="glyphicon glyphicon-stop" ></i>
														</a>
													</p>
												</div>
											{else}
												<p>{$data.ques_inbound_sms_input_audio_content}</p>
											{/if}
										</div>
									</div>
								</div>
							{/if}
							{* ここまで*}
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
									{if $permission_flag && !$exist_setting_inbound}
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
							{$view->element('inboundtemplate/add_ques')}
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