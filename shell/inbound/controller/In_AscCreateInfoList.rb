# encoding: UTF-8
#=============================================================================
# Contents   : 着信リストファイル作成
# Author     : Ascend Corp
# Since      : 2016/04/14        1.0
#=============================================================================

load File.join(File.dirname(__FILE__),'../config/AscCommon.rb')
load File.join(File.dirname(__FILE__),'../model/AscT13InboundListItem.rb')
load File.join(File.dirname(__FILE__),'../model/AscT17InboundTelList.rb')
load File.join(File.dirname(__FILE__),'../model/AscT31TemplateQuestion.rb')
class AscCreateInfoList

	#=============================================================================
	#　初期設定
	#=============================================================================
	def initialize
		@ModelT13InboundListItem = AscT13InboundListItem.new
		@ModelT17InboundTelList = AscT17InboundTelList.new
		@ModelT31TemplateQuestion = AscT31TemplateQuestion.new
	end
	#=============================================================================
	#　ダイアルファイルを作成
	# 例 : 08011115555,000001,19800,19660208 - 電話番号あり
	#      ,000002,19800,20000320            - 電話番号無し
	#      (電話番号,照合項目,認証項目,SMS挿入項目)
	#=============================================================================

	def createColSelect(list_id, template_id)
		total_col = 0
		tel_col = @ModelT13InboundListItem.getColumnByItemCode(list_id, "tel_no")
		if tel_col.blank?
			str_col = "''"
		else
			str_col = tel_col
		end
		total_col = 1
		#照合項目を取る
		match_item = @ModelT31TemplateQuestion.getAuthMatchItemByTemplateId(template_id)
		match_col = @ModelT13InboundListItem.getColumnByItemName(list_id, match_item)
		#match_colで値を取得できた場合は照合項目を追加し、
		#値が取得できない場合は電話番号を追加(1列目と同じ値をコピー)する。
		#着信照合や文字列認証がない場合もカウントされるが以降のループを通らないため、影響なし
		unless match_col.blank?
			str_col = str_col + ", " + match_col
		else
			str_col = str_col + ", " + tel_col
		end
		
		total_col = total_col + 1

		#各認証カラムを取る
		str_auth_col = ""
		arr_auth_item = @ModelT31TemplateQuestion.getAuthItemByTemplateId(template_id)
		total_col = total_col + arr_auth_item.length
		isFirst = true
		arr_auth_item.each do | row |
			auth_item = row[0]
			auth_col = @ModelT13InboundListItem.getColumnByItemName(list_id, auth_item)
			if str_auth_col.blank? && isFirst
				str_auth_col = auth_col
				isFirst = false
			else
				str_auth_col = str_auth_col + ", " + auth_col
			end
		end
		#SMS挿入項目を取る
		str_sms_col = ""
		arr_sms_item = @ModelT31TemplateQuestion.getSmsItemNameByTemplateId(template_id)
		total_col = total_col + arr_sms_item.length
		sms_col_count = arr_sms_item.length
		isFirst = true
		arr_sms_item.each do | row |
			sms_item_col = @ModelT13InboundListItem.getColumnByItemName(list_id, row)
			if str_sms_col.blank? && isFirst
				str_sms_col = sms_item_col
				isFirst = false
			else
				str_sms_col = str_sms_col + ", " + sms_item_col
			end
		end

		unless str_auth_col.blank?
			str_col = str_col + ", " + str_auth_col
		end
		unless str_sms_col.blank?
			str_col = str_col + ", " + str_sms_col
		end
		arr_col = Array.new()
		#arr_col[0] : str_col
		#arr_col[1] : total collumn
		#arr_col[2] : total sms item collumn
		arr_col.push(str_col)
		arr_col.push(total_col)
		arr_col.push(sms_col_count)
		return arr_col
	end

	def createInfoList(file, list_id, template_id)
		csvFile = File.open(file, 'a:UTF-8')
		unless list_id.blank?
			#電話番号カラムを取る
			str_col = createColSelect(list_id, template_id)
			total_col = str_col[1].to_i
			sms_col_count = str_col[2].to_i
			#ダイアル情報を取って作成する
			arr_info = @ModelT17InboundTelList.getInfoListByListId(list_id, str_col[0])
			arr_info.each do | arr |
				line = ""
				for i in 0..arr.length
					if i == 0
						line = arr[i].to_s.gsub(/[^\d]/, '')
					elsif i < total_col - sms_col_count
						line = line + "," + arr[i].to_s.gsub(/[^\d]/, '')
					else
						line = line + "," + arr[i].to_s
					end
				end
				csvFile.puts(NKF::nkf('-Wsm0', line))
			end
		end
		csvFile.close
	end

	#=============================================================================
	#　転送ダイアルファイルを作成
	# 例 : 00100103011115555
	#      00100103011115555
	#      00100103011115555
	#=============================================================================
	def createTransList(file, template_id, prefix)
		csvFile = File.open(file, 'a:UTF-8')
		arr_info_trans = @ModelT31TemplateQuestion.getQuestionTransByTemplateId(template_id)
		trans_tel = ""
		trans_seat_num = "0"
		arr_info_trans.each do | arr |
			trans_tel = arr[0]
			trans_seat_num = arr[1] 
		end
		if trans_seat_num.to_i > 0
			for i in 1..trans_seat_num.to_i
				csvFile.puts(NKF::nkf('-Wsm0', prefix + trans_tel))
			end
		end
		csvFile.close
	end
end