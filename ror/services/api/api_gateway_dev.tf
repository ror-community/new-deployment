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

# v1 resource for development
resource "aws_api_gateway_resource" "dev_v1" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  parent_id   = aws_api_gateway_rest_api.api_gateway_dev.root_resource_id
  path_part   = "v1"
}

# v2 resource for development
resource "aws_api_gateway_resource" "dev_v2" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  parent_id   = aws_api_gateway_rest_api.api_gateway_dev.root_resource_id
  path_part   = "v2"
}

# organizations resource under v1 for development
resource "aws_api_gateway_resource" "dev_v1_organizations" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  parent_id   = aws_api_gateway_resource.dev_v1.id
  path_part   = "organizations"
}

# organization ID resource under v1/organizations for development
resource "aws_api_gateway_resource" "dev_v1_organizations_id" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  parent_id   = aws_api_gateway_resource.dev_v1_organizations.id
  path_part   = "{id}"
}

# organizations resource under v2 for development
resource "aws_api_gateway_resource" "dev_v2_organizations" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  parent_id   = aws_api_gateway_resource.dev_v2.id
  path_part   = "organizations"
}

# organization ID resource under v2/organizations for development
resource "aws_api_gateway_resource" "dev_v2_organizations_id" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  parent_id   = aws_api_gateway_resource.dev_v2_organizations.id
  path_part   = "{id}"
}

# organizations resource (without version - uses default v2) for development
resource "aws_api_gateway_resource" "dev_organizations" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  parent_id   = aws_api_gateway_rest_api.api_gateway_dev.root_resource_id
  path_part   = "organizations"
}

# organization ID resource under organizations (without version - uses default v2) for development
resource "aws_api_gateway_resource" "dev_organizations_id" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  parent_id   = aws_api_gateway_resource.dev_organizations.id
  path_part   = "{id}"
}

# heartbeat resource under v1 for development
resource "aws_api_gateway_resource" "dev_v1_heartbeat" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  parent_id   = aws_api_gateway_resource.dev_v1.id
  path_part   = "heartbeat"
}

# heartbeat resource under v2 for development
resource "aws_api_gateway_resource" "dev_v2_heartbeat" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  parent_id   = aws_api_gateway_resource.dev_v2.id
  path_part   = "heartbeat"
}

# =============================================================================
# API GATEWAY METHODS - DEVELOPMENT
# =============================================================================

# GET method for v1/organizations (development)
resource "aws_api_gateway_method" "dev_v1_organizations_get" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id   = aws_api_gateway_resource.dev_v1_organizations.id
  http_method   = "GET"
  authorization = "NONE"
  
  request_parameters = {
    "method.request.querystring.query"       = false
    "method.request.querystring.affiliation" = false
  }
}

# OPTIONS method for v1/organizations (CORS) (development)
resource "aws_api_gateway_method" "dev_v1_organizations_options" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id   = aws_api_gateway_resource.dev_v1_organizations.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# GET method for v1/organizations/{id} (development)
resource "aws_api_gateway_method" "dev_v1_organizations_id_get" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id   = aws_api_gateway_resource.dev_v1_organizations_id.id
  http_method   = "GET"
  authorization = "NONE"
  
  request_parameters = {
    "method.request.path.id" = true
  }
}

# OPTIONS method for v1/organizations/{id} (CORS) (development)
resource "aws_api_gateway_method" "dev_v1_organizations_id_options" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id   = aws_api_gateway_resource.dev_v1_organizations_id.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# GET method for v2/organizations (development)
resource "aws_api_gateway_method" "dev_v2_organizations_get" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id   = aws_api_gateway_resource.dev_v2_organizations.id
  http_method   = "GET"
  authorization = "NONE"
  
  request_parameters = {
    "method.request.querystring.query"       = false
    "method.request.querystring.affiliation" = false
  }
}

# GET method for organizations (without version - uses default v2) (development)
resource "aws_api_gateway_method" "dev_organizations_get" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id   = aws_api_gateway_resource.dev_organizations.id
  http_method   = "GET"
  authorization = "NONE"
  
  request_parameters = {
    "method.request.querystring.query"       = false
    "method.request.querystring.affiliation" = false
  }
}

# GET method for organizations/{id} (without version - uses default v2) (development)
resource "aws_api_gateway_method" "dev_organizations_id_get" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id   = aws_api_gateway_resource.dev_organizations_id.id
  http_method   = "GET"
  authorization = "NONE"
  
  request_parameters = {
    "method.request.path.id" = true
  }
}

# OPTIONS method for organizations/{id} (CORS) (development)
resource "aws_api_gateway_method" "dev_organizations_id_options" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id   = aws_api_gateway_resource.dev_organizations_id.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# GET method for v2/organizations/{id} (development)
resource "aws_api_gateway_method" "dev_v2_organizations_id_get" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id   = aws_api_gateway_resource.dev_v2_organizations_id.id
  http_method   = "GET"
  authorization = "NONE"
  
  request_parameters = {
    "method.request.path.id" = true
  }
}

# OPTIONS method for v2/organizations/{id} (CORS) (development)
resource "aws_api_gateway_method" "dev_v2_organizations_id_options" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id   = aws_api_gateway_resource.dev_v2_organizations_id.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# GET method for v1/heartbeat (development)
resource "aws_api_gateway_method" "dev_v1_heartbeat_get" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id   = aws_api_gateway_resource.dev_v1_heartbeat.id
  http_method   = "GET"
  authorization = "NONE"
}

# GET method for v2/heartbeat (development)
resource "aws_api_gateway_method" "dev_v2_heartbeat_get" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id   = aws_api_gateway_resource.dev_v2_heartbeat.id
  http_method   = "GET"
  authorization = "NONE"
} 

# =============================================================================
# API GATEWAY METHOD RESPONSES - DEVELOPMENT
# =============================================================================

# Method responses for development (similar to original but with dev_ prefix)
resource "aws_api_gateway_method_response" "dev_v1_organizations_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.dev_v1_organizations.id
  http_method = aws_api_gateway_method.dev_v1_organizations_get.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

resource "aws_api_gateway_method_response" "dev_v1_organizations_options" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.dev_v1_organizations.id
  http_method = aws_api_gateway_method.dev_v1_organizations_options.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

resource "aws_api_gateway_method_response" "dev_v1_organizations_id_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.dev_v1_organizations_id.id
  http_method = aws_api_gateway_method.dev_v1_organizations_id_get.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

resource "aws_api_gateway_method_response" "dev_v1_organizations_id_options" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.dev_v1_organizations_id.id
  http_method = aws_api_gateway_method.dev_v1_organizations_id_options.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

resource "aws_api_gateway_method_response" "dev_v2_organizations_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.dev_v2_organizations.id
  http_method = aws_api_gateway_method.dev_v2_organizations_get.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

resource "aws_api_gateway_method_response" "dev_organizations_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.dev_organizations.id
  http_method = aws_api_gateway_method.dev_organizations_get.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

resource "aws_api_gateway_method_response" "dev_organizations_id_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.dev_organizations_id.id
  http_method = aws_api_gateway_method.dev_organizations_id_get.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

resource "aws_api_gateway_method_response" "dev_organizations_id_options" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.dev_organizations_id.id
  http_method = aws_api_gateway_method.dev_organizations_id_options.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

resource "aws_api_gateway_method_response" "dev_v2_organizations_id_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.dev_v2_organizations_id.id
  http_method = aws_api_gateway_method.dev_v2_organizations_id_get.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

resource "aws_api_gateway_method_response" "dev_v2_organizations_id_options" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.dev_v2_organizations_id.id
  http_method = aws_api_gateway_method.dev_v2_organizations_id_options.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

resource "aws_api_gateway_method_response" "dev_v1_heartbeat_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.dev_v1_heartbeat.id
  http_method = aws_api_gateway_method.dev_v1_heartbeat_get.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

resource "aws_api_gateway_method_response" "dev_v2_heartbeat_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.dev_v2_heartbeat.id
  http_method = aws_api_gateway_method.dev_v2_heartbeat_get.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
} 

# =============================================================================
# API GATEWAY INTEGRATIONS - DEVELOPMENT
# =============================================================================

# Integrations for development with caching enabled
resource "aws_api_gateway_integration" "dev_v1_organizations_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.dev_v1_organizations.id
  http_method = aws_api_gateway_method.dev_v1_organizations_get.http_method

  type                    = "HTTP"
  integration_http_method = "GET"
  uri                     = "https://api.dev.ror.org/v1/organizations"
  
  # CACHING CONFIGURATION - Path + query parameters
  cache_key_parameters = ["method.request.querystring.query", "method.request.querystring.affiliation"]
  cache_namespace     = "v1-organizations"
  content_handling    = "CONVERT_TO_TEXT"
}

resource "aws_api_gateway_integration" "dev_v1_organizations_id_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.dev_v1_organizations_id.id
  http_method = aws_api_gateway_method.dev_v1_organizations_id_get.http_method

  type                    = "HTTP"
  integration_http_method = "GET"
  uri                     = "https://api.dev.ror.org/v1/organizations/{id}"
  
  request_parameters = {
    "integration.request.path.id" = "method.request.path.id"
  }
  
  # CACHING CONFIGURATION
  cache_key_parameters = ["method.request.path.id"]
  cache_namespace     = "v1-organizations-id"
  content_handling    = "CONVERT_TO_TEXT"
}

resource "aws_api_gateway_integration" "dev_v2_organizations_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.dev_v2_organizations.id
  http_method = aws_api_gateway_method.dev_v2_organizations_get.http_method

  type                    = "HTTP"
  integration_http_method = "GET"
  uri                     = "https://${data.aws_lb.alb-dev.dns_name}/v2/organizations"
  
  # CACHING CONFIGURATION - Path + query parameters
  cache_key_parameters = ["method.request.querystring.query", "method.request.querystring.affiliation"]
  cache_namespace     = "v2-organizations"
  content_handling    = "CONVERT_TO_TEXT"
}

resource "aws_api_gateway_integration" "dev_organizations_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.dev_organizations.id
  http_method = aws_api_gateway_method.dev_organizations_get.http_method

  type                    = "HTTP"
  integration_http_method = "GET"
  uri                     = "https://api.dev.ror.org/organizations"
  
  # CACHING CONFIGURATION - Path + query parameters
  cache_key_parameters = ["method.request.querystring.query", "method.request.querystring.affiliation"]
  cache_namespace     = "organizations"
  content_handling    = "CONVERT_TO_TEXT"
}

resource "aws_api_gateway_integration" "dev_v2_organizations_id_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.dev_v2_organizations_id.id
  http_method = aws_api_gateway_method.dev_v2_organizations_id_get.http_method

  type                    = "HTTP"
  integration_http_method = "GET"
  uri                     = "https://api.dev.ror.org/v2/organizations/{id}"
  
  request_parameters = {
    "integration.request.path.id" = "method.request.path.id"
  }
  
  # CACHING CONFIGURATION
  cache_key_parameters = ["method.request.path.id"]
  cache_namespace     = "v2-organizations-id"
  content_handling    = "CONVERT_TO_TEXT"
}

resource "aws_api_gateway_integration" "dev_organizations_id_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.dev_organizations_id.id
  http_method = aws_api_gateway_method.dev_organizations_id_get.http_method

  type                    = "HTTP"
  integration_http_method = "GET"
  uri                     = "https://api.dev.ror.org/organizations/{id}"
  
  request_parameters = {
    "integration.request.path.id" = "method.request.path.id"
  }
  
  # CACHING CONFIGURATION
  cache_key_parameters = ["method.request.path.id"]
  cache_namespace     = "organizations-id"
  content_handling    = "CONVERT_TO_TEXT"
}

# OPTIONS integrations for CORS (development)
resource "aws_api_gateway_integration" "dev_v1_organizations_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.dev_v1_organizations.id
  http_method = aws_api_gateway_method.dev_v1_organizations_options.http_method

  type = "MOCK"
  
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration" "dev_v1_organizations_id_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.dev_v1_organizations_id.id
  http_method = aws_api_gateway_method.dev_v1_organizations_id_options.http_method

  type = "MOCK"
  
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration" "dev_organizations_id_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.dev_organizations_id.id
  http_method = aws_api_gateway_method.dev_organizations_id_options.http_method

  type = "MOCK"
  
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration" "dev_v2_organizations_id_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.dev_v2_organizations_id.id
  http_method = aws_api_gateway_method.dev_v2_organizations_id_options.http_method

  type = "MOCK"
  
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration" "dev_v1_heartbeat_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.dev_v1_heartbeat.id
  http_method = aws_api_gateway_method.dev_v1_heartbeat_get.http_method

  type                    = "HTTP"
  integration_http_method = "GET"
  uri                     = "https://api.dev.ror.org/v1/heartbeat"
  
  # No caching for heartbeat endpoints (health checks)
  content_handling    = "CONVERT_TO_TEXT"
}

resource "aws_api_gateway_integration" "dev_v2_heartbeat_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.dev_v2_heartbeat.id
  http_method = aws_api_gateway_method.dev_v2_heartbeat_get.http_method

  type                    = "HTTP"
  integration_http_method = "GET"
  uri                     = "https://api.dev.ror.org/v2/heartbeat"
  
  # No caching for heartbeat endpoints (health checks)
  content_handling    = "CONVERT_TO_TEXT"
} 

# =============================================================================
# API GATEWAY INTEGRATION RESPONSES - DEVELOPMENT
# =============================================================================

# Integration responses for development
resource "aws_api_gateway_integration_response" "dev_v1_organizations_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.dev_v1_organizations.id
  http_method = aws_api_gateway_method.dev_v1_organizations_get.http_method
  status_code = aws_api_gateway_method_response.dev_v1_organizations_get.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }

  depends_on = [
    aws_api_gateway_integration.dev_v1_organizations_integration
  ]
}

resource "aws_api_gateway_integration_response" "dev_v1_organizations_id_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.dev_v1_organizations_id.id
  http_method = aws_api_gateway_method.dev_v1_organizations_id_get.http_method
  status_code = aws_api_gateway_method_response.dev_v1_organizations_id_get.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }

  depends_on = [
    aws_api_gateway_integration.dev_v1_organizations_id_integration
  ]
}

resource "aws_api_gateway_integration_response" "dev_v2_organizations_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.dev_v2_organizations.id
  http_method = aws_api_gateway_method.dev_v2_organizations_get.http_method
  status_code = aws_api_gateway_method_response.dev_v2_organizations_get.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }

  depends_on = [
    aws_api_gateway_integration.dev_v2_organizations_integration
  ]
}

resource "aws_api_gateway_integration_response" "dev_organizations_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.dev_organizations.id
  http_method = aws_api_gateway_method.dev_organizations_get.http_method
  status_code = aws_api_gateway_method_response.dev_organizations_get.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }

  depends_on = [
    aws_api_gateway_integration.dev_organizations_integration
  ]
}

resource "aws_api_gateway_integration_response" "dev_v2_organizations_id_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.dev_v2_organizations_id.id
  http_method = aws_api_gateway_method.dev_v2_organizations_id_get.http_method
  status_code = aws_api_gateway_method_response.dev_v2_organizations_id_get.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }

  depends_on = [
    aws_api_gateway_integration.dev_v2_organizations_id_integration
  ]
}

resource "aws_api_gateway_integration_response" "dev_organizations_id_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.dev_organizations_id.id
  http_method = aws_api_gateway_method.dev_organizations_id_get.http_method
  status_code = aws_api_gateway_method_response.dev_organizations_id_get.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }

  depends_on = [
    aws_api_gateway_integration.dev_organizations_id_integration
  ]
}

resource "aws_api_gateway_integration_response" "dev_v1_heartbeat_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.dev_v1_heartbeat.id
  http_method = aws_api_gateway_method.dev_v1_heartbeat_get.http_method
  status_code = aws_api_gateway_method_response.dev_v1_heartbeat_get.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }

  depends_on = [
    aws_api_gateway_integration.dev_v1_heartbeat_integration
  ]
}

# OPTIONS integration responses for CORS (development)
resource "aws_api_gateway_integration_response" "dev_v1_organizations_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.dev_v1_organizations.id
  http_method = aws_api_gateway_method.dev_v1_organizations_options.http_method
  status_code = aws_api_gateway_method_response.dev_v1_organizations_options.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }

  depends_on = [
    aws_api_gateway_integration.dev_v1_organizations_options_integration
  ]
}

resource "aws_api_gateway_integration_response" "dev_v1_organizations_id_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.dev_v1_organizations_id.id
  http_method = aws_api_gateway_method.dev_v1_organizations_id_options.http_method
  status_code = aws_api_gateway_method_response.dev_v1_organizations_id_options.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }

  depends_on = [
    aws_api_gateway_integration.dev_v1_organizations_id_options_integration
  ]
}

resource "aws_api_gateway_integration_response" "dev_organizations_id_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.dev_organizations_id.id
  http_method = aws_api_gateway_method.dev_organizations_id_options.http_method
  status_code = aws_api_gateway_method_response.dev_organizations_id_options.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }

  depends_on = [
    aws_api_gateway_integration.dev_organizations_id_options_integration
  ]
}

resource "aws_api_gateway_integration_response" "dev_v2_organizations_id_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.dev_v2_organizations_id.id
  http_method = aws_api_gateway_method.dev_v2_organizations_id_options.http_method
  status_code = aws_api_gateway_method_response.dev_v2_organizations_id_options.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }

  depends_on = [
    aws_api_gateway_integration.dev_v2_organizations_id_options_integration
  ]
}

resource "aws_api_gateway_integration_response" "dev_v2_heartbeat_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.dev_v2_heartbeat.id
  http_method = aws_api_gateway_method.dev_v2_heartbeat_get.http_method
  status_code = aws_api_gateway_method_response.dev_v2_heartbeat_get.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }

  depends_on = [
    aws_api_gateway_integration.dev_v2_heartbeat_integration
  ]
} 