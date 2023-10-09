data "digitalocean_kubernetes_cluster" "default" {
  name = module.do-k8s-cluster.name
}

provider "helm" {
  kubernetes {
    host  = data.digitalocean_kubernetes_cluster.default.endpoint
    token = data.digitalocean_kubernetes_cluster.default.kube_config.token
    cluster_ca_certificate = base64decode(
      data.digitalocean_kubernetes_cluster.default.kube_config.cluster_ca_certificate
    )
  }
}

resource "helm_release" "argocd" {
  count      = data.digitalocean_kubernetes_cluster.default.endpoint ? 1 : 0
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "5.34.1"
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
