# =============================================================================
# API GATEWAY SHARED CONFIGURATION
# Used by all stages (dev, staging, prod)
# =============================================================================


# API Gateway REST API with caching enabled
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

# Data sources for access logging ARN construction
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

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

# v1/{proxy+} resource - catches everything after v1/ including organizations
resource "aws_api_gateway_resource" "v1_proxy" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1.id
  path_part   = "{proxy+}"
}

# v2/{proxy+} resource - unified proxy for all v2 endpoints
resource "aws_api_gateway_resource" "v2_proxy" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2.id
  path_part   = "{proxy+}"
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

# Root /{proxy+} resource for versionless requests
resource "aws_api_gateway_resource" "root_proxy" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "{proxy+}"
}

# Root /heartbeat resource for versionless requests  
resource "aws_api_gateway_resource" "heartbeat" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "heartbeat"
}

# =============================================================================
# METHODS
# =============================================================================

# Root path resource for base URL
resource "aws_api_gateway_method" "root_get" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  http_method   = "GET"
  authorization = "NONE"
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

# /heartbeat GET method
resource "aws_api_gateway_method" "heartbeat_get" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.heartbeat.id
  http_method   = "GET"
  authorization = "NONE"
}

# v1/{proxy+} ANY method
resource "aws_api_gateway_method" "v1_proxy" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.v1_proxy.id
  http_method   = "ANY"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.proxy" = true
    "method.request.querystring.query" = false
    "method.request.querystring.page" = false
    "method.request.querystring.affiliation" = false
    "method.request.querystring.filter" = false
    "method.request.querystring.format" = false
    "method.request.querystring.all_status" = false
    "method.request.querystring.query.advanced" = false
    "method.request.querystring.query.name" = false
    "method.request.querystring.query.names" = false
    "method.request.querystring.page_size" = false
  }
}

# v2/{proxy+} ANY method
resource "aws_api_gateway_method" "v2_proxy" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.v2_proxy.id
  http_method   = "ANY"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.proxy" = true
    "method.request.querystring.query" = false
    "method.request.querystring.page" = false
    "method.request.querystring.affiliation" = false
    "method.request.querystring.filter" = false
    "method.request.querystring.format" = false
    "method.request.querystring.all_status" = false
    "method.request.querystring.query.advanced" = false
    "method.request.querystring.query.name" = false
    "method.request.querystring.query.names" = false
    "method.request.querystring.page_size" = false
    "method.request.querystring.single_search" = false
  }
}

# Root /{proxy+} ANY method for versionless requests
resource "aws_api_gateway_method" "root_proxy" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.root_proxy.id
  http_method   = "ANY"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.proxy" = true
    "method.request.querystring.page" = false
    "method.request.querystring.query" = false
    "method.request.querystring.affiliation" = false
    "method.request.querystring.filter" = false
    "method.request.querystring.format" = false
    "method.request.querystring.query.name" = false
    "method.request.querystring.query.names" = false
    "method.request.querystring.all_status" = false
    "method.request.querystring.query.advanced" = false
    "method.request.querystring.page_size" = false
    "method.request.querystring.single_search" = false
  }
}

# =============================================================================
# METHOD RESPONSES
# =============================================================================

# Root path method response
resource "aws_api_gateway_method_response" "root_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_rest_api.api_gateway.root_resource_id
  http_method = aws_api_gateway_method.root_get.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Content-Type" = true
    "method.response.header.Access-Control-Allow-Origin" = true
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

# Method response for root /{proxy+} (versionless)
resource "aws_api_gateway_method_response" "root_proxy" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.root_proxy.id
  http_method = aws_api_gateway_method.root_proxy.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

# Method response for root /heartbeat (versionless)
resource "aws_api_gateway_method_response" "heartbeat_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.heartbeat.id
  http_method = aws_api_gateway_method.heartbeat_get.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

# Method response for v1/{proxy+}
resource "aws_api_gateway_method_response" "v1_proxy" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v1_proxy.id
  http_method = aws_api_gateway_method.v1_proxy.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

# Method response for v2/{proxy+}
resource "aws_api_gateway_method_response" "v2_proxy" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v2_proxy.id
  http_method = aws_api_gateway_method.v2_proxy.http_method
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

# Root path integration (mock integration to return static JSON)
resource "aws_api_gateway_integration" "root_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_rest_api.api_gateway.root_resource_id
  http_method = aws_api_gateway_method.root_get.http_method

  type = "MOCK"
  
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# Integration for v1/heartbeat
resource "aws_api_gateway_integration" "v1_heartbeat_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v1_heartbeat.id
  http_method = aws_api_gateway_method.v1_heartbeat_get.http_method

  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  uri                     = "http://$${stageVariables.backend_host}/v1/heartbeat"

  request_parameters = {
    "integration.request.header.Host" = "stageVariables.api_host"
  }

  # No caching for heartbeat
}

# Integration for v2/heartbeat
resource "aws_api_gateway_integration" "v2_heartbeat_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v2_heartbeat.id
  http_method = aws_api_gateway_method.v2_heartbeat_get.http_method

  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  uri                     = "http://$${stageVariables.backend_host}/v2/heartbeat"

  request_parameters = {
    "integration.request.header.Host" = "stageVariables.api_host"
  }

  # No caching for heartbeat
}

# Integration for root /heartbeat (versionless)
resource "aws_api_gateway_integration" "heartbeat_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.heartbeat.id
  http_method = aws_api_gateway_method.heartbeat_get.http_method

  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  uri                     = "http://$${stageVariables.backend_host}/heartbeat"

  request_parameters = {
    "integration.request.header.Host" = "stageVariables.api_host"
  }

  # No caching for heartbeat
}

# Integration for v1/{proxy+}
resource "aws_api_gateway_integration" "v1_proxy" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v1_proxy.id
  http_method = aws_api_gateway_method.v1_proxy.http_method

  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  uri                     = "https://$${stageVariables.backend_host}/v1/{proxy}"

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
    "integration.request.header.Host" = "stageVariables.api_host"
  }

  # Caching configuration - cache by common query parameters
  cache_key_parameters = [
    "method.request.path.proxy",
    "method.request.querystring.query",
    "method.request.querystring.page", 
    "method.request.querystring.affiliation",
    "method.request.querystring.filter",
    "method.request.querystring.format",
    "method.request.querystring.all_status",
    "method.request.querystring.query.advanced",
    "method.request.querystring.query.name",
    "method.request.querystring.query.names",
    "method.request.querystring.page_size"
  ]
  cache_namespace      = "v1-proxy"
}

# Integration for v2/{proxy+}
resource "aws_api_gateway_integration" "v2_proxy" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v2_proxy.id
  http_method = aws_api_gateway_method.v2_proxy.http_method

  type                    = "HTTP_PROXY"
  integration_http_method = "GET"
  uri                     = "https://$${stageVariables.backend_host}/v2/{proxy}"

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
    "integration.request.header.Host" = "stageVariables.api_host"
  }

  # Caching configuration - cache on the proxy path
  cache_key_parameters = [
    "method.request.path.proxy",
    "method.request.querystring.query",
    "method.request.querystring.page", 
    "method.request.querystring.affiliation",
    "method.request.querystring.filter",
    "method.request.querystring.format",
    "method.request.querystring.all_status",
    "method.request.querystring.query.advanced",
    "method.request.querystring.query.name",
    "method.request.querystring.query.names",
    "method.request.querystring.page_size",
    "method.request.querystring.single_search"
    ]
  cache_namespace     = "v2-proxy"
}

# Integration for /{proxy+}
resource "aws_api_gateway_integration" "root_proxy" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.root_proxy.id
  http_method = aws_api_gateway_method.root_proxy.http_method

  type                    = "HTTP_PROXY"
  integration_http_method = "GET"
  uri                     = "https://$${stageVariables.backend_host}/{proxy}"

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
    "integration.request.header.Host" = "stageVariables.api_host"
  }

  # Caching configuration - cache on the proxy path
  cache_key_parameters = [
    "method.request.path.proxy",
    "method.request.querystring.query",
    "method.request.querystring.page", 
    "method.request.querystring.affiliation",
    "method.request.querystring.filter",
    "method.request.querystring.format",
    "method.request.querystring.all_status",
    "method.request.querystring.query.advanced",
    "method.request.querystring.query.name",
    "method.request.querystring.query.names",
    "method.request.querystring.page_size",
    "method.request.querystring.single_search"
  ]
  cache_namespace     = "root-proxy"
}

# =============================================================================
# INTEGRATION RESPONSES
# =============================================================================


# Root path integration response
resource "aws_api_gateway_integration_response" "root_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_rest_api.api_gateway.root_resource_id
  http_method = aws_api_gateway_method.root_get.http_method
  status_code = aws_api_gateway_method_response.root_get.status_code

  response_parameters = {
    "method.response.header.Content-Type" = "'application/json'"
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  response_templates = {
    "application/json" = "{\"organizations\":\"https://$${stageVariables.api_host}/v2/organizations\"}"
  }
}

# =============================================================================
# API GATEWAY DEPLOYMENT
# =============================================================================

# API Gateway Deployment (shared across all stages)
resource "aws_api_gateway_deployment" "api_gateway" {

  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  
  variables = {
    deployed_at = timestamp()
    force_update = "true"
  }
  
  depends_on = [
    aws_api_gateway_integration.v1_proxy,
    aws_api_gateway_integration.v2_proxy,
    aws_api_gateway_integration.root_proxy,
    aws_api_gateway_integration.heartbeat_get,
    aws_api_gateway_integration.v1_heartbeat_get,
    aws_api_gateway_integration.v2_heartbeat_get,
    aws_api_gateway_integration.root_get,
    aws_api_gateway_method.root_proxy,
    aws_api_gateway_method.heartbeat_get
  ]
  
  lifecycle {
    create_before_destroy = true
  }
}