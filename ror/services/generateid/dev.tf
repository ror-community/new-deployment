resource "aws_ecs_service" "generateid-dev" {
  name = "generateid-dev"
  cluster = data.aws_ecs_cluster.default.id
  launch_type = "FARGATE"
  task_definition = aws_ecs_task_definition.generateid-dev.arn
  desired_count = 1

  health_check_grace_period_seconds = 600

  network_configuration {
    security_groups = [var.private_security_group_id]
    subnets         = var.private_subnet_ids
  }

  service_registries {
    registry_arn = aws_service_discovery_service.generateid-dev.arn
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.generateid-dev.id
    container_name   = "generateid"
    container_port   = "80"
  }

  depends_on = [
    data.aws_lb_listener.alb-dev
  ]
}

resource "aws_lb_target_group" "generateid-dev" {
  name     = "generateid-dev"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"

  health_check {
    path = "/heartbeat"
  }
}

resource "aws_lb_listener_rule" "generateid-dev" {
  listener_arn = data.aws_lb_listener.alb-dev.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.generateid-dev.arn
  }

  condition {
    field  = "host-header"
    values = [aws_route53_record.generateid-dev.name]
  }
}

resource "aws_cloudwatch_log_group" "generateid-dev" {
  name = "/ecs/generateid-dev"
}

resource "aws_ecs_task_definition" "generateid-dev" {
  family = "generateid-dev"
  execution_role_arn = data.aws_iam_role.ecs_tasks_execution_role.arn
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "256"
  memory = "512"

  container_definitions = templatefile("generateid.json", {
        token = var.token_dev
        route_user = var.route_user
        ror_api_url = var.ror_api_url_dev
        allowed_origins = var.allowed_origins_dev
        version = "dev"
  })
}

resource "aws_route53_record" "generateid-dev" {
    zone_id = data.aws_route53_zone.public.zone_id
    name = "generateid.dev.ror.org"
    type = "CNAME"
    ttl = var.ttl
    records = [data.aws_lb.alb-dev.dns_name]
}

resource "aws_route53_record" "split-generateid-dev" {
  zone_id = data.aws_route53_zone.internal.zone_id
  name = "generateid.dev.ror.org"
  type = "CNAME"
  ttl = var.ttl
  records = [data.aws_lb.alb-dev.dns_name]
}

resource "aws_service_discovery_service" "generateid-dev" {
  name = "generateid.dev"

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
