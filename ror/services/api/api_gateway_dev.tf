# =============================================================================
# API GATEWAY CACHING ENDPOINT - DEVELOPMENT
# =============================================================================

# API Gateway REST API with caching enabled for development
resource "aws_api_gateway_rest_api" "api_gateway_dev" {
  name = "ror-api"
  description = "ROR API Gateway for development with caching"
  
  endpoint_configuration {
    types = ["REGIONAL"]
  }
  
  tags = {
    environment = "ror-dev"
    purpose = "development-with-cache"
  }
}

# API Gateway Stage (method-level caching only)
resource "aws_api_gateway_stage" "api_gateway_dev" {
  deployment_id = aws_api_gateway_deployment.api_gateway_dev.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_dev.id
  stage_name    = "dev"
  
  # Enable caching for this stage
  cache_cluster_enabled = true
  cache_cluster_size    = "0.5"  # 0.5GB cache size
  
  tags = {
    environment = "ror-dev"
    purpose = "api-gateway-caching"
  }
}

# API Gateway Method Settings for caching
resource "aws_api_gateway_method_settings" "api_gateway_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  stage_name  = aws_api_gateway_stage.api_gateway_dev.stage_name
  method_path = "*/*"  # Apply to all methods

  settings {
    # Caching settings - enabled for all methods (heartbeats will be handled by separate method settings)
    caching_enabled        = true
    cache_ttl_in_seconds   = 300  # 5 minutes cache TTL
  }
}

# API Gateway Usage Plan with caching
resource "aws_api_gateway_usage_plan" "api_gateway_dev" {
  name = "api-gateway-dev-usage-plan"
  description = "Usage plan for ROR API Gateway development with caching"
  
  api_stages {
    api_id = aws_api_gateway_rest_api.api_gateway_dev.id
    stage  = aws_api_gateway_stage.api_gateway_dev.stage_name
  }
  
  tags = {
    environment = "ror-dev"
    purpose = "api-gateway-caching"
  }
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  parent_id   = aws_api_gateway_rest_api.api_gateway_dev.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = "ANY"

  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "https://${data.aws_lb.alb-dev.dns_name}/{proxy}"
  passthrough_behavior    = "WHEN_NO_MATCH"
  content_handling        = "CONVERT_TO_TEXT"

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

