#!/bin/bash

# reference: https://butwt.wordpress.com/2018/03/05/quaga-ospf-on-ubuntu/
# UFW放行OSPF报文

echo "
# allow Link local multicast
-A ufw6-before-input -p ospf -d ff02::/16 -j ACCEPT
" >> /etc/ufw/before6.rules

ufw disable && ufw enable

ufw allow from 224.0.0.0/24