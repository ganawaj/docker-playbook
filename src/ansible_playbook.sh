#! /bin/bash
set -e

if [[ -f "/.vault-token" ]]; then

    export VAULT_TOKEN=$(cat /.vault-token)
    ssh-keygen -q -t rsa -C "$SSH_CERT_USER" -N '' -f $HOME/.ssh/id_rsa
    vault write -field=signed_key "$VAULT_SSH_SIGNER_PATH" public_key=@$HOME/.ssh/id_rsa.pub > $HOME/.ssh/id_rsa-cert.pub

else

    exit 1

fi

ansible-playbook "$@"

