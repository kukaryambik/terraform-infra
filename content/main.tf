terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "kroche"

    workspaces {
      name = "kroche-default"
    }
  }

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.9.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}
