variable "env_name" {
    type = string
}
variable "subnets" {
    type = list(map(string))
}