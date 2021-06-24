<div id="pager" class="pager textDefault">
	{html func='image' path='common/pager/first.png' class="first" alt="最初" border="0"}
	{html func='image' path='common/pager/prev.png' class="prev" alt="前" border="0"}
	<span class="pagedisplay"></span> <!-- this can be any element, including an input -->
	{html func='image' path='common/pager/next.png' class="next" alt="次" border="0"}
	{html func='image' path='common/pager/last.png' class="last" alt="最後" border="0"}
	<div style="display:none">
		<select id="pagesize" class=".pagesize" title="テーブルサイズ選択">
			<option value="5">5</option>
		</select>
	</div>
	<select class="gotoPage" style="padding: 2px 4px; " title="ページ番号選択"></select>　ページ
</div>