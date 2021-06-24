# encoding: UTF-8
#=============================================================================
# Contents   : ans_listファイル作成
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
	template_id = ARGV[1]
	#DB接続情報
	db_ip = config[:database_ip]
	db_id = config[:database_id]
	db_pass = config[:database_pass]
	db_schema = config[:database_schema]
	localPathSchedule = config[:local_schedule]
	localPathScheduleId = config[:local_schedule] + schedule_no
	localPathIndata = localPathScheduleId + '/indata/'
	localPathAns = localPathIndata + 'ans_list/'
	fileAns = '1_ans.txt'
	createBlankCSV(localPathAns, fileAns)
	csvFile = File.open(localPathAns + fileAns, 'a:UTF-8')
	#ans_list作成
	mysql_cli=Mysql.connect(db_ip, db_id, db_pass, db_schema)
	mysql_cli.charset="utf8"
	#質問・認証・転送・カウント
	query = <<EOS
		select 
			t31.question_no, 
			t31.question_type, 
			GROUP_CONCAT(
				CASE
					WHEN t32.answer_no = '51' THEN '\\\\#'
					WHEN t32.answer_no = '52' THEN '*'
					ELSE t32.answer_no
				END
				order by t32.answer_no asc
			),
			t31.recheck_flag,
			t31.recheck_button_next
		from
			t31_template_questions t31
				left join
			t32_template_buttons t32 ON t31.template_id = t32.template_id
				and t31.question_no = t32.question_no
				and t32.yuko_flag = '1'
				and t32.del_flag = 'N'
		where
			t31.template_id = '#{template_id}'
				and t31.del_flag = 'N'
		group by t31.question_no
		order by t31.question_no asc
EOS
	mysql_cli.query(query).each do | row |
		question_no = row[0]
		question_type = row[1]
		if row[2].blank?
			ans_list = 9999999999
		else
			ans_list = row[2]
		end
		recheck_flag = row[3]
		recheck_button_next = row[4]
		#カウント場合
		if(question_type == "7")
			csvFile.puts(NKF::nkf('-Wsm0', 'C 1'))
		#SMS場合
		elsif(question_type == "13")
			csvFile.puts(NKF::nkf('-Wsm0', 'SMS 1'))
		#番号指定SMS
		elsif(question_type == "19")
			csvFile.puts(NKF::nkf('-Wsm0', 'Q' + question_no + ' ' + ans_list.to_s))
			csvFile.puts(NKF::nkf('-Wsm0', 'Q' + question_no + '-1 ' + recheck_button_next.to_s))
			csvFile.puts(NKF::nkf('-Wsm0', 'SMS 1'))
		#他場合
		else
			#再生・転送・録音・切断・タイムアウト以外場合
			if(question_type != "1" && question_type != "5" && question_type != "6" && question_type != "8" && question_type != "9")
				csvFile.puts(NKF::nkf('-Wsm0', 'Q' + question_no + ' ' + ans_list.to_s))
				if(recheck_flag.to_s == "1" && question_type.to_s == "3")
					csvFile.puts(NKF::nkf('-Wsm0', 'Q' + question_no + '-1 ' + recheck_button_next.to_s))
					csvFile.puts(NKF::nkf('-Wsm0', 'Q' + question_no + '-2 ' + recheck_button_next.to_s))
					csvFile.puts(NKF::nkf('-Wsm0', 'Q' + question_no + '-3 ' + recheck_button_next.to_s))
				end
				if(recheck_flag.to_s == "1" && question_type.to_s == "4")
					csvFile.puts(NKF::nkf('-Wsm0', 'Q' + question_no + '-1 ' + recheck_button_next.to_s))
				end
				if(recheck_flag.to_s == "1" && question_type.to_s == "10")
					csvFile.puts(NKF::nkf('-Wsm0', 'Q' + question_no + '-1 ' + recheck_button_next.to_s))
					csvFile.puts(NKF::nkf('-Wsm0', 'Q' + question_no + '-2 ' + recheck_button_next.to_s))
				end
			end
		end
	end
	mysql_cli.close()
	csvFile.close
rescue Exception => e
	puts "err_file_ans"
	writeLog("err_file_ans : " + e.message)
	writeLog("エラー：ans_listファイルを作成失敗")
	writeLog(e.backtrace.join("\n"))
	sendMailError(schedule_no.to_i)
	exit 9
end