# encoding: UTF-8
#=============================================================================
# Contents   : パス定義、CSVファイル書き込み、SSH転送、メール
# Author     : Ascend Corp
# Since      : 2015/09/07        1.0
#=============================================================================
require 'rubygems'
require 'csv'
require 'action_mailer'
require 'ntlm/smtp'
require 'nkf'
require 'net/ssh'
require 'net/sftp'
require 'date'
require 'time'
require 'fileutils'
require 'mysql'
require 'curb'
require 'uri'
require 'net/http'
require 'json'
require 'base64'
require 'tempfile'

###########################################
#
# OUTバウンドで利用する定数
#
###########################################
$SMS_API_V2_VALUE = '2'
$SMS_API_V1_KAISEN_NAME_NTT = 'NTTCOM'
$SMS_API_V2_KAISEN_NAME_NTT = 'NTTCOM2'
# 手動停止の捕捉で停止中の時間閾値(秒)
KILL_FAILURE_TIME = 120

###########################################
#
# ステータス
#
###########################################
STATUS_NO_CALL = '0'
STATUS_CALLING = '1'
STATUS_STOP_CALL = '2'
STATUS_TEMP_FINISH = '3'
STATUS_FINISH = '4'
STATUS_STOPING = '5'
STATUS_FINISHING = '6'
STATUS_REDIAL_WAIT = '7'

###########################################
#
# 発信時間超過スケジュール捕捉バッチで使用する定数
#
###########################################
# 捕捉対象閾値(秒)
$RERUN_THRESHOLD = 600
# 捕捉対象スケジュール終了時間閾値(分)
$RERUN_END_TIME_THRESHOLD = 10

load File.join(File.dirname(__FILE__),'config.rb')

###########################################
#
# フォルダパス情報
#
###########################################
def getLocalPathLogBatch()
	return File.dirname(__FILE__) + "/log/"
end

###########################################
#
# ログファイル名を取得
#
###########################################
def getLogFileName()
	localPathLog = getLocalPathLogBatch()
	FileUtils.mkdir_p(localPathLog) unless File.exists?(localPathLog)
	return localPathLog+Time.now.strftime("%Y%m%d")+".log"
end

###########################################
#
# ログ記録用
#
###########################################
def writeLog(str) 
	unless File.file?(getLogFileName())
		logCreate = File.new(getLogFileName(), "w")
		logCreate.chmod(0777)
	end
	logFile = File.open(getLogFileName(),'a:UTF-8')
	logFile.puts "["+Time.now.strftime("%Y/%m/%d %H:%M:%S")+"] "+str
	logFile.close
end

###########################################
#
# ログファイルを削除する。
#
###########################################
def clearLog ()
	if File.exist?(getLogFileName())
		FileUtils.rm_f(getLogFileName())
	end
end

###########################################
#
# 空のCSVファイルを出力する。
#
###########################################
def createBlankCSV(csvPath, fileName)
	csvFile = File.open(csvPath + fileName, 'w')
	csvFile.close
	system("chmod 777 " + csvPath + fileName)
end

###########################################
#
# メガ実行コマンド
#
###########################################
def command(host, schedule_id, cmd, parameter)
	instance =  AscConfig.new
	instance.instance_eval File.read File.join(File.dirname(__FILE__),'config.ini')
	config = instance.getData
	ascallsrv_port = config[:ascallsrv_port]
	if parameter.blank? then
		command = "/home/robo/as-call/bin/ascallcli -h " + host + " -p "+ ascallsrv_port +" -s " + schedule_id + " -c " + cmd
		result = `#{command}` 
	elsif
		command = "/home/robo/as-call/bin/ascallcli -h " + host + " -p "+ ascallsrv_port +" -s " + schedule_id + " -c " + cmd + " " + parameter
		result = `#{command}` 
	end
	if result.strip != "RET_OK" then
		if(cmd != "autocall" && cmd != "delschedule")
			cmd_dellschedule = "/home/robo/as-call/bin/ascallcli -h " + host + " -p "+ ascallsrv_port +" -s " + schedule_id + " -c delschedule"
			rel_clear = `#{cmd_dellschedule}` 
			writeLog("スケジュール解放実行 : " + rel_clear)
		end
		writeLog("ascallcli実行コマンドエラーが発生しました")
		writeLog("実行コマンド : " + command)
		writeLog("エラーコード : " + result)
		sendMailError(schedule_id.to_i)
		raise result
	end
	return result
end

###########################################
#
# メガ実行コマンドステータス
#
###########################################
def commandGetStatus(host, schedule_id)
	instance =  AscConfig.new
	instance.instance_eval File.read File.join(File.dirname(__FILE__),'config.ini')
	config = instance.getData
	ascallsrv_port = config[:ascallsrv_port]
	command = "/home/robo/as-call/bin/ascallcli -h " + host + " -p "+ ascallsrv_port +" -s " + schedule_id + " -c getstatus"
	result = `#{command}` 
	if result.strip != "RET_ALIVE" && result.strip != "RET_TERM" then
		writeLog("実行コマンド : " + command)
		writeLog("エラーコード : " + result)
		#raise result
	end
	return result
end

###########################################
#
# 発信リスト関連
#
###########################################
#カラムを取得
def getColumnByItemName(mysql_cli, item, list_id)
	column = ""
	query = <<EOS
		select 
			t12.column
		from
			t12_list_items t12
		where
			list_id = '#{list_id}' and
			item_name = '#{item}' and
			del_flag = "N"
EOS
	
	mysql_cli.query(query).each do | row |
		column = row[0]
	end
	return column
end

#カラムを取得
def getColumnByItemCode(mysql_cli, item, list_id)
	column = ""
	query = <<EOS
		select 
			t12.column
		from
			t12_list_items t12
		where
			list_id = '#{list_id}' and
			item_code = '#{item}' and
			del_flag = "N"
EOS
	
	mysql_cli.query(query).each do | row |
		column = row[0]
	end
	return column
end

#カラムテキストを取得
def getAllColumn(mysql_cli, schedule_id, list_id, tbl)
	tel_no = getColumnByItemCode(mysql_cli, "tel_no", list_id)
	str_item = tbl + "." + tel_no
	query = <<EOS
			select 
    			distinct t31.auth_item
			from
				t20_out_schedules t20 
					left join 
				t31_template_questions t31 on t20.template_id = t31.template_id 
					and t31.question_type in('3', '10')
					and t31.del_flag = 'N'
			where
				t20.id = #{schedule_id} 
				and t20.del_flag = 'N'
			order by t31.question_no
EOS
	mysql_cli.query(query).each do | row |
		column = getColumnByItemName(mysql_cli, row[0], list_id)
		if column.blank?
			str_item = str_item + "," + "''"
		else
			str_item = str_item + "," + tbl + "." + column
		end
	end
	return str_item
end

#認証数を取得
def getNumAuthItemByScheduleId(mysql_cli, schedule_id)
	count = 0
	query = <<EOS
			select 
    			count(distinct t31.auth_item)
			from
				t20_out_schedules t20 
					left join 
				t31_template_questions t31 on t20.template_id = t31.template_id 
					and t31.question_type in('3', '10')
					and t31.del_flag = 'N'
			where
				t20.id = #{schedule_id} 
				and t20.del_flag = 'N'
			order by t31.question_no
EOS
	mysql_cli.query(query).each do | row |
		count = row[0].to_i
	end
	#認証項目が無ければdial作成時、デフォルトの値が空白のため、項目も1にする
	if(count == 0)
		count = 1
	end
	return count
end

#SMSセクションの挿入項目を洗い出す
def getSmsItemName(mysql_cli, schedule_id)
	data = Array.new()
	query = <<EOS
	select
		t31.sms_content
	from
		t20_out_schedules t20
	join 
		t31_template_questions t31
	on t20.template_id = t31.template_id
    where
    	t20.id = '#{schedule_id}' and
    	t31.question_type in ('13','19') and
    	t20.del_flag = 'N' and
    	t31.del_flag = 'N';
EOS
	mysql_cli.query(query).each do | row |
		data = data + Array.new(1, row)
	end
	arr_item = Array.new()
	data.each do | row |
		items = row[0].scan(/{(.*?)}/u)
		items.each do | row |
			unless arr_item.include? row[0]
				arr_item.push(row[0])
			end
		end
	end
	return arr_item
end


#項目コードを取得
def getItemListCode(mysql_cli, item)
	item_code = ""
	query = <<EOS
		select 
			item_code
		from
			m90_pulldown_codes 
		where
			type_code = "list_item" and
			item_name = "#{item}" and
			del_flag = "N"
EOS
	mysql_cli.query(query).each do | row |
		item_code = row[0]
	end
	return item_code
end

def queryGetQues(template_id)
	query = <<EOS
		select 
			t31.question_no,
			t31.question_type,
			t31.audio_id,
			t31.audio_type,
			t31.audio_content,
			t31.trans_timeout_audio_id,
			t31.trans_timeout_audio_type,
			t31.trans_timeout_audio_content,
			t31.recheck_flag,
			t31.recheck_audio_id,
			t31.recheck_audio_type,
			t31.recheck_audio_content,
			t31.sms_error_audio_type,
			t31.sms_error_audio_id,
			t31.sms_error_audio_content
		from
			t31_template_questions t31 
		where
			t31.template_id = '#{template_id}' and
			t31.del_flag = 'N'
		order by t31.question_no;
EOS
	return query
end

#音声ファイル
def processGetFilePcm(mysql_cli, audio_id, path)
	query = <<EOS
		select 
			file_pcm_contents
		from
			t89_manage_files
		where
			id = '#{audio_id}'
EOS
	mysql_cli.query(query).each do | row |
		File.binwrite(path, row[0])
		system("chmod 777 " + path)
	end
end

#音声合成
def processGetFilePcmMix(mysql_cli, text, path, filename, speaker, from = nil)
	if text.blank?
		path_pcm = path + filename
		pcmFile = File.open(path_pcm, 'w')
		pcmFile.close
	else
		uri = URI.parse("http://10.1.1.191/FutureVoiceCrayon/scripts/TTSWebAPI.cgi")

		if speaker == "1" then
			speakerid = "000-00-1-114"
			styleid = "114"
			vtype = "1.05"
			srate = from == 'read_list' ?  "0.8" : "1.05"
			pitch = "11"
			intonation = from == 'read_list' ?  "9" : "9"
		elsif speaker == "2" then
			speakerid = "000-00-0-113"
			styleid = "113"
			vtype = "1.1"
			srate = from == 'read_list' ?  "0.8" : "0.95"
			pitch = "16"
			intonation = from == 'read_list' ?  "9" : "10"
		end
		# 3回、頑張る
		max_roop = 3
		wait_seconds = 1
		for i in 1..max_roop
			response = nil

			http = Net::HTTP.new(uri.host, uri.port)
			#http.use_ssl = true
			#http.verify_mode = OpenSSL::SSL::VERIFY_NONE

			req = Net::HTTP::Post.new(uri.request_uri,initheader = {'Content-Type' =>'application/json'})

			req.body = {Command: "AP_Synth",						
						TextData: text,
						AudioFileFormat: 3,
						SamplingRate: 0,
						SpeakerID: speakerid,
						StyleID: styleid,
						VoiceType: vtype,
						Pitch: pitch,
						Intonation: intonation,
						SpeechRate: srate,
						PowerRate: 0.7}.to_json
			response = http.request(req)
			# 200番台でかつ本文の長さが0でなければOK。
			# response.codeはstring型。
			# 送信データの最大サイズは、10,000byteだが、それ以上を渡すと「response.code：200」「response.content_length：0」になる
			if response.code.to_i >= 200 && response.code.to_i < 300 && !(response["x-content-length"].blank?) && response["x-content-length"].to_i > 0
				break
			else
				# 規定回数異常失敗した場合は、ログを残し処理を継続（その音声はなしで発信する仕様）
				if i == max_roop
					kaigyou = "\r\n"
					log_body = "API「FutureVoiceCrayon」実行失敗（processGetFilePcmMix）" + kaigyou
					log_body = log_body + "path：" + path.to_s + kaigyou
					log_body = log_body + "filename：" + filename.to_s + kaigyou
					log_body = log_body + "response.code：" + response.code.to_s + kaigyou
					log_body = log_body + "response.content_length：" + response["x-content-length"].to_s + kaigyou
					log_body = log_body + "text：" + text.to_s + kaigyou
					log_body = log_body + "speakerid：" + speakerid.to_s + kaigyou
					log_body = log_body + "styleid：" + styleid.to_s + kaigyou
					log_body = log_body + "vtype：" + vtype.to_s + kaigyou
					log_body = log_body + "pitch：" + pitch.to_s + kaigyou
					log_body = log_body + "intonation：" + intonation.to_s + kaigyou
					log_body = log_body + "srate：" + srate.to_s + kaigyou
					writeLog(log_body)
				else
					sleep(wait_seconds)
				end
			end
		end
		path_pcm = path + filename
		File.binwrite(path_pcm, Base64.decode64(response.body))
		system("chmod 777 " + path_pcm)
	end
end


############################################
#
#　スケジュールログを追加
#
############################################
def insert_log_schedule(mysql_cli, schedule_id)
	num = 0
	queryCheckData = <<EOS
		select 
			count(*)
		from
			t50_list_histories t50
		where
			t50.schedule_id = '#{schedule_id}';
EOS
	mysql_cli.query(queryCheckData).each do | arr |
		num = arr[0]
	end
	if(num == "0")
		queryInsertT50 = <<EOS
			insert into t50_list_histories(schedule_id, list_id, list_name, list_test_flag, tel_total)
			select 
				t20.id,
				t10.id,
				t10.list_name,
				t10.list_test_flag,
				t10.tel_total
			from t20_out_schedules t20 inner join t10_call_lists t10 on t20.list_id = t10.id and t10.del_flag = "N"
			where t20.id = '#{schedule_id}';
EOS
		queryInsertT51 = <<EOS
			insert into t51_tel_histories(schedule_id, customize1, customize2, customize3, customize4,
			 customize5, customize6, customize7, customize8, customize9, customize10, customize11, muko_flag, muko_modified)
			select 
				t20.id,
				t11.customize1,
				t11.customize2,
				t11.customize3,
				t11.customize4,
				t11.customize5,
				t11.customize6,
				t11.customize7,
				t11.customize8,
				t11.customize9,
				t11.customize10,
				t11.customize11,
				t11.muko_flag,
				t11.muko_modified
			from t20_out_schedules t20 inner join t11_tel_lists t11 on t20.list_id = t11.list_id and t11.del_flag = "N"
			where t20.id = '#{schedule_id}';
EOS
		queryInsertT54 = <<EOS
			insert into t54_list_ng_histories(schedule_id, list_ng_id, list_name, total, expired_date_from, expired_date_to)
			select 
				t20.id,
				t14.id,
				t14.list_name,
				t14.total,
				t14.expired_date_from,
				t14.expired_date_to
			from t20_out_schedules t20 inner join t14_outgoing_ng_lists t14 on t20.list_ng_id = t14.id and t14.del_flag = "N"
			where t20.id = '#{schedule_id}';
EOS
		queryInsertT55 = <<EOS
			insert into t55_tel_ng_histories(schedule_id, tel_no, memo)
			select 
				t20.id,
				t15.tel_no,
				t15.memo
			from t20_out_schedules t20 inner join t15_outgoing_ng_tels t15 on t20.list_ng_id = t15.list_ng_id and t15.del_flag = "N"
			where t20.id = '#{schedule_id}';
EOS
		queryInsertT60 = <<EOS
			insert into t60_template_histories(schedule_id, template_id, template_name, question_total, description)
			select 
				t20.id,
				t30.id,
				t30.template_name,
				t30.question_total,
				t30.description
			from t20_out_schedules t20 inner join t30_templates t30 on t20.template_id = t30.id and t30.del_flag = "N"
			where t20.id = '#{schedule_id}';
EOS
		queryInsertT61 = <<EOS
			insert into t61_question_histories(
				schedule_id, question_no, question_type, question_yuko, question_title, 
				audio_type, audio_id, audio_name, audio_content, 
				question_repeat, auth_item, second_record, yuko_button_record, digit, 
				trans_tel, trans_seat_num, trans_empty_seat_flag, 
				trans_timeout_audio_type, trans_timeout_audio_id, trans_timeout_audio_name, trans_timeout_audio_content, trans_timeout, 
				recheck_flag, recheck_audio_type, recheck_audio_id, recheck_audio_name, recheck_audio_content, 
				recheck_button_next, recheck_button_prev, sms_display_number, sms_content
			)
			select 
				t20.id,
				t31.question_no,
				t31.question_type,
				t31.question_yuko,
				t31.question_title,
				t31.audio_type,
				t31.audio_id,
				t31.audio_name,
				t31.audio_content,
				t31.question_repeat,
				t31.auth_item,
				t31.second_record,
				t31.yuko_button_record,
				t31.digit,
				t31.trans_tel,
				t31.trans_seat_num,
				t31.trans_empty_seat_flag,
				t31.trans_timeout_audio_type,
				t31.trans_timeout_audio_id,
				t31.trans_timeout_audio_name,
				t31.trans_timeout_audio_content,
				t31.trans_timeout,
				t31.recheck_flag,
				t31.recheck_audio_type,
				t31.recheck_audio_id,
				t31.recheck_audio_name,
				t31.recheck_audio_content,
				t31.recheck_button_next,
				t31.recheck_button_prev,
				t31.sms_display_number,
				t31.sms_content
			from t20_out_schedules t20 inner join t31_template_questions t31 on t20.template_id = t31.template_id and t31.del_flag = "N"
			where t20.id = '#{schedule_id}';
EOS
		queryInsertT62 = <<EOS
			insert into t62_button_histories(schedule_id, question_no, answer_no, yuko_flag, jump_question, answer_content)
			select 
				t20.id,
				t32.question_no,
				t32.answer_no,
				t32.yuko_flag,
				t32.jump_question,
				t32.answer_content
			from t20_out_schedules t20 inner join t32_template_buttons t32 on t20.template_id = t32.template_id and t32.del_flag = "N"
			where t20.id = '#{schedule_id}';
EOS
		mysql_cli.query(queryInsertT50)
		writeLog("T50リストログを追加　：　OK")
		mysql_cli.query(queryInsertT51)
		writeLog("T51電話番号ログを追加　：　OK")
		mysql_cli.query(queryInsertT54)
		writeLog("T54NGリストログを追加　：　OK")
		mysql_cli.query(queryInsertT55)
		writeLog("T55NG電話番号ログを追加　：　OK")
		mysql_cli.query(queryInsertT60)
		writeLog("T60ログを追加　：　OK")
		mysql_cli.query(queryInsertT61)
		writeLog("T61ログを追加　：　OK")
		mysql_cli.query(queryInsertT62)
		writeLog("T62ログを追加　：　OK")
	end
end

############################################
#
# 実行ログ追加
#
############################################
def insert_run_log(mysql_cli, schedule_id)
	time_now = Time.now.strftime("%Y-%m-%d %H:%M")
	query = <<EOS
		INSERT INTO t22_out_logs (schedule_id, time_start)
		VALUES ('#{schedule_id}', '#{time_now}');
EOS
	mysql_cli.query(query)
end

###########################################
#
# メールアカウントを初期化する。
# 例）
# initMail('smtp.office365.com', 'ascend-corp.co.jp', 'astar_report@ascend-corp.co.jp', 'Fj2Lp=ntXygn-N?m2Z3VCs')
#
###########################################
def initMail(address, domain, user_name, password)
	ActionMailer::Base.delivery_method = :smtp
	ActionMailer::Base.smtp_settings = {
	  enable_starttls_auto: true,
	  address: address,
	  port: 587,
	  domain: domain,
	  user_name: user_name,
	  password: password,
	  authentication: :login,
	  #enable_starttls_auto: false
	}
end

###########################################
#
# アセンドメールに再定義
#
###########################################
class AscMailer < ActionMailer::Base
	def send_mail(to, from, subject, body, filePath, fileName)
		initMail('smtp.office365.com', 'ascend-corp.co.jp', 'astar_report@ascend-corp.co.jp', 'Fj2Lp=ntXygn-N?m2Z3VCs')
		unless filePath.blank?
			attachments[fileName] = {
				:content => File.read(filePath, :mode => 'rb'),
				:transfer_encoding => :binary
			}
		end

		mail(
			to: to,
			from: from,
			subject: subject.to_s,
			body: body.to_s
		)
	end
	def send_mail_backup(to, from, subject, body, filePath, fileName)
		initMail('smtp.gmail.com', 'ascend-corp.co.jp', 'ascallreport@gmail.com', 'Pass1234qwe109r')
		unless filePath.blank?
			attachments[fileName] = {
				:content => File.read(filePath, :mode => 'rb'),
				:transfer_encoding => :binary
			}
		end

		mail(
			to: to,
			from: from,
			subject: subject.to_s,
			body: body.to_s
		)
	end

end

def getListMail()
	# listMail = ["system@ascend-corp.co.jp"]
	listMail = ["hayabusa_dev@ascend-corp.co.jp"]
	return listMail
end

def queryGetScheduleByScheduleId(schedule_id)
	query = <<EOS
				select 
				    m02.company_name,
				    t20.schedule_no,
				    t20.schedule_name,
				    t20.external_number,
				    t20.proc_num,
				    t10.tel_total,
					GROUP_CONCAT(t21.time_start,"~",t21.time_end," "),
					t20.recall,
					t20.recall_flag
				from
				    t20_out_schedules t20
				        inner join
				    m02_companies m02 ON t20.company_id = m02.company_id
				        inner join
				    t10_call_lists t10 ON t20.list_id = t10.id
						inner join
					t21_out_times t21 ON t21.schedule_id = t20.id and t21.del_flag = "N"
				where
					t20.id = '#{schedule_id}'
EOS
	return query
end

def sendMailError(schedule_id)
	instance =  AscConfig.new
	instance.instance_eval File.read File.join(File.dirname(__FILE__),'config.ini')
	config = instance.getData

	# to = ["robocall-alert@ascend-corp.co.jp"]
	to = ["hayabusa_dev@ascend-corp.co.jp"]
	from = "astar_report@ascend-corp.co.jp"
	subject = "【はやぶさ】(GS-DEV環境)エラー"
    body = "お疲れ様です。\r\nエラーが発生しました。\r\n"
    body = body + "詳細は下記資料と添付ファイルを確認し、ご対応お願いします。\r\n"
    body = body + "※資料の場所：\\\\10.101.0.231\\ascend-sjk\\案件フォルダ\\hayabusa_team\\troubleshoot\r\n"
	#body = body + "・メガサーバ名: " + config[:aserver_name].to_s + "\r\n"
	if schedule_id.blank?
		body = body + "・区分: クーロン\r\n"
	else
		schedule_id = schedule_id.to_s
		body = body + "・区分: 画面\r\n"
		body = body + "・スケジュールID: " + schedule_id + "\r\n"
		db_ip = config[:database_ip]
		db_id = config[:database_id]
		db_pass = config[:database_pass]
		db_schema = config[:database_schema]
		mysql_cli = Mysql.connect(db_ip, db_id, db_pass, db_schema)
		mysql_cli.charset = "utf8"
		mysql_cli.query(queryGetScheduleByScheduleId(schedule_id)).each do | row |
			body = body + "・会社名: " + row[0].to_s + "\r\n"
			body = body + "・スケジュールNO: " + row[1].to_s + "\r\n"
			body = body + "・スケジュール名: " + row[2].to_s + "\r\n"
			body = body + "・発信番号: " + row[3].to_s + "\r\n"
			body = body + "・ch数: " + row[4].to_s + "\r\n"
			body = body + "・リスト件数: " + row[5].to_s + "\r\n"
			body = body + "・発信時間: " + row[6].to_s + "\r\n"
		end
		mysql_cli.close()
	end
	logFilePath = getLogFileName()
	logFileName = "error_log.txt"
	# tailした内容を添付する
	begin
		result = `tail -100 #{logFilePath}`
		tmp = Tempfile.new('log')
		tmp.write("#{result}\n")
		tmp.flush
		logFilePath = tmp.path
	rescue Exception =>e
		body +=  "\r\n\r\n※エラーログの抜粋に失敗しましたので、添付ファイルには、すべてのログを添付します。" + "\r\n"
		body +=  "＊＊＊＊以下、抜粋失敗のエラー＊＊＊＊" + "\r\n"
		body +=  e.message + "\r\n"
		body +=  "＊＊＊＊抜粋失敗のエラーEND＊＊＊＊" + "\r\n"
		# ログファイルを再設定（全部出す）
		logFilePath = getLogFileName()
	end
	begin
		# 締めのメッセージが2重に出ないようworkを利用する。
		work_body = body + "以上、宜しくお願いします。"
		AscMailer.send_mail(to, from, subject, work_body, logFilePath, logFileName).deliver
		writeLog("メールする　：　OK")
	rescue Exception =>e
		body +=  "\r\n\r\n※メールの送信に失敗しましたので、Gmailにて送信します。" + "\r\n"
		body +=  "＊＊＊＊以下、抜粋失敗のエラー＊＊＊＊" + "\r\n"
		body +=  e.message + "\r\n"
		body +=  "＊＊＊＊メールの送信失敗時のエラーEND＊＊＊＊" + "\r\n"
        # これ以上メッセージはついアされないので、締めのメッセージをbodyに入れる。
        body += "以上、宜しくお願いします。"
		writeLog("[SendMailError]メール通知エラー")
		writeLog("[SendMailError]to : " + to.to_s)
		writeLog("[SendMailError]from : " + from.to_s)
		writeLog("[SendMailError]subject : " + subject.to_s)
		writeLog("[SendMailError]body : " + body.to_s)
		writeLog("[SendMailError]logFilePath : " + logFilePath.to_s)
		writeLog("[SendMailError]logFileName : " + logFileName.to_s)
		begin
			AscMailer.send_mail_backup(to, from, subject, body, logFilePath, logFileName).deliver
			writeLog("メールする　：　OK")
		rescue Exception =>e
			writeLog("[SendMailError]Gmailでメール送信失敗")
		end
	end

end

def sendMailInfo(schedule_id, message)
	instance =  AscConfig.new
	instance.instance_eval File.read File.join(File.dirname(__FILE__),'config.ini')
	config = instance.getData

	to = ["hayabusa_dev@ascend-corp.co.jp"]
	from = "astar_report@ascend-corp.co.jp"
	subject = "【はやぶさ】(GS-DEV環境)通知"
	body = message+ "\r\n"

	schedule_id = schedule_id.to_s
	body = body + "・スケジュールID: " + schedule_id + "\r\n"
	db_ip = config[:database_ip]
	db_id = config[:database_id]
	db_pass = config[:database_pass]
	db_schema = config[:database_schema]
	mysql_cli = Mysql.connect(db_ip, db_id, db_pass, db_schema)
	mysql_cli.charset = "utf8"
	mysql_cli.query(queryGetScheduleByScheduleId(schedule_id)).each do | row |
		body = body + "・会社名: " + row[0].to_s + "\r\n"
		body = body + "・スケジュールNO: " + row[1].to_s + "\r\n"
		body = body + "・スケジュール名: " + row[2].to_s + "\r\n"
		body = body + "・発信番号: " + row[3].to_s + "\r\n"
		body = body + "・ch数: " + row[4].to_s + "\r\n"
		body = body + "・リスト件数: " + row[5].to_s + "\r\n"
		body = body + "・発信時間: " + row[6].to_s + "\r\n"
	end
	mysql_cli.close()

	begin
		AscMailer.send_mail(to, from, subject, body, "", "").deliver
		writeLog("メールする　：　OK")
	rescue Exception =>e
		body +=  "\r\n\r\n※メールの送信に失敗しましたので、Gmailにて送信します。" + "\r\n"
		body +=  "＊＊＊＊以下、抜粋失敗のエラー＊＊＊＊" + "\r\n"
		body +=  e.message + "\r\n"
		body +=  "＊＊＊＊メールの送信失敗時のエラーEND＊＊＊＊" + "\r\n"
		writeLog("[SendMailError]メール通知エラー")
		writeLog("[SendMailError]to : " + to.to_s)
		writeLog("[SendMailError]from : " + from.to_s)
		writeLog("[SendMailError]subject : " + subject.to_s)
		writeLog("[SendMailError]body : " + body.to_s)
		begin
			AscMailer.send_mail_backup(to, from, subject, body, "", "").deliver
			writeLog("メールする　：　OK")
		rescue Exception =>e
			writeLog("[SendMailError]Gmailでメール送信失敗")
		end
	end

end

###########################################
#
# アセンドメールに再定義
#
###########################################

def getYukoNum(mysql_cli, schedule_id, list_id)
	query = <<EOS
				select 
					t61.question_no,
					t61.question_type,
					t61.auth_item,
					t61.recheck_flag,
					t61.question_yuko
				from
					t61_question_histories t61
				where
					t61.schedule_id = '#{schedule_id}'
					order by t61.question_no ASC
EOS

	row = 1
	i = 1
	str_query = ""
	mysql_cli.query(query).each do | arr | 
		ques_no = arr[0]
		ques_type = arr[1]
		auth_item = arr[2]
		recheck_flag = arr[3]
		ques_yuko = arr[4]
		str_answ_yuko = ""
		if ques_yuko.to_i == 1
			query_answ_yuko = <<EOS
				select 
					CASE
						WHEN t62.answer_no = '51' THEN '*'
						WHEN t62.answer_no = '52' THEN '#'
						ELSE t62.answer_no
					END
				from
					t62_button_histories t62
				where
					t62.schedule_id = '#{schedule_id}'
					and t62.question_no = '#{ques_no}'
					and t62.yuko_flag = '1'

EOS
			mysql_cli.query(query_answ_yuko).each do | arr_yuko |
				if str_answ_yuko.blank?
					str_answ_yuko = "'" + arr_yuko[0] + "'"
				else
					str_answ_yuko = str_answ_yuko + ",'" + arr_yuko[0] + "'"
				end
				
			end 
		end
		if ques_type.to_s == '1' || ques_type.to_s == '5' || ques_type.to_s == '6' || ques_type.to_s == '8' || ques_type.to_s == '9'
			row = row + 0
		elsif ques_type.to_s == '2'
			if ques_yuko.to_i == 1
				tmp = "t80.answer"+row.to_s + " in (" + str_answ_yuko + ")"
				if i == 1
					str_query = tmp
					i = 2
				else
					str_query = str_query + " and " + tmp
				end
			end
			row = row + 1
		elsif ques_type.to_s == '3'
			auth_column = getColumnByItemName(mysql_cli, auth_item, list_id)
			if ques_yuko.to_i == 1
				str_auth = ""
				str_answ_yuko.split(",").each do | ans |
          ans.gsub!("'", "")
					if ans.to_s == '1'
						tmp = "t80.answer" + row.to_s + " < t51." + auth_column
					elsif ans.to_s == '2'
						tmp = "t80.answer" + row.to_s + " = t51." + auth_column
					elsif ans.to_s == '3'
						tmp = "t80.answer" + row.to_s + " > t51." + auth_column
					end
					if str_auth.blank?
						str_auth = tmp
					else
						str_auth = str_auth + " or " + tmp
					end
				end
				if i == 1
					str_query = "(" + str_auth + ")"
					i = 2
				else
					str_query = str_query + " and (" + str_auth + ")"
				end
			end
			if recheck_flag.to_s == '1'
				row = row + 4
			else
				row = row + 1
			end
		elsif ques_type.to_s == '10'
			auth_column = getColumnByItemName(mysql_cli, auth_item, list_id)
			if ques_yuko.to_i == 1
				str_auth = ""
				str_answ_yuko.split(",").each do | ans |
				ans.gsub!("'", "")
					if ans.to_s == '1'
						tmp = "t80.answer" + row.to_s + " = t51." + auth_column
					elsif ans.to_s == '2'
						tmp = "t80.answer" + row.to_s + " != t51." + auth_column
					end
					if str_auth.blank?
						str_auth = tmp
					else
						str_auth = str_auth + " or " + tmp
					end
				end
				if i == 1
					str_query = "(" + str_auth + ")"
					i = 2
				else
					str_query = str_query + " and (" + str_auth + ")"
				end
			end
			if recheck_flag.to_s == '1'
				row = row + 3
			else
				row = row + 1
			end
		elsif ques_type.to_s == '4'
			if recheck_flag.to_s == '1'
				row = row + 2
			else
				row = row + 1
			end
		elsif ques_type.to_s == '7'
			row = row + 1
		end
	end
	tel_item = getColumnByItemCode(mysql_cli, "tel_no", list_id)
	query = <<EOS
		select 
			count(*)
		from
			t80_outgoing_results t80
				inner join
			t51_tel_histories t51 ON t51.#{tel_item} = t80.tel_no
				and t51.schedule_id = t80.schedule_id
				and t51.schedule_id = '#{schedule_id}'
				and t51.del_flag = 'N'
		where
			t80.schedule_id = '#{schedule_id}'
				and t80.status not in ('timeout', 'reject')
				and #{str_query}
EOS
	yuko_num = 0
	writeLog(query)
	mysql_cli.query(query).each do | row |
		yuko_num = row[0]
	end
	return yuko_num
end

###########################################
#
# 接続数を取得
#
###########################################

def getConnectedNum(mysql_cli, schedule_id)
	query = <<EOS
		select 
			count(*)
		from
			t80_outgoing_results t80
		where
			t80.schedule_id = '#{schedule_id}'
				and t80.status not in ('timeout', 'reject')
EOS
	connected_num = 0
	writeLog(query)
	mysql_cli.query(query).each do | row |
		connected_num = row[0]
	end
	return connected_num
end
#=============================================================================
#　音声合成を分けて配列に入れる
# param : audio_content
# return : array
#=============================================================================
def getArrAudioContent(audio_content)
	arr = Array.new()
	count_start = 0
	count_end = 0
	for i in 0..audio_content.length
		if audio_content[i] == "{" && i > count_start
			count_end = i - 1
			arr = arr + Array.new(1, audio_content[count_start..count_end])
			count_start = i
		elsif audio_content[count_start] == "{" && audio_content[i] == "}"
			count_end = i
			arr = arr + Array.new(1, audio_content[count_start..count_end])
			count_start = i + 1
		elsif i == audio_content.length && i > count_start
			count_end = i
			arr = arr + Array.new(1, audio_content[count_start..count_end])
		end
	end
	return arr
end

#=============================================================================
# SMSセクションカウント
# @param 	: mysql_cli
# @param 	: template_id
# @return 	: boolean
# @author 	: Hungnv
#=============================================================================
def hasSmsQues(mysql_cli, template_id)
	data = Array.new()
	query = <<EOS
	select
		count(t31.id)
	from
		t31_template_questions t31
    where
    	t31.template_id = '#{template_id}' and
    	t31.question_type in ('13','19') and
    	t31.del_flag = 'N'
EOS
	mysql_cli.query(query).each do | row |
		data = data + Array.new(1, row)
	end
	count = "0"
	data.each do | row |
		count = row[0]
	end
	if count == "0"
		return false
	else
		return true
	end
end

#=============================================================================
# SMS送信中スケジュールカウント
# @param 	: mysql_cli
# @param 	: schedule_id
# @return 	: boolean
# @author 	: Hungnv
#=============================================================================
def hasSmsSending(mysql_cli, schedule_id)
	data = Array.new()
	query = <<EOS
	select
		count(t83.id)
	from
		t83_outgoing_sms_statuses t83
    where
    	t83.schedule_id = '#{schedule_id}' and
    	t83.sms_status = 'sending' and
    	t83.del_flag = 'N'
EOS
	mysql_cli.query(query).each do | row |
		data = data + Array.new(1, row)
	end
	count = "0"
	data.each do | row |
		count = row[0]
	end
	if count == "0"
		return false
	else
		return true
	end
end

#=============================================================================
# SMS本文をファイルに保存
# @param 	: file_path
# @param 	: content
# @author 	: Hungnv
#=============================================================================
def smsContentToFile(file_path, content, allAuthItems, allSmsItems)
	smsFile = File.open(file_path, 'w')
	if content.include?"\r\n"
		content = content.gsub!("\r\n", "\n")
	end

	#挿入項目を取得する
	items = content.scan(/{(.*?)}/u)
	arr_item = Array.new()
	items.each do | row |
		unless arr_item.include? row[0]
			arr_item.push(row[0])
		end
	end
	idx = 1
	idx_str = ""
	arr_item.each do | row |
		idx = allAuthItems.length + 1
		allSmsItems.each do | r |
			if(row == r)
				break
			else
				idx += 1
			end
		end
		#### 仕様変更。$00、$01・・・$09、$10・・・$99と2桁になる。
		doll_str = idx < 10 ? "$0" : "$"
		idx_str = doll_str + idx.to_s
		tmp_item = "{" + row + "}"
		content = content.gsub!(tmp_item, idx_str)
	end
	#content = content.gsub!("\\", "￥")
	smsFile.print(content)
	smsFile.close
end
#=============================================================================
# Get sms service ID。送信ユーザ⓪の情報
# @param 	: mysql_cli
# @param 	: company_id
# @return 	: array
# @author 	: Hungnv
#=============================================================================
def getSmsAccountInfo(mysql_cli, company_id, sms_display_number)
	data = Array.new()
	query = <<EOS
	select
		service_id,
		url,
		group_id,
		user,
		pass,
		display_number,
		api_id
	from
		m08_sms_api_infos
    where
    	company_id = '#{company_id}' and
    	display_number = '#{sms_display_number}'
    and
        ((role_code = '30' and api_id != '#{$SMS_API_V2_VALUE}')
            or api_id = '#{$SMS_API_V2_VALUE}'
        )
    and
    	del_flag = 'N'   
EOS
	mysql_cli.query(query).each do | row |
		data = data + Array.new(1, row)
	end	
	return data
end

#=============================================================================
#　テンプレートの全質問を取得
# @param 	: mysql_cli
# @param	: schedule_id
# @return	: Mixed array|NULL
# @author 	: Hungnv
#=============================================================================
def getQuesByScheduleId(mysql_cli, schedule_id)
	data = Array.new()
	query = <<EOS
		select  question_title,
				question_no,
				question_type,
				recheck_flag,
				recheck_button_next,
				auth_item,
				auth_match_flag,
				sms_display_number
		from t61_question_histories
		where schedule_id = '#{schedule_id}'
		and del_flag = 'N'
		group by question_no;
EOS
	mysql_cli.query(query).each do | row |
		data = data + Array.new(1, row)
	end
	return data
end

###########################################
# 着信ログファイル取得
# @param 	: mysql_cli
# @param	: schedule_id
# @return 	: array
#　@author 	: Hungnv
###########################################
def getAnswerPos(mysql_cli, schedule_id)
	# Define answer of offset for each question type
	# QuesVoice 			Have no answer
	# QuesBasic 			Answer have one column (answer number)
	# QuesAuth 				If repeat flag is false, answer have one column (input value)
	#  						If repeat flag is true, answer have four columns (input value, > of repeat number, = of repeat number, < of repeat number)
	# QuesTel 				If repeat flag is false, answer have two column (input value)
	#  						If repeat flag is true, answer have two columns (input value, repeat number)
	# QuesTrans 			Have no answer
	# QuesRecord 			Have no answer
	# QuesCount				Answer have one column (count)
	# QuesEnd 				Have no answer
	# QuesTimeout 			Have no answer
	# QuesAuthChar 			If repeat flag is false, answer have one column (input value)
	#  						If repeat flag is true, answer have three columns (input value, = of repeat number, # of repeat number)
	# QuesSms 				Answer have one collumn
	quesVoiceCode = '1'
	quesBasicCode = '2'
	quesAuthCode = '3'
	quesTelCode = '4'
	quesTransCode = '5'
	quesRecordCode = '6'
	quesCountCode = '7'
	quesEndCode = '8'
	quesTimeoutCode = '9'
	quesAuthCharCode = '10'
	quesSmsCode = '13'
	quesSmsInputCode = '19'
	arr_answer_offset = {
		quesVoiceCode => 0,
		quesBasicCode => 1,
		quesAuthCode => {'0' => 1, '1' => 4},
		quesTelCode => {'0' => 1, '1' => 2},
		quesTransCode => 0,
		quesRecordCode => 0,
		quesCountCode => 1,
		quesEndCode => 0,
		quesTimeoutCode => 0,
		quesAuthCharCode => {'0' => 1, '1' => 3},
		quesSmsCode => 1,
		quesSmsInputCode => 3
	}
	# The first question
	current_pos = 1
	# array of answer position for earch question
	arr_answer_pos = {}
	# Get all the question of schedule
	questions = getQuesByScheduleId(mysql_cli, schedule_id)
	questions.each do | row |
		question_no = row[1]
		question_type = row[2]
		recheck_flag = row[3]
		if [quesAuthCode, quesTelCode, quesAuthCharCode].include? question_type
			count_column = arr_answer_offset[question_type][recheck_flag]
		else
			count_column = arr_answer_offset[question_type]
		end
		if count_column.to_i > 0
			arr_answer_pos[question_no] = current_pos
			current_pos += count_column.to_i
		elsif question_type == quesRecordCode
			arr_answer_pos[question_no] = 'trans_call_time'
		else
			arr_answer_pos[question_no] = ''
		end
	end
	return arr_answer_pos
end

#=============================================================================
#　スケジュールの情報を取得
# @param 	: mysql_cli
# @param	: schedule_id
# @return	: array|NULL
# @author 	: Hungnv
#=============================================================================
def getScheduleById(mysql_cli, schedule_id)
	data = Array.new()
	query = <<EOS
		select  id,
				company_id,
				template_id,
				list_id,
				list_ng_id,
				status
		from t20_out_schedules
		where id = '#{schedule_id}'
		and del_flag = 'N';
EOS
	mysql_cli.query(query).each do | row |
		data = data + Array.new(1, row)
	end
	return data
end

#認証項目を取得
def getAllAuthItem(mysql_cli, schedule_id)
	data = Array.new()
	query = <<EOS
			select 
    			distinct t31.auth_item
			from
				t20_out_schedules t20 
					left join 
				t31_template_questions t31 on t20.template_id = t31.template_id 
					and t31.question_type in('3', '10')
					and t31.del_flag = 'N'
			where
				t20.id = #{schedule_id} 
				and t20.del_flag = 'N'
			order by t31.question_no
EOS
	mysql_cli.query(query).each do | row |
		data = data + Array.new(1, row)
	end
	return data
end

#=============================================================================
# エスケープ変換用配列
# @param	: str
# @return	: str
#=============================================================================
ESCAPE_TABLE = {
  '&' => '\\&',
  '<' => '\\<',
  '>' => '\\>',
  '"' => '\\"',
  "'" => "\\'",
  ":" => "\\:",
  "/" => "\\/",
  "?" => "\\?",
  "#" => "\\#",
  "[" => "\\[",
  "]" => "\\]",
  "@" => "\\@",
  "!" => "\\!",
  "(" => "\\(",
  ")" => "\\)",
  "*" => "\\*",
  "+" => "\\+",
  "," => "\\,",
  ";" => "\\;",
  "="  => "\\="
}

#=============================================================================
# エスケープした値を返す
# @param	: str
# @return	: str
#=============================================================================
def escape_str(str)

    rt = str.gsub(/[&<>"':\/?#\[\]@!\(\)*+,;=]/, ESCAPE_TABLE)
    return rt
end

#=============================================================================
# 予約時間帯取得
# @param	: schedule_id
# @return	: array
#=============================================================================
def getScheduleTimeByScheduleId(mysql_cli, schedule_id)
	data = Array.new()
	query = <<EOS
				select 
					t21.time_start,
					t21.time_end
				from
					t21_out_times t21 
				where
					t21.schedule_id = '#{schedule_id}'
					and t21.del_flag = "N"
EOS
	mysql_cli.query(query).each do | row |
		data = data + Array.new(1, row)
	end
	return data
end