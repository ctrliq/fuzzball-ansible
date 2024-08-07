#!/bin/bash
#

if [[! -f vultr_deployment.tfvars ]]; then
    
    echo "File vultr_deployment.tfvars doesnt exist"
    ####################################################################################################
    #Let's get some variables:
    ####################################################################################################

    echo " "
    echo "####################################################################################################"
    echo "Gathering information for the deployment"
    echo "####################################################################################################"
    echo " "
    echo " "

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
      read -p "Please enter your username (max 36 characters, alphanumeric only): " USERNAME
      
      # Check if the input is empty
      if [[ -z "$USERNAME" ]]; then
        echo "Input cannot be empty. Please try again."
      # Check if it contains invalid characters
      elif contains_invalid_characters "$USERNAME"; then
        echo "Input contains invalid characters. Please enter alphanumeric characters only."
      # Limit to 36 characters  
      elif [[ ${#user_input} -gt 36 ]]; then
        echo "Input exceeds 36 characters. Please try again."
      else
        echo " "
        echo "Your username is: $USERNAME"
        echo " "
        echo "USERNAME=$USERNAME" > vultr_deployment.tfvars
        break
      fi
    done

    ####################################################################################################
    # Create a SSH key
    ####################################################################################################
    echo " "
    echo "===================================================================================================="
    echo "Checking if SSH Key exist"
    echo "===================================================================================================="
    echo " "

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
        read -p "Do you want to generate a new SSH key? (y/n): " response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            read -p "Enter the file path to save the new key (default: ~/.ssh/id_ed25519): " key_path
            key_path=${key_path:-~/.ssh/id_ed25519}
            ssh-keygen -t ed25519 -f "$key_path" -N ""
            ssh_public_key="${$key_path}.pub"
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
    echo "ssh_public_key=$ssh_public_key" >> vultr_deployment.tfvars

    ####################################################################################################
    #Get amount of nodes to deploy
    ####################################################################################################
    echo " "
    echo "===================================================================================================="
    echo "Amount of nodes to deploy"
    echo "===================================================================================================="
    echo " "

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
      read -p "How many admin nodes would you want to add? (default 1): " admin_nodes
      admin_nodes=${admin_nodes:-1}  # Use default value if input is empty
      if is_number "$admin_nodes"; then
        break
      else
        echo "Please enter a valid number."
      fi
    done

    # Prompt for number of control nodes to deploy
    while true; do
      read -p "How many control nodes do you want? (default 1): " control_nodes
      control_nodes=${control_nodes:-1}
      if is_number "$control_nodes"; then
        break
      else
        echo "Please enter a valid number."
      fi
    done

    # Prompt for number of compute nodes to deploy
    while true; do
      read -p "How many compute nodes do you want? (default 1): " compute_nodes
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
      read -p "Do you want to proceed with this configuration? (y/N): " confirm
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
    echo "admin_nodes=$admin_nodes" >> vultr_deployment.tfvars
    echo "control_nodes=$control_nodes" >> vultr_deployment.tfvars
    echo "compute_nodes=$compute_nodes" >> vultr_deployment.tfvars

    ####################################################################################################
    # Prompt for Vultr API key
    ####################################################################################################
    echo " "
    echo "===================================================================================================="
    echo "Vultr API key"
    echo "===================================================================================================="
    echo " "
    while true; do
      read -sp "Please enter your Vultr API key: " VULTR_API_KEY
      echo  # Move to the next line after input
      if [[ -n "$VULTR_API_KEY" ]]; then
        echo "API key entered successfully."
        break
      else
        echo "API key cannot be empty. Please try again."
      fi
    done

    # Output the API key length for confirmation (optional)
    echo "Length of the entered API key: $(echo $VULTR_API_KEY | wc -m) characters"
    echo "VULTR_API_KEY=$VULTR_API_KEY" >> vultr_deployment.tfvars

    ####################################################################################################
    # Prompt for firewall_group_id, vpc id, and region
    ####################################################################################################
    echo " "
    echo "===================================================================================================="
    echo "Firewall ID to deploy to"
    echo "===================================================================================================="
    echo " "
    while true; do
      read -p "Please enter your firewall group ID: " firewall_group_id
      if [[ -n "$firewall_group_id" ]]; then
          echo "Firewall group ID entered successfully."
          echo "firewall_group_id=$firewall_group_id" >> vultr_deployment.tfvars
          break
      else
          echo "Firewall group ID cannot be empty. Please try again."
      fi
    done

    echo " "
    echo "===================================================================================================="
    echo "Region to deploy to"
    echo "===================================================================================================="
    echo " "

    # List of Vultr regions 
    declare -A regions=(
        ["Amsterdam"]="ams"
        ["Atlanta"]="atl"
        ["Bangalore"]="blr"
        ["Mumbai"]="bom"
        ["Paris"]="cdg"
        ["Delhi NCR"]="del"
        ["Dallas"]="dfw"
        ["New Jersey"]="ewr"
        ["Frankfurt"]="fra"
        ["Honolulu"]="hnl"
        ["Seoul"]="icn"
        ["Osaka"]="itm"
        ["Johannesburg"]="jnb"
        ["Los Angeles"]="lax"
        ["London"]="lhr"
        ["Madrid"]="mad"
        ["Manchester"]="man"
        ["Melbourne"]="mel"
        ["Mexico City"]="mex"
        ["Miami"]="mia"
        ["Tokyo"]="nrt"
        ["Chicago"]="ord"
        ["São Paulo"]="sao"
        ["Santiago"]="scl"
        ["Seattle"]="sea"
        ["Singapore"]="sgp"
        ["Silicon Valley"]="sjc"
        ["Stockholm"]="sto"
        ["Sydney"]="syd"
        ["Tel Aviv"]="tlv"
        ["Warsaw"]="waw"
        ["Toronto"]="yto"
    )
    echo " "
    echo "Please select a Vultr region:"
    echo " "

    # Display the selection menu
    select abbreviation in "${!regions[@]}"; do
        # Check if the selection is valid
        if [[ -n "$abbreviation" ]]; then
            selected_region=${regions[$abbreviation]}
            echo "You selected: $selected_region ($abbreviation)"
            echo "region=$selected_region" >> vultr_deployment.tfvars
            break
        else
            echo "Invalid selection. Please try again."
        fi
    done
    echo " "
    echo "===================================================================================================="
    echo "VPC to deploy to"
    echo "Please leave blank to create new VPC"
    echo "===================================================================================================="
    echo " "

    # Prompt the user for the VPC ID
    read -p "Enter VPC ID (or leave blank to create a new one): " VPC_ID

    # Check if the input is empty
    if [ -z "$VPC_ID" ]; then
        echo "No VPC ID entered. A new VPC will be created."
        VPC_ID=""
    else
        echo "VPC ID entered: $VPC_ID"
    fi

else 
    ####################################################################################################
    ###### Lets Run Terraform
    echo "vultr_deployment.tfvars file exist"
    ls vultr_deployment.tfvars
    terraform -chdir=vultr init  #Initialize terraform

    #if [ -z "$VPC_ID" ]; then
        #terraform -chdir=vultr apply -var region="$selected_region" -var tag="${USERNAME}" -var prefix="${USERNAME}" -var VULTR_API_KEY="$VULTR_API_KEY" -var ssh_public_key="$ssh_public_key" -var compute_nodes="$compute_nodes" -var control_nodes="$control_nodes" -var admin_nodes="$admin_nodes" -var firewall_group_id="$firewall_group_id"
        terraform -chdir=vultr apply
    #else
      # terraform -chdir=vultr apply -var region="$selected_region" -var cluster_vpc_id="$VPC_ID" -var tag="${USERNAME}" -var prefix="${USERNAME}" -var VULTR_API_KEY="$VULTR_API_KEY" -var ssh_public_key="$ssh_public_key" -var compute_nodes="$compute_nodes" -var control_nodes="$control_nodes" -var admin_nodes="$admin_nodes" -var firewall_group_id="$firewall_group_id"
    #fi
fi    

###
#add to check ansible

#
#/script/create hosts.yaml
