#!/bin/bash
# Install BGPQ4
apt install libtool autoconf g++ make
wget https://github.com/bgp/bgpq4/archive/refs/tags/1.9.tar.gz 
tar -xzvf 1.9.tar.gz
cd bgpq4-1.9/
./bootstrap
./configure
make
make install

# Install FRR RPKI
apt install frr-rpki-rtrlib
sed -i 's/\(bgpd_options=".*\)"$/\1 -M rpki"/' /etc/frr/daemons

service frr restart
