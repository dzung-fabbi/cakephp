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
begin 
	schedule_no = ARGV[0]
	localPathSchedule = config[:local_schedule]
	localPathScheduleId = config[:local_schedule] + schedule_no
	localPathAutopoll = localPathScheduleId + '/'
	localPathIndata = localPathScheduleId + '/indata/'
	localPathAns = localPathIndata + 'ans_list/'
	localPathDial = localPathIndata + 'dial/'
	localPathPcm = localPathIndata + 'pcm_q/'
	localPathPcmVar = localPathIndata + 'pcm_var/'
	localPathSplist = localPathIndata + 'splist/'
	localPathSms = localPathIndata + 'sms/'
	if File.exists?(localPathPcm)
		FileUtils.rm_rf(localPathPcm)
	end
	
	FileUtils.mkdir_p(localPathScheduleId) unless File.exists?(localPathScheduleId)
	#`chmod 777 #{localPathScheduleId}`
	system("chmod 777 " + localPathScheduleId)
	FileUtils.mkdir_p(localPathIndata) unless File.exists?(localPathIndata)
	system("chmod 777 " + localPathIndata)
	FileUtils.mkdir_p(localPathDial) unless File.exists?(localPathDial)
	system("chmod 777 " + localPathDial)
	FileUtils.mkdir_p(localPathAns) unless File.exists?(localPathAns)
	system("chmod 777 " + localPathAns)
	FileUtils.mkdir_p(localPathPcm) unless File.exists?(localPathPcm)
	system("chmod 777 " + localPathPcm)
	FileUtils.mkdir_p(localPathPcmVar) unless File.exists?(localPathPcmVar)
	system("chmod 777 " + localPathPcmVar)
	FileUtils.mkdir_p(localPathSplist) unless File.exists?(localPathSplist)
	system("chmod 777 " + localPathSplist)
	FileUtils.mkdir_p(localPathSms) unless File.exists?(localPathSms)
	system("chmod 777 " + localPathSms)
rescue Exception=>e
	puts "err_create_folder"
	writeLog("err_create_folder : " + e.message)
	writeLog("エラー：設定フォルダを作成失敗")
	writeLog(e.backtrace.join("\n"))
	sendMailError(schedule_no.to_i)
	exit 9
end