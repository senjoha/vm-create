#!/bin/bash

# set env-variables to work with
VMNAME=$1
FULLNAME=$VMNAME".iede.senjoha.org"
TMP_VMID=$2
VMID=$(( $TMP_VMID + 100 ))

# create real container
# see pct-create.sh
# execute pct-create on pve host
ssh -l root homie "/root/vm-create/pct-create.sh $VMNAME $VMID"

# start container
ssh -l root homie "pct start $VMID"

# create ansible-hosts-file
touch ./new
echo "[new]" > ./new
echo $VMNAME >> ./new

# add new host to temporary ssh-config
touch ~/.ssh/new
echo "Host $VMNAME" >> ~/.ssh/new
echo "Hostname 192.168.178.$VMID" >> ~/.ssh/new
echo "User root" >> ~/.ssh/new
echo "Identityfile ~/.ssh/home" >> ~/.ssh/new

# sleep for 5 seconds to start vm and get interface up 
sleep 5

# run initial ansible-playbook (other repo)
ansible-playbook ~/Ansible/initial.yml -i ./new

# create prometheus config file
#echo '[{"labels": {"job": "node"}, "targets": ["$FULLNAME:9100"]}]' | ssh prometheus -l root -T "cat > /etc/prometheus/generated/$FULLNAME.json"
#ansible-playbook ~/Ansible/node-exporter.yml --extra-vars "FULLNAME=$FULLNAME"

# remove created ssh-config
rm ~/.ssh/new

# remove ansible hosts file
rm ./new

# unset variables
unset VMNAME
unset FULLNAME
unset TMP_VMID
unset VMID

# notify of finished
curl -d "vm creation is done. Please check!" https://ntfy.iede.senjoha.org/ansible
echo "vm creation is done. Please check!"
