#!/bin/bash
###########################################################
# dumpファイルをNASへコピーする
# エラー発生時はメールで送信する
###########################################################

#### マウントディレクトリ空き容量閾値 KBで記載 100GB=104857600KB
LIMIT=104857600

#### アラートメール送信先
TO_ADDRESS="nogiwa@ascend-corp.co.jp;hayabusa_dev@ascend-corp.co.jp"

HOSTNAME=`hostname`
DUMP_LOG_DIR=/tmp
CURRENT_DIR=/home/ftpuser/robo
LOG_FILE=backup.log

#### 1.dump処理

SCHEMA=$1

DB_USER=$2
DB_PASS=$3

vardate=`date +%Y%m%d%H%M`
dirdate=`date +%Y%m%d`
dump_file=${SCHEMA}_${vardate}_sin.gz
dump_log=dump_log_${vardate}_sin.log

echo `date` "START: Dump "${dump_file}

# all dump
ionice -c 2 -n 7 nice -n 19 mysqldump -u$DB_USER -p$DB_PASS $SCHEMA --single-transaction --hex-blob --quick --log-error=${DUMP_LOG_DIR}/$dump_log | ionice -c 2 -n 7 nice -n 1 gzip > ${DUMP_LOG_DIR}/${dump_file}

# 当日ログファイルのサイズ取得
size=`wc -c /tmp/${dump_log} | awk '{print $1}'`

#### 2.dumpファイルコピー

if [ ${size} == 0 ]; then
	echo "バックアップ正常終了(エラーログ無し)"

	# 空き容量チェック
	df=`df | grep /mnt/gsrc-nas01`
	available=`echo ${df} | cut -d " " -f 3`

	# 空き領域がリミットに達した場合はエラーメールを送信し、処理を中止する
	if [ $LIMIT -ge $available ]; then
		df -h > ${LOG_FILE}

		subject="【はやぶさ】エラー：(警告)マウント領域の空き容量が閾値に達しました"
		mail_body=`echo -e "対象サーバー：${HOSTNAME}\r\n"`
		mail_body=${mail_body}`echo -e "閾値：${LIMIT}KB\r\n"`
		mail_body=${mail_body}`echo -e "現在値(空き容量)：${available}KB\r\n"`
		mail_body=${mail_body}`echo -e "対応をお願いします"`
		./gs_sendmail.sh ${TO_ADDRESS} ${subject} ${mail_body} ${LOG_FILE} ${CURRENT_DIR}

		# 添付ファイルの削除
		rm ${LOG_FILE}

		exit 0
	fi

	echo "コピー開始"

	# マウントディレクトリ
	MOUNT_DIR=/mnt/gsrc-nas01

	# dumpファイルコピー先ディレクトリ
	DUMP_TO_DIR=${MOUNT_DIR}/hayabusa/${HOSTNAME}/daily_backup

	rsync -v --bwlimit=10240 ${DUMP_LOG_DIR}/${dump_file} ${DUMP_TO_DIR} ${DUMP_TO_DIR}
	result=$?
	if [ ${result} -gt 0 ]; then
		subject="【はやぶさ】エラー：dumpファイルコピーに失敗しました"
		mail_body=`echo -e "対象サーバー：${HOSTNAME}\r\n"`
		mail_body=${mail_body}`echo -e "dumpファイルコピーに失敗しました\r\n"`
		mail_body=${mail_body}`echo -e "対応をお願いします"`
		./gs_sendmail.sh ${TO_ADDRESS} ${subject} ${mail_body} ${LOG_FILE} ${CURRENT_DIR}

		# 添付ファイルの削除
		rm ${LOG_FILE}
		exit 0
	fi

else
	subject="【はやぶさ】エラー：バックアップエラー"
	mail_body=`echo -e "対象サーバー：${HOSTNAME}\r\n"`
	mail_body=${mail_body}`echo -e "バックアップエラーが発生しました\r\n"`
	mail_body=${mail_body}`echo -e "${dump_log}\r\n"`
	mail_body=${mail_body}`echo -e "対応をお願いします"`
	./gs_sendmail.sh ${TO_ADDRESS} ${subject} ${mail_body} ${dump_log} ${DUMP_LOG_DIR}
	exit 0
fi


exit 0

