resource "aws_ecs_service" "api-dev-community" {
  name = "api-dev-community"
  cluster = data.aws_ecs_cluster.default.id
  launch_type = "FARGATE"
  task_definition = aws_ecs_task_definition.api-dev.arn
  desired_count = 1

  network_configuration {
    security_groups = [var.private_security_group_id]
    subnets         = var.private_subnet_ids
  }

  service_registries {
    registry_arn = aws_service_discovery_service.api-dev.arn
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.api-dev-community.id
    container_name   = "api-dev-community"
    container_port   = "80"
  }

  depends_on = [
    data.aws_lb_listener.alb
  ]
}

resource "aws_lb_target_group" "api-dev-community" {
  name     = "api-dev-community"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"

  health_check {
    path = "/heartbeat"
  }

  depends_on = [
    data.aws_lb_listener.alb
  ]
}

resource "aws_lb_listener_rule" "redirect-api-dev" {
  listener_arn = data.aws_lb_listener.alb-http.arn

  action {
    type = "redirect"

    redirect {
      host        = "api.dev.ror.community"
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_302"
    }
  }

  condition {
    field  = "host-header"
    values = ["api.dev.ror.community"]
  }
}

resource "aws_lb_listener_rule" "api-dev" {
  listener_arn = data.aws_lb_listener.alb.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api-dev-community.arn
  }

  condition {
    field  = "host-header"
    values = [aws_route53_record.api-dev.name]
  }
}

resource "aws_cloudwatch_log_group" "api-dev" {
  name = "/ecs/api-dev-community"
}

resource "aws_ecs_task_definition" "api-dev" {
  family = "api-dev"
  execution_role_arn = data.aws_iam_role.ecs_tasks_execution_role.arn
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "512"
  memory = "1024"

  container_definitions =  data.template_file.api-dev_task.rendered
}

resource "aws_route53_record" "api-dev" {
    zone_id = data.aws_route53_zone.public.zone_id
    name = "api.dev.ror.org"
    type = "CNAME"
    ttl = var.ttl
    records = [data.aws_lb.alb.dns_name]
}

resource "aws_route53_record" "split-api-dev" {
  zone_id = data.aws_route53_zone.internal.zone_id
  name = "api.dev.ror.org"
  type = "CNAME"
  ttl = var.ttl
  records = [data.aws_lb.alb.dns_name]
}

resource "aws_service_discovery_service" "api-dev" {
  name = "api.dev"

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
