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

data "aws_lb" "alb" {
  name = "lb"
}

data "aws_lb_listener" "alb" {
  load_balancer_arn = data.aws_lb.alb.arn
  port              = 443
}

data "template_file" "api_task" {
  template = file("api.json")

  vars = {
    elastic7_host         = var.elastic7_host
    elastic7_port         = var.elastic7_port
    access_key            = var.access_key
    secret_key            = var.secret_key
    region                = var.region
    public_key            = var.public_key
    sentry_dsn            = var.sentry_dsn
    django_secret_key     = var.django_secret_key
    token                 = var.token
    route_user            = var.route_user
    data_store            = var.data_store
    public_store          = var.public_store
    github_token          = var.github_token
    version               = var.ror-api_tags["version"]
    launch_darkly_key     = var.launch_darkly_key
    db_host               = var.db_host
    db_password           = var.db_password
    db_port               = var.db_port
    db_name               = var.db_name
    db_user               = var.db_username
    single_search_default = var.single_search_default
  }
}

data "aws_wafv2_web_acl" "prod-v2" {
  name  = "waf-prod-v2"
  scope = "REGIONAL"
}
