locals {
  bucket_name          = "s3-terraform-backend-netology-${var.s3-name-suffix}"
  GiB                  = 1073741824 # 1 GiB
  aws_credentials_file = "~/.aws/credentials"
  aws_config_file      = "~/.aws/config"
  backend_info_file    = "${path.module}/../s3-backend.info"
  admin_info_file      = "${path.module}/../s3-admin.info"
  admin_name           = strcontains(var.s3_sa_user_name, "user") ? replace(var.s3_sa_user_name, "user", "admin") : "${var.s3_sa_user_name}-admin"
  user_static_key      = yandex_iam_service_account_static_access_key.s3_sa_user
  is_admin_provided    = data.yandex_iam_service_account.given_s3_sa_admin.id != null
  admin                = local.is_admin_provided ? data.yandex_iam_service_account.given_s3_sa_admin : yandex_iam_service_account.s3_sa_admin[0]
  admin_static_key = (
    local.is_admin_provided ?
    yandex_iam_service_account_static_access_key.given_s3_sa_admin[0] :
  yandex_iam_service_account_static_access_key.s3_admin_static_key[0])
}
