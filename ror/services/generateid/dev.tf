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
    container_name   = "generateid-dev"
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

  depends_on = [
    data.aws_lb_listener.alb-dev
  ]
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

  container_definitions = templatefile("generateid-dev.json", {
        token = var.token_dev
        route_user = var.route_user
        ror_api_url = var.ror_api_url_dev
        allowed_origins = var.allowed_origins
        version = var.generateid-dev_tags["sha"]
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

resource "aws_service_discovery_private_dns_namespace" "internal" {
  name = "local"
  vpc = var.vpc_id
}

resource "aws_service_discovery_service" "generateid-dev" {
  name = "generateid.dev"

  health_check_custom_config {
    failure_threshold = 3
  }

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.internal.id

    dns_records {
      ttl = 300
      type = "A"
    }
  }
}
