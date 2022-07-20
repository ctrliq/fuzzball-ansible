variable "ldap_servers" {
  type = number
  nullable = false
  default = 0
}

variable "ldap_snapshot_id" {
  type     = string
  nullable = false
  default  = "613d52cc-5c09-4b9c-8108-c1e92f786df3"
}

resource "vultr_instance" "ldap" {
  count             = var.ldap_servers
  plan              = "vhf-1c-2gb"
  region            = "ewr"
  snapshot_id       = "${var.ldap_snapshot_id}"
  label             = "LDAP Server ${count.index+1} (${var.prefix})"
  hostname          = "${var.prefix}-ldap${count.index+1}"
  vpc_ids           = ["${var.vpc_id}"]
  ssh_key_ids       = [vultr_ssh_key.root_ssh_key.id]
  firewall_group_id = "${var.firewall_group_id}"
  tags              = ["${var.tag}"]
}
