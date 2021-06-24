#!/bin/bash

SCHEMA=$1

DB_USER=$2
DB_PASS=$3

vardate=`date +%Y%m%d%H%M`
dirdate=`date +%Y%m%d`
dump_file=${SCHEMA}_${vardate}.gz

echo `date` "START: Dump "$dump_file

#all dump
mysqldump -u$DB_USER -p$DB_PASS $SCHEMA --hex-blob | gzip > /tmp/$dump_file

echo "/tmp/$dump_file"
echo `date` "END: Dump "

exit 0