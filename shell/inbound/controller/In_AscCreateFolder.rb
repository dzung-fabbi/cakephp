# encoding: UTF-8
#=============================================================================
# 
#=============================================================================
load File.join(File.dirname(__FILE__),'../config/AscCommon.rb')
class AscCreateFolder
	#=============================================================================
	#　初期設定
	#=============================================================================
	def initialize
		@ConfigCommon = AscCommon.new
		@myslq_cli = @ConfigCommon.connectDB
		#ロカールパース
		@local_path = @ConfigCommon.localPathInbound
	end
	
	#=============================================================================
	#　フォルダ・ファイル作成
	#=============================================================================
	
	def localPathSchedule(inbound_id)
		inbound_no = "000000".slice(1..6-inbound_id.to_s.length) + inbound_id.to_s
		@local_path_inbound = @local_path + "/" + inbound_no.to_s		
		@ConfigCommon.createFolder(@local_path_inbound)
	end

	def localPathConfig
		file_config = @local_path_inbound + '/autopoll.conf'
		@ConfigCommon.createFile(file_config)
		return file_config
	end

	def localPathRental2Config
		file_config = @local_path_inbound + '/rental2.conf'
		@ConfigCommon.createFile(file_config)
		return file_config
	end


	def localPathInfoList
		file_info_list = @local_path_inbound + '/inbound_info_list.txt'
		@ConfigCommon.createFile(file_info_list)
		return file_info_list
	end

	def localPathRejectList
		file_reject_list = @local_path_inbound + '/inbound_reject_list.txt'
		@ConfigCommon.createFile(file_reject_list)
		return file_reject_list
	end

	def localPathPort
		file_port = @local_path_inbound + '/inbound_port.txt'
		@ConfigCommon.createFile(file_port)
		return file_port
	end
	
	def localPathIndata
		@local_path_indata = @local_path_inbound + '/indata'
		@ConfigCommon.createFolder(@local_path_indata)
	end

	def localPathCsv
		@local_path_csv = @local_path_inbound + '/csv'
		@ConfigCommon.createFolder(@local_path_csv)
	end

	def localPathRec
		@local_path_csv = @local_path_inbound + '/rec'
		@ConfigCommon.createFolder(@local_path_csv)
	end
	
	def localPathAns
		local_path_ans = @local_path_indata + '/ans_list'
		@ConfigCommon.createFolder(local_path_ans)
		file_ans = local_path_ans + '/1_ans.txt'
		@ConfigCommon.createFile(file_ans)
		return file_ans
	end
	
	def localPathPcmQ
		local_path_pcm_q = @local_path_indata + '/pcm_q'
		@ConfigCommon.createFolder(local_path_pcm_q)
		return local_path_pcm_q
	end

	def localPathSms
		local_path_sms = @local_path_indata + '/sms'
		@ConfigCommon.createFolder(local_path_sms)
		return local_path_sms
	end
	
	def localPathPcmVar
		local_path_pcm_var = @local_path_indata + '/pcm_var'
		@ConfigCommon.createFolder(local_path_pcm_var)
		return local_path_pcm_var
	end
	
	def localPathSplist
		local_path_splist = @local_path_indata + '/splist'
		@ConfigCommon.createFolder(local_path_splist)
		file_splist = local_path_splist + '/1_splist.txt'
		@ConfigCommon.createFile(file_splist)
		return file_splist
	end

	def localPathDial
		@local_path_dial = @local_path_indata + '/dial'
		@ConfigCommon.createFolder(@local_path_dial)
	end

	def localPathTransList
		file_trans_list = @local_path_dial + '/trans_list.txt'
		@ConfigCommon.createFile(file_trans_list)
		return file_trans_list
	end
	
end
