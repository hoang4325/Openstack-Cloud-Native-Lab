locals {
  k8s_nodes = {
    "k8s-control-01" = {
        processors = 2
        memory = 2048
    }

    "k8s-worker-01" = {
        processors = 2
        memory = 4096
    }

    "k8s-worker-02" = {
        processors = 2
        memory = 4096
    }
  }
}

resource "vmworkstation_virtual_machine" "k8s_nodes" {
  for_each = local.k8s_nodes

  sourceid = var.template_id

  denomination = each.key

  description = "Kubernetes node managed by Terraform"

  path = "${var.vm_base_path}\\${each.key}\\${each.key}.vmx"

  processors = each.value.processors

  memory = each.value.memory

  state = "on"
}