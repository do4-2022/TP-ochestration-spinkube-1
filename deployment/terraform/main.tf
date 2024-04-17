terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.4.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
    http = {
      source = "hashicorp/http"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
    }
  }
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}
provider "kubernetes" {
  config_path = "~/.kube/config"
}

data "http" "spin_operator_runtime_class" {
  url = "https://github.com/spinkube/spin-operator/releases/download/v0.1.0/spin-operator.runtime-class.yaml"
}

data "http" "spin_operator_shrim_executor" {
  url = "https://github.com/spinkube/spin-operator/releases/download/v0.1.0/spin-operator.shim-executor.yaml"
}

resource "kubectl_manifest" "spin_operator_runtime_class" {
  yaml_body = data.http.spin_operator_runtime_class.response_body
}

resource "kubernetes_manifest" "spin_app_crd" {
  manifest = yamldecode(file("${path.module}/kube/crds/spin/spinApp.yaml"))
}

resource "kubernetes_manifest" "spin_app_executor_crd" {
  manifest = yamldecode(file("${path.module}/kube/crds/spin/spinAppExecutor.yaml"))
}

resource "helm_release" "cert-manager" {
  name             = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  atomic = true
  cleanup_on_fail = true
  wait = true
  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "helm_release" "spin_operator" {
  name             = "spin-operator"
  namespace        = "spin-operator"
  create_namespace = true
  chart            = "oci://ghcr.io/spinkube/charts/spin-operator"
  wait            = true
  version         = "0.1.0"
  atomic          = true
  cleanup_on_fail = true
}

resource "kubectl_manifest" "spin_operator_shrim_executor" {
  yaml_body = data.http.spin_operator_shrim_executor.response_body
}

resource "helm_release" "keda" {
  name             = "keda"
  namespace        = "keda"
  create_namespace = true
  repository       = "https://kedacore.github.io/charts"
  chart            = "keda"
}
