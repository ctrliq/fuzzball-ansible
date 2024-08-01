output "substrate_nfs_subnet" {
  value = "${vultr_vpc.cluster_net[0].v4_subnet}/${vultr_vpc.cluster_net[0].v4_subnet_mask}"
}




output "controller_node_ips" {
  description = "The main IPs of the controller nodes"
  value = {
    for idx, instance in vultr_instance.ctl : "internal_IP_ctl${idx + 1}" => instance.main_ip
  }
}

output "admin_instances_public_ip" {
  description = "The public IPs of the admin instances"
  value = {
    for idx, instance in vultr_instance.admin : "internal_IP_admin${idx + 1}" => instance.main_ip
  }
}

output "ctl_instances_public_ip" {
  description = "The public IPs of the ctl instances"
  value = {
    for idx, instance in vultr_instance.ctl : "internal_IP_ctl${idx + 1}" => instance.main_ip
  }
}

locals {
  transformed_ip    = [for instance in vultr_instance.ctl : replace(instance.main_ip, ".", "-")]
  transformed_kc_ip = [for instance in vultr_instance.admin : replace(instance.main_ip, ".", "-")]
}

output "transformed_fuzzball_ip" {
  description = "The transformed IPs of the ctl instances"
  value = { for idx, ip in local.transformed_ip : "internal_IP_ctl${idx + 1}" => ip }
}

output "transformed_keycloak_ip" {
  description = "The transformed IPs of the admin instances"
  value = { for idx, ip in local.transformed_kc_ip : "internal_IP_admin${idx + 1}" => ip }
}


