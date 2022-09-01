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


# Move to working Directory
WORKDIR /opt/core

# Install Core Components
# hadolint ignore=DL3008,DL3009,DL3013
RUN apt-get update && apt-get upgrade -y &&  apt-get install --no-install-recommends -y python3 python3-pip openssh-client  && apt-get autoremove -y && pip3 install --no-cache-dir --upgrade pip
RUN pip3 install --no-cache-dir -r requirements3.txt  && ansible-galaxy collection install community.general && pip install --no-cache-dir -r requirements2.txt

ARG APP_TITLE="ptg-docker-core"
ENV APP_TITLE="ptg-docker-core"
# Build backdrop
RUN ansible-playbook /opt/core/build.yml --connection=local

# Run and Execute live
ENTRYPOINT ["/usr/bin/bash","entrypoint.sh"]
