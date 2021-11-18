#! /bin/sh

# Stop on errors
set -e

if [ -f /ansible/playbooks/roles/requirements.yml ]; then

    echo "requirements.yml found - installing roles"
    ansible-galaxy install -r /ansible/playbooks/roles/requirements.yml
fi


ssh-keygen -q -t rsa -C "$SSH_CERT_USER" -N '' -f $HOME/.ssh/id_rsa
vault write -field=signed_key "$VAULT_SSH_SIGNER_PATH" public_key=@$HOME/.ssh/id_rsa.pub > $HOME/.ssh/id_rsa-cert.pub


ansible-playbook "$@"