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

data "aws_iam_policy_document" "ecs_tasks_execution_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_lb" "alb" {
  name = "lb"
}

data "aws_lb" "alb-staging" {
  name = "lb-staging"
}

// data "aws_lb" "alb-dev" {
//   name = "lb-dev"
// }

data "aws_lb" "alb-community" {
  name = "lb-community"
}

data "aws_lb_target_group" "api-community" {
  name = "api-community"
}

data "aws_lb_target_group" "api-staging" {
  name = "api-staging"
}

data "aws_lb_target_group" "api-dev" {
  name = "api-dev"
}

data "aws_acm_certificate" "ror" {
  domain = "ror.org"
  statuses = ["ISSUED"]
  most_recent = true
}

data "aws_acm_certificate" "ror-staging" {
  domain = "*.staging.ror.org"
  statuses = ["ISSUED"]
  most_recent = true
}

// data "aws_acm_certificate" "ror-community" {
//   domain = "ror.community"
//   statuses = ["ISSUED"]
//   most_recent = true
// }

data "aws_acm_certificate" "cloudfront" {
  provider = aws.use1
  domain = "ror.org"
  statuses = ["ISSUED"]
}

data "aws_acm_certificate" "cloudfront-staging" {
  provider = aws.use1
  domain = "staging.ror.org"
  statuses = ["ISSUED"]
}

data "aws_s3_bucket" "logs" {
  bucket = "logfiles.ror.community"
}

data "aws_s3_bucket" "site" {
  bucket = "main.ror.community"
}

data "aws_s3_bucket" "site-dev" {
  bucket = "www.dev.ror.community"
}

data "aws_s3_bucket" "site-staging" {
  bucket = "www.staging.ror.community"
}

data "aws_s3_bucket" "search" {
  bucket = "search.ror.community"
}

data "aws_s3_bucket" "search-dev" {
  bucket = "search.dev.ror.community"
}

// data "aws_iam_role" "iam_for_lambda" {
//   name = "iam_for_lambda"
// }

data "aws_lambda_function" "index-page" {
  provider = aws.use1
  function_name = "index-page-community"
}

data "aws_route53_zone" "public" {
  name = "ror.org"
}

data "aws_route53_zone" "internal" {
  name = "ror.org"
  private_zone = true
}
