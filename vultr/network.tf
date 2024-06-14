resource "vultr_vpc2" "cluster_net" {
    description = "internal cluster network"
    region = "ewr"
    ip_block = "10.0.0.0"
    ip_type = "v4"
    prefix_length = 24
}
