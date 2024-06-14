variable "compute_nodes" {
  type     = number
  nullable = false
  default  = 0
}

resource "vultr_instance" "compute" {
  count             = var.compute_nodes
  label             = "Compute Node ${count.index+1} (${var.prefix})"
  tags              = ["${var.tag}"]
  firewall_group_id = "${var.firewall_group_id}"
  plan              = "vc2-4c-8gb"
  region            = "ewr"
  script_id         = vultr_startup_script.ipxeNodes.id
  os_id             = 448 # rocky linux
  hostname          = "${var.prefix}-compute${count.index+1}"
  vpc2_ids          = [vultr_vpc2.cluster_net.id]
  ssh_key_ids       = [vultr_ssh_key.root_ssh_key.id]
}
