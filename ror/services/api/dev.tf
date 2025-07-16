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

# =============================================================================
# API GATEWAY NON-CACHING ENDPOINT
# =============================================================================

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
resource "aws_lb_listener_rule" "api_gateway_test_host" {
  listener_arn = data.aws_lb_listener.alb-dev.arn
  priority = 50

  action {
    type  = "forward"
    target_group_arn = aws_lb_target_group.api_gateway_test.arn
  }

  condition {
    field  = "host-header"
    values = ["api-gateway-test.dev.ror.org"]
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

# API Gateway REST API (non-caching)
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

# organization ID resource under v1/organizations
resource "aws_api_gateway_resource" "v1_organizations_id" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  parent_id   = aws_api_gateway_resource.v1_organizations.id
  path_part   = "{id}"
}

# organizations resource under v2
resource "aws_api_gateway_resource" "v2_organizations" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  parent_id   = aws_api_gateway_resource.v2.id
  path_part   = "organizations"
}

# organization ID resource under v2/organizations
resource "aws_api_gateway_resource" "v2_organizations_id" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  parent_id   = aws_api_gateway_resource.v2_organizations.id
  path_part   = "{id}"
}

# organizations resource (without version - uses default v2)
resource "aws_api_gateway_resource" "organizations" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  parent_id   = aws_api_gateway_rest_api.api_gateway_test.root_resource_id
  path_part   = "organizations"
}

# organization ID resource under organizations (without version - uses default v2)
resource "aws_api_gateway_resource" "organizations_id" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  parent_id   = aws_api_gateway_resource.organizations.id
  path_part   = "{id}"
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

# GET method for v1/organizations/{id}
resource "aws_api_gateway_method" "v1_organizations_id_get" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id   = aws_api_gateway_resource.v1_organizations_id.id
  http_method   = "GET"
  authorization = "NONE"
  
  request_parameters = {
    "method.request.path.id" = true
  }
}

# OPTIONS method for v1/organizations/{id} (CORS)
resource "aws_api_gateway_method" "v1_organizations_id_options" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id   = aws_api_gateway_resource.v1_organizations_id.id
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

# GET method for organizations (without version - uses default v2)
resource "aws_api_gateway_method" "organizations_get" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id   = aws_api_gateway_resource.organizations.id
  http_method   = "GET"
  authorization = "NONE"
}

# GET method for organizations/{id} (without version - uses default v2)
resource "aws_api_gateway_method" "organizations_id_get" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id   = aws_api_gateway_resource.organizations_id.id
  http_method   = "GET"
  authorization = "NONE"
  
  request_parameters = {
    "method.request.path.id" = true
  }
}

# OPTIONS method for organizations/{id} (CORS)
resource "aws_api_gateway_method" "organizations_id_options" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id   = aws_api_gateway_resource.organizations_id.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# GET method for v2/organizations/{id}
resource "aws_api_gateway_method" "v2_organizations_id_get" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id   = aws_api_gateway_resource.v2_organizations_id.id
  http_method   = "GET"
  authorization = "NONE"
  
  request_parameters = {
    "method.request.path.id" = true
  }
}

# OPTIONS method for v2/organizations/{id} (CORS)
resource "aws_api_gateway_method" "v2_organizations_id_options" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id   = aws_api_gateway_resource.v2_organizations_id.id
  http_method   = "OPTIONS"
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

# Method response for organizations (without version - uses default v2)
resource "aws_api_gateway_method_response" "organizations_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.organizations.id
  http_method = aws_api_gateway_method.organizations_get.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

# Method response for v1/organizations/{id}
resource "aws_api_gateway_method_response" "v1_organizations_id_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.v1_organizations_id.id
  http_method = aws_api_gateway_method.v1_organizations_id_get.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

# Method response for v1/organizations/{id} OPTIONS
resource "aws_api_gateway_method_response" "v1_organizations_id_options" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.v1_organizations_id.id
  http_method = aws_api_gateway_method.v1_organizations_id_options.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

# Method response for v2/organizations/{id}
resource "aws_api_gateway_method_response" "v2_organizations_id_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.v2_organizations_id.id
  http_method = aws_api_gateway_method.v2_organizations_id_get.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

# Method response for v2/organizations/{id} OPTIONS
resource "aws_api_gateway_method_response" "v2_organizations_id_options" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.v2_organizations_id.id
  http_method = aws_api_gateway_method.v2_organizations_id_options.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

# Method response for organizations/{id} (without version - uses default v2)
resource "aws_api_gateway_method_response" "organizations_id_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.organizations_id.id
  http_method = aws_api_gateway_method.organizations_id_get.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

# Method response for organizations/{id} OPTIONS (without version - uses default v2)
resource "aws_api_gateway_method_response" "organizations_id_options" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.organizations_id.id
  http_method = aws_api_gateway_method.organizations_id_options.http_method
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

  type                    = "HTTP"
  integration_http_method = "GET"
  uri                     = "https://api.dev.ror.org/v1/organizations"
  
  # CACHING CONFIGURATION (uncomment to enable)
  # cache_key_parameters = ["method.request.path.proxy"]
  # cache_namespace     = "v1-organizations"
  # content_handling    = "CONVERT_TO_TEXT"
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

  depends_on = [
    aws_api_gateway_integration.v1_organizations_integration
  ]
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

  depends_on = [
    aws_api_gateway_integration.v1_organizations_options_integration
  ]
}

# Integration for v1/organizations/{id}
resource "aws_api_gateway_integration" "v1_organizations_id_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.v1_organizations_id.id
  http_method = aws_api_gateway_method.v1_organizations_id_get.http_method

  type                    = "HTTP"
  integration_http_method = "GET"
  uri                     = "https://api.dev.ror.org/v1/organizations/{id}"
  
  request_parameters = {
    "integration.request.path.id" = "method.request.path.id"
  }
  
  # CACHING CONFIGURATION (uncomment to enable)
  # cache_key_parameters = ["method.request.path.proxy", "method.request.path.id"]
  # cache_namespace     = "v1-organizations-id"
  # content_handling    = "CONVERT_TO_TEXT"
}

# Integration response for v1/organizations/{id}
resource "aws_api_gateway_integration_response" "v1_organizations_id_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.v1_organizations_id.id
  http_method = aws_api_gateway_method.v1_organizations_id_get.http_method
  status_code = aws_api_gateway_method_response.v1_organizations_id_get.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }

  depends_on = [
    aws_api_gateway_integration.v1_organizations_id_integration
  ]
}

# OPTIONS integration for v1/organizations/{id} (CORS)
resource "aws_api_gateway_integration" "v1_organizations_id_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.v1_organizations_id.id
  http_method = aws_api_gateway_method.v1_organizations_id_options.http_method

  type = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# Integration response for v1/organizations/{id} OPTIONS
resource "aws_api_gateway_integration_response" "v1_organizations_id_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.v1_organizations_id.id
  http_method = aws_api_gateway_method.v1_organizations_id_options.http_method
  status_code = aws_api_gateway_method_response.v1_organizations_id_options.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }

  depends_on = [
    aws_api_gateway_integration.v1_organizations_id_options_integration
  ]
}

# Integration for v2/organizations
resource "aws_api_gateway_integration" "v2_organizations_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.v2_organizations.id
  http_method = aws_api_gateway_method.v2_organizations_get.http_method

  type                    = "HTTP"
  integration_http_method = "GET"
  uri                     = "https://api.dev.ror.org/v2/organizations"
  
  # CACHING CONFIGURATION (uncomment to enable)
  # cache_key_parameters = ["method.request.path.proxy"]
  # cache_namespace     = "v2-organizations"
  # content_handling    = "CONVERT_TO_TEXT"
}

# Integration for organizations (without version - uses default v2)
resource "aws_api_gateway_integration" "organizations_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.organizations.id
  http_method = aws_api_gateway_method.organizations_get.http_method

  type                    = "HTTP"
  integration_http_method = "GET"
  uri                     = "https://api.dev.ror.org/organizations"
  
  # CACHING CONFIGURATION (uncomment to enable)
  # cache_key_parameters = ["method.request.path.proxy"]
  # cache_namespace     = "organizations"
  # content_handling    = "CONVERT_TO_TEXT"
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

  depends_on = [
    aws_api_gateway_integration.v2_organizations_integration
  ]
}

# Integration response for organizations (without version - uses default v2)
resource "aws_api_gateway_integration_response" "organizations_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.organizations.id
  http_method = aws_api_gateway_method.organizations_get.http_method
  status_code = aws_api_gateway_method_response.organizations_get.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }

  depends_on = [
    aws_api_gateway_integration.organizations_integration
  ]
}

# Integration for v2/organizations/{id}
resource "aws_api_gateway_integration" "v2_organizations_id_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.v2_organizations_id.id
  http_method = aws_api_gateway_method.v2_organizations_id_get.http_method

  type                    = "HTTP"
  integration_http_method = "GET"
  uri                     = "https://api.dev.ror.org/v2/organizations/{id}"
  
  request_parameters = {
    "integration.request.path.id" = "method.request.path.id"
  }
  
  # CACHING CONFIGURATION (uncomment to enable)
  # cache_key_parameters = ["method.request.path.proxy", "method.request.path.id"]
  # cache_namespace     = "v2-organizations-id"
  # content_handling    = "CONVERT_TO_TEXT"
}

# Integration response for v2/organizations/{id}
resource "aws_api_gateway_integration_response" "v2_organizations_id_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.v2_organizations_id.id
  http_method = aws_api_gateway_method.v2_organizations_id_get.http_method
  status_code = aws_api_gateway_method_response.v2_organizations_id_get.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }

  depends_on = [
    aws_api_gateway_integration.v2_organizations_id_integration
  ]
}

# OPTIONS integration for v2/organizations/{id} (CORS)
resource "aws_api_gateway_integration" "v2_organizations_id_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.v2_organizations_id.id
  http_method = aws_api_gateway_method.v2_organizations_id_options.http_method

  type = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# Integration response for v2/organizations/{id} OPTIONS
resource "aws_api_gateway_integration_response" "v2_organizations_id_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.v2_organizations_id.id
  http_method = aws_api_gateway_method.v2_organizations_id_options.http_method
  status_code = aws_api_gateway_method_response.v2_organizations_id_options.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }

  depends_on = [
    aws_api_gateway_integration.v2_organizations_id_options_integration
  ]
}

# Integration for organizations/{id} (without version - uses default v2)
resource "aws_api_gateway_integration" "organizations_id_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.organizations_id.id
  http_method = aws_api_gateway_method.organizations_id_get.http_method

  type                    = "HTTP"
  integration_http_method = "GET"
  uri                     = "https://api.dev.ror.org/organizations/{id}"
  
  request_parameters = {
    "integration.request.path.id" = "method.request.path.id"
  }
  
  # CACHING CONFIGURATION (uncomment to enable)
  # cache_key_parameters = ["method.request.path.proxy", "method.request.path.id"]
  # cache_namespace     = "organizations-id"
  # content_handling    = "CONVERT_TO_TEXT"
}

# Integration response for organizations/{id} (without version - uses default v2)
resource "aws_api_gateway_integration_response" "organizations_id_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.organizations_id.id
  http_method = aws_api_gateway_method.organizations_id_get.http_method
  status_code = aws_api_gateway_method_response.organizations_id_get.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }

  depends_on = [
    aws_api_gateway_integration.organizations_id_integration
  ]
}

# OPTIONS integration for organizations/{id} (CORS)
resource "aws_api_gateway_integration" "organizations_id_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.organizations_id.id
  http_method = aws_api_gateway_method.organizations_id_options.http_method

  type = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# Integration response for organizations/{id} OPTIONS
resource "aws_api_gateway_integration_response" "organizations_id_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.organizations_id.id
  http_method = aws_api_gateway_method.organizations_id_options.http_method
  status_code = aws_api_gateway_method_response.organizations_id_options.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }

  depends_on = [
    aws_api_gateway_integration.organizations_id_options_integration
  ]
}

# Integration for v1/heartbeat
resource "aws_api_gateway_integration" "v1_heartbeat_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.v1_heartbeat.id
  http_method = aws_api_gateway_method.v1_heartbeat_get.http_method

  type                    = "HTTP"
  integration_http_method = "GET"
  uri                     = "https://api.dev.ror.org/v1/heartbeat"
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

  depends_on = [
    aws_api_gateway_integration.v1_heartbeat_integration
  ]
}


# Integration for v2/heartbeat
resource "aws_api_gateway_integration" "v2_heartbeat_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.v2_heartbeat.id
  http_method = aws_api_gateway_method.v2_heartbeat_get.http_method

  type                    = "HTTP"
  integration_http_method = "GET"
  uri                     = "https://api.dev.ror.org/v2/heartbeat"
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

  depends_on = [
    aws_api_gateway_integration.v2_heartbeat_integration
  ]
}


resource "aws_api_gateway_deployment" "api_gateway_test" {
  depends_on = [
    aws_api_gateway_integration.v1_organizations_integration,
    aws_api_gateway_integration.v1_organizations_options_integration,
    aws_api_gateway_integration.v1_organizations_id_integration,
    aws_api_gateway_integration.v1_organizations_id_options_integration,
    aws_api_gateway_integration.v2_organizations_integration,
    aws_api_gateway_integration.organizations_integration,
    aws_api_gateway_integration.v2_organizations_id_integration,
    aws_api_gateway_integration.v2_organizations_id_options_integration,
    aws_api_gateway_integration.organizations_id_integration,
    aws_api_gateway_integration.organizations_id_options_integration,
    aws_api_gateway_integration.v1_heartbeat_integration,
    aws_api_gateway_integration.v2_heartbeat_integration,
    aws_api_gateway_integration_response.v1_organizations_integration,
    aws_api_gateway_integration_response.v1_organizations_options_integration,
    aws_api_gateway_integration_response.v1_organizations_id_integration,
    aws_api_gateway_integration_response.v1_organizations_id_options_integration,
    aws_api_gateway_integration_response.v2_organizations_integration,
    aws_api_gateway_integration_response.organizations_integration,
    aws_api_gateway_integration_response.v2_organizations_id_integration,
    aws_api_gateway_integration_response.v2_organizations_id_options_integration,
    aws_api_gateway_integration_response.organizations_id_integration,
    aws_api_gateway_integration_response.organizations_id_options_integration,
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

# API Gateway Custom Domain Name
resource "aws_api_gateway_domain_name" "api_gateway_test" {
  domain_name = "api-gateway-test.dev.ror.org"
  
  regional_certificate_arn = data.aws_acm_certificate.ror.arn
  
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# Base path mapping for API Gateway custom domain
resource "aws_api_gateway_base_path_mapping" "api_gateway_test" {
  api_id      = aws_api_gateway_rest_api.api_gateway_test.id
  stage_name  = aws_api_gateway_deployment.api_gateway_test.stage_name
  domain_name = aws_api_gateway_domain_name.api_gateway_test.domain_name
  
  depends_on = [
    aws_api_gateway_deployment.api_gateway_test
  ]
}

# Route53 record for API Gateway custom domain
resource "aws_route53_record" "api_gateway_test" {
    zone_id = data.aws_route53_zone.public.zone_id
    name    = "api-gateway-test.dev.ror.org"
    type    = "A"
    
    alias {
        name                   = aws_api_gateway_domain_name.api_gateway_test.regional_domain_name
        zone_id                = aws_api_gateway_domain_name.api_gateway_test.regional_zone_id
        evaluate_target_health = false
    }
    
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

# WAF Association for API Gateway test service
resource "aws_wafv2_web_acl_association" "api_gateway_test" {
  resource_arn = "${aws_api_gateway_rest_api.api_gateway_test.arn}/stages/${aws_api_gateway_deployment.api_gateway_test.stage_name}"
  web_acl_arn  = data.aws_wafv2_web_acl.dev-v2.arn
  
  depends_on = [
    aws_api_gateway_deployment.api_gateway_test
  ]
}

# =============================================================================
# API GATEWAY CACHING ENDPOINT
# =============================================================================

# API Gateway REST API with caching enabled
resource "aws_api_gateway_rest_api" "api_gateway_cache_test" {
  name = "ror-api-cache-test"
  description = "ROR API Gateway for testing with caching"
  
  endpoint_configuration {
    types = ["REGIONAL"]
  }
  
  tags = {
    environment = "ror-dev"
    purpose = "testing-with-cache"
  }
}

# API Gateway Stage with caching enabled
resource "aws_api_gateway_stage" "api_gateway_cache_test" {
  deployment_id = aws_api_gateway_deployment.api_gateway_cache_test.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_cache_test.id
  stage_name    = "test"
  
  # Enable caching for this stage
  cache_cluster_enabled = true
  cache_cluster_size    = "0.5"  # 0.5GB cache size (smallest available)
  
  tags = {
    environment = "ror-dev"
    purpose = "api-gateway-caching"
  }
}

# API Gateway Usage Plan with caching
resource "aws_api_gateway_usage_plan" "api_gateway_cache_test" {
  name = "api-gateway-cache-test-usage-plan"
  description = "Usage plan for ROR API Gateway cache test with caching"
  
  api_stages {
    api_id = aws_api_gateway_rest_api.api_gateway_cache_test.id
    stage  = aws_api_gateway_stage.api_gateway_cache_test.stage_name
  }
  
  tags = {
    environment = "ror-dev"
    purpose = "api-gateway-caching"
  }
}

# v1 resource for cache test
resource "aws_api_gateway_resource" "cache_v1" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_cache_test.id
  parent_id   = aws_api_gateway_rest_api.api_gateway_cache_test.root_resource_id
  path_part   = "v1"
}

# v2 resource for cache test
resource "aws_api_gateway_resource" "cache_v2" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_cache_test.id
  parent_id   = aws_api_gateway_rest_api.api_gateway_cache_test.root_resource_id
  path_part   = "v2"
}

# organizations resource under v1 for cache test
resource "aws_api_gateway_resource" "cache_v1_organizations" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_cache_test.id
  parent_id   = aws_api_gateway_resource.cache_v1.id
  path_part   = "organizations"
}

# organization ID resource under v1/organizations for cache test
resource "aws_api_gateway_resource" "cache_v1_organizations_id" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_cache_test.id
  parent_id   = aws_api_gateway_resource.cache_v1_organizations.id
  path_part   = "{id}"
}

# organizations resource under v2 for cache test
resource "aws_api_gateway_resource" "cache_v2_organizations" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_cache_test.id
  parent_id   = aws_api_gateway_resource.cache_v2.id
  path_part   = "organizations"
}

# organization ID resource under v2/organizations for cache test
resource "aws_api_gateway_resource" "cache_v2_organizations_id" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_cache_test.id
  parent_id   = aws_api_gateway_resource.cache_v2_organizations.id
  path_part   = "{id}"
}

# organizations resource (without version - uses default v2) for cache test
resource "aws_api_gateway_resource" "cache_organizations" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_cache_test.id
  parent_id   = aws_api_gateway_rest_api.api_gateway_cache_test.root_resource_id
  path_part   = "organizations"
}

# organization ID resource under organizations (without version - uses default v2) for cache test
resource "aws_api_gateway_resource" "cache_organizations_id" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_cache_test.id
  parent_id   = aws_api_gateway_resource.cache_organizations.id
  path_part   = "{id}"
}

# heartbeat resource under v1 for cache test
resource "aws_api_gateway_resource" "cache_v1_heartbeat" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_cache_test.id
  parent_id   = aws_api_gateway_resource.cache_v1.id
  path_part   = "heartbeat"
}

# heartbeat resource under v2 for cache test
resource "aws_api_gateway_resource" "cache_v2_heartbeat" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_cache_test.id
  parent_id   = aws_api_gateway_resource.cache_v2.id
  path_part   = "heartbeat"
}

# GET method for v1/organizations (cache test)
resource "aws_api_gateway_method" "cache_v1_organizations_get" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_cache_test.id
  resource_id   = aws_api_gateway_resource.cache_v1_organizations.id
  http_method   = "GET"
  authorization = "NONE"
}

# OPTIONS method for v1/organizations (CORS) (cache test)
resource "aws_api_gateway_method" "cache_v1_organizations_options" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_cache_test.id
  resource_id   = aws_api_gateway_resource.cache_v1_organizations.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# GET method for v1/organizations/{id} (cache test)
resource "aws_api_gateway_method" "cache_v1_organizations_id_get" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_cache_test.id
  resource_id   = aws_api_gateway_resource.cache_v1_organizations_id.id
  http_method   = "GET"
  authorization = "NONE"
  
  request_parameters = {
    "method.request.path.id" = true
  }
}

# OPTIONS method for v1/organizations/{id} (CORS) (cache test)
resource "aws_api_gateway_method" "cache_v1_organizations_id_options" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_cache_test.id
  resource_id   = aws_api_gateway_resource.cache_v1_organizations_id.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# GET method for v2/organizations (cache test)
resource "aws_api_gateway_method" "cache_v2_organizations_get" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_cache_test.id
  resource_id   = aws_api_gateway_resource.cache_v2_organizations.id
  http_method   = "GET"
  authorization = "NONE"
}

# GET method for organizations (without version - uses default v2) (cache test)
resource "aws_api_gateway_method" "cache_organizations_get" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_cache_test.id
  resource_id   = aws_api_gateway_resource.cache_organizations.id
  http_method   = "GET"
  authorization = "NONE"
}

# GET method for organizations/{id} (without version - uses default v2) (cache test)
resource "aws_api_gateway_method" "cache_organizations_id_get" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_cache_test.id
  resource_id   = aws_api_gateway_resource.cache_organizations_id.id
  http_method   = "GET"
  authorization = "NONE"
  
  request_parameters = {
    "method.request.path.id" = true
  }
}

# OPTIONS method for organizations/{id} (CORS) (cache test)
resource "aws_api_gateway_method" "cache_organizations_id_options" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_cache_test.id
  resource_id   = aws_api_gateway_resource.cache_organizations_id.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# GET method for v2/organizations/{id} (cache test)
resource "aws_api_gateway_method" "cache_v2_organizations_id_get" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_cache_test.id
  resource_id   = aws_api_gateway_resource.cache_v2_organizations_id.id
  http_method   = "GET"
  authorization = "NONE"
  
  request_parameters = {
    "method.request.path.id" = true
  }
}

# OPTIONS method for v2/organizations/{id} (CORS) (cache test)
resource "aws_api_gateway_method" "cache_v2_organizations_id_options" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_cache_test.id
  resource_id   = aws_api_gateway_resource.cache_v2_organizations_id.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# GET method for v1/heartbeat (cache test)
resource "aws_api_gateway_method" "cache_v1_heartbeat_get" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_cache_test.id
  resource_id   = aws_api_gateway_resource.cache_v1_heartbeat.id
  http_method   = "GET"
  authorization = "NONE"
}

# GET method for v2/heartbeat (cache test)
resource "aws_api_gateway_method" "cache_v2_heartbeat_get" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_cache_test.id
  resource_id   = aws_api_gateway_resource.cache_v2_heartbeat.id
  http_method   = "GET"
  authorization = "NONE"
}

# Method responses for cache test (similar to original but with cache_ prefix)
resource "aws_api_gateway_method_response" "cache_v1_organizations_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_cache_test.id
  resource_id = aws_api_gateway_resource.cache_v1_organizations.id
  http_method = aws_api_gateway_method.cache_v1_organizations_get.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

resource "aws_api_gateway_method_response" "cache_v1_organizations_options" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_cache_test.id
  resource_id = aws_api_gateway_resource.cache_v1_organizations.id
  http_method = aws_api_gateway_method.cache_v1_organizations_options.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

resource "aws_api_gateway_method_response" "cache_v1_organizations_id_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_cache_test.id
  resource_id = aws_api_gateway_resource.cache_v1_organizations_id.id
  http_method = aws_api_gateway_method.cache_v1_organizations_id_get.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

resource "aws_api_gateway_method_response" "cache_v1_organizations_id_options" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_cache_test.id
  resource_id = aws_api_gateway_resource.cache_v1_organizations_id.id
  http_method = aws_api_gateway_method.cache_v1_organizations_id_options.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

resource "aws_api_gateway_method_response" "cache_v2_organizations_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_cache_test.id
  resource_id = aws_api_gateway_resource.cache_v2_organizations.id
  http_method = aws_api_gateway_method.cache_v2_organizations_get.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

resource "aws_api_gateway_method_response" "cache_organizations_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_cache_test.id
  resource_id = aws_api_gateway_resource.cache_organizations.id
  http_method = aws_api_gateway_method.cache_organizations_get.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

resource "aws_api_gateway_method_response" "cache_organizations_id_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_cache_test.id
  resource_id = aws_api_gateway_resource.cache_organizations_id.id
  http_method = aws_api_gateway_method.cache_organizations_id_get.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

resource "aws_api_gateway_method_response" "cache_organizations_id_options" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_cache_test.id
  resource_id = aws_api_gateway_resource.cache_organizations_id.id
  http_method = aws_api_gateway_method.cache_organizations_id_options.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

resource "aws_api_gateway_method_response" "cache_v2_organizations_id_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_cache_test.id
  resource_id = aws_api_gateway_resource.cache_v2_organizations_id.id
  http_method = aws_api_gateway_method.cache_v2_organizations_id_get.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

resource "aws_api_gateway_method_response" "cache_v2_organizations_id_options" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_cache_test.id
  resource_id = aws_api_gateway_resource.cache_v2_organizations_id.id
  http_method = aws_api_gateway_method.cache_v2_organizations_id_options.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

resource "aws_api_gateway_method_response" "cache_v1_heartbeat_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_cache_test.id
  resource_id = aws_api_gateway_resource.cache_v1_heartbeat.id
  http_method = aws_api_gateway_method.cache_v1_heartbeat_get.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

resource "aws_api_gateway_method_response" "cache_v2_heartbeat_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_cache_test.id
  resource_id = aws_api_gateway_resource.cache_v2_heartbeat.id
  http_method = aws_api_gateway_method.cache_v2_heartbeat_get.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

# Integrations for cache test with caching enabled
resource "aws_api_gateway_integration" "cache_v1_organizations_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_cache_test.id
  resource_id = aws_api_gateway_resource.cache_v1_organizations.id
  http_method = aws_api_gateway_method.cache_v1_organizations_get.http_method

  type                    = "HTTP"
  integration_http_method = "GET"
  uri                     = "https://api.dev.ror.org/v1/organizations"
  
  # CACHING CONFIGURATION
  cache_key_parameters = ["method.request.path.proxy"]
  cache_namespace     = "v1-organizations"
  content_handling    = "CONVERT_TO_TEXT"
}

resource "aws_api_gateway_integration" "cache_v1_organizations_id_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_cache_test.id
  resource_id = aws_api_gateway_resource.cache_v1_organizations_id.id
  http_method = aws_api_gateway_method.cache_v1_organizations_id_get.http_method

  type                    = "HTTP"
  integration_http_method = "GET"
  uri                     = "https://api.dev.ror.org/v1/organizations/{id}"
  
  request_parameters = {
    "integration.request.path.id" = "method.request.path.id"
  }
  
  # CACHING CONFIGURATION
  cache_key_parameters = ["method.request.path.proxy", "method.request.path.id"]
  cache_namespace     = "v1-organizations-id"
  content_handling    = "CONVERT_TO_TEXT"
}

resource "aws_api_gateway_integration" "cache_v2_organizations_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_cache_test.id
  resource_id = aws_api_gateway_resource.cache_v2_organizations.id
  http_method = aws_api_gateway_method.cache_v2_organizations_get.http_method

  type                    = "HTTP"
  integration_http_method = "GET"
  uri                     = "https://api.dev.ror.org/v2/organizations"
  
  # CACHING CONFIGURATION
  cache_key_parameters = ["method.request.path.proxy"]
  cache_namespace     = "v2-organizations"
  content_handling    = "CONVERT_TO_TEXT"
}

resource "aws_api_gateway_integration" "cache_organizations_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_cache_test.id
  resource_id = aws_api_gateway_resource.cache_organizations.id
  http_method = aws_api_gateway_method.cache_organizations_get.http_method

  type                    = "HTTP"
  integration_http_method = "GET"
  uri                     = "https://api.dev.ror.org/organizations"
  
  # CACHING CONFIGURATION
  cache_key_parameters = ["method.request.path.proxy"]
  cache_namespace     = "organizations"
  content_handling    = "CONVERT_TO_TEXT"
}

resource "aws_api_gateway_integration" "cache_v2_organizations_id_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_cache_test.id
  resource_id = aws_api_gateway_resource.cache_v2_organizations_id.id
  http_method = aws_api_gateway_method.cache_v2_organizations_id_get.http_method

  type                    = "HTTP"
  integration_http_method = "GET"
  uri                     = "https://api.dev.ror.org/v2/organizations/{id}"
  
  request_parameters = {
    "integration.request.path.id" = "method.request.path.id"
  }
  
  # CACHING CONFIGURATION
  cache_key_parameters = ["method.request.path.proxy", "method.request.path.id"]
  cache_namespace     = "v2-organizations-id"
  content_handling    = "CONVERT_TO_TEXT"
}

resource "aws_api_gateway_integration" "cache_organizations_id_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_cache_test.id
  resource_id = aws_api_gateway_resource.cache_organizations_id.id
  http_method = aws_api_gateway_method.cache_organizations_id_get.http_method

  type                    = "HTTP"
  integration_http_method = "GET"
  uri                     = "https://api.dev.ror.org/organizations/{id}"
  
  request_parameters = {
    "integration.request.path.id" = "method.request.path.id"
  }
  
  # CACHING CONFIGURATION
  cache_key_parameters = ["method.request.path.proxy", "method.request.path.id"]
  cache_namespace     = "organizations-id"
  content_handling    = "CONVERT_TO_TEXT"
}

resource "aws_api_gateway_integration" "cache_v1_heartbeat_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_cache_test.id
  resource_id = aws_api_gateway_resource.cache_v1_heartbeat.id
  http_method = aws_api_gateway_method.cache_v1_heartbeat_get.http_method

  type                    = "HTTP"
  integration_http_method = "GET"
  uri                     = "https://api.dev.ror.org/v1/heartbeat"
}

resource "aws_api_gateway_integration" "cache_v2_heartbeat_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_cache_test.id
  resource_id = aws_api_gateway_resource.cache_v2_heartbeat.id
  http_method = aws_api_gateway_method.cache_v2_heartbeat_get.http_method

  type                    = "HTTP"
  integration_http_method = "GET"
  uri                     = "https://api.dev.ror.org/v2/heartbeat"
}

# Integration responses for cache test
resource "aws_api_gateway_integration_response" "cache_v1_organizations_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_cache_test.id
  resource_id = aws_api_gateway_resource.cache_v1_organizations.id
  http_method = aws_api_gateway_method.cache_v1_organizations_get.http_method
  status_code = aws_api_gateway_method_response.cache_v1_organizations_get.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }

  depends_on = [
    aws_api_gateway_integration.cache_v1_organizations_integration
  ]
}

resource "aws_api_gateway_integration_response" "cache_v1_organizations_id_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_cache_test.id
  resource_id = aws_api_gateway_resource.cache_v1_organizations_id.id
  http_method = aws_api_gateway_method.cache_v1_organizations_id_get.http_method
  status_code = aws_api_gateway_method_response.cache_v1_organizations_id_get.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }

  depends_on = [
    aws_api_gateway_integration.cache_v1_organizations_id_integration
  ]
}

resource "aws_api_gateway_integration_response" "cache_v2_organizations_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_cache_test.id
  resource_id = aws_api_gateway_resource.cache_v2_organizations.id
  http_method = aws_api_gateway_method.cache_v2_organizations_get.http_method
  status_code = aws_api_gateway_method_response.cache_v2_organizations_get.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }

  depends_on = [
    aws_api_gateway_integration.cache_v2_organizations_integration
  ]
}

resource "aws_api_gateway_integration_response" "cache_organizations_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_cache_test.id
  resource_id = aws_api_gateway_resource.cache_organizations.id
  http_method = aws_api_gateway_method.cache_organizations_get.http_method
  status_code = aws_api_gateway_method_response.cache_organizations_get.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }

  depends_on = [
    aws_api_gateway_integration.cache_organizations_integration
  ]
}

resource "aws_api_gateway_integration_response" "cache_v2_organizations_id_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_cache_test.id
  resource_id = aws_api_gateway_resource.cache_v2_organizations_id.id
  http_method = aws_api_gateway_method.cache_v2_organizations_id_get.http_method
  status_code = aws_api_gateway_method_response.cache_v2_organizations_id_get.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }

  depends_on = [
    aws_api_gateway_integration.cache_v2_organizations_id_integration
  ]
}

resource "aws_api_gateway_integration_response" "cache_organizations_id_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_cache_test.id
  resource_id = aws_api_gateway_resource.cache_organizations_id.id
  http_method = aws_api_gateway_method.cache_organizations_id_get.http_method
  status_code = aws_api_gateway_method_response.cache_organizations_id_get.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }

  depends_on = [
    aws_api_gateway_integration.cache_organizations_id_integration
  ]
}

resource "aws_api_gateway_integration_response" "cache_v1_heartbeat_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_cache_test.id
  resource_id = aws_api_gateway_resource.cache_v1_heartbeat.id
  http_method = aws_api_gateway_method.cache_v1_heartbeat_get.http_method
  status_code = aws_api_gateway_method_response.cache_v1_heartbeat_get.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }

  depends_on = [
    aws_api_gateway_integration.cache_v1_heartbeat_integration
  ]
}

resource "aws_api_gateway_integration_response" "cache_v2_heartbeat_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_cache_test.id
  resource_id = aws_api_gateway_resource.cache_v2_heartbeat.id
  http_method = aws_api_gateway_method.cache_v2_heartbeat_get.http_method
  status_code = aws_api_gateway_method_response.cache_v2_heartbeat_get.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }

  depends_on = [
    aws_api_gateway_integration.cache_v2_heartbeat_integration
  ]
}

# Deployment for cache test
resource "aws_api_gateway_deployment" "api_gateway_cache_test" {
  depends_on = [
    aws_api_gateway_integration.cache_v1_organizations_integration,
    aws_api_gateway_integration.cache_v1_organizations_id_integration,
    aws_api_gateway_integration.cache_v2_organizations_integration,
    aws_api_gateway_integration.cache_organizations_integration,
    aws_api_gateway_integration.cache_v2_organizations_id_integration,
    aws_api_gateway_integration.cache_organizations_id_integration,
    aws_api_gateway_integration.cache_v1_heartbeat_integration,
    aws_api_gateway_integration.cache_v2_heartbeat_integration,
    aws_api_gateway_integration_response.cache_v1_organizations_integration,
    aws_api_gateway_integration_response.cache_v1_organizations_id_integration,
    aws_api_gateway_integration_response.cache_v2_organizations_integration,
    aws_api_gateway_integration_response.cache_organizations_integration,
    aws_api_gateway_integration_response.cache_v2_organizations_id_integration,
    aws_api_gateway_integration_response.cache_organizations_id_integration,
    aws_api_gateway_integration_response.cache_v1_heartbeat_integration,
    aws_api_gateway_integration_response.cache_v2_heartbeat_integration,
  ]

  rest_api_id = aws_api_gateway_rest_api.api_gateway_cache_test.id
  
  variables = {
    deployed_at = timestamp()
    force_update = "true"
  }
  
  lifecycle {
    create_before_destroy = true
  }
}

# API Gateway Custom Domain Name for cache test
resource "aws_api_gateway_domain_name" "api_gateway_cache_test" {
  domain_name = "api-gateway-cache-test.dev.ror.org"
  
  regional_certificate_arn = data.aws_acm_certificate.ror.arn
  
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# Base path mapping for API Gateway cache test custom domain
resource "aws_api_gateway_base_path_mapping" "api_gateway_cache_test" {
  api_id      = aws_api_gateway_rest_api.api_gateway_cache_test.id
  stage_name  = aws_api_gateway_stage.api_gateway_cache_test.stage_name
  domain_name = aws_api_gateway_domain_name.api_gateway_cache_test.domain_name
  
  depends_on = [
    aws_api_gateway_stage.api_gateway_cache_test
  ]
}

# Route53 record for API Gateway cache test custom domain
resource "aws_route53_record" "api_gateway_cache_test" {
    zone_id = data.aws_route53_zone.public.zone_id
    name    = "api-gateway-cache-test.dev.ror.org"
    type    = "A"
    
    alias {
        name = aws_api_gateway_domain_name.api_gateway_cache_test.regional_domain_name
        zone_id = aws_api_gateway_domain_name.api_gateway_cache_test.regional_zone_id
        evaluate_target_health = false
    }
    
    lifecycle {
        create_before_destroy = true
    }
}

# WAF Association for API Gateway cache test service
resource "aws_wafv2_web_acl_association" "api_gateway_cache_test" {
  resource_arn = "${aws_api_gateway_rest_api.api_gateway_cache_test.arn}/stages/${aws_api_gateway_stage.api_gateway_cache_test.stage_name}"
  web_acl_arn  = data.aws_wafv2_web_acl.dev-v2.arn
  
  depends_on = [
    aws_api_gateway_stage.api_gateway_cache_test
  ]
}