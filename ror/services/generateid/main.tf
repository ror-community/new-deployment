resource "aws_ecs_service" "generateid" {
  name = "generateid"
  cluster = data.aws_ecs_cluster.default.id
  launch_type = "FARGATE"
  task_definition = aws_ecs_task_definition.generateid.arn
  desired_count = 1

  health_check_grace_period_seconds = 600

  network_configuration {
    security_groups = [var.private_security_group_id]
    subnets         = var.private_subnet_ids
  }

  service_registries {
    registry_arn = aws_service_discovery_service.generateid.arn
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.generateid.id
    container_name   = "generateid"
    container_port   = "80"
  }

  depends_on = [
    data.aws_lb_listener.alb
  ]
}

resource "aws_lb_target_group" "generateid" {
  name     = "generateid"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"

  health_check {
    path = "/heartbeat"
  }
}

resource "aws_lb_listener_rule" "generateid" {
  listener_arn = data.aws_lb_listener.alb.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.generateid.arn
  }

  condition {
    field  = "host-header"
    values = [aws_route53_record.generateid.name]
  }
}

resource "aws_cloudwatch_log_group" "generateid" {
  name = "/ecs/generateid"
}

resource "aws_ecs_task_definition" "generateid" {
  family = "generateid"
  execution_role_arn = data.aws_iam_role.ecs_tasks_execution_role.arn
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "256"
  memory = "512"

  container_definitions = templatefile("generateid.json", {
        token = var.token
        route_user = var.route_user
        ror_api_url = var.ror_api_url
        allowed_origins = var.allowed_origins
        version = var.generateid_tags["version"]
  })
}

resource "aws_route53_record" "generateid" {
    zone_id = data.aws_route53_zone.public.zone_id
    name = "generateid.ror.org"
    type = "CNAME"
    ttl = var.ttl
    records = [data.aws_lb.alb.dns_name]
}

resource "aws_route53_record" "split-generateid" {
  zone_id = data.aws_route53_zone.internal.zone_id
  name = "generateid.ror.org"
  type = "CNAME"
  ttl = var.ttl
  records = [data.aws_lb.alb.dns_name]
}

resource "aws_service_discovery_service" "generateid" {
  name = "generateid"

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
