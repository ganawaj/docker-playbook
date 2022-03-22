FROM alpine

ENV ANSIBLE_GATHERING smart
ENV ANSIBLE_HOST_KEY_CHECKING false
ENV ANSIBLE_RETRY_FILES_ENABLED false
ENV ANSIBLE_ROLES_PATH /ansible/playbooks/roles
ENV ANSIBLE_SSH_PIPELINING True
ENV PATH /ansible/bin:$PATH
ENV PYTHONPATH /ansible/lib

COPY ./src/ansible_playbook.sh /root/ansible_playbook.sh

RUN \
    # add apk edge community repo
    echo '@edge https://dl-cdn.alpinelinux.org/alpine/edge/community' >> /etc/apk/repositories && \
    apk update && \
    # install ansible and dependencies
    apk add --update curl iputils openssh git unzip py3-pip && \
    apk add --update ansible && \
    apk add --update jo jq libcap-dev tar && \
    # install vault and dependencies
    apk add --update vault libcap && \
    setcap cap_ipc_lock= /usr/sbin/vault && \
    # install ansible docker dependencies
    pip install docker && \
    # make entrypoint executable
    chmod +x /root/ansible_playbook.sh && \
    # create ansible folders
    mkdir -p /ansible/playbooks/roles && \
    mkdir -p /etc/ansible && \
    # pass localhost to hostfile
    echo "[local]" >> /etc/ansible/hosts && \
    echo "localhost" >> /etc/ansible/hosts && \
    # Avoid hostkey error for git cloning by using:
    #   ssh-keyscan -t rsa github.com >> /root/.ssh/known_hosts
    mkdir -p /root/.ssh && \
    chmod 700 /root/.ssh && \
    touch /root/.ssh/known_hosts && \
    chmod 600 /root/.ssh/known_hosts && \
    # Fix for git 'hostkey validation failed' error.
    ssh-keyscan github.com >> /root/.ssh/known_hosts

WORKDIR /ansible/playbooks

ENTRYPOINT ["/root/ansible_playbook.sh"]