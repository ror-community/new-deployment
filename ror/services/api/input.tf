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

data "template_file" "api_task" {
  template = file("api.json")

  vars = {
    elastic_host       = var.elastic_host
    elastic_port       = var.elastic_port
    access_key         = var.access_key
    secret_key         = var.secret_key
    region             = var.region
    public_key         = var.public_key
    sentry_dsn         = var.sentry_dsn
    django_secret_key  = var.django_secret_key
    version            = var.ror-api_tags["version"]
  }
}

data "template_file" "api-dev_task" {
  template = file("api-dev.json")

  vars = {
    elastic_host_dev   = var.elastic_host_dev
    elastic_port_dev   = var.elastic_port_dev
    access_key         = var.access_key
    secret_key         = var.secret_key
    region             = var.region
    public_key         = var.public_key
    sentry_dsn         = var.sentry_dsn
    django_secret_key  = var.django_secret_key
    version            = var.ror-api-dev_tags["sha"]
  }
}

data "template_file" "api-staging_task" {
  template = file("api-staging.json")

  vars = {
    elastic_host_staging = var.elastic_host_staging
    elastic_port_staging = var.elastic_port_staging
    access_key         = var.access_key
    secret_key         = var.secret_key
    region             = var.region
    public_key         = var.public_key
    sentry_dsn         = var.sentry_dsn
    django_secret_key  = var.django_secret_key
    version            = var.ror-api-staging_tags["sha"]
  }
}

data "aws_s3_bucket" "search-ror-community" {
  bucket = "search.ror.community"
}

data "aws_s3_bucket" "main-ror-community" {
  bucket = "main.ror.community"
}
