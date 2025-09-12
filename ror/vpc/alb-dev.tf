module "alb-dev" {
  source                        = "terraform-aws-modules/alb/aws"
  version                       = "5.13.0"
  name                          = "lb-dev"
  load_balancer_type            = "application"
  security_groups               = [aws_security_group.lb_sg.id]
  access_logs = {
    bucket                      = aws_s3_bucket.logs.bucket
  }
  subnets                       = module.vpc.public_subnets
  tags                          = {"environment" = "ror-dev"}
  vpc_id                        = module.vpc.vpc_id
  idle_timeout                  = "240"
}

resource "aws_lb_listener" "alb-http-dev" {
  load_balancer_arn = module.alb-dev.this_lb_arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "alb-dev" {
  load_balancer_arn = module.alb-dev.this_lb_arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.ror.arn


  default_action {
    target_group_arn = data.aws_lb_target_group.api-dev.id
    type             = "forward"
  }
}



# Rule 1: Allow traffic that came through API Gateway (highest priority)
resource "aws_lb_listener_rule" "allow_api_gateway_dev" {
  listener_arn = aws_lb_listener.alb-dev.arn
  priority = 10

  action {
    type             = "forward"
    target_group_arn = data.aws_lb_target_group.api-dev.id
  }

  condition {
    host_header {
      values = ["api.dev.ror.org"]
    }
  }
}

# Rule 2: Allow traffic with "indexdata" in the path
resource "aws_lb_listener_rule" "allow_indexdata_dev" {
  listener_arn = aws_lb_listener.alb-dev.arn
  priority = 20

  action {
    type             = "forward"
    target_group_arn = data.aws_lb_target_group.api-dev.id
  }

  condition {
    path_pattern {
      values = ["*indexdata*"]
    }
  }
}

# Rule 3: Allow traffic with "indexdatadump" in the path
resource "aws_lb_listener_rule" "allow_indexdatadump_dev" {
  listener_arn = aws_lb_listener.alb-dev.arn
  priority = 30

  action {
    type             = "forward"
    target_group_arn = data.aws_lb_target_group.api-dev.id
  }

  condition {
    path_pattern {
      values = ["*indexdatadump*"]
    }
  }
}

# Rule 4: Block all other API traffic (return 403)
resource "aws_lb_listener_rule" "block_api_traffic_dev" {
  listener_arn = aws_lb_listener.alb-dev.arn
  priority = 90

  action {
    type = "fixed_response"
    fixed_response {
      content_type = "application/json"
      message_body = "{\"error\":\"Access denied - API access restricted\"}"
      status_code  = "403"
    }
  }

  condition {
    host_header {
      values = ["alb-dev.ror.org"]
    }
  }
}

resource "aws_lb_listener_rule" "redirect_www-dev" {
  listener_arn = aws_lb_listener.alb-dev.arn
  priority = 100

  action {
    type = "redirect"

    redirect {
      host        = "dev.ror.org"
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    host_header {
      values = ["www.dev.ror.org"]
    }
  }
}

resource "aws_route53_record" "www-dev" {
    zone_id = data.aws_route53_zone.public.zone_id
    name = "www.dev.ror.org"
    type = "CNAME"
    ttl = var.ttl
    records = [data.aws_lb.alb-dev.dns_name]
}

# HTTP listener rule to handle API Gateway requests (higher priority than default redirect)
resource "aws_lb_listener_rule" "api-dev-http-forward" {
  listener_arn = aws_lb_listener.alb-http-dev.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = data.aws_lb_target_group.api-dev.arn
  }

  condition {
    host_header {
      values = ["api.dev.ror.org"]
    }
  }
}
