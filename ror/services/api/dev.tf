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

# Listener rule for API Gateway test service - routes all traffic for api-gateway-test.dev.ror.org
resource "aws_lb_listener_rule" "api_gateway_test_host" {
  listener_arn = data.aws_lb_listener.alb-dev.arn
  priority = 60

  action {
    type = "redirect"

    redirect {
      host        = "api-gateway-test.dev.ror.org"
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_302"
    }
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

# API Gateway REST API
resource "aws_api_gateway_rest_api" "api_gateway_test" {
  name = "ror-api-test"
  description = "ROR API Gateway for testing - updated configuration"
  
  endpoint_configuration {
    types = ["REGIONAL"]
  }
  
  tags = {
    environment = "ror-dev"
    purpose = "testing"
  }
}

# v1 proxy resource - captures everything under /v1/*
resource "aws_api_gateway_resource" "v1_proxy" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  parent_id   = aws_api_gateway_rest_api.api_gateway_test.root_resource_id
  path_part   = "v1"
}

resource "aws_api_gateway_resource" "v1_proxy_catch_all" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  parent_id   = aws_api_gateway_resource.v1_proxy.id
  path_part   = "{proxy+}"
}

# v2 proxy resource - captures everything under /v2/*
resource "aws_api_gateway_resource" "v2_proxy" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  parent_id   = aws_api_gateway_rest_api.api_gateway_test.root_resource_id
  path_part   = "v2"
}

resource "aws_api_gateway_resource" "v2_proxy_catch_all" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  parent_id   = aws_api_gateway_resource.v2_proxy.id
  path_part   = "{proxy+}"
}

# organizations proxy resource - captures everything under /organizations*
resource "aws_api_gateway_resource" "organizations_proxy" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  parent_id   = aws_api_gateway_rest_api.api_gateway_test.root_resource_id
  path_part   = "organizations"
}

resource "aws_api_gateway_resource" "organizations_proxy_catch_all" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  parent_id   = aws_api_gateway_resource.organizations_proxy.id
  path_part   = "{proxy+}"
}

# heartbeat proxy resource - captures everything under /heartbeat*
resource "aws_api_gateway_resource" "heartbeat_proxy" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  parent_id   = aws_api_gateway_rest_api.api_gateway_test.root_resource_id
  path_part   = "heartbeat"
}

resource "aws_api_gateway_resource" "heartbeat_proxy_catch_all" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  parent_id   = aws_api_gateway_resource.heartbeat_proxy.id
  path_part   = "{proxy+}"
}

# GET method for v1/{proxy+}
resource "aws_api_gateway_method" "v1_proxy_get" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id   = aws_api_gateway_resource.v1_proxy_catch_all.id
  http_method   = "GET"
  authorization = "NONE"
  
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

# OPTIONS method for v1/{proxy+} (CORS)
resource "aws_api_gateway_method" "v1_proxy_options" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id   = aws_api_gateway_resource.v1_proxy_catch_all.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# GET method for v2/{proxy+}
resource "aws_api_gateway_method" "v2_proxy_get" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id   = aws_api_gateway_resource.v2_proxy_catch_all.id
  http_method   = "GET"
  authorization = "NONE"
  
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

# OPTIONS method for v2/{proxy+} (CORS)
resource "aws_api_gateway_method" "v2_proxy_options" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id   = aws_api_gateway_resource.v2_proxy_catch_all.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# GET method for organizations/{proxy+}
resource "aws_api_gateway_method" "organizations_proxy_get" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id   = aws_api_gateway_resource.organizations_proxy_catch_all.id
  http_method   = "GET"
  authorization = "NONE"
  
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

# OPTIONS method for organizations/{proxy+} (CORS)
resource "aws_api_gateway_method" "organizations_proxy_options" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id   = aws_api_gateway_resource.organizations_proxy_catch_all.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# GET method for heartbeat/{proxy+}
resource "aws_api_gateway_method" "heartbeat_proxy_get" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id   = aws_api_gateway_resource.heartbeat_proxy_catch_all.id
  http_method   = "GET"
  authorization = "NONE"
  
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

# OPTIONS method for heartbeat/{proxy+} (CORS)
resource "aws_api_gateway_method" "heartbeat_proxy_options" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id   = aws_api_gateway_resource.heartbeat_proxy_catch_all.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# Method responses for all endpoints
resource "aws_api_gateway_method_response" "v1_proxy_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.v1_proxy_catch_all.id
  http_method = aws_api_gateway_method.v1_proxy_get.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

resource "aws_api_gateway_method_response" "v1_proxy_options" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.v1_proxy_catch_all.id
  http_method = aws_api_gateway_method.v1_proxy_options.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

resource "aws_api_gateway_method_response" "v2_proxy_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.v2_proxy_catch_all.id
  http_method = aws_api_gateway_method.v2_proxy_get.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

resource "aws_api_gateway_method_response" "v2_proxy_options" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.v2_proxy_catch_all.id
  http_method = aws_api_gateway_method.v2_proxy_options.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

resource "aws_api_gateway_method_response" "organizations_proxy_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.organizations_proxy_catch_all.id
  http_method = aws_api_gateway_method.organizations_proxy_get.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

resource "aws_api_gateway_method_response" "organizations_proxy_options" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.organizations_proxy_catch_all.id
  http_method = aws_api_gateway_method.organizations_proxy_options.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

resource "aws_api_gateway_method_response" "heartbeat_proxy_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.heartbeat_proxy_catch_all.id
  http_method = aws_api_gateway_method.heartbeat_proxy_get.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

resource "aws_api_gateway_method_response" "heartbeat_proxy_options" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.heartbeat_proxy_catch_all.id
  http_method = aws_api_gateway_method.heartbeat_proxy_options.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

# Integrations for all endpoints
resource "aws_api_gateway_integration" "v1_proxy_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.v1_proxy_catch_all.id
  http_method = aws_api_gateway_method.v1_proxy_get.http_method

  type                    = "HTTP_PROXY"
  integration_http_method = "GET"
  uri                     = "http://api-gateway-test.internal/v1/{proxy}"
  
  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
    "integration.request.header.Host" = "'api-gateway-test.internal'"
  }
}

resource "aws_api_gateway_integration" "v1_proxy_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.v1_proxy_catch_all.id
  http_method = aws_api_gateway_method.v1_proxy_options.http_method

  type = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration" "v2_proxy_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.v2_proxy_catch_all.id
  http_method = aws_api_gateway_method.v2_proxy_get.http_method

  type                    = "HTTP_PROXY"
  integration_http_method = "GET"
  uri                     = "http://api-gateway-test.internal/v2/{proxy}"
  
  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
    "integration.request.header.Host" = "'api-gateway-test.internal'"
  }
}

resource "aws_api_gateway_integration" "v2_proxy_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.v2_proxy_catch_all.id
  http_method = aws_api_gateway_method.v2_proxy_options.http_method

  type = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration" "organizations_proxy_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.organizations_proxy_catch_all.id
  http_method = aws_api_gateway_method.organizations_proxy_get.http_method

  type                    = "HTTP_PROXY"
  integration_http_method = "GET"
  uri                     = "http://api-gateway-test.internal/organizations/{proxy}"
  
  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
    "integration.request.header.Host" = "'api-gateway-test.internal'"
  }
}

resource "aws_api_gateway_integration" "organizations_proxy_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.organizations_proxy_catch_all.id
  http_method = aws_api_gateway_method.organizations_proxy_options.http_method

  type = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration" "heartbeat_proxy_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.heartbeat_proxy_catch_all.id
  http_method = aws_api_gateway_method.heartbeat_proxy_get.http_method

  type                    = "HTTP_PROXY"
  integration_http_method = "GET"
  uri                     = "http://api-gateway-test.internal/heartbeat/{proxy}"
  
  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
    "integration.request.header.Host" = "'api-gateway-test.internal'"
  }
}

resource "aws_api_gateway_integration" "heartbeat_proxy_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.heartbeat_proxy_catch_all.id
  http_method = aws_api_gateway_method.heartbeat_proxy_options.http_method

  type = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# Integration responses for all endpoints
resource "aws_api_gateway_integration_response" "v1_proxy_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.v1_proxy_catch_all.id
  http_method = aws_api_gateway_method.v1_proxy_get.http_method
  status_code = aws_api_gateway_method_response.v1_proxy_get.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }
}

resource "aws_api_gateway_integration_response" "v1_proxy_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.v1_proxy_catch_all.id
  http_method = aws_api_gateway_method.v1_proxy_options.http_method
  status_code = aws_api_gateway_method_response.v1_proxy_options.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }
}

resource "aws_api_gateway_integration_response" "v2_proxy_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.v2_proxy_catch_all.id
  http_method = aws_api_gateway_method.v2_proxy_get.http_method
  status_code = aws_api_gateway_method_response.v2_proxy_get.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }
}

resource "aws_api_gateway_integration_response" "v2_proxy_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.v2_proxy_catch_all.id
  http_method = aws_api_gateway_method.v2_proxy_options.http_method
  status_code = aws_api_gateway_method_response.v2_proxy_options.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }
}

resource "aws_api_gateway_integration_response" "organizations_proxy_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.organizations_proxy_catch_all.id
  http_method = aws_api_gateway_method.organizations_proxy_get.http_method
  status_code = aws_api_gateway_method_response.organizations_proxy_get.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }
}

resource "aws_api_gateway_integration_response" "organizations_proxy_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.organizations_proxy_catch_all.id
  http_method = aws_api_gateway_method.organizations_proxy_options.http_method
  status_code = aws_api_gateway_method_response.organizations_proxy_options.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }
}

resource "aws_api_gateway_integration_response" "heartbeat_proxy_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.heartbeat_proxy_catch_all.id
  http_method = aws_api_gateway_method.heartbeat_proxy_get.http_method
  status_code = aws_api_gateway_method_response.heartbeat_proxy_get.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }
}

resource "aws_api_gateway_integration_response" "heartbeat_proxy_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  resource_id = aws_api_gateway_resource.heartbeat_proxy_catch_all.id
  http_method = aws_api_gateway_method.heartbeat_proxy_options.http_method
  status_code = aws_api_gateway_method_response.heartbeat_proxy_options.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }
}

# API Gateway deployment
resource "aws_api_gateway_deployment" "api_gateway_test" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test.id
  stage_name  = "test"
  
  variables = {
    deployed_at = timestamp()
  }
  
  depends_on = [
    aws_api_gateway_integration.v1_proxy_integration,
    aws_api_gateway_integration.v1_proxy_options_integration,
    aws_api_gateway_integration.v2_proxy_integration,
    aws_api_gateway_integration.v2_proxy_options_integration,
    aws_api_gateway_integration.organizations_proxy_integration,
    aws_api_gateway_integration.organizations_proxy_options_integration,
    aws_api_gateway_integration.heartbeat_proxy_integration,
    aws_api_gateway_integration.heartbeat_proxy_options_integration
  ]
  
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

### NEW
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
