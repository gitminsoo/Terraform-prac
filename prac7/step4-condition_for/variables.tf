variable "environment" {
  type    = string
  default = "dev"

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "dev 또는 prod 만 허용됩니다."
  }
}

variable "enable_nat_gateway" {
  type    = bool
  default = false
}
