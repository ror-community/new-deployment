provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

data "aws_route53_zone" "public" {
  name = "ror.org"
}

data "aws_route53_zone" "internal" {
  name         = "ror.org"
  private_zone = true
}

data "aws_acm_certificate" "ror-staging" {
  domain      = "*.staging.ror.org"
  statuses    = ["ISSUED"]
  most_recent = true
}

data "aws_ecs_cluster" "default" {
  cluster_name = "default"
}

data "aws_iam_role" "ecs_tasks_execution_role" {
  name = "ecs-task-execution-role"
}

data "aws_lb" "alb-staging" {
  name = "lb-staging"
}

data "aws_lb_listener" "alb-staging" {
  load_balancer_arn = data.aws_lb.alb-staging.arn
  port              = 443
}

data "aws_lb_listener" "alb-http-staging" {
  load_balancer_arn = data.aws_lb.alb-staging.arn
  port              = 80
}

data "aws_wafv2_web_acl" "staging-v2" {
  name  = "waf-staging-v2"
  scope = "REGIONAL"
}
