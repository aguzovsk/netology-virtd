terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.119"
    }
  }
  required_version = "~> 1.5.7"

  backend "s3" {
    profile           = "yandex-s3-tfstate"
    dynamodb_endpoint = "https://docapi.serverless.yandexcloud.net/ru-central1/b1gtkbd8a8583hto5i3s/etnbuf6cim4nnmuhu309"
    dynamodb_table    = "aws-dynamodb-lock-table"
    bucket            = "s3-terraform-backend-netology-aguzovsk1"

    key                         = "terraform.tfstate"
    endpoint                    = "storage.yandexcloud.net"
    region                      = "ru-central1"
    skip_region_validation      = true
    skip_credentials_validation = true
    # skip_requesting_account_id  = true # This option is required for Terraform 1.6.1 or higher.
    # skip_s3_checksum            = true # This option is required to describe backend for Terraform version 1.6.3 or higher.
  }
}

provider "yandex" {
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  service_account_key_file = file("~/.authorized_key.json")
}
