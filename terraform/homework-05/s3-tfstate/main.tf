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
    bucket_name   = local.bucket_name
    bucket_owner  = var.bucket_owner_id
    bucket_admin  = local.admin_id
    bucket_user   = local.user_id
    bucket_viewer = local.viewer_id
    item          = var.path_to_tfstate
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

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = yandex_kms_symmetric_key.key-sym-a.id
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

resource "terraform_data" "dynamodb_table" {
  # If YDB database binding is not specified it may run before binding is in effect
  depends_on = [yandex_ydb_database_iam_binding.editor, terraform_data.user_setup]

  triggers_replace = [
    var.is_aws_cli_installed,
    yandex_ydb_database_serverless.ydb-lock-db.id,
    var.ydb_table_name,
  ]

  input = {
    table_name       = var.ydb_table_name
    doc_api_endpoint = yandex_ydb_database_serverless.ydb-lock-db.document_api_endpoint
    access_key       = local.user_static_key.access_key
    secret_key       = local.user_static_key.secret_key
  }

  provisioner "local-exec" {
    when    = create
    command = <<EOT
      aws dynamodb create-table \
        --table-name ${var.ydb_table_name} \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --endpoint ${yandex_ydb_database_serverless.ydb-lock-db.document_api_endpoint} \
        --profile ${var.aws_profile_user}
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
      export AWS_ACCESS_KEY_ID=${self.input.access_key}
      export AWS_SECRET_ACCESS_KEY=${nonsensitive(self.input.secret_key)}
      aws dynamodb delete-table \
        --table-name ${self.input.table_name}
        --endpoint ${self.input.doc_api_endpoint} \
        --region ru-central1
    EOT
  }
}

resource "terraform_data" "user_setup" {
  # If bucket/path within bucket or ydb db/table make changes do it on your own
  triggers_replace = [
    local.user_static_key.id,
    var.aws_profile_user,
  ]

  input = {
    user_info            = local.user_info_file
    aws_profile_user     = var.aws_profile_user
    aws_credentials_file = local.aws_credentials_file
    aws_config_file      = local.aws_config_file
  }

  provisioner "local-exec" {
    when       = create
    on_failure = continue
    command    = <<-EOT
      mkdir -p ${dirname(local.aws_credentials_file)}
      touch ${local.aws_credentials_file}
      touch ${local.aws_config_file}
      sed -i -e '/\[${var.aws_profile_user}\]/,+2d' ${local.aws_credentials_file}
      sed -i -e '/\[profile ${var.aws_profile_user}\]/,+1d' ${local.aws_config_file}

      cat <<EOF >> ${local.aws_credentials_file}
      [${var.aws_profile_user}]
      aws_access_key_id = ${local.user_static_key.access_key}
      aws_secret_access_key = ${local.user_static_key.secret_key}
      EOF

      cat <<EOF >> ${local.aws_config_file}
      [profile ${var.aws_profile_user}]
      region = ru-central1
      EOF

      cat <<EOF > ${local.user_info_file}
      backend "s3" {
        profile                     = "${var.aws_profile_user}"
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
    EOT
  }

  provisioner "local-exec" {
    when       = destroy
    on_failure = continue
    command    = <<EOT
      rm ${self.input.user_info} || true
      sed -i -e '/\[${self.input.aws_profile_user}\]/,+2d' ${self.input.aws_credentials_file}
      sed -i -e '/\[profile ${self.input.aws_profile_user}\]/,+1d' ${self.input.aws_config_file}
    EOT
  }
}

resource "terraform_data" "viewer_setup" {
  # If bucket/path within bucket or ydb db/table make changes do it on your own
  triggers_replace = [
    local.viewer_static_key.id,
    var.aws_profile_viewer
  ]

  input = {
    viewer_info          = local.viewer_info_file
    aws_profile_viewer   = var.aws_profile_viewer
    aws_credentials_file = local.aws_credentials_file
    aws_config_file      = local.aws_config_file
  }

  provisioner "local-exec" {
    when       = create
    on_failure = continue
    command    = <<-EOT
      mkdir -p ${dirname(local.aws_credentials_file)}
      touch ${local.aws_credentials_file}
      touch ${local.aws_config_file}

      sed -i -e '/\[${var.aws_profile_viewer}\]/,+2d' ${local.aws_credentials_file}
      sed -i -e '/\[profile ${var.aws_profile_viewer}\]/,+1d' ${local.aws_config_file}

      cat <<EOF >> ${local.aws_credentials_file}
      [${var.aws_profile_viewer}]
      aws_access_key_id = ${local.viewer_static_key.access_key}
      aws_secret_access_key = ${nonsensitive(local.viewer_static_key.secret_key)}
      EOF

      cat <<EOF >> ${local.aws_config_file}
      [profile ${var.aws_profile_viewer}]
      region = ru-central1
      EOF

      cat <<EOF > ${local.viewer_info_file}
      data "terraform_remote_state" "example_name" {
        backend = "s3"
        config = {
          profile                     = "${var.aws_profile_viewer}"
          bucket                      = "${yandex_storage_bucket.tfstate.bucket}"

          key                         = "${var.path_to_tfstate}"
          endpoint                    = "storage.yandexcloud.net"
          region                      = "ru-central1"
          skip_region_validation      = true
          skip_credentials_validation = true
          # skip_requesting_account_id  = true # This option is required for Terraform 1.6.1 or higher.
          # skip_s3_checksum            = true # This option is required to describe backend for Terraform version 1.6.3 or higher.
        }
      }
      EOF
    EOT
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    when        = destroy
    on_failure  = continue
    command     = <<-EOT
      rm ${self.input.viewer_info} || true
      sed -i -e '/\[${self.input.aws_profile_viewer}\]/,+2d' ${self.input.aws_credentials_file}
      sed -i -e '/\[profile ${self.input.aws_profile_viewer}\]/,+1d' ${self.input.aws_config_file}
    EOT
  }
}

resource "terraform_data" "admin_info" {
  input = {
    admin_info = local.admin_info_file
  }

  provisioner "local-exec" {
    when    = create
    command = <<-EOT
      cat <<EOF > ${local.admin_info_file}
      admin_service_account_name = ${local.admin_name}
      admin_service_account_id   = ${local.admin_id}
      access_key = ${local.admin_static_key.access_key}
      EOF
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
      rm ${self.input.admin_info} || true
    EOT
  }
}
