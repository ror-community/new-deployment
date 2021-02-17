variable "access_key" {}
variable "secret_key" {}

variable "region" {
  default = "eu-west-1"
}

variable "ttl" {
  default = "300"
}

variable "vpc_id" {}

variable "private_subnet_ids" {
  type = "list"
}

variable "private_security_group_id" {}

variable "ror-reconcile_tags" {
  type = "map"
}

variable "ror-reconcile-dev_tags" {
  type = "map"
}

variable "ror-reconcile-staging_tags" {
  type = "map"
}

variable "public_key" {}

variable "aws_service_discovery_private_dns_namespace_id" {}

variable "lb_arn" {}

variable "ror_api_dev" { 
  default = "https://api.dev.ror.org"
}
variable "ror_api_staging" { 
  default = "https://api.ror.org"
}
variable "ror_recon_dev" { 
  default = "https://reconcile.dev.ror.org"
}
variable "ror_recon_staging" { 
  default = "https://reconcile.ror.org"
}
