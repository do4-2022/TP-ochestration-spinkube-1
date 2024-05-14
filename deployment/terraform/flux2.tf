module "flux-bootstrap" {
  source     = "./modules/flux-bootstrap"
  depends_on = [kubectl_manifest.spin_operator_shim_executor, helm_release.keda]
}

module "flux-sync" {
  source               = "./modules/flux-sync"
  name                 = "cluster-keda"
  path                 = "deployment/flux"
  service_account_name = "kustomize-controller"
  depends_on           = [module.flux-bootstrap]
}
