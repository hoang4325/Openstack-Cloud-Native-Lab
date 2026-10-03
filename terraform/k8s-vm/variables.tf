variable "vm_username" {
  description = "Username used to authenticate to VMware Workstation REST API"
  type = string
  sensitive = true
}

variable "vm_password" {
  description = "Password used to authenticate to VMware Workstation REST API"
  type = string
  sensitive = true
}

variable "template_id" {
  description = "VMware Workstation ID of the Kubernetes Ubuntu template"
  type = string

  default = "2U61LOPNVS56EIFEFNCM5J4QGBSC5SCN"
}

variable "vm_base_path" {
  description = "Directory on PC2 used to store Kubernetes VMs"
  type = string

  default = "E:\\VM"
}