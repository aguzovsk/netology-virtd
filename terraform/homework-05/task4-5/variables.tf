variable "ip_address" {
  type        = string
  description = "IP address"

  # default = "192.168.256.12"
  # default = "1920.1680.0.1"
  default = "192.168.0.1"

  validation {
    condition     = can(cidrnetmask("${var.ip_address}/32"))
    error_message = "This is not a valid IP address"
  }
}

variable "ip_addresses_list" {
  type = list(string)

  # default = ["192.168.0.1", "1920.1680.0.1"]
  default = ["192.168.0.1", "192.168.0.1"]

  validation {
    condition = alltrue([
      for address in var.ip_addresses_list : can(cidrnetmask("${address}/32"))
    ])
    error_message = "Some of provided IPs are not valid"
  }
}

variable "lowercase_words" {
  type = string

  # default = "Should be lowercase string"
  # default = "Shouldbelowercasestring"
  default = "should be lowercase string"

  description = "Should be lowercase string"

  validation {
    condition     = !can(regex("[A-Z]", var.lowercase_words))
    error_message = "Given string is not lowercase"
  }
}

variable "two_xor_booleans" {
  type = object({
    Dunkan = optional(bool)
    Connor = optional(bool)
  })

  # default = {
  #   Dunkan = true
  #   Connor = true
  # }
  # default = {
  #   Dunkan = false
  #   Connor = false
  # }
  # default = {
  #   Dunkan = true
  #   Connor = false
  # }
  # default = {
  #   Dunkan = false
  #   Connor = true
  # }

  # default = {
  #   Dunkan = true
  # }
  # default = {
  #   Dunkan = false
  # }
  # default = {
  #   Connor = true
  # }
  # default = {
  #   Connor = false
  # }

  default = {}

  description = "Both values are not true and false at the same time"

  validation {
    condition     = !((var.two_xor_booleans.Dunkan == var.two_xor_booleans.Connor) && (var.two_xor_booleans.Dunkan != null))
    error_message = "Negation + AND: Provided values don't are both true or false at the same time"
  }

  validation {
    # Same as above
    condition     = var.two_xor_booleans.Dunkan != var.two_xor_booleans.Connor || var.two_xor_booleans.Dunkan == null
    error_message = "ALTERNATIVE: Provided values don't are both true or false at the same time"
  }
}
