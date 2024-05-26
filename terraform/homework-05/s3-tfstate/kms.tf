/*
  Docs: https://yandex.cloud/en/docs/kms/security/
*/

resource "yandex_kms_symmetric_key" "key-sym-a" {
  name              = "s3-tfstate-sse-key"
  description       = "Terraform backend S3 state SSE symmetric key"
  default_algorithm = "AES_192" # AES_128 AES_256 AES_256_HSM
  rotation_period   = "8760h"   // equal to 1 year
}

resource "yandex_resourcemanager_folder_iam_member" "kms_storage_user_sa" {
  folder_id = var.folder_id
  role      = "kms.keys.encrypterDecrypter"
  member    = "serviceAccount:${local.user_id}"
}

resource "yandex_resourcemanager_folder_iam_member" "kms_storage_viewer_sa" {
  folder_id = var.folder_id
  role      = "kms.keys.decrypter"
  member    = "serviceAccount:${local.viewer_id}"
}
