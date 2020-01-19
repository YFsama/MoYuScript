#!/bin/bash

# 修改下面兩個參數后，配置crontab/webhook调用即可
# 自动拉取代码

localPath="/www/wwwroot/"
gitHttp=""

echo "Update $localPath"

if [ -d "$localPath" ]; then
        cd $localPath
        git reset --hard origin/master
        
        git pull origin master
        echo "Updated"
    
        chown -R www:www $localPath
        exit
else
        echo "Path nof found"
        exit
fi