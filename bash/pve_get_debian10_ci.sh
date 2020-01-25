#!/bin/bash

# YFsama PVE导入Debian10 鏡像使用

apt install -y wget

# TODO: 国内放个镜像
wget "http://cdimage.debian.org/cdimage/cloud/OpenStack/current-10/debian-10-openstack-amd64.qcow2"

qm importdisk $0 debian-10-openstack-amd64.qcow2 $1
qm set $0 --virtio0 $1:vm-$0-disk-0
qm set $0 --boot c --bootdisk virtio0
qm set $0 --serial0 socket --vga serial0
qm set $0 --ide2 $1:cloudinit
qm template $0
