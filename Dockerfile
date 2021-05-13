FROM ubuntu

ENV ANSIBLE_GATHERING smart
ENV ANSIBLE_HOST_KEY_CHECKING false
ENV ANSIBLE_RETRY_FILES_ENABLED false
ENV ANSIBLE_ROLES_PATH /ansible/playbooks/roles
ENV ANSIBLE_SSH_PIPELINING True
ENV PATH /ansible/bin:$PATH
ENV PYTHONPATH /ansible/lib

ENV VAULT_ADDR=''

ARG VAULT_VERSION='1.5.5'

RUN apt update -y
RUN apt-get install curl ansible iputils-ping openssh-client -y
RUN apt-get install git unzip -y 

# Vault & JQ.
RUN \
  apt-get update && \
  apt-get install -y \
    jo \
    jq \
    libcap-dev \
    tar

RUN \ 
  curl --silent --remote-name https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip && \
  unzip vault_${VAULT_VERSION}_linux_amd64.zip && \
  chown root:root vault && \ 
  mv vault /usr/local/bin/

COPY ./src/ansible_playbook.sh /root/ansible_playbook.sh
RUN chmod +x /root/ansible_playbook.sh

RUN mkdir /ansible
RUN echo "[local]" >> /etc/ansible/hosts && \
    echo "localhost" >> /etc/ansible/hosts

RUN mkdir -p /ansible/playbooks
RUN mkdir /ansible/playbooks/roles

# Cleanup.
RUN \
  apt-get clean && \
  rm -fr /var/lib/apt/lists/* && \
  rm -fr /tmp/*

# Avoid hostkey error for git cloning by using:
#   ssh-keyscan -t rsa github.com >> /root/.ssh/known_hosts
RUN \
  mkdir -p /root/.ssh && \
  chmod 700 /root/.ssh && \
  touch /root/.ssh/known_hosts && \
  chmod 600 /root/.ssh/known_hosts && \
  # Fix for git 'hostkey validation failed' error.
  ssh-keyscan github.com >> /root/.ssh/known_hosts

WORKDIR /ansible/playbooks

ENTRYPOINT ["/root/ansible_playbook.sh"]