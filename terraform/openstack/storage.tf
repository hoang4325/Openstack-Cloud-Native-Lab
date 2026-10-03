resource "openstack_blockstorage_volume_v3" "vm" {
  name = var.volume_name
  description = "Cinder volume managed by Terraform"

  size = var.volume_size
}

resource "openstack_compute_volume_attach_v2" "vm" {
  instance_id = openstack_compute_instance_v2.vm.id
  volume_id = openstack_blockstorage_volume_v3.vm.id
}