variable "access_key" {}
variable "secret_key" {}
variable "region" {
    default = "eu-west-1"
}
variable "vpc_id" {}
variable "vpc_cidr" {}

variable "ttl" {
  default = "300"
}

variable "public_subnet_id" {}
variable "private_subnet_id" {}
variable "private_security_group_id" {}

variable "ami_linux_2023" {
  type = "map"
  description = "Amazon Linux 2023 AMI"

  default = {
    eu-west-1 = "ami-0dab0800aa38826f2"
  }
}

variable "hostname_linux_2023" {}
variable "key_name_linux_2023" {}

