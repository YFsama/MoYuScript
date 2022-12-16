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

ifup vmbr1

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

touch /etc/network/if-pre-up.d/iptables

echo "
#!/bin/sh
/sbin/iptables-restore < /etc/iptables
" > /etc/network/if-pre-up.d/iptables

chmod +x /etc/network/if-pre-up.d/iptables

iptables-save > /etc/iptables

