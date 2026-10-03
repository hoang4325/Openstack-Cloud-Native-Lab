provider "vmworkstation" {
  endpoint = "http://127.0.0.1:8697/api"

  username = var.vm_username
  password = var.vm_password

  https = false
  debug = "NONE"
}