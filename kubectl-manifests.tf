provider "kubectl" {
  host  = module.do-k8s-cluster.endpoint
  token = module.do-k8s-cluster.kube_config.token
  cluster_ca_certificate = base64decode(
    module.do-k8s-cluster.kube_config.cluster_ca_certificate
  )
  load_config_file = false
}

resource "kubectl_manifest" "argocd-appset" {
  depends_on         = [kubernetes_secret.argocd-creds]
  override_namespace = "argocd"
  server_side_apply  = true
  yaml_body          = file("argocd/appset_default.yaml")
}
