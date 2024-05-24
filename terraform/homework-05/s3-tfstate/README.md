## General

It will create 2 files in the parent directory:
* s3-backend.info (There will be information about S3 backend)
* s3-admin.info (There will be information about admin Service Account)

Also it will "create" AWS profile on your __LINUX__ machine.  

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.5.7 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |
| <a name="provider_yandex"></a> [yandex](#provider\_yandex) | 0.119.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [terraform_data.final_info](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [yandex_iam_service_account.s3_sa_admin](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/iam_service_account) | resource |
| [yandex_iam_service_account.s3_sa_user](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/iam_service_account) | resource |
| [yandex_iam_service_account_static_access_key.given_s3_sa_admin](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/iam_service_account_static_access_key) | resource |
| [yandex_iam_service_account_static_access_key.s3_admin_static_key](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/iam_service_account_static_access_key) | resource |
| [yandex_iam_service_account_static_access_key.s3_sa_user](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/iam_service_account_static_access_key) | resource |
| [yandex_resourcemanager_folder_iam_member.given_s3_sa_admin](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/resourcemanager_folder_iam_member) | resource |
| [yandex_resourcemanager_folder_iam_member.s3_sa_admin](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/resourcemanager_folder_iam_member) | resource |
| [yandex_resourcemanager_folder_iam_member.s3_sa_user](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/resourcemanager_folder_iam_member) | resource |
| [yandex_storage_bucket.tfstate](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/storage_bucket) | resource |
| [yandex_ydb_database_iam_binding.editor](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/ydb_database_iam_binding) | resource |
| [yandex_ydb_database_serverless.ydb-lock-db](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/ydb_database_serverless) | resource |
| [yandex_iam_service_account.given_s3_sa_admin](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/data-sources/iam_service_account) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_profile"></a> [aws\_profile](#input\_aws\_profile) | AWS profile with given name will be created (with YC credentials, you can use it with Yandex cloud not AWS itself) | `string` | `"yandex-s3-tfstate"` | no |
| <a name="input_bucket_admin"></a> [bucket\_admin](#input\_bucket\_admin) | May be omitted. ID of service account, which will have full access to the bucket itself, but not its content | `string` | `null` | no |
| <a name="input_bucket_owner"></a> [bucket\_owner](#input\_bucket\_owner) | ID of user/service account, which will have full access to the created bucket. Put there your user's ID, so you can manage bucket from console | `string` | `null` | no |
| <a name="input_cloud_id"></a> [cloud\_id](#input\_cloud\_id) | https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id | `string` | n/a | yes |
| <a name="input_default_zone"></a> [default\_zone](#input\_default\_zone) | https://cloud.yandex.ru/docs/overview/concepts/geo-scope | `string` | `"ru-central1-a"` | no |
| <a name="input_folder_id"></a> [folder\_id](#input\_folder\_id) | https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id | `string` | n/a | yes |
| <a name="input_is_aws_cli_installed"></a> [is\_aws\_cli\_installed](#input\_is\_aws\_cli\_installed) | If AWS CLI is installed Lock table will be installed by the script, if not you will need set it up yourelf | `bool` | n/a | yes |
| <a name="input_path_to_tfstate"></a> [path\_to\_tfstate](#input\_path\_to\_tfstate) | Path to terraform.tfstate file within the S3 bucket. | `string` | `"terraform.tfstate"` | no |
| <a name="input_s3-name-suffix"></a> [s3-name-suffix](#input\_s3-name-suffix) | Add suffix to 's3-terraform-backend-netology-', so that name is unique | `string` | n/a | yes |
| <a name="input_s3_sa_user_name"></a> [s3\_sa\_user\_name](#input\_s3\_sa\_user\_name) | Name of the service account, which will upload data to the bucket | `string` | `"s3-terraform-sa-user"` | no |
| <a name="input_versioning"></a> [versioning](#input\_versioning) | S3 bucket storage versioning and it lifycecle. Retention period in days | <pre>object({<br>    is_enabled    = bool<br>    has_lifecycle = bool<br>    retention     = optional(number, 90)<br>  })</pre> | <pre>{<br>  "has_lifecycle": true,<br>  "is_enabled": true<br>}</pre> | no |
| <a name="input_ydb_db_name"></a> [ydb\_db\_name](#input\_ydb\_db\_name) | Name of the YDB database, where state lock table should be created. | `string` | `"state-lock-db"` | no |
| <a name="input_ydb_table_name"></a> [ydb\_table\_name](#input\_ydb\_table\_name) | Dependend on AWS CLI. Name of the YDB table, where lock will be stored. If no AWS CLI is installed you should create it yourself. | `string` | `"aws-dynamodb-lock-table"` | no |

## Outputs

No outputs.
