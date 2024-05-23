/*
Terraform cannot work with YC S3 Buckets if those Actions are not set on the bucket level:
  s3:ListBucket
  s3:GetBucketVersioning
  s3:GetBucketCORS
  s3:GetBucketWebsite
  s3:GetEncryptionConfiguration
*/

resource "yandex_storage_bucket" "tfstate" {
  access_key = local.admin_static_key.access_key
  secret_key = local.admin_static_key.secret_key
  bucket     = local.bucket_name
  max_size   = local.GiB

  policy = templatefile("${path.module}/policy.json.tftpl", {
    tfstate_sa   = yandex_iam_service_account.s3_sa_user.id,
    bucket_name  = local.bucket_name
    bucket_owner = var.bucket_owner
    bucket_admin = local.admin.id
    item         = var.path_to_tfstate
  })

  versioning {
    enabled = var.versioning.is_enabled
  }

  lifecycle_rule {
    id      = "cleanupoldversions"
    enabled = var.versioning.has_lifecycle && var.versioning.is_enabled
    noncurrent_version_expiration {
      days = var.versioning.retention
    }
  }
}


resource "terraform_data" "final_info" {
  triggers_replace = [
    yandex_iam_service_account_static_access_key.s3_sa_user.id,
    var.is_aws_cli_installed
  ]

  input = {
    backend_info         = local.backend_info_file
    admin_info           = local.admin_info_file
    aws_profile          = var.aws_profile
    aws_credentials_file = local.aws_credentials_file
  }

  provisioner "local-exec" {
    # Bash is required, sh cannot do "echo -e" (does not recognize -e option)
    interpreter = ["bash", "-c"]
    when        = create
    on_failure  = continue
    command     = <<-EOT
      mkdir -p ${dirname(local.aws_credentials_file)}
      touch ${local.aws_credentials_file}
      sed -e '/\[${var.aws_profile}\]/,+2d' < ${local.aws_credentials_file} > ${local.aws_credentials_file}

      cat <<EOF >> ${local.aws_credentials_file}
      [${var.aws_profile}]
      aws_access_key_id = ${local.user_static_key.access_key}
      aws_secret_access_key = ${local.user_static_key.secret_key}
      EOF

      export AWS_PROFILE=${var.aws_profile}
      echo -e "${local.user_static_key.access_key}\n${local.user_static_key.secret_key}\nru-central1\n\n" | aws configure
      aws dynamodb create-table \
        --table-name ${local.lock_table_name} \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --endpoint ${yandex_ydb_database_serverless.ydb-lock-db.document_api_endpoint}


      cat <<EOF > ${local.backend_info_file}
      profile = "${var.aws_profile}"
      dynamodb_endpoint = "${yandex_ydb_database_serverless.ydb-lock-db.document_api_endpoint}"
      bucket = "${yandex_storage_bucket.tfstate.bucket}"
      ${var.is_aws_cli_installed ? "dynamodb_table = \"${local.lock_table_name}\"" : "# dynamodb_table = SHOULD BE CREATED  BY YOURSELF"}

      key                         = "terraform.tfstate"
      endpoint                    = "storage.yandexcloud.net"
      region                      = "ru-central1"
      skip_region_validation      = true
      skip_credentials_validation = true
      EOF

      cat <<EOF > ${local.admin_info_file}
      admin_service_account_name = ${local.admin.name}
      admin_service_account_id   = ${local.admin.service_account_id}
      access_key = ${local.admin_static_key.access_key}
      EOF
    EOT
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    when        = destroy
    on_failure  = continue
    command     = <<-EOT
      rm ${self.input.backend_info} || true
      rm ${self.input.backend_info} || true
      sed -e '/\[${self.input.aws_profile}\]/,+2d' < ${self.input.aws_credentials_file} > ${self.input.aws_credentials_file}
    EOT
  }
}
