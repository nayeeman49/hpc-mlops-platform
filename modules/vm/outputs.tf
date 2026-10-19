output "name" {
  value = var.name
}

output "role" {
  value = var.role
}

output "ip" {
  value = try(libvirt_domain.node.network_interface[0].addresses[0], null)
}
