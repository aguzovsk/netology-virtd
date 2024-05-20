variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "s3-name-suffix" {
  type        = string
  description = "Add suffix to 'netology-devops-', so that name is unique"
}

variable "yc-user-id" {
  type        = string
  description = "Provide your YC user account name, for which s3 bucket will be created"
}
