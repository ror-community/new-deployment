variable "access_key" {}
variable "secret_key" {}
variable "region" {
    default = "eu-west-1"
}

variable "ttl" {
  default = "300"
}

variable "vpc_name" {}
variable "vpc_cidr" {}
variable "azs" {
    type = "list"
}
variable "private_subnets"{
    type = "list"
}
variable "public_subnets"{
    type = "list"
}

variable "cluster_name" {
  default = "default"
}

variable "status_dns_name" {}

variable "waf_nat_ip" {}

variable "wafv2_nat_ip" {
  type = "list"
}

variable "whitelist_ips_dev"{
  type = "list"
}

variable "blacklist_ips_dev"{
  type = "list"
}

variable "whitelist_ips_staging"{
  type = "list"
}

variable "blacklist_ips_staging"{
  type = "list"
}
