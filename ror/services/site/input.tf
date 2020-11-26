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

data "aws_route53_zone" "public" {
  name         = "ror.org"
}

data "aws_route53_zone" "internal" {
  name         = "ror.org"
  private_zone = true
}
