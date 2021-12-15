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

data "aws_acm_certificate" "cloudfront-stage" {
  provider = "aws.use1"
  domain = "*.stage.datacite.org"
  statuses = ["ISSUED"]
  most_recent = true
}
