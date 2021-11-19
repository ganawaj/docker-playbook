FROM alpine

ENV ANSIBLE_GATHERING smart
ENV ANSIBLE_HOST_KEY_CHECKING false
ENV ANSIBLE_RETRY_FILES_ENABLED false
ENV ANSIBLE_ROLES_PATH /ansible/playbooks/roles
ENV ANSIBLE_SSH_PIPELINING True
ENV PATH /ansible/bin:$PATH
ENV PYTHONPATH /ansible/lib

RUN apk add --update curl iputils openssh git unzip py3-pip && \
    apk add --update ansible && \
    apk add --update jo jq libcap-dev tar

RUN apk add --update vault libcap
RUN setcap cap_ipc_lock= /usr/sbin/vault

RUN pip install docker

COPY ./src/ansible_playbook.sh /root/ansible_playbook.sh
RUN chmod +x /root/ansible_playbook.sh

RUN mkdir -p /ansible/playbooks/roles && \
    mkdir -p /etc/ansible

RUN echo "[local]" >> /etc/ansible/hosts && \
    echo "localhost" >> /etc/ansible/hosts

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