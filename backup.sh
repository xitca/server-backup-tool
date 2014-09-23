#!/bin/bash 

# which directory you want to save.
BackupPath=/vagrant/bk

# which directory you need to backup. 
WebSite=/vagrant/backup_tool

# mysql user and password
MysqlUser="root" 
MysqlPass="root" 

# mysql path
MYSQLDUMP=mysqldump
MYSQL=mysql

# Dropbox app root 
DropboxDir=/$(date +%Y-%m-%d) 
OldDropboxDIR=/$(date -d -30day +%Y-%m-%d) 

# define file name
CurrentDay=$(date +"%Y-%m-%d-%H%M%S")
SevenDay=$(date -d -7day +"%Y-%m-%d-%H%M%S")

DataBakName=$CurrentDay"_Database.tar.gz"
WebBakName=$CurrentDay"_Web.tar.gz"
OldData=$SevenDay"_Database.tar.gz" 
OldWeb=$SevenDay"_Web.tar.gz" 

# get current path
CurrentPath=$(pwd)

if [ ! -x "dropbox_uploader.sh" ]; then 
	wget https://raw.github.com/andreafabrizi/Dropbox-Uploader/master/dropbox_uploader.sh
	chmod +x dropbox_uploader.sh
fi 
if [ ! -x "$BackupPath" ]; then 
	mkdir "$BackupPath" 
fi 
if [ ! -w "$BackupPath" ] ; then
    chmod -R 700 $BackupPath 
fi

#crontab sh backup.sh

echo  "* 1 * * * $CurrentPath/$0 > /dev/null 2>&1"  >> /var/spool/cron/root

# export mysql db except Database information_schema mysql temp performance_schema
MysqlDB=$($MYSQL -u$MysqlUser -p$MysqlPass -e "SHOW Databases;")

echo -ne "Dump mysql..." 
cd $BackupPath
for db in ${MysqlDB[@]}; do 
	if [ $db != "Database" -a $db != "information_schema" -a $db != "mysql" -a $db != "temp" -a $db != "performance_schema" ]; then
		($MYSQLDUMP -u$MysqlUser -p$MysqlPass ${db} > ${db}.sql) 
	fi
done 
tar zcf $BackupPath/$DataBakName *.sql 
rm -rf $BackupPath/*.sql 
echo -e "Done" 

# backup website data
echo -ne "Backup website files..." 
cd $WebSite
tar zcf $BackupPath/$WebBakName * 
echo -e "Done" 

# clean up 7day's backup at local
echo -ne "Delete local data of 7 days old..." 
rm -rf $BackupPath/$OldData $BackupPath/$OldWeb 
echo -e "Done" 

# start Dropbox 
echo -e "Start uploading..." 
cd $CurrentPath
./dropbox_uploader.sh upload $BackupPath/$DataBakName $DropboxDir/$DataBakName 
./dropbox_uploader.sh upload $BackupPath/$WebBakName $DropboxDir/$WebBakName 

# clean up 30day's backup at Dropbox 
./dropbox_uploader.sh delete $OldDropboxDir/ 
echo -e "Thank you! All done." 
