variable "cluster_vpc2_id" {
    type     = string
    nullable = true
    default  = null
}


resource "vultr_vpc2" "cluster_net" {
    count          = var.cluster_vpc2_id == null ? 1 : 0
    description    = "Fuzzball testing cluster network (${var.prefix})"
    region         = var.region
    ip_block       = "10.0.0.0"
    prefix_length  = 24
}

locals {
    cluster_vpc2_id = var.cluster_vpc2_id != null ? var.cluster_vpc2_id : vultr_vpc2.cluster_net[0].id
}
