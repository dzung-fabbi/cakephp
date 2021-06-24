# encoding: UTF-8
#=============================================================================
# Contents   : 転送ファイル
# Author     : Ascend Corp
# Since      : 2016/04/14        1.0
#=============================================================================

load File.join(File.dirname(__FILE__),'../config/AscCommon.rb')
load File.join(File.dirname(__FILE__),'../model/AscM07ServerExternal.rb')
load File.join(File.dirname(__FILE__),'../model/AscT25Inbound.rb')
load File.join(File.dirname(__FILE__),'../model/AscT31TemplateQuestion.rb')

class AscGetTransPort
	#=============================================================================
	#　初期設定
	#
	#=============================================================================
	def initialize
		@ConfigCommon = AscCommon.new
		@ModelM07ServerExternal = AscM07ServerExternal.new
		@ModelT25Inbound = AscT25Inbound.new
		@ModelT31TemplateQuestion = AscT31TemplateQuestion.new
	end

	###########################################
	# 転送port
	# param : inbound_id
	#
	###########################################
	def getTransPort(inbound_id)
		@ConfigCommon.writeLog("inbound_id : " + inbound_id)
		arr_trans_port = Array.new()
		arr_port = Array.new()
		trans_seat_num = 0
		arr_info_inbound = @ModelT25Inbound.getInfoByInboundId(inbound_id)
		arr_info_inbound.each do | arr_inbound |
			external_number = arr_inbound[0]
			template_id = arr_inbound[2]
			port_txt = @ModelM07ServerExternal.getPortByExternal(external_number)
			arr_info_trans = @ModelT31TemplateQuestion.getQuestionTransByTemplateId(template_id)
			arr_info_trans.each do | arr_trans |
				trans_seat_num = arr_trans[1]
				@ConfigCommon.writeLog("trans_seat_num : " + trans_seat_num)
			end
			port_txt.split(" ").each do | str |
				if str.split("-").length == 1
					arr_port = arr_port + Array.new(1, str.to_i + 200)
				elsif str.split("-").length == 2
					port_start = str.split("-")[0]
					port_end = str.split("-")[1]
					for num in port_start.to_i..port_end.to_i
						arr_port = arr_port + Array.new(1, num.to_i + 200)
					end
				end
			end
		end
		@ConfigCommon.writeLog("arr_port : " + arr_port.to_s)
		arr_trans_port = arr_port.last(trans_seat_num.to_i)
		@ConfigCommon.writeLog("arr_trans_port : " + arr_trans_port.to_s)
		return arr_trans_port
	end

end