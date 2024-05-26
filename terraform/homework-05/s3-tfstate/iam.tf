/*
  Access rights are given according to documentation
  (https://yandex.cloud/en/docs/storage/security/)
*/
/*
  S3 "user" account creation and configuration
*/

data "yandex_iam_service_account" "given_s3_user_by_id" {
  service_account_id = coalesce(var.bucket_user_id, "NONE!")
}

# When specified name was not found throws an error
# data "yandex_iam_service_account" "given_s3_user_by_name" {
#   name = coalesce(var.bucket_user_name, "NONE!")
# }

resource "yandex_iam_service_account" "newly_created_s3_user" {
  count     = local.is_user_provided ? 0 : 1
  folder_id = var.folder_id
  name      = local.user_name
}

resource "yandex_resourcemanager_folder_iam_member" "s3_sa_user" {
  folder_id = var.folder_id
  role      = "storage.uploader"
  member    = "serviceAccount:${local.user_id}"
}

// May be granted
# resource "yandex_resourcemanager_folder_iam_member" "s3_sa_user_configurer" {
#   folder_id = var.folder_id
#   role      = "storage.configurer"
#   member    = "serviceAccount:${yandex_iam_service_account.s3_sa_user.id}"
# }

resource "yandex_iam_service_account_static_access_key" "s3_user_static_key" {
  service_account_id = local.user_id
  description        = "static access key for object storage"
}

/*
  S3 "Admin" account creation and configuration
*/

data "yandex_iam_service_account" "given_s3_admin_by_id" {
  service_account_id = coalesce(var.bucket_admin_id, "NONE!")
}

# data "yandex_iam_service_account" "given_s3_admin_by_name" {
#   name = coalesce(var.bucket_admin_name, "NONE!")
# }

resource "yandex_iam_service_account" "newly_created_s3_admin" {
  count     = local.is_admin_provided ? 0 : 1
  folder_id = var.folder_id
  name      = local.admin_name
}

resource "yandex_resourcemanager_folder_iam_member" "s3_sa_admin" {
  folder_id = var.folder_id
  role      = "storage.admin" # admin access needed for applying policy on S3
  member    = "serviceAccount:${local.admin_id}"
}

resource "yandex_iam_service_account_static_access_key" "s3_admin_static_key" {
  service_account_id = local.admin_id
  description        = "Static access key for admin of S3"
}


/*
  S3 "Viewer" account creation anc configuration
*/

data "yandex_iam_service_account" "given_s3_viewer_by_id" {
  service_account_id = coalesce(var.bucket_viewer_id, "NONE!")
}

# data "yandex_iam_service_account" "given_s3_viewer_by_name" {
#   name = coalesce(var.bucket_viewer_name, "NONE!")
# }

resource "yandex_iam_service_account" "newly_created_s3_viewer" {
  count     = local.is_viewer_provided ? 0 : 1
  folder_id = var.folder_id
  name      = local.viewer_name
}

resource "yandex_resourcemanager_folder_iam_member" "s3_sa_viewer" {
  folder_id = var.folder_id
  role      = "storage.viewer"
  member    = "serviceAccount:${local.viewer_id}"
}

resource "yandex_iam_service_account_static_access_key" "s3_viewer_static_key" {
  service_account_id = local.viewer_id
  description        = "Static access key for viewer of S3"
}
