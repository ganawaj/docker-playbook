FROM alpine

ARG ANSIBLE_VERSION

ENV ANSIBLE_GATHERING smart
ENV ANSIBLE_HOST_KEY_CHECKING false
ENV ANSIBLE_RETRY_FILES_ENABLED false
ENV ANSIBLE_ROLES_PATH /ansible/playbooks/roles
ENV ANSIBLE_SSH_PIPELINING True
ENV PATH /ansible/bin:$PATH
ENV PYTHONPATH /ansible/lib

COPY ./src/ansible_playbook.sh /root/ansible_playbook.sh

RUN \
    # install dependencies
    apk add --update \
        curl \
        iputils \
        openssh \
        git \
        unzip \
        python3 \
        py3-pip \
        py3-cryptography && \
    apk add --update --virtual \
        .build-deps \
        python3-dev \
        libffi-dev \
        openssl-dev \
        build-base && \
    # upgrade pip and cffi
    pip3 install --upgrade \
        pip \
        cffi && \
    # install ansible
    pip3 install \
        ansible==${ANSIBLE_VERSION} && \
    # install ansible-docker dependencies
    pip3 install docker && \
    # install vault dependencies
    apk add --update \
        jo \
        jq \
        libcap \
        libcap-dev \
        tar && \
    # install vault
    apk add --update \
        vault && \
    setcap cap_ipc_lock= /usr/sbin/vault && \
    # cleanup packages
    apk del .build-deps && \
    rm -rf /var/cache/apk/*

RUN \
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