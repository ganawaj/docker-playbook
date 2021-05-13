#! /bin/bash

# Stop on errors 
set -e

#! /bin/bash

[[ -f /root/.ssh/id_rsa ]] && chmod 600 /root/.ssh/id_rsa
[[ -f /root/.ssh/id_rsa.pub ]] && chmod 644 /root/.ssh/id_rsa.pub

if [[ -f /ansible/playbooks/roles/requirements.yml ]]; then

    echo "requirements.yml found - installing roles"
    ansible-galaxy install -r /ansible/playbooks/roles/requirements.yml
fi

if [[ -f "/.vault-token" ]]; then

    export VAULT_TOKEN=$(cat /.vault-token)
    ssh-keygen -q -t rsa -C "$SSH_CERT_USER" -N '' -f $HOME/.ssh/id_rsa
    vault write -field=signed_key "$VAULT_SSH_SIGNER_PATH" public_key=@$HOME/.ssh/id_rsa.pub > $HOME/.ssh/id_rsa-cert.pub

else

    echo "No Vault token found. Populate /.vault-token to use vault token authentication."

fi

ansible-playbook "$@"

