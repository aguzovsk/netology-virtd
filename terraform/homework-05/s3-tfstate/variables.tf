variable "s3-name-suffix" {
  type        = string
  description = "Add suffix to 'netology-devops-', so that name is unique"
}

variable "path_to_tfstate" {
  type    = string
  default = "terraform.tfstate"
}


variable "bucket_owner" {
  type        = string
  nullable    = true
  description = "ID of user/service account, which will have full access to the created bucket. Put there your user's ID, so you can manage bucket from console"
}

variable "bucket_admin" {
  type        = string
  nullable    = true
  description = "May be omitted. ID of service account, which will have full access to the bucket itself, but not its content"

  validation {
    condition     = var.bucket_admin == null || length(var.bucket_admin) == 0 || length(var.bucket_admin) > 19
    error_message = "Probably, you provided wrong service account ID, since its length is incorrect"
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

variable "s3_sa_user_name" {
  type        = string
  default     = "s3-terraform-sa-user"
  description = "Name of the service account, which will "
}

variable "aws_profile" {
  type        = string
  default     = "yandex-s3-tfstate"
  description = "AWS profile with given name will be created, or just simply credentials will be installed"
}

variable "is_aws_cli_installed" {
  type        = bool
  description = "If AWS CLI is installed Lock table will be installed by the script, if not you will need set it up yourelf"
}

variable "ydb_db_name" {
  type    = string
  default = "state-lock-db"
}

variable "ydb_table_name" {
  type    = string
  default = "state-lock-table"
}

