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
  port              = 443
}

data "aws_lb_listener" "alb-dev" {
  load_balancer_arn = data.aws_lb.alb-dev.arn
  port              = 443
}

data "aws_lb_listener" "alb-staging" {
  load_balancer_arn = data.aws_lb.alb-staging.arn
  port              = 443
}

data "template_file" "reconcile_task" {
  template = file("reconcile.json")

  vars = {
    access_key  = var.access_key
    secret_key  = var.secret_key
    region      = var.region
    public_key  = var.public_key
    ror_api     = var.ror_api
    ror_recon   = var.ror_recon
    version     = var.ror-reconcile_tags["sha"]
  }
}

data "template_file" "reconcile-dev_task" {
  template = file("reconcile-dev.json")

  vars = {
    access_key  = var.access_key
    secret_key  = var.secret_key
    region      = var.region
    public_key  = var.public_key
    ror_api     = var.ror_api_dev
    ror_recon   = var.ror_recon_dev
    version     = var.ror-reconcile-dev_tags["sha"]
  }
}

data "template_file" "reconcile-staging_task" {
  template = file("reconcile-staging.json")

  vars = {
    access_key  = var.access_key
    secret_key  = var.secret_key
    region      = var.region
    public_key  = var.public_key
    ror_api     = var.ror_api_staging
    ror_recon   = var.ror_recon_staging
    version     = var.ror-reconcile-staging_tags["sha"]
  }
}
