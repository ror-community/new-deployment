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

# Shared deployment - depends on shared resources only
resource "aws_api_gateway_deployment" "api_gateway" {
  depends_on = [
    # Shared method responses only
    aws_api_gateway_method_response.v1_organizations_get,
    aws_api_gateway_method_response.v2_organizations_get,
    aws_api_gateway_method_response.v1_organizations_id_get,
    aws_api_gateway_method_response.v2_organizations_id_get,
    aws_api_gateway_method_response.v1_heartbeat_get,
    aws_api_gateway_method_response.v2_heartbeat_get,
    aws_api_gateway_method_response.organizations_get,
    aws_api_gateway_method_response.organizations_id_get,
    aws_api_gateway_method_response.root_get,
    aws_api_gateway_method_response.proxy
  ]

  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  
  variables = {
    deployed_at = timestamp()
    force_update = "true"
  }
  
  lifecycle {
    create_before_destroy = true
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

# Root path resource for base URL
resource "aws_api_gateway_method" "root_get" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  http_method   = "GET"
  authorization = "NONE"
}

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
# INTEGRATIONS - DEFINED IN STAGE-SPECIFIC FILES
# =============================================================================
# Integrations are defined in api_gateway_dev.tf and api_gateway_staging.tf
# to allow for stage-specific backend routing

# =============================================================================
# INTEGRATION RESPONSES - DEFINED IN STAGE-SPECIFIC FILES  
# =============================================================================
# Integration responses are defined in api_gateway_dev.tf and api_gateway_staging.tf
# to allow for stage-specific backend routing and response handling
