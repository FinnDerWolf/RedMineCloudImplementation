output "namespace" {
  value = var.namespace
}

output "release_name" {
  value = helm_release.kube_prometheus_stack.name
}
