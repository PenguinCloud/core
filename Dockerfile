FROM ubuntu
LABEL maintainer="Penguinz Media Group LLC"
COPY . /opt/baseline-ansible-setup
ENV TZ=America/Chicago
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN mkdir -p /etc/ansible /root/.kube /etc/sshd
RUN apt-get update && apt-get install -y python3 openssh-server python3-pip cron && apt-get clean
RUN pip3 install ansible lxml
RUN ansible-galaxy collection install community.general
RUN ansible-galaxy install kwoodson.yedit
COPY ./configs/hosts.yaml /etc/ansible/hosts
RUN echo "[defaults]" > /etc/ansible/ansible.cfg && echo "host_key_checking = False" >> /etc/ansible/ansible.cfg
ENV runmode="docker"
CMD ansible-playbook /opt/baseline-ansible-setup/upstart.yaml -c local