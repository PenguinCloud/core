FROM ubuntu:20.04
LABEL maintainer="Penguin Technologies Group LLC"

# Set Timezone
ARG TZ=America/Chicago
ENV TZ=America/Chicago
ARG CRON_UPDATE="yes"

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
# Make Dirs
RUN mkdir -p /etc/Ansible

# Copy Files
COPY . /opt/core
COPY configs/hosts.yml /etc/ansible/hosts
COPY configs/ansible.cfg /etc/ansible/ansible.cfg
COPY configs/sudoers /etc/sudoers

# Move to working Directory
WORKDIR /opt/core

# Install Core Components
RUN apt-get update && apt-get install -y python3 python3-pip python3-apt openssh-client && apt-get autoremove -y
RUN pip3 install ansible lxml \
RUN ansible-galaxy collection install community.general

# Build backdrop
RUN ansible-playbook /opt/core/build.yml --connection=local

# Run and Execute live
ENTRYPOINT ["/usr/bin/bash","entrypoint.sh"]
