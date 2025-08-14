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

# Integration for v1/organizations
resource "aws_api_gateway_integration" "v1_organizations_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v1_organizations.id
  http_method = aws_api_gateway_method.v1_organizations_get.http_method

  integration_http_method = "GET"
  type                    = "HTTP"
  uri                     = "http://\${stageVariables.backend_host}/v1/organizations"

  request_parameters = {
    "integration.request.querystring.page" = "method.request.querystring.page"
    "integration.request.querystring.query" = "method.request.querystring.query"
    "integration.request.querystring.affiliation" = "method.request.querystring.affiliation"
    "integration.request.querystring.filter" = "method.request.querystring.filter"
    "integration.request.querystring.format" = "method.request.querystring.format"
    "integration.request.querystring.query.name" = "method.request.querystring.query.name"
    "integration.request.querystring.query.names" = "method.request.querystring.query.names"
    "integration.request.header.Host" = "stageVariables.api_host"
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
  uri                     = "http://\${stageVariables.backend_host}/v2/organizations"

  request_parameters = {
    "integration.request.querystring.page" = "method.request.querystring.page"
    "integration.request.querystring.query" = "method.request.querystring.query"
    "integration.request.querystring.affiliation" = "method.request.querystring.affiliation"
    "integration.request.querystring.filter" = "method.request.querystring.filter"
    "integration.request.querystring.format" = "method.request.querystring.format"
    "integration.request.querystring.query.name" = "method.request.querystring.query.name"
    "integration.request.querystring.query.names" = "method.request.querystring.query.names"
    "integration.request.header.Host" = "stageVariables.api_host"
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
  uri                     = "http://\${stageVariables.backend_host}/v1/organizations/{id}"

  request_parameters = {
    "integration.request.path.id" = "method.request.path.id"
    "integration.request.header.Host" = "stageVariables.api_host"
  }

  # Caching configuration
  cache_key_parameters = ["method.request.path.id"]
  cache_namespace     = "v1-organizations-id"
}

# Integration for v2/organizations/{id}
resource "aws_api_gateway_integration" "v2_organizations_id_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v2_organizations_id.id
  http_method = aws_api_gateway_method.v2_organizations_id_get.http_method

  type                    = "HTTP"
  integration_http_method = "GET"
  uri                     = "http://\${stageVariables.backend_host}/v2/organizations/{id}"

  request_parameters = {
    "integration.request.path.id" = "method.request.path.id"
    "integration.request.header.Host" = "stageVariables.api_host"
  }

  # Caching configuration
  cache_key_parameters = ["method.request.path.id"]
  cache_namespace     = "v2-organizations-id"
}

# Integration for v1/heartbeat
resource "aws_api_gateway_integration" "v1_heartbeat_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v1_heartbeat.id
  http_method = aws_api_gateway_method.v1_heartbeat_get.http_method

  integration_http_method = "GET"
  type                    = "HTTP"
  uri                     = "http://\${stageVariables.backend_host}/v1/heartbeat"

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
  type                    = "HTTP"
  uri                     = "http://\${stageVariables.backend_host}/v2/heartbeat"

  request_parameters = {
    "integration.request.header.Host" = "stageVariables.api_host"
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
  uri                     = "http://\${stageVariables.backend_host}/organizations"

  request_parameters = {
    "integration.request.querystring.page" = "method.request.querystring.page"
    "integration.request.querystring.query" = "method.request.querystring.query"
    "integration.request.querystring.affiliation" = "method.request.querystring.affiliation"
    "integration.request.querystring.filter" = "method.request.querystring.filter"
    "integration.request.querystring.format" = "method.request.querystring.format"
    "integration.request.querystring.query.name" = "method.request.querystring.query.name"
    "integration.request.querystring.query.names" = "method.request.querystring.query.names"
    "integration.request.header.Host" = "stageVariables.api_host"
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
  uri                     = "http://\${stageVariables.backend_host}/organizations/{id}"

  request_parameters = {
    "integration.request.path.id" = "method.request.path.id"
    "integration.request.header.Host" = "stageVariables.api_host"
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
  uri                     = "http://\${stageVariables.backend_host}/{proxy}"

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
    "integration.request.header.Host" = "stageVariables.api_host"
  }
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
    "application/json" = "{\"organizations\":\"https://\${stageVariables.api_host}/v2/organizations\"}"
  }

  depends_on = [
    aws_api_gateway_integration.root_get
  ]
}

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
