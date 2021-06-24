# encoding: UTF-8
#=============================================================================
# Contents   : 着信設定モデール
# Author     : Ascend Corp
# Since      : 2016/04/15        1.0
#=============================================================================
load File.join(File.dirname(__FILE__),'../config/AscCommon.rb')
class AscT25Inbound
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
	def getInfoByInboundId(inbound_id)
		data = Array.new()
		query = <<EOS
		select 
			external_number,
			status,
			template_id,
			list_ng_id,
			list_id
		from
			t25_inbounds
		where
			id = '#{inbound_id}'
EOS
		@mysql_cli.query(query).each do | row |
			data = data + Array.new(1, row)
		end
		return data
	end

	#=============================================================================
	#　着信設定情報を取る
	# param : server_id
	# return : array
	#=============================================================================
	def getInfoInboundMessageByServerId(server_id)
		data = Array.new()
		query = <<EOS
			select 
				t25.id,
				t25.template_id,
				t25.list_id,
				t25.list_ng_id
			from
				t25_inbounds t25
					inner join
				m07_server_externals m07 ON t25.external_number = m07.external_number
					and m07.del_flag = 'N'
					and m07.in_server_id = '#{server_id}'
			where
				t25.status = '#{@common.getStatusInboundMessage}'
					and t25.del_flag = 'N'
EOS
		@mysql_cli.query(query).each do | row |
			data = data + Array.new(1, row)
		end
		return data
	end

	#=============================================================================
	#　録音着信設定情報を取る
	# param : server_id
	# return : array
	#=============================================================================
	def getInfoInboundRecordByServerId(server_id)
		data = Array.new()
		query = <<EOS
			select 
				t25.id
			from
				t25_inbounds t25
					inner join
				m07_server_externals m07 ON t25.external_number = m07.external_number					
					and m07.in_server_id = '#{server_id}'
					and m07.del_flag = 'N'
					inner join
				t31_template_questions t31 ON t25.template_id = t31.template_id
					and t31.question_type = '#{@common.getQuesRecordCode}'
					and t31.del_flag = 'N'
			where
				t25.cron_record_flag = 'N'
					and t25.del_flag = 'N'
EOS
		@mysql_cli.query(query).each do | row |
			data = data + Array.new(1, row)
		end
		return data
	end

	#=============================================================================
	#　クーロン録音フラグ更新
	# param : inbound_id
	# 
	#=============================================================================
	def updateCronRecordFlag(inbound_id)
		query = <<EOS
			update 
				t25_inbounds
			set
				cron_record_flag = 'Y'
			where
				id = '#{inbound_id}'
					and status = '#{@common.getStatusInboundEnd}'
					and del_flag = 'N'
EOS
		@mysql_cli.query(query)
	end

  #=============================================================================
  #　録音着信設定情報を取る
  # param : inbound_id
  # return : array
  #=============================================================================
  def getInfoInboundById(inbound_id)
    data = Array.new()
    query = <<EOS
    select 
        m02.company_name,
        t25.id,
        t25.inbound_no,
        t25.external_number,
        ifnull(t30.template_name, 'busy') as template,
        ifnull(t16.list_name, '設定なし') as list_name,
        ifnull(t16.tel_total, '') as tel_total,
        ifnull(t18.list_name, '設定なし') as ng_list_name,
        ifnull(t18.total, '') as ng_tel_total
    from
        t25_inbounds t25
            left join
        t30_templates t30 ON t25.template_id = t30.id
            and t30.del_flag = 'N'
            left join
        t16_inbound_call_lists t16 ON t25.list_id = t16.id
            and t16.del_flag = 'N'
            left join
        t18_incoming_ng_lists t18 ON t25.list_ng_id = t18.id
            and t18.del_flag = 'N'
            left join
        m02_companies m02 ON t25.company_id = m02.company_id
            and m02.del_flag = 'N'
    where
        t25.id = '#{inbound_id}'
EOS
    @mysql_cli.query(query).each do | row |
      data = data + Array.new(1, row)
    end
    return data
  end
  	
  	#=============================================================================
	# Fax送信中の着信設定を習得
	# return : array
	#=============================================================================
	def getFaxSending()
		data = Array.new()
		query = <<EOS
		select
			t82.id,
			t82.log_id,
			t82.inbound_id,
			t82.template_id,
			t82.fax_question_no,
			t82.fax_id,
			t25.status
		from
			t25_inbounds t25
        join
        	t82_bukken_fax_statuses t82
        on 
        	t25.id = t82.inbound_id
        where 
        	t25.bukken_fax_flag = '1'
        and 
        	t82.fax_status = '送信中'
        and
        	t25.del_flag = 'N'
        and
        	t82.del_flag = 'N'
EOS
		@mysql_cli.query(query).each do | row |
			data = data + Array.new(1, row)
		end
		return data
	end

  	#=============================================================================
	# Fax送信中の着信設定をカウント
	# return : array
	#=============================================================================
	def countFaxSendingByInboundId(inbound_id)
		data = Array.new()
		query = <<EOS
		select
			count(t25.id)
		from
			t25_inbounds t25
        join
        	t82_bukken_fax_statuses t82
        on 
        	t25.id = t82.inbound_id
        where
        	t25.id = '#{inbound_id}' 
        and
        	t25.bukken_fax_flag = '1'
        and 
        	t82.fax_status = '送信中'
        and
        	t25.del_flag = 'N'
        and
        	t82.del_flag = 'N'
EOS
		@mysql_cli.query(query).each do | row |
			data = data + Array.new(1, row)
		end
		return data
	end
	#=============================================================================
	# FAX送信ステータステーブルに更新
	# @param : log_id
	# @param : fax_id
	# @param : fax_status
	# @param : message
	# return : array
	#=============================================================================
	def updateFaxStatus(inbound_id)
		data = Array.new()
		query = <<EOS
		update
			t25_inbounds set
			bukken_fax_flag = '0',
			modified = now()
		where
			id = '#{inbound_id}'
EOS
		@mysql_cli.query(query)
	end
	#=============================================================================
	#　スケジュールの情報を取得
	# @param	: inbound_id
	# @return	: array|NULL
	# @author 	: Hungnv
	# @Since	: 2017/10/04
	#=============================================================================
	def getInboundById(inbound_id)
		data = Array.new()
		query = <<EOS
			select  id,
					company_id,
					template_id,
					list_id,
					list_ng_id,
					status,
					external_number
			from t25_inbounds
			where id = '#{inbound_id}'
			and del_flag = 'N';
EOS
		@mysql_cli.query(query).each do | row |
			data = data + Array.new(1, row)
		end
		return data
	end
end
