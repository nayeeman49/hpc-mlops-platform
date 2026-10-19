output "node_ips" {
  description = "DHCP addresses leased to the lab VMs."
  value       = { for name, node in module.node : name => node.ip }
}

output "ssh_commands" {
  description = "Commands to reach each VM from the workstation."
  value       = { for name, node in module.node : name => "ssh ${var.ssh_user}@${node.ip}" }
}

output "ansible_inventory" {
  description = "Inventory generated from the leased addresses."
  value       = local_file.ansible_inventory.filename
}
