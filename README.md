server-backup-tool
===================

服务器备份工具-Shell
######适用于包含网站文件较少的服务器，当然也可以单独备份配置文件。

####1.使用
+ `git clone https://github.com/kchum/server-backup-tool.git` 也可下载zip。
+ `cd server-backup-tool`
+ `vi backup.sh` 根据注释和自己需求编辑配置到 config done，并保存。
+ `/path/to/server-backup-tool/backup.sh` 首次运行需配置 Dropbox 的 App key、App secret，根据提示的操作就可以了。配置一次即可。关于在 Dropbox 创建 app 有一些推荐配置，见下面

####2.配置备份任务周期
+ `crontab -e` 设置备份周期
+ `0 0 * * * /path/to/server-backup-tool/backup.sh` 增加此行

####Dropbox 创建 app 的建议
+ `https://www.dropbox.com/developers/apps` -> `Create app`
+ `What type of app do you want to create?` 选择 `Dropbox API app` 
+ `What type of data does your app need to store on Dropbox?` 选择 `Files and datastores`
+ `Can your app be limited to its own folder?` 如果是专门申请个账号做备份，选 `No`，即在根目录 `/` 本人是这样的。选 `Y` 则在 `/apps/` 下备份
+ `What type of files does your app need access to?` 选择 `All file types`
+ 输入App name -> `Create app` 即可 

###感谢
`@andreafabrizi` 的 `Dropbox-Uploader`