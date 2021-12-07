FROM ubuntu
LABEL maintainer="Penguin Tech Group LLC"
COPY . /opt/core
ARG TZ=America/Chicago
ENV TZ=America/Chicago
ARG DNS="1.1.1.1"
ENV PUBLIC_INTERFACE="enp1s0"
ENV INTERNAL_INTERFACE="enp6s0"
ARG KERNEL_MODS="no"
ARG DOCKER="no"
ARG CRON_UPDATE="yes"
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN mkdir -p /etc/ansible /root/.kube /etc/sshd
RUN apt-get update && apt-get install -y python3 openssh-server python3-pip cron && apt-get clean
RUN pip3 install ansible lxml awxkit
RUN ansible-galaxy collection install community.general
RUN ansible-galaxy install kwoodson.yedit
COPY ./vars/hosts.yml /etc/ansible/hosts
RUN echo "[defaults]" > /etc/ansible/ansible.cfg && echo "host_key_checking = False" >> /etc/ansible/ansible.cfg
RUN ansible-playbook /opt/core/upstart.yml -c local --skip-tags metal,run,exec
ENTRYPOINT ["ansible-playbook","/opt/core/upstart.yml","-c local", "--skip-tags metal,build"]
