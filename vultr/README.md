To set up a test environment:

    cp terraform.tfvars{-example,}
    vi terraform.tfvars # populate api_key
    terraform apply -var tag="${USERNAME}" -var prefix="${USERNAME}" -var ssh_public_key=$HOME/.ssh/id_ed25519.pub -var compute_nodes=1

Once the environment has been provisioned, `terraform show`
will display the provisioned state, including assigned ip
addresses.

https://registry.terraform.io/providers/vultr/vultr/latest/docs

## CIQ-specific data

This terraform configuration can be supplied with some variables that are specific to a local Vultr account. For example, the following values may be placed in a `ciq-defaults.auto.tfvars` file to use CIQ-local references:

```
firewall_group_id = "6d5385a0-dace-43ce-ad6a-6d7e09f9185c"
cluster_vpc_id = "449b512b-1076-44c6-a43b-498ad46ce7a1"
```

Specifying `cluster_vpc_id` causes the cluster (internal) VPC to use an existing VPC rather than attempt to generate a dedicated VPC. This may be required in some instances where the number of VPCs is limited.

Specifying `firewall_group_id` configures provisioned nodes' public network interfaces with CIQ-standard firewall rules (e.g., allowing inbound SSH).
