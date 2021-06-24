# encoding: UTF-8
#=============================================================================
# Contents   : Set del_flag for result
# Author     : Ascend Corp
# Since      : 2021/03/04        1.0
#=============================================================================
load File.join(File.dirname(__FILE__),'common.rb')
load File.join(File.dirname(__FILE__),'config.rb')

instance =  AscConfig.new
instance.instance_eval File.read File.join(File.dirname(__FILE__),'config.ini')
config = instance.getData
############################################
#
# DBのT80
#
############################################
def updateT80(mysql_cli, start_time, end_time, time_update)
	query = <<-EOS
		UPDATE
			t80_outgoing_results AS t80
			INNER JOIN t20_out_schedules AS t20
				ON t80.schedule_id = t20.id
			INNER JOIN t50_list_histories AS t50
				ON t20.id = t50.schedule_id
				AND t20.list_id = t50.list_id
				AND t50.list_test_flag = '1'
			INNER JOIN m05_users AS m05
				ON t20.entry_user = m05.user_id
				AND m05.entry_user = 'exclude_user'
			INNER JOIN m11_exclusion_tel_numbers AS m11
				ON t80.tel_no = m11.tel_no
		SET
			t80.del_flag = 'Y',
			t80.modified = '#{time_update}',
			t80.update_program = 'Delete test number record'
		WHERE
			t80.del_flag = 'N'
			AND t80.call_datetime BETWEEN '#{start_time}' AND '#{end_time}'
	EOS
	mysql_cli.query(query)
end
############################################
#
# DBのT80
#
############################################
def getRemainT80(mysql_cli, start_time, end_time)
	query = <<-EOS
		SELECT
			t80.id
		FROM
			t80_outgoing_results AS t80
			INNER JOIN m11_exclusion_tel_numbers AS m11
				ON t80.tel_no = m11.tel_no
		WHERE
			t80.del_flag = 'N'
			AND t80.call_datetime BETWEEN '#{start_time}' AND '#{end_time}'
	EOS
	data = Array.new()
	mysql_cli.query(query).each do | row |
		data = data + Array.new(1, row)
	end
	return data
end
############################################
#
# DBのT81
#
############################################
def updateT81(mysql_cli, start_time, end_time, time_update)
	query = <<-EOS
		UPDATE
			t81_incoming_results AS t81
			INNER JOIN t25_inbounds AS t25
				ON t81.inbound_id = t25.id
			INNER JOIN m05_users AS m05
				ON t25.entry_user = m05.user_id
				AND m05.entry_user = 'exclude_user'
			INNER JOIN m11_exclusion_tel_numbers AS m11
				ON t81.tel_no = m11.tel_no
		SET
			t81.del_flag = 'Y',
			t81.modified = '#{time_update}',
			t81.update_program = 'Delete test number record'
		WHERE
			t81.del_flag = 'N'
			AND t81.call_datetime BETWEEN '#{start_time}' AND '#{end_time}'
	EOS
	mysql_cli.query(query)
end
############################################
#
# DBのT81
#
############################################
def getRemainT81(mysql_cli, start_time, end_time)
	query = <<-EOS
		SELECT
			t81.id
		FROM
			t81_incoming_results AS t81
			INNER JOIN m11_exclusion_tel_numbers AS m11
				ON t81.tel_no = m11.tel_no
		WHERE
			t81.del_flag = 'N'
			AND t81.call_datetime BETWEEN '#{start_time}' AND '#{end_time}'
	EOS
	data = Array.new()
	mysql_cli.query(query).each do | row |
		data = data + Array.new(1, row)
	end
	return data
end
############################################
#
# DBのT800
#
############################################
def updateT800(mysql_cli, start_time, end_time, time_update)
	query = <<-EOS
		UPDATE
			t800_sms_send_results AS t800
			INNER JOIN t200_sms_send_schedules AS t200
				ON t800.schedule_id = t200.id
			INNER JOIN t500_sms_list_histories AS t500
				ON t200.id = t500.schedule_id
				AND t200.list_id = t500.list_id
				AND t500.list_test_flag = '1'
			INNER JOIN m05_users AS m05
				ON t200.entry_user = m05.user_id
				AND m05.entry_user = 'exclude_user'
			INNER JOIN m11_exclusion_tel_numbers AS m11
				ON t800.tel_no = m11.tel_no
		SET
			t800.del_flag = 'Y',
			t800.modified = '#{time_update}',
			t800.update_program = 'Delete test number record'
		WHERE
			t800.del_flag = 'N'
			AND t800.send_datetime BETWEEN '#{start_time}' AND '#{end_time}'
	EOS
	mysql_cli.query(query)
end
############################################
#
# DBのT800
#
############################################
def getRemainT800(mysql_cli, start_time, end_time)
	query = <<-EOS
		SELECT
			t800.id
		FROM
			t800_sms_send_results AS t800
			INNER JOIN m11_exclusion_tel_numbers AS m11
				ON t800.tel_no = m11.tel_no
		WHERE
				t800.del_flag = 'N'
			AND t800.send_datetime BETWEEN '#{start_time}' AND '#{end_time}'
	EOS
	data = Array.new()
	mysql_cli.query(query).each do | row |
		data = data + Array.new(1, row)
	end
	return data
end
############################################
#
# Send Mail
#
############################################
def sendMailInfoFinish(mysql_cli, start_time, end_time)
	message = "先月分のテスト発信番号データ除外処理が実行されましたが、以下の発信テスト番号データが残存しているので、速やかに削除をお願いします。\n"
	arr_t80 = getRemainT80(mysql_cli, start_time, end_time)
	if arr_t80.length() > 0
		message = message + "t80_outgoing_results: "
		arr_t80.each do | row |
			message = message + row[0] + ","
		end
		message = message[0, message.length - 1] +  "\n"
	end
	arr_t81 = getRemainT81(mysql_cli, start_time, end_time)
	if arr_t81.length() > 0
		message = message + "t81_incoming_results: "
		arr_t81.each do | row |
			message = message + row[0] + ","
		end
		message = message[0, message.length - 1] +  "\n"
	end
	arr_t800 = getRemainT800(mysql_cli, start_time, end_time)
	if arr_t800.length() > 0
		message = message + "t800_sms_send_results: "
		arr_t800.each do | row |
			message = message + row[0] + ","
		end
		message = message[0, message.length - 1]
	end
	if arr_t80.length() == 0 && arr_t81.length() == 0 && arr_t800.length() == 0
		message = "先月分のテスト発信番号データ除外処理が正常に実行されました。"
	end
	sendMailInfo("", message)
end
############################################
#
# バッチのメイン処理
#
############################################
begin
	program_name = "[ExcludeTestTelNumbers]"
	#メール
	#DB接続情報
	db_ip = config[:database_ip]
	db_id = config[:database_id]
	db_pass = config[:database_pass]
	db_schema = config[:database_schema]
	server_name = config[:aserver_name]
	mysql_cli = Mysql.connect(db_ip, db_id, db_pass, db_schema)
	mysql_cli.charset = "utf8"
	time_update = Time.now.strftime("%Y-%m-%d %H:%M:%S")
	prev_month = DateTime.now.prev_month(1)
	start_time = prev_month.strftime("%Y-%m-01 00:00:00")
	end_time = Date.civil(prev_month.year, prev_month.month, -1).strftime("%Y-%m-%d 23:59:59")
	updateT80(mysql_cli, start_time, end_time, time_update)
	updateT81(mysql_cli, start_time, end_time, time_update)
	updateT800(mysql_cli, start_time, end_time, time_update)
	sendMailInfoFinish(mysql_cli, start_time, end_time)
	mysql_cli.close()
rescue Exception => e
	writeLog("err_exclude_test_tel_numbers")
	writeLog(program_name + "エラー：テスト発信番号除外バッチ実行：失敗 - " + e.message)
	writeLog(e.backtrace.join("\n"))
	sendMailError("")
	exit 9
end