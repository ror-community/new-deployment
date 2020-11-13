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

data "template_file" "site" {
  template = file("s3_cloudfront.json")

  vars = {
    bucket_name = "ror.org"
  }
}

data "template_file" "site-dev" {
  template = file("s3_cloudfront.json")

  vars = {
    bucket_name = "dev.ror.org"
  }
}

data "template_file" "site-staging" {
  template = file("s3_cloudfront.json")

  vars = {
    bucket_name = "staging.ror.org"
  }
}

data "aws_route53_zone" "public" {
  name         = "ror.community"
}

data "aws_route53_zone" "internal" {
  name         = "ror.community"
  private_zone = true
}
