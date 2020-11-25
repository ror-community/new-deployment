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
  version    = "~> 2.7"
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
  name = "alb"
}

data "aws_lb" "alb-community" {
  name = "alb-community"
}

data "aws_lb_target_group" "api" {
  name = "api"
}

data "aws_acm_certificate" "ror" {
  domain = "ror.org"
  statuses = ["ISSUED"]
  most_recent = true
}

data "aws_acm_certificate" "ror-community" {
  domain = "ror.community"
  statuses = ["ISSUED"]
  most_recent = true
}

data "aws_acm_certificate" "cloudfront" {
  provider = aws.use1
  domain = "ror.community"
  statuses = ["ISSUED"]
}

data "aws_s3_bucket" "logs" {
  bucket = "logs.ror.community"
}

data "aws_s3_bucket" "site" {
  bucket = "main.ror.community"
}

data "aws_s3_bucket" "site-dev" {
  bucket = "dev.ror.community"
}

data "aws_s3_bucket" "site-staging" {
  bucket = "staging.ror.community"
}

data "aws_s3_bucket" "search" {
  bucket = "search.ror.community"
}

data "aws_s3_bucket" "search-dev" {
  bucket = "search.dev.ror.community"
}

data "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"
}

data "aws_lambda_function" "index-page" {
  provider = aws.use1
  function_name = "index-page"
}
