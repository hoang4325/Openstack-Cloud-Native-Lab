variable "cloud_name" {
    description = "Cloud entry name from clouds.yaml"
    type = string
    default = "kolla-admin"
}

variable "region" {
    description = "Openstack region"
    type = string
    default = "RegionOne"
}

variable "external_network_name" {
    description = "Existing Openstack external network"
    type = string
    default = "public"
}
variable "image_name" {
    description = "Existing Glance image used by the VM"
    type = string
    default = "cirros"
}

variable "flavor_name" {
    description = "Existing Nova Flavor"
    type = string
    default = "m1.tiny"
}

variable "private_network_name" {
    description = "Terraform-managed private network"
    type = string
    default = "tf-private"
}

variable "private_subnet_name" {
    description = "Terraform-managed private subnet"
    type = string
    default = "tf-private-subnet"
}

variable "private_subnet_cidr" {
    description = "CIDR for Terraform private network"
    type = string
    default = "10.20.0.0/24"
}

variable "router_name" {
    description = "Terraform-managed router"
    type = string
    default = "tf-router"
}

variable "instance_name" {
    description = "Terraform-managed instance"
    type = string
    default = "tf-vm-01"
}

variable "volume_name" {
    description = "Terraform-managed Cinder volume"
    type = string
    default = "tf-volume-01"
}

variable "volume_size" {
    description = "Cinder volume size in GB"
    type = number
    default = 1
}