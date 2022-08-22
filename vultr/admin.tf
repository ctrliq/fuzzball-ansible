variable "admin_nodes" {
  type     = number
  nullable = false
  default  = 1
}

resource "vultr_instance" "admin" {
  count             = var.admin_nodes
  label             = "Admin Node ${count.index+1} (${var.prefix})"
  tags              = ["${var.tag}"]
  firewall_group_id = "${var.firewall_group_id}"
  plan              = "vhf-1c-2gb"
  region            = "ewr"
  os_id             = 448 # rocky linux
  hostname          = "${var.prefix}-admin${count.index+1}"
  vpc_ids           = ["${var.vpc_id}"]
  ssh_key_ids       = [vultr_ssh_key.root_ssh_key.id]
}