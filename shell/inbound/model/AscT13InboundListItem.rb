# encoding: UTF-8
#=============================================================================
# Contents   : 着信リスト項目モデール
# Author     : Ascend Corp
# Since      : 2016/04/15        1.0
#=============================================================================
load File.join(File.dirname(__FILE__),'../config/AscCommon.rb')
class AscT13InboundListItem
	#=============================================================================
	#　初期設定
	#=============================================================================
	def initialize
		@common = AscCommon.new
		@mysql_cli = @common.connectDB
	end

	#=============================================================================
	#　リストID、項目コードより対象リストカラムを取る
	# param : list_id, 
	#         item_code
	# return : column
	#=============================================================================
	def getColumnByItemCode(list_id, item_code)
		column = ""
		query = <<EOS
			select 
			    t13.column
			from
			    t13_inbound_list_items t13
			where
			    t13.list_id = '#{list_id}'
			    	and t13.item_code = '#{item_code}'
			    	and t13.del_flag = 'N'
EOS
		@mysql_cli.query(query).each do | row |
			column = row[0]
		end
		return column
	end

	#=============================================================================
	#　リストID、項目名より対象リストカラムを取る
	# param : list_id, 
	#         item_name
	# return : column
	#=============================================================================
	def getColumnByItemName(list_id, item_name)
		column = ""
		query = <<EOS
			select 
			    t13.column
			from
			    t13_inbound_list_items t13
			where
			    t13.list_id = '#{list_id}'
			    	and t13.item_name = '#{item_name}'
			    	and t13.del_flag = 'N'
EOS
		@mysql_cli.query(query).each do | row |
			column = row[0]
		end
		return column
	end
end
