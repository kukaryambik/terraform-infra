resource "digitalocean_project" "default" {
  name        = "kroche-default"
  description = "Pet project for self-development."
  purpose     = "Kubernetes Cluster"
  environment = "Production"
}

resource "random_pet" "do-k8s-cluster" {}

locals {
  cluster_name = "${digitalocean_project.default.name}-${random_pet.do-k8s-cluster.id}"
}

module "do-k8s-cluster" {
  source  = "kroche-co/k8s-cluster/digitalocean"
  version = "v0.2.4"

  depends_on = [digitalocean_project.default]

  project_name = digitalocean_project.default.name

  name                      = local.cluster_name
  region                    = "ams3"
  kubernetes_version_prefix = "1.25."
  auto_upgrade              = true
  surge_upgrade             = true

  node_pools = [{
    default    = true
    name       = "worker-pool"
    size       = "s-4vcpu-8gb"
    auto_scale = true
    min_nodes  = 1
    max_nodes  = 3
  }]

  maintenance_policy = {
    start_time = "04:00"
    day        = "monday"
  }
}

data "digitalocean_kubernetes_cluster" "default" {
  depends_on = [module.do-k8s-cluster]

  name = local.cluster_name
}
