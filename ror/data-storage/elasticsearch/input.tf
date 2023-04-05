provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
  version = "~> 2.7"
}

data "aws_security_group" "private_security_group" {
  id = var.private_security_group
}

data "aws_subnet" "private_subnet" {
  ids = var.private_subnet
}

data "aws_route53_zone" "internal" {
  name         = "ror.org"
  private_zone = true
}
