# fuzzball-ansible deployment automation

`fuzzball-ansible` automates the process of deploying Fuzzball test
environments, and [includes Terraform code for provisioning necessary
test resources on Vultr.][vultr]

[vultr]: vultr/README.md


## Generate the hosts.yaml file

To generate the hosts.yaml file we need to run the script `terraform.sh` without options.

This script will gather all the necesary input to deploy the vultr instances using the terraform code.

```shell
./terraform.sh
```

You can use `--help` for other options
```shell
$ ./terraform.sh -h
Usage: ./terraform.sh [options]
Options:
  --apply       Apply Terraform configuration but do not run wizard
  --destroy     Destroy Terraform-managed infrastructure
  --hosts       Generate hosts.yaml file but do not run wizard
  --wipe        Wipe tfvars and .env.sh
  -d, --domain  Used with --hosts will change the default nip.io to this domain
  -h, --help      Display this help message
```


For more general information, read [How to build your
inventory][ansible_inventory].

[ansible_inventory]: https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html

See the comments in `hosts.yaml-example` for more information on
available inventory variables.

### Playbooks

A kubernetes-substrate deployment uses the following playbook:

* `setup-rke2-and-fuzzball.yaml`
  * Deploy an NFS share on admin nodes.
  * Deploy RKE2, the Fuzzball operator, and Fuzzball Orchestrate on
    control nodes.
  * Deploy Fuzzball Substrate on compute nodes.
  * Install the Fuzzball CLI on all nodes.

```shell

ansible-playbook setup-rke2-and-fuzzball.yaml --inventory hosts.yaml
```  

#### Keycloak

Keycloak should get installed along with the fuzzball operator. In case you want to install Keycloak on a different instance you can run the following plabook. Please be aware that you will need to add the Realm manually.

* `setup-keycloak.yaml`
  * install Keycloak on admin nodes for testing external Keycloak
    support.

```shell

ansible-playbook setup-keycloak.yaml --inventory hosts.yaml
```  

### UI Access

To access UI please create a dynamic proxy via ssh.

```shell
ssh -A -D 5900 <Controller_Node_IP>
```
For the SOCKS proxy settings in your browser (the example here is Firefox), go to Network Settings →  Manual proxy configuration. Set the SOCKS proxy settings as localhost and port 5900 (the port number used is arbitrary, as long as it matches the port used in the prior ssh command).

Use the Fuzzball UI URL that you received from running

```shell

./terraform.sh --data
```

Navigate to the URL in your browser. To login, you need the Fuzzball Admin credentials in thi scase use admin@ciq.com\password.

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


Create a dynamic proxy via ssh.



ssh -A -D 5900 <Controller_Node_IP>
For the SOCKS proxy settings in your browser (the example here is Firefox), go to Network Settings →  Manual proxy configuration. Set the SOCKS proxy settings as localhost and port 5900 (the port number used is arbitrary, as long as it matches the port used in the prior ssh command).

Open Screenshot from 2024-05-23 17-03-24.png
Screenshot from 2024-05-23 17-03-24.png
 

Open Screenshot from 2024-05-23 17-10-29.png
Screenshot from 2024-05-23 17-10-29.png
Use the Fuzzball UI URL that you received from iqube provision info.

Navigate to the URL in your browser. To login, you need the Fuzzball Admin credentials from iqube provision info.