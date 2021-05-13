FROM ubuntu

RUN apt update -y
RUN apt-get install curl ansible iputils-ping openssh-client -y
RUN apt-get install git unzip -y 

RUN curl --silent --remote-name https://releases.hashicorp.com/vault/1.5.5/vault_1.5.5_linux_amd64.zip

RUN unzip vault_1.5.5_linux_amd64.zip
RUN chown root:root vault
RUN mv vault /usr/local/bin/

COPY ./src/ansible_playbook.sh /root/ansible_playbook.sh
RUN chmod +x /root/ansible_playbook.sh

RUN mkdir /ansible
RUN echo "[local]" >> /etc/ansible/hosts && \
    echo "localhost" >> /etc/ansible/hosts

RUN mkdir -p /ansible/playbooks
RUN mkdir /ansible/playbooks/roles

WORKDIR /ansible/playbooks

ENV ANSIBLE_GATHERING smart
ENV ANSIBLE_HOST_KEY_CHECKING false
ENV ANSIBLE_RETRY_FILES_ENABLED false
ENV ANSIBLE_ROLES_PATH /ansible/playbooks/roles
ENV ANSIBLE_SSH_PIPELINING True
ENV PATH /ansible/bin:$PATH
ENV PYTHONPATH /ansible/lib

ENTRYPOINT ["/root/ansible_playbook.sh"]