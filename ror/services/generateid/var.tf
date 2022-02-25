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

variable "namespace_id" {}

variable "generateid_tags" {
  type = "map"
}

variable "generateid-dev_tags" {
  type = "map"
}

variable "generateid-staging_tags" {
  type = "map"
}

variable "route_user" {}

variable "token_dev" {}
variable "token_stage" {}
variable "token" {}

variable "ror_api_url_dev" {}
variable "ror_api_url_stage" {}
variable "ror_api_url" {}

variable "allowed_origins_dev" {}
variable "allowed_origins_stage" {}
variable "allowed_origins" {}

variable "microservice_use_token_dev" {}