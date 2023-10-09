locals {
  opns = "onepassword-connect"
}

provider "kubectl" {
  host  = data.digitalocean_kubernetes_cluster.default.endpoint
  token = data.digitalocean_kubernetes_cluster.default.kube_config.token
  cluster_ca_certificate = base64decode(
    data.digitalocean_kubernetes_cluster.default.kube_config.cluster_ca_certificate
  )
  load_config_file = false
}

resource "kubectl_manifest" "argocd-appset" {
  count              = data.digitalocean_kubernetes_cluster.default.endpoint ? 1 : 0
  depends_on         = [helm_release.argocd]
  override_namespace = "argocd"
  server_side_apply  = true
  yaml_body          = file("argocd/appset_default.yaml")
}

resource "kubectl_manifest" "onepassword-connect-ns" {
  count             = data.digitalocean_kubernetes_cluster.default.endpoint ? 1 : 0
  server_side_apply = true
  apply_only        = true
  ignore_fields = [
    "metadata.annotations",
    "metadata.labels",
  ]
  yaml_body = templatefile(
    "onepassword-connect/ns_onepassword-connect.yaml",
    { name = local.opns }
  )
}

resource "kubectl_manifest" "onepassword-credentials" {
  count              = data.digitalocean_kubernetes_cluster.default.endpoint ? 1 : 0
  depends_on         = [kubectl_manifest.onepassword-connect-ns]
  override_namespace = local.opns
  server_side_apply  = true
  yaml_body = templatefile(
    "onepassword-connect/secret_onepassword-credentials.yaml",
    { creds = base64encode(var.OP_CREDENTIALS) }
  )
}

resource "kubectl_manifest" "onepassword-token" {
  count              = data.digitalocean_kubernetes_cluster.default.endpoint ? 1 : 0
  depends_on         = [kubectl_manifest.onepassword-connect-ns]
  override_namespace = local.opns
  server_side_apply  = true
  yaml_body = templatefile(
    "onepassword-connect/secret_onepassword-token.yaml",
    { token = var.OP_TOKEN }
  )
}
