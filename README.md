# fuzzball-ansible deployment automation

`fuzzball-ansible` automates the process of deploying Fuzzball test
environments, and [includes Terraform code for provisioning necessary
test resources on Vultr.][vultr]

[vultr]: vultr/README.md


## Prepare an inventory

This guide assumes that your host inventory is recorded in
`hosts.yaml`. Start a new inventory by copying from the provided
example.

    cp hosts.yaml-example hosts.yaml # customize hosts.yaml
    
If your hosts are not defined by name in DNS, `/etc/hosts`, or
`.ssh/config`, define their IP address with `ansible_host`.

For more general information, read [How to build your
inventory][ansible_inventory].

[ansible_inventory]: https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html

See the comments in `hosts.yaml-example` for more information on
available inventory variables.

### Playbooks

A kubernetes-substrate deployment uses the following playbooks:

* `setup-rke2-and-fuzzball.yaml`
  * Deploy an NFS share on admin nodes.
  * Deploy RKE2, the Fuzzball operator, and Fuzzball Orchestrate on
    control nodes.
  * Deploy Fuzzball Substrate on compute nodes.
  * Install the Fuzzball CLI on all nodes.
* `setup-keycloak.yaml`
  * install Keycloak on admin nodes for testing external Keycloak
    support.

```shell

ansible-playbook setup-rke2-and-fuzzball.yaml --inventory hosts.yaml
```

### See also

* [Fuzzball Cluster Admin Guide][cluster-admin-guide]
* [Deploying a local RKE2 environment for Fuzzball deployment testing][deploy-rke2]
* [Using the Fuzzball Operator][using-fuzzball-operator]
* [Deploying Fuzzball Substrate][deploy-fuzzball-substrate]

[cluster-admin-guide]: https://beta.fuzzball.io/docs/cluster-admin-guide/
[deploy-rke2]: https://ciqinc.atlassian.net/wiki/spaces/ENG/pages/684720192/Deploying+a+local+RKE2+environment+for+Fuzzball+deployment+testing
[using-fuzzball-operator]: https://ciqinc.atlassian.net/wiki/spaces/ENG/pages/786235424/Using+the+Fuzzball+Operator
[deploy-fuzzball-substrate]: https://ciqinc.atlassian.net/wiki/spaces/ENG/pages/803733505/Deploying+Fuzzball+Substrate

## Notes

- Changes to interface zones cannot be made permanent because of
  configuration conflicts between cloud-init, NetworkManager, and
  firewalld. As such, these playbooks make ephemeral firewalld changes
  only, and must be re-run after reboot.

## To do

- provision provider build env
  - direnv (on admin)
  - bazelisk (on admin)
- configure default nfs storage
  - ephemeral
  - persistent
