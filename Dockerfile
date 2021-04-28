FROM ubuntu

RUN apt update -y
RUN apt install curl ansible iputils-ping openssh-client -y
RUN apt install git unzip -y 
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