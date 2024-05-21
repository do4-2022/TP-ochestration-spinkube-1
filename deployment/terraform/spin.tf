data "http" "spin_operator_runtime_class" {
  url = "https://github.com/spinkube/spin-operator/releases/download/v0.1.0/spin-operator.runtime-class.yaml"
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