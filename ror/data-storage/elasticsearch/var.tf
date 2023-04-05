variable "access_key" {}
variable "secret_key" {}
variable "region" {
    default = "eu-west-1"
}

variable "private_security_group" {}

variable "private_subnet" {}

variable "private_subnet_ids" {
  type = list(string)
}

variable "ttl" {
  default = "300"
}
