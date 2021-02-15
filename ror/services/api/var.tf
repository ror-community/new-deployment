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

variable "elastic_host" {
  default = "elasticsearch.ror.org"
}
variable "elastic_port" {
  default = "80"
}
variable "elastic_host_dev" {
  default = "elasticsearch.dev.ror.org"
}
variable "elastic_port_dev" {
  default = "80"
}
variable "elastic_host_staging" {
  default = "elasticsearch.dev.ror.org"
}
variable "elastic_port_staging" {
  default = "80"
}
variable "index_staging" {
  default = "staging-organizations"
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
