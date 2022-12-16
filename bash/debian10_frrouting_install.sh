#!/bin/bash

# 更改DNS
echo "nameserver 8.8.8.8" > /etc/resolv.conf

# 更新系統 組件
apt update -y
apt upgrade -y
apt install -y curl gnupg2 traceroute

# 安裝FRRouting

curl -s https://deb.frrouting.org/frr/keys.asc | sudo apt-key add -
FRRVER="frr-stable"
echo deb https://deb.frrouting.org/frr $(lsb_release -s -c) $FRRVER | sudo tee -a /etc/apt/sources.list.d/frr.list
sudo apt update -y && sudo apt install -y frr frr-pythontools

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

# 打开Frr全部功能
sed -i "s/=no/=yes/g" /etc/frr/daemons
service frr restart

sudo vtysh
