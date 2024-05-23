/*
  As of yandex terraform provider v0.119.0 it is not supported creation YDB Document tables, but only Row-based
  As of YC CLI v0.125.0 you can only create YDB database, but not table
  You can resort to AWS CLI to create YDB Document-based table, as described in documentation
  (https://yandex.cloud/en/docs/ydb/docapi/tools/aws-cli/create-table)
  This is done in terraform_data resource in local_exec provisioner (main.tf)
*/

// Create YDB lock Databese
resource "yandex_ydb_database_serverless" "ydb-lock-db" {
  name      = var.ydb_db_name
  folder_id = var.folder_id
}

//Access binding
resource "yandex_ydb_database_iam_binding" "editor" {
  database_id = yandex_ydb_database_serverless.ydb-lock-db.id
  role        = "ydb.editor"
  # ydb.admin role stated in manual
  # (https://yandex.cloud/en/docs/tutorials/infrastructure-management/terraform-state-lock#create-service-account)

  members = [
    "serviceAccount:${yandex_iam_service_account.s3_sa_user.id}",
  ]
}

# It creates only Row table, not Document table
# resource "yandex_ydb_table" "ydb-lock-table" {
#   path              = var.ydb_table_name
#   connection_string = yandex_ydb_database_serverless.ydb-lock-db.ydb_full_endpoint

#   column {
#     name = "LockID"
#     type = "String"
#   }

#   primary_key = ["LockID"]
# }


# Cannot mimic Document-based ydb-table (unsuccessful)
# resource "yandex_ydb_table" "ydb-table-document" {
#   path              = "table299Document"
#   connection_string = yandex_ydb_database_serverless.ydb-lock-db.ydb_full_endpoint

#   attributes = {
#     __document_api_version = "20200804"
#     dynamodbDataColumns    = jsonencode({})
#     dynamodbIndexes        = jsonencode({})
#   }

#   column {
#     name     = "LockID"
#     not_null = false
#     type     = "Utf8"
#   }

#   column {
#     name     = "__Hash"
#     not_null = false
#     type     = "Uint64"
#   }

#   column {
#     name     = "__RowData"
#     not_null = false
#     type     = "JsonDocument"
#   }

#   primary_key = ["__Hash", "LockID"]
#   partitioning_settings {
#     auto_partitioning_by_load              = true
#     auto_partitioning_by_size_enabled      = true
#     auto_partitioning_max_partitions_count = 0
#     auto_partitioning_min_partitions_count = 1
#     auto_partitioning_partition_size_mb    = 1024
#     uniform_partitions                     = 0
#   }
# }


# Imitating Document-based (2) ydb-table (unsuccessful)
# resource "yandex_ydb_table" "ydb-lock-table-v2" {
#   path              = "a-la-documnet"
#   connection_string = yandex_ydb_database_serverless.ydb-lock-db.ydb_full_endpoint

#   column {
#     name = "LockID"
#     type = "String"
#   }

#   # attributes = {
#   #   __document_api_version = "20200804"
#   #   dynamodbDataColumns    = jsonencode({})
#   #   dynamodbIndexes        = jsonencode({})
#   # }

#   # column {
#   #   name     = "__Hash"
#   #   not_null = false
#   #   type     = "Uint64"
#   # }
#   # column {
#   #   name     = "__RowData"
#   #   not_null = false
#   #   type     = "JsonDocument"
#   # }


#   partitioning_settings {
#     auto_partitioning_by_load              = true
#     auto_partitioning_by_size_enabled      = true
#     auto_partitioning_max_partitions_count = 0
#     auto_partitioning_min_partitions_count = 1
#     auto_partitioning_partition_size_mb    = 1024
#     uniform_partitions                     = 0
#   }

#   # primary_key = ["__Hash", "LockID"]
#   primary_key = ["LockID"]
# }
