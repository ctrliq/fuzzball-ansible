variable "admin_nodes" {
  type     = number
  nullable = false
  default  = 0
}

resource "vultr_instance" "admin" {
  count             = var.admin_nodes
  label             = "Admin Node ${count.index+1} (${var.prefix})"
  tags              = ["${var.tag}"]
  plan              = "vhf-1c-2gb"
  region            = var.region
  os_id             = 448 # rocky linux
  hostname          = "${var.prefix}-admin${count.index+1}"
  vpc_ids           = [local.cluster_vpc_id]
  ssh_key_ids       = [vultr_ssh_key.root_ssh_key.id]
}
