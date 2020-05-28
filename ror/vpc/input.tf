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

//data "template_file" "logs" {
  //template = file("s3_write_access.json")

  //vars = {
    //bucket_name = "logs.ror.org"
  //}
//}

//data "aws_lb" "alb" {
  //name = "alb"
//}

//data "aws_lb" "alb-community" {
  //name = "alb-community"
//}

//data "aws_lb_target_group" "api" {
  //name = "api"
//}

//data "aws_acm_certificate" "ror" {
  //domain = "ror.org"
  //statuses = ["ISSUED"]
  //most_recent = true
//}

//data "aws_acm_certificate" "ror-community" {
  //domain = "ror.community"
  //statuses = ["ISSUED"]
  //most_recent = true
//}

//data "aws_acm_certificate" "cloudfront" {
  //provider = aws.use1
  //domain = "ror.org"
  //statuses = ["ISSUED"]
//}

//data "aws_s3_bucket" "logs" {
  //bucket = "logs.ror.org"
//}

//data "aws_s3_bucket" "site" {
  //bucket = "ror.org"
//}

//data "aws_s3_bucket" "site-dev" {
  //bucket = "dev.ror.org"
//}

//data "aws_s3_bucket" "site-staging" {
  //bucket = "staging.ror.org"
//}

//data "aws_s3_bucket" "search" {
  //bucket = "search.ror.org"
//}

//data "aws_s3_bucket" "search-dev" {
  //bucket = "search.dev.ror.org"
//}

//data "aws_iam_role" "iam_for_lambda" {
  //name = "iam_for_lambda"
//}

//data "aws_lambda_function" "index-page" {
  //provider = aws.use1
  //function_name = "index-page"
//}
