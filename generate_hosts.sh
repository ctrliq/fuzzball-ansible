#! /bin/bash

cat << EOF > hosts.yaml
all:
  vars:
    ansible_user: root
    mtn_access_key:
    substrate_nfs_subnet: 10.0.0.0/24
    substrate_nfs_mount: admin1:/fuzzball/shared
    fuzzball_orchestrate:
      spec:
        fuzzball:
          substrate:
            nfs:
              server: # IP address of NFS server hosting Fuzzball Substrate config
          kube:
            backendGatewayService:
              metallb.universe.tf/loadBalancerIPs: # preferred external IP address
          workflow:
            callbackService:
              annotations:
                metallb.universe.tf/loadBalancerIPs: # preferred external IP address
        ingress:
          create:
            domain: # e.g., 10.0.0.99.nip.io
            proxy:
              annotations:
                metallb.universe.tf/loadBalancerIPs: # preferred external IP address
        keycloak:
          create:
            realmId: # Unique UUIDv4, or existing UUIDv4 for external Keycloak
            ingres:
              hostname: # e.g., auth.10.0.0.99.nip.io
        database:
          create:
            credentials:
              password: # database password to use
    metallb_pool:
      spec:
        addresses:
        - # addresses available for use with external services; e.g., "10.0.0.99-10.0.0.100"
  children:
    admin:
      hosts:
        admin1:
          cluster_interface:
    controller:
      hosts:
        ctl1:
          rke2_node_ip:
    compute:
      hosts:
        compute[1:4]:
          cluster_interface:
EOF