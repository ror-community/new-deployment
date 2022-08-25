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
  name = "ror.org"
}

data "aws_route53_zone" "internal" {
  name = "ror.org"
  private_zone = true
}

data "aws_ecs_cluster" "default" {
  cluster_name = "default"
}

data "aws_iam_role" "ecs_tasks_execution_role" {
  name = "ecs-task-execution-role"
}

data "aws_lb" "alb" {
  name = "lb"
}

data "aws_lb" "alb-dev" {
  name = "lb-dev"
}

data "aws_lb" "alb-staging" {
  name = "lb-staging"
}

data "aws_lb_listener" "alb" {
  load_balancer_arn = data.aws_lb.alb.arn
  port = 443
}

data "aws_lb_listener" "alb-http" {
  load_balancer_arn = data.aws_lb.alb.arn
  port = 80
}

data "aws_lb_listener" "alb-staging" {
  load_balancer_arn = data.aws_lb.alb-staging.arn
  port = 443
}

data "aws_lb_listener" "alb-dev" {
  load_balancer_arn = data.aws_lb.alb-dev.arn
  port = 443
}

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