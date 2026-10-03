output "instance_id" {
  description = "ID of the Terraform VM"
  value       = openstack_compute_instance_v2.vm.id
}

output "instance_name" {
  description = "Name of the Terraform VM"
  value       = openstack_compute_instance_v2.vm.name
}

output "private_ip" {
  description = "Private IP of the Terraform VM"
  value       = openstack_networking_port_v2.vm.all_fixed_ips[0]
}

output "floating_ip" {
  description = "Floating IP assigned to the Terraform VM"
  value       = openstack_networking_floatingip_v2.vm.address
}

output "volume_id" {
  description = "Cinder volume ID"
  value       = openstack_blockstorage_volume_v3.vm.id
}

output "private_network_id" {
  description = "Terraform private network ID"
  value       = openstack_networking_network_v2.private.id
}

output "router_id" {
  description = "Terraform router ID"
  value       = openstack_networking_router_v2.router.id
}