#!/bin/bash
VMNAME=$1
VMID=$2
TEMPLATE=local:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst

pvesm alloc local-lvm $VMID vm-$VMID-disk-0 8G
mkfs.ext4 $(pvesm path local-lvm:vm-$VMID-disk-0) -E root_owner=100000:100000

pct create $VMID $TEMPLATE \
    -arch amd64 \
    -cmode shell \
    -cores 4 \
    -features nesting=1,keyctl=1 \
    -hostname $VMNAME \
    -memory 2048 \
    -net0 name=eth0,bridge=vmbr0,firewall=1,gw=192.168.178.1,ip=192.168.178.$VMID/24,ip6=auto \
    -ostype debian \
    -rootfs volume=local-lvm:vm-$VMID-disk-0,size=8G \
    -storage local-lvm \
    -swap 0 \
    -timezone Europe/Berlin \
    -unprivileged 1 \
    -ssh-public-keys /root/vm-create/root-key.pub
