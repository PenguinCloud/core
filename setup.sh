#!/bin/bash
# setup.sh is the same as Dockerfile but for metal hosts

# Set ENV variables
export TZ=America/Chicago
export DNS="1.1.1.1"
export PUBLIC_INTERFACE="enp1s0"
export INTERNAL_INTERFACE="enp6s0"
export KERNEL_MODS="yes"
export DOCKER="yes"
export CRON_UPDATE="yes"
export IP_PRIVATE="10.0.0.1/24"
export ANSIBLE_HOST_KEY_CHECKING=False
export KUBECONFIG=/root/.kube/config
# Set Timezone
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
# Make Dirs
mkdir -p /etc/ansible /root/.kube /etc/sshd
# Copy Files
cp -rfu * /opt/core
FILE=/etc/ansible/hosts
if test -f "$FILE"; then
    echo "$FILE exists, skipping setup."
else
cp -f ./configs/hosts.yml /etc/ansible/hosts
fi
# Move to working Directory
cd /opt/core
# Install Core Components
apt update && apt install python3 python3-pip openssh-client -y && apt upgrade -y
ansible-galaxy collection install community.general
pip3 install ansible lxml
# Enable SSH Server Daemon (metal only)
systemctl enable ssh
systemctl restart ssh
# setup Ansible config if not already there
FILE=/etc/ansible/ansible.cfg
if test -f "$FILE"; then
    echo "$FILE exists, skipping setup."
else
  echo "Setting up ansible config file"
echo "[defaults]" > /etc/ansible/ansible.cfg
echo "host_key_checking = False" >> /etc/ansible/ansible.cfg
fi
ansible-playbook /opt/core/upstart.yml -c local --skip-tags metal,run,exec
# Run and Execute live
if [ -z $1 ]; then
ansible-playbook -e 'host_key_checking=False' /opt/core/upstart.yml  -t run,exec
else
ansible-playbook -e 'host_key_checking=False' /opt/core/upstart.yml  -t $1
fi
# "resolvectl status" can be used to validate DNS applied (you usually have to scroll down to see them)
# We have it set to cloudflare as they are our primary dns host for PMG prod