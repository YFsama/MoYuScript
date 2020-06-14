#!/bin/bash

#空白系统配置成支持CI的系统

#更新系统
apt update -y || yum update -y
apt upgrade -y || yum upgrade -y

#安装组件
yum install sudo -y || apt install -y sudo 
sudo yum install -y git epel-release traceroute wget curl vim nano net-tools || sudo apt install -y apt-transport-https ca-certificates net-tools traceroute wget curl vim nano

#安装Cloud-init
apt install -y cloud-init || yum install -y cloud-init cloud-utils-growpart

#安装qemu-guest
apt install -y qemu-guest-agent || yum install -y qemu-guest-agent

#替换cloud.cfg qemu.cfg
sed -i -e '/- package-update-upgrade-install/d' /etc/cloud/cloud.cfg
sed -i -e 's/disable_root: true/disable_root: false \nssh_pwauth: true/g' -e 's/ssh_pwauth:   0/ssh_pwauth:   1/g'  /etc/cloud/cloud.cfg
sed -i -e 's/disable_root: 1/disable_root: 0/g' -e 's/ssh_pwauth:   0/ssh_pwauth:   1/g'  /etc/cloud/cloud.cfg

#开机启动 Qemu-Guest-Agent
systemctl start qemu-guest-agent
systemctl enable qemu-guest-agent || chkconfig qemu-ga on

#写MOTD
echo "
Welcome to Next-Generation MercyCloud Service !
" > /etc/motd

#删除记录

echo > /var/log/btmp
echo > /var/log/wtmp
echo > /var/log/secure
echo > ~/.bash_history

history -c

rm ~/anaconda-ks.cfg 
rm moyu.sh