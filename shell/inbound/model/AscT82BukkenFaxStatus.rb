# encoding: UTF-8
#=============================================================================
# Contents   : 着信設定モデール
# Author     : Ascend Corp
# Since      : 2016/10/06        1.0
#=============================================================================
load File.join(File.dirname(__FILE__),'../config/AscCommon.rb')
class AscT82BukkenFaxStatus
	#=============================================================================
	#　初期設定
	#=============================================================================
	def initialize
		@common = AscCommon.new
		@mysql_cli = @common.connectDB
	end

	#=============================================================================
	#　着信設定情報を取る
	# param : inbound_id
	# return : array
	#=============================================================================
	def getFaxInfoByInboundId(inbound_id)
		data = Array.new()
		query = <<EOS
		select 
			log_id,
			inbound_id,
			template_id,
			fax_question_no,
			fax_id,
			fax_status
		from
			t82_bukken_fax_statuses
		where
			inbound_id = '#{inbound_id}'
EOS
		@mysql_cli.query(query).each do | row |
			data = data + Array.new(1, row)
		end
		return data
	end

	#=============================================================================
	#　FAX送信ステータステーブルに更新
	# @param : log_id
	# @param : fax_id
	# @param : fax_status
	# @param : message
	# return : array
	#=============================================================================
	def updateStatus(log_id, fax_id, fax_status, message)
		data = Array.new()
		query = <<EOS
		update
			t82_bukken_fax_statuses set
			fax_status = '#{fax_status}',
			message = '#{message}',
			modified = now()
		where
			log_id = '#{log_id}' and
			fax_id = '#{fax_id}'
EOS
		@mysql_cli.query(query)
	end

	#=============================================================================
	#　FAX送信ステータステーブルにインサート
	# param : inbound_id
	# return : array
	#=============================================================================
	def insertFaxInfoFromLog(inbound_id, template_id, question_no, answer_pos)
		fax_id_pos = answer_pos.to_i + 4
		fax_answer_pos = "answer" + fax_id_pos.to_s
		query = <<EOS
		insert into t82_bukken_fax_statuses (log_id, inbound_id, template_id, fax_question_no, fax_id, fax_status, created)
		select 
			t81.id,
			t81.inbound_id,
			#{template_id},
			#{question_no},
			t81.#{fax_answer_pos},
			IF(t81.#{fax_answer_pos} IS NULL, '送信なし', if(t81.#{fax_answer_pos} = '', '送信なし','送信中')),
			now()
		from
			t81_incoming_results t81
		left join
			t82_bukken_fax_statuses t82
		on
			t81.id = t82.log_id and		
			t81.inbound_id = t82.inbound_id
		where
			t81.inbound_id = '#{inbound_id}' and
			(t82.template_id is null or t82.template_id <> '#{template_id}') and
			(t82.fax_question_no is null or t82.fax_question_no <> '#{question_no}') and
			(t81.#{fax_answer_pos} <> '' or t81.#{fax_answer_pos} is not null)
EOS
		@mysql_cli.query(query)
	end

end
