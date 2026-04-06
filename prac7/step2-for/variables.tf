variable "subnets" {
  type = map(string)
  default = {
    "KMS-PUBLIC-Azone"      = "10.0.1.0/24"
    "KMS-PUBLIC-Czone"      = "10.0.2.0/24"
    "KMS-PRIVATE-WEB-Azone" = "10.0.11.0/24"
    "KMS-PRIVATE-WEB-Czone" = "10.0.12.0/24"
  }
}
