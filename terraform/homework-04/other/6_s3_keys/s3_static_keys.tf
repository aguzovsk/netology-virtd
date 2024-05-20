// Create SA
resource "yandex_iam_service_account" "sa-s3" {
  folder_id = var.folder_id
  name      = "s3-terraform-sa"
}

// Grant permissions
resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id = var.folder_id
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.sa-s3.id}"
}

// Create Static Access Keys
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.sa-s3.id
  description        = "static access key for object storage"
}

resource "random_id" "aws_profile" {
  keepers = {
    static_key_id = yandex_iam_service_account_static_access_key.sa-static-key.id
  }

  byte_length = 8
}


resource "terraform_data" "check_if_static_key_changed" {
  triggers_replace = [
    yandex_iam_service_account_static_access_key.sa-static-key.id
  ]

  provisioner "local-exec" {
    command = <<-EOT
      mkdir -p ~/.aws
      cat <<EOF >> ~/.aws/credentials
      [yandex-${random_id.aws_profile.id}]
      aws_access_key_id = ${yandex_iam_service_account_static_access_key.sa-static-key.access_key}
      aws_secret_access_key = ${yandex_iam_service_account_static_access_key.sa-static-key.secret_key}
      EOF
    EOT
  }
}
