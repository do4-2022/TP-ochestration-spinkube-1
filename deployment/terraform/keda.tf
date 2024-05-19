resource "helm_release" "keda" {
  name             = "keda"
  namespace        = "keda"
  create_namespace = true
  repository       = "https://kedacore.github.io/charts"
  chart            = "keda"
}

resource "helm_release" "keda_add_on_http" {
  name             = "keda-http-add-on"
  namespace        = "keda"
  create_namespace = true
  repository       = "https://kedacore.github.io/charts"
  chart            = "keda-add-ons-http"
  depends_on       = [helm_release.keda]
}
