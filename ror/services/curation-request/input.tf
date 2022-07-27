provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
  version    = "~> 2.7"
}

provider "aws" {
  # us-east-1 region
  access_key = var.access_key
  secret_key = var.secret_key
  region = "us-east-1"
  alias = "use1"
}

data "aws_route53_zone" "ror" {
  name         = "ror.org"
}

data "aws_acm_certificate" "cloudfront" {
  provider = aws.use1
  domain = "ror.org"
  statuses = ["ISSUED"]
}

data "aws_iam_role" "iam_for_lambda" {
   name = "iam_for_lambda"
}