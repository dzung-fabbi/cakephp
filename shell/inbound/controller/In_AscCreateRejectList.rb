# encoding: UTF-8
#=============================================================================
# Contents   : 着信拒否リスト作成
# Author     : Ascend Corp
# Since      : 2016/04/15        1.0
#=============================================================================

load File.join(File.dirname(__FILE__),'../model/AscT19IncomingNgTel.rb')
load File.join(File.dirname(__FILE__),'../model/AscT13InboundListItem.rb')
load File.join(File.dirname(__FILE__),'../model/AscT17InboundTelList.rb')
load File.join(File.dirname(__FILE__),'../config/AscCommon.rb')
class AscCreateRejectList
	#=============================================================================
	#　初期設定
	#=============================================================================
	def initialize
		@ModelT13InboundListItem = AscT13InboundListItem.new
		@ModelT17InboundTelList = AscT17InboundTelList.new
		@ModelT19IncomingNgTel = AscT19IncomingNgTel.new
	end

	#=============================================================================
	#　着信拒否リストを作成
	# params 
	# 	file_path : ファイルのパス 
	# 	reject_list_id : 着信拒否リストID
	#   list_id : 着信リスト
	# 例　：　0312340001
	#      0312340002
	#      0312340003
	#=============================================================================
	def createRejectList(file_path, reject_list_id, list_id)
		csvFile = File.open(file_path, 'a:UTF-8')
		#着信拒否電話番号
		unless reject_list_id.blank?
			arr_reject = @ModelT19IncomingNgTel.getTelNoByNgListId(reject_list_id)
			arr_reject.each do | row |
				tel_no = row[0]
				csvFile.puts(NKF::nkf('-Wsm0', tel_no))
			end
		end
		#無効電話番号
		#unless list_id.blank?
		#	tel_col = @ModelT13InboundListItem.getColumnByItemCode(list_id, "tel_no")
		#	unless tel_col.blank?
		#		arr_muko = @ModelT17InboundTelList.getMukoTelByListId(list_id, tel_col)
		#		arr_muko.each do | row |
		#			tel_no = row[0]
		#			csvFile.puts(NKF::nkf('-Wsm0', tel_no))
		#		end
		#	end
		#end
		csvFile.close
	end
end