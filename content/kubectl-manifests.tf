locals {
  opns = "onepassword-connect"
}

provider "kubectl" {
  host  = data.terraform_remote_state.base.outputs.cluster_endpoint
  token = data.terraform_remote_state.base.outputs.cluster_token
  cluster_ca_certificate = base64decode(
    data.terraform_remote_state.base.outputs.cluster_ca_certificate
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

  depends_on         = [kubectl_manifest.onepassword-connect-ns]
  override_namespace = local.opns
  server_side_apply  = true
  yaml_body = templatefile(
    "onepassword-connect/secret_onepassword-credentials.yaml",
    { creds = base64encode(var.OP_CREDENTIALS) }
  )
}

resource "kubectl_manifest" "onepassword-token" {

  depends_on         = [kubectl_manifest.onepassword-connect-ns]
  override_namespace = local.opns
  server_side_apply  = true
  yaml_body = templatefile(
    "onepassword-connect/secret_onepassword-token.yaml",
    { token = base64encode(var.OP_TOKEN) }
  )
}
