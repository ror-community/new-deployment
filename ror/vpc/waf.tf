// TODO: Create WAF module with inputs for different envs

resource "aws_wafregional_ipset" "nat" {
  name = "natIPSet"

  ip_set_descriptor {
    type  = "IPV4"
    value = var.waf_nat_ip
  }
}

resource "aws_wafregional_ipset" "whitelist" {
  name = "whitelistIPSet"

  ip_set_descriptor {
    type  = "IPV4"
    value = var.waf_whitelisted_ip
  }
}

resource "aws_wafregional_ipset" "blacklist" {
  name = "blacklistIPSet"

  ip_set_descriptor {
    type  = "IPV4"
    value = var.waf_blacklisted_ip
  }
}

resource "aws_wafregional_rate_based_rule" "rate" {
  depends_on  = [aws_wafregional_ipset.nat, aws_wafregional_ipset.whitelist]
  name        = "rate_rule"
  metric_name = "rateRule"

  rate_key   = "IP"
  rate_limit = 2000

  predicate {
    data_id = aws_wafregional_ipset.nat.id
    negated = true
    type    = "IPMatch"
  }

  predicate {
    data_id = aws_wafregional_ipset.whitelist.id
    negated = true
    type    = "IPMatch"
  }
}

resource "aws_wafregional_rule" "block_ip" {
  name        = "block_ip_rule"
  metric_name = "blockIpRule"

  predicate {
    type    = "IPMatch"
    data_id = aws_wafregional_ipset.blacklist.id
    negated = false
  }
}

resource "aws_wafregional_byte_match_set" "empty_affiliation_param" {
  name = "empty_affiliation_param_byte_match_set"

  byte_match_tuples {
    text_transformation   = "NONE"
    target_string         = "affiliation="
    positional_constraint = "EXACTLY"

    field_to_match {
      type = "QUERY_STRING"
    }
  }
}

resource "aws_wafregional_rule" "block_empty_affiliation_param" {
  name        = "block_empty_affiliation_param_rule"
  metric_name = "blockEmptyAffiliationParamRule"

  predicate {
    type    = "ByteMatch"
    data_id = aws_wafregional_byte_match_set.empty_affiliation_param.id
    negated = false
  }
}

resource "aws_wafregional_web_acl" "prod" {
  name        = "waf-prod"
  metric_name = "wafProd"

  default_action {
    type = "ALLOW"
  }

  rule {
    action {
      type = "BLOCK"
    }

    priority = 1
    rule_id  = aws_wafregional_rate_based_rule.rate.id
    type     = "RATE_BASED"
  }

  rule {
    action {
      type = "BLOCK"
    }

    priority = 2
    rule_id  = aws_wafregional_rule.block_ip.id
    type     = "REGULAR"
  }
}

resource "aws_wafregional_web_acl" "staging" {
  name        = "waf-staging"
  metric_name = "wafStaging"

  default_action {
    type = "ALLOW"
  }

  rule {
    action {
      type = "BLOCK"
    }

    priority = 1
    rule_id  = aws_wafregional_rate_based_rule.rate.id
    type     = "RATE_BASED"
  }

  rule {
    action {
      type = "BLOCK"
    }

    priority = 2
    rule_id  = aws_wafregional_rule.block_ip.id
    type     = "REGULAR"
  }

  rule {
    action {
      type = "BLOCK"
    }

    priority = 3
    rule_id  = aws_wafregional_rule.block_empty_affiliation_param.id
    type     = "REGULAR"
  }
}

resource "aws_wafregional_web_acl_association" "staging" {
  resource_arn = data.aws_lb.alb-staging.arn
  web_acl_id   = aws_wafregional_web_acl.staging.id
}

resource "aws_wafregional_web_acl_association" "prod" {
  resource_arn = data.aws_lb.alb.arn
  web_acl_id   = aws_wafregional_web_acl.prod.id
}