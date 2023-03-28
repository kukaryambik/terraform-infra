locals {
  opns = "onepassword-connect"
}

provider "kubectl" {
  host  = module.do-k8s-cluster.endpoint
  token = module.do-k8s-cluster.kube_config.token
  cluster_ca_certificate = base64decode(
    module.do-k8s-cluster.kube_config.cluster_ca_certificate
  )
  load_config_file = false
}

resource "kubectl_manifest" "argocd-appset" {
  depends_on         = [helm_release.argocd]
  override_namespace = "argocd"
  server_side_apply  = true
  yaml_body          = file("argocd/appset_default.yaml")
}

resource "kubectl_manifest" "onepassword-connect-ns" {
  server_side_apply = true
  ignore_fields = [
    "metadata.annotations",
    "metadata.labels",
  ]
  yaml_body = templatefile(
    "onepassword-connect/ns_onepassword-connect.yaml",
    { name = local.opns }
  )
  lifecycle {
    prevent_destroy = true
  }
}

resource "kubectl_manifest" "onepassword-credentials" {
  depends_on         = [kubectl_manifest.onepassword-connect-ns]
  override_namespace = local.opns
  server_side_apply  = true
  yaml_body = templatefile(
    "onepassword-connect/secret_onepassword-credantials.yaml",
    { creds = base64encode(var.OP_CREDENTIALS) }
  )
}

resource "kubectl_manifest" "onepassword-token" {
  depends_on         = [kubectl_manifest.onepassword-connect-ns]
  override_namespace = local.opns
  server_side_apply  = true
  yaml_body = templatefile(
    "onepassword-connect/secret_onepassword-token.yaml",
    { token = var.OP_TOKEN }
  )
}
