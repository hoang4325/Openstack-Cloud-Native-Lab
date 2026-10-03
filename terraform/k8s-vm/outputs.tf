output "k8s_nodes" {
  description = "Kubernetes VMs running on VMware Workstation PC2"

  value = {
    for name, vm in vmworkstation_virtual_machine.k8s_nodes :
    name => {
      id = vm.id
      ip = vm.ip
    }
  }
}