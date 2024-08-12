#!/bin/bash
#

print_header() {
    local message="$1"
    
    # Get the width of the terminal
    local width=$(tput cols)
    
    # Generate the top and bottom lines of '#' characters
    local line=$(printf '%*s' "$width" '' | tr ' ' '=')

    # Print the header
    echo " "
    echo "$line"
    
    # Print each line of the message, centering it
    while IFS= read -r line_msg; do
        local padding=$(( (width - ${#line_msg}) / 2 - 1 ))
        printf "%*s%s%*s\n" "$padding" "" "$line_msg" "$padding" ""
    done <<< "$(echo -e "$message")"
    
    echo "$line"
    echo " "
    echo " "
}

function tfvars_output(){
    TF_OUTPUT=$(terraform -chdir=vultr output --json)
    domain="${domain:-nip.io}"
    substrate_nfs_subnet=$(echo "$TF_OUTPUT" | jq -r '.substrate_nfs_subnet.value')
    substrate_nfs_mount=$(echo "$TF_OUTPUT" | jq -r '.admin_nodes_private_ip.value.private_IP_admin1')
    metallb_lb_pub_ip=$(echo "$TF_OUTPUT" | jq -r '.controller_node_public_ips.value.public_IP_ctl1')
    metallb_lb_ip="${substrate_nfs_subnet%.*}.99"
    keycloak_ip=$(echo "$TF_OUTPUT" | jq -r '.admin_nodes_public_ip.value.public_IP_admin1')
    lb_pub_ip_dashed=${metallb_lb_pub_ip//\./-}
    lb_ip_dashed=${metallb_lb_ip//\./-}
    fz_domain="${lb_ip_dashed}.${domain}"
    keycloak_ip_dashed=${keycloak_ip//\./-}
    keycloak_domain="${keycloak_ip_dashed}.${domain}"
}


function user_input() {
    ####################################################################################################
    #Let's get some variables:
    ####################################################################################################

    print_header "Gathering information for the deployment"

    # Function to check for invalid characters
    contains_invalid_characters() {
        if [[ $1 =~ [^a-zA-Z0-9] ]]; then
        return 0
        else
        return 1
        fi
    }

    # Prompt user for username
    while true; do
        read -rp "Please enter your username (max 36 characters, alphanumeric only): " USERNAME
        
        # Check if the input is empty
        if [[ -z "$USERNAME" ]]; then
        echo "Input cannot be empty. Please try again."
        # Check if it contains invalid characters
        elif contains_invalid_characters "$USERNAME"; then
        echo "Input contains invalid characters. Please enter alphanumeric characters only."
        # Limit to 36 characters  
        elif [[ ${#USERNAME} -gt 36 ]]; then
        echo "Input exceeds 36 characters. Please try again."
        else
        echo " "
        echo "Your username is: $USERNAME"
        echo " "
        echo "prefix = \"$USERNAME\"" > vultr/terraform.tfvars
        echo "tag = \"$USERNAME\"" >> vultr/terraform.tfvars
        break
        fi
    done

    ####################################################################################################
    # Create a SSH key
    ####################################################################################################

    print_header "Checking if SSH Key exist"

    if [ -f "$HOME"/.ssh/id_rsa ]; then
        ssh_private_key="$HOME/.ssh/id_rsa"
    elif [ -f ~/.ssh/id_ecdsa ]; then
        ssh_private_key="$HOME/.ssh/id_ecdsa"
    elif [ -f ~/.ssh/id_ed25519 ]; then
        ssh_private_key="$HOME/.ssh/id_ed25519"
    else
        ssh_private_key=""
    fi

    if [ -n "$ssh_private_key" ] && [ -f "$ssh_private_key" ]; then
        # Set $ssh_public_key if key exists
        ssh_public_key="${ssh_private_key}.pub"
        echo " "
        echo "Using existing SSH key: $ssh_public_key for deployment"
        echo " "
    else
        echo " "
        echo "No SSH key found."
        echo " "
        # Prompt user to generate a new SSH key
        read -rp "Do you want to generate a new SSH key? (y/n): " response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            read -rp "Enter the file path to save the new key (default: ~/.ssh/id_ed25519): " key_path
            key_path=${key_path:-~/.ssh/id_ed25519}
            ssh-keygen -t ed25519 -f "$key_path" -N ""
            ssh_public_key="${key_path}.pub"
            echo "New SSH key generated: $key_path"
            echo "New Public key: $ssh_public_key"
        else
            echo " "
            echo "No SSH key generated."
            echo " "
            echo "Script canceled by user request"
            echo " "
            exit 1
        fi
    fi
    echo "ssh_public_key = \"$ssh_public_key\"" >> vultr/terraform.tfvars

    ####################################################################################################
    #Get amount of nodes to deploy
    ####################################################################################################

    print_header "Amount of nodes to deploy"

    # Function to check if input is a valid number
    is_number() {
        if [[ $1 =~ ^[0-9]+$ ]]; then
        return 0
        else
        return 1
        fi
    }

    # Prompt for number of admin nodes to deploy
    while true; do
        read -rp "How many admin nodes would you want to add? (default 1): " admin_nodes
        admin_nodes=${admin_nodes:-1}  # Use default value if input is empty
        if is_number "$admin_nodes"; then
        break
        else
        echo "Please enter a valid number."
        fi
    done

    # Prompt for number of control nodes to deploy
    while true; do
        read -rp "How many control nodes do you want? (default 1): " control_nodes
        control_nodes=${control_nodes:-1}
        if is_number "$control_nodes"; then
        break
        else
        echo "Please enter a valid number."
        fi
    done

    # Prompt for number of compute nodes to deploy
    while true; do
        read -rp "How many compute nodes do you want? (default 1): " compute_nodes
        compute_nodes=${compute_nodes:-1}
        if is_number "$compute_nodes"; then
        break
        else
        echo "Please enter a valid number."
        fi
    done

    # Confirm the number of nodes
    while true; do
        echo "You have specified the following:"
        echo "Admin nodes: $admin_nodes"
        echo "Control nodes: $control_nodes"
        echo "Compute nodes: $compute_nodes"
        read -rp "Do you want to proceed with this configuration? (y/N): " confirm
        confirm=${confirm:-no} # Default to 'no' if input is empty
        case $confirm in
        [Yy][Ee][Ss] | [Yy])
            echo "Proceeding with the deployment..."
            break
            ;;
        [Nn][Oo] | [Nn])
            echo "Installation cancelled by user request"
            exit 1
            ;;
        *)
            echo "Please answer yes or no."
            ;;
        esac
    done
    {
    echo "admin_nodes = \"$admin_nodes\""
    echo "control_nodes = \"$control_nodes\""
    echo "compute_nodes = \"$compute_nodes\""
    } >> vultr/terraform.tfvars

    read -rp "Enter firewall group (Press Enter to proceed with ciq default): " firewall_group_id
    firewall_group_id="${firewall_group_id:-"6d5385a0-dace-43ce-ad6a-6d7e09f9185c"}"
    echo "firewall_group_id = \"${firewall_group_id}\"" >> vultr/terraform.tfvars


    ####################################################################################################
    # Prompt for Vultr API key
    ####################################################################################################

    print_header "Vultr API key"

    while true; do
        read -srp "Please enter your Vultr API key: " VULTR_API_KEY
        echo  # Move to the next line after input
        if [[ -n "$VULTR_API_KEY" ]]; then
        echo "API key entered successfully."
        break
        else
        echo "API key cannot be empty. Please try again."
        fi
    done

    # Output the API key length for confirmation (optional)
    echo "Length of the entered API key: ${#VULTR_API_KEY} characters"
    echo "VULTR_API_KEY = \"$VULTR_API_KEY\"" >> vultr/terraform.tfvars

    print_header "Region to deploy to"


    # List of Vultr regions (name:abbreviation)
    regions=("Amsterdam:ams" "Atlanta:atl" "Bangalore:blr" "Mumbai:bom" "Paris:cdg" 
            "Delhi NCR:del" "Dallas:dfw" "New Jersey:ewr" "Frankfurt:fra" 
            "Honolulu:hnl" "Seoul:icn" "Osaka:itm" "Johannesburg:jnb" 
            "Los Angeles:lax" "London:lhr" "Madrid:mad" "Manchester:man" 
            "Melbourne:mel" "Mexico City:mex" "Miami:mia" "Tokyo:nrt" 
            "Chicago:ord" "São Paulo:sao" "Santiago:scl" "Seattle:sea" 
            "Singapore:sgp" "Silicon Valley:sjc" "Stockholm:sto" 
            "Sydney:syd" "Tel Aviv:tlv" "Warsaw:waw" "Toronto:yto")

    echo " "
    echo "Please select a Vultr region:"
    echo " "

    # Display the selection menu
    select choice in "${regions[@]}"; do
        # Check if the selection is valid
        if [[ -n "$choice" ]]; then
            # Split the selected item into region name and abbreviation
            abbreviation="${choice##*:}"
            region="${choice%%:*}"
            
            echo "You selected: $abbreviation ($region)"
            echo "region = \"$abbreviation\"" >> vultr/terraform.tfvars
            break
        else
            echo "Invalid selection. Please try again."
        fi
    done


    print_header "VPC to deploy to \n Please leave blank to create new VPC"


    # Prompt the user for the VPC ID
    read -rp "Enter VPC ID (or leave blank to create a new one): " VPC_ID

    # Check if the input is empty
    if [ -z "$VPC_ID" ]; then
        echo "No VPC ID entered. A new VPC will be created."
        VPC_ID=""
    else
        echo "VPC ID entered: $VPC_ID"
        echo "VPC_ID = \"$VPC_ID\"" >> vultr/terraform.tfvars
    fi
}

function generate_hosts() {
    tfvars_output

    fuzzball_default_version="v0.0.1-gc972cffc"

    if [[ -f ".env.sh" ]]
    then
        source .env.sh
    fi

    if [[ -z $keycloak_uuid ]]
    then
        keycloak_uuid=$(uuidgen | tr '[:upper:]' '[:lower:]')
        echo "export keycloak_uuid=$keycloak_uuid" >> .env.sh
        export keycloak_uuid
    fi

    if [[ -z $MTN_KEY ]]
    then
        read -rp "Enter your Mountain key: " MTN_KEY
        echo "export MTN_KEY=$MTN_KEY" >> .env.sh
        export MTN_KEY
    fi

    if [[ -n $fuzzball_operator_version ]]; then
    fuzzball_default_version=$fuzzball_operator_version
    fi

    read -rp "Enter fuzzball operator version (default: ${fuzzball_default_version}): " fuzzbal_ver
    fuzzball_operator_version="${fuzzbal_ver:-$fuzzball_default_version}"

    if grep -q '^export fuzzball_operator_version=' .env.sh; then
        perl -pi -e "s/^export fuzzball_operator_version=.*/export fuzzball_operator_version=$fuzzball_operator_version/" '.env.sh'
    else
        echo "export fuzzball_operator_version=$fuzzball_operator_version" >> .env.sh
    fi
    export fuzzball_operator_version


    cat << EOF > hosts.yaml
all:
  vars:
    ansible_user: root
    mtn_access_key: ${MTN_KEY}
    substrate_nfs_subnet: ${substrate_nfs_subnet}
    substrate_nfs_mount: ${substrate_nfs_mount}:/srv/fuzzball/shared
    FB_POLL_CONFIG: /fuzzball/shared/substrate/substrate-config.yaml
    fuzzball_operator_version: ${fuzzball_operator_version}
    fuzzball_operator_storage_class: "local-path"
    fuzzball_operator_chart: "oci://repository.ciq.com/fuzzball-testing/images/helm/fuzzball-operator"
    fuzzball_operator_image: "repository.ciq.com/fuzzball-testing/images/fuzzball-operator"
    fuzzball_orchestrate:
      spec:
        fuzzball: 
          substrate:
            nfs:
              server: ${substrate_nfs_mount}
          kube:
            backendGatewayService:
              metallb.universe.tf/loadBalancerIPs: ${metallb_lb_ip}
          workflow:
            callbackService:
              annotations:
                metallb.universe.tf/loadBalancerIPs: ${metallb_lb_ip}
        ingress:
          create:
            domain: ${fz_domain}
            proxy:
              annotations:
                metallb.universe.tf/loadBalancerIPs: ${metallb_lb_ip}
        keycloak:
          create:
            realmId: ${keycloak_uuid}
            ingress:
              hostname: auth.${fz_domain}
        database:
          create:
            credentials:
              password: password
    metallb_pool:
      spec:
        addresses:
        - ${metallb_lb_ip}/32
    keycloak_env:
      KC_DB_PASSWORD: password
      KEYCLOAK_ADMIN_PASSWORD: password
      KC_HOSTNAME_URL: https://auth.${fz_domain}/auth
      KC_HOSTNAME_ADMIN_URL: https://auth.${fz_domain}/auth
    # keycloak_certbot_email: noreply@ciq.co
    # keycloak_certbot_domain: "auth.${keycloak_domain},authadmin.${keycloak_domain}"
EOF

    cat << EOF >> hosts.yaml
  children:
    admin:
      hosts:
EOF
    echo "$TF_OUTPUT" | jq -r '.admin_nodes_public_ip.value | to_entries[] | "\(.key)=\(.value)"' | while IFS="=" read -r key value; do
    cat << EOF >> hosts.yaml
        ${key##*_}:
          ansible_host: $value
          cluster_interface: "enp8s0"
EOF
    done

    cat << EOF >> hosts.yaml
    controller:
      hosts:
EOF
    echo "$TF_OUTPUT" | jq -r '.controller_node_public_ips.value | to_entries[] | "\(.key)=\(.value)"' | while IFS="=" read -r key value; do
    internal_ip=$(echo "$TF_OUTPUT" | jq -r ".controller_node_private_ips.value.private_IP_${key##*_}")
    cat << EOF >> hosts.yaml
        ${key##*_}:
          ansible_host: $value
          cluster_interface: "enp8s0"
          rke2_node_ip: $internal_ip
EOF
    done
    cat << EOF >> hosts.yaml
    compute:
      hosts:
EOF
    echo "$TF_OUTPUT" | jq -r '.compute_instances_public_ip.value | to_entries[] | "\(.key)=\(.value)"' | while IFS="=" read -r key value; do
    cat << EOF >> hosts.yaml
        ${key##*_}:
          ansible_host: $value
          cluster_interface: "enp8s0"
EOF
    done

    printf "\e[32m✅ hosts.yaml\e[0m file generated. Please check for any issues.\n"
}

function check_ansible() {
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
        read -rp "Do you want to install Ansible? (yes/no): " choice
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
}

function terraform_apply() {
    terraform -chdir=vultr apply
}

function terraform_destroy() {
    terraform -chdir=vultr destroy
}

function wipe() {
    echo "This will delete your vultr terraform variables and your hosts environments."
    read -rp "Do you want to continue? (y/n): " choice

    # Check user input
    if [[ "$choice" =~ ^[Yy]$ ]]; then
        rm -f "vultr/terraform.tfvars"
        rm -f ".env.sh"
        echo "Removed..." 
    else
        echo "Aborted."
        exit 1
    fi
}

function help() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  --apply       Apply Terraform configuration but do not run wizard"
    echo "  --destroy     Destroy Terraform-managed infrastructure"
    echo "  --hosts       Generate hosts.yaml file but do not run wizard"
    echo "  --wipe        Wipe tfvars and .env.sh"
    echo "  -d, --domain  Used with --hosts will change the default nip.io to this domain"
    echo "  -h, --help      Display this help message"

}

function data() {
    tfvars_output
    print_header "Additional usefull commands"
    echo "# Create dynamic proxy via SSH"
    echo " ssh -A -D 5900 $metallb_lb_pub_ip "
    echo " "
    echo "# Set PATH and KUBECONFIG on Controller instance  for later steps."
    echo "PATH=/var/lib/rancher/rke2/bin:$/PATH"
    echo "export KUBECONFIG=/etc/rancher/rke2/rke2.yaml"
    echo "kubectl get ingress -A"
    echo " "
    echo "# Fuzzball UI URL"
    echo "ui.fb.${fz_domain}"
    echo " "
}

main() {
    ##################################################################################################################################
    # Terraform
    ##################################################################################################################################
    if [[ ! -f vultr/terraform.tfvars ]]; then
        user_input
        terraform -chdir=vultr init
    fi
    terraform_apply
    
    ##################################################################################################################################
    # Create hosts.yaml file
    ##################################################################################################################################

    print_header "Generating hosts.yaml file"

    generate_hosts

    ##################################################################################################################################
    # Check for Ansible
    ##################################################################################################################################

    print_header "Ansible is a prerequisite for this installation \n\n Checking if ansible is installed"

    check_ansible

    ##################################################################################################################################
    # Sending outputs to the user
    ##################################################################################################################################

    print_header "Ansible has been installed successfully and hosts.yaml file has been generated with the necesary inputs\n\nTo continue deploying fuzzball to the recently created vultr instances please run the following commands"

    printf "You can run '\033[32mexport ANSIBLE_HOST_KEY_CHECKING=False'\033[0m to ignore ssh host keys\n"
    echo "Run the following commands to start the install"
    echo " "
    printf "\033[1;34m\033[40mansible-playbook --inventory hosts.yaml setup-rke2-and-fuzzball.yaml\033[0m\n"
    echo " "
    #printf "\033[1;34m\033[40mansible-playbook --inventory hosts.yaml setup-keycloak.yaml\033[0m\n"
    #echo " "

}

# Default action
ACTION="main"

# Parse arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --apply) ACTION="terraform_apply";;
    --destroy) ACTION="terraform_destroy";;
    --hosts) ACTION="generate_hosts";;
    --wipe) ACTION="wipe";;
    --data) ACTION="data";;
    -d|--domain) domain=$2; shift;;
    -h|--help) help; exit 0;;
    *) echo "Unknown parameter passed: $1" ; help ; exit 1;;
  esac
  shift
done

$ACTION