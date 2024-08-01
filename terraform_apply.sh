#!/bin/bash
#

####################################################################################################
#Let's get some variables:

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
    echo "Your username is: $USERNAME"
    break
  fi
done

####################################################################################################
# Create a SSH key
# Define the path for the SSH key

if [ -f "$HOME"/.ssh/id_rsa ]; then
    ssh_private_key="$HOME/.ssh/id_rsa"
elif [ -f ~/.ssh/id_ecdsa ]; then
    ssh_private_key="$HOME/.ssh/id_ecdsa"
elif [ -f ~/.ssh/id_ed25519 ]; then
    ssh_private_key="$HOME/.ssh/id_ed25519"
else
    ssh_private_key=""
fi

# Set $ssh_public_key if key exists
if [ -n "$ssh_private_key" ] && [ -f "$ssh_private_key" ]; then
    ssh_public_key=$(cat "$ssh_private_key.pub")
    echo "Using existing SSH key: $ssh_private_key"
    echo "Public key: $ssh_public_key"
else
    echo "No default SSH key found."

    # Prompt user to generate a new SSH key
    read -p "Do you want to generate a new SSH key? (y/n): " response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        read -p "Enter the file path to save the new key (default: ~/.ssh/id_ed25519): " key_path
        key_path=${key_path:-~/.ssh/id_ed25519}
        ssh-keygen -t ed25519 -f "$key_path" -N ""
        ssh_public_key=$(cat "$key_path.pub")
        echo "New SSH key generated: $key_path"
        echo "Public key: $ssh_public_key"
    else
        echo "No SSH key generated."
        exit 1
    fi
fi


####################################################################################################
#Get amount of nodes to deploy
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
  read -p "How many admin nodes do you want? (default 1): " admin_nodes
  admin_nodes="1"  # Use default value if input is empty
  if is_number "$admin_nodes"; then
    break
  else
    echo "Please enter a valid number."
  fi
done

# Prompt for number of control nodes to deploy
while true; do
  read -p "How many control nodes do you want? (default 1): " control_nodes
  control_nodes="1"  # Use default value if input is empty
  if is_number "$control_nodes"; then
    break
  else
    echo "Please enter a valid number."
  fi
done

# Prompt for number of compute nodes to deploy
while true; do
  read -p "How many compute nodes do you want? (default 1): " compute_nodes
  compute_nodes="1"  # Use default value if input is empty
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
      echo "Configuration cancelled."
      exit 1
      ;;
    *)
      echo "Please answer yes or no."
      ;;
  esac
done

####################################################################################################
# Prompt for Vultr API key
while true; do
  read -sp "Please enter your API key: " VULTR_API_KEY
  echo  # Move to the next line after input
  if [[ -n "$VULTR_API_KEY" ]]; then
    echo "API key entered successfully."
    break
  else
    echo "API key cannot be empty. Please try again."
  fi
done

# Output the API key length for confirmation (optional)
echo "Length of the entered API key: ${VULTR_API_KEY} characters"


####################################################################################################
# Prompt for firewall_group_id
while true; do
  read -p "Please enter your firewall group ID: " firewall_group_id
  if [[ -n "$firewall_group_id" ]]; then
    echo "Firewall group ID entered successfully."
    break
  else
    echo "Firewall group ID cannot be empty. Please try again."
  fi
done

###
#add to check ansible

###
#Prompt for region 
#
/script/create hosst.yaml

####################################################################################################
###### Lets Run Terraform

terraform -chdir=vultr init  #Initialize terraform
terraform -chdir=vultr apply -var region=$region -var tag="${USERNAME}" -var prefix="${USERNAME}" -var $VULTR_API_KEY -var ssh_public_key=$ssh_public_key -var compute_nodes=$compute_nodes -var control_nodes=$control_nodes -var admin_nodes=$admin_nodes

#
#/script/create hosts.yaml