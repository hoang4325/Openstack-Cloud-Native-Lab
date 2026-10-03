terraform {
  required_version = ">= 1.5.0"

  required_providers {
    vmworkstation = {
        source = "elsudano/vmworkstation"
        version = "2.0.1"
    }
  }
}