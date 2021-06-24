# encoding: UTF-8
#=============================================================================
# Contents   : リスト更新
# Author     : Fabbi - Canh
# Since      : 2018/07/26        1.0
#=============================================================================
load File.join(File.dirname(__FILE__),'common.rb')
load File.join(File.dirname(__FILE__),'config.rb')

instance =  AscConfig.new
instance.instance_eval File.read File.join(File.dirname(__FILE__),'config.ini')
config = instance.getData

def getInfoSchedule(mysql_cli)
	arr = Array.new()
	query = <<EOS
		select 
			t20.id,
			t20.list_id,
			t20.list_ng_id
		from
			t20_out_schedules t20
		where
			(t20.tel_total is null or (t20.tel_total = '' and t20.tel_total <> 0))
			and t20.status = '4'
			and t20.del_flag = 'N'
EOS
	mysql_cli.query(query).each do | row |
		arr = arr + Array.new(1, row)
	end
	return arr
end

def getTelTotal(mysql_cli, schedule_id)
	tel_total = 0
	query = <<EOS
			SELECT 
				COUNT(*)
			FROM
				t51_tel_histories t51
			WHERE
				t51.schedule_id = '#{schedule_id}'
					AND t51.del_flag = 'N'
					AND t51.muko_flag = 'N'
EOS
	mysql_cli.query(query).each do | arr |
		tel_total = arr[0]
	end
	return tel_total
end

def getColumnTelNo(mysql_cli, item, list_id)
	column = ""
	query = <<EOS
		select 
			t12.column
		from
			t12_list_items t12
		where
			list_id = '#{list_id}' 
			and item_code = '#{item}'
EOS
	
	mysql_cli.query(query).each do | row |
		column = row[0]
	end
	return column
end

def getNgTelTotal(mysql_cli, schedule_id, list_id)
	ngtel_total = 0;
	tel_item = getColumnTelNo(mysql_cli, "tel_no", list_id)
	query = <<EOS
			SELECT 
				COUNT(*)
			FROM
				t51_tel_histories t51 INNER JOIN t55_tel_ng_histories t55
				ON 
					t51.#{tel_item} = t55.tel_no
					AND t51.schedule_id = '#{schedule_id}'
					AND t55.schedule_id = '#{schedule_id}'
			WHERE
					t51.del_flag = 'N'
					AND t51.muko_flag = 'N'
					AND t55.del_flag = 'N'
EOS
	mysql_cli.query(query).each do | row |
		ngtel_total = row[0]
	end
	return ngtel_total
end

def updateTelTotal(mysql_cli, schedule_id, total)
	query = <<EOS
		UPDATE 
			t20_out_schedules t20 
		SET 
			t20.tel_total = '#{total}'
		WHERE
			t20.id = '#{schedule_id}'
EOS
	mysql_cli.query(query)
end
############################################
#
# バッチのメイン処理
#
############################################
begin
	program_name = "[リスト数更新]"
	writeLog(program_name + " 開始")
	#DB接続情報
	db_ip = config[:database_ip]
	db_id = config[:database_id]
	db_pass = config[:database_pass]
	db_schema = config[:database_schema]
	mysql_cli = Mysql.connect(db_ip, db_id, db_pass, db_schema)
	mysql_cli.charset="utf8"

	arr_schedule = getInfoSchedule(mysql_cli)
	if arr_schedule.length > 0
		arr_schedule.each do | arr |
			schedule_id = arr[0]
			list_id = arr[1]
			list_ng_id = arr[2]
			tel_total = getTelTotal(mysql_cli, schedule_id)
			if list_ng_id.empty?
				ngtel_total = 0
			else
				ngtel_total = getNgTelTotal(mysql_cli, schedule_id, list_id)
			end
			total = tel_total.to_i - ngtel_total.to_i
			updateTelTotal(mysql_cli, schedule_id, total)
			writeLog("スケジュール" + schedule_id.to_s + "のリスト数 ： " + total.to_s + "件更新されました。")
		end
	end
	mysql_cli.close()
	writeLog(program_name + " 終了")
rescue Exception, StandardError =>e
	writeLog(program_name + "err_mega_get_teltotal : " + e.message)
	writeLog(e.backtrace.join("\n"))
	sendMailError("")
	exit 9
end