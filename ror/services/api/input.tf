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
  name = "ror.org"
  private_zone = true
}

data "aws_acm_certificate" "ror" {
  domain = "ror.org"
  statuses = ["ISSUED"]
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

data "template_file" "api_task" {
  template = file("api.json")

  vars = {
    elastic7_host      = var.elastic7_host
    elastic7_port      = var.elastic7_port
    access_key         = var.access_key
    secret_key         = var.secret_key
    region             = var.region
    public_key         = var.public_key
    sentry_dsn         = var.sentry_dsn
    django_secret_key  = var.django_secret_key
    token              = var.token
    route_user         = var.route_user
    data_store         = var.data_store
    public_store       = var.public_store
    github_token       = var.github_token
    version            = var.ror-api_tags["version"]
    launch_darkly_key  = var.launch_darkly_key
    db_host            = var.db_host
    db_password        = var.db_password
    db_port            = var.db_port
    db_name            = var.db_name
    db_user            = var.db_username
  }
}

data "template_file" "api-dev_task" {
  template = file("api-dev.json")

  vars = {
    elastic7_host_dev   = var.elastic7_host_dev
    elastic7_port_dev   = var.elastic7_port_dev
    access_key         = var.access_key
    secret_key         = var.secret_key
    region             = var.region
    public_key         = var.public_key
    sentry_dsn         = var.sentry_dsn
    django_secret_key  = var.django_secret_key
    token              = var.token_dev
    route_user         = var.route_user
    data_store         = var.data_store_dev
    public_store       = var.public_store_dev
    github_token       = var.github_token
    version            = var.ror-api-dev_tags["sha"]
    launch_darkly_key  = var.launch_darkly_key_dev
    db_host            = var.db_host_dev
    db_password        = var.db_password_dev
    db_port            = var.db_port_dev
    db_name            = var.db_name
    db_user            = var.db_username_dev
  }
}

data "template_file" "api-staging_task" {
  template = file("api-staging.json")

  vars = {
    elastic7_host_staging   = var.elastic7_host_staging
    elastic7_port_staging   = var.elastic7_port_staging
    access_key         = var.access_key
    secret_key         = var.secret_key
    region             = var.region
    public_key         = var.public_key
    sentry_dsn         = var.sentry_dsn
    django_secret_key  = var.django_secret_key
    token              = var.token_staging
    route_user         = var.route_user
    data_store         = var.data_store_staging
    public_store       = var.public_store_staging
    github_token       = var.github_token
    version            = var.ror-api-staging_tags["sha"]
    launch_darkly_key  = var.launch_darkly_key_staging
    db_host            = var.db_host_staging
    db_password        = var.db_password_staging
    db_port            = var.db_port_staging
    db_name            = var.db_name
    db_user            = var.db_username_staging
  }
}

data "aws_s3_bucket" "search-ror-community" {
  bucket = "search.ror.community"
}

data "aws_s3_bucket" "main-ror-community" {
  bucket = "main.ror.community"
}

data "aws_wafv2_web_acl" "dev-v2" {
  name  = "waf-dev-v2"
  scope = "REGIONAL"
}
