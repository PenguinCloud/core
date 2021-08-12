FROM ubuntu
LABEL maintainer="Penguinz Media Group LLC"
COPY . /opt/baseline-ansible-setup
RUN apt-get update && apt-get install -y python3 openssh-server python3-pip cron && apt-get clean
RUN pip3 install ansible lxml
RUN ansible-galaxy collection install community.general
ENV runmode="docker"
ENTRYPOINT ["bash","/opt/baseline-ansible-setup/setup.sh"]