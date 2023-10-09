terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "kroche"

    workspaces {
      name = "kroche-default"
    }
  }

  required_providers {
    random = {
      source  = "hashicorp/random"
      version = ">= 3.4.0"
    }
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = ">= 2.0"
    }
  }
}
