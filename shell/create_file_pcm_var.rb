# encoding: UTF-8
#=============================================================================
# Contents   : 設定フォルダ、ファイル作成
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
def getExternalPrefix(mysql_cli, schedule_id)
	arr = Array.new()
	query = <<EOS
		select 
			m07.external_prefix,
			t20.call_type
		from
			t20_out_schedules t20 
				inner join
			m07_server_externals m07 on t20.external_number = m07.external_number
				and m07.del_flag = 'N'
		where
			t20.id = #{schedule_id} 
			and t20.del_flag = "N"
EOS
	mysql_cli.query(query).each do | row |
		arr = arr + Array.new(1, row)
	end
	return arr
end

begin
	schedule_no = ARGV[0]
	template_id = ARGV[1]
	list_id = ARGV[2]
	arr_item = Array.new()
	#DB接続情報
	db_ip = config[:database_ip]
	db_id = config[:database_id]
	db_pass = config[:database_pass]
	db_schema = config[:database_schema]
	localPathSchedule = config[:local_schedule]
	localPathScheduleId = config[:local_schedule] + schedule_no
	localPathIndata = localPathScheduleId + '/indata/'
	localPathPcmVar = localPathIndata + 'pcm_var/'
	#pcm_q作成
	mysql_cli=Mysql.connect(db_ip, db_id, db_pass, db_schema)
	mysql_cli.charset="utf8"
	external_prefix = ""
	call_type = ""
	speaker = ""
	external_prefix_info = getExternalPrefix(mysql_cli, schedule_no.to_i)
	external_prefix_info.each do | row |
		external_prefix = row[0]
		call_type = row[1]
		if(call_type == "1")
			call_type = "184"
		else
			call_type = ""
		end
	end
	#質問情報を取る
	queryGetQues = queryGetQues(template_id)
	mysql_cli.query(queryGetQues).each do | row |
		question_type = row[1]
		audio_type = row[3]
		audio_content = row[4]
		recheck_flag = row[8]
		recheck_audio_type = row[10]
		recheck_audio_content = row[11]
		if (audio_type == "1" || audio_type == "2")
			arr_item_tmp = Array.new()
			speaker = audio_type
			arr_item_tmp = audio_content.scan(/{(.*?)}/u)
			arr_item_tmp.each do | row |
				unless arr_item.include? row
					arr_item.push(row)
				end
			end
		end
		#数値認証・番号入力・文字列認証
		if (question_type.to_s == "3" || question_type.to_s == "4" || question_type.to_s == "10") && recheck_flag.to_s == "1" && (recheck_audio_type.to_s == "1" || recheck_audio_type.to_s == "2")
			arr_item_recheck_tmp = Array.new()
			speaker = recheck_audio_type
			arr_item_recheck_tmp = recheck_audio_content.scan(/{(.*?)}/u)
			arr_item_recheck_tmp.each do | row |
				unless arr_item.include? row
					arr_item.push(row)
				end
			end
		end
	end
	tel_column = getColumnByItemCode(mysql_cli, "tel_no", list_id)
	arr_item.each do | row |
		item_column = getColumnByItemName(mysql_cli, row[0], list_id)
		path = localPathPcmVar + item_column.to_s + "/"
		FileUtils.mkdir_p(path) unless File.exists?(path)
		`chmod 777 #{path}`
		query = <<EOS
			SELECT
				#{tel_column},
				#{item_column}
			FROM
				t11_tel_lists t11 
			WHERE
				t11.list_id = '#{list_id}' and
				t11.del_flag = 'N'
EOS
		mysql_cli.query(query).each do | arr |
			pcm_filename = external_prefix.to_s + call_type.to_s + arr[0].to_s + ".pcm"
			item_txt = arr[1]
			processGetFilePcmMix(mysql_cli, item_txt, path, pcm_filename, speaker, "read_list")
		end
	end
	mysql_cli.close()
rescue Exception => e
	puts "err_create_file_pcm_var"
	writeLog("err_create_file_pcm_var : " + e.message)
	writeLog("エラー：pcm_varファイルを作成失敗")
	writeLog(e.backtrace.join("\n"))
	sendMailError(schedule_no.to_i)
	exit 9
end