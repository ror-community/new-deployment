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

resource "aws_route53_record" "api-dev" {
    zone_id = data.aws_route53_zone.public.zone_id
    name = "api.dev.ror.org"
    type = "CNAME"
    ttl = var.ttl
    records = [data.aws_lb.alb-dev.dns_name]
}

resource "aws_route53_record" "split-api-dev" {
  zone_id = data.aws_route53_zone.internal.zone_id
  name = "api.dev.ror.org"
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

####################################################################################
####################################################################################

# API Gateway for testing - separate ECS service with same container and security settings
resource "aws_ecs_service" "api_gateway_test" {
  name = "api-gateway-test"
  cluster = data.aws_ecs_cluster.default.id
  launch_type = "FARGATE"
  task_definition = aws_ecs_task_definition.api_gateway_test.arn
  desired_count = 2

  # give container time to start up
  health_check_grace_period_seconds = 600

  network_configuration {
    security_groups = [var.private_security_group_id]
    subnets         = var.private_subnet_ids
  }

  service_registries {
    registry_arn = aws_service_discovery_service.api_gateway_test.arn
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.api_gateway_test.id
    container_name   = "api-gateway-test"
    container_port   = "80"
  }

  tags = {environment = "ror-dev"}

  depends_on = [
    data.aws_lb_listener.alb-dev
  ]

}

resource "aws_lb_target_group" "api_gateway_test" {
  name     = "api-gateway-test-new"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"

  depends_on = [
    data.aws_lb_listener.alb-dev
  ]
}

# Listener rule for API Gateway test service - v1 paths
resource "aws_lb_listener_rule" "api_gateway_test_v1" {
  listener_arn = data.aws_lb_listener.alb-dev.arn
  priority = 50

  action {
    type  = "forward"
    target_group_arn = aws_lb_target_group.api_gateway_test.arn
  }

  condition {
    field  = "path-pattern"
    values = ["/v1/*"]
  }
}

# Listener rule for API Gateway test service - v2 paths
resource "aws_lb_listener_rule" "api_gateway_test_v2" {
  listener_arn = data.aws_lb_listener.alb-dev.arn
  priority = 51

  action {
    type  = "forward"
    target_group_arn = aws_lb_target_group.api_gateway_test.arn
  }

  condition {
    field  = "path-pattern"
    values = ["/v2/*"]
  }
}


resource "aws_ecs_task_definition" "api_gateway_test" {
  family = "api-gateway-test"
  execution_role_arn = data.aws_iam_role.ecs_tasks_execution_role.arn
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "1024"
  memory = "4096"

  container_definitions = data.template_file.api_gateway_test_task.rendered
}

resource "aws_service_discovery_service" "api_gateway_test" {
  name = "api-gateway-test"

  health_check_custom_config {
    failure_threshold = 1
  }

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.internal.id

    dns_records {
      ttl = 300
      type = "A"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_log_group" "api_gateway_test" {
  name = "/ecs/api-gateway-test-new"
}

# Autoscaling for API Gateway test service
resource "aws_appautoscaling_target" "api_gateway_test_autoscale_target" {
  max_capacity = 4
  min_capacity = 2
  resource_id = "service/default/api-gateway-test"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace = "ecs"
}

resource "aws_appautoscaling_policy" "api_gateway_test_autoscale_policy" {
  name = "api-gateway-test-cpu"
  policy_type = "TargetTrackingScaling"
  resource_id = aws_appautoscaling_target.api_gateway_test_autoscale_target.resource_id
  scalable_dimension = aws_appautoscaling_target.api_gateway_test_autoscale_target.scalable_dimension
  service_namespace = aws_appautoscaling_target.api_gateway_test_autoscale_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = 80
  }
}

# API Gateway REST API (supports caching)
resource "aws_api_gateway_rest_api" "api_gateway_test" {
  name = "ror-api-test"
  description = "ROR API Gateway for testing"
  
  endpoint_configuration {
    types = ["REGIONAL"]
  }
  
  tags = {
    environment = "ror-dev"
    purpose = "testing"
  }
}

# v1 resource
resource "aws_api_gateway_resource" "v1" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  parent_id   = aws_api_gateway_rest_api.api_gateway_test.root_resource_id
  path_part   = "v1"
}

# v2 resource
resource "aws_api_gateway_resource" "v2" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  parent_id   = aws_api_gateway_rest_api.api_gateway_test.root_resource_id
  path_part   = "v2"
}

# organizations resource under v1
resource "aws_api_gateway_resource" "v1_organizations" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  parent_id   = aws_api_gateway_resource.v1.id
  path_part   = "organizations"
}

# organizations resource under v2
resource "aws_api_gateway_resource" "v2_organizations" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  parent_id   = aws_api_gateway_resource.v2.id
  path_part   = "organizations"
}

# heartbeat resource under v1
resource "aws_api_gateway_resource" "v1_heartbeat" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  parent_id   = aws_api_gateway_resource.v1.id
  path_part   = "heartbeat"
}

# heartbeat resource under v2
resource "aws_api_gateway_resource" "v2_heartbeat" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  parent_id   = aws_api_gateway_resource.v2.id
  path_part   = "heartbeat"
}

# GET method for v1/organizations
resource "aws_api_gateway_method" "v1_organizations_get" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id   = aws_api_gateway_resource.v1_organizations.id
  http_method   = "GET"
  authorization = "NONE"
}

# OPTIONS method for v1/organizations (CORS)
resource "aws_api_gateway_method" "v1_organizations_options" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id   = aws_api_gateway_resource.v1_organizations.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# Method response for v1/organizations
resource "aws_api_gateway_method_response" "v1_organizations_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.v1_organizations.id
  http_method = aws_api_gateway_method.v1_organizations_get.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

# Method response for v1/organizations OPTIONS
resource "aws_api_gateway_method_response" "v1_organizations_options" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.v1_organizations.id
  http_method = aws_api_gateway_method.v1_organizations_options.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

# GET method for v2/organizations
resource "aws_api_gateway_method" "v2_organizations_get" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id   = aws_api_gateway_resource.v2_organizations.id
  http_method   = "GET"
  authorization = "NONE"
}

# Method response for v2/organizations
resource "aws_api_gateway_method_response" "v2_organizations_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.v2_organizations.id
  http_method = aws_api_gateway_method.v2_organizations_get.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

# GET method for v1/heartbeat
resource "aws_api_gateway_method" "v1_heartbeat_get" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id   = aws_api_gateway_resource.v1_heartbeat.id
  http_method   = "GET"
  authorization = "NONE"
}

# Method response for v1/heartbeat
resource "aws_api_gateway_method_response" "v1_heartbeat_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.v1_heartbeat.id
  http_method = aws_api_gateway_method.v1_heartbeat_get.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

# GET method for v2/heartbeat
resource "aws_api_gateway_method" "v2_heartbeat_get" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id   = aws_api_gateway_resource.v2_heartbeat.id
  http_method   = "GET"
  authorization = "NONE"
}

# Method response for v2/heartbeat
resource "aws_api_gateway_method_response" "v2_heartbeat_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.v2_heartbeat.id
  http_method = aws_api_gateway_method.v2_heartbeat_get.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

# Integration for v1/organizations
resource "aws_api_gateway_integration" "v1_organizations_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.v1_organizations.id
  http_method = aws_api_gateway_method.v1_organizations_get.http_method

  type                    = "HTTP_PROXY"
  integration_http_method = "GET"
  uri                     = "https://${data.aws_lb.alb-dev.dns_name}/v1/organizations/"
  
  request_parameters = {
    "integration.request.header.Host" = "'api.dev.ror.org'"
  }
}

# Integration response for v1/organizations
resource "aws_api_gateway_integration_response" "v1_organizations_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.v1_organizations.id
  http_method = aws_api_gateway_method.v1_organizations_get.http_method
  status_code = aws_api_gateway_method_response.v1_organizations_get.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }
}

# OPTIONS integration for v1/organizations (CORS)
resource "aws_api_gateway_integration" "v1_organizations_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.v1_organizations.id
  http_method = aws_api_gateway_method.v1_organizations_options.http_method

  type = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# Integration response for v1/organizations OPTIONS
resource "aws_api_gateway_integration_response" "v1_organizations_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.v1_organizations.id
  http_method = aws_api_gateway_method.v1_organizations_options.http_method
  status_code = aws_api_gateway_method_response.v1_organizations_options.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }
}

# Integration for v2/organizations
resource "aws_api_gateway_integration" "v2_organizations_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.v2_organizations.id
  http_method = aws_api_gateway_method.v2_organizations_get.http_method

  type                    = "HTTP_PROXY"
  integration_http_method = "GET"
  uri                     = "https://${data.aws_lb.alb-dev.dns_name}/v2/organizations/"
  
  request_parameters = {
    "integration.request.header.Host" = "'api.dev.ror.org'"
  }
}

# Integration response for v2/organizations
resource "aws_api_gateway_integration_response" "v2_organizations_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.v2_organizations.id
  http_method = aws_api_gateway_method.v2_organizations_get.http_method
  status_code = aws_api_gateway_method_response.v2_organizations_get.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }
}

# Integration for v1/heartbeat
resource "aws_api_gateway_integration" "v1_heartbeat_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.v1_heartbeat.id
  http_method = aws_api_gateway_method.v1_heartbeat_get.http_method

  type                    = "HTTP_PROXY"
  integration_http_method = "GET"
  uri                     = "https://${data.aws_lb.alb-dev.dns_name}/v1/heartbeat/"
  
  request_parameters = {
    "integration.request.header.Host" = "'api.dev.ror.org'"
  }
}

# Integration response for v1/heartbeat
resource "aws_api_gateway_integration_response" "v1_heartbeat_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.v1_heartbeat.id
  http_method = aws_api_gateway_method.v1_heartbeat_get.http_method
  status_code = aws_api_gateway_method_response.v1_heartbeat_get.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }
}

# Integration for v2/heartbeat
resource "aws_api_gateway_integration" "v2_heartbeat_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.v2_heartbeat.id
  http_method = aws_api_gateway_method.v2_heartbeat_get.http_method

  type                    = "HTTP_PROXY"
  integration_http_method = "GET"
  uri                     = "https://${data.aws_lb.alb-dev.dns_name}/v2/heartbeat/"
  
  request_parameters = {
    "integration.request.header.Host" = "'api.dev.ror.org'"
  }
}

# Integration response for v2/heartbeat
resource "aws_api_gateway_integration_response" "v2_heartbeat_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.v2_heartbeat.id
  http_method = aws_api_gateway_method.v2_heartbeat_get.http_method
  status_code = aws_api_gateway_method_response.v2_heartbeat_get.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }
}

resource "aws_api_gateway_deployment" "api_gateway_test" {
  depends_on = [
    aws_api_gateway_integration.v1_organizations_integration,
    aws_api_gateway_integration.v1_organizations_options_integration,
    aws_api_gateway_integration.v2_organizations_integration,
    aws_api_gateway_integration.v1_heartbeat_integration,
    aws_api_gateway_integration.v2_heartbeat_integration,
    aws_api_gateway_integration_response.v2_organizations_integration,
    aws_api_gateway_integration_response.v1_heartbeat_integration,
    aws_api_gateway_integration_response.v2_heartbeat_integration,
  ]

  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  stage_name  = "test"
  
  variables = {
    deployed_at = timestamp()
    force_update = "true"
  }
  
  lifecycle {
    create_before_destroy = true
  }
}

# Route53 record for API Gateway
resource "aws_route53_record" "api_gateway_test" {
    zone_id = data.aws_route53_zone.public.zone_id
    name    = "api-gateway-test.dev.ror.org"
    type    = "CNAME"
    ttl     = var.ttl
    records = ["${aws_api_gateway_rest_api.api_gateway_test.id}.execute-api.eu-west-1.amazonaws.com/test"]
    
    lifecycle {
        create_before_destroy = true
    }
}



# IAM role for API Gateway to write logs
resource "aws_iam_role" "api_gateway_cloudwatch" {
  name = "api-gateway-cloudwatch-role"

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

resource "aws_iam_role_policy" "api_gateway_cloudwatch" {
  name = "api-gateway-cloudwatch-policy"
  role = aws_iam_role.api_gateway_cloudwatch.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
          "logs:GetLogEvents",
          "logs:FilterLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}
