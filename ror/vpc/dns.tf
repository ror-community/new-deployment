// TODO bring under Terraform control
// resource "aws_route53_zone" "public" {
//     name = "ror.org"

//     lifecycle {
//         prevent_destroy = true
//     }

//     tags = {
//         Environment = "public"
//     }
// }

resource "aws_route53_zone" "internal" {
    name = "ror.org"
    
    vpc {
        vpc_id = module.vpc.vpc_id
    }

    tags = {
        Environment = "internal"
    }
}

// TODO bring under Terraform control
// resource "aws_route53_record" "internal-ns" {
//     zone_id = aws_route53_zone.internal.zone_id
//     name = "ror.org"
//     type = "NS"
//     ttl = "30"
//     records = [
//         aws_route53_zone.internal.name_servers.0,
//         aws_route53_zone.internal.name_servers.1,
//         aws_route53_zone.internal.name_servers.2,
//         aws_route53_zone.internal.name_servers.3
//     ]
// }

// resource "aws_service_discovery_private_dns_namespace" "internal" {
//   name = "ror.community"
//   vpc = module.vpc.vpc_id
// }

// TODO bring under Terraform control
// resource "aws_route53_record" "mx-ror" {
//     zone_id = data.aws_route53_zone.public.zone_id
//     name = data.aws_route53_zone.public.name
//     type = "MX"
//     ttl = "300"
//     records = [
//         "1 aspmx.l.google.com",
//         "5 alt1.aspmx.l.google.com",
//         "5 alt2.aspmx.l.google.com",
//         "10 aspmx2.googlemail.com",
//         "10 aspmx3.googlemail.com"
//     ]
// }

resource "aws_route53_record" "status" {
    zone_id = data.aws_route53_zone.public.zone_id
    name = "status.ror.org"
    type = "CNAME"
    ttl = "3600"
    records = [var.status_dns_name]
}

resource "aws_route53_zone" "public-community" {
    name = "ror.community"

    lifecycle {
        prevent_destroy = true
    }

    tags = {
        Environment = "public"
    }
}
