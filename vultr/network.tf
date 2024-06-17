variable "cluster_vpc_id" {
    type     = string
    nullable = true
    default  = null
}


resource "vultr_vpc" "cluster_net" {
    count          = var.cluster_vpc_id == null ? 1 : 0
    description    = "Fuzzball testing cluster network (${var.prefix})"
    region         = "ewr"
    v4_subnet      = "10.0.0.0"
    v4_subnet_mask = 24
}

locals {
    cluster_vpc_id = var.cluster_vpc_id != null ? var.cluster_vpc_id : vultr_vpc.cluster_net[0].id
}
