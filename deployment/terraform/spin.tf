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

resource "helm_release" "kwasm" {
  name             = "kwasm-operator"
  namespace        = "kwasm"
  create_namespace = true
  repository       = "http://kwasm.sh/kwasm-operator/"
  chart            = "kwasm-operator"
  atomic           = true
  cleanup_on_fail  = true
  wait             = true
  depends_on       = [kubectl_manifest.spin_operator_shim_executor]
}

resource "null_resource" "annotate_nodes" {
  triggers = {
    always_run = "${timestamp()}" // Always run this resource
  }

  provisioner "local-exec" {
    command = "kubectl annotate node --all kwasm.sh/kwasm-node=true"
  }
}