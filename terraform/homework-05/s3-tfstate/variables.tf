variable "s3-name-suffix" {
  type        = string
  description = "Add suffix to 's3-terraform-backend-netology-', so that name is unique"

  validation {
    condition     = length(var.s3-name-suffix) > 0
    error_message = "s3-name-suffix cannot be empty"
  }
}

variable "path_to_tfstate" {
  type        = string
  default     = "terraform.tfstate"
  description = "Path to terraform.tfstate file within the S3 bucket."

  validation {
    condition     = length(var.path_to_tfstate) > 0
    error_message = "Path cannot be empty"
  }
}


variable "bucket_owner_id" {
  type        = string
  default     = null
  description = "ID of user/service account, which will have full access to the created bucket. Put there your user's ID, so you can manage bucket from console"

  validation {
    # This should be written that way. Without ternary operator (only with OR) there will be an error (v1.5.7). This is kind of Safeguard
    condition     = var.bucket_owner_id == null ? true : (length(var.bucket_owner_id) == 0 || length(var.bucket_owner_id) > 19)
    error_message = "Probably, you provided wrong service account ID, since its length is incorrect"
  }
}

variable "bucket_admin_id" {
  type        = string
  default     = null
  description = "May be omitted. ID of service account, which will have full access to the bucket itself, but not its content"

  validation {
    condition     = var.bucket_admin_id == null ? true : (length(var.bucket_admin_id) == 0 || length(var.bucket_admin_id) > 19)
    error_message = "Probably, you provided wrong service account ID, since its length is incorrect"
  }
}

variable "bucket_viewer_id" {
  type        = string
  default     = null
  description = "ID of service account, which will have only view access to the bucket (for terraform_remote_state)"

  validation {
    condition     = var.bucket_viewer_id == null ? true : (length(var.bucket_viewer_id) == 0 || length(var.bucket_viewer_id) > 19)
    error_message = "Probably, you provided wrong service account ID, since its length is incorrect"
  }
}

variable "bucket_user_id" {
  type        = string
  default     = null
  description = "ID of service account, which will have read write access to Yandex S3 also to the YDB for terraform state lock"

  validation {
    condition     = var.bucket_user_id == null ? true : ((length(var.bucket_user_id) == 0 || length(var.bucket_user_id) > 19))
    error_message = "Probably, you provided wrong service account ID, since its length is incorrect"
  }
}

variable "bucket_user_name" {
  type        = string
  default     = null
  description = "(ID has prevalence over name) Name of the service account, which will upload data to the bucket"

  validation {
    condition     = var.bucket_user_name == null ? true : length(var.bucket_user_name) > 1
    error_message = "Value can't be shorter than 2 characters"
  }
}

variable "bucket_admin_name" {
  type        = string
  default     = null
  description = "(ID has prevalence over name) Name of Service Account which has admin permissions over YC S3"

  validation {
    condition     = var.bucket_admin_name == null ? true : length(var.bucket_admin_name) > 1
    error_message = "Value can't be shorter than 2 characters"
  }
}

variable "bucket_viewer_name" {
  type        = string
  default     = null
  description = "(ID has prevalence over name) Name of Service Account for Yandex S3 bucket view only"

  validation {
    condition     = var.bucket_viewer_name == null ? true : length(var.bucket_viewer_name) > 1
    error_message = "Value can't be shorter than 2 characters"
  }
}

variable "versioning" {
  type = object({
    is_enabled    = bool
    has_lifecycle = bool
    retention     = optional(number, 90)
  })

  default = {
    is_enabled    = true
    has_lifecycle = true
  }

  description = "S3 bucket storage versioning and it lifycecle. Retention period in days"

  validation {
    condition     = var.versioning.is_enabled || !var.versioning.has_lifecycle
    error_message = "Retention lifecycle policy cannot be enbled while versioning is disabled. versioning = {is_enabled = false, has_lifecycle = false}"
  }
}

variable "aws_profile_user" {
  type        = string
  default     = "yandex-s3-tfstate"
  description = "AWS profile with given name will be created (with YC credentials, you can use it with Yandex cloud not AWS itself)"
}

variable "aws_profile_viewer" {
  type        = string
  default     = "yandex-s3-tfstate-viewer"
  description = "AWS profile with given name will be created (with YC credentials, you can use it with Yandex cloud not AWS itself)"
}

variable "is_aws_cli_installed" {
  type        = bool
  description = "If AWS CLI is installed Lock table will be installed by the script, if not, you will be needed set it up yourelf"
}

variable "ydb_db_name" {
  type        = string
  default     = "state-lock-db"
  description = "Name of the YDB database, where state lock table should be created."
}

variable "ydb_table_name" {
  type        = string
  default     = "aws-dynamodb-lock-table"
  description = "Dependend on AWS CLI. Name of the YDB table, where lock will be stored. If no AWS CLI is installed you should create it yourself."
}

