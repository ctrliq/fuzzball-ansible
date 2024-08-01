variable "control_nodes" {
  type     = number
  nullable = false
  default  = 1
}

resource "vultr_instance" "ctl" {
  count             = var.control_nodes
  label             = "Controller Node ${count.index+1} (${var.prefix})"
  tags              = ["${var.tag}"]
  firewall_group_id = "${var.firewall_group_id}"
  plan              = "vc2-6c-16gb"
  region            = "ewr"
  os_id             = 448 # rocky linux
  hostname          = "${var.prefix}-ctl${count.index+1}"
  vpc_ids           = [local.cluster_vpc_id]
  ssh_key_ids       = [vultr_ssh_key.root_ssh_key.id]
}
