# Ansible-Playbook 

A Docker container for the purpose of running ansible-playbook

### Configuration

#### Vault Token

Vault token to use in all Vault related operations.

* `VAULT_TOKEN` Environment variable.
* `/.vault-token` File containing token mounted into container.

## Usage

Run a playbook!
_Note: This example assumes the playbook name is `playbook.yml` and the server to run it against is `server1`._

```shell
docker run --rm \
  --privileged \
  -v "${HOME}/.vault-token:/.vault-token" \
  -v "$(pwd)/test:/ansible/playbooks" \
  ganawa/ansible_playbook:latest -- \
  -i "server1," \
  playbook.yml
```