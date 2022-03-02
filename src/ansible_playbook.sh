#!/bin/sh

# Stop on errors
set -e

# variables
WRITE_KEY="${WRITE_KEY:=0}"
USE_CERT_SIGNING="${USE_CERT_SIGNING:=1}"
PRIV_KEY_PASSED="${PRIV_KEY_PASSED:=0}"


# check for passed private key
if [[ ! -z "${B64_ID_RSA}" ]]; then
    echo "Private key passed as env variable."
    PRIV_KEY_PASSED=1
    WRITE_KEY=1
fi

if [[ -f $HOME/.ssh/id_rsa ]]; then
    echo "Existing private key exist. Mounted private key will take precedence."
    PRIV_KEY_PASSED=1
    WRITE_KEY=0
fi

# if a private key is not already passed, check for cert user to sign for
if [[ $USE_CERT_SIGNING -eq 1 && $PRIV_KEY_PASSED -eq 0 && -z "${SSH_CERT_USER}" ]]; then
    echo "$USE_CERT_SIGNING SSH_CERT_USER unset. Set to use ssh certificate signing."
    return 1
fi

# if signing, check for vault token
if [[ $USE_CERT_SIGNING -eq 1 && -z "${VAULT_TOKEN}" ]]; then
    echo "No vault token found. Please set VAULT_TOKEN env to use ssh certificate signing"
    return 1
fi

# if signing check vault ssh-signer path
if [[ $USE_CERT_SIGNING -eq 1 && -z "${VAULT_SSH_SIGNER_PATH}"]]; then
    echo "VAULT_SSH_SIGNER_PATH unset. Set to use ssh certificate signing."
    return 1
fi

sign_key(){

    if [[ $PRIV_KEY_PASSED -eq 0 ]]; then
        ssh-keygen -q -t rsa -C "$SSH_CERT_USER" -N '' -f $HOME/.ssh/id_rsa
    fi

    vault write -field=signed_key "$VAULT_SSH_SIGNER_PATH" public_key=@$HOME/.ssh/id_rsa.pub > $HOME/.ssh/id_rsa-cert.pub

}

# Write priate key passed to file
if [[ $WRITE_KEY -eq 1 ]]; then
    echo "$B64_ID_RSA" | base64 -d >> $HOME/.ssh/id_rsa
    # echo "$ID_RSA" >> $HOME/.ssh/id_rsa
    chmod 600 $HOME/.ssh/id_rsa
fi

[[ $USE_CERT_SIGNING -eq 1 ]] &&
    sign_key

if [ -f /ansible/playbooks/roles/requirements.yml ]; then

    echo "requirements.yml found - installing roles"
    ansible-galaxy install -r /ansible/playbooks/roles/requirements.yml
fi

if [ -f /ansible/playbooks/requirements.yml ]; then

    echo "requirements.yml found - installing roles"
    ansible-galaxy install -r /ansible/playbooks/requirements.yml
fi

ansible-playbook "$@"