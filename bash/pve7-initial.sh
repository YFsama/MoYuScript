#!/bin/bash

if [ ! $1 ]; then
   net=$1;
else
  net="10.100.0.0/24";
fi

if [ ! $2 ]; then
   gateway=$2;
else
   gateway="10.100.0.254";
fi

if [ ! $3 ]; then
   int=$3;
else
   int="vmbr100";
fi

#添加網卡
echo "

auto ${int}
iface ${int} inet static
	address  ${gateway}
	netmask  24
	bridge-ports none
	bridge-stp off
	bridge-fd 0
" >> /etc/network/interfaces

ifup ${int}

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
" >> /etc/sysctl.conf

sysctl -p
# IPtable初始化 保存
iptables -t nat -A POSTROUTING -s ${net} -o vmbr0 -j MASQUERADE

apt install -y iptables-persistent

#开启嵌套虚拟化
modprobe -r kvm_intel
modprobe kvm_intel nested=1
echo "options kvm_intel nested=1" >> /etc/modprobe.d/modprobe.conf


echo "deb http://download.proxmox.com/debian/pve bullseye pve-no-subscription " >> /etc/apt/sources.list.d/pve-no-sub.list

# 注释掉企业源
echo "#deb https://enterprise.proxmox.com/debian/pve bullseye pve-enterprise" >  /etc/apt/sources.list.d/pve-enterprise.list
