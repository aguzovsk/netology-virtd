terraform {
  required_version = "~> 1.8"

  required_providers {
    lxd = {
      source  = "terraform-lxd/lxd"
      version = "~> 2.4"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

# provider "lxd" {}
