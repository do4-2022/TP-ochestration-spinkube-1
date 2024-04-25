terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">=2.9.0"
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

data "http" "spin_operator_shim_executor" {
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
  atomic           = true
  cleanup_on_fail  = true
  wait             = true
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
  wait             = true
  version          = "0.1.0"
  atomic           = true
  cleanup_on_fail  = true
  depends_on       = [helm_release.cert-manager]
}

resource "kubectl_manifest" "spin_operator_shim_executor" {
  yaml_body = data.http.spin_operator_shim_executor.response_body
  depends_on = [
    helm_release.spin_operator,
    kubectl_manifest.spin_operator_runtime_class,
    kubernetes_manifest.spin_app_crd,
    kubernetes_manifest.spin_app_executor_crd
  ]
}

resource "kubernetes_manifest" "spin_app_ingress" {
  manifest = yamldecode(file("${path.module}/kube/network/ingress.yaml"))
}

resource "helm_release" "keda" {
  name             = "keda"
  namespace        = "keda"
  create_namespace = true
  repository       = "https://kedacore.github.io/charts"
  chart            = "keda"
}

module "flux-bootstrap" {
  source = "./modules/flux-bootstrap"
  depends_on = [ kubectl_manifest.spin_operator_shim_executor, helm_release.keda]
}

module "flux-sync" {
  source               = "./modules/flux-sync"
  name                 = "cluster-keda"
  path                 = "deployment/flux"
  service_account_name = "kustomize-controller"
  depends_on           = [module.flux-bootstrap]
}
