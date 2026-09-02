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
  type = list(string)
}

variable "private_security_group_id" {}

variable "service_discovery_namespace_id" {}

variable "elastic7_host_dev" {
  default = "elasticsearch-v7.dev.ror.org"
}

variable "elastic7_port_dev" {
  default = "80"
}

variable "ror-api-dev_tags" {
  type = "map"
}

variable "public_key" {}
variable "sentry_dsn" {}
variable "django_secret_key" {}
variable "token_dev" {}
variable "data_store_dev" {}
variable "public_store_dev" {}
variable "route_user" {}
variable "github_token" {}
variable "launch_darkly_key_dev" {}
variable "db_password_dev" {}
variable "db_username_dev" {}
variable "db_host_dev" {}
variable "db_port_dev" {}
variable "db_name" {}

variable "api_gateway_token" {
  type = string
}

variable "single_search_default_dev" {
  default = "False"
}
