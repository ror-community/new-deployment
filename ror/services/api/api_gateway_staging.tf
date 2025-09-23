# =============================================================================
# API GATEWAY STAGING STAGE
# =============================================================================

# API Gateway Stage (staging)
resource "aws_api_gateway_stage" "api_gateway_staging" {
  deployment_id = aws_api_gateway_deployment.api_gateway.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  stage_name    = "staging"
  
  # Enable caching for this stage
  cache_cluster_enabled = true
  cache_cluster_size    = "0.5"  # 0.5GB cache size
  
  # Stage variables for backend routing
  variables = {
    backend_host = "alb.staging.ror.org"
    api_host = "api.staging.ror.org"
  }
  
  # Access logging configuration
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway_access_logs_staging.arn
    format = jsonencode({
      requestId         = "$context.requestId"
      requestTime       = "$context.requestTime"
      httpMethod        = "$context.httpMethod"
      path              = "$context.path"
      resourcePath      = "$context.resourcePath"
      status            = "$context.status"
      responseLatency   = "$context.responseLatency"
      integrationLatency = "$context.integrationLatency"
      stage             = "$context.stage"
      sourceIp          = "$context.identity.sourceIp"
      userAgent         = "$context.identity.userAgent"
      error             = "$context.error.message"
      responseLength    = "$context.responseLength"
      wafStatus         = "$context.waf.status"
      wafResponseCode   = "$context.wafResponseCode"
    })
  }
  
  tags = {
    environment = "ror-staging"
    purpose = "api-gateway-caching"
  }
}

# =============================================================================
# METHOD SETTINGS FOR CACHING - STAGING STAGE
# =============================================================================

# Enable caching for v1/{proxy+} endpoint
resource "aws_api_gateway_method_settings" "v1_proxy_cache_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  stage_name  = aws_api_gateway_stage.api_gateway_staging.stage_name
  method_path = "v1/{proxy+}/GET"

  settings {
    caching_enabled        = true
    cache_ttl_in_seconds   = 300  # 5 minutes cache TTL
    cache_data_encrypted   = false
    
    # Prevent cache bypass from client headers
    require_authorization_for_cache_control = true
    unauthorized_cache_control_header_strategy = "SUCCEED_WITHOUT_RESPONSE_HEADER"
    
    throttling_rate_limit  = 10000
    throttling_burst_limit = 5000
  }
}

# Disable caching for v1/{proxy+} POST requests
resource "aws_api_gateway_method_settings" "v1_proxy_post_no_cache_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  stage_name  = aws_api_gateway_stage.api_gateway_staging.stage_name
  method_path = "v1/{proxy+}/POST"

  settings {
    caching_enabled        = false
    cache_ttl_in_seconds   = 0
    cache_data_encrypted   = false
    
    throttling_rate_limit  = 10000
    throttling_burst_limit = 5000
  }
}

# Enable caching for v2/organizations endpoint
resource "aws_api_gateway_method_settings" "v2_proxy_cache_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  stage_name  = aws_api_gateway_stage.api_gateway_staging.stage_name
  method_path = "v2/{proxy+}/GET"

  depends_on = [
    aws_api_gateway_method_settings.v1_proxy_cache_staging
  ]

  settings {
    caching_enabled        = true
    cache_ttl_in_seconds   = 300  # 5 minutes cache TTL
    cache_data_encrypted   = false
    
    # Prevent cache bypass from client headers
    require_authorization_for_cache_control = true
    unauthorized_cache_control_header_strategy = "SUCCEED_WITHOUT_RESPONSE_HEADER"
    
    throttling_rate_limit  = 10000
    throttling_burst_limit = 5000
  }
}

# Disable caching for v2/{proxy+} POST requests
resource "aws_api_gateway_method_settings" "v2_proxy_post_no_cache_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  stage_name  = aws_api_gateway_stage.api_gateway_staging.stage_name
  method_path = "v2/{proxy+}/POST"

  settings {
    caching_enabled        = false
    cache_ttl_in_seconds   = 0
    cache_data_encrypted   = false
    
    throttling_rate_limit  = 10000
    throttling_burst_limit = 5000
  }
}

# Enable caching for organizations endpoint (no version)
resource "aws_api_gateway_method_settings" "root_proxy_cache_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  stage_name  = aws_api_gateway_stage.api_gateway_staging.stage_name
  method_path = "{proxy+}/GET"

  depends_on = [
    aws_api_gateway_method_settings.v2_proxy_cache_staging
  ]

  settings {
    caching_enabled        = true
    cache_ttl_in_seconds   = 300  # 5 minutes cache TTL
    cache_data_encrypted   = false
    
    # Prevent cache bypass from client headers
    require_authorization_for_cache_control = true
    unauthorized_cache_control_header_strategy = "SUCCEED_WITHOUT_RESPONSE_HEADER"
    
    throttling_rate_limit  = 10000
    throttling_burst_limit = 5000
  }
}

# Disable caching for root /{proxy+} POST requests (versionless)
resource "aws_api_gateway_method_settings" "root_proxy_post_no_cache_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  stage_name  = aws_api_gateway_stage.api_gateway_staging.stage_name
  method_path = "{proxy+}/POST"

  settings {
    caching_enabled        = false
    cache_ttl_in_seconds   = 0
    cache_data_encrypted   = false
    
    throttling_rate_limit  = 10000
    throttling_burst_limit = 5000
  }
}

# Disable caching for root /heartbeat endpoint (versionless)
resource "aws_api_gateway_method_settings" "heartbeat_no_cache_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  stage_name  = aws_api_gateway_stage.api_gateway_staging.stage_name
  method_path = "heartbeat/GET"

  depends_on = [
    aws_api_gateway_method_settings.root_proxy_cache_staging
  ]

  settings {
    caching_enabled        = false
    cache_ttl_in_seconds   = 0
    cache_data_encrypted   = false
    
    throttling_rate_limit  = 10000
    throttling_burst_limit = 5000
  }
}

# Disable caching for v1/heartbeat endpoint
resource "aws_api_gateway_method_settings" "v1_heartbeat_no_cache_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  stage_name  = aws_api_gateway_stage.api_gateway_staging.stage_name
  method_path = "v1/heartbeat/GET"

  depends_on = [
    aws_api_gateway_method_settings.heartbeat_no_cache_staging
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
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
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
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  stage_name  = aws_api_gateway_stage.api_gateway_staging.stage_name
  method_path = "*/*"  # Apply to all methods

  depends_on = [
    aws_api_gateway_method_settings.v2_heartbeat_no_cache_staging,
    aws_api_gateway_account.api_gateway_account
  ]

  settings {
    metrics_enabled             = true
    logging_level               = "ERROR"
    data_trace_enabled         = false
    throttling_rate_limit       = 10000
    throttling_burst_limit      = 5000
  }
}

# =============================================================================
# CORS CONFIGURATION FOR STAGING STAGE
# =============================================================================

# OPTIONS method for v1/{proxy+} - CORS preflight
resource "aws_api_gateway_method" "v1_proxy_options_staging" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.v1_proxy.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# OPTIONS method for v2/{proxy+} - CORS preflight
resource "aws_api_gateway_method" "v2_proxy_options_staging" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.v2_proxy.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# OPTIONS method for root /{proxy+} - CORS preflight
resource "aws_api_gateway_method" "root_proxy_options_staging" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.root_proxy.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# OPTIONS method for v1/heartbeat - CORS preflight
resource "aws_api_gateway_method" "v1_heartbeat_options_staging" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.v1_heartbeat.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# OPTIONS method for v2/heartbeat - CORS preflight
resource "aws_api_gateway_method" "v2_heartbeat_options_staging" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.v2_heartbeat.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# OPTIONS method for root /heartbeat - CORS preflight
resource "aws_api_gateway_method" "heartbeat_options_staging" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.heartbeat.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# =============================================================================
# CORS METHOD RESPONSES
# =============================================================================

# Method response for v1/{proxy+} OPTIONS
resource "aws_api_gateway_method_response" "v1_proxy_options_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v1_proxy.id
  http_method = aws_api_gateway_method.v1_proxy_options_staging.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Max-Age"       = true
  }
}

# Method response for v2/{proxy+} OPTIONS
resource "aws_api_gateway_method_response" "v2_proxy_options_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v2_proxy.id
  http_method = aws_api_gateway_method.v2_proxy_options_staging.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Max-Age"       = true
  }
}

# Method response for root /{proxy+} OPTIONS
resource "aws_api_gateway_method_response" "root_proxy_options_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.root_proxy.id
  http_method = aws_api_gateway_method.root_proxy_options_staging.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Max-Age"       = true
  }
}

# Method response for v1/heartbeat OPTIONS
resource "aws_api_gateway_method_response" "v1_heartbeat_options_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v1_heartbeat.id
  http_method = aws_api_gateway_method.v1_heartbeat_options_staging.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Max-Age"       = true
  }
}

# Method response for v2/heartbeat OPTIONS
resource "aws_api_gateway_method_response" "v2_heartbeat_options_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v2_heartbeat.id
  http_method = aws_api_gateway_method.v2_heartbeat_options_staging.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Max-Age"       = true
  }
}

# Method response for root /heartbeat OPTIONS
resource "aws_api_gateway_method_response" "heartbeat_options_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.heartbeat.id
  http_method = aws_api_gateway_method.heartbeat_options_staging.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Max-Age"       = true
  }
}

# =============================================================================
# CORS INTEGRATIONS (MOCK)
# =============================================================================

# Mock integration for v1/{proxy+} OPTIONS
resource "aws_api_gateway_integration" "v1_proxy_options_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v1_proxy.id
  http_method = aws_api_gateway_method.v1_proxy_options_staging.http_method

  type = "MOCK"
  
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# Mock integration for v2/{proxy+} OPTIONS
resource "aws_api_gateway_integration" "v2_proxy_options_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v2_proxy.id
  http_method = aws_api_gateway_method.v2_proxy_options_staging.http_method

  type = "MOCK"
  
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# Mock integration for root /{proxy+} OPTIONS
resource "aws_api_gateway_integration" "root_proxy_options_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.root_proxy.id
  http_method = aws_api_gateway_method.root_proxy_options_staging.http_method

  type = "MOCK"
  
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# Mock integration for v1/heartbeat OPTIONS
resource "aws_api_gateway_integration" "v1_heartbeat_options_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v1_heartbeat.id
  http_method = aws_api_gateway_method.v1_heartbeat_options_staging.http_method

  type = "MOCK"
  
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# Mock integration for v2/heartbeat OPTIONS
resource "aws_api_gateway_integration" "v2_heartbeat_options_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v2_heartbeat.id
  http_method = aws_api_gateway_method.v2_heartbeat_options_staging.http_method

  type = "MOCK"
  
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# Mock integration for root /heartbeat OPTIONS
resource "aws_api_gateway_integration" "heartbeat_options_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.heartbeat.id
  http_method = aws_api_gateway_method.heartbeat_options_staging.http_method

  type = "MOCK"
  
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# =============================================================================
# CORS INTEGRATION RESPONSES
# =============================================================================

# Integration response for v1/{proxy+} OPTIONS
resource "aws_api_gateway_integration_response" "v1_proxy_options_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v1_proxy.id
  http_method = aws_api_gateway_method.v1_proxy_options_staging.http_method
  status_code = aws_api_gateway_method_response.v1_proxy_options_staging.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,HEAD,OPTIONS'"
    "method.response.header.Access-Control-Max-Age"       = "'86400'"
  }
}

# Integration response for v2/{proxy+} OPTIONS
resource "aws_api_gateway_integration_response" "v2_proxy_options_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v2_proxy.id
  http_method = aws_api_gateway_method.v2_proxy_options_staging.http_method
  status_code = aws_api_gateway_method_response.v2_proxy_options_staging.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,HEAD,OPTIONS'"
    "method.response.header.Access-Control-Max-Age"       = "'86400'"
  }
}

# Integration response for root /{proxy+} OPTIONS
resource "aws_api_gateway_integration_response" "root_proxy_options_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.root_proxy.id
  http_method = aws_api_gateway_method.root_proxy_options_staging.http_method
  status_code = aws_api_gateway_method_response.root_proxy_options_staging.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,HEAD,OPTIONS'"
    "method.response.header.Access-Control-Max-Age"       = "'86400'"
  }
}

# Integration response for v1/heartbeat OPTIONS
resource "aws_api_gateway_integration_response" "v1_heartbeat_options_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v1_heartbeat.id
  http_method = aws_api_gateway_method.v1_heartbeat_options_staging.http_method
  status_code = aws_api_gateway_method_response.v1_heartbeat_options_staging.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,HEAD,OPTIONS'"
    "method.response.header.Access-Control-Max-Age"       = "'86400'"
  }
}

# Integration response for v2/heartbeat OPTIONS
resource "aws_api_gateway_integration_response" "v2_heartbeat_options_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v2_heartbeat.id
  http_method = aws_api_gateway_method.v2_heartbeat_options_staging.http_method
  status_code = aws_api_gateway_method_response.v2_heartbeat_options_staging.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,HEAD,OPTIONS'"
    "method.response.header.Access-Control-Max-Age"       = "'86400'"
  }
}

# Integration response for root /heartbeat OPTIONS
resource "aws_api_gateway_integration_response" "heartbeat_options_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.heartbeat.id
  http_method = aws_api_gateway_method.heartbeat_options_staging.http_method
  status_code = aws_api_gateway_method_response.heartbeat_options_staging.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,HEAD,OPTIONS'"
    "method.response.header.Access-Control-Max-Age"       = "'86400'"
  }
}

# Associate staging WAF with API Gateway staging stage
resource "aws_wafv2_web_acl_association" "api_gateway_staging" {
  resource_arn = aws_api_gateway_stage.api_gateway_staging.arn
  web_acl_arn  = data.aws_wafv2_web_acl.staging-v2.arn
}
