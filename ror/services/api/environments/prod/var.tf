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

variable "elastic7_host" {
  default = "elasticsearch-v7.ror.org"
}

variable "elastic7_port" {
  default = "80"
}

variable "ror-api_tags" {
  type = map(string)
}

variable "public_key" {}
variable "sentry_dsn" {}
variable "django_secret_key" {}
variable "token" {}
variable "data_store" {}
variable "public_store" {}
variable "route_user" {}
variable "github_token" {}
variable "launch_darkly_key" {}
variable "db_password" {}
variable "db_username" {}
variable "db_host" {}
variable "db_port" {}
variable "db_name" {}

variable "api_gateway_token" {
  type = string
}

variable "single_search_default" {
  default = "False"
}
