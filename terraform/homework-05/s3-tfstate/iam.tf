/*
  Access rights are given according to documentation
  (https://yandex.cloud/en/docs/storage/security/)
*/
/*
  S3 "user" account creation and configuration
*/
// Create SA
resource "yandex_iam_service_account" "s3_sa_user" {
  folder_id = var.folder_id
  name      = var.s3_sa_user_name
}

// Grant permissions
resource "yandex_resourcemanager_folder_iam_member" "s3_sa_user" {
  folder_id = var.folder_id
  role      = "storage.uploader"
  member    = "serviceAccount:${yandex_iam_service_account.s3_sa_user.id}"
}

// May be granted
# resource "yandex_resourcemanager_folder_iam_member" "s3_sa_user_configurer" {
#   folder_id = var.folder_id
#   role      = "storage.configurer"
#   member    = "serviceAccount:${yandex_iam_service_account.s3_sa_user.id}"
# }

// Create Static Access Keys
resource "yandex_iam_service_account_static_access_key" "s3_sa_user" {
  service_account_id = yandex_iam_service_account.s3_sa_user.id
  description        = "static access key for object storage"
}

/*
  S3 "Given Admin" account fetching and configuration
*/
data "yandex_iam_service_account" "given_s3_sa_admin" {
  service_account_id = var.bucket_admin
}

resource "yandex_resourcemanager_folder_iam_member" "given_s3_sa_admin" {
  count     = local.is_admin_provided ? 1 : 0
  folder_id = var.folder_id
  role      = "storage.admin" # admin access needed for applying policy on S3
  member    = "serviceAccount:${data.yandex_iam_service_account.given_s3_sa_admin.id}"
}

resource "yandex_iam_service_account_static_access_key" "given_s3_sa_admin" {
  count              = local.is_admin_provided ? 1 : 0
  service_account_id = data.yandex_iam_service_account.given_s3_sa_admin.id
  description        = "Static access key for admin of S3"
}

/*
  S3 "Admin" account creation and configuration
*/

resource "yandex_iam_service_account" "s3_sa_admin" {
  count     = local.is_admin_provided ? 0 : 1
  folder_id = var.folder_id
  name      = local.admin_name
}

resource "yandex_resourcemanager_folder_iam_member" "s3_sa_admin" {
  count     = local.is_admin_provided ? 0 : 1
  folder_id = var.folder_id
  role      = "storage.admin" # admin access needed for applying policy on S3
  member    = "serviceAccount:${yandex_iam_service_account.s3_sa_admin[0].id}"
}

resource "yandex_iam_service_account_static_access_key" "s3_admin_static_key" {
  count              = local.is_admin_provided ? 0 : 1
  service_account_id = yandex_iam_service_account.s3_sa_admin[0].id
  description        = "Static access key for admin of S3"
}
