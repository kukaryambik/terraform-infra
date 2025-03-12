provider "helm" {
  kubernetes {
    host  = component.cluster.cluster_endpoint
    token = component.cluster.cluster_token
    cluster_ca_certificate = base64decode(
      component.cluster.cluster_ca_certificate
    )
  }
}

resource "helm_release" "argocd" {

  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "7.8.10"
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
