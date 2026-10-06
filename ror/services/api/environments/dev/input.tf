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

data "aws_acm_certificate" "ror" {
  domain      = "ror.org"
  statuses    = ["ISSUED"]
  most_recent = true
}

data "aws_ecs_cluster" "default" {
  cluster_name = "default"
}

data "aws_iam_role" "ecs_tasks_execution_role" {
  name = "ecs-task-execution-role"
}

data "aws_lb" "alb-dev" {
  name = "lb-dev"
}

data "aws_lb_listener" "alb-dev" {
  load_balancer_arn = data.aws_lb.alb-dev.arn
  port              = 443
}

data "aws_lb_listener" "alb-http-dev" {
  load_balancer_arn = data.aws_lb.alb-dev.arn
  port              = 80
}

data "aws_wafv2_web_acl" "dev-v2" {
  name  = "waf-dev-v2"
  scope = "REGIONAL"
}
