output "grafana_url" {
  description = "Grafana UI on the workstation."
  value       = var.grafana_url
}

output "dashboard_url" {
  description = "Node overview dashboard."
  value       = grafana_dashboard.nodes.url
}
