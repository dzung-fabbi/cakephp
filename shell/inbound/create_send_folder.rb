# encoding: UTF-8
#=============================================================================
# Contents   : フォルダ作成・転送
# Author     : Ascend Corp
# Param      : server_id             サーバーID
#              inbound_id            インバウンドID   
#              external_number       外線番号
#              template_id           テンプレートID
#              list_ng_id            着信拒否ID
#              list_id               着信リストID
# Since      : 2016/04/15        1.0
#=============================================================================
load File.join(File.dirname(__FILE__),'config/AscCommon.rb')
load File.join(File.dirname(__FILE__),'controller/In_AscCreateFolder.rb')
load File.join(File.dirname(__FILE__),'controller/In_AscCreateConfig.rb')
load File.join(File.dirname(__FILE__),'controller/In_AscCreateInfoList.rb')
load File.join(File.dirname(__FILE__),'controller/In_AscCreateRejectList.rb')
load File.join(File.dirname(__FILE__),'controller/In_AscCreatePort.rb')
load File.join(File.dirname(__FILE__),'controller/In_AscCreateAns.rb')
load File.join(File.dirname(__FILE__),'controller/In_AscCreateOutPcm.rb')
load File.join(File.dirname(__FILE__),'controller/In_AscCreateSplist.rb')
load File.join(File.dirname(__FILE__),'controller/In_AscSendFolder.rb')
load File.join(File.dirname(__FILE__),'controller/In_AscInboundSetup.rb')
load File.join(File.dirname(__FILE__),'controller/In_AscCreateHistory.rb')

begin
	#パラメーターを取る
	company_id = ARGV[0]
	server_id = ARGV[1]
	inbound_id = ARGV[2]
	# ARGV[3] is ASCII-8BIT
	# And external_number is frozen String.
	# So copy the arg and convert "utf-8".
	external_number_work = ARGV[3]
	external_number = external_number_work.dup
	external_number.force_encoding("UTF-8")

	template_id = ARGV[4]
	list_ng_id = ARGV[5]
	list_id = ARGV[6]
	enosip_port = ARGV[7]
	prefix = ARGV[8]
	#クラス初期
	ConfigCommon = AscCommon.new
	ClassCreateFolder = AscCreateFolder.new
	ClassCreateConfig = AscCreateConfig.new
	ClassCreateInfoList = AscCreateInfoList.new
	ClassCreateRejectList = AscCreateRejectList.new
	ClassCreatePort = AscCreatePort.new
	ClassCreateAns = AscCreateAns.new
	ClassCreateSplist = AscCreateSplist.new
	ClassCreateOutPcm = AscCreateOutPcm.new
	ClassSendFolder = AscSendFolder.new
	ClassCreateHistory = AscCreateHistory.new
	#フォルダ・indataフォルダ作成
	ConfigCommon.writeLog("[#{inbound_id}]着信番号 : #{external_number.to_s}, インバウンドNO : #{inbound_id} - フォルダ作成・転送開始")
	ClassCreateFolder.localPathSchedule(inbound_id)
	ClassCreateFolder.localPathIndata
	ConfigCommon.writeLog("[#{inbound_id}]フォルダ・indataフォルダ作成 : OK")
	ClassCreateFolder.localPathDial
	ConfigCommon.writeLog("[#{inbound_id}]dialフォルダ作成 : OK")
	ClassCreateFolder.localPathCsv
	ConfigCommon.writeLog("[#{inbound_id}]csvフォルダ作成 : OK")
	ClassCreateFolder.localPathRec
	ConfigCommon.writeLog("[#{inbound_id}]録音フォルダ作成 : OK")
	ClassCreateFolder.localPathSms
	ConfigCommon.writeLog("[#{inbound_id}]smsフォルダー : OK")
	#コンフィグファイル作成
	file_config = ClassCreateFolder.localPathConfig

	#コンフィグファイル作成(object.rental2向け)
	file_config_rental2 = ClassCreateFolder.localPathRental2Config

	ClassCreateConfig.createConfig(file_config, company_id, inbound_id, template_id, external_number, file_config_rental2)
	ConfigCommon.writeLog("[#{inbound_id}]コンフィグファイル作成 : OK")
	#情報リスト作成
	file_info_list = ClassCreateFolder.localPathInfoList
	ClassCreateInfoList.createInfoList(file_info_list, list_id, template_id)
	ConfigCommon.writeLog("[#{inbound_id}]情報リスト作成 : OK")
	#転送リスト作成
	file_trans_list = ClassCreateFolder.localPathTransList
	ClassCreateInfoList.createTransList(file_trans_list, template_id, prefix)
	ConfigCommon.writeLog("[#{inbound_id}]転送リスト作成 : OK")
	#着信ポート番号作成
	file_inbound_port = ClassCreateFolder.localPathPort
	ClassCreatePort.createPort(file_inbound_port, enosip_port)
	ConfigCommon.writeLog("[#{inbound_id}]着信ポート番号作成 : OK")
	#着信拒否リスト作成
	file_reject = ClassCreateFolder.localPathRejectList
	ClassCreateRejectList.createRejectList(file_reject, list_ng_id, list_id)
	ConfigCommon.writeLog("[#{inbound_id}]着信拒否リスト作成 : OK")
	#回答リスト作成
	file_ans = ClassCreateFolder.localPathAns
	ClassCreateAns.createFileAns(file_ans, template_id)
	ConfigCommon.writeLog("[#{inbound_id}]回答リスト作成 : OK")

	#対話音声
	file_pcm_q = ClassCreateFolder.localPathPcmQ
	ClassCreateOutPcm.createFilePcm(file_pcm_q, template_id)
	ClassCreateOutPcm.createFilePcmTrans(ConfigCommon.localPathInbound, file_pcm_q, template_id)
	file_pcm_var = ClassCreateFolder.localPathPcmVar
	ClassCreateOutPcm.createFilePcmVar(file_pcm_var, template_id, list_id)
	ConfigCommon.writeLog("[#{inbound_id}]対話音声 : OK")

	#対話リスト
	file_splist = ClassCreateFolder.localPathSplist
	ClassCreateSplist.createSplist(file_splist, template_id, list_id, inbound_id)
	ConfigCommon.writeLog("[#{inbound_id}]対話リスト : OK")
	#フォルダ転送
	ClassSendFolder.execSendFolder(server_id, inbound_id)
	ConfigCommon.writeLog("[#{inbound_id}]フォルダ転送 : OK")
	#履歴追加
	ClassCreateHistory.insertInboundHistory(inbound_id)
	ConfigCommon.writeLog("[#{inbound_id}]履歴追加 : OK")
	
	ConfigCommon.writeLog("[#{inbound_id}]着信番号 : #{external_number.to_s}, インバウンドNO : #{inbound_id} - フォルダ作成・転送終了")
rescue Exception => e
	puts "error"
	ConfigCommon.writeLog(e.backtrace.join("\n"))
	ConfigCommon.sendMailError(inbound_id.to_i)
	exit 9
end
