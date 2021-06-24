# encoding: UTF-8
#=============================================================================
# Contents   : ansファイル作成
# Author     : Ascend Corp
# Since      : 2016/04/15        1.0
#=============================================================================

load File.join(File.dirname(__FILE__),'../config/AscCommon.rb')
load File.join(File.dirname(__FILE__),'../model/AscT56InboundListHistory.rb')
load File.join(File.dirname(__FILE__),'../model/AscT57InboundTelHistory.rb')
load File.join(File.dirname(__FILE__),'../model/AscT58InboundListNgHistory.rb')
load File.join(File.dirname(__FILE__),'../model/AscT59InboundTelNgHistory.rb')
load File.join(File.dirname(__FILE__),'../model/AscT63InboundTemplateHistory.rb')
load File.join(File.dirname(__FILE__),'../model/AscT64InboundQuestionHistory.rb')
load File.join(File.dirname(__FILE__),'../model/AscT65InboundButtonHistory.rb')

class AscCreateHistory
	#=============================================================================
	#　初期設定
	#=============================================================================
	def initialize
		@ConfigCommon = AscCommon.new
		@ModelT56InboundListHistory = AscT56InboundListHistory.new
		@ModelT57InboundTelHistory = AscT57InboundTelHistory.new
		@ModelT58InboundListNgHistory = AscT58InboundListNgHistory.new
		@ModelT59InboundTelNgHistory = AscT59InboundTelNgHistory.new
		@ModelT63InboundTemplateHistory = AscT63InboundTemplateHistory.new
		@ModelT64InboundQuestionHistory = AscT64InboundQuestionHistory.new
		@ModelT65InboundButtonHistory = AscT65InboundButtonHistory.new
	end

	#=============================================================================
	#　inbound履歴追加
	# params : inbound_id
	# 
	#=============================================================================
	def insertInboundHistory(inbound_id)
		@ModelT56InboundListHistory.insertInboundListHistory(inbound_id)
		@ModelT57InboundTelHistory.insertInboundTelHistory(inbound_id)
		@ModelT58InboundListNgHistory.insertInboundListNgHistory(inbound_id)
		@ModelT59InboundTelNgHistory.insertInboundTelNgHistory(inbound_id)
		@ModelT63InboundTemplateHistory.insertInboundTemplateHistory(inbound_id)
		@ModelT64InboundQuestionHistory.insertInboundQuestionHistory(inbound_id)
		@ModelT65InboundButtonHistory.insertInboundButtonHistory(inbound_id)
	end
end