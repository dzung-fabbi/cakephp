# encoding: UTF-8
#=============================================================================
# Contents   : 着信拒否モデール
# Author     : Ascend Corp
# Since      : 2016/04/15        1.0
#=============================================================================

load File.join(File.dirname(__FILE__),'../config/AscCommon.rb')
class AscT19IncomingNgTel
	#=============================================================================
	#　初期設定
	#=============================================================================
	def initialize
		@common = AscCommon.new
		@mysql_cli = @common.connectDB
	end

	#=============================================================================
	#　着信拒否番号を取る
	# param : id　：　着信拒否リスト
	# return : array
	#=============================================================================
	def getTelNoByNgListId(id)
		data = Array.new()
		query = <<EOS
			select 
    			t19.tel_no
			from
			    t19_incoming_ng_tels t19
			where
			    t19.list_ng_id = '#{id}'
			    and t19.del_flag = 'N'

EOS
		@mysql_cli.query(query).each do | row |
			data = data + Array.new(1, row)
		end
		return data
	end
end
