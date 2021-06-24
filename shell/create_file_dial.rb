# encoding: UTF-8
#=============================================================================
# Contents   : dialファイル作成
# Author     : Ascend Corp
# Since      : 2015/09/07        1.0
#=============================================================================

load File.join(File.dirname(__FILE__),'common.rb')
load File.join(File.dirname(__FILE__),'config.rb')

instance =  AscConfig.new
instance.instance_eval File.read File.join(File.dirname(__FILE__),'config.ini')
config = instance.getData

############################################
#
# バッチのメイン処理
#
############################################
begin
	schedule_no = ARGV[0]
	schedule_id = ARGV[1]
	list_id = ARGV[2]
	#DB接続情報
	db_ip = config[:database_ip]
	db_id = config[:database_id]
	db_pass = config[:database_pass]
	db_schema = config[:database_schema]
	localPathSchedule = config[:local_schedule]
	localPathScheduleId = config[:local_schedule] + schedule_no
	localPathIndata = localPathScheduleId + '/indata/'
	localPathDial = localPathIndata + 'dial/'
	fileDial = '1_dial.txt'
	createBlankCSV(localPathDial, fileDial)
	system("chmod 777 " + localPathDial + fileDial)
	csvFile = File.open(localPathDial + fileDial, 'a:UTF-8')
	#dial作成
	mysql_cli=Mysql.connect(db_ip, db_id, db_pass, db_schema)
	mysql_cli.charset="utf8"
	num_item = getNumAuthItemByScheduleId(mysql_cli, schedule_id)
	tel_item = getColumnByItemCode(mysql_cli, "tel_no", list_id)

	sms_items = getSmsItemName(mysql_cli, schedule_id)
	sms_arr_item = Array.new()
	sms_num_item = 0
	sms_items.each do | row |
		column = getColumnByItemName(mysql_cli, row, list_id)
		sms_arr_item.push(column)
		sms_num_item += 1
	end

	queryGetSchedule = <<EOS
		SELECT 
		    t20.recall_flag, 
		    t20.list_ng_id, 
		    DATE(t21.time_start),
		    t20.status
		FROM
		    t20_out_schedules t20
		        inner join
		    t21_out_times t21 ON t20.id = t21.schedule_id
		WHERE
		    t20.id = '#{schedule_id}'
		LIMIT 1
EOS
	mysql_cli.query(queryGetSchedule).each do | arr |
		redial_flag = arr[0]
		list_ng_id = arr[1]
		status = arr[3]
		if list_ng_id.blank?
			query_list_ng = ""
		end
		query_sms_item = ""
		#リダイヤルの場合
		if redial_flag.to_i > 0
			str_item = getAllColumn(mysql_cli, schedule_id, list_id, 't52')

			sms_arr_item.each do | item |
				query_sms_item += ",t52.#{item}"
			end

			unless list_ng_id.blank?
				date_run = arr[2]
				query_list_ng = "and t52.#{tel_item} not in (SELECT 
																tel_no
															FROM
																t15_outgoing_ng_tels t15
															WHERE
																t15.list_ng_id = '#{list_ng_id}'
																and t15.del_flag = 'N'
															)
								"
			end
			if status.to_s == "7"
				queryGetDial = <<EOS
							SELECT
								'1',
								t20.call_type,
								m07.external_prefix,
								#{str_item}
								#{query_sms_item}
							FROM
								t52_tel_redials t52 
									inner join 
								t20_out_schedules t20 on t20.id = t52.schedule_id 
									and t20.id = '#{schedule_id}'
									inner join
								m07_server_externals m07 on t20.external_number = m07.external_number
									and m07.del_flag = 'N'
									inner join
								m01_servers m01 on m01.server_id = m07.server_id
									and m01.server_type = '1'
									and m01.del_flag = 'N'
									inner join
								t11_tel_lists t11 on t11.#{tel_item} = t52.#{tel_item}
									and t11.list_id = '#{list_id}'
									and t11.muko_flag = 'N'
									and t11.del_flag = 'N'
							WHERE
								t52.schedule_id = '#{schedule_id}' 
								and t52.redial_flag = '#{redial_flag}'
								and t52.#{tel_item} not in (SELECT 
																t80.tel_no
															FROM
																t80_outgoing_results t80
															WHERE
																t80.schedule_id = '#{schedule_id}'
																and t80.redial_flag = '#{redial_flag}'
																and t80.status not in ('timeout', 'reject')
														   ) 
								#{query_list_ng}
							ORDER BY RAND()
EOS
			else
				queryGetDial = <<EOS
							SELECT
								'1',
								t20.call_type,
								m07.external_prefix,
								#{str_item}
								#{query_sms_item}
							FROM
								t52_tel_redials t52 
									inner join 
								t20_out_schedules t20 on t20.id = t52.schedule_id 
									and t20.id = '#{schedule_id}'
									inner join
								m07_server_externals m07 on t20.external_number = m07.external_number
									and m07.del_flag = 'N'
									inner join
								m01_servers m01 on m01.server_id = m07.server_id
									and m01.server_type = '1'
									and m01.del_flag = 'N'
									inner join
								t11_tel_lists t11 on t11.#{tel_item} = t52.#{tel_item}
									and t11.list_id = '#{list_id}'
									and t11.muko_flag = 'N'
									and t11.del_flag = 'N'
							WHERE
								t52.schedule_id = '#{schedule_id}' 
								and t52.redial_flag = '#{redial_flag}'
								and t52.#{tel_item} not in (SELECT 
																t80.tel_no
															FROM
																t80_outgoing_results t80
															WHERE
																t80.schedule_id = '#{schedule_id}'
																and t80.redial_flag = '#{redial_flag}'
														   ) 
								#{query_list_ng}
							ORDER BY RAND()
EOS
			end	
		else
			str_item = getAllColumn(mysql_cli, schedule_id, list_id, 't11')

			sms_arr_item.each do | item |
				query_sms_item += ",t11.#{item}"
			end
			unless list_ng_id.blank?
				date_run = arr[2]
				query_list_ng = "and t11.#{tel_item} not in (SELECT 
																tel_no
															FROM
																t15_outgoing_ng_tels t15
															WHERE
																t15.list_ng_id = '#{list_ng_id}'
																and t15.del_flag = 'N'
															)
								"
			end
			#リダイアル待ちの場合ダイアルリストが未接続の部分のみから作成
			if status.to_s == "7"
				queryGetDial = <<EOS
							SELECT
								'1',
								t20.call_type,
								m07.external_prefix,
								#{str_item}
								#{query_sms_item}
							FROM
								t11_tel_lists t11 
									inner join 
								t20_out_schedules t20 on t20.list_id = t11.list_id 
									and t20.id = '#{schedule_id}'
									inner join
								m07_server_externals m07 on t20.external_number = m07.external_number
									and m07.del_flag = 'N'
									inner join
								m01_servers m01 on m01.server_id = m07.server_id
									and m01.server_type = '1'
									and m01.del_flag = 'N'
							WHERE
								t11.list_id = '#{list_id}'
								and t11.#{tel_item} not in (SELECT 
																t80.tel_no
															FROM
																t80_outgoing_results t80
															WHERE
																t80.schedule_id = '#{schedule_id}'
																and t80.status not in ('timeout', 'reject')
														   ) 
								and t11.muko_flag = 'N'
								and t11.del_flag = 'N'
								#{query_list_ng}
							ORDER BY RAND()
EOS
			#リダイアル待ちじゃない場合ダイアルリストが未発信の部分のみから作成
			else
				queryGetDial = <<EOS
							SELECT
								'1',
								t20.call_type,
								m07.external_prefix,
								#{str_item}
								#{query_sms_item}
							FROM
								t11_tel_lists t11 
									inner join 
								t20_out_schedules t20 on t20.list_id = t11.list_id 
									and t20.id = '#{schedule_id}'
									inner join
								m07_server_externals m07 on t20.external_number = m07.external_number
									and m07.del_flag = 'N'
									inner join
								m01_servers m01 on m01.server_id = m07.server_id
									and m01.server_type = '1'
									and m01.del_flag = 'N'
							WHERE
								t11.list_id = '#{list_id}'
								and t11.#{tel_item} not in (SELECT 
																t80.tel_no
															FROM
																t80_outgoing_results t80
															WHERE
																t80.schedule_id = '#{schedule_id}'
														   ) 
								and t11.muko_flag = 'N'
								and t11.del_flag = 'N'
								#{query_list_ng}
							ORDER BY RAND()
EOS

			end

		end
		mysql_cli.query(queryGetDial).each do | row_dial |
			# t20.call_type = row_dial[1] = <通知(0)・非通知(1)>
			if row_dial[1] == "1"
				# 184を電話番号に付与して非通知とする。
				row_dial[3] = "184" + row_dial[3].to_s
			end
			# num_item=ユニークな認証項目の数。
			#    例：電話番号、生年月日=2  電話番号、電話番号=1
			# sms_num_item=ユニークなSMS挿入項目の数。
			#    例：電話番号、生年月日=2  電話番号、電話番号=1
			tmp = num_item + sms_num_item + 3
			str = ""
			#ダイアルリストはまずグループ番号が先頭に入る。半角スペースを開けて、下記を登録していく。
			#<prefix付き電話番号>,<認証項目1>,<認証項目2>・・・・,<SMS挿入項目1>,<SMS挿入項目2>・・・・
			# （例）認証項目やSMS挿入項目がない場合→1 00190209097859705,
			for i in 3..tmp
				## 電話番号
				if i == 3
					str = row_dial[2].to_s + row_dial[i].to_s
				## 認証項目
				elsif i <= num_item + 3
					str = str + "," + row_dial[i].to_s.gsub(/[^\d]/, '')
				## SMS挿入項目
				else
					str = str + "," + row_dial[i].to_s.gsub(/ /, '')
				end
			end
			# row_dial[0]＝グループ番号。
			csvFile.puts(NKF::nkf('-Wsm0', row_dial[0].to_s + " " + str))
		end
	end
	mysql_cli.close()
	csvFile.close
rescue Exception => e
	puts "err_create_file_dial"
	writeLog("err_create_file_dial : " + e.message)
	writeLog("エラー：dialファイルを作成失敗")
	writeLog(e.backtrace.join("\n"))
	sendMailError(schedule_id)
	exit 9
end