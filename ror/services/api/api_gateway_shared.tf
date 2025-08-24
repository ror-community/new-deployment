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

# v1/{proxy+} ANY method (catches everything after v1/)
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
    "method.request.querystring.page_size" = false
    "method.request.querystring.invalid_params" = false
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

# Method response for v1/{proxy+} (catches everything after v1/)
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

# v1/{proxy+} integration - passes everything after v1/ directly to backend
resource "aws_api_gateway_integration" "v1_proxy" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.v1_proxy.id
  http_method = aws_api_gateway_method.v1_proxy.http_method

  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  uri                     = "http://$${stageVariables.backend_host}/v1/{proxy}"

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
    "integration.request.header.Host" = "stageVariables.api_host"
  }

  request_templates = {
    "application/json" = <<EOF
#set($context.requestOverride.path.resourcePath = "/v1/$input.params('proxy')")

## Define valid parameters for v1 endpoints
#set($validParams = ["query", "page", "affiliation", "filter", "format", "all_status", "query.advanced", "page_size"])

## Initialize query string parts and invalid parameter flag
#set($queryParts = [])
#set($hasInvalidParams = false)

## Process all query parameters
#foreach($paramName in $input.params().querystring.keySet())
  #set($paramValue = $input.params().querystring.get($paramName))
  
  ## Check if parameter is valid
  #set($isValid = false)
  #foreach($validParam in $validParams)
    #if($paramName == $validParam)
      #set($isValid = true)
      #break
    #end
  #end
  
  ## Handle parameter based on validity
  #if($isValid)
    ## Valid parameter - add to query string
    #if($paramValue && $paramValue != "")
      ## Parameter has a value
      #if($paramName == "all_status" && $paramValue == "")
        ## Special case: empty all_status becomes true
        #set($ignore = $queryParts.add("$paramName=true"))
      #else
        #set($ignore = $queryParts.add("$paramName=$paramValue"))
      #end
    #else
      ## Parameter without value (like ?all_status)
      #if($paramName == "all_status")
        #set($ignore = $queryParts.add("$paramName=true"))
      #else
        #set($ignore = $queryParts.add($paramName))
      #end
    #end
  #else
    ## Invalid parameter - mark flag and pass it through
    #set($hasInvalidParams = true)
    #if($paramValue && $paramValue != "")
      #set($ignore = $queryParts.add("$paramName=$paramValue"))
    #else
      #set($ignore = $queryParts.add($paramName))
    #end
  #end
#end

## Set cache key for invalid_params parameter
#if($hasInvalidParams)
  #set($ignore = $queryParts.add("invalid_params=true"))
  #set($context.requestOverride.querystring.invalid_params = "true")
#else
  #set($context.requestOverride.querystring.invalid_params = "false")
#end

## Build final query string
#if($queryParts.size() > 0)
  #set($queryString = "?")
  #foreach($part in $queryParts)
    #if($velocityCount > 1)
      #set($queryString = "$queryString&$part")
    #else
      #set($queryString = "$queryString$part")
    #end
  #end
  #set($context.requestOverride.path.resourcePath = "/v1/$input.params('proxy')$queryString")
#end
EOF
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
    "method.request.querystring.page_size",
    "method.request.querystring.invalid_params",
    "integration.request.path.proxy"
  ]
  cache_namespace      = "v1-proxy"
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
  depends_on = [
    # Ensure all methods and integrations are created first
    aws_api_gateway_integration.root_get,
    aws_api_gateway_integration.v2_organizations_get,
    aws_api_gateway_integration.v2_organizations_id_get,
    aws_api_gateway_integration.v1_heartbeat_get,
    aws_api_gateway_integration.v2_heartbeat_get,
    aws_api_gateway_integration.organizations_get,
    aws_api_gateway_integration.organizations_id_get,
    aws_api_gateway_integration.v1_proxy
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