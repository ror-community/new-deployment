variable "access_key" {}
variable "secret_key" {}
variable "region" {
    default = "eu-west-1"
}

variable "private_security_group" {}
variable "private_subnet" {}

variable "ttl" {
  default = "300"
}
