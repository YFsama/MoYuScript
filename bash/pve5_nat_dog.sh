#!/bin/bash
#https://rbq.ai/p/581/
#狗蛋给咱的PVE5 NAT脚本

rm -rf /etc/apt/sources.list.d/*
cat > /etc/apt/sources.list  <<'EOF'
deb http://ftp.cn.debian.org/debian/ stretch main
deb-src http://ftp.cn.debian.org/debian/ stretch main

deb http://security.debian.org/ stretch/updates main contrib non-free
deb-src http://security.debian.org/ stretch/updates main contrib non-free

deb http://ftp.cn.debian.org/debian/ stretch-updates main contrib non-free
deb-src http://ftp.cn.debian.org/debian/ stretch-updates main contrib non-free
EOF
apt-get update
apt-get -y install dnsmasq
cat >> /etc/network/interfaces <<'EOF'

auto vmbr1
iface vmbr1 inet static
address 192.168.0.1
netmask 255.255.255.0
bridge_ports none
bridge_stp off
bridge_fd 0
EOF
cat >> /etc/dnsmasq.conf <<'EOF'
interface=vmbr1
#dhcp-option=1,255.255.225.0
dhcp-range=192.168.0.100,192.168.0.199,12h
dhcp-option=3,192.168.0.1
dhcp-option=option:dns-server,114.114.114.114,8.8.8.8
EOF
cat >> /etc/sysctl.conf <<'EOF'
net.ipv4.ip_forward = 1
EOF
sysctl -p
iptables -t nat -A POSTROUTING -s 192.168.0.0/24 -j MASQUERADE
cat > /etc/network/if-pre-up.d/iptables <<'EOF'
#!/bin/bash
/sbin/iptables-restore < /etc/iptables.up.rules
EOF
chmod +x /etc/network/if-pre-up.d/iptables
iptables-save > /etc/iptables.up.rules
service networking restart
service dnsmasq restart
rm 1.sh
