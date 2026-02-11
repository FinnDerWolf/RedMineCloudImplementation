locals {
  dashboards = {
    cluster       = "cluster_overview.json"
    namespace = "pods_overview.json"
    pod        = "single_pod.json"
  }
}

resource "kubernetes_config_map" "grafana_dashboards" {
  for_each = local.dashboards

  metadata {
    name      = "grafana-dashboard-${each.key}"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    labels = {
      grafana_dashboard = "1"
    }
  }

  data = {
    "${each.value}" = file("${path.module}/dashboards/${each.value}")
  }
}
