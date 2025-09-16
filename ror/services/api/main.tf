resource "aws_ecs_service" "api-community" {
  name = "api-community"
  cluster = data.aws_ecs_cluster.default.id
  launch_type = "FARGATE"
  task_definition = aws_ecs_task_definition.api-community.arn
  desired_count = 2

  # give container time to start up
  health_check_grace_period_seconds = 600

  network_configuration {
    security_groups = [var.private_security_group_id]
    subnets         = var.private_subnet_ids
  }

  service_registries {
    registry_arn = aws_service_discovery_service.api.arn
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.api-community.id
    container_name   = "api-community"
    container_port   = "80"
  }

  depends_on = [
    data.aws_lb_listener.alb
  ]
}

resource "aws_appautoscaling_target" "api-prod-autoscale-target" {
  max_capacity = 4
  min_capacity = 2
  resource_id = "service/default/api-community"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace = "ecs"
}

resource "aws_appautoscaling_policy" "api-prod-autoscale-policy" {
  name = "api-prod-cpu"
  policy_type = "TargetTrackingScaling"
  resource_id = aws_appautoscaling_target.api-prod-autoscale-target.resource_id
  scalable_dimension = aws_appautoscaling_target.api-prod-autoscale-target.scalable_dimension
  service_namespace = aws_appautoscaling_target.api-prod-autoscale-target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 80
  }
}


resource "aws_lb_target_group" "api-community" {
  name     = "api-community"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"

  health_check {
    path = "/heartbeat"
    interval = 300
    timeout = 120
  }

  depends_on = [
    data.aws_lb_listener.alb
  ]
}

resource "aws_cloudwatch_log_group" "api" {
  name = "/ecs/api-community"
}

resource "aws_ecs_task_definition" "api-community" {
  family = "api-community"
  execution_role_arn = data.aws_iam_role.ecs_tasks_execution_role.arn
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "1024"
  memory = "4096"

  container_definitions =  data.template_file.api_task.rendered
}

resource "aws_route53_record" "api" {
    zone_id = data.aws_route53_zone.public.zone_id
    name = "api.ror.org"
    type = "CNAME"
    ttl = var.ttl
    records = [data.aws_lb.alb.dns_name]
}

resource "aws_route53_record" "split-api" {
  zone_id = data.aws_route53_zone.internal.zone_id
  name = "api.ror.org"
  type = "CNAME"
  ttl = var.ttl
  records = [data.aws_lb.alb.dns_name]
}



# Service Discovery Namepace
resource "aws_service_discovery_private_dns_namespace" "internal" {
  name = "local"
  vpc = var.vpc_id
}

resource "aws_service_discovery_service" "api" {
  name = "api"

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

 resource "aws_s3_bucket" "data-prod" {
  bucket = "data.ror.org"
  acl    = "private"
  tags = {
      Name = "data-prod"
  }
}

resource "aws_s3_bucket" "public-prod" {
  bucket = "public.ror.org"
  tags = {
      Name = "public-prod"
  }
}

resource "aws_s3_bucket_public_access_block" "prod-block-public-access" {
  bucket = aws_s3_bucket.public-prod.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "public-prod-bucket-policy" {
  bucket = aws_s3_bucket.public-prod.bucket
  policy = templatefile("s3_public.json", {
    bucket_name = "public.ror.org"
  })
}

# =============================================================================
# API GATEWAY PROD RESOURCES
# =============================================================================

# CloudWatch Log Group for API Gateway Access Logs - Production
resource "aws_cloudwatch_log_group" "api_gateway_access_logs_prod" {
  name              = "/aws/apigateway/ror-api-prod"
  retention_in_days = 30
  
  tags = {
    environment = "ror-prod"
    purpose = "api-gateway-access-logs"
  }
}

# CloudWatch Log Resource Policy for API Gateway - Production
resource "aws_cloudwatch_log_resource_policy" "api_gateway_logs_prod" {
  policy_name = "api-gateway-logs-policy-prod"
  
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
        Resource = "${aws_cloudwatch_log_group.api_gateway_access_logs_prod.arn}:*"
      }
    ]
  })
}

# API Gateway Custom Domain Name for production
resource "aws_api_gateway_domain_name" "api_gateway_prod" {
  domain_name = "api.ror.org"
  
  regional_certificate_arn = data.aws_acm_certificate.ror.arn
  
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# Base path mapping for API Gateway production custom domain
resource "aws_api_gateway_base_path_mapping" "api_gateway_prod" {
  api_id      = aws_api_gateway_rest_api.api_gateway.id
  stage_name  = aws_api_gateway_stage.api_gateway_prod.stage_name
  domain_name = aws_api_gateway_domain_name.api_gateway_prod.domain_name
  
  depends_on = [
    aws_api_gateway_stage.api_gateway_prod
  ]
}
