# =============================================================================
# API GATEWAY PROD STAGE
# =============================================================================

# API Gateway Stage (production)
resource "aws_api_gateway_stage" "api_gateway_prod" {
  deployment_id = aws_api_gateway_deployment.api_gateway.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  stage_name    = "prod"
  
  # Enable caching for this stage
  cache_cluster_enabled = true
  cache_cluster_size    = "0.5"  # 0.5GB cache size
  
  # Stage variables for backend routing
  variables = {
    backend_host = data.aws_lb.alb.dns_name
    api_host = "api.ror.org"
  }
  
  # Access logging configuration
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway_access_logs_prod.arn
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
    environment = "ror-prod"
    purpose = "api-gateway-caching"
  }
}

# =============================================================================
# METHOD SETTINGS FOR CACHING - PROD STAGE
# =============================================================================

# Enable caching for v1/organizations endpoint
resource "aws_api_gateway_method_settings" "v1_organizations_cache_prod" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  stage_name  = aws_api_gateway_stage.api_gateway_prod.stage_name
  method_path = "v1/organizations/GET"

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
resource "aws_api_gateway_method_settings" "v2_proxy_cache_prod" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  stage_name  = aws_api_gateway_stage.api_gateway_prod.stage_name
  method_path = "v2/{proxy+}/GET"

  depends_on = [
    aws_api_gateway_method_settings.v1_organizations_cache_prod
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

# Enable caching for organizations endpoint (no version)
resource "aws_api_gateway_method_settings" "root_proxy_cache_prod" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  stage_name  = aws_api_gateway_stage.api_gateway_prod.stage_name
  method_path = "{proxy+}/GET"

  depends_on = [
    aws_api_gateway_method_settings.v2_proxy_cache_prod
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

# Enable caching for v1/organizations/{id} endpoint
resource "aws_api_gateway_method_settings" "v1_organizations_id_cache_prod" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  stage_name  = aws_api_gateway_stage.api_gateway_prod.stage_name
  method_path = "v1/organizations/{id}/GET"

  depends_on = [
    aws_api_gateway_method_settings.root_proxy_cache_prod
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



# Enable caching for organizations/{id} endpoint (no version)
resource "aws_api_gateway_method_settings" "heartbeat_no_cache_prod" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  stage_name  = aws_api_gateway_stage.api_gateway_prod.stage_name
  method_path = "heartbeat/GET"

  depends_on = [
    aws_api_gateway_method_settings.root_proxy_cache_prod
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
resource "aws_api_gateway_method_settings" "v1_heartbeat_no_cache_prod" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  stage_name  = aws_api_gateway_stage.api_gateway_prod.stage_name
  method_path = "v1/heartbeat/GET"

  depends_on = [
    aws_api_gateway_method_settings.heartbeat_no_cache_prod
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
resource "aws_api_gateway_method_settings" "v2_heartbeat_no_cache_prod" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  stage_name  = aws_api_gateway_stage.api_gateway_prod.stage_name
  method_path = "v2/heartbeat/GET"

  depends_on = [
    aws_api_gateway_method_settings.v1_heartbeat_no_cache_prod
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
resource "aws_api_gateway_method_settings" "metrics_and_logging_prod" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  stage_name  = aws_api_gateway_stage.api_gateway_prod.stage_name
  method_path = "*/*"  # Apply to all methods

  depends_on = [
    aws_api_gateway_method_settings.v2_heartbeat_no_cache_prod,
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
