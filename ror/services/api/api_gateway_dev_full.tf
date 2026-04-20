# =============================================================================
# API GATEWAY DEV - DEDICATED GATEWAY
# Independent gateway for dev environment, separate from shared gateway
# =============================================================================

# Data sources for access logging ARN construction
data "aws_region" "dev_gateway" {}
data "aws_caller_identity" "dev_gateway" {}

locals {
  cors_allow_headers_dev       = "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent,Client-Id"
  dev_full_api_deployment_hash = sha1(file("${path.module}/api_gateway_dev_full.tf"))
}

# =============================================================================
# API GATEWAY REST API
# =============================================================================

resource "aws_api_gateway_rest_api" "api_gateway_dev" {
  name        = "ror-api-dev"
  description = "ROR API Gateway - Dev environment (dedicated)"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = {
    environment = "ror-dev"
    purpose     = "api-gateway"
  }
}

# =============================================================================
# ENDPOINT RESOURCES
# =============================================================================

# v1 resource
resource "aws_api_gateway_resource" "v1_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  parent_id   = aws_api_gateway_rest_api.api_gateway_dev.root_resource_id
  path_part   = "v1"
}

# v2 resource
resource "aws_api_gateway_resource" "v2_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  parent_id   = aws_api_gateway_rest_api.api_gateway_dev.root_resource_id
  path_part   = "v2"
}

# v1/{proxy+} resource
resource "aws_api_gateway_resource" "v1_proxy_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  parent_id   = aws_api_gateway_resource.v1_dev.id
  path_part   = "{proxy+}"
}

# v2/{proxy+} resource
resource "aws_api_gateway_resource" "v2_proxy_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  parent_id   = aws_api_gateway_resource.v2_dev.id
  path_part   = "{proxy+}"
}

# v1/heartbeat resource
resource "aws_api_gateway_resource" "v1_heartbeat_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  parent_id   = aws_api_gateway_resource.v1_dev.id
  path_part   = "heartbeat"
}

# v2/heartbeat resource
resource "aws_api_gateway_resource" "v2_heartbeat_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  parent_id   = aws_api_gateway_resource.v2_dev.id
  path_part   = "heartbeat"
}

# v2/organizations resource
resource "aws_api_gateway_resource" "v2_organizations_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  parent_id   = aws_api_gateway_resource.v2_dev.id
  path_part   = "organizations"
}

# v2/organizations/{orgid} resource
resource "aws_api_gateway_resource" "v2_organizations_orgid_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  parent_id   = aws_api_gateway_resource.v2_organizations_dev.id
  path_part   = "{orgid}"
}

# Root /{proxy+} resource
resource "aws_api_gateway_resource" "root_proxy_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  parent_id   = aws_api_gateway_rest_api.api_gateway_dev.root_resource_id
  path_part   = "{proxy+}"
}

# Root /heartbeat resource
resource "aws_api_gateway_resource" "heartbeat_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  parent_id   = aws_api_gateway_rest_api.api_gateway_dev.root_resource_id
  path_part   = "heartbeat"
}

# Root /generateid resource
resource "aws_api_gateway_resource" "generateid_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  parent_id   = aws_api_gateway_rest_api.api_gateway_dev.root_resource_id
  path_part   = "generateid"
}

# Root /organizations resource
resource "aws_api_gateway_resource" "organizations_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  parent_id   = aws_api_gateway_rest_api.api_gateway_dev.root_resource_id
  path_part   = "organizations"
}

# /organizations/{orgid} resource
resource "aws_api_gateway_resource" "organizations_orgid_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  parent_id   = aws_api_gateway_resource.organizations_dev.id
  path_part   = "{orgid}"
}

# =============================================================================
# METHODS
# =============================================================================

# Root path GET method
resource "aws_api_gateway_method" "root_get_dev" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id   = aws_api_gateway_rest_api.api_gateway_dev.root_resource_id
  http_method   = "GET"
  authorization = "NONE"
}

# v1/heartbeat GET method
resource "aws_api_gateway_method" "v1_heartbeat_get_dev" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id   = aws_api_gateway_resource.v1_heartbeat_dev.id
  http_method   = "GET"
  authorization = "NONE"
}

# v2/heartbeat GET method
resource "aws_api_gateway_method" "v2_heartbeat_get_dev" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id   = aws_api_gateway_resource.v2_heartbeat_dev.id
  http_method   = "GET"
  authorization = "NONE"
}

# /heartbeat GET method
resource "aws_api_gateway_method" "heartbeat_get_dev" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id   = aws_api_gateway_resource.heartbeat_dev.id
  http_method   = "GET"
  authorization = "NONE"
}

# /generateid GET method
resource "aws_api_gateway_method" "generateid_get_dev" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id   = aws_api_gateway_resource.generateid_dev.id
  http_method   = "GET"
  authorization = "NONE"
}

# /organizations/{orgid} GET method
resource "aws_api_gateway_method" "organizations_orgid_get_dev" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id   = aws_api_gateway_resource.organizations_orgid_dev.id
  http_method   = "GET"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.orgid" = true
  }
}

# /organizations ANY method
resource "aws_api_gateway_method" "organizations_any_dev" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id   = aws_api_gateway_resource.organizations_dev.id
  http_method   = "ANY"
  authorization = "NONE"

  request_parameters = {
    "method.request.querystring.query"          = false
    "method.request.querystring.page"           = false
    "method.request.querystring.affiliation"    = false
    "method.request.querystring.filter"         = false
    "method.request.querystring.format"         = false
    "method.request.querystring.all_status"     = false
    "method.request.querystring.query.advanced" = false
    "method.request.querystring.query.name"     = false
    "method.request.querystring.query.names"    = false
    "method.request.querystring.page_size"      = false
    "method.request.querystring.single_search"  = false
    "method.request.querystring.multisearch"    = false
  }
}

# v2/organizations/{orgid} GET method
resource "aws_api_gateway_method" "v2_organizations_orgid_get_dev" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id   = aws_api_gateway_resource.v2_organizations_orgid_dev.id
  http_method   = "GET"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.orgid" = true
  }
}

# v2/organizations ANY method
resource "aws_api_gateway_method" "v2_organizations_any_dev" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id   = aws_api_gateway_resource.v2_organizations_dev.id
  http_method   = "ANY"
  authorization = "NONE"

  request_parameters = {
    "method.request.querystring.query"          = false
    "method.request.querystring.page"           = false
    "method.request.querystring.affiliation"    = false
    "method.request.querystring.filter"         = false
    "method.request.querystring.format"         = false
    "method.request.querystring.all_status"     = false
    "method.request.querystring.query.advanced" = false
    "method.request.querystring.query.name"     = false
    "method.request.querystring.query.names"    = false
    "method.request.querystring.page_size"      = false
    "method.request.querystring.single_search"  = false
    "method.request.querystring.multisearch"    = false
  }
}

# v1/{proxy+} ANY method
resource "aws_api_gateway_method" "v1_proxy_dev" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id   = aws_api_gateway_resource.v1_proxy_dev.id
  http_method   = "ANY"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.proxy"                 = true
    "method.request.querystring.query"          = false
    "method.request.querystring.page"           = false
    "method.request.querystring.affiliation"    = false
    "method.request.querystring.filter"         = false
    "method.request.querystring.format"         = false
    "method.request.querystring.all_status"     = false
    "method.request.querystring.query.advanced" = false
    "method.request.querystring.query.name"     = false
    "method.request.querystring.query.names"    = false
    "method.request.querystring.page_size"      = false
  }
}

# v2/{proxy+} ANY method
resource "aws_api_gateway_method" "v2_proxy_dev" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id   = aws_api_gateway_resource.v2_proxy_dev.id
  http_method   = "ANY"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.proxy"                 = true
    "method.request.querystring.query"          = false
    "method.request.querystring.page"           = false
    "method.request.querystring.affiliation"    = false
    "method.request.querystring.filter"         = false
    "method.request.querystring.format"         = false
    "method.request.querystring.all_status"     = false
    "method.request.querystring.query.advanced" = false
    "method.request.querystring.query.name"     = false
    "method.request.querystring.query.names"    = false
    "method.request.querystring.page_size"      = false
    "method.request.querystring.single_search"  = false
    "method.request.querystring.multisearch"    = false
  }
}

# Root /{proxy+} ANY method
resource "aws_api_gateway_method" "root_proxy_dev" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id   = aws_api_gateway_resource.root_proxy_dev.id
  http_method   = "ANY"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.proxy"                 = true
    "method.request.querystring.page"           = false
    "method.request.querystring.query"          = false
    "method.request.querystring.affiliation"    = false
    "method.request.querystring.filter"         = false
    "method.request.querystring.format"         = false
    "method.request.querystring.query.name"     = false
    "method.request.querystring.query.names"    = false
    "method.request.querystring.all_status"     = false
    "method.request.querystring.query.advanced" = false
    "method.request.querystring.page_size"      = false
    "method.request.querystring.single_search"  = false
    "method.request.querystring.multisearch"    = false
  }
}

# =============================================================================
# METHOD RESPONSES
# =============================================================================

# Root path method response
resource "aws_api_gateway_method_response" "root_get_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_rest_api.api_gateway_dev.root_resource_id
  http_method = aws_api_gateway_method.root_get_dev.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Content-Type"                = true
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

# Method response for v1/heartbeat - 410 Gone
resource "aws_api_gateway_method_response" "v1_heartbeat_get_410_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.v1_heartbeat_dev.id
  http_method = aws_api_gateway_method.v1_heartbeat_get_dev.http_method
  status_code = "410"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

# Method response for v2/heartbeat
resource "aws_api_gateway_method_response" "v2_heartbeat_get_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.v2_heartbeat_dev.id
  http_method = aws_api_gateway_method.v2_heartbeat_get_dev.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

# Method response for root /{proxy+}
resource "aws_api_gateway_method_response" "root_proxy_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.root_proxy_dev.id
  http_method = aws_api_gateway_method.root_proxy_dev.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

# Method response for root /heartbeat
resource "aws_api_gateway_method_response" "heartbeat_get_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.heartbeat_dev.id
  http_method = aws_api_gateway_method.heartbeat_get_dev.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

# Method response for root /generateid
resource "aws_api_gateway_method_response" "generateid_get_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.generateid_dev.id
  http_method = aws_api_gateway_method.generateid_get_dev.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

# Method response for /organizations/{orgid}
resource "aws_api_gateway_method_response" "organizations_orgid_get_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.organizations_orgid_dev.id
  http_method = aws_api_gateway_method.organizations_orgid_get_dev.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

# Method response for /organizations ANY
resource "aws_api_gateway_method_response" "organizations_any_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.organizations_dev.id
  http_method = aws_api_gateway_method.organizations_any_dev.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

# Method response for v2/organizations/{orgid}
resource "aws_api_gateway_method_response" "v2_organizations_orgid_get_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.v2_organizations_orgid_dev.id
  http_method = aws_api_gateway_method.v2_organizations_orgid_get_dev.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

# Method response for v2/organizations ANY
resource "aws_api_gateway_method_response" "v2_organizations_any_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.v2_organizations_dev.id
  http_method = aws_api_gateway_method.v2_organizations_any_dev.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

# Method response for v1/{proxy+} - 410 Gone
resource "aws_api_gateway_method_response" "v1_proxy_410_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.v1_proxy_dev.id
  http_method = aws_api_gateway_method.v1_proxy_dev.http_method
  status_code = "410"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

# Method response for v2/{proxy+}
resource "aws_api_gateway_method_response" "v2_proxy_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.v2_proxy_dev.id
  http_method = aws_api_gateway_method.v2_proxy_dev.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

# =============================================================================
# INTEGRATIONS
# =============================================================================

# Root path integration (mock)
resource "aws_api_gateway_integration" "root_get_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_rest_api.api_gateway_dev.root_resource_id
  http_method = aws_api_gateway_method.root_get_dev.http_method

  type = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# Integration for v1/heartbeat - Return 410 Gone
resource "aws_api_gateway_integration" "v1_heartbeat_get_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.v1_heartbeat_dev.id
  http_method = aws_api_gateway_method.v1_heartbeat_get_dev.http_method

  type = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 410}"
  }
}

# Integration for v2/heartbeat
resource "aws_api_gateway_integration" "v2_heartbeat_get_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.v2_heartbeat_dev.id
  http_method = aws_api_gateway_method.v2_heartbeat_get_dev.http_method

  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  uri                     = "https://$${stageVariables.backend_host}/v2/heartbeat"

  request_parameters = {
    "integration.request.header.Host"                    = "stageVariables.api_host"
    "integration.request.header.X-ROR-API-Gateway-Token" = "'${var.api_gateway_token}'"
  }
}

# Integration for root /heartbeat
resource "aws_api_gateway_integration" "heartbeat_get_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.heartbeat_dev.id
  http_method = aws_api_gateway_method.heartbeat_get_dev.http_method

  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  uri                     = "https://$${stageVariables.backend_host}/heartbeat"

  request_parameters = {
    "integration.request.header.Host"                    = "stageVariables.api_host"
    "integration.request.header.X-ROR-API-Gateway-Token" = "'${var.api_gateway_token}'"
  }
}

# Integration for root /generateid
resource "aws_api_gateway_integration" "generateid_get_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.generateid_dev.id
  http_method = aws_api_gateway_method.generateid_get_dev.http_method

  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  uri                     = "https://$${stageVariables.backend_host}/generateid"

  request_parameters = {
    "integration.request.header.Host"                    = "stageVariables.api_host"
    "integration.request.header.X-ROR-API-Gateway-Token" = "'${var.api_gateway_token}'"
  }
}

# Integration for /organizations/{orgid}
resource "aws_api_gateway_integration" "organizations_orgid_get_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.organizations_orgid_dev.id
  http_method = aws_api_gateway_method.organizations_orgid_get_dev.http_method

  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  uri                     = "https://$${stageVariables.backend_host}/organizations/{orgid}"

  request_parameters = {
    "integration.request.path.orgid"                     = "method.request.path.orgid"
    "integration.request.header.Host"                    = "stageVariables.api_host"
    "integration.request.header.X-ROR-API-Gateway-Token" = "'${var.api_gateway_token}'"
  }
}

# Integration for /organizations ANY
resource "aws_api_gateway_integration" "organizations_any_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.organizations_dev.id
  http_method = aws_api_gateway_method.organizations_any_dev.http_method

  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "https://$${stageVariables.backend_host}/organizations"

  request_parameters = {
    "integration.request.header.Host"                    = "stageVariables.api_host"
    "integration.request.header.X-ROR-API-Gateway-Token" = "'${var.api_gateway_token}'"
    "integration.request.querystring.query"              = "method.request.querystring.query"
    "integration.request.querystring.page"               = "method.request.querystring.page"
    "integration.request.querystring.affiliation"        = "method.request.querystring.affiliation"
    "integration.request.querystring.filter"             = "method.request.querystring.filter"
    "integration.request.querystring.format"             = "method.request.querystring.format"
    "integration.request.querystring.all_status"         = "method.request.querystring.all_status"
    "integration.request.querystring.query.advanced"     = "method.request.querystring.query.advanced"
    "integration.request.querystring.query.name"         = "method.request.querystring.query.name"
    "integration.request.querystring.query.names"        = "method.request.querystring.query.names"
    "integration.request.querystring.page_size"          = "method.request.querystring.page_size"
    "integration.request.querystring.single_search"      = "method.request.querystring.single_search"
    "integration.request.querystring.multisearch"        = "method.request.querystring.multisearch"
  }

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
    "method.request.querystring.single_search",
    "method.request.querystring.multisearch"
  ]
  cache_namespace = "organizations-dev"
}

# Integration for v2/organizations/{orgid}
resource "aws_api_gateway_integration" "v2_organizations_orgid_get_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.v2_organizations_orgid_dev.id
  http_method = aws_api_gateway_method.v2_organizations_orgid_get_dev.http_method

  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  uri                     = "https://$${stageVariables.backend_host}/v2/organizations/{orgid}"

  request_parameters = {
    "integration.request.path.orgid"                     = "method.request.path.orgid"
    "integration.request.header.Host"                    = "stageVariables.api_host"
    "integration.request.header.X-ROR-API-Gateway-Token" = "'${var.api_gateway_token}'"
  }
}

# Integration for v2/organizations ANY
resource "aws_api_gateway_integration" "v2_organizations_any_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.v2_organizations_dev.id
  http_method = aws_api_gateway_method.v2_organizations_any_dev.http_method

  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "https://$${stageVariables.backend_host}/v2/organizations"

  request_parameters = {
    "integration.request.header.Host"                    = "stageVariables.api_host"
    "integration.request.header.X-ROR-API-Gateway-Token" = "'${var.api_gateway_token}'"
    "integration.request.querystring.query"              = "method.request.querystring.query"
    "integration.request.querystring.page"               = "method.request.querystring.page"
    "integration.request.querystring.affiliation"        = "method.request.querystring.affiliation"
    "integration.request.querystring.filter"             = "method.request.querystring.filter"
    "integration.request.querystring.format"             = "method.request.querystring.format"
    "integration.request.querystring.all_status"         = "method.request.querystring.all_status"
    "integration.request.querystring.query.advanced"     = "method.request.querystring.query.advanced"
    "integration.request.querystring.query.name"         = "method.request.querystring.query.name"
    "integration.request.querystring.query.names"        = "method.request.querystring.query.names"
    "integration.request.querystring.page_size"          = "method.request.querystring.page_size"
    "integration.request.querystring.single_search"      = "method.request.querystring.single_search"
    "integration.request.querystring.multisearch"        = "method.request.querystring.multisearch"
  }

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
    "method.request.querystring.single_search",
    "method.request.querystring.multisearch"
  ]
  cache_namespace = "v2-organizations-dev"
}

# Integration for v1/{proxy+} - Return 410 Gone
resource "aws_api_gateway_integration" "v1_proxy_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.v1_proxy_dev.id
  http_method = aws_api_gateway_method.v1_proxy_dev.http_method

  type = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 410}"
  }
}

# Integration for v2/{proxy+}
resource "aws_api_gateway_integration" "v2_proxy_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.v2_proxy_dev.id
  http_method = aws_api_gateway_method.v2_proxy_dev.http_method

  type                    = "HTTP_PROXY"
  integration_http_method = "ANY"
  uri                     = "https://$${stageVariables.backend_host}/v2/{proxy}"

  request_parameters = {
    "integration.request.path.proxy"                     = "method.request.path.proxy"
    "integration.request.header.Host"                    = "stageVariables.api_host"
    "integration.request.header.X-ROR-API-Gateway-Token" = "'${var.api_gateway_token}'"
    "integration.request.querystring.query"              = "method.request.querystring.query"
    "integration.request.querystring.page"               = "method.request.querystring.page"
    "integration.request.querystring.affiliation"        = "method.request.querystring.affiliation"
    "integration.request.querystring.filter"             = "method.request.querystring.filter"
    "integration.request.querystring.format"             = "method.request.querystring.format"
    "integration.request.querystring.all_status"         = "method.request.querystring.all_status"
    "integration.request.querystring.query.advanced"     = "method.request.querystring.query.advanced"
    "integration.request.querystring.query.name"         = "method.request.querystring.query.name"
    "integration.request.querystring.query.names"        = "method.request.querystring.query.names"
    "integration.request.querystring.page_size"          = "method.request.querystring.page_size"
    "integration.request.querystring.single_search"      = "method.request.querystring.single_search"
    "integration.request.querystring.multisearch"        = "method.request.querystring.multisearch"
  }

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
    "method.request.querystring.single_search",
    "method.request.querystring.multisearch"
  ]
  cache_namespace = "v2-proxy-dev"
}

# Integration for /{proxy+}
resource "aws_api_gateway_integration" "root_proxy_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.root_proxy_dev.id
  http_method = aws_api_gateway_method.root_proxy_dev.http_method

  type                    = "HTTP_PROXY"
  integration_http_method = "ANY"
  uri                     = "https://$${stageVariables.backend_host}/{proxy}"

  request_parameters = {
    "integration.request.path.proxy"                     = "method.request.path.proxy"
    "integration.request.header.Host"                    = "stageVariables.api_host"
    "integration.request.header.X-ROR-API-Gateway-Token" = "'${var.api_gateway_token}'"
    "integration.request.querystring.query"              = "method.request.querystring.query"
    "integration.request.querystring.page"               = "method.request.querystring.page"
    "integration.request.querystring.affiliation"        = "method.request.querystring.affiliation"
    "integration.request.querystring.filter"             = "method.request.querystring.filter"
    "integration.request.querystring.format"             = "method.request.querystring.format"
    "integration.request.querystring.all_status"         = "method.request.querystring.all_status"
    "integration.request.querystring.query.advanced"     = "method.request.querystring.query.advanced"
    "integration.request.querystring.query.name"         = "method.request.querystring.query.name"
    "integration.request.querystring.query.names"        = "method.request.querystring.query.names"
    "integration.request.querystring.page_size"          = "method.request.querystring.page_size"
    "integration.request.querystring.single_search"      = "method.request.querystring.single_search"
    "integration.request.querystring.multisearch"        = "method.request.querystring.multisearch"
  }

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
    "method.request.querystring.single_search",
    "method.request.querystring.multisearch"
  ]
  cache_namespace = "root-proxy-dev"
}

# =============================================================================
# INTEGRATION RESPONSES
# =============================================================================

# Root path integration response
resource "aws_api_gateway_integration_response" "root_get_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_rest_api.api_gateway_dev.root_resource_id
  http_method = aws_api_gateway_method.root_get_dev.http_method
  status_code = aws_api_gateway_method_response.root_get_dev.status_code

  response_parameters = {
    "method.response.header.Content-Type"                = "'application/json'"
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  response_templates = {
    "application/json" = "{\"organizations\":\"https://$${stageVariables.api_host}/v2/organizations\"}"
  }
}

# Integration response for v1/heartbeat - 410 Gone
resource "aws_api_gateway_integration_response" "v1_heartbeat_get_410_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.v1_heartbeat_dev.id
  http_method = aws_api_gateway_method.v1_heartbeat_get_dev.http_method
  status_code = "410"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'${local.cors_allow_headers_dev}'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,HEAD,OPTIONS'"
  }

  response_templates = {
    "application/json" = "{\"errors\":[{\"status\":\"410\",\"title\":\"API Version Deprecated\",\"detail\":\"The v1 API has been deprecated. Please migrate to v2.\",\"deprecated_at\":\"2025-12-09\"}]}"
  }

  depends_on = [
    aws_api_gateway_method_response.v1_heartbeat_get_410_dev
  ]
}

# Integration response for v2/heartbeat
resource "aws_api_gateway_integration_response" "v2_heartbeat_get_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.v2_heartbeat_dev.id
  http_method = aws_api_gateway_method.v2_heartbeat_get_dev.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'${local.cors_allow_headers_dev}'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,HEAD,OPTIONS'"
  }
}

# Integration response for root /heartbeat
resource "aws_api_gateway_integration_response" "heartbeat_get_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.heartbeat_dev.id
  http_method = aws_api_gateway_method.heartbeat_get_dev.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'${local.cors_allow_headers_dev}'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,HEAD,OPTIONS'"
  }
}

# Integration response for root /generateid
resource "aws_api_gateway_integration_response" "generateid_get_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.generateid_dev.id
  http_method = aws_api_gateway_method.generateid_get_dev.http_method
  status_code = "200"

  depends_on = [
    aws_api_gateway_integration.generateid_get_dev
  ]

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'${local.cors_allow_headers_dev}'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,HEAD,OPTIONS'"
  }
}

# Integration response for /organizations/{orgid}
resource "aws_api_gateway_integration_response" "organizations_orgid_get_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.organizations_orgid_dev.id
  http_method = aws_api_gateway_method.organizations_orgid_get_dev.http_method
  status_code = "200"

  depends_on = [
    aws_api_gateway_integration.organizations_orgid_get_dev
  ]

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'${local.cors_allow_headers_dev}'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }
}

# Integration response for /organizations ANY
resource "aws_api_gateway_integration_response" "organizations_any_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.organizations_dev.id
  http_method = aws_api_gateway_method.organizations_any_dev.http_method
  status_code = "200"

  depends_on = [
    aws_api_gateway_integration.organizations_any_dev
  ]

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'${local.cors_allow_headers_dev}'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,HEAD,OPTIONS'"
  }
}

# Integration response for v2/organizations/{orgid}
resource "aws_api_gateway_integration_response" "v2_organizations_orgid_get_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.v2_organizations_orgid_dev.id
  http_method = aws_api_gateway_method.v2_organizations_orgid_get_dev.http_method
  status_code = "200"

  depends_on = [
    aws_api_gateway_integration.v2_organizations_orgid_get_dev
  ]

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'${local.cors_allow_headers_dev}'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }
}

# Integration response for v2/organizations ANY
resource "aws_api_gateway_integration_response" "v2_organizations_any_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.v2_organizations_dev.id
  http_method = aws_api_gateway_method.v2_organizations_any_dev.http_method
  status_code = "200"

  depends_on = [
    aws_api_gateway_integration.v2_organizations_any_dev
  ]

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'${local.cors_allow_headers_dev}'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,HEAD,OPTIONS'"
  }
}

# Integration response for v1/{proxy+} - 410 Gone
resource "aws_api_gateway_integration_response" "v1_proxy_410_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.v1_proxy_dev.id
  http_method = aws_api_gateway_method.v1_proxy_dev.http_method
  status_code = "410"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'${local.cors_allow_headers_dev}'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,HEAD,OPTIONS'"
  }

  response_templates = {
    "application/json" = "{\"errors\":[{\"status\":\"410\",\"title\":\"API Version Deprecated\",\"detail\":\"The v1 API has been deprecated. Please migrate to v2.\",\"deprecated_at\":\"2025-12-09\"}]}"
  }

  depends_on = [
    aws_api_gateway_method_response.v1_proxy_410_dev
  ]
}

# Integration response for v2/{proxy+}
resource "aws_api_gateway_integration_response" "v2_proxy_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.v2_proxy_dev.id
  http_method = aws_api_gateway_method.v2_proxy_dev.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'${local.cors_allow_headers_dev}'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,HEAD,OPTIONS'"
  }
}

# Integration response for /{proxy+}
resource "aws_api_gateway_integration_response" "root_proxy_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.root_proxy_dev.id
  http_method = aws_api_gateway_method.root_proxy_dev.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'${local.cors_allow_headers_dev}'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,HEAD,OPTIONS'"
  }
}

# =============================================================================
# CORS OPTIONS METHODS
# =============================================================================

resource "aws_api_gateway_method" "v1_proxy_options_dev" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id   = aws_api_gateway_resource.v1_proxy_dev.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "v2_proxy_options_dev" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id   = aws_api_gateway_resource.v2_proxy_dev.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "root_proxy_options_dev" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id   = aws_api_gateway_resource.root_proxy_dev.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "v1_heartbeat_options_dev" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id   = aws_api_gateway_resource.v1_heartbeat_dev.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "v2_heartbeat_options_dev" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id   = aws_api_gateway_resource.v2_heartbeat_dev.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "heartbeat_options_dev" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id   = aws_api_gateway_resource.heartbeat_dev.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "generateid_options_dev" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id   = aws_api_gateway_resource.generateid_dev.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "organizations_orgid_options_dev" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id   = aws_api_gateway_resource.organizations_orgid_dev.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "organizations_options_dev" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id   = aws_api_gateway_resource.organizations_dev.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "v2_organizations_orgid_options_dev" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id   = aws_api_gateway_resource.v2_organizations_orgid_dev.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "v2_organizations_options_dev" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id   = aws_api_gateway_resource.v2_organizations_dev.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# =============================================================================
# CORS METHOD RESPONSES
# =============================================================================

resource "aws_api_gateway_method_response" "v1_proxy_options_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.v1_proxy_dev.id
  http_method = aws_api_gateway_method.v1_proxy_options_dev.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Max-Age"       = true
  }
}

resource "aws_api_gateway_method_response" "v2_proxy_options_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.v2_proxy_dev.id
  http_method = aws_api_gateway_method.v2_proxy_options_dev.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Max-Age"       = true
  }
}

resource "aws_api_gateway_method_response" "root_proxy_options_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.root_proxy_dev.id
  http_method = aws_api_gateway_method.root_proxy_options_dev.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Max-Age"       = true
  }
}

resource "aws_api_gateway_method_response" "v1_heartbeat_options_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.v1_heartbeat_dev.id
  http_method = aws_api_gateway_method.v1_heartbeat_options_dev.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Max-Age"       = true
  }
}

resource "aws_api_gateway_method_response" "v2_heartbeat_options_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.v2_heartbeat_dev.id
  http_method = aws_api_gateway_method.v2_heartbeat_options_dev.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Max-Age"       = true
  }
}

resource "aws_api_gateway_method_response" "heartbeat_options_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.heartbeat_dev.id
  http_method = aws_api_gateway_method.heartbeat_options_dev.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Max-Age"       = true
  }
}

resource "aws_api_gateway_method_response" "generateid_options_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.generateid_dev.id
  http_method = aws_api_gateway_method.generateid_options_dev.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Max-Age"       = true
  }
}

resource "aws_api_gateway_method_response" "organizations_orgid_options_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.organizations_orgid_dev.id
  http_method = aws_api_gateway_method.organizations_orgid_options_dev.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Max-Age"       = true
  }
}

resource "aws_api_gateway_method_response" "organizations_options_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.organizations_dev.id
  http_method = aws_api_gateway_method.organizations_options_dev.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Max-Age"       = true
  }
}

resource "aws_api_gateway_method_response" "v2_organizations_orgid_options_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.v2_organizations_orgid_dev.id
  http_method = aws_api_gateway_method.v2_organizations_orgid_options_dev.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Max-Age"       = true
  }
}

resource "aws_api_gateway_method_response" "v2_organizations_options_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.v2_organizations_dev.id
  http_method = aws_api_gateway_method.v2_organizations_options_dev.http_method
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

resource "aws_api_gateway_integration" "v1_proxy_options_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.v1_proxy_dev.id
  http_method = aws_api_gateway_method.v1_proxy_options_dev.http_method

  type = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration" "v2_proxy_options_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.v2_proxy_dev.id
  http_method = aws_api_gateway_method.v2_proxy_options_dev.http_method

  type = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration" "root_proxy_options_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.root_proxy_dev.id
  http_method = aws_api_gateway_method.root_proxy_options_dev.http_method

  type = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration" "v1_heartbeat_options_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.v1_heartbeat_dev.id
  http_method = aws_api_gateway_method.v1_heartbeat_options_dev.http_method

  type = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration" "v2_heartbeat_options_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.v2_heartbeat_dev.id
  http_method = aws_api_gateway_method.v2_heartbeat_options_dev.http_method

  type = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration" "heartbeat_options_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.heartbeat_dev.id
  http_method = aws_api_gateway_method.heartbeat_options_dev.http_method

  type = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration" "generateid_options_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.generateid_dev.id
  http_method = aws_api_gateway_method.generateid_options_dev.http_method

  type = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration" "organizations_orgid_options_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.organizations_orgid_dev.id
  http_method = aws_api_gateway_method.organizations_orgid_options_dev.http_method

  type = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration" "organizations_options_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.organizations_dev.id
  http_method = aws_api_gateway_method.organizations_options_dev.http_method

  type = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration" "v2_organizations_orgid_options_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.v2_organizations_orgid_dev.id
  http_method = aws_api_gateway_method.v2_organizations_orgid_options_dev.http_method

  type = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration" "v2_organizations_options_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.v2_organizations_dev.id
  http_method = aws_api_gateway_method.v2_organizations_options_dev.http_method

  type = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# =============================================================================
# CORS INTEGRATION RESPONSES
# =============================================================================

resource "aws_api_gateway_integration_response" "v1_proxy_options_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.v1_proxy_dev.id
  http_method = aws_api_gateway_method.v1_proxy_options_dev.http_method
  status_code = aws_api_gateway_method_response.v1_proxy_options_dev.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'${local.cors_allow_headers_dev}'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,HEAD,OPTIONS'"
    "method.response.header.Access-Control-Max-Age"       = "'86400'"
  }
}

resource "aws_api_gateway_integration_response" "v2_proxy_options_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.v2_proxy_dev.id
  http_method = aws_api_gateway_method.v2_proxy_options_dev.http_method
  status_code = aws_api_gateway_method_response.v2_proxy_options_dev.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'${local.cors_allow_headers_dev}'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,HEAD,OPTIONS'"
    "method.response.header.Access-Control-Max-Age"       = "'86400'"
  }
}

resource "aws_api_gateway_integration_response" "root_proxy_options_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.root_proxy_dev.id
  http_method = aws_api_gateway_method.root_proxy_options_dev.http_method
  status_code = aws_api_gateway_method_response.root_proxy_options_dev.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'${local.cors_allow_headers_dev}'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,HEAD,OPTIONS'"
    "method.response.header.Access-Control-Max-Age"       = "'86400'"
  }
}

resource "aws_api_gateway_integration_response" "v1_heartbeat_options_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.v1_heartbeat_dev.id
  http_method = aws_api_gateway_method.v1_heartbeat_options_dev.http_method
  status_code = aws_api_gateway_method_response.v1_heartbeat_options_dev.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'${local.cors_allow_headers_dev}'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,HEAD,OPTIONS'"
    "method.response.header.Access-Control-Max-Age"       = "'86400'"
  }
}

resource "aws_api_gateway_integration_response" "v2_heartbeat_options_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.v2_heartbeat_dev.id
  http_method = aws_api_gateway_method.v2_heartbeat_options_dev.http_method
  status_code = aws_api_gateway_method_response.v2_heartbeat_options_dev.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'${local.cors_allow_headers_dev}'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,HEAD,OPTIONS'"
    "method.response.header.Access-Control-Max-Age"       = "'86400'"
  }
}

resource "aws_api_gateway_integration_response" "heartbeat_options_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.heartbeat_dev.id
  http_method = aws_api_gateway_method.heartbeat_options_dev.http_method
  status_code = aws_api_gateway_method_response.heartbeat_options_dev.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'${local.cors_allow_headers_dev}'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,HEAD,OPTIONS'"
    "method.response.header.Access-Control-Max-Age"       = "'86400'"
  }
}

resource "aws_api_gateway_integration_response" "generateid_options_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.generateid_dev.id
  http_method = aws_api_gateway_method.generateid_options_dev.http_method
  status_code = aws_api_gateway_method_response.generateid_options_dev.status_code

  depends_on = [
    aws_api_gateway_integration.generateid_options_dev
  ]

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,HEAD,OPTIONS'"
    "method.response.header.Access-Control-Max-Age"       = "'86400'"
  }
}

resource "aws_api_gateway_integration_response" "organizations_orgid_options_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.organizations_orgid_dev.id
  http_method = aws_api_gateway_method.organizations_orgid_options_dev.http_method
  status_code = aws_api_gateway_method_response.organizations_orgid_options_dev.status_code

  depends_on = [
    aws_api_gateway_integration.organizations_orgid_options_dev
  ]

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'${local.cors_allow_headers_dev}'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
    "method.response.header.Access-Control-Max-Age"       = "'86400'"
  }
}

resource "aws_api_gateway_integration_response" "organizations_options_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.organizations_dev.id
  http_method = aws_api_gateway_method.organizations_options_dev.http_method
  status_code = aws_api_gateway_method_response.organizations_options_dev.status_code

  depends_on = [
    aws_api_gateway_integration.organizations_options_dev
  ]

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'${local.cors_allow_headers_dev}'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,HEAD,OPTIONS'"
    "method.response.header.Access-Control-Max-Age"       = "'86400'"
  }
}

resource "aws_api_gateway_integration_response" "v2_organizations_orgid_options_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.v2_organizations_orgid_dev.id
  http_method = aws_api_gateway_method.v2_organizations_orgid_options_dev.http_method
  status_code = aws_api_gateway_method_response.v2_organizations_orgid_options_dev.status_code

  depends_on = [
    aws_api_gateway_integration.v2_organizations_orgid_options_dev
  ]

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'${local.cors_allow_headers_dev}'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
    "method.response.header.Access-Control-Max-Age"       = "'86400'"
  }
}

resource "aws_api_gateway_integration_response" "v2_organizations_options_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.v2_organizations_dev.id
  http_method = aws_api_gateway_method.v2_organizations_options_dev.http_method
  status_code = aws_api_gateway_method_response.v2_organizations_options_dev.status_code

  depends_on = [
    aws_api_gateway_integration.v2_organizations_options_dev
  ]

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'${local.cors_allow_headers_dev}'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,HEAD,OPTIONS'"
    "method.response.header.Access-Control-Max-Age"       = "'86400'"
  }
}

# =============================================================================
# CLOUDWATCH LOG GROUP FOR ACCESS LOGS
# =============================================================================

resource "aws_cloudwatch_log_group" "api_gateway_dev_full_access_logs" {
  name              = "/aws/apigateway/ror-api-dev-full"
  retention_in_days = 30

  tags = {
    environment = "ror-dev"
    purpose     = "api-gateway-access-logs"
  }
}

resource "aws_cloudwatch_log_resource_policy" "api_gateway_dev_full_logs" {
  policy_name = "api-gateway-logs-policy-dev-full"

  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "${aws_cloudwatch_log_group.api_gateway_dev_full_access_logs.arn}:*"
      }
    ]
  })
}

# =============================================================================
# API GATEWAY DEPLOYMENT
# =============================================================================

resource "aws_api_gateway_deployment" "api_gateway_dev_full" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id

  triggers = {
    redeployment = local.dev_full_api_deployment_hash
  }

  depends_on = [
    aws_api_gateway_integration.v1_proxy_dev,
    aws_api_gateway_integration.v2_proxy_dev,
    aws_api_gateway_integration.root_proxy_dev,
    aws_api_gateway_integration.heartbeat_get_dev,
    aws_api_gateway_integration.v1_heartbeat_get_dev,
    aws_api_gateway_integration.v2_heartbeat_get_dev,
    aws_api_gateway_integration.root_get_dev,
    aws_api_gateway_integration.generateid_get_dev,
    aws_api_gateway_integration.organizations_orgid_get_dev,
    aws_api_gateway_integration.organizations_any_dev,
    aws_api_gateway_integration.v2_organizations_orgid_get_dev,
    aws_api_gateway_integration.v2_organizations_any_dev,
    aws_api_gateway_integration.v1_proxy_options_dev,
    aws_api_gateway_integration.v2_proxy_options_dev,
    aws_api_gateway_integration.root_proxy_options_dev,
    aws_api_gateway_integration.v1_heartbeat_options_dev,
    aws_api_gateway_integration.v2_heartbeat_options_dev,
    aws_api_gateway_integration.heartbeat_options_dev,
    aws_api_gateway_integration.generateid_options_dev,
    aws_api_gateway_integration.organizations_orgid_options_dev,
    aws_api_gateway_integration.organizations_options_dev,
    aws_api_gateway_integration.v2_organizations_orgid_options_dev,
    aws_api_gateway_integration.v2_organizations_options_dev,
    aws_api_gateway_integration_response.v1_proxy_410_dev,
    aws_api_gateway_integration_response.v2_proxy_dev,
    aws_api_gateway_integration_response.root_proxy_dev,
    aws_api_gateway_integration_response.v1_heartbeat_get_410_dev,
    aws_api_gateway_integration_response.v2_heartbeat_get_dev,
    aws_api_gateway_integration_response.heartbeat_get_dev,
    aws_api_gateway_integration_response.generateid_get_dev,
    aws_api_gateway_integration_response.organizations_orgid_get_dev,
    aws_api_gateway_integration_response.organizations_any_dev,
    aws_api_gateway_integration_response.v2_organizations_orgid_get_dev,
    aws_api_gateway_integration_response.v2_organizations_any_dev,
    aws_api_gateway_integration_response.v1_proxy_options_dev,
    aws_api_gateway_integration_response.v2_proxy_options_dev,
    aws_api_gateway_integration_response.root_proxy_options_dev,
    aws_api_gateway_integration_response.v1_heartbeat_options_dev,
    aws_api_gateway_integration_response.v2_heartbeat_options_dev,
    aws_api_gateway_integration_response.heartbeat_options_dev,
    aws_api_gateway_integration_response.generateid_options_dev,
    aws_api_gateway_integration_response.organizations_orgid_options_dev,
    aws_api_gateway_integration_response.organizations_options_dev,
    aws_api_gateway_integration_response.v2_organizations_orgid_options_dev,
    aws_api_gateway_integration_response.v2_organizations_options_dev
  ]

  lifecycle {
    create_before_destroy = true
  }
}

# =============================================================================
# API GATEWAY STAGE
# =============================================================================

resource "aws_api_gateway_stage" "api_gateway_dev_full" {
  deployment_id = aws_api_gateway_deployment.api_gateway_dev_full.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_dev.id
  stage_name    = "dev"

  cache_cluster_enabled = true
  cache_cluster_size    = "0.5"

  variables = {
    backend_host = "alb.dev.ror.org"
    api_host     = "api.dev.ror.org"
  }

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway_dev_full_access_logs.arn
    format = jsonencode({
      requestId            = "$context.requestId"
      requestTime          = "$context.requestTime"
      httpMethod           = "$context.httpMethod"
      path                 = "$context.path"
      resourcePath         = "$context.resourcePath"
      overrideResourcePath = "$context.requestOverride.path.resourcePath"
      status               = "$context.status"
      responseLatency      = "$context.responseLatency"
      integrationLatency   = "$context.integrationLatency"
      stage                = "$context.stage"
      sourceIp             = "$context.identity.sourceIp"
      userAgent            = "$context.identity.userAgent"
      error                = "$context.error.message"
      responseLength       = "$context.responseLength"
      wafStatus            = "$context.waf.status"
      wafResponseCode      = "$context.wafResponseCode"
    })
  }

  tags = {
    environment = "ror-dev"
    purpose     = "api-gateway-caching"
  }
}

# =============================================================================
# METHOD SETTINGS FOR CACHING
# =============================================================================

resource "aws_api_gateway_method_settings" "v2_proxy_cache_dev_full" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  stage_name  = aws_api_gateway_stage.api_gateway_dev_full.stage_name
  method_path = "v2/{proxy+}/GET"

  settings {
    caching_enabled                            = true
    cache_ttl_in_seconds                       = 300
    cache_data_encrypted                       = false
    require_authorization_for_cache_control    = true
    unauthorized_cache_control_header_strategy = "SUCCEED_WITHOUT_RESPONSE_HEADER"
    throttling_rate_limit                      = 10000
    throttling_burst_limit                     = 5000
  }
}

resource "aws_api_gateway_method_settings" "root_proxy_cache_dev_full" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  stage_name  = aws_api_gateway_stage.api_gateway_dev_full.stage_name
  method_path = "{proxy+}/GET"

  settings {
    caching_enabled                            = true
    cache_ttl_in_seconds                       = 300
    cache_data_encrypted                       = false
    require_authorization_for_cache_control    = true
    unauthorized_cache_control_header_strategy = "SUCCEED_WITHOUT_RESPONSE_HEADER"
    throttling_rate_limit                      = 10000
    throttling_burst_limit                     = 5000
  }
}

resource "aws_api_gateway_method_settings" "organizations_cache_dev_full" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  stage_name  = aws_api_gateway_stage.api_gateway_dev_full.stage_name
  method_path = "organizations/GET"

  settings {
    caching_enabled                            = true
    cache_ttl_in_seconds                       = 300
    cache_data_encrypted                       = false
    require_authorization_for_cache_control    = true
    unauthorized_cache_control_header_strategy = "SUCCEED_WITHOUT_RESPONSE_HEADER"
    throttling_rate_limit                      = 10000
    throttling_burst_limit                     = 5000
  }
}

resource "aws_api_gateway_method_settings" "v2_organizations_cache_dev_full" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  stage_name  = aws_api_gateway_stage.api_gateway_dev_full.stage_name
  method_path = "v2/organizations/GET"

  settings {
    caching_enabled                            = true
    cache_ttl_in_seconds                       = 300
    cache_data_encrypted                       = false
    require_authorization_for_cache_control    = true
    unauthorized_cache_control_header_strategy = "SUCCEED_WITHOUT_RESPONSE_HEADER"
    throttling_rate_limit                      = 10000
    throttling_burst_limit                     = 5000
  }
}

resource "aws_api_gateway_method_settings" "metrics_and_logging_dev_full" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  stage_name  = aws_api_gateway_stage.api_gateway_dev_full.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled        = true
    logging_level          = "ERROR"
    data_trace_enabled     = false
    throttling_rate_limit  = 10000
    throttling_burst_limit = 5000
  }
}

# =============================================================================
# WAF ASSOCIATION
# =============================================================================

resource "aws_wafv2_web_acl_association" "api_gateway_dev_full" {
  resource_arn = aws_api_gateway_stage.api_gateway_dev_full.arn
  web_acl_arn  = data.aws_wafv2_web_acl.dev-v2.arn
}