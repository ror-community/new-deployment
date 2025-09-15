# =============================================================================
# API GATEWAY DEV STAGE
# =============================================================================

# API Gateway Stage (method-level caching only)
resource "aws_api_gateway_stage" "api_gateway_dev" {
  deployment_id = aws_api_gateway_deployment.api_gateway.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  stage_name    = "dev"
  
  # Enable caching for this stage
  cache_cluster_enabled = true
  cache_cluster_size    = "0.5"  # 0.5GB cache size
  
  # Stage variables for backend routing
  variables = {
    backend_host = "alb.dev.ror.org"
    api_host = "api.dev.ror.org"
  }
  
  # Access logging configuration
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway_access_logs.arn
    format = jsonencode({
      requestId         = "$context.requestId"
      requestTime       = "$context.requestTime"
      httpMethod        = "$context.httpMethod"
      path              = "$context.path"
      resourcePath      = "$context.resourcePath"
      overrideResourcePath = "$context.requestOverride.path.resourcePath"
      status            = "$context.status"
      responseLatency   = "$context.responseLatency"
      integrationLatency = "$context.integrationLatency"
      stage             = "$context.stage"
      sourceIp          = "$context.identity.sourceIp"
      userAgent         = "$context.identity.userAgent"
      error             = "$context.error.message"
      responseLength    = "$context.responseLength"
    })
  }
  
  tags = {
    environment = "ror-dev"
    purpose = "api-gateway-caching"
  }
}

# =============================================================================
# METHOD SETTINGS FOR CACHING
# =============================================================================

# Enable caching for v1/{proxy+} endpoint (replaces old v1/organizations)
resource "aws_api_gateway_method_settings" "v1_proxy_cache" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  stage_name  = aws_api_gateway_stage.api_gateway_dev.stage_name
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

# Enable caching for v2/organizations endpoint
resource "aws_api_gateway_method_settings" "v2_proxy_cache" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  stage_name  = aws_api_gateway_stage.api_gateway_dev.stage_name
  method_path = "v2/{proxy+}/GET"

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

# Enable caching for root /{proxy+} endpoint (versionless)
resource "aws_api_gateway_method_settings" "root_proxy_cache" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  stage_name  = aws_api_gateway_stage.api_gateway_dev.stage_name
  method_path = "{proxy+}/GET"

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

# Disable caching for root /heartbeat endpoint (versionless)
resource "aws_api_gateway_method_settings" "heartbeat_no_cache" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  stage_name  = aws_api_gateway_stage.api_gateway_dev.stage_name
  method_path = "heartbeat/GET"

  settings {
    caching_enabled        = false
    cache_ttl_in_seconds   = 0
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

  settings {
    caching_enabled        = false
    cache_ttl_in_seconds   = 0
    cache_data_encrypted   = false
    throttling_rate_limit  = 10000
    throttling_burst_limit = 5000
  }
}

# Enable CloudWatch metrics and execution logging for all methods
resource "aws_api_gateway_method_settings" "metrics_and_logging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  stage_name  = aws_api_gateway_stage.api_gateway_dev.stage_name
  method_path = "*/*"  # Apply to all methods

  settings {
    metrics_enabled             = true
    logging_level               = "ERROR"
    data_trace_enabled         = false
    throttling_rate_limit       = 10000
    throttling_burst_limit      = 5000
  }
}
