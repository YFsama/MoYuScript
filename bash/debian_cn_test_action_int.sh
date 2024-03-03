#!/bin/bash

down="eth1"
time=`date +%Y-%m-%d" "%H:%M:%S`
ping="223.5.5.5"
target="www.baidu.com"

function network()
{
    #超时时间
    local timeout=3
    #获取响应状态码
    local ret_code=`curl -I -s --connect-timeout ${timeout} ${target} -w %{http_code} | tail -n1`
    if [ "x$ret_code" = "x200" ]; then
        #网络畅通
        return 1
    else
        #网络不畅通
        return 0
    fi
    return 0
}

network

if [ $? -eq 0 ];then
    # 写一个失败次数 (读取原本的)
    if [ -e ./fail ];then
    num=`cat ./fail`
    else
    num=0
    fi 
    
    new=`expr $num + 1`
    echo $new > ./fail

    if [ $num -gt 2 ]; then
        # 如果甚至还ping不通(也有可能是测试站挂了x) 
        # Todo 这里也触发一次远程提醒
        ping -c 3 $ping > /dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo 1 > ./down
            echo "Interface down ${down} - ${time}"
            ifdown $down
        else
            echo "Ping ok ${ping} - ${time}"
        fi
    fi 

        echo "Curl fail: ${num} - ${time}"
        exit -1
else
    if [ -e ./fail ];then
    rm ./fail
    fi 

    # 如果存在把接口禁用了就重新启用接口
    if [ -e ./down ]; then
        echo "Interface up ${down} - ${time}"
        ifup $down
        rm ./down
    fi
fi

# 清理Log
line=`wc -l < ./log`

if [ $line -gt 5 ];then
   tail -3 ./log > ./log.temp
   mv ./log.temp ./log
   echo "Clear log - ${time}" >> ./log
fi


echo "Script finished! - ${time}"
exit 0
