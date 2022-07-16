To set up a test environment for iqube:

    cp terraform.tfvars{-example,}
    vi terraform.tfvars # populate api_key
    terraform apply -var tag="Support - iqube, ${USERNAME}" -var prefix="${USERNAME}" -var ssh_public_key=$HOME/.ssh/id_ed25519.pub

https://registry.terraform.io/providers/vultr/vultr/latest/docs
