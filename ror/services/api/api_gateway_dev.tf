# =============================================================================
# API GATEWAY CACHING ENDPOINT - DEVELOPMENT
# =============================================================================

# Data sources for access logging ARN construction
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# API Gateway REST API with caching enabled - completely reset
resource "aws_api_gateway_rest_api" "api_gateway" {
  name = "ror-api"
  description = "ROR API Gateway with caching - individual endpoints"
  
  endpoint_configuration {
    types = ["REGIONAL"]
  }
  
  tags = {
    environment = "api-gateway"
  }
}

# API Gateway Stage (method-level caching only)
resource "aws_api_gateway_stage" "api_gateway_dev" {
  deployment_id = aws_api_gateway_deployment.api_gateway.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  stage_name    = "dev"
  
  # Enable caching for this stage
  cache_cluster_enabled = true
  cache_cluster_size    = "0.5"  # 0.5GB cache size
  
  # Access logging configuration for cache analytics
  access_log_destination_arn = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/apigateway/ror-api-dev:*"
  access_log_format = jsonencode({
    requestId = "$context.requestId"
    requestTime = "$context.requestTime"
    httpMethod = "$context.httpMethod"
    path = "$context.path"
    status = "$context.status"
    responseTime = "$context.responseTime"
    cacheStatus = "$context.responseType"
    integrationLatency = "$context.integrationLatency"
    responseLength = "$context.responseLength"
    sourceIp = "$context.identity.sourceIp"
    userAgent = "$context.identity.userAgent"
    queryString = "$context.requestQueryString"
    errorMessage = "$context.error.message"
    errorMessageString = "$context.error.messageString"
  })
  
  tags = {
    environment = "ror-dev"
    purpose = "api-gateway-caching"
  }
}

# =============================================================================
# METHOD SETTINGS FOR CACHING
# =============================================================================

# Enable caching for v1/organizations endpoint
resource "aws_api_gateway_method_settings" "v1_organizations_cache" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  stage_name  = aws_api_gateway_stage.api_gateway_dev.stage_name
  method_path = "v1/organizations/GET"

  settings {
    caching_enabled        = true
    cache_ttl_in_seconds   = 300  # 5 minutes cache TTL
    cache_data_encrypted   = false
    throttling_rate_limit  = 10000
    throttling_burst_limit = 5000
  }
}

# Enable caching for v2/organizations endpoint
resource "aws_api_gateway_method_settings" "v2_organizations_cache" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  stage_name  = aws_api_gateway_stage.api_gateway_dev.stage_name
  method_path = "v2/organizations/GET"

  depends_on = [
    aws_api_gateway_method_settings.v1_organizations_cache
  ]

  settings {
    caching_enabled        = true
    cache_ttl_in_seconds   = 300  # 5 minutes cache TTL
    cache_data_encrypted   = false
    throttling_rate_limit  = 10000
    throttling_burst_limit = 5000
  }
}

# Enable caching for organizations endpoint (no version)
resource "aws_api_gateway_method_settings" "organizations_cache" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  stage_name  = aws_api_gateway_stage.api_gateway_dev.stage_name
  method_path = "organizations/GET"

  depends_on = [
    aws_api_gateway_method_settings.v2_organizations_cache
  ]

  settings {
    caching_enabled        = true
    cache_ttl_in_seconds   = 300  # 5 minutes cache TTL
    cache_data_encrypted   = false
    throttling_rate_limit  = 10000
    throttling_burst_limit = 5000
  }
}

# Enable caching for v1/organizations/{id} endpoint
resource "aws_api_gateway_method_settings" "v1_organizations_id_cache" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  stage_name  = aws_api_gateway_stage.api_gateway_dev.stage_name
  method_path = "v1/organizations/*/GET"

  depends_on = [
    aws_api_gateway_method_settings.organizations_cache
  ]

  settings {
    caching_enabled        = true
    cache_ttl_in_seconds   = 300  # 5 minutes cache TTL
    cache_data_encrypted   = false
    throttling_rate_limit  = 10000
    throttling_burst_limit = 5000
  }
}

# Enable caching for v2/organizations/{id} endpoint
resource "aws_api_gateway_method_settings" "v2_organizations_id_cache" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  stage_name  = aws_api_gateway_stage.api_gateway_dev.stage_name
  method_path = "v2/organizations/*/GET"

  depends_on = [
    aws_api_gateway_method_settings.v1_organizations_id_cache
  ]

  settings {
    caching_enabled        = true
    cache_ttl_in_seconds   = 300  # 5 minutes cache TTL
    cache_data_encrypted   = false
    throttling_rate_limit  = 10000
    throttling_burst_limit = 5000
  }
}

# Enable caching for organizations/{id} endpoint (no version)
resource "aws_api_gateway_method_settings" "organizations_id_cache" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  stage_name  = aws_api_gateway_stage.api_gateway_dev.stage_name
  method_path = "organizations/*/GET"

  depends_on = [
    aws_api_gateway_method_settings.v2_organizations_id_cache
  ]

  settings {
    caching_enabled        = true
    cache_ttl_in_seconds   = 300  # 5 minutes cache TTL
    cache_data_encrypted   = false
    throttling_rate_limit  = 10000
    throttling_burst_limit = 5000
  }
}

# Disable caching for v1/heartbeat endpoint
resource "aws_api_gateway_method_settings" "v1_heartbeat_no_cache" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  stage_name  = aws_api_gateway_stage.api_gateway_dev.stage_name
  method_path = "v1/heartbeat/GET"

  depends_on = [
    aws_api_gateway_method_settings.organizations_id_cache
  ]

  settings {
    caching_enabled        = false
    cache_ttl_in_seconds   = 0
    cache_data_encrypted   = false
    throttling_rate_limit  = 10000
    throttling_burst_limit = 5000
  }
}

# Disable caching for v2/heartbeat endpoint
resource "aws_api_gateway_method_settings" "v2_heartbeat_no_cache" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  stage_name  = aws_api_gateway_stage.api_gateway_dev.stage_name
  method_path = "v2/heartbeat/GET"

  depends_on = [
    aws_api_gateway_method_settings.v1_heartbeat_no_cache
  ]

  settings {
    caching_enabled        = false
    cache_ttl_in_seconds   = 0
    cache_data_encrypted   = false
    throttling_rate_limit  = 10000
    throttling_burst_limit = 5000
  }
}

# API Gateway Usage Plan with caching
resource "aws_api_gateway_usage_plan" "api_gateway" {
  name = "api-gateway-usage-plan"
  description = "Usage plan for ROR API Gateway with caching"
  
  api_stages {
    api_id = aws_api_gateway_rest_api.api_gateway.id
    stage  = aws_api_gateway_stage.api_gateway_dev.stage_name
  }
  
  tags = {
    environment = "ror-dev"
    purpose = "api-gateway-caching"
  }
}

# =============================================================================
# INDIVIDUAL ENDPOINT RESOURCES
# =============================================================================

# v1 resource
resource "aws_api_gateway_resource" "v1" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "v1"
}

# v2 resource
resource "aws_api_gateway_resource" "v2" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "v2"
}

# v1/organizations resource
resource "aws_api_gateway_resource" "v1_organizations" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1.id
  path_part   = "organizations"
}

# v2/organizations resource
resource "aws_api_gateway_resource" "v2_organizations" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2.id
  path_part   = "organizations"
}

# v1/organizations/{id} resource
resource "aws_api_gateway_resource" "v1_organizations_id" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_organizations.id
  path_part   = "{id}"
}

# v2/organizations/{id} resource
resource "aws_api_gateway_resource" "v2_organizations_id" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_organizations.id
  path_part   = "{id}"
}

# v1/heartbeat resource
resource "aws_api_gateway_resource" "v1_heartbeat" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1.id
  path_part   = "heartbeat"
}

# v2/heartbeat resource
resource "aws_api_gateway_resource" "v2_heartbeat" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2.id
  path_part   = "heartbeat"
}

# Default organizations resource (maps to v2)
resource "aws_api_gateway_resource" "organizations" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "organizations"
}

# Default organizations/{id} resource (maps to v2)
resource "aws_api_gateway_resource" "organizations_id" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.organizations.id
  path_part   = "{id}"
}

# Catch-all proxy resource for all other endpoints
resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "{proxy+}"
}

# =============================================================================
# METHODS
# =============================================================================

# GET method for v2/organizations/{id}
resource "aws_api_gateway_method" "v2_organizations_id_get" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.v2_organizations_id.id
  http_method   = "GET"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.id" = true
  }
}

# =============================================================================
# METHOD RESPONSES
# =============================================================================

# Method response for v2/organizations/{id}
resource "aws_api_gateway_method_response" "v2_organizations_id_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v2_organizations_id.id
  http_method = aws_api_gateway_method.v2_organizations_id_get.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

# =============================================================================
# INTEGRATIONS
# =============================================================================

# Integration for v2/organizations/{id}
resource "aws_api_gateway_integration" "v2_organizations_id_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v2_organizations_id.id
  http_method = aws_api_gateway_method.v2_organizations_id_get.http_method

  type                    = "HTTP"
  integration_http_method = "GET"
  uri                     = "http://${data.aws_lb.alb-dev.dns_name}/v2/organizations/{id}"

  request_parameters = {
    "integration.request.path.id" = "method.request.path.id"
    "integration.request.header.Host" = "'api.dev.ror.org'"
  }

  # Caching configuration
  cache_key_parameters = ["method.request.path.id"]
  cache_namespace     = "v2-organizations-id"
}

# =============================================================================
# API GATEWAY METHODS FOR ALL ENDPOINTS
# =============================================================================

# v1/organizations GET method
resource "aws_api_gateway_method" "v1_organizations_get" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.v1_organizations.id
  http_method   = "GET"
  authorization = "NONE"

  request_parameters = {
    "method.request.querystring.page" = false
    "method.request.querystring.query" = false
    "method.request.querystring.affiliation" = false
    "method.request.querystring.filter" = false
    "method.request.querystring.format" = false
    "method.request.querystring.query.name" = false
    "method.request.querystring.query.names" = false
  }
}

# v2/organizations GET method
resource "aws_api_gateway_method" "v2_organizations_get" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.v2_organizations.id
  http_method   = "GET"
  authorization = "NONE"

  request_parameters = {
    "method.request.querystring.page" = false
    "method.request.querystring.query" = false
    "method.request.querystring.affiliation" = false
    "method.request.querystring.filter" = false
    "method.request.querystring.format" = false
    "method.request.querystring.query.name" = false
    "method.request.querystring.query.names" = false
  }
}

# v1/organizations/{id} GET method
resource "aws_api_gateway_method" "v1_organizations_id_get" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.v1_organizations_id.id
  http_method   = "GET"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.id" = true
  }
}

# v1/heartbeat GET method
resource "aws_api_gateway_method" "v1_heartbeat_get" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.v1_heartbeat.id
  http_method   = "GET"
  authorization = "NONE"
}

# v2/heartbeat GET method
resource "aws_api_gateway_method" "v2_heartbeat_get" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.v2_heartbeat.id
  http_method   = "GET"
  authorization = "NONE"
}

# organizations GET method (no version)
resource "aws_api_gateway_method" "organizations_get" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.organizations.id
  http_method   = "GET"
  authorization = "NONE"

  request_parameters = {
    "method.request.querystring.page" = false
    "method.request.querystring.query" = false
    "method.request.querystring.affiliation" = false
    "method.request.querystring.filter" = false
    "method.request.querystring.format" = false
    "method.request.querystring.query.name" = false
    "method.request.querystring.query.names" = false
  }
}

# organizations/{id} GET method (no version)
resource "aws_api_gateway_method" "organizations_id_get" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.organizations_id.id
  http_method   = "GET"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.id" = true
  }
}

# Catch-all proxy method for all HTTP methods
resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

# =============================================================================
# API GATEWAY METHOD RESPONSES FOR ALL ENDPOINTS
# =============================================================================

# Method response for v1/organizations
resource "aws_api_gateway_method_response" "v1_organizations_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v1_organizations.id
  http_method = aws_api_gateway_method.v1_organizations_get.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

# Method response for v2/organizations
resource "aws_api_gateway_method_response" "v2_organizations_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v2_organizations.id
  http_method = aws_api_gateway_method.v2_organizations_get.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

# Method response for v1/organizations/{id}
resource "aws_api_gateway_method_response" "v1_organizations_id_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v1_organizations_id.id
  http_method = aws_api_gateway_method.v1_organizations_id_get.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

# Method response for v1/heartbeat
resource "aws_api_gateway_method_response" "v1_heartbeat_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v1_heartbeat.id
  http_method = aws_api_gateway_method.v1_heartbeat_get.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

# Method response for v2/heartbeat
resource "aws_api_gateway_method_response" "v2_heartbeat_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v2_heartbeat.id
  http_method = aws_api_gateway_method.v2_heartbeat_get.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

# Method response for organizations (no version)
resource "aws_api_gateway_method_response" "organizations_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.organizations.id
  http_method = aws_api_gateway_method.organizations_get.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

# Method response for organizations/{id} (no version)
resource "aws_api_gateway_method_response" "organizations_id_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.organizations_id.id
  http_method = aws_api_gateway_method.organizations_id_get.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

# Method response for catch-all proxy
resource "aws_api_gateway_method_response" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.proxy.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

# =============================================================================
# API GATEWAY INTEGRATIONS FOR ALL ENDPOINTS
# =============================================================================

# Integration for v1/organizations
resource "aws_api_gateway_integration" "v1_organizations_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v1_organizations.id
  http_method = aws_api_gateway_method.v1_organizations_get.http_method

  integration_http_method = "GET"
  type                    = "HTTP"
  uri                     = "http://${data.aws_lb.alb-dev.dns_name}/v1/organizations"

  request_parameters = {
    "integration.request.querystring.page" = "method.request.querystring.page"
    "integration.request.querystring.query" = "method.request.querystring.query"
    "integration.request.querystring.affiliation" = "method.request.querystring.affiliation"
    "integration.request.querystring.filter" = "method.request.querystring.filter"
    "integration.request.querystring.format" = "method.request.querystring.format"
    "integration.request.querystring.query.name" = "method.request.querystring.query.name"
    "integration.request.querystring.query.names" = "method.request.querystring.query.names"
    "integration.request.header.Host" = "'api.dev.ror.org'"
  }

  # Caching configuration - include affiliation and filter for better cache differentiation
  cache_key_parameters = ["method.request.querystring.page", "method.request.querystring.query", "method.request.querystring.affiliation", "method.request.querystring.filter"]
  cache_namespace     = "v1-organizations"
}

# Integration for v2/organizations
resource "aws_api_gateway_integration" "v2_organizations_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v2_organizations.id
  http_method = aws_api_gateway_method.v2_organizations_get.http_method

  integration_http_method = "GET"
  type                    = "HTTP"
  uri                     = "http://${data.aws_lb.alb-dev.dns_name}/v2/organizations"

  request_parameters = {
    "integration.request.querystring.page" = "method.request.querystring.page"
    "integration.request.querystring.query" = "method.request.querystring.query"
    "integration.request.querystring.affiliation" = "method.request.querystring.affiliation"
    "integration.request.querystring.filter" = "method.request.querystring.filter"
    "integration.request.querystring.format" = "method.request.querystring.format"
    "integration.request.querystring.query.name" = "method.request.querystring.query.name"
    "integration.request.querystring.query.names" = "method.request.querystring.query.names"
    "integration.request.header.Host" = "'api.dev.ror.org'"
  }

  # Caching configuration - include affiliation and filter for better cache differentiation
  cache_key_parameters = ["method.request.querystring.page", "method.request.querystring.query", "method.request.querystring.affiliation", "method.request.querystring.filter"]
  cache_namespace     = "v2-organizations"
}

# Integration for v1/organizations/{id}
resource "aws_api_gateway_integration" "v1_organizations_id_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v1_organizations_id.id
  http_method = aws_api_gateway_method.v1_organizations_id_get.http_method

  integration_http_method = "GET"
  type                    = "HTTP"
  uri                     = "http://${data.aws_lb.alb-dev.dns_name}/v1/organizations/{id}"

  request_parameters = {
    "integration.request.path.id" = "method.request.path.id"
    "integration.request.header.Host" = "'api.dev.ror.org'"
  }

  # Caching configuration
  cache_key_parameters = ["method.request.path.id"]
  cache_namespace     = "v1-organizations-id"
}

# Integration for v1/heartbeat
resource "aws_api_gateway_integration" "v1_heartbeat_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v1_heartbeat.id
  http_method = aws_api_gateway_method.v1_heartbeat_get.http_method

  integration_http_method = "GET"
  type                    = "HTTP"
  uri                     = "http://${data.aws_lb.alb-dev.dns_name}/v1/heartbeat"

  request_parameters = {
    "integration.request.header.Host" = "'api.dev.ror.org'"
  }

  # No caching for heartbeat
}

# Integration for v2/heartbeat
resource "aws_api_gateway_integration" "v2_heartbeat_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v2_heartbeat.id
  http_method = aws_api_gateway_method.v2_heartbeat_get.http_method

  integration_http_method = "GET"
  type                    = "HTTP"
  uri                     = "http://${data.aws_lb.alb-dev.dns_name}/v2/heartbeat"

  request_parameters = {
    "integration.request.header.Host" = "'api.dev.ror.org'"
  }

  # No caching for heartbeat
}

# Integration for organizations (no version)
resource "aws_api_gateway_integration" "organizations_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.organizations.id
  http_method = aws_api_gateway_method.organizations_get.http_method

  integration_http_method = "GET"
  type                    = "HTTP"
  uri                     = "http://${data.aws_lb.alb-dev.dns_name}/organizations"

  request_parameters = {
    "integration.request.querystring.page" = "method.request.querystring.page"
    "integration.request.querystring.query" = "method.request.querystring.query"
    "integration.request.querystring.affiliation" = "method.request.querystring.affiliation"
    "integration.request.querystring.filter" = "method.request.querystring.filter"
    "integration.request.querystring.format" = "method.request.querystring.format"
    "integration.request.querystring.query.name" = "method.request.querystring.query.name"
    "integration.request.querystring.query.names" = "method.request.querystring.query.names"
    "integration.request.header.Host" = "'api.dev.ror.org'"
  }

  # Caching configuration
  cache_key_parameters = ["method.request.querystring.page", "method.request.querystring.query", "method.request.querystring.affiliation", "method.request.querystring.filter"]
  cache_namespace     = "organizations"
}

# Integration for organizations/{id} (no version)
resource "aws_api_gateway_integration" "organizations_id_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.organizations_id.id
  http_method = aws_api_gateway_method.organizations_id_get.http_method

  integration_http_method = "GET"
  type                    = "HTTP"
  uri                     = "http://${data.aws_lb.alb-dev.dns_name}/organizations/{id}"

  request_parameters = {
    "integration.request.path.id" = "method.request.path.id"
    "integration.request.header.Host" = "'api.dev.ror.org'"
  }

  # Caching configuration
  cache_key_parameters = ["method.request.path.id"]
  cache_namespace     = "organizations-id"
}

# Catch-all HTTP_PROXY integration - passes through all headers and methods
resource "aws_api_gateway_integration" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.proxy.http_method

  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "http://${data.aws_lb.alb-dev.dns_name}/{proxy}"

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
    "integration.request.header.Host" = "'api.dev.ror.org'"
  }
}

# =============================================================================
# INTEGRATION RESPONSES FOR ALL ENDPOINTS
# =============================================================================

# Integration response for v1/organizations
resource "aws_api_gateway_integration_response" "v1_organizations_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v1_organizations.id
  http_method = aws_api_gateway_method.v1_organizations_get.http_method
  status_code = aws_api_gateway_method_response.v1_organizations_get.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }

  depends_on = [
    aws_api_gateway_integration.v1_organizations_get
  ]
}

# Integration response for v2/organizations
resource "aws_api_gateway_integration_response" "v2_organizations_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v2_organizations.id
  http_method = aws_api_gateway_method.v2_organizations_get.http_method
  status_code = aws_api_gateway_method_response.v2_organizations_get.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }

  depends_on = [
    aws_api_gateway_integration.v2_organizations_get
  ]
}

# Integration response for v1/organizations/{id}
resource "aws_api_gateway_integration_response" "v1_organizations_id_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v1_organizations_id.id
  http_method = aws_api_gateway_method.v1_organizations_id_get.http_method
  status_code = aws_api_gateway_method_response.v1_organizations_id_get.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }

  depends_on = [
    aws_api_gateway_integration.v1_organizations_id_get
  ]
}

# Integration response for v2/organizations/{id}
resource "aws_api_gateway_integration_response" "v2_organizations_id_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v2_organizations_id.id
  http_method = aws_api_gateway_method.v2_organizations_id_get.http_method
  status_code = aws_api_gateway_method_response.v2_organizations_id_get.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }

  depends_on = [
    aws_api_gateway_integration.v2_organizations_id_get
  ]
}

# Integration response for v1/heartbeat
resource "aws_api_gateway_integration_response" "v1_heartbeat_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v1_heartbeat.id
  http_method = aws_api_gateway_method.v1_heartbeat_get.http_method
  status_code = aws_api_gateway_method_response.v1_heartbeat_get.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }

  depends_on = [
    aws_api_gateway_integration.v1_heartbeat_get
  ]
}

# Integration response for v2/heartbeat
resource "aws_api_gateway_integration_response" "v2_heartbeat_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v2_heartbeat.id
  http_method = aws_api_gateway_method.v2_heartbeat_get.http_method
  status_code = aws_api_gateway_method_response.v2_heartbeat_get.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }

  depends_on = [
    aws_api_gateway_integration.v2_heartbeat_get
  ]
}

# Integration response for organizations (no version)
resource "aws_api_gateway_integration_response" "organizations_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.organizations.id
  http_method = aws_api_gateway_method.organizations_get.http_method
  status_code = aws_api_gateway_method_response.organizations_get.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }

  depends_on = [
    aws_api_gateway_integration.organizations_get
  ]
}

# Integration response for organizations/{id} (no version)
resource "aws_api_gateway_integration_response" "organizations_id_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.organizations_id.id
  http_method = aws_api_gateway_method.organizations_id_get.http_method
  status_code = aws_api_gateway_method_response.organizations_id_get.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }

  depends_on = [
    aws_api_gateway_integration.organizations_id_get
  ]
}

# Integration response for catch-all proxy
resource "aws_api_gateway_integration_response" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.proxy.http_method
  status_code = aws_api_gateway_method_response.proxy.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,Client-Id'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,OPTIONS'"
  }

  depends_on = [
    aws_api_gateway_integration.proxy
  ]
} 