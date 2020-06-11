#!/bin/bash

# 变更更新源
echo "deb https://mirrors.tuna.tsinghua.edu.cn/proxmox/debian buster pve-no-subscription" >> /etc/apt/sources.list.d/pve-no-sub.list
# 注释掉企业源
echo "#deb https://enterprise.proxmox.com/debian/pve buster pve-enterprise" >  /etc/apt/sources.list.d/pve-enterprise.list


# 开启嵌套虚拟化

modprobe -r kvm_intel
modprobe kvm_intel nested=1 
echo "options kvm_intel nested=1" >> /etc/modprobe.d/modprobe.conf

# APT切换清华源
echo "
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ buster main contrib non-free
# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ buster main contrib non-free
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ buster-updates main contrib non-free
# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ buster-updates main contrib non-free
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ buster-backports main contrib non-free
# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ buster-backports main contrib non-free
deb https://mirrors.tuna.tsinghua.edu.cn/debian-security buster/updates main contrib non-free
# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian-security buster/updates main contrib non-free
" > /etc/apt/sources.list

# 更改DNS
echo "nameserver 8.8.8.8" > /etc/resolv.conf


# 更新系统

apt update -y 
apt upgrade -y

# 安装软件
apt install curl wget ifupdown2 git zip -y 

# 開啓IP轉發
echo "
net.ipv4.conf.all.forwarding = 1
net.ipv6.conf.all.disable_ipv6 = 0
net.ipv6.conf.default.disable_ipv6 = 0
net.ipv6.conf.lo.disable_ipv6 = 0
net.ipv6.conf.default.forwarding = 1
net.ipv6.conf.all.forwarding = 1
net.ipv6.conf.all.proxy_ndp = 1
net.ipv6.conf.all.accept_ra = 2
" > /etc/sysctl.conf

sysctl -p


