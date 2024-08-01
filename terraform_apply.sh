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

read "Could you please provide your username"

####################################################################################################
# Create a SSH key
# Define the path for the SSH key
ssh_public_key="$HOME/.ssh/id_ed25519.pub"
ssh_private_key="$HOME/.ssh/id_ed25519"

# Check if the SSH key already exists
if [ -f "$ssh_private_key" ] && [ -f "$ssh_public_key" ]; then
  echo "SSH key pair already exists at: $ssh_private_key and $ssh_public_key"
  echo "Using existing keys for deployment"
else
# Generate the SSH key pair using the Ed25519 algorithm
  ssh-keygen -t ed25519 -f "$ssh_private_key" -N ""
  echo "SSH key pair created:"
  echo "Private key: $ssh_private_key"
  echo "Public key: $ssh_public_key"
  echo "Using created keys for deployment"
fi

####################################################################################################
#Get ammount of nodes to deploy
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
  confirm="no" # Default to 'no' if input is empty
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
/script/create hosts.yaml