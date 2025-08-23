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
    backend_host = data.aws_lb.alb-staging.dns_name
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
      query             = "$context.requestOverride.querystring.query"
      affiliation       = "$context.requestOverride.querystring.affiliation"
      filter            = "$context.requestOverride.querystring.filter"
      page              = "$context.requestOverride.querystring.page"
      page_size         = "$context.requestOverride.querystring.page_size"
      invalid_param     = "$context.requestOverride.querystring._invalid_param"
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
    environment = "ror-staging"
    purpose = "api-gateway-caching"
  }
}

# =============================================================================
# METHOD SETTINGS FOR CACHING - STAGING STAGE
# =============================================================================

# Enable caching for v1/organizations endpoint
resource "aws_api_gateway_method_settings" "v1_organizations_cache_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  stage_name  = aws_api_gateway_stage.api_gateway_staging.stage_name
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
resource "aws_api_gateway_method_settings" "v2_organizations_cache_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  stage_name  = aws_api_gateway_stage.api_gateway_staging.stage_name
  method_path = "v2/organizations/GET"

  depends_on = [
    aws_api_gateway_method_settings.v1_organizations_cache_staging
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
resource "aws_api_gateway_method_settings" "organizations_cache_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  stage_name  = aws_api_gateway_stage.api_gateway_staging.stage_name
  method_path = "organizations/GET"

  depends_on = [
    aws_api_gateway_method_settings.v2_organizations_cache_staging
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
resource "aws_api_gateway_method_settings" "v1_organizations_id_cache_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  stage_name  = aws_api_gateway_stage.api_gateway_staging.stage_name
  method_path = "v1/organizations/{id}/GET"

  depends_on = [
    aws_api_gateway_method_settings.organizations_cache_staging
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

# Enable caching for v2/organizations/{id} endpoint
resource "aws_api_gateway_method_settings" "v2_organizations_id_cache_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  stage_name  = aws_api_gateway_stage.api_gateway_staging.stage_name
  method_path = "v2/organizations/{id}/GET"

  depends_on = [
    aws_api_gateway_method_settings.v1_organizations_id_cache_staging
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
resource "aws_api_gateway_method_settings" "organizations_id_cache_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  stage_name  = aws_api_gateway_stage.api_gateway_staging.stage_name
  method_path = "organizations/{id}/GET"

  depends_on = [
    aws_api_gateway_method_settings.v2_organizations_id_cache_staging
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

# Disable caching for v1/heartbeat endpoint
resource "aws_api_gateway_method_settings" "v1_heartbeat_no_cache_staging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
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
