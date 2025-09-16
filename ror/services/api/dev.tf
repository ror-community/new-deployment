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
  listener_arn = data.aws_lb_listener.alb-http-dev.arn

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

# CloudWatch Log Group for API Gateway Access Logs
resource "aws_cloudwatch_log_group" "api_gateway_access_logs" {
  name              = "/aws/apigateway/ror-api-dev"
  retention_in_days = 30
  
  tags = {
    environment = "ror-dev"
    purpose = "api-gateway-cache-analytics"
  }
}

# Resource policy to allow API Gateway to write to the log group
resource "aws_cloudwatch_log_resource_policy" "api_gateway_logs" {
  policy_name = "api-gateway-logs-policy"
  
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
        Resource = "${aws_cloudwatch_log_group.api_gateway_access_logs.arn}:*"
      }
    ]
  })
}

# IAM role for API Gateway CloudWatch logging
resource "aws_iam_role" "api_gateway_cloudwatch_role" {
  name = "api-gateway-cloudwatch-role-dev"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })
}

# IAM role policy attachment for API Gateway CloudWatch logging
resource "aws_iam_role_policy_attachment" "api_gateway_cloudwatch_logs" {
  role       = aws_iam_role.api_gateway_cloudwatch_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

# API Gateway account configuration for logging
resource "aws_api_gateway_account" "api_gateway_account" {
  cloudwatch_role_arn = aws_iam_role.api_gateway_cloudwatch_role.arn
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

resource "aws_route53_record" "api-dev" {
    zone_id = data.aws_route53_zone.public.zone_id
    name = "api.dev.ror.org"
    type = "A"
    
    alias {
        name = aws_api_gateway_domain_name.api_gateway_dev.regional_domain_name
        zone_id = aws_api_gateway_domain_name.api_gateway_dev.regional_zone_id
        evaluate_target_health = false
    }
}

resource "aws_route53_record" "split-api-dev" {
  zone_id = data.aws_route53_zone.internal.zone_id
  name = "api.dev.ror.org"
  type = "A"
  
  alias {
    name = aws_api_gateway_domain_name.api_gateway_dev.regional_domain_name
    zone_id = aws_api_gateway_domain_name.api_gateway_dev.regional_zone_id
    evaluate_target_health = false
  }
}


# Route53 CNAME record for ALB dev (public)
resource "aws_route53_record" "alb-dev" {
    zone_id = data.aws_route53_zone.public.zone_id
    name = "alb.dev.ror.org"
    type = "CNAME"
    ttl = var.ttl
    records = [data.aws_lb.alb-dev.dns_name]
}

# Route53 CNAME record for ALB dev (internal)
resource "aws_route53_record" "split-alb-dev" {
  zone_id = data.aws_route53_zone.internal.zone_id
  name = "alb.dev.ror.org"
  type = "CNAME"
  ttl = var.ttl
  records = [data.aws_lb.alb-dev.dns_name]
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

# =============================================================================
# API GATEWAY DEPLOYMENT & DOMAIN - DEV
# =============================================================================

# API Gateway Custom Domain Name for development
resource "aws_api_gateway_domain_name" "api_gateway_dev" {
  domain_name = "api.dev.ror.org"
  
  regional_certificate_arn = data.aws_acm_certificate.ror.arn
  
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# Base path mapping for API Gateway development custom domain
resource "aws_api_gateway_base_path_mapping" "api_gateway_dev" {
  api_id      = aws_api_gateway_rest_api.api_gateway.id
  stage_name  = aws_api_gateway_stage.api_gateway_dev.stage_name
  domain_name = aws_api_gateway_domain_name.api_gateway_dev.domain_name
  
  depends_on = [
    aws_api_gateway_stage.api_gateway_dev
  ]
}