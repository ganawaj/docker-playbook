FROM ubuntu

RUN apt update -y
RUN apt-get install curl ansible iputils-ping openssh-client -y
RUN apt-get install git unzip -y 

RUN curl --silent --remote-name https://releases.hashicorp.com/vault/1.5.5/vault_1.5.5_linux_amd64.zip

RUN unzip vault_1.5.5_linux_amd64.zip
RUN chown root:root vault
RUN mv vault /usr/local/bin/

# RUN apt-get install gnupg2 -y
# RUN apt-get install software-properties-common -y

# RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
# RUN apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
# RUN apt-get install vault -y

# RUN \
#   apt install \
#     curl \
#     openssh-client \
#     python \
#     py-boto \
#     py-dateutil \
#     py-httplib2 \
#     py-jinja2 \
#     py-paramiko \
#     py-pip \
#     py-setuptools \
#     py-yaml \
#     tar && \
#   pip install --upgrade pip python-keyczar && \

COPY ./src/ansible_playbook.sh /root/ansible_playbook.sh
RUN chmod +x /root/ansible_playbook.sh

RUN mkdir /ansible
RUN echo "[local]" >> /etc/ansible/hosts && \
    echo "localhost" >> /etc/ansible/hosts

# RUN \
#   curl -fsSL https://releases.ansible.com/ansible/ansible-${VERSION}.tar.gz -o ansible.tar.gz && \
#   tar -xzf ansible.tar.gz -C ansible --strip-components 1 && \
#   rm -fr ansible.tar.gz /ansible/docs /ansible/examples /ansible/packaging

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