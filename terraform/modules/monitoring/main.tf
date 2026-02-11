terraform {
  required_version = ">= 1.3.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13"
    }
  }
}

#######################################
# Provider
#######################################

provider "kubernetes" {
  config_path = var.kubeconfig_path
}

provider "helm" {
  kubernetes {
    config_path = var.kubeconfig_path
  }
}

#######################################
# Namespace
#######################################

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.namespace
  }
}

#######################################
# kube-prometheus-stack
#######################################

resource "helm_release" "kube_prometheus_stack" {
  name      = "kube-prometheus-stack"
  namespace = kubernetes_namespace.monitoring.metadata[0].name

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = var.chart_version

  create_namespace = false

  #values = [
  #  file("${path.module}/values.yaml")
  #]

  depends_on = [
    kubernetes_namespace.monitoring
  ]
}
