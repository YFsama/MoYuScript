#!/bin/bash

DATE=`date +%Y%m%d`

BACKUP_DB_PATH=/backup/db
BACKUP_ZIP_PATH=/backup/zip
BACKUP_TEMP_PATH=/backup/tmp
VW_DATA_PATH=/vw_data

sqlite3 $VW_DATA_PATH/db.sqlite3 ".backup '$BACKUP_DB_PATH/db-$DATE.sqlite3'"

cd $VW_DATA_PATH 
cp -r `ls $VW_DATA_PATH | grep -v sqlite3 | xargs` $BACKUP_TEMP_PATH

cd $BACKUP_TEMP_PATH
BACKUP_ZIP_NAME=$BACKUP_ZIP_PATH/vw-data-$DATE.zip
zip -rq $BACKUP_ZIP_NAME *

rm -r $BACKUP_TEMP_PATH/*

find $BACKUP_ZIP_PATH -name "*.zip" -type f -mtime +30 -exec rm {} \;

rclone copy $BACKUP_DB_PATH/db-$DATE.sqlite3 minio:vaultwarden-db
rclone copy $BACKUP_ZIP_NAME minio:vaultwarden-file
