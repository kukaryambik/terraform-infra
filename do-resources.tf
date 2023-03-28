resource "digitalocean_project" "default" {
  name        = "kroche-default"
  description = "Pet project for self-development."
  purpose     = "Kubernetes Cluster"
  environment = "Production"
}

resource "random_pet" "k8s-cluster" {
  # If I want to recreate or migrate to a new cluster,
  # I can add a number to the list, create an additional cluster
  # and then delete the previous one.
  for_each = toset(["001"])
}

module "do-k8s-cluster" {
  for_each = random_pet.k8s-cluster
  source   = "github.com/kroche-co/terraform-digitalocean-k8s-cluster.git"

  name                      = "${digitalocean_project.default.name}-${each.value.id}"
  region                    = "ams3"
  kubernetes_version_prefix = "1.24."
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
