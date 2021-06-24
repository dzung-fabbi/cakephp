# encoding: UTF-8
#=============================================================================
# Contents   : 着信電話番号モデール
# Author     : Ascend Corp
# Since      : 2016/04/15        1.0
#=============================================================================
load File.join(File.dirname(__FILE__),'../config/AscCommon.rb')
class AscT17InboundTelList
	#=============================================================================
	#　初期設定
	#=============================================================================
	def initialize
		@common = AscCommon.new
		@mysql_cli = @common.connectDB
	end

	#=============================================================================
	#　着信電話番号・認証照合、項目を取る
	# param : list_id
	#         str_col : 各カラム名
	# return : array
	#=============================================================================
	def getInfoListByListId(list_id, str_col)
		data = Array.new()
		query = <<EOS
			select 
    			#{str_col}
			from
			    t17_inbound_tel_lists t17
			where
			    t17.list_id = '#{list_id}'
			        and t17.del_flag = 'N'
			order by RAND()
EOS
		@mysql_cli.query(query).each do | row |
			data = data + Array.new(1, row)
		end
		return data
	end

	#=============================================================================
	#　音声合成項目内容情報を取る
	# param : list_id, 
	#         match_item_col　：　メイン項目カラム, 
	#         mix_item_col　：　音声合成項目カラム
	# return : array
	#=============================================================================
	def getInfoItemMix(list_id, match_item_col, mix_item_col)
		data = Array.new()
		query = <<EOS
					select 
						#{match_item_col},
						#{mix_item_col}	
					from 
						t17_inbound_tel_lists t17 
					where
						t17.list_id = '#{list_id}'
							and t17.del_flag = 'N'
EOS
		@mysql_cli.query(query).each do | arr |
			data = data + Array.new(1, arr)
		end
		return data
	end

	#=============================================================================
	#　無効電話番号取得
	# param : list_id, 
	#         tel_col　：　電話番号カラム
	# return : array
	#=============================================================================
	#def getMukoTelByListId(list_id, tel_col)
	#	data = Array.new()
	#	query = <<EOS
	#				select 
	#					#{tel_col}
	#				from 
	#					t17_inbound_tel_lists t17 
	#				where
	#					t17.list_id = '#{list_id}'
	#						and t17.muko_flag = 'Y'
	#						and t17.del_flag = 'N'
#EOS
	#	@mysql_cli.query(query).each do | arr |
	#		data = data + Array.new(1, arr)
	#	end
	#	return data
	#end
end
