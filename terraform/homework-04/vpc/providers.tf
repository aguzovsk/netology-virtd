terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = "~> 1.5.7"

  backend "s3" {
    profile           = "yandex-s3-tfstate"
    dynamodb_endpoint = "https://docapi.serverless.yandexcloud.net/ru-central1/b1gtkbd8a8583hto5i3s/etn9vhpqgt4bddk0t1f8"
    bucket            = "s3-terraform-backend-netology-aguzovsk1"
    dynamodb_table    = "aws-dynamodb-lock-table"

    key                         = "terraform.tfstate"
    endpoint                    = "storage.yandexcloud.net"
    region                      = "ru-central1"
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

provider "yandex" {
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  service_account_key_file = file("~/.authorized_key.json")
}
