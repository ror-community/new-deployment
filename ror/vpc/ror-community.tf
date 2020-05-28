resource "aws_route53_record" "public-ns" {
    zone_id = aws_route53_zone.public.zone_id
    name = "ror.org"
    type = "NS"
    ttl = "300"
    records = [
        aws_route53_zone.public.name_servers.0,
        aws_route53_zone.public.name_servers.1,
        aws_route53_zone.public.name_servers.2,
        aws_route53_zone.public.name_servers.3
    ]
}

resource "aws_route53_zone" "public-community" {
    name = "ror.community"

    tags = {
        Environment = "public"
    }
}

resource "aws_route53_record" "public-community-ns" {
    zone_id = aws_route53_zone.public-community.zone_id
    name = "ror.community"
    type = "NS"
    ttl = "300"
    records = [
        aws_route53_zone.public-community.name_servers.0,
        aws_route53_zone.public-community.name_servers.1,
        aws_route53_zone.public-community.name_servers.2,
        aws_route53_zone.public-community.name_servers.3
    ]
}

resource "aws_lb_listener_rule" "redirect_community" {
  listener_arn = aws_lb_listener.alb.arn

  action {
    type = "redirect"

    redirect {
      host        = "ror.org"
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_302"
    }
  }

  condition {
    field  = "host-header"
    values = ["ror.community"]
  }
}

resource "aws_lb_listener_rule" "redirect_www_community" {
  listener_arn = aws_lb_listener.alb.arn

  action {
    type = "redirect"

    redirect {
      host        = "ror.org"
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_302"
    }
  }

  condition {
    field  = "host-header"
    values = ["www.ror.community"]
  }
}

module "alb-community" {
  source                        = "terraform-aws-modules/alb/aws"
  version                       = "~> v5.0"
  name                          = "alb-community"
  security_groups               = [aws_security_group.lb_sg.id]
  access_logs = {
    bucket                      = aws_s3_bucket.logs.bucket
  }
  subnets                       = module.vpc.public_subnets
  tags                          = map("Environment", "production")
  vpc_id                        = module.vpc.vpc_id
}

resource "aws_lb_listener" "alb-community-http" {
  load_balancer_arn = module.alb-community.this_lb_arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      host        = "ror.org"
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "alb-community" {
  load_balancer_arn = module.alb-community.this_lb_arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.ror-community.arn

  default_action {
    type = "redirect"

    redirect {
      host        = "ror.org"
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_route53_record" "apex-community" {
  zone_id = aws_route53_zone.public-community.zone_id
  name = "ror.community"
  type = "A"

  alias {
    name = data.aws_lb.alb-community.dns_name
    zone_id = data.aws_lb.alb-community.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "www-community" {
    zone_id = aws_route53_zone.public-community.zone_id
    name = "www.ror.community"
    type = "CNAME"
    ttl = var.ttl
    records = [data.aws_lb.alb-community.dns_name]
}
