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

# v2/organizations resource
resource "aws_api_gateway_resource" "v2_organizations" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2.id
  path_part   = "organizations"
}

# v2/organizations/{orgid} resource
resource "aws_api_gateway_resource" "v2_organizations_orgid" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_organizations.id
  path_part   = "{orgid}"
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

# Root /generateid resource
resource "aws_api_gateway_resource" "generateid" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "generateid"
}

# Root /organizations resource
resource "aws_api_gateway_resource" "organizations" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "organizations"
}

# /organizations/{orgid} resource
resource "aws_api_gateway_resource" "organizations_orgid" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.organizations.id
  path_part   = "{orgid}"
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

# /generateid GET method
resource "aws_api_gateway_method" "generateid_get" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.generateid.id
  http_method   = "GET"
  authorization = "NONE"
}

# /organizations/{orgid} GET method
resource "aws_api_gateway_method" "organizations_orgid_get" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.organizations_orgid.id
  http_method   = "GET"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.orgid" = true
  }
}

# /organizations ANY method (for query strings and other requests)
resource "aws_api_gateway_method" "organizations_any" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.organizations.id
  http_method   = "ANY"
  authorization = "NONE"

  request_parameters = {
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

# v2/organizations/{orgid} GET method
resource "aws_api_gateway_method" "v2_organizations_orgid_get" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.v2_organizations_orgid.id
  http_method   = "GET"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.orgid" = true
  }
}

# v2/organizations ANY method (for query strings and other requests)
resource "aws_api_gateway_method" "v2_organizations_any" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.v2_organizations.id
  http_method   = "ANY"
  authorization = "NONE"

  request_parameters = {
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

# Method response for root /generateid
resource "aws_api_gateway_method_response" "generateid_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.generateid.id
  http_method = aws_api_gateway_method.generateid_get.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

# Method response for /organizations/{orgid}
resource "aws_api_gateway_method_response" "organizations_orgid_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.organizations_orgid.id
  http_method = aws_api_gateway_method.organizations_orgid_get.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

# Method response for /organizations ANY
resource "aws_api_gateway_method_response" "organizations_any" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.organizations.id
  http_method = aws_api_gateway_method.organizations_any.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

# Method response for v2/organizations/{orgid}
resource "aws_api_gateway_method_response" "v2_organizations_orgid_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v2_organizations_orgid.id
  http_method = aws_api_gateway_method.v2_organizations_orgid_get.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

# Method response for v2/organizations ANY
resource "aws_api_gateway_method_response" "v2_organizations_any" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v2_organizations.id
  http_method = aws_api_gateway_method.v2_organizations_any.http_method
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
  uri                     = "https://$${stageVariables.backend_host}/v1/heartbeat"

  request_parameters = {
    "integration.request.header.Host" = "stageVariables.api_host"
    "integration.request.header.X-ROR-API-Gateway-Token" = "'${var.api_gateway_token}'"
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
  uri                     = "https://$${stageVariables.backend_host}/v2/heartbeat"

  request_parameters = {
    "integration.request.header.Host" = "stageVariables.api_host"
    "integration.request.header.X-ROR-API-Gateway-Token" = "'${var.api_gateway_token}'"
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
  uri                     = "https://$${stageVariables.backend_host}/heartbeat"

  request_parameters = {
    "integration.request.header.Host" = "stageVariables.api_host"
    "integration.request.header.X-ROR-API-Gateway-Token" = "'${var.api_gateway_token}'"
  }

  # No caching for heartbeat
}

# Integration for root /generateid
resource "aws_api_gateway_integration" "generateid_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.generateid.id
  http_method = aws_api_gateway_method.generateid_get.http_method

  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  uri                     = "https://$${stageVariables.backend_host}/generateid"

  request_parameters = {
    "integration.request.header.Host" = "stageVariables.api_host"
    "integration.request.header.X-ROR-API-Gateway-Token" = "'${var.api_gateway_token}'"
  }
}

# Integration for /organizations/{orgid}
resource "aws_api_gateway_integration" "organizations_orgid_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.organizations_orgid.id
  http_method = aws_api_gateway_method.organizations_orgid_get.http_method

  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  uri                     = "https://$${stageVariables.backend_host}/organizations/{orgid}"

  request_parameters = {
    "integration.request.path.orgid" = "method.request.path.orgid"
    "integration.request.header.Host" = "stageVariables.api_host"
    "integration.request.header.X-ROR-API-Gateway-Token" = "'${var.api_gateway_token}'"

  }

  # No caching for organizations/{orgid}
}

# Integration for /organizations ANY (for query strings)
resource "aws_api_gateway_integration" "organizations_any" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.organizations.id
  http_method = aws_api_gateway_method.organizations_any.http_method

  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "https://$${stageVariables.backend_host}/organizations"

  request_parameters = {
    "integration.request.header.Host" = "stageVariables.api_host"
    "integration.request.header.X-ROR-API-Gateway-Token" = "'${var.api_gateway_token}'"
    "integration.request.querystring.query" = "method.request.querystring.query"
    "integration.request.querystring.page" = "method.request.querystring.page"
    "integration.request.querystring.affiliation" = "method.request.querystring.affiliation"
    "integration.request.querystring.filter" = "method.request.querystring.filter"
    "integration.request.querystring.format" = "method.request.querystring.format"
    "integration.request.querystring.all_status" = "method.request.querystring.all_status"
    "integration.request.querystring.query.advanced" = "method.request.querystring.query.advanced"
    "integration.request.querystring.query.name" = "method.request.querystring.query.name"
    "integration.request.querystring.query.names" = "method.request.querystring.query.names"
    "integration.request.querystring.page_size" = "method.request.querystring.page_size"
    "integration.request.querystring.single_search" = "method.request.querystring.single_search"
  }

  # Caching configuration - cache by query parameters
  cache_key_parameters = [
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
  cache_namespace = "organizations"
}

# Integration for v2/organizations/{orgid}
resource "aws_api_gateway_integration" "v2_organizations_orgid_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v2_organizations_orgid.id
  http_method = aws_api_gateway_method.v2_organizations_orgid_get.http_method

  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  uri                     = "https://$${stageVariables.backend_host}/v2/organizations/{orgid}"

  request_parameters = {
    "integration.request.path.orgid" = "method.request.path.orgid"
    "integration.request.header.Host" = "stageVariables.api_host"
    "integration.request.header.X-ROR-API-Gateway-Token" = "'${var.api_gateway_token}'"
  }

  # No caching for v2/organizations/{orgid}
}

# Integration for v2/organizations ANY (for query strings)
resource "aws_api_gateway_integration" "v2_organizations_any" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v2_organizations.id
  http_method = aws_api_gateway_method.v2_organizations_any.http_method

  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "https://$${stageVariables.backend_host}/v2/organizations"

  request_parameters = {
    "integration.request.header.Host" = "stageVariables.api_host"
    "integration.request.header.X-ROR-API-Gateway-Token" = "'${var.api_gateway_token}'"
    "integration.request.querystring.query" = "method.request.querystring.query"
    "integration.request.querystring.page" = "method.request.querystring.page"
    "integration.request.querystring.affiliation" = "method.request.querystring.affiliation"
    "integration.request.querystring.filter" = "method.request.querystring.filter"
    "integration.request.querystring.format" = "method.request.querystring.format"
    "integration.request.querystring.all_status" = "method.request.querystring.all_status"
    "integration.request.querystring.query.advanced" = "method.request.querystring.query.advanced"
    "integration.request.querystring.query.name" = "method.request.querystring.query.name"
    "integration.request.querystring.query.names" = "method.request.querystring.query.names"
    "integration.request.querystring.page_size" = "method.request.querystring.page_size"
    "integration.request.querystring.single_search" = "method.request.querystring.single_search"
  }

  # Caching configuration - cache by query parameters
  cache_key_parameters = [
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
  cache_namespace = "v2-organizations"
}

# Integration for v1/{proxy+}
resource "aws_api_gateway_integration" "v1_proxy" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v1_proxy.id
  http_method = aws_api_gateway_method.v1_proxy.http_method

  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "https://$${stageVariables.backend_host}/v1/{proxy}"

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
    "integration.request.header.Host" = "stageVariables.api_host"
    "integration.request.header.X-ROR-API-Gateway-Token" = "'${var.api_gateway_token}'"
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
  integration_http_method = "ANY"
  uri                     = "https://$${stageVariables.backend_host}/v2/{proxy}"

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
    "integration.request.header.Host" = "stageVariables.api_host"
    "integration.request.header.X-ROR-API-Gateway-Token" = "'${var.api_gateway_token}'"
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
  integration_http_method = "ANY"
  uri                     = "https://$${stageVariables.backend_host}/{proxy}"

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
    "integration.request.header.Host" = "stageVariables.api_host"
    "integration.request.header.X-ROR-API-Gateway-Token" = "'${var.api_gateway_token}'"
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

# Integration responses for existing proxy methods to ensure CORS headers
resource "aws_api_gateway_integration_response" "v1_heartbeat_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v1_heartbeat.id
  http_method = aws_api_gateway_method.v1_heartbeat_get.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,HEAD,OPTIONS'"
  }
}

resource "aws_api_gateway_integration_response" "v2_heartbeat_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v2_heartbeat.id
  http_method = aws_api_gateway_method.v2_heartbeat_get.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,HEAD,OPTIONS'"
  }
}

resource "aws_api_gateway_integration_response" "heartbeat_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.heartbeat.id
  http_method = aws_api_gateway_method.heartbeat_get.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,HEAD,OPTIONS'"
  }
}

resource "aws_api_gateway_integration_response" "generateid_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.generateid.id
  http_method = aws_api_gateway_method.generateid_get.http_method
  status_code = "200"

  depends_on = [
    aws_api_gateway_integration.generateid_get
  ]

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,HEAD,OPTIONS'"
  }
}

resource "aws_api_gateway_integration_response" "organizations_orgid_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.organizations_orgid.id
  http_method = aws_api_gateway_method.organizations_orgid_get.http_method
  status_code = "200"

  depends_on = [
    aws_api_gateway_integration.organizations_orgid_get
  ]

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }
}

resource "aws_api_gateway_integration_response" "organizations_any" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.organizations.id
  http_method = aws_api_gateway_method.organizations_any.http_method
  status_code = "200"

  depends_on = [
    aws_api_gateway_integration.organizations_any
  ]

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,HEAD,OPTIONS'"
  }
}

resource "aws_api_gateway_integration_response" "v2_organizations_orgid_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v2_organizations_orgid.id
  http_method = aws_api_gateway_method.v2_organizations_orgid_get.http_method
  status_code = "200"

  depends_on = [
    aws_api_gateway_integration.v2_organizations_orgid_get
  ]

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }
}

resource "aws_api_gateway_integration_response" "v2_organizations_any" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v2_organizations.id
  http_method = aws_api_gateway_method.v2_organizations_any.http_method
  status_code = "200"

  depends_on = [
    aws_api_gateway_integration.v2_organizations_any
  ]

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,HEAD,OPTIONS'"
  }
}

resource "aws_api_gateway_integration_response" "v1_proxy" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v1_proxy.id
  http_method = aws_api_gateway_method.v1_proxy.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,HEAD,OPTIONS'"
  }
}

resource "aws_api_gateway_integration_response" "v2_proxy" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v2_proxy.id
  http_method = aws_api_gateway_method.v2_proxy.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,HEAD,OPTIONS'"
  }
}

resource "aws_api_gateway_integration_response" "root_proxy" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.root_proxy.id
  http_method = aws_api_gateway_method.root_proxy.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,HEAD,OPTIONS'"
  }
}

# =============================================================================
# CORS OPTIONS METHODS
# =============================================================================
# OPTIONS method for v1/{proxy+} - CORS preflight
resource "aws_api_gateway_method" "v1_proxy_options" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.v1_proxy.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# OPTIONS method for v2/{proxy+} - CORS preflight
resource "aws_api_gateway_method" "v2_proxy_options" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.v2_proxy.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# OPTIONS method for root /{proxy+} - CORS preflight
resource "aws_api_gateway_method" "root_proxy_options" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.root_proxy.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# OPTIONS method for v1/heartbeat - CORS preflight
resource "aws_api_gateway_method" "v1_heartbeat_options" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.v1_heartbeat.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# OPTIONS method for v2/heartbeat - CORS preflight
resource "aws_api_gateway_method" "v2_heartbeat_options" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.v2_heartbeat.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# OPTIONS method for root /heartbeat - CORS preflight
resource "aws_api_gateway_method" "heartbeat_options" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.heartbeat.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# OPTIONS method for root /generateid - CORS preflight
resource "aws_api_gateway_method" "generateid_options" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.generateid.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# OPTIONS method for /organizations/{orgid} - CORS preflight
resource "aws_api_gateway_method" "organizations_orgid_options" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.organizations_orgid.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# OPTIONS method for /organizations - CORS preflight
resource "aws_api_gateway_method" "organizations_options" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.organizations.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# OPTIONS method for v2/organizations/{orgid} - CORS preflight
resource "aws_api_gateway_method" "v2_organizations_orgid_options" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.v2_organizations_orgid.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# OPTIONS method for v2/organizations - CORS preflight
resource "aws_api_gateway_method" "v2_organizations_options" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.v2_organizations.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# =============================================================================
# CORS METHOD RESPONSES
# =============================================================================

# Method response for v1/{proxy+} OPTIONS
resource "aws_api_gateway_method_response" "v1_proxy_options" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v1_proxy.id
  http_method = aws_api_gateway_method.v1_proxy_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Max-Age"       = true
  }
}

# Method response for v2/{proxy+} OPTIONS
resource "aws_api_gateway_method_response" "v2_proxy_options" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v2_proxy.id
  http_method = aws_api_gateway_method.v2_proxy_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Max-Age"       = true
  }
}

# Method response for root /{proxy+} OPTIONS
resource "aws_api_gateway_method_response" "root_proxy_options" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.root_proxy.id
  http_method = aws_api_gateway_method.root_proxy_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Max-Age"       = true
  }
}

# Method response for v1/heartbeat OPTIONS
resource "aws_api_gateway_method_response" "v1_heartbeat_options" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v1_heartbeat.id
  http_method = aws_api_gateway_method.v1_heartbeat_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Max-Age"       = true
  }
}

# Method response for v2/heartbeat OPTIONS
resource "aws_api_gateway_method_response" "v2_heartbeat_options" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v2_heartbeat.id
  http_method = aws_api_gateway_method.v2_heartbeat_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Max-Age"       = true
  }
}

# Method response for root /heartbeat OPTIONS
resource "aws_api_gateway_method_response" "heartbeat_options" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.heartbeat.id
  http_method = aws_api_gateway_method.heartbeat_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Max-Age"       = true
  }
}

# Method response for root /generateid OPTIONS
resource "aws_api_gateway_method_response" "generateid_options" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.generateid.id
  http_method = aws_api_gateway_method.generateid_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Max-Age"       = true
  }
}

# Method response for /organizations/{orgid} OPTIONS
resource "aws_api_gateway_method_response" "organizations_orgid_options" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.organizations_orgid.id
  http_method = aws_api_gateway_method.organizations_orgid_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Max-Age"       = true
  }
}

# Method response for /organizations OPTIONS
resource "aws_api_gateway_method_response" "organizations_options" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.organizations.id
  http_method = aws_api_gateway_method.organizations_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Max-Age"       = true
  }
}

# Method response for v2/organizations/{orgid} OPTIONS
resource "aws_api_gateway_method_response" "v2_organizations_orgid_options" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v2_organizations_orgid.id
  http_method = aws_api_gateway_method.v2_organizations_orgid_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Max-Age"       = true
  }
}

# Method response for v2/organizations OPTIONS
resource "aws_api_gateway_method_response" "v2_organizations_options" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v2_organizations.id
  http_method = aws_api_gateway_method.v2_organizations_options.http_method
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
resource "aws_api_gateway_integration" "v1_proxy_options" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v1_proxy.id
  http_method = aws_api_gateway_method.v1_proxy_options.http_method

  type = "MOCK"
  
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# Mock integration for v2/{proxy+} OPTIONS
resource "aws_api_gateway_integration" "v2_proxy_options" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v2_proxy.id
  http_method = aws_api_gateway_method.v2_proxy_options.http_method

  type = "MOCK"
  
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# Mock integration for root /{proxy+} OPTIONS
resource "aws_api_gateway_integration" "root_proxy_options" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.root_proxy.id
  http_method = aws_api_gateway_method.root_proxy_options.http_method

  type = "MOCK"
  
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# Mock integration for v1/heartbeat OPTIONS
resource "aws_api_gateway_integration" "v1_heartbeat_options" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v1_heartbeat.id
  http_method = aws_api_gateway_method.v1_heartbeat_options.http_method

  type = "MOCK"
  
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# Mock integration for v2/heartbeat OPTIONS
resource "aws_api_gateway_integration" "v2_heartbeat_options" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v2_heartbeat.id
  http_method = aws_api_gateway_method.v2_heartbeat_options.http_method

  type = "MOCK"
  
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# Mock integration for root /heartbeat OPTIONS
resource "aws_api_gateway_integration" "heartbeat_options" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.heartbeat.id
  http_method = aws_api_gateway_method.heartbeat_options.http_method

  type = "MOCK"
  
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# Mock integration for root /generateid OPTIONS
resource "aws_api_gateway_integration" "generateid_options" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.generateid.id
  http_method = aws_api_gateway_method.generateid_options.http_method

  type = "MOCK"
  
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# Mock integration for /organizations/{orgid} OPTIONS
resource "aws_api_gateway_integration" "organizations_orgid_options" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.organizations_orgid.id
  http_method = aws_api_gateway_method.organizations_orgid_options.http_method

  type = "MOCK"
  
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# Mock integration for /organizations OPTIONS
resource "aws_api_gateway_integration" "organizations_options" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.organizations.id
  http_method = aws_api_gateway_method.organizations_options.http_method

  type = "MOCK"
  
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# Mock integration for v2/organizations/{orgid} OPTIONS
resource "aws_api_gateway_integration" "v2_organizations_orgid_options" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v2_organizations_orgid.id
  http_method = aws_api_gateway_method.v2_organizations_orgid_options.http_method

  type = "MOCK"
  
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# Mock integration for v2/organizations OPTIONS
resource "aws_api_gateway_integration" "v2_organizations_options" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v2_organizations.id
  http_method = aws_api_gateway_method.v2_organizations_options.http_method

  type = "MOCK"
  
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# =============================================================================
# CORS INTEGRATION RESPONSES
# =============================================================================

# Integration response for v1/{proxy+} OPTIONS
resource "aws_api_gateway_integration_response" "v1_proxy_options" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v1_proxy.id
  http_method = aws_api_gateway_method.v1_proxy_options.http_method
  status_code = aws_api_gateway_method_response.v1_proxy_options.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,HEAD,OPTIONS'"
    "method.response.header.Access-Control-Max-Age"       = "'86400'"
  }
}

# Integration response for v2/{proxy+} OPTIONS
resource "aws_api_gateway_integration_response" "v2_proxy_options" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v2_proxy.id
  http_method = aws_api_gateway_method.v2_proxy_options.http_method
  status_code = aws_api_gateway_method_response.v2_proxy_options.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,HEAD,OPTIONS'"
    "method.response.header.Access-Control-Max-Age"       = "'86400'"
  }
}

# Integration response for root /{proxy+} OPTIONS
resource "aws_api_gateway_integration_response" "root_proxy_options" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.root_proxy.id
  http_method = aws_api_gateway_method.root_proxy_options.http_method
  status_code = aws_api_gateway_method_response.root_proxy_options.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,HEAD,OPTIONS'"
    "method.response.header.Access-Control-Max-Age"       = "'86400'"
  }
}

# Integration response for v1/heartbeat OPTIONS
resource "aws_api_gateway_integration_response" "v1_heartbeat_options" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v1_heartbeat.id
  http_method = aws_api_gateway_method.v1_heartbeat_options.http_method
  status_code = aws_api_gateway_method_response.v1_heartbeat_options.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,HEAD,OPTIONS'"
    "method.response.header.Access-Control-Max-Age"       = "'86400'"
  }
}

# Integration response for v2/heartbeat OPTIONS
resource "aws_api_gateway_integration_response" "v2_heartbeat_options" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v2_heartbeat.id
  http_method = aws_api_gateway_method.v2_heartbeat_options.http_method
  status_code = aws_api_gateway_method_response.v2_heartbeat_options.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,HEAD,OPTIONS'"
    "method.response.header.Access-Control-Max-Age"       = "'86400'"
  }
}

# Integration response for root /heartbeat OPTIONS
resource "aws_api_gateway_integration_response" "heartbeat_options" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.heartbeat.id
  http_method = aws_api_gateway_method.heartbeat_options.http_method
  status_code = aws_api_gateway_method_response.heartbeat_options.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,HEAD,OPTIONS'"
    "method.response.header.Access-Control-Max-Age"       = "'86400'"
  }
}

# Integration response for root /generateid OPTIONS
resource "aws_api_gateway_integration_response" "generateid_options" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.generateid.id
  http_method = aws_api_gateway_method.generateid_options.http_method
  status_code = aws_api_gateway_method_response.generateid_options.status_code

  depends_on = [
    aws_api_gateway_integration.generateid_options
  ]

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,HEAD,OPTIONS'"
    "method.response.header.Access-Control-Max-Age"       = "'86400'"
  }
}

# Integration response for /organizations/{orgid} OPTIONS
resource "aws_api_gateway_integration_response" "organizations_orgid_options" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.organizations_orgid.id
  http_method = aws_api_gateway_method.organizations_orgid_options.http_method
  status_code = aws_api_gateway_method_response.organizations_orgid_options.status_code

  depends_on = [
    aws_api_gateway_integration.organizations_orgid_options
  ]

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
    "method.response.header.Access-Control-Max-Age"       = "'86400'"
  }
}

# Integration response for /organizations OPTIONS
resource "aws_api_gateway_integration_response" "organizations_options" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.organizations.id
  http_method = aws_api_gateway_method.organizations_options.http_method
  status_code = aws_api_gateway_method_response.organizations_options.status_code

  depends_on = [
    aws_api_gateway_integration.organizations_options
  ]

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,HEAD,OPTIONS'"
    "method.response.header.Access-Control-Max-Age"       = "'86400'"
  }
}

# Integration response for v2/organizations/{orgid} OPTIONS
resource "aws_api_gateway_integration_response" "v2_organizations_orgid_options" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v2_organizations_orgid.id
  http_method = aws_api_gateway_method.v2_organizations_orgid_options.http_method
  status_code = aws_api_gateway_method_response.v2_organizations_orgid_options.status_code

  depends_on = [
    aws_api_gateway_integration.v2_organizations_orgid_options
  ]

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
    "method.response.header.Access-Control-Max-Age"       = "'86400'"
  }
}

# Integration response for v2/organizations OPTIONS
resource "aws_api_gateway_integration_response" "v2_organizations_options" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v2_organizations.id
  http_method = aws_api_gateway_method.v2_organizations_options.http_method
  status_code = aws_api_gateway_method_response.v2_organizations_options.status_code

  depends_on = [
    aws_api_gateway_integration.v2_organizations_options
  ]

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,HEAD,OPTIONS'"
    "method.response.header.Access-Control-Max-Age"       = "'86400'"
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
    aws_api_gateway_integration.generateid_get,
    aws_api_gateway_integration.organizations_orgid_get,
    aws_api_gateway_integration.organizations_any,
    aws_api_gateway_integration.v2_organizations_orgid_get,
    aws_api_gateway_integration.v2_organizations_any,
    aws_api_gateway_integration.v1_proxy_options,
    aws_api_gateway_integration.v2_proxy_options,
    aws_api_gateway_integration.root_proxy_options,
    aws_api_gateway_integration.v1_heartbeat_options,
    aws_api_gateway_integration.v2_heartbeat_options,
    aws_api_gateway_integration.heartbeat_options,
    aws_api_gateway_integration.generateid_options,
    aws_api_gateway_integration.organizations_orgid_options,
    aws_api_gateway_integration.organizations_options,
    aws_api_gateway_integration.v2_organizations_orgid_options,
    aws_api_gateway_integration.v2_organizations_options,
    aws_api_gateway_integration_response.v1_proxy,
    aws_api_gateway_integration_response.v2_proxy,
    aws_api_gateway_integration_response.root_proxy,
    aws_api_gateway_integration_response.v1_heartbeat_get,
    aws_api_gateway_integration_response.v2_heartbeat_get,
    aws_api_gateway_integration_response.heartbeat_get,
    aws_api_gateway_integration_response.generateid_get,
    aws_api_gateway_integration_response.organizations_orgid_get,
    aws_api_gateway_integration_response.organizations_any,
    aws_api_gateway_integration_response.v2_organizations_orgid_get,
    aws_api_gateway_integration_response.v2_organizations_any,
    aws_api_gateway_integration_response.v1_proxy_options,
    aws_api_gateway_integration_response.v2_proxy_options,
    aws_api_gateway_integration_response.root_proxy_options,
    aws_api_gateway_integration_response.v1_heartbeat_options,
    aws_api_gateway_integration_response.v2_heartbeat_options,
    aws_api_gateway_integration_response.heartbeat_options,
    aws_api_gateway_integration_response.generateid_options,
    aws_api_gateway_integration_response.organizations_orgid_options,
    aws_api_gateway_integration_response.organizations_options,
    aws_api_gateway_integration_response.v2_organizations_orgid_options,
    aws_api_gateway_integration_response.v2_organizations_options,
    aws_api_gateway_method.root_proxy,
    aws_api_gateway_method.heartbeat_get,
    aws_api_gateway_method.generateid_get,
    aws_api_gateway_method.v1_proxy_options,
    aws_api_gateway_method.v2_proxy_options,
    aws_api_gateway_method.root_proxy_options,
    aws_api_gateway_method.v1_heartbeat_options,
    aws_api_gateway_method.v2_heartbeat_options,
    aws_api_gateway_method.heartbeat_options,
    aws_api_gateway_method.generateid_options
  ]
  
  lifecycle {
    create_before_destroy = true
  }
}