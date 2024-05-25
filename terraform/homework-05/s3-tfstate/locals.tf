locals {
  bucket_name          = "s3-terraform-backend-netology-${var.s3-name-suffix}"
  GiB                  = 1073741824 # 1 GiB
  aws_credentials_file = "~/.aws/credentials"
  aws_config_file      = "~/.aws/config"
  user_info_file       = "${path.module}/../s3-user.info"
  admin_info_file      = "${path.module}/../s3-admin.info"
  viewer_info_file     = "${path.module}/../s3-viewer.info"

  # is_user_provided = can(coalesce(data.yandex_iam_service_account.given_s3_user_by_id.id, data.yandex_iam_service_account.given_s3_user_by_name.id))
  is_user_provided = data.yandex_iam_service_account.given_s3_user_by_id.id != null
  user_name        = coalesce(data.yandex_iam_service_account.given_s3_user_by_id.name, var.bucket_user_name, "s3-terraform-sa-user")
  # user = (local.is_user_provided ? (data.yandex_iam_service_account.given_s3_user_by_id.id != null ? data.yandex_iam_service_account.given_s3_user_by_id
  # : data.yandex_iam_service_account.given_s3_user_by_name) : yandex_iam_service_account.newly_created_s3_user[0])
  # user_id         = coalesce(data.yandex_iam_service_account.given_s3_user_by_id.id, yandex_iam_service_account.newly_created_s3_user[0].id)
  user_id = (length(yandex_iam_service_account.newly_created_s3_user[0]) > 0 ? yandex_iam_service_account.newly_created_s3_user[0].id
  : data.yandex_iam_service_account.given_s3_user_by_id.id)
  user_static_key = yandex_iam_service_account_static_access_key.s3_user_static_key

  is_admin_provided = can(coalesce(data.yandex_iam_service_account.given_s3_admin_by_id.id))
  admin_name = coalesce(data.yandex_iam_service_account.given_s3_admin_by_id.name, var.bucket_admin_name,
  strcontains(local.user_name, "user") ? replace(local.user_name, "user", "admin") : "${local.user_name}-admin")
  # admin = (local.is_admin_provided ? (data.yandex_iam_service_account.given_s3_admin_by_id.id != null ? data.yandex_iam_service_account.given_s3_admin_by_id
  # : data.yandex_iam_service_account.given_s3_admin_by_name) : yandex_iam_service_account.newly_created_s3_admin[0])
  admin_id = (length(yandex_iam_service_account.newly_created_s3_admin) > 0 ? yandex_iam_service_account.newly_created_s3_admin[0].id
  : data.yandex_iam_service_account.given_s3_admin_by_id.id)
  admin_static_key = yandex_iam_service_account_static_access_key.s3_admin_static_key

  # is_viewer_provided = can(coalesce(data.yandex_iam_service_account.given_s3_viewer_by_id.id, data.yandex_iam_service_account.given_s3_viewer_by_name.id))
  is_viewer_provided = data.yandex_iam_service_account.given_s3_viewer_by_id.id != null
  viewer_name = coalesce(data.yandex_iam_service_account.given_s3_viewer_by_id.name, var.bucket_viewer_name,
  strcontains(local.user_name, "user") ? replace(local.user_name, "user", "viewer") : "${local.user_name}-viewer")
  # viewer = (local.is_viewer_provided ? (data.yandex_iam_service_account.given_s3_viewer_by_id.id != null ? data.yandex_iam_service_account.given_s3_viewer_by_id
  # : data.yandex_iam_service_account.given_s3_viewer_by_name) : yandex_iam_service_account.newly_created_s3_viewer[0])
  # viewer_id         = coalesce(data.yandex_iam_service_account.given_s3_viewer_by_id.id, yandex_iam_service_account.newly_created_s3_viewer[0].id)
  viewer_id = (length(yandex_iam_service_account.newly_created_s3_viewer[0]) > 0 ? yandex_iam_service_account.newly_created_s3_viewer[0].id
  : data.yandex_iam_service_account.given_s3_viewer_by_id.id)
  viewer_static_key = yandex_iam_service_account_static_access_key.s3_viewer_static_key
}
