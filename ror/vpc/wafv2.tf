resource "aws_wafv2_ip_set" "nat" {
  name = "natIPSet"
  description        = "NAT IP set"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = ["{$var.waf_nat_ip}"]
}

resource "aws_wafv2_ip_set" "whitelist" {
  name = "whitelistIPSet"
  description        = "Whitelist IP set"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = var.whitelist_ips
}

resource "aws_wafv2_ip_set" "blacklist" {
  name = "blacklistIPSet"
  description        = "Blacklist IP set"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = var.blacklist_ips
}

resource "aws_wafv2_rule_group" "invalid-request" {
  name     = "invalid-request-rule-group"
  scope    = "REGIONAL"
  capacity = 500
}



resource "aws_wafv2_web_acl" "dev-v2" {
    // metric_name = "wafDevV2"
    name        = "waf-dev-v2"
    description = "Dev ALB WAF"
    scope       = "REGIONAL"

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
                        arn = aws_wafv2_ip_set.whitelist.arn
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
        bloack {}
        }
        statement {
            ip_set_reference_statement {
                arn = aws_wafv2_ip_set.blacklist.arn
            }
        }
        visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "block-ip-metric"
        sampled_requests_enabled   = true
        }
    }

    rule {
        name     = "rate-limit-rule"
        priority = 3
        action {
        block {}
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
        priority = 4
        action {
        block {}
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

resource "aws_wafv2_web_acl_association" "dev-v2" {
    resource_arn = data.aws_lb.alb-dev.arn
    web_acl_arn  = aws_wafv2_web_acl.dev-v2.arn
}