resource "grafana_folder" "lab" {
  title = "HPC lab"
  uid   = "hpc-lab"
}

resource "grafana_data_source" "prometheus" {
  type       = "prometheus"
  name       = "Prometheus"
  uid        = "prometheus"
  url        = var.prometheus_url
  is_default = true

  json_data_encoded = jsonencode({
    httpMethod   = "POST"
    timeInterval = "15s"
  })
}

resource "grafana_dashboard" "nodes" {
  folder      = grafana_folder.lab.uid
  overwrite   = true
  message     = "Managed by Terraform"
  config_json = file("${path.module}/dashboards/nodes.json")

  depends_on = [grafana_data_source.prometheus]
}
