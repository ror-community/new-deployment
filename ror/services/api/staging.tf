resource "aws_ecs_service" "api-staging" {
  name = "api-staging"
  cluster = data.aws_ecs_cluster.default.id
  launch_type = "FARGATE"
  task_definition = aws_ecs_task_definition.api-staging.arn
  desired_count = 1

  # give container time to start up
  health_check_grace_period_seconds = 600

  network_configuration {
    security_groups = [var.private_security_group_id]
    subnets         = var.private_subnet_ids
  }

  service_registries {
    registry_arn = aws_service_discovery_service.api-staging.arn
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.api-staging.id
    container_name   = "api-staging"
    container_port   = "80"
  }

  depends_on = [
    data.aws_lb_listener.alb-staging
  ]
}

resource "aws_lb_target_group" "api-staging" {
  name     = "api-staging"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"

  health_check {
    path = "/heartbeat"
  }

  depends_on = [
    data.aws_lb_listener.alb-staging
  ]
}

resource "aws_lb_listener_rule" "redirect-api-staging" {
  listener_arn = data.aws_lb_listener.alb-http.arn

  action {
    type = "redirect"

    redirect {
      host        = "api.staging.ror.org"
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_302"
    }
  }

  condition {
    field  = "host-header"
    values = ["api.staging.ror.org"]
  }
}

resource "aws_lb_listener_rule" "api-staging" {
  listener_arn = data.aws_lb_listener.alb-staging.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api-staging.arn
  }

  condition {
    field  = "host-header"
    values = [aws_route53_record.api-staging.name]
  }
}

resource "aws_cloudwatch_log_group" "api-staging" {
  name = "/ecs/api-staging"
}

resource "aws_ecs_task_definition" "api-staging" {
  family = "api-staging"
  execution_role_arn = data.aws_iam_role.ecs_tasks_execution_role.arn
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "1024"
  memory = "4096"

  container_definitions =  data.template_file.api-staging_task.rendered
}

resource "aws_route53_record" "api-staging" {
    zone_id = data.aws_route53_zone.public.zone_id
    name = "api.staging.ror.org"
    type = "CNAME"
    ttl = var.ttl
    records = [data.aws_lb.alb-staging.dns_name]
}

resource "aws_route53_record" "split-api-staging" {
  zone_id = data.aws_route53_zone.internal.zone_id
  name = "api.staging.ror.org"
  type = "CNAME"
  ttl = var.ttl
  records = [data.aws_lb.alb-staging.dns_name]
}

resource "aws_service_discovery_service" "api-staging" {
  name = "api.staging"

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

resource "aws_s3_bucket" "data-staging" {
  bucket = "data.staging.ror.org"
  acl    = "private"
  tags = {
      Name = "data-staging"
  }
}

resource "aws_s3_bucket" "public-staging" {
  bucket = "public.staging.ror.org"
  tags = {
      Name = "public-staging"
  }
}

resource "aws_s3_bucket_public_access_block" "staging-block-public-access" {
  bucket = aws_s3_bucket.public-staging.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "public-staging-bucket-policy" {
  bucket = aws_s3_bucket.public-staging.bucket
  policy = templatefile("s3_public.json", {
    bucket_name = "public.staging.ror.org"
  })
}


# =============================================================================
# API GATEWAY STAGING RESOURCES
# =============================================================================

# CloudWatch Log Group for API Gateway Access Logs - Staging
resource "aws_cloudwatch_log_group" "api_gateway_access_logs_staging" {
  name              = "/aws/apigateway/ror-api-staging"
  retention_in_days = 30
  
  tags = {
    environment = "ror-staging"
    purpose = "api-gateway-cache-analytics"
  }
}

# Resource policy to allow API Gateway to write to the staging log group
resource "aws_cloudwatch_log_resource_policy" "api_gateway_logs_staging" {
  policy_name = "api-gateway-logs-policy-staging"
  
  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "${aws_cloudwatch_log_group.api_gateway_access_logs_staging.arn}:*"
      }
    ]
  })
}

# API Gateway Deployment - Staging
resource "aws_api_gateway_deployment" "api_gateway_staging" {
  depends_on = [
    # v1 endpoints
    aws_api_gateway_integration.v1_organizations_get_staging,
    aws_api_gateway_method_response.v1_organizations_get_staging,
    aws_api_gateway_integration_response.v1_organizations_get_staging,
    aws_api_gateway_integration.v1_organizations_id_get_staging,
    aws_api_gateway_method_response.v1_organizations_id_get_staging,
    aws_api_gateway_integration_response.v1_organizations_id_get_staging,
    aws_api_gateway_integration.v1_heartbeat_get_staging,
    aws_api_gateway_method_response.v1_heartbeat_get_staging,
    aws_api_gateway_integration_response.v1_heartbeat_get_staging,
    
    # v2 endpoints
    aws_api_gateway_integration.v2_organizations_get_staging,
    aws_api_gateway_method_response.v2_organizations_get_staging,
    aws_api_gateway_integration_response.v2_organizations_get_staging,
    aws_api_gateway_integration.v2_organizations_id_get_staging,
    aws_api_gateway_method_response.v2_organizations_id_get_staging,
    aws_api_gateway_integration_response.v2_organizations_id_get_staging,
    aws_api_gateway_integration.v2_heartbeat_get_staging,
    aws_api_gateway_method_response.v2_heartbeat_get_staging,
    aws_api_gateway_integration_response.v2_heartbeat_get_staging,
    
    # No version endpoints
    aws_api_gateway_integration.organizations_get_staging,
    aws_api_gateway_method_response.organizations_get_staging,
    aws_api_gateway_integration_response.organizations_get_staging,
    aws_api_gateway_integration.organizations_id_get_staging,
    aws_api_gateway_method_response.organizations_id_get_staging,
    aws_api_gateway_integration_response.organizations_id_get_staging,
    
    # Root path
    aws_api_gateway_integration.root_get_staging,
    aws_api_gateway_method_response.root_get_staging,
    aws_api_gateway_integration_response.root_get_staging,
    
    # Catch-all proxy
    aws_api_gateway_integration.proxy_staging,
    aws_api_gateway_method_response.proxy_staging,
    aws_api_gateway_integration_response.proxy_staging
  ]

  rest_api_id = aws_api_gateway_rest_api.api_gateway_staging.id
  
  variables = {
    deployed_at = timestamp()
    force_update = "true"
  }
  
  lifecycle {
    create_before_destroy = true
  }
} 