#! /bin/bash
chmod 600 /root/.ssh/id_rsa
chmod 644 /root/.ssh/id_rsa.pub

[[ -f /ansible/playbooks/roles/requirements.yml ]] && ansible-galaxy install -r /ansible/playbooks/roles/requirements.yml

ansible-playbook "$@"