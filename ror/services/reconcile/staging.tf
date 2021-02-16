resource "aws_ecs_service" "reconcile-staging" {
  name            = "reconcile-staging"
  cluster         = data.aws_ecs_cluster.default.id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.reconcile-staging.arn
  desired_count   = 1

  network_configuration {
    security_groups = [var.private_security_group_id]
    subnets         = var.private_subnet_ids
  }

  // service_registries {
  //   registry_arn = aws_service_discovery_service.reconcile-dev-community.arn
  // }

  load_balancer {
    target_group_arn = aws_lb_target_group.reconcile-staging.id
    container_name   = "reconcile-staging"
    container_port   = "80"
  }

  depends_on = [
    data.aws_lb_listener.alb-staging
  ]
}

resource "aws_lb_target_group" "reconcile-staging" {
  name        = "reconcile-staging"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path = "/heartbeat"
  }
}

resource "aws_lb_listener_rule" "reconcile-staging" {
  listener_arn = data.aws_lb_listener.alb-staging.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.reconcile-staging.arn
  }

  condition {
    field  = "host-header"
    values = [aws_route53_record.reconcile-staging.name]
  }
}

resource "aws_cloudwatch_log_group" "reconcile-staging" {
  name = "/ecs/reconcile-staging"
}

resource "aws_ecs_task_definition" "reconcile-staging" {
  family                   = "reconcile-staging"
  execution_role_arn       = data.aws_iam_role.ecs_tasks_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"

  container_definitions = data.template_file.reconcile-staging_task.rendered
}

resource "aws_route53_record" "reconcile-staging" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = "reconcile.staging.ror.org"
  type    = "CNAME"
  ttl     = var.ttl
  records = [data.aws_lb.alb.dns_name]
}

resource "aws_route53_record" "split-reconcile-staging" {
  zone_id = data.aws_route53_zone.internal.zone_id
  name    = "reconcile.staging.ror.org"
  type    = "CNAME"
  ttl     = var.ttl
  records = [data.aws_lb.alb.dns_name]
}

// resource "aws_service_discovery_service" "reconcile-dev-community" {
//   name = "reconcile-dev-community"

//   health_check_custom_config {
//     failure_threshold = 3
//   }

//   dns_config {
//     namespace_id = var.aws_service_discovery_private_dns_namespace_id

//     dns_records {
//       ttl  = 300
//       type = "A"
//     }
//   }
// }
