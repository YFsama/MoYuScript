#!/bin/bash


# 变更更新源
echo "deb https://mirrors.tuna.tsinghua.edu.cn/proxmox/debian buster pve-no-subscription" >> /etc/apt/sources.list.d/pve-no-sub.list
# 注释掉企业源
echo "#deb https://enterprise.proxmox.com/debian/pve buster pve-enterprise" >  /etc/apt/sources.list.d/pve-enterprise.list


# 开启嵌套虚拟化

modprobe -r kvm_intel
modprobe kvm_intel nested=1 
echo "options kvm_intel nested=1" >> /etc/modprobe.d/modprobe.conf

# APT切换清华源
echo "
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ buster main contrib non-free
# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ buster main contrib non-free
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ buster-updates main contrib non-free
# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ buster-updates main contrib non-free
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ buster-backports main contrib non-free
# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ buster-backports main contrib non-free
deb https://mirrors.tuna.tsinghua.edu.cn/debian-security buster/updates main contrib non-free
# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian-security buster/updates main contrib non-free
" > /etc/apt/sources.list



# 更新系统

apt update -y 
apt upgrade -y

# 安装软件
apt install  -y dig whois curl wget ifupdown2 git zip traceroute

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


# 创建一张NAT网卡备用

cat >> /etc/network/interfaces <<'EOF'

auto vmbr3
iface vmbr3 inet static
  address 10.21.0.254
  netmask 255.255.255.0
  bridge_ports none
  bridge_stp off
  bridge_fd 0
EOF


iptables -t nat -A POSTROUTING -s 10.21.0.254/24 -j MASQUERADE
cat > /etc/network/if-pre-up.d/iptables <<'EOF'
#!/bin/bash
/sbin/iptables-restore < /etc/iptables.up.rules
EOF
chmod +x /etc/network/if-pre-up.d/iptables
iptables-save > /etc/iptables.up.rules


# 下载系统
mdkir ~/system
cd ~/system
wget http://cn.system.down.hstack.io:9886/system_wget.log
wget -i system_wget.log
rm -f system_wget.log

dir=* #当前目录
vmid=2000
for i in ${dir}
  do
    if [ $i == $0 ]
    then
        continue
    fi
    qm create $vmid --name ${i%.qcow2} --agent 1
    qm importdisk $vmid $i $1
    qm set $vmid --virtio0 $1:vm-$vmid-disk-0
    qm set $vmid --boot c --bootdisk virtio0
    # qm set $num --serial0 socket --vga serial0
    qm set $vmid --ide2 $1:cloudinit
    qm template $vmid
    vmid=$((vmid+1))
done
