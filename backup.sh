#!/bin/bash

# where will you store?
BackupPath='/vagrant/Backups'

#Server name example in the Cloud: /app/testserver or /testserver
ServerName='testserver'

#Cloud name Dropbox
DropBoxBackup='true'

# get date
CurrentDay=$(date +"%Y%m%d%H%M%S")
SevenDay=$(date -d -7day +"%Y%m%d")

# path setting
# example /home/www  20141010-website.tar.gz
FilePath=('/vagrant/test2' '/vagrant/test1' '/vagrant/test')
NamePath=('test2' 'test1' 'test')

# MYSQL setting
# MYSQL user MYSQL password
MysqlUser='root'
MysqlPass='root'

# MYSQL which database you want to backup?
MysqlDbs=('sales25du' 'ec' 'oc')

# CurrentDay MYSQL backup FileName
CurrentDayMysqlFile=$CurrentDay'-mysql.tar.gz'

# MYSQL Path 
MYSQLDUMP=mysqldump
MYSQL=mysql

CurrentPath=$(pwd)

# Dropbox/BaiduYun app root 
CloudDir=/$(date +%Y%m%d) 
OldCloudDIR=/$(date -d -30day +%Y%m%d) 

# config done

# download Dropbox_uploader.sh
if [ ! -x "./dropbox_uploader.sh" ]; then 
	wget https://raw.github.com/andreafabrizi/Dropbox-Uploader/master/dropbox_uploader.sh
	chmod +x dropbox_uploader.sh
fi 

cd /


# create directory
if [ ! -x "$BackupPath" ]; then 
	mkdir "$BackupPath" 
fi 
# write privilege
if [ ! -w "$BackupPath" ] ; then
    chmod -R 700 $BackupPath 
fi

# export mysql db 
echo -ne 'Dump mysql...' 
cd $BackupPath
for db in ${MysqlDbs[@]}; do 
	($MYSQLDUMP -u$MysqlUser -p$MysqlPass ${db} > ${db}.sql) 
done 
tar zcf $BackupPath/$CurrentDayMysqlFile *.sql 
tar zcf $BackupPath/$CurrentDayMysqlFile *.sql 
rm -rf $BackupPath/*.sql 
echo -e 'Done'

# backup files 
echo -ne "Backup website files..." 
TotalPaths=${#FilePath[@]}
for (( i=0; i<$TotalPaths; i++)); do
	cd ${FilePath[$i]}
	TempPath=$(basename `pwd`)
	cd ..
	tar zcf $BackupPath/$CurrentDay'-'${NamePath[$i]}.tar.gz $TempPath/*
done
echo -e "Done" 

# clean up 7day's backup at local
echo -ne "Delete local data of 7 days old..." 
echo $SevenDay
rm -rf $BackupPath/$SevenDay*
echo -e "Done" 

# start Dropbox 
if [ $DropBoxBackup == "true"  ]; then
	echo -e "Start uploading(Dropbox)..." 
	cd $CurrentPath

	CurrentFiles=$BackupPath/$CurrentDay*
	for f in ${CurrentFiles[@]}; do 
		./dropbox_uploader.sh upload $f $ServerName/$CloudDir/`basename $f`
	done

	# clean up 30day's backup at Dropbox 
	echo -e "Start clean up 30day's backup at Dropbox"
	./dropbox_uploader.sh delete $ServerName/$OldCloudDIR/ 
fi

echo -e "Upload done!" 
echo -e "Thank you! All done." 

