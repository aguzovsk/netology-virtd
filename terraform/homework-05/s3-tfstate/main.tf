/*
Terraform Yandex provider cannot work with YC S3 Buckets if those permissions are not set
on the bucket level for the entity on which behalf we operate:
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
  # If not specified it may run before binding is in effect
  depends_on = [yandex_ydb_database_iam_binding.editor]

  triggers_replace = [
    local.user_static_key.id,
    var.is_aws_cli_installed,
    yandex_ydb_database_serverless.ydb-lock-db.id
  ]

  input = {
    backend_info         = local.backend_info_file
    admin_info           = local.admin_info_file
    aws_profile          = var.aws_profile
    aws_credentials_file = local.aws_credentials_file
    aws_config_file      = local.aws_config_file
  }
  /*
    I'm not using sed -i, since it is Linux
  */

  provisioner "local-exec" {
    # Bash is required, sh cannot do "echo -e" (does not recognize -e option)
    interpreter = ["bash", "-c"]
    when        = create
    on_failure  = continue
    command     = <<-EOT
      mkdir -p ${dirname(local.aws_credentials_file)}
      touch ${local.aws_credentials_file}
      touch ${local.aws_config_file}
      sed -i -e '/\[${var.aws_profile}\]/,+2d' ${local.aws_credentials_file}
      sed -i -e '/\[profile ${var.aws_profile}\]/,+1d' ${local.aws_config_file}

      cat <<EOF >> ${local.aws_credentials_file}
      [${var.aws_profile}]
      aws_access_key_id = ${local.user_static_key.access_key}
      aws_secret_access_key = ${nonsensitive(local.user_static_key.secret_key)}
      EOF

      cat <<EOF >> ${local.aws_config_file}
      [profile ${var.aws_profile}]
      region = ru-central1
      EOF

      aws dynamodb create-table \
        --table-name ${var.ydb_table_name} \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --endpoint ${yandex_ydb_database_serverless.ydb-lock-db.document_api_endpoint} \
        --profile ${var.aws_profile}


      cat <<EOF > ${local.backend_info_file}
      backend "s3" {
        profile                     = "${var.aws_profile}"
        dynamodb_endpoint           = "${yandex_ydb_database_serverless.ydb-lock-db.document_api_endpoint}"
        ${var.is_aws_cli_installed ? "dynamodb_table = \"${var.ydb_table_name}\"" : "# dynamodb_table = SHOULD BE CREATED  BY YOURSELF"}
        bucket                      = "${yandex_storage_bucket.tfstate.bucket}"

        key                         = "${var.path_to_tfstate}"
        endpoint                    = "storage.yandexcloud.net"
        region                      = "ru-central1"
        skip_region_validation      = true
        skip_credentials_validation = true
        # skip_requesting_account_id  = true # This option is required for Terraform 1.6.1 or higher.
        # skip_s3_checksum            = true # This option is required to describe backend for Terraform version 1.6.3 or higher.
      }
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
      rm ${self.input.admin_info} || true
      sed -i -e '/\[${self.input.aws_profile}\]/,+2d' ${self.input.aws_credentials_file}
      sed -i -e '/\[profile ${self.input.aws_profile}\]/,+1d' ${self.input.aws_config_file}
    EOT
  }
}
