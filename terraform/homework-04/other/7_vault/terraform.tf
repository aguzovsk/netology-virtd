terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.2"
    }
  }
  required_version = "~> 1.5.7"
}

provider "vault" {
  address         = "http://localhost:8200"
  skip_tls_verify = true
  token           = "education" #checkov:skip=CKV_SECRET_6:Base64 High Entropy String
}
