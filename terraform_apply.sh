#!/bin/bash
#

if [[ ! -f vultr_deployment.tfvars ]]; then
    
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

./generate_hosts.sh

###
#add to check ansible
###



