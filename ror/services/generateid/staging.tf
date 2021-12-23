resource "aws_ecs_service" "generateid-staging" {
  name = "generateid-staging"
  cluster = data.aws_ecs_cluster.default.id
  launch_type = "FARGATE"
  task_definition = aws_ecs_task_definition.generateid-staging.arn
  desired_count = 1

  health_check_grace_period_seconds = 600

  network_configuration {
    security_groups = [var.private_security_group_id]
    subnets         = var.private_subnet_ids
  }

  service_registries {
    registry_arn = aws_service_discovery_service.generateid-staging.arn
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.generateid-staging.id
    container_name   = "generateid-staging"
    container_port   = "80"
  }

  depends_on = [
    data.aws_lb_listener.alb-staging
  ]
}

resource "aws_lb_target_group" "generateid-staging" {
  name     = "generateid-staging"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"

  health_check {
    path = "/heartbeat"
  }
}

resource "aws_lb_listener_rule" "generateid-staging" {
  listener_arn = data.aws_lb_listener.alb-staging.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.generateid-staging.arn
  }

  condition {
    field  = "host-header"
    values = [aws_route53_record.generateid-staging.name]
  }
}

resource "aws_cloudwatch_log_group" "generateid-staging" {
  name = "/ecs/generateid-staging"
}

resource "aws_ecs_task_definition" "generateid-staging" {
  family = "generateid-staging"
  execution_role_arn = data.aws_iam_role.ecs_tasks_execution_role.arn
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "256"
  memory = "512"

  container_definitions = templatefile("generateid.json", {
        token = var.token_stage
        route_user = var.route_user
        ror_api_url = var.ror_api_url_stage
        allowed_origins = var.allowed_origins_stage
        version = "latest"
  })
}

resource "aws_route53_record" "generateid-staging" {
    zone_id = data.aws_route53_zone.public.zone_id
    name = "generateid.staging.ror.org"
    type = "CNAME"
    ttl = var.ttl
    records = [data.aws_lb.alb-staging.dns_name]
}

resource "aws_route53_record" "split-generateid-staging" {
  zone_id = data.aws_route53_zone.internal.zone_id
  name = "generateid.staging.ror.org"
  type = "CNAME"
  ttl = var.ttl
  records = [data.aws_lb.alb-staging.dns_name]
}

resource "aws_service_discovery_service" "generateid-staging" {
  name = "generateid.staging"

  health_check_custom_config {
    failure_threshold = 3
  }

  dns_config {
    namespace_id = var.namespace_id

    dns_records {
      ttl = 300
      type = "A"
    }
  }
}
