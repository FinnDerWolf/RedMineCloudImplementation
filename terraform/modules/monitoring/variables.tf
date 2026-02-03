variable "namespace" {
  description = "Namespace for monitoring stack"
  type        = string
  default     = "monitoring"
}

variable "chart_version" {
  description = "kube-prometheus-stack Helm chart version"
  type        = string
  default     = "56.6.0"
}
