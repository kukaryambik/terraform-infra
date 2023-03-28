terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "kroche"

    workspaces {
      name = "kroche-default"
    }
  }

  required_providers {
    random = {
      source = "hashicorp/random"
      version = ">= 3.4.0"
    }
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = ">= 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.9.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.18.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}
