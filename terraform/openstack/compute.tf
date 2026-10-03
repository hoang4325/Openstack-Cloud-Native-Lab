resource "openstack_networking_port_v2" "vm" {
  name = "${var.instance_name}-port"
  network_id = openstack_networking_network_v2.private.id
  admin_state_up = true

  security_group_ids = [
    openstack_networking_secgroup_v2.vm.id
  ]

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.private.id
  }
}

resource "openstack_compute_instance_v2" "vm" {
  name = var.instance_name

  image_id = data.openstack_images_image_v2.cirros.id

  flavor_id = data.openstack_compute_flavor_v2.tiny.id

  network {
    port = openstack_networking_port_v2.vm.id
  }

  depends_on = [ 
    openstack_networking_router_interface_v2.private
  ]
}

resource "openstack_networking_floatingip_v2" "vm" {
  pool = data.openstack_networking_network_v2.public.name

  port_id = openstack_networking_port_v2.vm.id

  depends_on = [ openstack_networking_router_interface_v2.private ]
}