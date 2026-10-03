data "openstack_networking_network_v2" "public" {
    name = var.external_network_name
    external = true
}

data "openstack_images_image_v2" "cirros" {
    name = var.image_name
    most_recent = true
}

data "openstack_compute_flavor_v2" "tiny" {
    name = var.flavor_name
}