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

variable "service_discovery_namespace_id" {}

variable "elastic7_host_staging" {
  default = "elasticsearch-v7.staging.ror.org"
}

variable "elastic7_port_staging" {
  default = "80"
}

variable "ror-api-staging_tags" {
  type = "map"
}

variable "public_key" {}
variable "sentry_dsn" {}
variable "django_secret_key" {}
variable "token_staging" {}
variable "data_store_staging" {}
variable "public_store_staging" {}
variable "route_user" {}
variable "github_token" {}
variable "launch_darkly_key_staging" {}
variable "db_password_staging" {}
variable "db_username_staging" {}
variable "db_host_staging" {}
variable "db_port_staging" {}
variable "db_name" {}

variable "api_gateway_token" {
  type = string
}

variable "single_search_default_staging" {
  default = "False"
}
