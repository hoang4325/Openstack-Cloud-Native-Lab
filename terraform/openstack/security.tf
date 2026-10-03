resource "openstack_networking_secgroup_v2" "vm" {
  name = "tf-vm-sg"
  description = "Security group managed by Terraform"
}

resource "openstack_networking_secgroup_rule_v2" "icpm" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "icmp"

  remote_ip_prefix = "172.20.0.0/24"

  security_group_id = openstack_networking_secgroup_v2.vm.id
}

resource "openstack_networking_secgroup_rule_v2" "ssh" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "tcp"

  port_range_min = 22
  port_range_max = 22

  remote_ip_prefix = "172.20.0.0/24"

  security_group_id = openstack_networking_secgroup_v2.vm.id
}