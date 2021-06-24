# encoding: UTF-8
#=============================================================================
# Contents   : Common
# Author     : Ascend Corp
# Since      : 2016/04/14        1.0
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

load File.join(File.dirname(__FILE__),'AscConfig.rb')

class AscCommon
	#=============================================================================
	#　初期設定
	#=============================================================================
	def initialize
		ascConfigIns = AscConfig.new
		ascConfigIns.instance_eval File.read File.join(File.dirname(__FILE__),'AscConfig.ini')
		@config = ascConfigIns.getData
	end

	def localPathInbound
		return @config[:local_path_inbound]
	end

	def remotePathInbound
		return @config[:remote_path_inbound]
	end

	def remotePath
		return @config[:remote_path]
	end

	def callModulePathInbound
		return @config[:call_module_path_inbound]
	end

	def getQuesVoiceCode
		return @config[:ques_voice]
	end

	def getQuesBasicCode
		return @config[:ques_basic]
	end

	def getQuesAuthCode
		return @config[:ques_auth]
	end

	def getQuesTelCode
		return @config[:ques_tel]
	end

	def getQuesTransCode
		return @config[:ques_trans]
	end

	def getQuesRecordCode
		return @config[:ques_record]
	end

	def getQuesCountCode
		return @config[:ques_count]
	end

	def getQuesEndCode
		return @config[:ques_end]
	end

	def getQuesTimeoutCode
		return @config[:ques_timeout]
	end

	def getQuesAuthCharacterCode
		return @config[:ques_auth_character]
	end

	def getQuesInboundCollationCode
		return @config[:ques_inbound_collation]
	end

	def getQuesInboundSmsInputCode
		return @config[:ques_inbound_sms_input]
	end

	def getQuesPropertyCode
		return @config[:ques_property]
	end

	def getQuesPropertySearchCode
		return @config[:ques_property_search]
	end

	def getQuesFaxCode
		return @config[:ques_fax]
	end

	def getQuesInboundSmsCode
		return @config[:ques_inbound_sms]
	end

	def getServerInboundType
		return @config[:server_inbound_type]
	end

	def getDatabaseIp
		return @config[:database_ip]
	end

	def getDatabaseId
		return @config[:database_id]
	end

	def getDatabasePass
		return @config[:database_pass]
	end

	def getDatabaseSchema
		return @config[:database_schema]
	end

	def getStatusInboundMessage
		return @config[:status_inbound_message]
	end

	def getStatusInboundBusy
		return @config[:status_inbound_busy]
	end

	def getStatusInboundEnd
		return @config[:status_inbound_end]
	end

	def getExtensionsConfPath
		return @config[:extensions_conf_path]
	end

	def getFaxApiUrl
		return @config[:fax_api_url]
	end

	def getFaxApiToken
		return @config[:fax_api_token]
	end

	def getPropertySearchMax
		return @config[:property_search_max]
	end

	def getPropertySynthUrl
		return @config[:property_synth_url]
	end

	def getPropertySynthCustomerId
		return @config[:property_synth_customer_id]
	end

	def getPropertySynthUserId
		return @config[:property_synth_user_id]
	end

	def getPropertySynthUserPassword
		return @config[:property_synth_user_password]
	end

	#=============================================================================
	#　データベース接続
	#=============================================================================
	def connectDB
		db_ip = @config[:database_ip]
		db_id = @config[:database_id]
		db_pass = @config[:database_pass]
		db_schema = @config[:database_schema]
		mysql_cli = Mysql.connect(db_ip, db_id, db_pass, db_schema)
		mysql_cli.charset = "utf8"
		return mysql_cli
	end

	#=============================================================================
	#　ログ
	#=============================================================================
	def writeLog(str)
		path_log =  @config[:local_log_path]
		FileUtils.mkdir_p(path_log) unless File.exists?(path_log)
		file_name = path_log  + "/" + Time.now.strftime("%Y%m%d")+".log"
		unless File.file?(file_name)
			folder_log = File.new(file_name, "w")
			system("chmod 777 " + file_name)
		end
		file_log = File.open(file_name,'a:UTF-8')
		file_log.puts "["+Time.now.strftime("%Y/%m/%d %H:%M:%S")+"] "+str
		file_log.close
	end
	
  ###########################################
  #
  # ログファイル名を取得
  #
  ###########################################
  def getLogFileName()
    localPathLog = @config[:local_log_path]
    FileUtils.mkdir_p(localPathLog) unless File.exists?(localPathLog)
    return localPathLog + "/" + Time.now.strftime("%Y%m%d")+".log"
  end
	#=============================================================================
	#　フォルダ・ファイル作成
	#=============================================================================
	def createFolder(path)
		FileUtils.mkdir_p(path) unless File.exists?(path)
		system("chmod 777 " + path)
	end
	
	def createFile(path)
		csvFile = File.open(path, 'w')
		csvFile.close
		system("chmod 777 " + path)
	end
	
	#=============================================================================
	#　メール
	#=============================================================================
	class AscMailer < ActionMailer::Base
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
			}
		end

		def sendMail(to, from, subject, body, file_path, file_name)
			initMail('smtp.office365.com', 'ascend-corp.co.jp', 'astar_report@ascend-corp.co.jp', 'Fj2Lp=ntXygn-N?m2Z3VCs')
			unless file_path.blank?
				attachments[file_name] = {
					:content => File.read(file_path, :mode => 'rb'),
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

	def execSendMail(to, from, subject, body, file_path, file_name)
		AscMailer.sendMail(to, from, subject, body, file_path, file_name).deliver
	end
	
	def execSendMailBackup(to, from, subject, body, file_path, file_name)
   AscMailer.send_mail_backup(to, from, subject, body, file_path, file_name).deliver
 end

 
def sendMailError(inbound_id)
#   to = ["robocall-alert@ascend-corp.co.jp"]
  to = ["hayabusa_dev@ascend-corp.co.jp"]
  from = "astar_report@ascend-corp.co.jp"
  subject = "【はやぶさ】(GS-DEV環境)インバウンドエラー"
  body = "お疲れ様です。\r\nエラーが発生しました。\r\n"
  body = body + "詳細は下記資料と添付ファイルを確認し、ご対応お願いします。\r\n"
  body = body + "※資料の場所：\\\\10.101.0.231\\ascend-sjk\\案件フォルダ\\hayabusa_team\\troubleshoot\r\n"

  if inbound_id.blank?
    body = body + "・区分: クーロン\r\n"
  else
    query = <<EOS
        select 
            m02.company_name,
            t25.id,
            t25.inbound_no,
            t25.external_number,
            ifnull(t30.template_name, 'busy') as template,
            ifnull(t16.list_name, '設定なし') as list_name,
            ifnull(t16.tel_total, '') as tel_total,
            ifnull(t18.list_name, '設定なし') as ng_list_name,
            ifnull(t18.total, '') as ng_tel_total
        from
            t25_inbounds t25
                left join
            t30_templates t30 ON t25.template_id = t30.id
                and t30.del_flag = 'N'
                left join
            t16_inbound_call_lists t16 ON t25.list_id = t16.id
                and t16.del_flag = 'N'
                left join
            t18_incoming_ng_lists t18 ON t25.list_ng_id = t18.id
                and t18.del_flag = 'N'
                left join
            m02_companies m02 ON t25.company_id = m02.company_id
                and m02.del_flag = 'N'
        where
            t25.id = '#{inbound_id}' and t25.del_flag = 'N'
EOS
    body = body + "・区分: 画面\r\n"
    mysql_cli = connectDB
    mysql_cli.charset = "utf8"
    mysql_cli.query(query).each do | row |
      body = body + "・会社名: " + row[0].to_s + "\r\n"
      body = body + "・スケジュールID: " + row[1].to_s + "\r\n"
      body = body + "・スケジュールNO: " + row[2].to_s + "\r\n"
      body = body + "・着信先番号: " + row[3].to_s + "\r\n"
      body = body + "・テンプレート名: " + row[4].to_s + "\r\n"
      body = body + "・着信リスト名: " + row[5].to_s + "\r\n"
      body = body + "・着信リスト件数: " + row[6].to_s + "\r\n"
      body = body + "・着信拒否リスト名: " + row[7].to_s + "\r\n"
      body = body + "・着信拒否リスト件数: " + row[8].to_s + "\r\n"
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
    execSendMail(to, from, subject, work_body, logFilePath, logFileName)
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
    	execSendMailBackup(to, from, subject, body, logFilePath, logFileName)
    	writeLog("メールする　：　OK")
    rescue Exception =>e
    	writeLog("[SendMailError]Gmailでメール送信失敗")
    end
  end
end

	#=============================================================================
	#　メール宛先設定
	#=============================================================================
	def getListMail()
		# listMail = ["system@ascend-corp.co.jp"]
		listMail = ["hayabusa_dev@ascend-corp.co.jp"]
		return listMail
	end

	#=============================================================================
	#　音声ファイル作成
	#=============================================================================
	def createFilePcmByAudioId(path, filename, audio_id)
		mysql_cli = connectDB
		path_pcm = path + "/" + filename
		query = <<EOS
			select 
				file_pcm_contents
			from
				t89_manage_files
			where
				id = '#{audio_id}'
EOS
		mysql_cli.query(query).each do | row |
			File.binwrite(path_pcm, row[0])
		end
	end

	#=============================================================================
	#　音声合成ファイル作成(aitalk)
	#=============================================================================
	def createFilePcmByTextAitalk(path, filename, text)
		if text.blank?
			path_pcm = path + "/" + filename
			pcmFile = File.open(path_pcm, 'w')
			pcmFile.close
		else
			response = Curl::Easy.http_post("http://webapi.aitalk.jp/webapi/v1/ttsget.php",
												Curl::PostField.content('username', @config[:ai_user]),
												Curl::PostField.content('password', @config[:ai_pass]),
												Curl::PostField.content('text', text),
												Curl::PostField.content('speaker_id', @config[:ai_speaker])
											)
			path_wav = path + "/tmp.wav"
			path_pcm = path + "/" + filename
			pcmFile = File.open(path_wav, 'w')
			pcmFile.puts(response.body_str)
			pcmFile.close
			system("sox #{path_wav} -b 8 -c 1 -r 8000 -t ul #{path_pcm}")
			File.delete(path_wav)
		end
	end
	

	#=============================================================================
	#　音声合成ファイル作成(nttit)
	#=============================================================================
	def createFilePcmByText(path, filename, text, speaker, from = nil)
		if text.blank?
			path_pcm = path + "/" + filename
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
					# 規定回数異常失敗した場合は、例外を投げる
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
			path_pcm = path + "/" + filename
			File.binwrite(path_pcm, Base64.decode64(response.body))
		end
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
	# SMS本文をファイルに保存
	# @param 	: file_path
	# @param 	: content
	# @author 	: Hungnv
	#=============================================================================
	def smsContentToFile(file_path, content, smsItemIndex)
		smsFile = File.open(file_path, 'w')
		if content.include?"\r\n"
			content = content.gsub!("\r\n", "\n")
		end
		idx = 0
		smsIdx = 0
		smsItemIndex.each do | row |
			#SMS挿入項目を存在する場合
			if smsItemIndex.length > 1
				#SMS挿入項目の始めてのindex
				if idx == 0
					smsIdx = row
				else
					#SMS挿入項目を置換する。例：　{名前} -> $3,.....
					#### 仕様変更。$00、$01・・・$09、$10・・・$99と2桁になる。
					doll_str = smsIdx < 10 ? "$0" : "$"
					idx_str = doll_str + smsIdx.to_s
					tmp_item = "{" + row + "}"
					#パターンが見つからない場合の挙動の違いによりgsubに変更
					#gsub:置換するパターンが見つからない場合、処理対象文字列に変化なし
					#gsub!:置換するパターンが見つからない場合、Nilになる
					content = content.gsub(tmp_item, idx_str)
					smsIdx = smsIdx + 1
				end
			end
			idx = idx + 1
		end
		#content = content.gsub!("\\", "￥")
		smsFile.print(content)
		smsFile.close
	end

	#=============================================================================
	# エスケープした値を返す
	# @param	: str
	# @return	: str
	#=============================================================================
	def escape_str(str)
	    rt = str.gsub(/[&<>"':\/?#\[\]@!\(\)*+,;=]/, ESCAPE_TABLE)
    	return rt
	end
end
