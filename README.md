# iqube-ansible deployment automation

`iqube-ansible` automates the process of deploying Fuzzball test
environments with IQube, and [includes Terraform code for provisioning
necessary test resources on Vultr.][vultr]

[vultr]: vultr/README.md


## Prepare an inventory

This guide assumes that your host inventory is recorded in
`hosts.yaml`. Start a new inventory by copying from the provided
example.

    cp hosts.yaml-example hosts.yaml # customize hosts.yaml
    
If your hosts are not defined by name in DNS or `.ssh/config`, define
their IP address with `ansible_host`.

For more general information, read [How to build your
inventory][ansible_inventory].

[ansible_inventory]: https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html


## kubernetes-substrate

A default IQube deployment of Fuzzball targets a Kubernetes cluster
deployed on top of Fuzzball Substrate.

### Inventory variables

* Identify the `cluster_interface` for each admin and controller
  node. (Interface name, not IP address. Allows firewalld to be
  appropriately configured.)
* Identify the `public_interface` for each controller and compute
  node. (Interface name, not IP address. Allows firewalld to be
  appropriately configured.)
  
Also check, define, and/or update variables in `hosts.yaml` as
necessary. In particular, review variables in the "All deployments"
and "kubernetes-substrate deployments" sections.

### Playbooks

A kubernetes-substrate deployment uses the following playbooks:

* `setup-iqube.yaml`
  * installs IQube on admin hosts
  * initializes a kubernetes-substrate IQube context on admin hosts at
    `/root/iqube-kubernetes/substrate`
  * exports an NFS share from admin hosts
  * starts standalone Fuzzball Substrate on controller hosts
* `setup-fuzzball.yaml`
  * installs the Fuzzball CLI
  * starts Fuzzball Substrate on compute hosts
  

When executing playbooks, provide a value for `mtn_access_key` to
allow packages and deployment artifacts to be fetched from Mountain.

```shell

ansible-playbook setup-iqube.yaml --inventory hosts.ini \
    --extra-vars="mtn_access_key=<key>"

ansible-playbook setup-fuzzball.yaml --inventory hosts.ini \
    --extra-vars="mtn_access_key=<key>"
```

### See also

* [Fuzzball Cluster Admin Quick Start][fuzzball-admin-docs]

[fuzzball-admin-docs]: https://integration.ciq.dev/docs/cluster-admin-guide/cluster-admin-quickstart/


## RKE2

IQube may also deploy Fuzzball into an existing RKE2 cluster using
`kubernetes-bootstrap`.

### Inventory variables

In addition to the host variables defined for "Prepare an inventory"
and the `cluster_interface` and `public_interface` variables defined
in the "kubernetes-substrate" section, also check, define, and/or
update variables in `hosts.yaml` in the "kubernetes-bootstrap / RKE2
deployments" section.

### Playbooks

In addition to the playbooks from the "kubernetes-substrate" section,
a kubernetes-bootstrap deployment uses the following playbooks:

* `setup-rke2.yaml`
  * installs and initializes RKE2 on controller hosts
  * installs IQube on controller hosts (because the provided
    kubernetes-bootstrap `iqube.yaml` references local
  * initializes a kubernetes-bootstrap IQube context on controller
    hosts at `/root/iqube-kubernetes-bootstrap`
  
(`setup-rke2.yaml` does not create a single multi-node cluster if more
than one control node is provided: each provided control node is its
own single-node cluster.)


```shell

ansible-playbook setup-iqube.yaml --inventory hosts.ini \
    --extra-vars="mtn_access_key=<key>"

ansible-playbook setup-fuzzball.yaml --inventory hosts.ini \
    --extra-vars="mtn_access_key=<key>"
    
ansible-playbook setup-rke2.yaml --inventory hosts.ini \
    --extra-vars="mtn_access_key=<key>"
```

kubernetes-bootstrap is deployed from an RKE2 control node; so this
playbook also deploys IQube to the control node.

If the database fails to provision during `iqube provision up`, run

    restorecon /var/lib/fuzzball/compute

and try again.

### See also

* [Deploying a local RKE2 environment for Fuzzball deployment testing][deploy-rke2]
* [Deploying Fuzzball Orchestrate on an existing RKE2 cluster with IQube][fuzzball-on-rke2]

[deploy-rke2]: https://ciqinc.atlassian.net/wiki/spaces/ENG/pages/684720192/Deploying+a+local+RKE2+environment+for+Fuzzball+deployment+testing
[fuzzball-on-rke2]: https://ciqinc.atlassian.net/wiki/spaces/ENG/pages/684883988/Deploying+Fuzzball+Orchestrate+on+an+existing+RKE2+cluster+with+IQube


## Keycloak

Fuzzball may also use an external Keycloak. The `setup-keycloak.yaml`
playbook provisions Keycloak onto admin hosts.

    ansible-playbook setup-keycloak.yaml --inventory hosts.ini \
        --extra-vars="mtn_access_key="
        
See the "Keycloak" section of `hosts.yaml` for configuration
parameters.


## Notes

- Changes to interface zones cannot be made permanent because of
  configuration conflicts between cloud-init, NetworkManager, and
  firewalld. As such, these playbooks make ephemeral firewalld changes
  only, and must be re-run after reboot.


## To do

- Update generated iqube.yaml to use external Keycloak if provisioned
- why does RKE2 database fail to provision / restorecon not work?
- provision provider build env
  - direnv (on admin)
  - bazelisk (on admin)
- configure default nfs storage
  - ephemeral
  - persistent
