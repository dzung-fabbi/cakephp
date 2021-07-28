# encoding: UTF-8
#=============================================================================
# Contents   : 結果ログ一括DLの全社指定機能追加
# Author     : Ascend Corp
# Since      : 2021/07/07        1.0
#=============================================================================

load File.join(File.dirname(__FILE__),'common.rb')
load File.join(File.dirname(__FILE__),'config.rb')

instance =  AscConfig.new
instance.instance_eval File.read File.join(File.dirname(__FILE__),'config.ini')
config = instance.getData
require "csv"
require "zip"
require 'fileutils'
############################################
#
# downloadOutbound
#
############################################
def downloadOutbound(mysql_cli, start_time, end_time, path_base, path_base_backup)
	# get heaader
	header_lists = ["発信元電話番号", "電話番号"]
	for i in 1..10
		str = "備考"
		header_lists = header_lists + Array.new(1, str.insert(str.length, i.to_s))
	end
	header_lists = header_lists + ["発信日時", "接続日時", "切断日時", "転送発信日時", "転送接続日時", "転送切断日時", "ステータス", "通話秒数", "転送秒数"]
	#backup
	prev_2_month = DateTime.now.prev_month(2)
	year_of_prev_2_month = prev_2_month.year
	moth_of_prev_2_month = prev_2_month.month
	if moth_of_prev_2_month < 10
		moth_of_prev_2_month = '0' + moth_of_prev_2_month.to_s
	end
	pre_2_month_file_zip_name = "アウトバウンド_" + year_of_prev_2_month.to_s + moth_of_prev_2_month.to_s + ".zip"
	FileUtils.cd(path_base) do
		if File.file?(pre_2_month_file_zip_name)
			FileUtils.move pre_2_month_file_zip_name, path_base_backup
		end
	end
	#Delele file
	prev_6_month = DateTime.now.prev_month(7)
	year_of_prev_6_month = prev_6_month.year
	month_of_prev_6_month = prev_6_month.month
	if month_of_prev_6_month < 10
		month_of_prev_6_month = '0' + month_of_prev_6_month.to_s
	end
	pre_6_month_file_zip_name = "アウトバウンド_" + year_of_prev_6_month.to_s + month_of_prev_6_month.to_s + ".zip"
	FileUtils.cd(path_base_backup) do
		if File.file?(pre_6_month_file_zip_name)
			File.delete(pre_6_month_file_zip_name)
		end
	end
	# get data
	company_ids = getCompanyId(mysql_cli)
	prev_month = DateTime.now.prev_month()
	year = prev_month.year
	month = prev_month.month
	if month < 10
		month = '0' + month.to_s
	end
	file_zip_name = "アウトバウンド_" + year.to_s + month.to_s + ".zip"
	non_date = '0000-00-00 00:00:00'
	path = path_base + file_zip_name
	file_list = []
	Zip::File.open(path, Zip::File::CREATE) do |zipfile|
		Zip.unicode_names = true
		for company_id in company_ids
			download_data_tmp = Array.new()
			schedules = getScheduleByCompanyAndTel(mysql_cli, company_id[0], start_time, end_time)
			for schedule in schedules
				schedule_id = schedule[0]
				tel_colum = getTelColumn(mysql_cli, schedule[2])
				tel_colum = tel_colum[0][0]
				logs = getAllByScheduleId(mysql_cli,schedule_id, false, tel_colum, start_time, end_time, true)
				for log in logs
					data = Array.new()
					data.push(schedule[1])
					data.push(log[3])
					for i in 1..11
						customize = "customize" + i.to_s
						if customize != tel_colum
							data.push(log[183 + i] ? log[183 + i] : '')
						end
					end
					data.push(log[7] == non_date ? '' : log[7])
					data.push(log[8] == non_date ? '' : log[8])
					data.push(log[9] == non_date ? '' : log[9])
					data.push(log[10] == non_date ? '' : log[10])
					trans_connect_datetime = log[11] == non_date ? '' : log[11]
					data.push(trans_connect_datetime)
					trans_cut_datetime = log[12] == non_date ? '' : log[12]
					data.push(trans_cut_datetime)
					if getCallResultConnectStatusArray().include?(log[13])
						if log[13] == "connect"
							data.push("ANSWER")
						elsif getCallResultConvertTFRejectArray().include?(log[13])
							data.push("TRANSFERREJECT")
						else
							data.push(log[13].upcase)
						end
						time_call = DateTime.parse(log[9]).to_time.to_i - DateTime.parse(log[8]).to_time.to_i
						data.push(time_call)
					else
						if log[13] == "reject"
							data.push("REJECT")
						elsif log[13] == "recover"
							data.push("SKIP")
						else
							data.push("NOANSWER")
						end
						data.push('')
					end
					trans_cut_datetime = trans_cut_datetime == '' ? 0 : DateTime.parse(log[12]).to_time.to_i
					trans_connect_datetime = trans_connect_datetime == '' ? 0 : DateTime.parse(log[11]).to_time.to_i
					count_second_trans = trans_cut_datetime - trans_connect_datetime
					data.push(count_second_trans > 0 ? count_second_trans : '')
					download_data_tmp.push(data)
				end
			end
			file_name = company_id[1].to_s + "_アウトバウンド_" + year.to_s + month.to_s + ".csv"
			file_path = path_base + file_name
			FileUtils.cd(path_base) do
				CSV.open(file_name, "w", encoding: "SJIS") do |csv|
					csv << header_lists
					download_data_tmp.each do |col|
						csv << col
					end
				end
				zipfile.add(file_name, file_path)
				file_list.push(file_path)
			end
		end
	end
	file_list.each do |file|
		File.delete(file)
	end
end
############################################
#
# downloadInbound
#
############################################
def downloadInbound(mysql_cli, start_time, end_time, path_base, path_base_backup)
	#get header
	header_lists = ["着信先電話番号", "電話番号"]
	for i in 1..10
		str = "備考";
		header_lists = header_lists + Array.new(1, str.insert(str.length, i.to_s))
	end
	header_lists = header_lists + ["着信日時", "接続日時", "切断日時", "転送発信日時", "転送接続日時", "転送切断日時", "ステータス", "通話秒数", "転送秒数"]
	#backup
	prev_2_month = DateTime.now.prev_month(2)
	year_of_prev_2_month = prev_2_month.year
	moth_of_prev_2_month = prev_2_month.month
	if moth_of_prev_2_month < 10
		moth_of_prev_2_month = '0' + moth_of_prev_2_month.to_s
	end
	pre_2_month_file_zip_name = "インバウンド_" + year_of_prev_2_month.to_s + moth_of_prev_2_month.to_s + ".zip"
	FileUtils.cd(path_base) do
		if File.file?(pre_2_month_file_zip_name)
			FileUtils.move pre_2_month_file_zip_name, path_base_backup
		end
	end
	#Delele file
	prev_6_month = DateTime.now.prev_month(7)
	year_of_prev_6_month = prev_6_month.year
	month_of_prev_6_month = prev_6_month.month
	if month_of_prev_6_month < 10
		month_of_prev_6_month = '0' + month_of_prev_6_month.to_s
	end
	pre_6_month_file_zip_name = "インバウンド_" + year_of_prev_6_month.to_s + month_of_prev_6_month.to_s + ".zip"
	FileUtils.cd(path_base) do
		if File.file?(pre_6_month_file_zip_name)
			File.delete(pre_6_month_file_zip_name)
		end
	end
	#get data
	company_ids = getCompanyId(mysql_cli)
	prev_month = DateTime.now.prev_month()
	year = prev_month.year
	month = prev_month.month
	if month < 10
		month = '0' + month.to_s
	end
	non_date = '0000-00-00 00:00:00'
	file_zip_name = "インバウンド_" + year.to_s + month.to_s + ".zip"
	path = path_base + file_zip_name
	file_list = []
	Zip::File.open(path, Zip::File::CREATE) do |zipfile|
		Zip.unicode_names = true
		for company_id in company_ids
			download_data_tmp = Array.new()
			inbounds = getInboundScheduleByCompanyAndTel(mysql_cli, company_id[0], start_time, end_time)
			for inbound in inbounds
				inbound_id = inbound[0]
				list_id = inbound[2]
				arr_answer_pos = getAnswerPos(mysql_cli, inbound_id)
				download_log_tmp_question_all_type = getT64QuesNumByScheduleId(mysql_cli, inbound_id)
				download_log_question_all_type = Array.new()
				for download_log_tmp in download_log_tmp_question_all_type
					download_log_question_all_type = download_log_question_all_type + Array.new(1, download_log_tmp[2])
				end
				answer_pos_auth_character = nil
				question_auth_char = 10
				question_temps = getT64InfoQuesAnswByScheduleId(mysql_cli, inbound_id, question_auth_char)
				for ques in question_temps
					ques_no = ques[1]
					if ques[6] == 1
						answer_pos_auth_character = arr_answer_pos[ques_no]
						break
					end
				end
				item_main_column = nil
				join_col = nil
				item_main_code = nil
				tel_column = ''
				if !(list_id.empty?)
					tel_colum = getInboundTelColumn(mysql_cli, list_id)
					tel_colum = tel_colum[0][0]
					list_item = getInboundInfoItemMain(mysql_cli, inbound_id, list_id)
					list_item = list_item[0]
					if !(list_item.nil?) && !(list_item.empty?)
						item_main_column = list_item[1]
						item_main_code = list_item[0]
					end
					if !(answer_pos_auth_character.blank?)
						join_col = 'answer' + answer_pos_auth_character.to_s
					elsif item_main_code == 'tel_no'
						join_col = 'tel_no'
					end
				end
				if !(download_log_question_all_type.include?("10")) && download_log_question_all_type.include?("17")
					tmp_item_main_column = getInboundTelColumn(mysql_cli, list_id)
					item_main_column = tmp_item_main_column[0][0]
				end
				if (download_log_question_all_type.include?("10") && download_log_question_all_type.include?("17")) || download_log_question_all_type.include?("17")
					join_col = 'memo'
					logs = getAllByScheduleIdInboundCollation(mysql_cli, inbound_id, item_main_column, join_col, start_time, end_time)
				else
					logs = getInboundAllByScheduleId(mysql_cli, inbound_id, item_main_column, join_col, start_time, end_time)
				end
				for log in logs
					data = Array.new()
					if log[13] != "recover"
						data.push(inbound[1])
						data.push(log[2].empty? ? "anonymous" : log[2])
						if (!(tel_colum.nil?) && !(tel_colum.empty?))
							for i in 1..11
								customize = "customize" + i.to_s
								if customize != tel_colum
									data.push(log[183 + i] ? log[183 + i] : '')
								end
							end
						else
							for i in 1..10
								data.push(log[183 + i] ? log[183 + i] : '')
							end
						end
						data.push(log[7] == non_date ? '' : log[7])
						data.push(log[8] == non_date ? '' : log[8])
						data.push(log[9] == non_date ? '' : log[9])
						data.push(log[10] == non_date ? '' : log[10])
						trans_connect_datetime = log[11] == non_date ? '' : log[11]
						data.push(trans_connect_datetime)
						trans_cut_datetime = log[12] == non_date ? '' : log[12]
						data.push(trans_cut_datetime)
						if getCallResultNoConvertArray().include?(log[13])
							data.push(log[13].upcase)
						elsif getCallResultConvertTFRejectArray().include?(log[13])
							data.push("TRANSFERREJECT")
						else
							data.push("ANSWER")
						end
						time_call = DateTime.parse(log[9]).to_time.to_i - DateTime.parse(log[8]).to_time.to_i
						data.push(time_call)
						trans_cut_datetime = trans_cut_datetime == '' ? 0 : DateTime.parse(log[12]).to_time.to_i
						trans_connect_datetime = trans_connect_datetime == '' ? 0 : DateTime.parse(log[11]).to_time.to_i
						count_second_trans = trans_cut_datetime - trans_connect_datetime
						data.push(count_second_trans > 0 ? count_second_trans : '')
						download_data_tmp.push(data)
					end
				end
			end
			file_name = company_id[1].to_s + "_インバウンド_" + year.to_s + month.to_s + ".csv"
			file_path = path_base + file_name
			FileUtils.cd(path_base) do
				CSV.open(file_name, "w", encoding: "SJIS") do |csv|
					csv << header_lists
					download_data_tmp.each do |col|
						csv << col
					end
				end
				zipfile.add(file_name, file_path)
				file_list.push(file_path)
			end
		end
	end
	file_list.each do |file|
		File.delete(file)
	end
end
############################################
#
# downloadSms
#
############################################
def downloadSms(mysql_cli, start_time, end_time, path_base, path_base_backup)
	#get header
	header_lists = ["送信日時", "通知番号", "電話番号"]
	for i in 1..10
		str = "備考";
		header_lists = header_lists + Array.new(1, str.insert(str.length, i.to_s))
	end
	header_lists = header_lists + ["送達状態", "送達警告情報", "短縮URLキー"]
	#backup
	prev_2_month = DateTime.now.prev_month(2)
	year_of_prev_2_month = prev_2_month.year
	moth_of_prev_2_month = prev_2_month.month
	if moth_of_prev_2_month < 10
		moth_of_prev_2_month = '0' + moth_of_prev_2_month.to_s
	end
	pre_2_month_file_zip_name = "SMS_" + year_of_prev_2_month.to_s + moth_of_prev_2_month.to_s + ".zip"
	FileUtils.cd(path_base_backup) do
		if File.file?(pre_2_month_file_zip_name)
			FileUtils.move pre_2_month_file_zip_name, path_base_backup
		end
	end
	#Delele file
	prev_6_month = DateTime.now.prev_month(7)
	year_of_prev_6_month = prev_6_month.year
	month_of_prev_6_month = prev_6_month.month
	if month_of_prev_6_month < 10
		month_of_prev_6_month = '0' + month_of_prev_6_month.to_s
	end
	pre_6_month_file_zip_name = "SMS_" + year_of_prev_6_month.to_s + month_of_prev_6_month.to_s + ".zip"
	FileUtils.cd(path_base_backup) do
		if File.file?(pre_6_month_file_zip_name)
			File.delete(pre_6_month_file_zip_name)
		end
	end
	#get data
	company_ids = getCompanyId(mysql_cli)
	prev_month = DateTime.now.prev_month()
	year = prev_month.year
	month = prev_month.month
	if month < 10
		month = '0' + month.to_s
	end
	file_zip_name = "SMS_" + year.to_s + month.to_s + ".zip"
	path = path_base + file_zip_name
	file_list = []
	Zip::File.open(path, Zip::File::CREATE) do |zipfile|
		Zip.unicode_names = true
		for company_id in company_ids
			download_data_tmp = Array.new()
			schedules = getSmsScheduleByCompanyAndTel(mysql_cli, company_id[0], start_time, end_time)
			for schedule in schedules
				schedule_id = schedule[0]
				tel_colum = getSmsTelColumn(mysql_cli, schedule[2])
				tel_colum = tel_colum[0][0]
				logs = getSmsAllByScheduleId(mysql_cli,schedule_id, tel_colum, start_time, end_time)
				for log in logs
					data = Array.new()
					data.push(schedule[3])
					data.push(schedule[1])
					data.push(log[2])
					for i in 1..11
						customize = "customize" + i.to_s
						if customize != tel_colum
							data.push(log[18 + i] ? log[18 + i] : '')
						end
					end
					if log[8].empty?
						data.push('')
					else
						case log[8]
						when "success"
							data.push("着信済み")
						when "unknown"
							data.push("不明")
						when "outside"
							data.push("圏外")
						when "history_judgement_ng"
							data.push("履歴判定NG")
						else
							data.push('')
						end
					end
					data.push(log[9].empty? ? '' : log[9])
					data.push(log[10].empty? ? '' : log[10])
					download_data_tmp.push(data)
				end
			end
			file_name = company_id[1].to_s + "_SMS_" + year.to_s + month.to_s + ".csv"
			file_path = path_base + file_name
			FileUtils.cd(path_base) do
				CSV.open(file_name, "w", encoding: "SJIS") do |csv|
					csv << header_lists
					download_data_tmp.each do |col|
						csv << col
					end
				end
				zipfile.add(file_name, file_path)
				file_list.push(file_path)
			end
		end
	end
	file_list.each do |file|
		File.delete(file)
	end
end

def getTelColumn(mysql_cli, list_id)
	query = <<EOS
	select
		t12.column
	from
		t12_list_items t12
	where
		t12.item_code = 'tel_no'
		and t12.list_id = #{list_id}
EOS
	data = Array.new()
	mysql_cli.query(query).each do | row |
		data = data + Array.new(1, row)
	end
	return data
end

def getInboundTelColumn(mysql_cli, list_id)
	query = <<EOS
	select
		t13.column
	from
		t13_inbound_list_items t13
	where
		t13.item_code = 'tel_no'
		and t13.list_id = #{list_id}
EOS
	data = Array.new()
	mysql_cli.query(query).each do | row |
		data = data + Array.new(1, row)
	end
	return data
end

def getSmsTelColumn(mysql_cli, list_id)
	query = <<EOS
	select
		t102.column
	from
		t102_sms_list_items t102
	where
		t102.item_code = 'tel_no'
		and t102.list_id = #{list_id}
EOS
	data = Array.new()
	mysql_cli.query(query).each do | row |
		data = data + Array.new(1, row)
	end
	return data
end

def getAllByScheduleId(mysql_cli,schedule_id, ans_only, tel_colum , start_time, end_time, valid_del_flag)
	query = <<EOS
	select
		t80.*,
		t51.*
	from
		t80_outgoing_results t80
			left join
		t51_tel_histories t51 on t51.schedule_id = t80.schedule_id
			and t51.del_flag = "N"
			and t51.#{tel_colum} = t80.tel_no
			and t51.schedule_id = #{schedule_id}
		where
			t80.schedule_id = #{schedule_id}
			and t80.del_flag = "N"
			and t80.call_datetime >= '#{start_time}'
			and t80.call_datetime <= '#{end_time}'
	order by
		t80.call_datetime asc
EOS
	data = Array.new()
	mysql_cli.query(query).each do | row |
		data = data + Array.new(1, row)
	end
	return data
end

def getInboundAllByScheduleId(mysql_cli, inbound_id, item_main_column, join_col, start_time, end_time)
	if item_main_column && join_col
		query = <<EOS
		select
			t81.*,
			t57.*
		from
			t81_incoming_results t81
				left join
			t57_inbound_tel_histories t57 on t57.inbound_id = t81.inbound_id
				and t57.del_flag = "N"
				and t57.#{item_main_column} = t81.#{join_col}
		where
			t81.inbound_id = #{inbound_id}
			and t81.del_flag = "N"
			and t81.call_datetime >= '#{start_time}'
			and t81.call_datetime <= '#{end_time}'
		order by
			t81.call_datetime asc
EOS
	else
		query = <<EOS
		select
			t81.*
		from
			t81_incoming_results t81
		where
			t81.inbound_id = #{inbound_id}
			and t81.call_datetime >= '#{start_time}'
			and t81.call_datetime <= '#{end_time}'
		order by
			t81.call_datetime asc
EOS
	end
	data = Array.new()
	mysql_cli.query(query).each do | row |
		data = data + Array.new(1, row)
	end
	return data
end

def getSmsAllByScheduleId(mysql_cli,schedule_id, tel_colum, start_time, end_time)
	query = <<EOS
	select
		t800.*,
		t501.*
	from
		t800_sms_send_results t800
			left join
		t501_sms_tel_histories t501 on t501.schedule_id = t800.schedule_id
			and t501.del_flag = "N"
			and t501.#{tel_colum} = t800.tel_no
			and t501.schedule_id = #{schedule_id}
	where
		t800.schedule_id = #{schedule_id}
		and t800.del_flag = "N"
		and t800.send_datetime >= '#{start_time}'
		and t800.send_datetime <= '#{end_time}'
	order by
		t800.send_datetime asc
EOS
	data = Array.new()
	mysql_cli.query(query).each do | row |
		data = data + Array.new(1, row)
	end
	return data
end

def getScheduleByCompanyAndTel(mysql_cli, company_id, start_time, end_time)
	query = <<EOS
	select
		t20.id,
		t20.external_number,
		t20.list_id
	from
		t20_out_schedules t20
			inner join
		t22_out_logs t22 on t22.schedule_id = t20.id
	where
		t20.company_id ='#{company_id}'
		and t22.time_start >= '#{start_time}'
		and t22.time_start <= '#{end_time}'
	group by
		t20.id
	order by
		t22.time_start
EOS
	data = Array.new()
	mysql_cli.query(query).each do | row |
		data = data + Array.new(1, row)
	end
	return data
end

def getInboundScheduleByCompanyAndTel(mysql_cli, company_id, start_time, end_time)
	query = <<EOS
	select
		t25.id,
		t25.external_number,
		t25.list_id
	from
		t25_inbounds t25
			inner join
		t81_incoming_results t81 on t81.inbound_id = t25.id
	where
		t25.company_id ='#{company_id}'
		and t81.call_datetime >= '#{start_time}'
		and t81.call_datetime <= '#{end_time}'
	group by
		t25.id
	order by
		t25.time_start
EOS
	data = Array.new()
	mysql_cli.query(query).each do | row |
		data = data + Array.new(1, row)
	end
	return data
end

def getSmsScheduleByCompanyAndTel(mysql_cli, company_id, start_time, end_time)
	query = <<EOS
	select
		t200.id,
		t200.display_number,
		t200.list_id,
		t202.time_start
	from
		t200_sms_send_schedules t200
			inner join
		t202_sms_send_logs t202 on t202.schedule_id = t200.id
	where
		t200.company_id ='#{company_id}'
		and t202.time_start >= '#{start_time}'
		and t202.time_start <= '#{end_time}'
	group by
		t200.id
	order by
		t202.time_start
EOS
	data = Array.new()
	mysql_cli.query(query).each do | row |
		data = data + Array.new(1, row)
	end
	return data
end

def getCompanyId(mysql_cli)
	query = <<EOS
	select
		m02.company_id,
		m02.company_name
	from
		m02_companies m02
	where
		m02.del_flag = "N"
EOS
	data = Array.new()
	mysql_cli.query(query).each do | row |
		data = data + Array.new(1, row)
	end
	return data
end

def getCallResultConnectStatusArray()
	work_array = ["connect","transfer", "transferfull", "transfertimeout", "transferreject", "transfercancel", "transferdisconnect"]
	return work_array
end

def getCallResultConvertTFRejectArray()
	return ["transfercancel", "transferdisconnect"]
end

def getAnswerPos(mysql_cli, inbound_id)
	arr_answer_pos = Array.new()
	current_pos = 1
	arr_count_column = Hash["1" => 0, "2" => 1, "3" => { "0" => 1, "1" => 4}, "4" => {"0" => 1, "1" => 2}, "5" => 0, "6" => 0, "7" => 1, "8" => 0, "9" => 0, "10" => {"0" => 1, "1" => 3}]
	question_numbers = getT64QuesNumByScheduleId(mysql_cli, inbound_id)
	for question_number in question_numbers
		question_no = question_number[1]
		question_type = question_number[2]
		arr_ques_auth_tel = ['3', '4', '10']
		if arr_ques_auth_tel.include?(question_type)
			count_column = "#{arr_count_column[question_type.to_s][(question_number[3]).to_s]}"
		else
			count_column = "#{arr_count_column[question_type.to_s]}"
		end
		if count_column.to_i > 0
			arr_answer_pos[question_no.to_i] = arr_answer_pos + Array.new(1, current_pos)
		elsif question_type == '5'
			arr_answer_pos[question_no.to_i] = arr_answer_pos + Array.new(1, 'trans_call_time')
		else
			arr_answer_pos[question_no.to_i] = arr_answer_pos + Array.new(1, nil)
		end
	end
	return arr_answer_pos
end

def getQuesNumByScheduleId(mysql_cli, inbound_id)
	query = <<EOS
	select
		t64.question_title,
		t64.question_no,
		t64.question_type,
		t64.recheck_flag,
		t64.recheck_button_next,
		t64.auth_item,
		t64.auth_match_flag
	from
		t64_inbound_question_histories t64
	where
		t64.inbound_id = #{inbound_id}
		and t64.del_flag = "N"
	group by
		t64.question_no
	order by
		cast(t64.question_no as UNSIGNED) asc
EOS
	data = Array.new()
	mysql_cli.query(query).each do | row |
		data = data + Array.new(1, row)
	end
	return data
end

def getT64QuesNumByScheduleId(mysql_cli, inbound_id)
	query = <<EOS
	select
		t64.question_title,
		t64.question_no,
		t64.question_type,
		t64.recheck_flag,
		t64.recheck_button_next,
		t64.auth_item,
		t64.auth_match_flag
	from
		t64_inbound_question_histories t64
	where
		t64.inbound_id = #{inbound_id}
		and t64.del_flag = "N"
		and t64.question_type in (2, 3, 4, 5, 6, 7, 10, 11, 12, 14, 16, 17, 18)
	group by
		t64.question_no
	order by
		cast(t64.question_no as UNSIGNED) asc
EOS
	data = Array.new()
	mysql_cli.query(query).each do | row |
		data = data + Array.new(1, row)
	end
	return data
end

def getT64InfoQuesAnswByScheduleId(mysql_cli, inbound_id, question_auth_char)
	query = <<EOS
	select
		t64.id,
		t64.question_no,
		t64.question_yuko,
		t64.question_type,
		t64.question_title,
		t64.auth_item,
		t64.auth_match_flag,
		t64.recheck_flag,
		t64.recheck_button_next,
		t64.recheck_button_prev,
		t65.id,
		t65.question_no,
		t65.answer_no,
		t65.answer_content
	from
		t64_inbound_question_histories t64
			left join
		t65_inbound_button_histories t65 on t64.inbound_id = t65.inbound_id
			and t64.question_no = t65.question_no
			and t65.del_flag = "N"
	where
		t64.inbound_id = #{inbound_id}
		and t64.del_flag = "N"
		and t64.question_type = #{question_auth_char}
	order by
		t64.question_no, t65.answer_no asc
EOS
	data = Array.new()
	mysql_cli.query(query).each do | row |
		data = data + Array.new(1, row)
	end
	return data
end

def getInboundInfoItemMain(mysql_cli, inbound_id, list_id)
	query = <<EOS
	select
		t13.item_code,
		t13.column
	from
		t56_inbound_list_histories t56
			inner join
		t13_inbound_list_items t13 on t13.list_id = t56.list_id
			and t13.item_name = t56.item_main
			and t13.list_id = #{list_id}
			and t13.del_flag = "N"
			and t56.del_flag = "N"
	where
		t56.inbound_id = #{inbound_id}
EOS
	data = Array.new()
	mysql_cli.query(query).each do | row |
		data = data + Array.new(1, row)
	end
	return data
end

def getAllByScheduleIdInboundCollation(mysql_cli, inbound_id, item_main_column, join_col, start_time, end_time)
	if item_main_column && join_col
		query = <<EOS
		select
			t81.*,
			t57.*
		from
			t81_incoming_results t81
				left join
			t57_inbound_tel_histories t57 on t57.inbound_id = t81.inbound_id
				and t57.#{item_main_column} = SUBSTRING_INDEX(t81.#{join_col}, ':', 1)
				and t57.del_flag = "N"
		where
			t81.inbound_id = #{inbound_id}
			and t81.call_datetime >= '#{start_time}'
			and t81.call_datetime <= '#{end_time}'
		order by
			t81.call_datetime asc
EOS
	else
		query = <<EOS
		select
			t81.*
		from
			t81_incoming_results t81
		where
			t81.inbound_id = #{inbound_id}
			and t81.call_datetime >= '#{start_time}'
			and t81.call_datetime <= '#{end_time}'
		order by
			t81.call_datetime asc
EOS
	end
	data = Array.new()
	mysql_cli.query(query).each do | row |
		data = data + Array.new(1, row)
	end
	return data
end

def getCallResultNoConvertArray()
	return ["transfer", "transferfull", "transfertimeout", "transferreject"]
end


#######################################################
begin
	#DB接続情報
	db_ip = config[:database_ip]
	db_id = config[:database_id]
	db_pass = config[:database_pass]
	db_schema = config[:database_schema]

	mysql_cli=Mysql.connect(db_ip, db_id, db_pass, db_schema)
	mysql_cli.charset="utf8"
	prev_month = DateTime.now.prev_month(2)
	start_time = prev_month.strftime("%Y-%m-01 00:00:00")
	end_time = Date.civil(prev_month.year, prev_month.month, -1).strftime("%Y-%m-%d 23:59:59")
	path_base = '/home/robo/var/bulk_history/'
	path_base_backup = '/home/robo/var/bulk_history/backup/'
	downloadOutbound(mysql_cli, start_time, end_time, path_base, path_base_backup)
	downloadInbound(mysql_cli, start_time, end_time, path_base, path_base_backup)
	downloadSms(mysql_cli, start_time, end_time, path_base, path_base_backup)
	mysql_cli.close()
rescue Exception => e
	puts "err_download_history_bulk"
	writeLog("err_download_history_bulk : " + e.message)
	writeLog(e.backtrace.join("\n"))
	sendMailError("")
	exit 9
end