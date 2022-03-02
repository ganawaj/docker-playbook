# Ansible-Playbook

A Docker container for the purpose of running ansible-playbook

### Configuration

#### Vault Token

Vault token to use in all Vault related operations.

* `VAULT_TOKEN` Environment variable.
* `/.vault-token` File containing token mounted into container.

If you intend to use vault certificate signing, you must pass a private key (as described below)
or set `SSH_CERT_USER` and a private key will be generated with this user.

#### Private Key

You can also disable certificate signing by setting `USE_CERT_SIGNING` to 0.

A private key can then be passed to ansible by either:

* Mounting a private key to `/root/.ssh/id_rsa`
* Passing a base64 encoded private key to the environmental variable `B64_ID_RSA`

_Note: If you choose to mount a private key, you must set the correct permissions. The container will not attempt to modify keys.

## Usage

Run a playbook!
_Note: This example assumes the playbook name is `playbook.yml` and the server to run it against is `server1`._

### VAUL TOKEN

```shell
docker run --rm \
  -v "${HOME}/.vault-token:/.vault-token" \
  -v "$(pwd)/test:/ansible/playbooks" \
  ganawa/ansible_playbook:latest playbook.yml \
  -i "server1,"
```

Alternatively:

```shell
docker run --rm \
  -e VAULT_TOKEN=KLSJDLKSJD...
  -v "$(pwd)/test:/ansible/playbooks" \
  ganawa/ansible_playbook:latest playbook.yml \
  -i "server1,"
```

### No certificate signing

```shell

echo "privatekey" | base64

docker run --rm
  -e USE_CERT_SIGNING=0 \
  -e B64_ID_RSA="cHJpdmF0ZWtleQo=" \
  -v "$(pwd)/test:/ansible/playbooks" \
  ganawa/ansible_playbook:latest playbook.yml \
  -i "server1,"
```

Alternatively:

```shell
docker run --rm
  -e USE_CERT_SIGNING=0 \
  -v "~/.ssh/id_rsa:/root/.ssh/id_rsa" \
  -v "$(pwd)/test:/ansible/playbooks" \
  ganawa/ansible_playbook:latest playbook.yml \
  -i "server1,"
```