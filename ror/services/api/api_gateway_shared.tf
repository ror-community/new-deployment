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

# v1/organizations/{id} resource - simple proxy for ID lookups
resource "aws_api_gateway_resource" "v1_organizations_id" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_organizations.id
  path_part   = "{id}"
}

# v2/organizations resource
resource "aws_api_gateway_resource" "v2_organizations" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2.id
  path_part   = "organizations"
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
    "method.request.querystring.all_status" = false
    "method.request.querystring.query.advanced" = false
    "method.request.querystring.page_size" = false
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
    "method.request.querystring.all_status" = false
    "method.request.querystring.query.advanced" = false
    "method.request.querystring.page_size" = false
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

# v1/organizations ANY method (catches all query params)
resource "aws_api_gateway_method" "v1_organizations_proxy_get" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.v1_organizations.id
  http_method   = "ANY"
  authorization = "NONE"
}

# v1/organizations/{id} ANY method (simple proxy for ID lookups)
resource "aws_api_gateway_method" "v1_organizations_id_any" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.v1_organizations_id.id
  http_method   = "ANY"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.id" = true
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

# Method response for v1/organizations proxy (base endpoint)
resource "aws_api_gateway_method_response" "v1_organizations_proxy_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v1_organizations.id
  http_method = aws_api_gateway_method.v1_organizations_proxy_get.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

# Method response for v1/organizations/{id} (ID lookups)
resource "aws_api_gateway_method_response" "v1_organizations_id_any" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v1_organizations_id.id
  http_method = aws_api_gateway_method.v1_organizations_id_any.http_method
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




# Integration for v2/organizations
resource "aws_api_gateway_integration" "v2_organizations_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v2_organizations.id
  http_method = aws_api_gateway_method.v2_organizations_get.http_method

  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  uri                     = "http://$${stageVariables.backend_host}/v2/organizations"

  request_parameters = {
    "integration.request.header.Host" = "stageVariables.api_host"
  }

  # Handle all_status parameter transformation using request template
  request_templates = {
    "application/json" = <<EOF
#set($params = "")
#set($hasParams = false)
#if($input.params('page'))
#if(!$hasParams)
#set($params = "$params?page=$util.urlEncode($input.params('page'))")
#set($hasParams = true)
#else
#set($params = "$params&page=$util.urlEncode($input.params('page'))")
#end
#end
#if($input.params('query'))
#if(!$hasParams)
#set($params = "$params?query=$util.urlEncode($input.params('query'))")
#set($hasParams = true)
#else
#set($params = "$params&query=$util.urlEncode($input.params('query'))")
#end
#end
#if($input.params('affiliation'))
#if(!$hasParams)
#set($params = "$params?affiliation=$util.urlEncode($input.params('affiliation'))")
#set($hasParams = true)
#else
#set($params = "$params&affiliation=$util.urlEncode($input.params('affiliation'))")
#end
#end
#if($input.params('filter'))
#if(!$hasParams)
#set($params = "$params?filter=$util.urlEncode($input.params('filter'))")
#set($hasParams = true)
#else
#set($params = "$params&filter=$util.urlEncode($input.params('filter'))")
#end
#end
#if($input.params('format'))
#if(!$hasParams)
#set($params = "$params?format=$util.urlEncode($input.params('format'))")
#set($hasParams = true)
#else
#set($params = "$params&format=$util.urlEncode($input.params('format'))")
#end
#end
#if($input.params('query.name'))
#if(!$hasParams)
#set($params = "$params?query.name=$util.urlEncode($input.params('query.name'))")
#set($hasParams = true)
#else
#set($params = "$params&query.name=$util.urlEncode($input.params('query.name'))")
#end
#end
#if($input.params('query.names'))
#if(!$hasParams)
#set($params = "$params?query.names=$util.urlEncode($input.params('query.names'))")
#set($hasParams = true)
#else
#set($params = "$params&query.names=$util.urlEncode($input.params('query.names'))")
#end
#end
#if($input.params('query.advanced'))
#if(!$hasParams)
#set($params = "$params?query.advanced=$util.urlEncode($input.params('query.advanced'))")
#set($hasParams = true)
#else
#set($params = "$params&query.advanced=$util.urlEncode($input.params('query.advanced'))")
#end
#end
#if($input.params('all_status'))
#set($allStatusValue = $input.params('all_status'))
#if($allStatusValue == "")
#set($allStatusValue = "true")
#end
#if(!$hasParams)
#set($params = "$params?all_status=$util.urlEncode($allStatusValue)")
#set($hasParams = true)
#else
#set($params = "$params&all_status=$util.urlEncode($allStatusValue)")
#end
#end
#if($input.params('page_size'))
#if(!$hasParams)
#set($params = "$params?page_size=$util.urlEncode($input.params('page_size'))")
#set($hasParams = true)
#else
#set($params = "$params&page_size=$util.urlEncode($input.params('page_size'))")
#end
#end
#set($context.requestOverride.path.resourcePath = "/v2/organizations$params")
EOF
  }

  # Caching configuration - include all query parameters for proper cache differentiation
  cache_key_parameters = ["method.request.querystring.page", "method.request.querystring.query", "method.request.querystring.affiliation", "method.request.querystring.filter", "method.request.querystring.format", "method.request.querystring.query.name", "method.request.querystring.query.names", "method.request.querystring.all_status", "method.request.querystring.query.advanced", "method.request.querystring.page_size"]
  cache_namespace     = "v2-organizations"
}



# Integration for v2/organizations/{id}
resource "aws_api_gateway_integration" "v2_organizations_id_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v2_organizations_id.id
  http_method = aws_api_gateway_method.v2_organizations_id_get.http_method

  type                    = "HTTP_PROXY"
  integration_http_method = "GET"
  uri                     = "http://$${stageVariables.backend_host}/v2/organizations/{id}"

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

# Integration for organizations (no version)
resource "aws_api_gateway_integration" "organizations_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.organizations.id
  http_method = aws_api_gateway_method.organizations_get.http_method

  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  uri                     = "http://$${stageVariables.backend_host}/organizations"

  request_parameters = {
    "integration.request.header.Host" = "stageVariables.api_host"
  }

  # Handle all_status parameter transformation using request template
  request_templates = {
    "application/json" = <<EOF
#set($params = "")
#set($hasParams = false)
#if($input.params('page'))
#if(!$hasParams)
#set($params = "$params?page=$util.urlEncode($input.params('page'))")
#set($hasParams = true)
#else
#set($params = "$params&page=$util.urlEncode($input.params('page'))")
#end
#end
#if($input.params('query'))
#if(!$hasParams)
#set($params = "$params?query=$util.urlEncode($input.params('query'))")
#set($hasParams = true)
#else
#set($params = "$params&query=$util.urlEncode($input.params('query'))")
#end
#end
#if($input.params('affiliation'))
#if(!$hasParams)
#set($params = "$params?affiliation=$util.urlEncode($input.params('affiliation'))")
#set($hasParams = true)
#else
#set($params = "$params&affiliation=$util.urlEncode($input.params('affiliation'))")
#end
#end
#if($input.params('filter'))
#if(!$hasParams)
#set($params = "$params?filter=$util.urlEncode($input.params('filter'))")
#set($hasParams = true)
#else
#set($params = "$params&filter=$util.urlEncode($input.params('filter'))")
#end
#end
#if($input.params('format'))
#if(!$hasParams)
#set($params = "$params?format=$util.urlEncode($input.params('format'))")
#set($hasParams = true)
#else
#set($params = "$params&format=$util.urlEncode($input.params('format'))")
#end
#end
#if($input.params('query.name'))
#if(!$hasParams)
#set($params = "$params?query.name=$util.urlEncode($input.params('query.name'))")
#set($hasParams = true)
#else
#set($params = "$params&query.name=$util.urlEncode($input.params('query.name'))")
#end
#end
#if($input.params('query.names'))
#if(!$hasParams)
#set($params = "$params?query.names=$util.urlEncode($input.params('query.names'))")
#set($hasParams = true)
#else
#set($params = "$params&query.names=$util.urlEncode($input.params('query.names'))")
#end
#end
#if($input.params('query.advanced'))
#if(!$hasParams)
#set($params = "$params?query.advanced=$util.urlEncode($input.params('query.advanced'))")
#set($hasParams = true)
#else
#set($params = "$params&query.advanced=$util.urlEncode($input.params('query.advanced'))")
#end
#end
#if($input.params('all_status'))
#set($allStatusValue = $input.params('all_status'))
#if($allStatusValue == "")
#set($allStatusValue = "true")
#end
#if(!$hasParams)
#set($params = "$params?all_status=$util.urlEncode($allStatusValue)")
#set($hasParams = true)
#else
#set($params = "$params&all_status=$util.urlEncode($allStatusValue)")
#end
#end
#if($input.params('page_size'))
#if(!$hasParams)
#set($params = "$params?page_size=$util.urlEncode($input.params('page_size'))")
#set($hasParams = true)
#else
#set($params = "$params&page_size=$util.urlEncode($input.params('page_size'))")
#end
#end
#set($context.requestOverride.path.resourcePath = "/organizations$params")
EOF
  }

  # Caching configuration - include all query parameters for proper cache differentiation
  cache_key_parameters = ["method.request.querystring.page", "method.request.querystring.query", "method.request.querystring.affiliation", "method.request.querystring.filter", "method.request.querystring.format", "method.request.querystring.query.name", "method.request.querystring.query.names", "method.request.querystring.all_status", "method.request.querystring.query.advanced", "method.request.querystring.page_size"]
  cache_namespace     = "organizations"
}

# Integration for organizations/{id} (no version)
resource "aws_api_gateway_integration" "organizations_id_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.organizations_id.id
  http_method = aws_api_gateway_method.organizations_id_get.http_method

  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  uri                     = "http://$${stageVariables.backend_host}/organizations/{id}"

  request_parameters = {
    "integration.request.path.id" = "method.request.path.id"
    "integration.request.header.Host" = "stageVariables.api_host"
  }

  # Caching configuration
  cache_key_parameters = ["method.request.path.id"]
  cache_namespace     = "organizations-id"
}

# v1/organizations proxy integration (base endpoint) - constructs path with params
resource "aws_api_gateway_integration" "v1_organizations_proxy_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v1_organizations.id
  http_method = aws_api_gateway_method.v1_organizations_proxy_get.http_method

  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "http://$${stageVariables.backend_host}/v1/organizations"

  request_parameters = {
    "integration.request.header.Host" = "stageVariables.api_host"
  }

  # Caching configuration - cache by request URI (includes all query parameters)
  cache_key_parameters = ["method.request.uri"]
  cache_namespace      = "v1-organizations-proxy"
}

# v1/organizations/{id} integration (ID lookups) - passes through all query params
resource "aws_api_gateway_integration" "v1_organizations_id_any" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v1_organizations_id.id
  http_method = aws_api_gateway_method.v1_organizations_id_any.http_method

  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "http://$${stageVariables.backend_host}/v1/organizations/{id}"

  request_parameters = {
    "integration.request.path.id" = "method.request.path.id"
    "integration.request.header.Host" = "stageVariables.api_host"
  }

  # Caching configuration - cache by ID and any query parameters
  cache_key_parameters = ["method.request.path.id"]
  cache_namespace      = "v1-organizations-id-proxy"
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
  
  lifecycle {
    create_before_destroy = true
  }
}