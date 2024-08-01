variable "compute_nodes" {
  type     = number
  nullable = false
  default  = 0
}

variable "tiny_compute_nodes" {
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
  region            = var.region
  script_id         = vultr_startup_script.ipxeNodes.id
  os_id             = 448 # rocky linux
  hostname          = "${var.prefix}-compute${count.index+1}"
  vpc_ids           = [local.cluster_vpc2_id]
  ssh_key_ids       = [vultr_ssh_key.root_ssh_key.id]
}

resource "vultr_instance" "tiny_compute" {
  count             = var.tiny_compute_nodes
  label             = "Tiny Compute Node ${count.index+1} (${var.prefix})"
  tags              = ["${var.tag}"]
  firewall_group_id = "${var.firewall_group_id}"
  plan              = "vc2-1c-1gb"
  region            = var.region
  script_id         = vultr_startup_script.ipxeNodes.id
  os_id             = 448 # rocky linux
  hostname          = "${var.prefix}-tiny-compute${count.index+1}"
  vpc_ids           = [local.cluster_vpc2_id]
  ssh_key_ids       = [vultr_ssh_key.root_ssh_key.id]
}
