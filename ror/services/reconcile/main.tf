resource "aws_ecs_service" "reconcile" {
  name            = "reconcile"
  cluster         = data.aws_ecs_cluster.default.id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.reconcile.arn
  desired_count   = 2

  network_configuration {
    security_groups = [var.private_security_group_id]
    subnets         = var.private_subnet_ids
  }

  service_registries {
    registry_arn = aws_service_discovery_service.reconcile.arn
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.reconcile.id
    container_name   = "reconcile"
    container_port   = "80"
  }

  depends_on = [
   data.aws_lb_listener.alb
  ]
}

resource "aws_lb_target_group" "reconcile" {
  name        = "reconcile"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path = "/heartbeat"
  }
}

resource "aws_lb_listener_rule" "reconcile" {
  listener_arn = data.aws_lb_listener.alb.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.reconcile.arn
  }

  condition {
    field  = "host-header"
    values = [aws_route53_record.reconcile.name]
  }
}

resource "aws_cloudwatch_log_group" "reconcile" {
  name = "/ecs/reconcile"
}

resource "aws_ecs_task_definition" "reconcile" {
  family                   = "reconcile"
  execution_role_arn       = data.aws_iam_role.ecs_tasks_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"

  container_definitions = data.template_file.reconcile_task.rendered
}

resource "aws_route53_record" "reconcile" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = "reconcile.ror.community"
  type    = "CNAME"
  ttl     = var.ttl
  records = [data.aws_lb.alb.dns_name]
}

resource "aws_route53_record" "split-reconcile" {
  zone_id = data.aws_route53_zone.internal.zone_id
  name    = "reconcile.ror.community"
  type    = "CNAME"
  ttl     = var.ttl
  records = [data.aws_lb.alb.dns_name]
}

resource "aws_service_discovery_service" "reconcile" {
  name = "reconcile"

  health_check_custom_config {
    failure_threshold = 3
  }

  dns_config {
    namespace_id = var.aws_service_discovery_private_dns_namespace_id

    dns_records {
      ttl  = 300
      type = "A"
    }
  }
}
