# fuzzball-ansible deployment automation

`fuzzball-ansible` automates the process of deploying Fuzzball test
environments and [includes Terraform code for provisioning necessary
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

## Playbooks

`fuzzball-ansible` provides ready-to-run playbooks that can be used to deploy Fuzzball into an existing environment.

Example:

```shell

ansible-playbook ciq.fuzzball.deploy_orchestrate --inventory hosts.yaml
```

These playbooks may also be used as examples to start an Ascender or AWX project.

### ciq.fuzzball.deploy_fuzzball_orchestrate

Deploy Fuzzball Orchestrate on `fuzzball_controller` nodes.
This playbook automatically deploys the Fuzzball operator into the target Kubernetes cluster to manage the Fuzzball Orchestrate deployment.

### ciq.fuzzball.deploy_fuzzball_substrate

Deploy Fuzzball Substrate on `fuzzball_compute` nodes.
Also configures an NFS client to access configuration published by Fuzzball Orchestrate.

### ciq.fuzzball.deploy_fuzzball_cli

Install the Fuzzball CLI on all nodes in the inventory.

### ciq.fuzzball.deploy_nfs_server

Deploy an NFS share on fuzzball_nfs_server nodes.
Fuzzball Orchestrate uses this share to publish configuration for Fuzzball Substrate to consume,
and Fuzzball Substrate uses this share to cache container images.
This share may also be used as backing storage for Fuzzball storage classes.

### ciq.fuzzball.deploy_rke2

Deploy a single-node RKE2 "cluster" on `fuzzball_controller` nodes as an installation target for Fuzzball Orchestrate.
Also installs the local path provisioner and metallb.

See also: `ciq.fuzzball.deploy_nfs_server`

## See also

- [Fuzzball Cluster Admin Guide][cluster-admin-guide]
- [Deploying a local RKE2 environment for Fuzzball deployment testing][deploy-rke2]
- [Using the Fuzzball Operator][using-fuzzball-operator]
- [Deploying Fuzzball Substrate][deploy-fuzzball-substrate]

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
