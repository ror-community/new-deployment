provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
  version    = "~> 2.7"
}

data "aws_route53_zone" "public" {
  name         = "ror.org"
}
data "aws_route53_zone" "internal" {
  name         = "ror.org"
  private_zone = true
}
data "aws_subnet" "public_subnet" {
  id = var.public_subnet_id
}
data "aws_subnet" "private_subnet" {
  id = var.private_subnet_id
}
data "aws_security_group" "private_security_group" {
  id = var.private_security_group_id
}
data "template_file" "bastion-user-data-cfg" {
  template = file("user_data.cfg")

  vars = {
    hostname     = var.hostname
    fqdn         = "${var.hostname}.ror.community"
  }
}

data "template_file" "bastion-2023-user-data-cfg" {
  template = file("user_data.cfg")

  vars = {
    hostname     = var.hostname_linux_2023
    fqdn         = "${var.hostname_linux_2023}.ror.community"
  }
}
