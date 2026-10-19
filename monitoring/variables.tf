variable "grafana_url" {
  description = "Grafana HTTP API used by this stack. Apply it on the workstation after Ansible starts Grafana."
  type        = string
  default     = "http://127.0.0.1:3000"
}

variable "prometheus_url" {
  description = "Prometheus URL as Grafana reaches it. Both containers use the host network."
  type        = string
  default     = "http://127.0.0.1:9090"
}

variable "grafana_admin_user" {
  type    = string
  default = "admin"
}

variable "grafana_admin_password" {
  description = "Same password as ansible/group_vars/gpu.yml."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.grafana_admin_password) >= 12 && var.grafana_admin_password != "replace-with-a-lab-password"
    error_message = "Set grafana_admin_password in monitoring/terraform.tfvars to the password Ansible used, at least 12 characters."
  }
}
