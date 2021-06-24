# encoding: UTF-8
#=============================================================================
# Contents   : インバウンドポートファイル作成
# Author     : Ascend Corp
# Since      : 2016/04/15        1.0
#=============================================================================

load File.join(File.dirname(__FILE__),'../config/AscCommon.rb')
class AscCreatePort
	#=============================================================================
	#　インバウンドポートを作成
	# params 
	# 	file_path　: ファイルのパス 
	# 	enosip_port　: enosipポート
	# 例　：　0-10 12 14
	#=============================================================================
	def createPort(file_path, enosip_port)
		csvFile = File.open(file_path, 'a:UTF-8')
		csvFile.puts(NKF::nkf('-Wsm0', enosip_port))
		csvFile.close
	end
end