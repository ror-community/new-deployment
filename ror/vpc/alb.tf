module "alb" {
  source                        = "terraform-aws-modules/alb/aws"
  version                       = "5.13.0"
  name                          = "lb"
  load_balancer_type            = "application"
  security_groups               = [aws_security_group.lb_sg.id]
  access_logs = {
    bucket                      = aws_s3_bucket.logs.bucket
  }
  subnets                       = module.vpc.public_subnets
  tags                          = {"Environment" = "production"}
  vpc_id                        = module.vpc.vpc_id
  idle_timeout                  = "240"
}

resource "aws_s3_bucket" "logs" {
  bucket = "logfiles.ror.community"
  acl    = "private"
  policy = templatefile("s3_write_access.json", {
    bucket_name = "logfiles.ror.community"
  })
  tags = {
      Name = "ror-community"
  }
}

resource "aws_lb_listener" "alb-http" {
  load_balancer_arn = module.alb.this_lb_arn
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

resource "aws_lb_listener" "alb" {
  load_balancer_arn = module.alb.this_lb_arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.ror.arn

  default_action {
    target_group_arn = data.aws_lb_target_group.api-community.id
    type             = "forward"
  }
}

# Rule 1: Allow traffic that came through API Gateway (highest priority)
resource "aws_lb_listener_rule" "allow_api_gateway_prod" {
  listener_arn = aws_lb_listener.alb.arn
  priority = 10

  action {
    type             = "forward"
    target_group_arn = data.aws_lb_target_group.api-community.id
  }

  condition {
    host_header {
      values = ["api.ror.org"]
    }
  }

  condition {
    http_header {
      http_header_name = "X-ROR-API-Gateway-Token"
      values = [var.api_gateway_token]
    }
  }
}

# Rule 2: Allow traffic with "indexdata" in the path
resource "aws_lb_listener_rule" "allow_indexdata_prod" {
  listener_arn = aws_lb_listener.alb.arn
  priority = 20

  action {
    type             = "forward"
    target_group_arn = data.aws_lb_target_group.api-community.id
  }

  condition {
    path_pattern {
      values = ["*indexdata*"]
    }
  }
}

# Rule 3: Allow traffic with "indexdatadump" in the path  
resource "aws_lb_listener_rule" "allow_indexdatadump_prod" {
  listener_arn = aws_lb_listener.alb.arn
  priority = 30

  action {
    type             = "forward"
    target_group_arn = data.aws_lb_target_group.api-community.id
  }

  condition {
    path_pattern {
      values = ["*indexdatadump*"]
    }
  }
}

# Rule 4: Block API paths without proper authentication (return 403)
resource "aws_lb_listener_rule" "block_api_traffic_prod" {
  listener_arn = aws_lb_listener.alb.arn
  priority = 90

  action {
    type             = "forward"
    target_group_arn = data.aws_lb_target_group.api-community.id
  }

  condition {
    path_pattern {
      values = ["/v1/*", "/v2/*", "/organizations*", "/heartbeat*"]
    }
  }
}

resource "aws_lb_listener_rule" "redirect_www" {
  listener_arn = aws_lb_listener.alb.arn
  priority = 100

  action {
    type = "redirect"

    redirect {
      host        = "ror.org"
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    host_header {
      values = ["www.ror.org"]
    }
  }
}

resource "aws_route53_record" "www" {
    zone_id = data.aws_route53_zone.public.zone_id
    name = "www.ror.org"
    type = "CNAME"
    ttl = var.ttl
    records = [data.aws_lb.alb.dns_name]
}
