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

variable "elastic7_host" {
  default = "elasticsearch-v7.ror.org"
}
variable "elastic7_port" {
  default = "80"
}
variable "elastic7_host_dev" {
  default = "elasticsearch-v7.dev.ror.org"
}
variable "elastic7_port_dev" {
  default = "80"
}
variable "elastic7_host_staging" {
  default = "elasticsearch-v7.staging.ror.org"
}
variable "elastic7_port_staging" {
  default = "80"
}
variable "es_name" {
  default = "es"
}
variable "ror-api_tags" {
  type = "map"
}

variable "ror-api-dev_tags" {
  type = "map"
}

variable "ror-api-staging_tags" {
  type = "map"
}

variable "public_key" {}
variable "sentry_dsn" {}

variable "cloudfront_dns_name" {}

variable "django_secret_key" {}

variable "token" {}
variable "token_dev" {}
variable "token_staging" {}

variable "data_store" {}
variable "data_store_dev" {}
variable "data_store_staging" {}

variable "route_user" {}

variable "github_token" {}

variable "launch_darkly_key" {}
variable "launch_darkly_key_dev" {}
variable "launch_darkly_key_staging" {}