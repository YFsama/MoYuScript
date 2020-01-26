#!/bin/bash

apt install dnsmasq

echo "
  server=223.5.5.5
  server=8.8.8.8
  listen-address=172.24.31.254
  resolv-file=/etc/resolv.dnsmasq.conf
  dhcp-range=172.24.31.40,172.24.31.240,12h
  dhcp-option=option:router,172.24.31.254
  dhcp-option=option:dns-server,223.5.5.5.114,8.8.8.8
" > /etc/dnsmasq.conf

echo "nameserver 127.0.0.1" > /etc/resolv.conf

echo "
nameserver 223.5.5.5
nameserver 8.8.8.8
" > /etc/resolv.dnsmasq.conf

iptables -A INPUT -p udp -m udp --dport 53 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 53 -j ACCEPT

iptables -t nat -A PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 53
iptables -t nat -A PREROUTING -p tcp --dport 53 -j REDIRECT --to-ports 53

service iptables save
service iptables restart
