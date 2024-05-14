resource "helm_release" "this" {
  name = var.name

  repository = "https://fluxcd-community.github.io/helm-charts"
  chart      = "flux2-sync"
  version    = "1.8.2"

  namespace = "flux-system"
  create_namespace = true
  wait      = true

  ## Git Repository
  set {
    name  = "gitRepository.spec.url"
    value = "https://github.com/do4-2022/TP-ochestration-spinkube-1"
  }

  set {
    name  = "gitRepository.spec.interval"
    value = "5m"
  }

  set {
    name  = "gitRepository.spec.ref.branch"
    value = "feat/keda" #TODO: Change to main
  }

  ## Kustomization Repository
  set {
    name  = "kustomization.spec.interval"
    value = "5m"
  }

  set {
    name  = "kustomization.spec.prune"
    value = "true"
  }

  set {
    name  = "kustomization.spec.wait"
    value = "true"
  }

  set {
    name  = "kustomization.spec.path"
    value = var.path
  }
}
