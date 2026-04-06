variable "env" {
  type    = string
  default = "staging"
}

variable "vpc_cidr" {
  type    = string
  default = "10.1.0.0/16" # dev(10.0)와 대역 분리
}

variable "instance_type" {
  type    = string
  default = "t3.small"
}

variable "min_size" {
  type    = number
  default = 2
}

variable "max_size" {
  type    = number
  default = 4
}

variable "desired_capacity" {
  type    = number
  default = 2
}
