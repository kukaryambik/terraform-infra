locals {
  opns = "onepassword-connect"
}

provider "kubernetes" {
  host  = module.do-k8s-cluster.endpoint
  token = module.do-k8s-cluster.kube_config.token
  cluster_ca_certificate = base64decode(
    module.do-k8s-cluster.kube_config.cluster_ca_certificate
  )
}

resource "kubernetes_secret" "argocd-creds" {
  metadata {
    name      = "creds--kroche-dev-do-k8s-cluster"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    "name"     = "kroche-dev-do-k8s-cluster"
    "type"     = "git"
    "url"      = "https://gitlab.com/kukaryambik/kroche-dev-do-k8s-cluster.git"
    "project"  = "default"
    "username" = var.ARGOCD_USERNAME
    "password" = var.ARGOCD_PASSWORD
  }

  immutable = true

  depends_on = [helm_release.argocd]
}

resource "kubernetes_namespace" "onepassword-connect" {
  metadata {
    name = local.opns
  }
  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels
    ]
  }

  depends_on = [module.do-k8s-cluster]
}

resource "kubernetes_secret" "onepassword-credentials" {
  metadata {
    name      = "onepassword-credentials"
    namespace = local.opns
  }

  binary_data = {
    "1password-credentials.json" = base64encode(var.OP_CREDENTIALS)
  }

  immutable = true

  depends_on = [kubernetes_namespace.onepassword-connect]
}

resource "kubernetes_secret" "onepassword-token" {
  metadata {
    name      = "onepassword-token"
    namespace = local.opns
  }

  binary_data = {
    token = var.OP_TOKEN
  }

  immutable = true

  depends_on = [kubernetes_namespace.onepassword-connect]
}
