#!/bin/bash
#

if [[ ! -f vultr/terraform.tfvars ]]; then
    
  ./user_input.sh

  terraform -chdir=vultr init  #Initialize terraform
  terraform -chdir=vultr apply

else 

  terraform -chdir=vultr apply
  #if [ -z "$VPC_ID" ]; then
      #terraform -chdir=vultr apply -var region="$selected_region" -var tag="${USERNAME}" -var prefix="${USERNAME}" -var VULTR_API_KEY="$VULTR_API_KEY" -var ssh_public_key="$ssh_public_key" -var compute_nodes="$compute_nodes" -var control_nodes="$control_nodes" -var admin_nodes="$admin_nodes" -var firewall_group_id="$firewall_group_id"
  #else
    # terraform -chdir=vultr apply -var region="$selected_region" -var cluster_vpc_id="$VPC_ID" -var tag="${USERNAME}" -var prefix="${USERNAME}" -var VULTR_API_KEY="$VULTR_API_KEY" -var ssh_public_key="$ssh_public_key" -var compute_nodes="$compute_nodes" -var control_nodes="$control_nodes" -var admin_nodes="$admin_nodes" -var firewall_group_id="$firewall_group_id"
  #fi
fi    


##################################################################################################################################
# Create hosts.yaml file
##################################################################################################################################
echo " "
echo "===================================================================================================="
echo "Generating hosts.yaml file"
echo "===================================================================================================="
echo " "

./generate_hosts.sh

##################################################################################################################################
# Check for Ansible
##################################################################################################################################

echo " "
echo "===================================================================================================="
echo "Ansible is a prerequisite for this installation"
echo " "
echo "Checking if ansible is installed"
echo "===================================================================================================="
echo " "


# Function to install Ansible using apt
install_ansible_apt() {
    sudo apt update
    sudo apt install -y ansible
}

# Function to install Ansible using yum
install_ansible_yum() {
    sudo yum install -y epel-release
    sudo yum install -y ansible
}

# Function to install Ansible using dnf
install_ansible_dnf() {
    sudo dnf install -y ansible
}

# Function to install Ansible using Homebrew
install_ansible_brew() {
    brew install ansible
}

# Check if Ansible is installed
if command -v ansible >/dev/null 2>&1; then
    echo "Ansible is installed."
    ansible --version
else
    echo "Ansible is not installed."
    read -p "Do you want to install Ansible? (yes/no): " choice
    if [[ "$choice" == "yes" ]]; then
        # Determine the package manager and install Ansible
        if command -v apt >/dev/null 2>&1; then
            install_ansible_apt
        elif command -v yum >/dev/null 2>&1; then
            install_ansible_yum
        elif command -v dnf >/dev/null 2>&1; then
            install_ansible_dnf
        elif command -v brew >/dev/null 2>&1; then
            install_ansible_brew
        else
            echo "Unsupported package manager. Please install Ansible manually."
            exit 1
        fi

        # Verify installation
        if command -v ansible >/dev/null 2>&1; then
            echo "Ansible has been installed successfully."
            ansible --version
        else
            echo "Failed to install Ansible. Please check your package manager and try again."
        fi
    else
        echo "Ansible installation aborted by the user."
    fi
fi


##################################################################################################################################
# Sending outputs to the user
##################################################################################################################################

echo " "
echo "===================================================================================================="
echo "Ansible has been installed successfully and hosts.yaml file has been generated with the necesary inputs"
echo " "
echo "To continue deploying fuzzball to the recently created vultr instances please run the following comands"
echo "===================================================================================================="
echo " "
printf "You can run '\033[32mexport ANSIBLE_HOST_KEY_CHECKING=False'\033[0m to ignore ssh host keys\n"
echo " "
echo "ansible-playbook --inventory hosts.yaml setup-rke2-and-fuzzball.yaml"
echo " "
echo "ansible-playbook --inventory hosts.yaml setup-keycloak.yaml"
echo " "
echo " "
