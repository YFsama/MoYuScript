#!/bin/bash

# 安装FRR+RPKI 优化系统加载项 开启MPLS 在 ~ 预留一个开机启动的文件

# System Update
apt update -y
apt upgrade -y
apt install -y curl gnupg2 traceroute net-tools tcpdump wget lsb-release sudo

# Install BGPQ4
apt install -y libtool autoconf g++ make
wget https://github.com/bgp/bgpq4/archive/refs/tags/1.9.tar.gz 
tar -xzvf 1.9.tar.gz
cd bgpq4-1.9/
./bootstrap
./configure
make
make install

cd ~

# FRR INSTALLL
curl -s https://deb.frrouting.org/frr/keys.asc | sudo apt-key add -
FRRVER="frr-stable"
echo deb https://deb.frrouting.org/frr $(lsb_release -s -c) $FRRVER | sudo tee -a /etc/apt/sources.list.d/frr.list
sudo apt update -y && sudo apt install -y frr frr-pythontools

#开启常用的协议
sed -i "s/bgpd=no/bgpd=yes/g" /etc/frr/daemons
sed -i "s/ospf6d=no/ospf6d=yes/g" /etc/frr/daemons
sed -i "s/ospfd=no/ospfd=yes/g" /etc/frr/daemons
sed -i "s/bfdd=no/bfdd=yes/g" /etc/frr/daemons
sed -i "s/pbrd=no/pbrd=yes/g" /etc/frr/daemons
sed -i "s/isisd=no/isisd=yes/g" /etc/frr/daemons
sed -i "s/ldpd=no/ldpd=yes/g" /etc/frr/daemons
sed -i "s/pathd=no/pathd=yes/g" /etc/frr/daemons

# RPKI
apt install -y frr-rpki-rtrlib
sed -i 's/\(bgpd_options=".*\)"$/\1 -M rpki"/' /etc/frr/daemons

service frr restart

# 长期 添加 Modules
echo " 
mpls_router
mpls_gso
mpls_iptunnel
" >>   /etc/modules-load.d/modules.conf

# 临时加载
modprobe mpls_router
modprobe mpls_gso
modprobe mpls_iptunnel

# Sysctl Addons
echo "

#Script Addons Start

net.ipv4.conf.all.forwarding = 1
net.ipv6.conf.all.disable_ipv6 = 0
net.ipv6.conf.all.forwarding = 1 

# see details in https://help.aliyun.com/knowledge_detail/39428.html
net.ipv4.conf.all.rp_filter = 0
net.ipv4.conf.default.rp_filter = 0
net.ipv4.conf.default.arp_announce = 2
net.ipv4.conf.lo.arp_announce = 2
net.ipv4.conf.all.arp_announce = 2

# see details in https://help.aliyun.com/knowledge_detail/41334.html
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 1024
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_slow_start_after_idle = 0

# BBR 
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr

# TCP

net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_syn_retries = 2
vm.swappiness=1
net.core.rmem_max=16777216
net.core.wmem_max=16777216
net.ipv4.tcp_rmem=4096 212992 16777216
net.ipv4.tcp_wmem=4096 212992 16777216

# VRF DOT REMOVE IPV6
net.ipv6.conf.all.keep_addr_on_down=1

#Script Addons End

# MPLS

net.mpls.conf.lo.input=1
net.mpls.conf.dummy0.input=1

net.mpls.platform_labels=1048575

" >> /etc/sysctl.conf


# 开机启动脚本

echo "
[Unit]
Description=Startup Script

[Service]
ExecStart=/root/startup.sh

[Install]
WantedBy=default.target

" > /etc/systemd/system/startup.service 

echo "" >> /root/startup.sh

chmod +x  /root/startup.sh

systemctl enable startup

