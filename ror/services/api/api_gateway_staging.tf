# =============================================================================
# API GATEWAY CACHING ENDPOINT - STAGING
# =============================================================================

# API Gateway REST API with caching enabled
resource "aws_api_gateway_rest_api" "api_gateway_staging" {
  name = "ror-api-staging"
  description = "ROR API Gateway with caching - staging environment"
  
  endpoint_configuration {
    types = ["REGIONAL"]
  }
  
  tags = {
    environment = "api-gateway-staging"
  }
}

# Data sources for access logging ARN construction
data "aws_region" "current_staging" {}
data "aws_caller_identity" "current_staging" {}

# API Gateway Stage (method-level caching only)
resource "aws_api_gateway_stage" "api_gateway_staging" {
  deployment_id = aws_api_gateway_deployment.api_gateway_staging.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_staging.id
  stage_name    = "staging"
  
  # Enable caching for this stage
  cache_cluster_enabled = true
  cache_cluster_size    = "0.5"  # 0.5GB cache size
  
  # Access logging configuration
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway_access_logs_staging.arn
    format = "$context.requestId $context.requestTime $context.httpMethod $context.path $context.resourcePath $context.status $context.responseLatency $context.integrationLatency"
  }
  
  tags = {
    environment = "ror-staging"
    purpose = "api-gateway-caching"
  }
}

# =============================================================================
# METHOD SETTINGS FOR CACHING
# =============================================================================

# Enable caching for v1/organizations endpoint
resource "aws_api_gateway_method_settings" "v1_organizations_cache_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_staging.id
  stage_name  = aws_api_gateway_stage.api_gateway_staging.stage_name
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
resource "aws_api_gateway_method_settings" "v2_organizations_cache_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_staging.id
  stage_name  = aws_api_gateway_stage.api_gateway_staging.stage_name
  method_path = "v2/organizations/GET"

  depends_on = [
    aws_api_gateway_method_settings.v1_organizations_cache_staging
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
resource "aws_api_gateway_method_settings" "organizations_cache_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_staging.id
  stage_name  = aws_api_gateway_stage.api_gateway_staging.stage_name
  method_path = "organizations/GET"

  depends_on = [
    aws_api_gateway_method_settings.v2_organizations_cache_staging
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
resource "aws_api_gateway_method_settings" "v1_organizations_id_cache_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_staging.id
  stage_name  = aws_api_gateway_stage.api_gateway_staging.stage_name
  method_path = "v1/organizations/*/GET"

  depends_on = [
    aws_api_gateway_method_settings.organizations_cache_staging
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
resource "aws_api_gateway_method_settings" "v2_organizations_id_cache_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_staging.id
  stage_name  = aws_api_gateway_stage.api_gateway_staging.stage_name
  method_path = "v2/organizations/*/GET"

  depends_on = [
    aws_api_gateway_method_settings.v1_organizations_id_cache_staging
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
resource "aws_api_gateway_method_settings" "organizations_id_cache_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_staging.id
  stage_name  = aws_api_gateway_stage.api_gateway_staging.stage_name
  method_path = "organizations/*/GET"

  depends_on = [
    aws_api_gateway_method_settings.v2_organizations_id_cache_staging
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
resource "aws_api_gateway_method_settings" "v1_heartbeat_no_cache_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_staging.id
  stage_name  = aws_api_gateway_stage.api_gateway_staging.stage_name
  method_path = "v1/heartbeat/GET"

  depends_on = [
    aws_api_gateway_method_settings.organizations_id_cache_staging
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
resource "aws_api_gateway_method_settings" "v2_heartbeat_no_cache_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_staging.id
  stage_name  = aws_api_gateway_stage.api_gateway_staging.stage_name
  method_path = "v2/heartbeat/GET"

  depends_on = [
    aws_api_gateway_method_settings.v1_heartbeat_no_cache_staging
  ]

  settings {
    caching_enabled        = false
    cache_ttl_in_seconds   = 0
    cache_data_encrypted   = false
    throttling_rate_limit  = 10000
    throttling_burst_limit = 5000
  }
}

# Enable CloudWatch metrics and execution logging for all methods
resource "aws_api_gateway_method_settings" "metrics_and_logging_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_staging.id
  stage_name  = aws_api_gateway_stage.api_gateway_staging.stage_name
  method_path = "*/*"  # Apply to all methods

  depends_on = [
    aws_api_gateway_method_settings.v2_heartbeat_no_cache_staging,
    aws_api_gateway_account.api_gateway_account
  ]

  settings {
    metrics_enabled             = true
    logging_level               = "INFO"
    data_trace_enabled         = true
    throttling_rate_limit       = 10000
    throttling_burst_limit      = 5000
  }
}

# API Gateway Usage Plan with caching
resource "aws_api_gateway_usage_plan" "api_gateway_staging" {
  name = "api-gateway-usage-plan-staging"
  description = "Usage plan for ROR API Gateway with caching - staging"
  
  api_stages {
    api_id = aws_api_gateway_rest_api.api_gateway_staging.id
    stage  = aws_api_gateway_stage.api_gateway_staging.stage_name
  }
  
  tags = {
    environment = "ror-staging"
    purpose = "api-gateway-caching"
  }
}

# =============================================================================
# INDIVIDUAL ENDPOINT RESOURCES
# =============================================================================

# v1 resource
resource "aws_api_gateway_resource" "v1_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_staging.id
  parent_id   = aws_api_gateway_rest_api.api_gateway_staging.root_resource_id
  path_part   = "v1"
}

# v2 resource
resource "aws_api_gateway_resource" "v2_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_staging.id
  parent_id   = aws_api_gateway_rest_api.api_gateway_staging.root_resource_id
  path_part   = "v2"
}

# v1/organizations resource
resource "aws_api_gateway_resource" "v1_organizations_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_staging.id
  parent_id   = aws_api_gateway_resource.v1_staging.id
  path_part   = "organizations"
}

# v2/organizations resource
resource "aws_api_gateway_resource" "v2_organizations_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_staging.id
  parent_id   = aws_api_gateway_resource.v2_staging.id
  path_part   = "organizations"
}

# v1/organizations/{id} resource
resource "aws_api_gateway_resource" "v1_organizations_id_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_staging.id
  parent_id   = aws_api_gateway_resource.v1_organizations_staging.id
  path_part   = "{id}"
}

# v2/organizations/{id} resource
resource "aws_api_gateway_resource" "v2_organizations_id_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_staging.id
  parent_id   = aws_api_gateway_resource.v2_organizations_staging.id
  path_part   = "{id}"
}

# v1/heartbeat resource
resource "aws_api_gateway_resource" "v1_heartbeat_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_staging.id
  parent_id   = aws_api_gateway_resource.v1_staging.id
  path_part   = "heartbeat"
}

# v2/heartbeat resource
resource "aws_api_gateway_resource" "v2_heartbeat_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_staging.id
  parent_id   = aws_api_gateway_resource.v2_staging.id
  path_part   = "heartbeat"
}

# Default organizations resource (maps to v2)
resource "aws_api_gateway_resource" "organizations_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_staging.id
  parent_id   = aws_api_gateway_rest_api.api_gateway_staging.root_resource_id
  path_part   = "organizations"
}

# Default organizations/{id} resource (maps to v2)
resource "aws_api_gateway_resource" "organizations_id_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_staging.id
  parent_id   = aws_api_gateway_resource.organizations_staging.id
  path_part   = "{id}"
}

# Root path resource for base URL
resource "aws_api_gateway_method" "root_get_staging" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_staging.id
  resource_id   = aws_api_gateway_rest_api.api_gateway_staging.root_resource_id
  http_method   = "GET"
  authorization = "NONE"
}

# Root path method response
resource "aws_api_gateway_method_response" "root_get_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_staging.id
  resource_id = aws_api_gateway_rest_api.api_gateway_staging.root_resource_id
  http_method = aws_api_gateway_method.root_get_staging.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Content-Type" = true
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

# Root path integration (mock integration to return static JSON)
resource "aws_api_gateway_integration" "root_get_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_staging.id
  resource_id = aws_api_gateway_rest_api.api_gateway_staging.root_resource_id
  http_method = aws_api_gateway_method.root_get_staging.http_method

  type = "MOCK"
  
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# Root path integration response
resource "aws_api_gateway_integration_response" "root_get_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_staging.id
  resource_id = aws_api_gateway_rest_api.api_gateway_staging.root_resource_id
  http_method = aws_api_gateway_method.root_get_staging.http_method
  status_code = aws_api_gateway_method_response.root_get_staging.status_code

  response_parameters = {
    "method.response.header.Content-Type" = "'application/json'"
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  response_templates = {
    "application/json" = "{\"organizations\":\"https://api.staging.ror.org/v2/organizations\"}"
  }

  depends_on = [
    aws_api_gateway_integration.root_get_staging
  ]
}

# Catch-all proxy resource for all other endpoints
resource "aws_api_gateway_resource" "proxy_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_staging.id
  parent_id   = aws_api_gateway_rest_api.api_gateway_staging.root_resource_id
  path_part   = "{proxy+}"
}

# =============================================================================
# METHODS
# =============================================================================

# GET method for v2/organizations/{id}
resource "aws_api_gateway_method" "v2_organizations_id_get_staging" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_staging.id
  resource_id   = aws_api_gateway_resource.v2_organizations_id_staging.id
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
resource "aws_api_gateway_method_response" "v2_organizations_id_get_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_staging.id
  resource_id = aws_api_gateway_resource.v2_organizations_id_staging.id
  http_method = aws_api_gateway_method.v2_organizations_id_get_staging.http_method
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
resource "aws_api_gateway_integration" "v2_organizations_id_get_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_staging.id
  resource_id = aws_api_gateway_resource.v2_organizations_id_staging.id
  http_method = aws_api_gateway_method.v2_organizations_id_get_staging.http_method

  type                    = "HTTP"
  integration_http_method = "GET"
  uri                     = "http://${data.aws_lb.alb-staging.dns_name}/v2/organizations/{id}"

  request_parameters = {
    "integration.request.path.id" = "method.request.path.id"
    "integration.request.header.Host" = "'api.staging.ror.org'"
  }

  # Caching configuration
  cache_key_parameters = ["method.request.path.id"]
  cache_namespace     = "v2-organizations-id-staging"
}

# =============================================================================
# API GATEWAY METHODS FOR ALL ENDPOINTS
# =============================================================================

# v1/organizations GET method
resource "aws_api_gateway_method" "v1_organizations_get_staging" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_staging.id
  resource_id   = aws_api_gateway_resource.v1_organizations_staging.id
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
resource "aws_api_gateway_method" "v2_organizations_get_staging" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_staging.id
  resource_id   = aws_api_gateway_resource.v2_organizations_staging.id
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
resource "aws_api_gateway_method" "v1_organizations_id_get_staging" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_staging.id
  resource_id   = aws_api_gateway_resource.v1_organizations_id_staging.id
  http_method   = "GET"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.id" = true
  }
}

# v1/heartbeat GET method
resource "aws_api_gateway_method" "v1_heartbeat_get_staging" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_staging.id
  resource_id   = aws_api_gateway_resource.v1_heartbeat_staging.id
  http_method   = "GET"
  authorization = "NONE"
}

# v2/heartbeat GET method
resource "aws_api_gateway_method" "v2_heartbeat_get_staging" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_staging.id
  resource_id   = aws_api_gateway_resource.v2_heartbeat_staging.id
  http_method   = "GET"
  authorization = "NONE"
}

# organizations GET method (no version)
resource "aws_api_gateway_method" "organizations_get_staging" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_staging.id
  resource_id   = aws_api_gateway_resource.organizations_staging.id
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
resource "aws_api_gateway_method" "organizations_id_get_staging" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_staging.id
  resource_id   = aws_api_gateway_resource.organizations_id_staging.id
  http_method   = "GET"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.id" = true
  }
}

# Catch-all proxy method for all HTTP methods
resource "aws_api_gateway_method" "proxy_staging" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_staging.id
  resource_id   = aws_api_gateway_resource.proxy_staging.id
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
resource "aws_api_gateway_method_response" "v1_organizations_get_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_staging.id
  resource_id = aws_api_gateway_resource.v1_organizations_staging.id
  http_method = aws_api_gateway_method.v1_organizations_get_staging.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

# Method response for v2/organizations
resource "aws_api_gateway_method_response" "v2_organizations_get_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_staging.id
  resource_id = aws_api_gateway_resource.v2_organizations_staging.id
  http_method = aws_api_gateway_method.v2_organizations_get_staging.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

# Method response for v1/organizations/{id}
resource "aws_api_gateway_method_response" "v1_organizations_id_get_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_staging.id
  resource_id = aws_api_gateway_resource.v1_organizations_id_staging.id
  http_method = aws_api_gateway_method.v1_organizations_id_get_staging.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

# Method response for v1/heartbeat
resource "aws_api_gateway_method_response" "v1_heartbeat_get_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_staging.id
  resource_id = aws_api_gateway_resource.v1_heartbeat_staging.id
  http_method = aws_api_gateway_method.v1_heartbeat_get_staging.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

# Method response for v2/heartbeat
resource "aws_api_gateway_method_response" "v2_heartbeat_get_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_staging.id
  resource_id = aws_api_gateway_resource.v2_heartbeat_staging.id
  http_method = aws_api_gateway_method.v2_heartbeat_get_staging.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

# Method response for organizations (no version)
resource "aws_api_gateway_method_response" "organizations_get_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_staging.id
  resource_id = aws_api_gateway_resource.organizations_staging.id
  http_method = aws_api_gateway_method.organizations_get_staging.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

# Method response for organizations/{id} (no version)
resource "aws_api_gateway_method_response" "organizations_id_get_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_staging.id
  resource_id = aws_api_gateway_resource.organizations_id_staging.id
  http_method = aws_api_gateway_method.organizations_id_get_staging.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

# Method response for catch-all proxy
resource "aws_api_gateway_method_response" "proxy_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_staging.id
  resource_id = aws_api_gateway_resource.proxy_staging.id
  http_method = aws_api_gateway_method.proxy_staging.http_method
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
resource "aws_api_gateway_integration" "v1_organizations_get_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_staging.id
  resource_id = aws_api_gateway_resource.v1_organizations_staging.id
  http_method = aws_api_gateway_method.v1_organizations_get_staging.http_method

  integration_http_method = "GET"
  type                    = "HTTP"
  uri                     = "http://${data.aws_lb.alb-staging.dns_name}/v1/organizations"

  request_parameters = {
    "integration.request.querystring.page" = "method.request.querystring.page"
    "integration.request.querystring.query" = "method.request.querystring.query"
    "integration.request.querystring.affiliation" = "method.request.querystring.affiliation"
    "integration.request.querystring.filter" = "method.request.querystring.filter"
    "integration.request.querystring.format" = "method.request.querystring.format"
    "integration.request.querystring.query.name" = "method.request.querystring.query.name"
    "integration.request.querystring.query.names" = "method.request.querystring.query.names"
    "integration.request.header.Host" = "'api.staging.ror.org'"
  }

  # Caching configuration - include affiliation and filter for better cache differentiation
  cache_key_parameters = ["method.request.querystring.page", "method.request.querystring.query", "method.request.querystring.affiliation", "method.request.querystring.filter"]
  cache_namespace     = "v1-organizations-staging"
}

# Integration for v2/organizations
resource "aws_api_gateway_integration" "v2_organizations_get_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_staging.id
  resource_id = aws_api_gateway_resource.v2_organizations_staging.id
  http_method = aws_api_gateway_method.v2_organizations_get_staging.http_method

  integration_http_method = "GET"
  type                    = "HTTP"
  uri                     = "http://${data.aws_lb.alb-staging.dns_name}/v2/organizations"

  request_parameters = {
    "integration.request.querystring.page" = "method.request.querystring.page"
    "integration.request.querystring.query" = "method.request.querystring.query"
    "integration.request.querystring.affiliation" = "method.request.querystring.affiliation"
    "integration.request.querystring.filter" = "method.request.querystring.filter"
    "integration.request.querystring.format" = "method.request.querystring.format"
    "integration.request.querystring.query.name" = "method.request.querystring.query.name"
    "integration.request.querystring.query.names" = "method.request.querystring.query.names"
    "integration.request.header.Host" = "'api.staging.ror.org'"
  }

  # Caching configuration - include affiliation and filter for better cache differentiation
  cache_key_parameters = ["method.request.querystring.page", "method.request.querystring.query", "method.request.querystring.affiliation", "method.request.querystring.filter"]
  cache_namespace     = "v2-organizations-staging"
}

# Integration for v1/organizations/{id}
resource "aws_api_gateway_integration" "v1_organizations_id_get_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_staging.id
  resource_id = aws_api_gateway_resource.v1_organizations_id_staging.id
  http_method = aws_api_gateway_method.v1_organizations_id_get_staging.http_method

  integration_http_method = "GET"
  type                    = "HTTP"
  uri                     = "http://${data.aws_lb.alb-staging.dns_name}/v1/organizations/{id}"

  request_parameters = {
    "integration.request.path.id" = "method.request.path.id"
    "integration.request.header.Host" = "'api.staging.ror.org'"
  }

  # Caching configuration
  cache_key_parameters = ["method.request.path.id"]
  cache_namespace     = "v1-organizations-id-staging"
}

# Integration for v1/heartbeat
resource "aws_api_gateway_integration" "v1_heartbeat_get_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_staging.id
  resource_id = aws_api_gateway_resource.v1_heartbeat_staging.id
  http_method = aws_api_gateway_method.v1_heartbeat_get_staging.http_method

  integration_http_method = "GET"
  type                    = "HTTP"
  uri                     = "http://${data.aws_lb.alb-staging.dns_name}/v1/heartbeat"

  request_parameters = {
    "integration.request.header.Host" = "'api.staging.ror.org'"
  }

  # No caching for heartbeat
}

# Integration for v2/heartbeat
resource "aws_api_gateway_integration" "v2_heartbeat_get_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_staging.id
  resource_id = aws_api_gateway_resource.v2_heartbeat_staging.id
  http_method = aws_api_gateway_method.v2_heartbeat_get_staging.http_method

  integration_http_method = "GET"
  type                    = "HTTP"
  uri                     = "http://${data.aws_lb.alb-staging.dns_name}/v2/heartbeat"

  request_parameters = {
    "integration.request.header.Host" = "'api.staging.ror.org'"
  }

  # No caching for heartbeat
}

# Integration for organizations (no version)
resource "aws_api_gateway_integration" "organizations_get_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_staging.id
  resource_id = aws_api_gateway_resource.organizations_staging.id
  http_method = aws_api_gateway_method.organizations_get_staging.http_method

  integration_http_method = "GET"
  type                    = "HTTP"
  uri                     = "http://${data.aws_lb.alb-staging.dns_name}/organizations"

  request_parameters = {
    "integration.request.querystring.page" = "method.request.querystring.page"
    "integration.request.querystring.query" = "method.request.querystring.query"
    "integration.request.querystring.affiliation" = "method.request.querystring.affiliation"
    "integration.request.querystring.filter" = "method.request.querystring.filter"
    "integration.request.querystring.format" = "method.request.querystring.format"
    "integration.request.querystring.query.name" = "method.request.querystring.query.name"
    "integration.request.querystring.query.names" = "method.request.querystring.query.names"
    "integration.request.header.Host" = "'api.staging.ror.org'"
  }

  # Caching configuration
  cache_key_parameters = ["method.request.querystring.page", "method.request.querystring.query", "method.request.querystring.affiliation", "method.request.querystring.filter"]
  cache_namespace     = "organizations-staging"
}

# Integration for organizations/{id} (no version)
resource "aws_api_gateway_integration" "organizations_id_get_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_staging.id
  resource_id = aws_api_gateway_resource.organizations_id_staging.id
  http_method = aws_api_gateway_method.organizations_id_get_staging.http_method

  integration_http_method = "GET"
  type                    = "HTTP"
  uri                     = "http://${data.aws_lb.alb-staging.dns_name}/organizations/{id}"

  request_parameters = {
    "integration.request.path.id" = "method.request.path.id"
    "integration.request.header.Host" = "'api.staging.ror.org'"
  }

  # Caching configuration
  cache_key_parameters = ["method.request.path.id"]
  cache_namespace     = "organizations-id-staging"
}

# Catch-all HTTP_PROXY integration - passes through all headers and methods
resource "aws_api_gateway_integration" "proxy_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_staging.id
  resource_id = aws_api_gateway_resource.proxy_staging.id
  http_method = aws_api_gateway_method.proxy_staging.http_method

  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "http://${data.aws_lb.alb-staging.dns_name}/{proxy}"

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
    "integration.request.header.Host" = "'api.staging.ror.org'"
  }
}

# =============================================================================
# INTEGRATION RESPONSES FOR ALL ENDPOINTS
# =============================================================================

# Integration response for v1/organizations
resource "aws_api_gateway_integration_response" "v1_organizations_get_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_staging.id
  resource_id = aws_api_gateway_resource.v1_organizations_staging.id
  http_method = aws_api_gateway_method.v1_organizations_get_staging.http_method
  status_code = aws_api_gateway_method_response.v1_organizations_get_staging.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }

  depends_on = [
    aws_api_gateway_integration.v1_organizations_get_staging
  ]
}

# Integration response for v2/organizations
resource "aws_api_gateway_integration_response" "v2_organizations_get_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_staging.id
  resource_id = aws_api_gateway_resource.v2_organizations_staging.id
  http_method = aws_api_gateway_method.v2_organizations_get_staging.http_method
  status_code = aws_api_gateway_method_response.v2_organizations_get_staging.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }

  depends_on = [
    aws_api_gateway_integration.v2_organizations_get_staging
  ]
}

# Integration response for v1/organizations/{id}
resource "aws_api_gateway_integration_response" "v1_organizations_id_get_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_staging.id
  resource_id = aws_api_gateway_resource.v1_organizations_id_staging.id
  http_method = aws_api_gateway_method.v1_organizations_id_get_staging.http_method
  status_code = aws_api_gateway_method_response.v1_organizations_id_get_staging.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }

  depends_on = [
    aws_api_gateway_integration.v1_organizations_id_get_staging
  ]
}

# Integration response for v2/organizations/{id}
resource "aws_api_gateway_integration_response" "v2_organizations_id_get_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_staging.id
  resource_id = aws_api_gateway_resource.v2_organizations_id_staging.id
  http_method = aws_api_gateway_method.v2_organizations_id_get_staging.http_method
  status_code = aws_api_gateway_method_response.v2_organizations_id_get_staging.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }

  depends_on = [
    aws_api_gateway_integration.v2_organizations_id_get_staging
  ]
}

# Integration response for v1/heartbeat
resource "aws_api_gateway_integration_response" "v1_heartbeat_get_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_staging.id
  resource_id = aws_api_gateway_resource.v1_heartbeat_staging.id
  http_method = aws_api_gateway_method.v1_heartbeat_get_staging.http_method
  status_code = aws_api_gateway_method_response.v1_heartbeat_get_staging.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }

  depends_on = [
    aws_api_gateway_integration.v1_heartbeat_get_staging
  ]
}

# Integration response for v2/heartbeat
resource "aws_api_gateway_integration_response" "v2_heartbeat_get_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_staging.id
  resource_id = aws_api_gateway_resource.v2_heartbeat_staging.id
  http_method = aws_api_gateway_method.v2_heartbeat_get_staging.http_method
  status_code = aws_api_gateway_method_response.v2_heartbeat_get_staging.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }

  depends_on = [
    aws_api_gateway_integration.v2_heartbeat_get_staging
  ]
}

# Integration response for organizations (no version)
resource "aws_api_gateway_integration_response" "organizations_get_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_staging.id
  resource_id = aws_api_gateway_resource.organizations_staging.id
  http_method = aws_api_gateway_method.organizations_get_staging.http_method
  status_code = aws_api_gateway_method_response.organizations_get_staging.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }

  depends_on = [
    aws_api_gateway_integration.organizations_get_staging
  ]
}

# Integration response for organizations/{id} (no version)
resource "aws_api_gateway_integration_response" "organizations_id_get_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_staging.id
  resource_id = aws_api_gateway_resource.organizations_id_staging.id
  http_method = aws_api_gateway_method.organizations_id_get_staging.http_method
  status_code = aws_api_gateway_method_response.organizations_id_get_staging.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }

  depends_on = [
    aws_api_gateway_integration.organizations_id_get_staging
  ]
}

# Integration response for catch-all proxy
resource "aws_api_gateway_integration_response" "proxy_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_staging.id
  resource_id = aws_api_gateway_resource.proxy_staging.id
  http_method = aws_api_gateway_method.proxy_staging.http_method
  status_code = aws_api_gateway_method_response.proxy_staging.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,Client-Id'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,OPTIONS'"
  }

  depends_on = [
    aws_api_gateway_integration.proxy_staging
  ]
} 
