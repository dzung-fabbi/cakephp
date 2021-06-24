#!/bin/bash

SCHEMA=$1

DB_USER=$2
DB_PASS=$3

vardate=`date +%Y%m%d%H%M`
dirdate=`date +%Y%m%d`
dump_file=${SCHEMA}_${vardate}_sin.gz
dump_log=dump_log_${vardate}_sin.log

echo `date` "START: Dump "$dump_file

#all dump
mysqldump -u$DB_USER -p$DB_PASS $SCHEMA --single-transaction --hex-blob --log-error=/tmp/$dump_log | gzip > /tmp/$dump_file

echo "/tmp/$dump_file"
echo `date` "END: Dump "

exit 0