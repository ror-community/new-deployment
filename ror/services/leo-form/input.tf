provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
  version    = "~> 2.7"
}

data "aws_route53_zone" "public" {
  name         = "ror.org"
}

data "aws_acm_certificate" "ror" {
  domain = "ror.org"
  statuses = ["ISSUED"]
  most_recent = true
}