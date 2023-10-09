provider "helm" {
  kubernetes {
    host  = module.do-k8s-cluster.endpoint
    token = module.do-k8s-cluster.kube_config.token
    cluster_ca_certificate = base64decode(
      module.do-k8s-cluster.kube_config.cluster_ca_certificate
    )
  }
}

resource "helm_release" "argocd" {

  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "5.46.7"
  atomic     = true
  timeout    = 600

  namespace        = "argocd"
  create_namespace = true

  values = [
    "${file("argocd/values.yaml")}"
  ]

  set_sensitive {
    name  = "configs.repositories.argocd-cluster.username"
    value = var.ARGOCD_USERNAME
  }

  set_sensitive {
    name  = "configs.repositories.argocd-cluster.password"
    value = var.ARGOCD_PASSWORD
  }
}
