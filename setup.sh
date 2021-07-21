#!/bin/bash
apt install python3 python3-pip -y
pip3 install ansible
ansible-galaxy install -r configs/ansible-requirements.yaml
mkdir -p /etc/ansible
mkdir -p /root/.kube
FILE=/etc/ansible/hosts
if test -f "$FILE"; then
    echo "$FILE exists, skipping setup."
else
echo "[cluster]"  >> /etc/ansible/hosts
echo 'localhost ansible_connection=local ansible_python_interpreter="/usr/bin/env python3"'  >> /etc/ansible/hosts
fi
export KUBECONFIG=/root/.kube/config
echo "Printing your local ip info for the next prompt"
ip a
if [ -z $1 ]; then 
ansible-playbook  upstart.yaml --connection=local
else
ansible-playbook  upstart.yaml --connection=local --tags $1
fi
