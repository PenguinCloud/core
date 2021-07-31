#!/bin/bash
apt install python3 python3-pip -y
pip3 install ansible
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-galaxy install -r configs/ansible-requirements.yaml
mkdir -p /etc/ansible
mkdir -p /root/.kube
mkdir -p /etc/sshd

FILE=/etc/ansible/ansible.cfg
if test -f "$FILE"; then
    echo "$FILE exists, skipping setup."
else
  echo "Setting up ansible config file"
echo "[defaults]" > /etc/ansible/ansible.cfg
echo "host_key_checking = False" >> /etc/ansible/ansible.cfg
fi

cd /opt/baseline-ansible-setup
FILE=/etc/ansible/hosts
if test -f "$FILE"; then
    echo "$FILE exists, skipping setup."
else
cp -f configs/hosts.yaml /etc/ansible/hosts
fi
export KUBECONFIG=/root/.kube/config

if [ -z $1 ]; then 
ansible-playbook -e 'host_key_checking=False' upstart.yaml
else
ansible-playbook -e 'host_key_checking=False' upstart.yaml --tags $1
fi
# "resolvectl status" can be used to validate DNS applied (you usually have to scroll down to see them)
# We have it set to cloudflare as they are our primary dns host for PMG prod