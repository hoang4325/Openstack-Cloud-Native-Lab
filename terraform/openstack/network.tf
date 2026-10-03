resource "openstack_networking_network_v2" "private" {
  name = var.private_network_name
  admin_state_up = true
}

resource "openstack_networking_subnet_v2" "private" {
  name = var.private_subnet_name
  network_id = openstack_networking_network_v2.private.id

  cidr = var.private_subnet_cidr
  ip_version = 4

  gateway_ip = "10.20.0.1"
  enable_dhcp = "true"

  dns_nameservers = [
    "8.8.8.8",
    "1.1.1.1"
  ]
}

resource "openstack_networking_router_v2" "router" {
  name = var.router_name
  admin_state_up = true

  external_network_id = data.openstack_networking_network_v2.public.id
}

resource "openstack_networking_router_interface_v2" "private" {
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.private.id
}