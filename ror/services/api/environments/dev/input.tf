provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
  version    = "~> 2.7"
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

data "template_file" "api-dev_task" {
  template = file("api-dev.json")

  vars = {
    elastic7_host_dev         = var.elastic7_host_dev
    elastic7_port_dev         = var.elastic7_port_dev
    access_key               = var.access_key
    secret_key               = var.secret_key
    region                   = var.region
    public_key               = var.public_key
    sentry_dsn               = var.sentry_dsn
    django_secret_key        = var.django_secret_key
    token                    = var.token_dev
    route_user               = var.route_user
    data_store               = var.data_store_dev
    public_store             = var.public_store_dev
    github_token             = var.github_token
    version                  = var.ror-api-dev_tags["sha"]
    launch_darkly_key        = var.launch_darkly_key_dev
    db_host                  = var.db_host_dev
    db_password              = var.db_password_dev
    db_port                  = var.db_port_dev
    db_name                  = var.db_name
    db_user                  = var.db_username_dev
    single_search_default_dev = var.single_search_default_dev
  }
}

data "aws_wafv2_web_acl" "dev-v2" {
  name  = "waf-dev-v2"
  scope = "REGIONAL"
}
