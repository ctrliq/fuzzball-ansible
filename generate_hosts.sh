#! /bin/bash

TF_OUTPUT=$(terraform -chdir=vultr output --json)
substrate_nfs_subnet=$(echo "$TF_OUTPUT" | jq -r '.substrate_nfs_subnet.value')
substrate_nfs_mount=$(echo "$TF_OUTPUT" | jq -r '.admin_nodes_private_ip.value.private_IP_admin1')
metallb_lb_ip=$(echo "$TF_OUTPUT" | jq -r '.controller_node_public_ips.value.public_IP_ctl1')
keycloak_ip=$(echo "$TF_OUTPUT" | jq -r '.admin_nodes_public_ip.value.public_IP_admin1')
lb_ip_dashed=${metallb_lb_ip//\./-}
fz_domain="${lb_ip_dashed}.nip.io"
keycloak_ip_dashed=${keycloak_ip//\./-}
keycloak_domain="${keycloak_ip_dashed}.nip.io"

if [[ -f ".env.sh" ]]
then
    source .env.sh
fi

if [[ -z keycloak_uuid ]]
then
    keycloak_uuid=$(uuidgen | tr '[:upper:]' '[:lower:]')
    echo "export keycloak_uuid=$keycloak_uuid" >> .env.sh
    export keycloak_uuid
fi

fuzzball_default_version="v0.0.1-g91c1e539"

if [[ -z MTN_KEY ]]
then
    read -rp "Enter your Mountain key: " MTN_KEY
    echo "export MTN_KEY=$MTN_KEY" >> .env.sh
    export MTN_KEY
fi

if [[ -z fuzzball_operator_version ]]
then
    read -rp "Enter fuzzball operator version (default is ${fuzzball_default_version}): " fuzzbal_ver
    fuzzball_operator_version=${fuzzbal_ver:-"${fuzzball_default_version}"}
    echo "export fuzzball_operator_version=$fuzzball_operator_version" >> .env.sh
    export fuzzball_operator_version
fi

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
              hostname: auth.${keycloak_domain}
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
      KC_HOSTNAME_URL: https://auth.${keycloak_domain}
      KC_HOSTNAME_ADMIN_URL: https://authadmin.${keycloak_domain}
    keycloak_certbot_email: noreply@ciq.co
    keycloak_certbot_domain: "auth.${keycloak_domain},authadmin.${keycloak_domain}"
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
