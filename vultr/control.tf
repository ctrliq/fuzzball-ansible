variable "control_nodes" {
  type     = number
  nullable = false
  default  = 3
}

variable "ldap_servers" {
  type = number
  nullable = false
  default = 0
}

variable "ldap_snapshot_id" {
  type     = string
  nullable = false
}

resource "vultr_instance" "ctl" {
  count             = var.control_nodes
  label             = "Controller Node ${count.index+1} (${var.prefix})"
  tags              = ["${var.tag}"]
  firewall_group_id = "${var.firewall_group_id}"
  plan              = "vc2-6c-16gb"
  region            = "ewr"
  script_id         = vultr_startup_script.ipxeNodes.id
  os_id             = 448 # rocky linux
  hostname          = "${var.prefix}-ctl${count.index+1}"
  vpc_ids           = ["${var.vpc_id}"]
  ssh_key_ids       = [vultr_ssh_key.root_ssh_key.id]
}


resource "vultr_instance" "ldap" {
  count             = var.ldap_servers
  plan              = "vhf-1c-2gb"
  region            = "ewr"
  snapshot_id       = "613d52cc-5c09-4b9c-8108-c1e92f786df3"
  label             = "LDAP Server ${count.index+1} (${var.prefix})"
  hostname          = "${var.prefix}-ldap${count.index+1}"
  vpc_ids           = ["${var.vpc_id}"]
  ssh_key_ids       = [vultr_ssh_key.root_ssh_key.id]
  firewall_group_id = "${var.firewall_group_id}"
  tags              = ["${var.tag}"]
}
