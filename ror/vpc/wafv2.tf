resource "aws_wafv2_ip_set" "nat" {
  name = "natIPSet"
  description        = "NAT IP set"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = var.wafv2_nat_ip
}

resource "aws_wafv2_ip_set" "whitelist" {
  name = "whitelistIPSet"
  description        = "DEV Whitelist IP set"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = var.whitelist_ips
}

resource "aws_wafv2_ip_set" "blacklist" {
  name = "blacklistIPSet"
  description        = "PROD Blacklist IP set"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = var.blacklist_ips
}

resource "aws_wafv2_ip_set" "whitelist-dev" {
  name = "whitelistIPSetDev"
  description        = "DEV Whitelist IP set"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = var.whitelist_ips_dev
}

resource "aws_wafv2_ip_set" "blacklist-dev" {
  name = "blacklistIPSetDev"
  description        = "DEV Blacklist IP set"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = var.blacklist_ips_dev
}

resource "aws_wafv2_ip_set" "ip-ratelimit-dev" {
  name = "ratelimitIPSetDev"
  description        = "DEV Rate limit IP set"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = var.ratelimit_ips_dev
}

resource "aws_wafv2_ip_set" "whitelist-staging" {
  name = "whitelistIPSetStaging"
  description        = "STAGING Whitelist IP set"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = var.whitelist_ips_staging
}

resource "aws_wafv2_regex_pattern_set" "valid_query_params" {
  name  = "valid-query-params"
  description = "Valid query parameters for ROR API"
  scope = "REGIONAL"
  
  regular_expression {
    regex_string = "^(query|page|affiliation|filter|format|all_status|query\\.advanced|query\\.name|query\\.names|single_search)(=|$)"
  }
  regular_expression {
    regex_string = "^$"
  }
}

resource "aws_wafv2_ip_set" "blacklist-staging" {
  name = "blacklistIPSetStaging"
  description        = "STAGING Blacklist IP set"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = var.blacklist_ips_staging
}

resource "aws_wafv2_ip_set" "ip-ratelimit-staging" {
  name = "ratelimitIPSetStaging"
  description        = "STAGING Rate limit IP set"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = var.ratelimit_ips_staging
}

resource "aws_wafv2_ip_set" "whitelist-prod" {
  name = "whitelistIPSetProd"
  description        = "PROD Whitelist IP set"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = var.whitelist_ips_prod
}

resource "aws_wafv2_ip_set" "blacklist-custom-msg-prod" {
  name = "blacklistCustomMsgIPSetProd"
  description        = "PROD Blacklist custom msg IP set"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = var.blacklist_custom_msg_ips_prod
}

resource "aws_wafv2_ip_set" "blacklist-prod" {
  name = "blacklistIPSetProd"
  description        = "PROD Blacklist IP set"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = var.blacklist_ips_prod
}

resource "aws_wafv2_ip_set" "ip-ratelimit-prod" {
  name = "ratelimitIPSetProd"
  description        = "PROD Rate limit IP set"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = var.ratelimit_ips_prod
}

resource "aws_wafv2_web_acl" "dev-v2" {
    name        = "waf-dev-v2"
    description = "Dev ALB WAF"
    scope       = "REGIONAL"

    custom_response_body {
        key           = "rate_limit_blocked_response"
        content       = "Rate Limit Exceeded. ROR API rate limit is 2000 requests per 5 minute period."
        content_type  = "TEXT_PLAIN"
    }

    custom_response_body {
        key           = "invalid_req_blocked_response"
        content       = "Bad Request"
        content_type  = "TEXT_PLAIN"
    }

    custom_response_body {
        key           = "invalid_query_param_response"
        content       = "{\"errors\":[\"Query parameter is illegal. Valid parameters are: query, page, affiliation, filter, format, all_status, query.advanced, query.name, query.names, single_search\"]}"
        content_type  = "APPLICATION_JSON"
    }

    default_action {
        allow {}
    }

    rule {
        name = "allow-ip-rule"
        priority = 1
        action {
        allow {}
        }
        statement {
            or_statement {
                statement {
                    ip_set_reference_statement {
                        arn = aws_wafv2_ip_set.nat.arn
                    }
                }
                statement {
                    ip_set_reference_statement {
                        arn = aws_wafv2_ip_set.whitelist-dev.arn
                    }
                }
            }
        }
        visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "allow-ip-metric"
        sampled_requests_enabled   = true
        }
    }

    rule {
        name = "block-ip-rule"
        priority = 2
        action {
            block {}
        }
        statement {
            ip_set_reference_statement {
                arn = aws_wafv2_ip_set.blacklist-dev.arn
            }
        }
        visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "block-ip-metric"
        sampled_requests_enabled   = true
        }
    }

    rule {
        name = "rate-limit-ip-rule"
        priority = 3
        action {
            block {
                custom_response {
                    response_code = 429
                }
            }
        }
        statement {
            rate_based_statement {
                limit              = 200
                aggregate_key_type = "IP"
                scope_down_statement {
                    ip_set_reference_statement {
                        arn = aws_wafv2_ip_set.ip-ratelimit-dev.arn
                    }
                }
            }
        }
        visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "ratelimit-ip-metric"
        sampled_requests_enabled   = true
        }
    }

    rule {
        name     = "rate-limit-rule"
        priority = 4
        action {
            block {
                custom_response {
                    custom_response_body_key  = "rate_limit_blocked_response"
                    response_code             = 429
                }
            }
        }
        statement {
            rate_based_statement {
                limit              = 2000
                aggregate_key_type = "IP"
            }
        }
        visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "rate-limit-metric"
        sampled_requests_enabled   = true
        }
    }

    rule {
        name = "block-invalid-query-params-rule"
        priority = 5
        action {
            block {
                custom_response {
                    custom_response_body_key  = "invalid_query_param_response"
                    response_code = 400
                }
            }
        }
        statement {
            and_statement {
                statement {
                    or_statement {
                        statement {
                            byte_match_statement {
                                positional_constraint = "STARTS_WITH"
                                search_string = "/v1/"
                                field_to_match {
                                    uri_path {}
                                }
                                text_transformation {
                                    priority = 1
                                    type     = "NONE"
                                }
                            }
                        }
                        statement {
                            byte_match_statement {
                                positional_constraint = "STARTS_WITH"
                                search_string = "/v2/"
                                field_to_match {
                                    uri_path {}
                                }
                                text_transformation {
                                    priority = 1
                                    type     = "NONE"
                                }
                            }
                        }
                        statement {
                            byte_match_statement {
                                positional_constraint = "STARTS_WITH"
                                search_string = "/organizations"
                                field_to_match {
                                    uri_path {}
                                }
                                text_transformation {
                                    priority = 1
                                    type     = "NONE"
                                }
                            }
                        }
                    }
                }
                statement {
                    byte_match_statement {
                        positional_constraint = "CONTAINS"
                        search_string = "="
                        field_to_match {
                            query_string {}
                        }
                        text_transformation {
                            priority = 1
                            type     = "NONE"
                        }
                    }
                }
                statement {
                    not_statement {
                        statement {
                            regex_pattern_set_reference_statement {
                                arn = aws_wafv2_regex_pattern_set.valid_query_params.arn
                                field_to_match {
                                    query_string {}
                                }
                                text_transformation {
                                    priority = 1
                                    type     = "URL_DECODE"
                                }
                                text_transformation {
                                    priority = 2
                                    type     = "LOWERCASE"
                                }
                            }
                        }
                    }
                }
            }
        }
        visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "block-invalid-query-params-metric"
        sampled_requests_enabled   = true
        }
    }

    rule {
        name = "block-invalid-request-rule"
        priority = 6
        action {
            block {
                custom_response {
                    custom_response_body_key  = "invalid_req_blocked_response"
                    response_code = 400
                }
            }
        }
        statement {
            or_statement {
                statement {
                    byte_match_statement {
                        positional_constraint = "EXACTLY"
                        search_string = "affiliation="
                        field_to_match {
                            query_string {}
                        }
                        text_transformation {
                            priority = 1
                            type     = "NONE"
                        }
                    }
                }
                statement {
                    byte_match_statement {
                        positional_constraint = "EXACTLY"
                        search_string = "affiliation=0"
                        field_to_match {
                            query_string {}
                        }
                        text_transformation {
                            priority = 1
                            type     = "NONE"
                        }
                    }
                }
                statement {
                    byte_match_statement {
                        positional_constraint = "CONTAINS"
                        search_string = "affiliation=no%20affiliation"
                        field_to_match {
                            query_string {}
                        }
                        text_transformation {
                            priority = 1
                            type     = "NONE"
                        }
                    }
                }
                statement {
                    byte_match_statement {
                        positional_constraint = "EXACTLY"
                        search_string = "affiliation=Department%20of%20Physics%2C%20Yale%20University%2C%20New%20Haven%2C%20CT%2006520%2C%20USA%20Russian%20Federation"
                        field_to_match {
                            query_string {}
                        }
                        text_transformation {
                            priority = 1
                            type     = "NONE"
                        }
                    }
                }
            }
        }
        visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "block-invalid-request-metric"
        sampled_requests_enabled   = true
        }
    }
    visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "dev-waf-acl"
        sampled_requests_enabled   = true
    }
}

resource "aws_wafv2_web_acl" "staging-v2" {
    name        = "waf-staging-v2"
    description = "Staging ALB WAF"
    scope       = "REGIONAL"

    custom_response_body {
        key           = "rate_limit_blocked_response"
        content       = "Rate Limit Exceeded. ROR API rate limit is 2000 requests per 5 minute period."
        content_type  = "TEXT_PLAIN"
    }

    custom_response_body {
        key           = "invalid_req_blocked_response"
        content       = "Bad Request"
        content_type  = "TEXT_PLAIN"
    }

    custom_response_body {
        key           = "invalid_query_param_response"
        content       = "{\"errors\":[\"Query parameter is illegal. Valid parameters are: query, page, affiliation, filter, format, all_status, query.advanced, query.name, query.names, single_search\"]}"
        content_type  = "APPLICATION_JSON"
    }

    default_action {
        allow {}
    }

    rule {
        name = "allow-ip-rule"
        priority = 1
        action {
        allow {}
        }
        statement {
            or_statement {
                statement {
                    ip_set_reference_statement {
                        arn = aws_wafv2_ip_set.nat.arn
                    }
                }
                statement {
                    ip_set_reference_statement {
                        arn = aws_wafv2_ip_set.whitelist-staging.arn
                    }
                }
            }
        }
        visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "allow-ip-metric"
        sampled_requests_enabled   = true
        }
    }

    rule {
        name = "block-ip-rule"
        priority = 2
        action {
            block {}
        }
        statement {
            ip_set_reference_statement {
                arn = aws_wafv2_ip_set.blacklist-staging.arn
            }
        }
        visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "block-ip-metric"
        sampled_requests_enabled   = true
        }
    }

    rule {
        name = "rate-limit-ip-rule"
        priority = 3
        action {
            block {
                custom_response {
                    response_code = 429
                }
            }
        }
        statement {
            rate_based_statement {
                limit              = 200
                aggregate_key_type = "IP"
                scope_down_statement {
                    ip_set_reference_statement {
                        arn = aws_wafv2_ip_set.ip-ratelimit-staging.arn
                    }
                }
            }
        }
        visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "ratelimit-ip-metric"
        sampled_requests_enabled   = true
        }
    }

    rule {
        name     = "rate-limit-rule"
        priority = 4
        action {
            block {
                custom_response {
                    custom_response_body_key  = "rate_limit_blocked_response"
                    response_code             = 429
                }
            }
        }
        statement {
        rate_based_statement {
            limit              = 2000
            aggregate_key_type = "IP"
        }
        }
        visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "rate-limit-metric"
        sampled_requests_enabled   = true
        }
    }

    rule {
        name = "block-invalid-query-params-rule"
        priority = 5
        action {
            block {
                custom_response {
                    custom_response_body_key  = "invalid_query_param_response"
                    response_code = 400
                }
            }
        }
        statement {
            and_statement {
                statement {
                    or_statement {
                        statement {
                            byte_match_statement {
                                positional_constraint = "STARTS_WITH"
                                search_string = "/v1/"
                                field_to_match {
                                    uri_path {}
                                }
                                text_transformation {
                                    priority = 1
                                    type     = "NONE"
                                }
                            }
                        }
                        statement {
                            byte_match_statement {
                                positional_constraint = "STARTS_WITH"
                                search_string = "/v2/"
                                field_to_match {
                                    uri_path {}
                                }
                                text_transformation {
                                    priority = 1
                                    type     = "NONE"
                                }
                            }
                        }
                        statement {
                            byte_match_statement {
                                positional_constraint = "STARTS_WITH"
                                search_string = "/organizations"
                                field_to_match {
                                    uri_path {}
                                }
                                text_transformation {
                                    priority = 1
                                    type     = "NONE"
                                }
                            }
                        }
                    }
                }
                statement {
                    byte_match_statement {
                        positional_constraint = "CONTAINS"
                        search_string = "="
                        field_to_match {
                            query_string {}
                        }
                        text_transformation {
                            priority = 1
                            type     = "NONE"
                        }
                    }
                }
                statement {
                    not_statement {
                        statement {
                            regex_pattern_set_reference_statement {
                                arn = aws_wafv2_regex_pattern_set.valid_query_params.arn
                                field_to_match {
                                    query_string {}
                                }
                                text_transformation {
                                    priority = 1
                                    type     = "URL_DECODE"
                                }
                                text_transformation {
                                    priority = 2
                                    type     = "LOWERCASE"
                                }
                            }
                        }
                    }
                }
            }
        }
        visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "block-invalid-query-params-metric"
        sampled_requests_enabled   = true
        }
    }

    rule {
        name = "block-invalid-request-rule"
        priority = 6
        action {
            block {
                custom_response {
                    custom_response_body_key  = "invalid_req_blocked_response"
                    response_code = 400
                }
            }
        }
        statement {
            or_statement {
                statement {
                    byte_match_statement {
                        positional_constraint = "EXACTLY"
                        search_string = "affiliation="
                        field_to_match {
                            query_string {}
                        }
                        text_transformation {
                            priority = 1
                            type     = "NONE"
                        }
                    }
                }
                statement {
                    byte_match_statement {
                        positional_constraint = "EXACTLY"
                        search_string = "affiliation=0"
                        field_to_match {
                            query_string {}
                        }
                        text_transformation {
                            priority = 1
                            type     = "NONE"
                        }
                    }
                }
                statement {
                    byte_match_statement {
                        positional_constraint = "CONTAINS"
                        search_string = "affiliation=no%20affiliation"
                        field_to_match {
                            query_string {}
                        }
                        text_transformation {
                            priority = 1
                            type     = "NONE"
                        }
                    }
                }
                statement {
                    byte_match_statement {
                        positional_constraint = "EXACTLY"
                        search_string = "affiliation=Department%20of%20Physics%2C%20Yale%20University%2C%20New%20Haven%2C%20CT%2006520%2C%20USA%20Russian%20Federation"
                        field_to_match {
                            query_string {}
                        }
                        text_transformation {
                            priority = 1
                            type     = "NONE"
                        }
                    }
                }
            }
        }
        visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "block-invalid-request-metric"
        sampled_requests_enabled   = true
        }
    }
    visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "staging-waf-acl"
        sampled_requests_enabled   = true
    }
}

resource "aws_wafv2_web_acl" "prod-v2" {
    name        = "waf-prod-v2"
    description = "Prod ALB WAF"
    scope       = "REGIONAL"

    custom_response_body {
        key           = "bad_behavior_blocked_response"
        content       = "You have been blocked due to bad behavior. Please stop sending large volumes of concurrent requests from multiple IP addresses. ROR API is a community resource. Please be considerate of other users."
        content_type  = "TEXT_PLAIN"
    }

    custom_response_body {
        key           = "country_rate_limited_response"
        content       = "Due to frequent abuse of the ROR API by IPs originating from certain countries, a restricted rate limit has been applied to requests from those country codes. Contact support@ror.org with questions."
        content_type  = "TEXT_PLAIN"
    }

    custom_response_body {
        key           = "rate_limit_blocked_response"
        content       = "Rate Limit Exceeded. ROR API rate limit is 2000 requests per 5 minute period."
        content_type  = "TEXT_PLAIN"
    }

    custom_response_body {
        key           = "invalid_req_blocked_response"
        content       = "Bad Request"
        content_type  = "TEXT_PLAIN"
    }

    default_action {
        allow {}
    }

    rule {
        name = "allow-ip-rule"
        priority = 1
        action {
        allow {}
        }
        statement {
            or_statement {
                statement {
                    ip_set_reference_statement {
                        arn = aws_wafv2_ip_set.nat.arn
                    }
                }
                statement {
                    ip_set_reference_statement {
                        arn = aws_wafv2_ip_set.whitelist-prod.arn
                    }
                }
            }
        }
        visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "allow-ip-metric"
        sampled_requests_enabled   = true
        }
    }

    rule {
        name = "block-custom-msg-ip-rule"
        priority = 2
        action {
            block {
                custom_response {
                    custom_response_body_key  = "bad_behavior_blocked_response"
                    response_code = 403
                }
            }
        }
        statement {
            ip_set_reference_statement {
                arn = aws_wafv2_ip_set.blacklist-custom-msg-prod.arn
            }
        }
        visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "block-ip-metric"
        sampled_requests_enabled   = true
        }
    }

    rule {
        name = "block-ip-rule"
        priority = 3
        action {
            block {}
        }
        statement {
            ip_set_reference_statement {
                arn = aws_wafv2_ip_set.blacklist-prod.arn
            }
        }
        visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "block-ip-metric"
        sampled_requests_enabled   = true
        }
    }

    rule {
        name = "rate-limit-ip-rule"
        priority = 4
        action {
            block {
                custom_response {
                    response_code = 429
                }
            }
        }
        statement {
            rate_based_statement {
                limit              = 200
                aggregate_key_type = "IP"
                scope_down_statement {
                    ip_set_reference_statement {
                        arn = aws_wafv2_ip_set.ip-ratelimit-prod.arn
                    }
                }
            }
        }
        visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "ratelimit-ip-metric"
        sampled_requests_enabled   = true
        }
    }

    rule {
        name = "rate-limit-country-rule"
        priority = 5
        action {
            block {
                custom_response {
                    custom_response_body_key  = "country_rate_limited_response"
                    response_code = 429
                }
            }
        }
        statement {
            rate_based_statement {
                limit              = 200
                aggregate_key_type = "IP"
                scope_down_statement {
                    geo_match_statement {
                        country_codes = ["RU"]
                    }
                }
            }
        }
        visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "ratelimit-country-metric"
        sampled_requests_enabled   = true
        }
    }

    rule {
        name     = "rate-limit-rule"
        priority = 6
        action {
            block {
                custom_response {
                    custom_response_body_key  = "rate_limit_blocked_response"
                    response_code             = 429
                }
            }
        }
        statement {
        rate_based_statement {
            limit              = 2000
            aggregate_key_type = "IP"
        }
        }
        visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "rate-limit-metric"
        sampled_requests_enabled   = true
        }
    }

    rule {
        name = "block-invalid-request-rule"
        priority = 7
        action {
            block {
                custom_response {
                    custom_response_body_key  = "invalid_req_blocked_response"
                    response_code = 400
                }
            }
        }
        statement {
            or_statement {
                statement {
                    byte_match_statement {
                        positional_constraint = "EXACTLY"
                        search_string = "affiliation="
                        field_to_match {
                            query_string {}
                        }
                        text_transformation {
                            priority = 1
                            type     = "NONE"
                        }
                    }
                }
                statement {
                    byte_match_statement {
                        positional_constraint = "EXACTLY"
                        search_string = "affiliation=0"
                        field_to_match {
                            query_string {}
                        }
                        text_transformation {
                            priority = 1
                            type     = "NONE"
                        }
                    }
                }
                statement {
                    byte_match_statement {
                        positional_constraint = "CONTAINS"
                        search_string = "affiliation=no%20affiliation"
                        field_to_match {
                            query_string {}
                        }
                        text_transformation {
                            priority = 1
                            type     = "NONE"
                        }
                    }
                }
                statement {
                    byte_match_statement {
                        positional_constraint = "EXACTLY"
                        search_string = "affiliation=Department%20of%20Physics%2C%20Yale%20University%2C%20New%20Haven%2C%20CT%2006520%2C%20USA%20Russian%20Federation"
                        field_to_match {
                            query_string {}
                        }
                        text_transformation {
                            priority = 1
                            type     = "NONE"
                        }
                    }
                }
            }
        }
        visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "block-invalid-request-metric"
        sampled_requests_enabled   = true
        }
    }
    visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "prod-waf-acl"
        sampled_requests_enabled   = true
    }
}
resource "aws_wafv2_web_acl_association" "staging-v2" {
    resource_arn = data.aws_lb.alb-staging.arn
    web_acl_arn  = aws_wafv2_web_acl.staging-v2.arn
}

resource "aws_wafv2_web_acl_association" "prod-v2" {
    resource_arn = data.aws_lb.alb.arn
    web_acl_arn  = aws_wafv2_web_acl.prod-v2.arn
}