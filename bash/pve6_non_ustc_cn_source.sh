#!/bin/bash

echo "deb http://mirrors.ustc.edu.cn/proxmox/debian/pve buster pve-no-subscription " >> /etc/apt/sources.list.d/pve-no-sub.list

# 注释掉企业源
echo "#deb https://enterprise.proxmox.com/debian/pve buster pve-enterprise" >  /etc/apt/sources.list.d/pve-enterprise.list
