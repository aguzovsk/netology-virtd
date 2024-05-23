data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "../vpc/terraform.tfstate"
  }
}


module "vm" {
  source     = "./1_cloud_init"
  network_id = module.simple_vpc.network_id
  subnet     = module.simple_vpc.subnet
  # network_id = local.network_id
  # subnet     = local.subnets[3]
}

module "simple_vpc" {
  source   = "./2_vpc"
  env_name = "Simple_Network"
  zone     = "ru-central1-a"
  cidr     = "172.18.0.0/16"
}

module "mysql_5" {
  source     = "./5_mysql"
  network_id = local.network_id
  subnets    = local.subnets
}

module "vault_7" {
  source = "./7_vault"
}

output "vault_module_outputs" {
  value = {
    example         = module.vault_7.vault_example
    created_example = module.vault_7.foo_example
  }
}

module "s3_keys_6" {
  source    = "./6_s3_keys"
  folder_id = var.folder_id
}

output "aws_profile_identifier" {
  value = module.s3_keys_6.aws_profile
}

/*
==> Generate service account & static keys with 6_s3_keys module
terraform apply -target module.s3_keys_6
export AWS_PROFILE=${aws_profile_identifier}
terraform apply -target module.s3 
*/
module "s3" {
  source      = "git::https://github.com/terraform-yc-modules/terraform-yc-s3?ref=master"
  bucket_name = local.bucket_name
  max_size    = 1073741824 # 1 GiB

  policy_console = {
    enabled = true
  }

  versioning = {
    enabled = true
  }

  policy = {
    enabled = true
    statements = [
      {
        sid    = "rule-allow-only-yourself-to-deal-with-s3-bucket"
        effect = "Allow"
        resources = [
          local.bucket_name,
          "${local.bucket_name}/*"
        ]
        actions = [
          "s3:*"
        ]
        principal = {
          type        = "CanonicalUser"
          identifiers = ["${var.yc-user-id}", "${module.s3_keys_6.service_account_id}"]
        }
      }
    ]
  }
}
