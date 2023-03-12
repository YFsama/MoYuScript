#!/bin/bash

# 更新系統 組件
apt update -y
apt upgrade -y
apt install -y curl gnupg2 traceroute net-tools wget lsb-release sudo

# 安裝FRRouting
curl -s https://deb.frrouting.org/frr/keys.asc | sudo apt-key add -
FRRVER="frr-stable"
echo deb https://deb.frrouting.org/frr $(lsb_release -s -c) $FRRVER | sudo tee -a /etc/apt/sources.list.d/frr.list
sudo apt update -y && sudo apt install -y frr frr-pythontools

# 開啓IP轉發
echo "

#Script Addons Start

net.ipv4.conf.all.forwarding = 1
net.ipv6.conf.all.disable_ipv6 = 0
net.ipv6.conf.default.disable_ipv6 = 0
net.ipv6.conf.lo.disable_ipv6 = 0
net.ipv6.conf.default.forwarding = 1
net.ipv6.conf.all.forwarding = 1
net.ipv6.conf.all.proxy_ndp = 1
net.ipv6.conf.all.accept_ra = 2

net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_fin_timeout = 30
net.inet.udp.checksum=1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.tcp_syn_retries = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.tcp_wmem = 30000000 30000000 30000000
net.ipv4.ip_local_port_range = 1024 65000
net.ipv4.netfilter.ip_conntrack_max=204800
net.core.optmem_max = 10000000
net.core.rmem_default = 10000000
net.core.rmem_max = 10000000
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr

#Script Addons End

" >> /etc/sysctl.conf

sysctl -p

sed -i "s/bgpd=no/bgpd=yes/g" /etc/frr/daemons
sed -i "s/ospf6d=no/ospf6d=yes/g" /etc/frr/daemons
sed -i "s/ospfd=no/ospfd=yes/g" /etc/frr/daemons
sed -i "s/bfdd=no/bfdd=yes/g" /etc/frr/daemons
sed -i "s/pbrd=no/pbrd=yes/g" /etc/frr/daemons

service frr restart
