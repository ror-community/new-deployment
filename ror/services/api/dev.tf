resource "aws_ecs_service" "api-dev" {
  name = "api-dev"
  cluster = data.aws_ecs_cluster.default.id
  launch_type = "FARGATE"
  task_definition = aws_ecs_task_definition.api-dev.arn
  desired_count = 2

  # give container time to start up
  health_check_grace_period_seconds = 600

  network_configuration {
    security_groups = [var.private_security_group_id]
    subnets         = var.private_subnet_ids
  }

  service_registries {
    registry_arn = aws_service_discovery_service.api-dev.arn
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.api-dev.id
    container_name   = "api-dev"
    container_port   = "80"
  }

  tags = {environment = "ror-dev"}

  depends_on = [
    data.aws_lb_listener.alb-dev
  ]
}

resource "aws_appautoscaling_target" "api-dev-autoscale-target" {
  max_capacity = 4
  min_capacity = 2
  resource_id = "service/default/api-dev"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace = "ecs"
}

resource "aws_appautoscaling_policy" "api-dev-autoscale-policy" {
  name = "api-dev-cpu"
  policy_type = "TargetTrackingScaling"
  resource_id = aws_appautoscaling_target.api-dev-autoscale-target.resource_id
  scalable_dimension = aws_appautoscaling_target.api-dev-autoscale-target.scalable_dimension
  service_namespace = aws_appautoscaling_target.api-dev-autoscale-target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = 80
  }
}

resource "aws_lb_target_group" "api-dev" {
  name     = "api-dev"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"

  depends_on = [
    data.aws_lb_listener.alb-dev
  ]
}

resource "aws_lb_listener_rule" "redirect-api-dev" {
  listener_arn = data.aws_lb_listener.alb-http.arn

  action {
    type = "redirect"

    redirect {
      host        = "api.dev.ror.org"
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_302"
    }
  }

  condition {
    field  = "host-header"
    values = ["api.dev.ror.org"]
  }
}

resource "aws_cloudwatch_log_group" "api-dev" {
  name = "/ecs/api-dev"
}

resource "aws_ecs_task_definition" "api-dev" {
  family = "api-dev"
  execution_role_arn = data.aws_iam_role.ecs_tasks_execution_role.arn
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "1024"
  memory = "4096"

  container_definitions =  data.template_file.api-dev_task.rendered
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

resource "aws_s3_bucket" "data-dev" {
  bucket = "data.dev.ror.org"
  acl    = "private"
  tags = {
      Name = "data-dev"
      environment = "ror-dev"
  }
}

resource "aws_s3_bucket" "public-dev" {
  bucket = "public.dev.ror.org"
  tags = {
      Name = "public-dev"
  }
}

resource "aws_s3_bucket_public_access_block" "dev-block-public-access" {
  bucket = aws_s3_bucket.public-dev.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "public-dev-bucket-policy" {
  bucket = aws_s3_bucket.public-dev.bucket
  policy = templatefile("s3_public.json", {
    bucket_name = "public.dev.ror.org"
  })
}

resource "aws_apigatewayv2_vpc_link" "api-dev-gateway-vpc-link" {
  name               = "api-dev-vpc-link"
  security_group_ids = [var.private_security_group_id]
  subnet_ids         = var.private_subnet_ids

  tags = {
    environment = "ror-dev"
  }
}

resource "aws_apigatewayv2_api" "api-dev-gateway" {
  name          = "api-dev-gateway"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "api-dev-gateway-stage" {
  api_id = aws_apigatewayv2_api.api-dev-gateway.id
  name   = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_route" "api-dev-gateway-route" {
  api_id    = aws_apigatewayv2_api.api-dev-gateway.id
  route_key = "ANY /{proxy+}"

  target = "integrations/${aws_apigatewayv2_integration.api-dev-gateway-integration.id}"
}

resource "aws_apigatewayv2_integration" "api-dev-gateway-integration" {
  api_id           = aws_apigatewayv2_api.api-dev-gateway.id
  description      = "DEV API gateway integration with ECS"
  integration_type = "HTTP_PROXY"
  integration_uri  = data.aws_lb_listener.alb-dev.arn

  integration_method = "ANY"
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.api-dev-gateway-vpc-link.id
}

resource "aws_apigatewayv2_domain_name" "api-dev-gateway-domain" {
  domain_name = "api.dev.ror.org"

  domain_name_configuration {
    certificate_arn = data.aws_acm_certificate.ror.arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_apigatewayv2_api_mapping" "api-dev-gateway-mapping" {
  api_id      = aws_apigatewayv2_api.api-dev-gateway.id
  domain_name = aws_apigatewayv2_domain_name.api-dev-gateway-domain.id
  stage       = aws_apigatewayv2_stage.$default.id
}