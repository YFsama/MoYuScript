#!/bin/bash

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
