#!/bin/bash

# reference: https://butwt.wordpress.com/2018/03/05/quaga-ospf-on-ubuntu/
# UFW放行OSPF报文

#V6
echo "
# allow Link local multicast
-A ufw6-before-input -p ospf -d ff02::/16 -j ACCEPT
" >> /etc/ufw/before6.rules

#V4
ufw allow from 224.0.0.0/24

#UFW 開啟IP轉發
sed 's/DEFAULT_FORWARD_POLICY="DROP"/DEFAULT_FORWARD_POLICY="ACCEPT"/g' /etc/default/ufw

ufw disable && ufw enable
