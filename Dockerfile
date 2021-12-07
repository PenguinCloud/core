FROM ubuntu
LABEL maintainer="Penguin Technologies Group LLC"

# Set ENV variables
ARG TZ=America/Chicago
ENV TZ=America/Chicago
ARG DNS="1.1.1.1"
ENV PUBLIC_INTERFACE="enp1s0"
ENV INTERNAL_INTERFACE="enp6s0"
ARG KERNEL_MODS="no"
ARG DOCKER="no"
ARG CRON_UPDATE="yes"
ENV IP_PRIVATE="10.0.0.1/24"
ARG IP_PRIVATE="10.0.0.1/24"
# Set Timezone
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
# Make Dirs
RUN mkdir -p /etc/ansible /root/.kube /etc/sshd
# Copy Files
COPY . /opt/core
COPY configs/hosts.yml /etc/ansible/hosts
# Move to working Directory
WORKDIR /opt/core
# Install Core Components
RUN apt-get update && apt-get install -y python3 python3-pip && apt-get clean
RUN pip3 install ansible lxml &&  ansible-galaxy collection install community.general
# setup Ansible config
RUN echo "[defaults]" > /etc/ansible/ansible.cfg && echo "host_key_checking = False" >> /etc/ansible/ansible.cfg
# Build backdrop
RUN ansible-playbook /opt/core/upstart.yml -c local --skip-tags metal,run,exec
# Run and Execute live
ENTRYPOINT ["ansible-playbook","/opt/core/upstart.yml","-c local", "-t run,exec"]
