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
    type = list(string)
}
variable "private_subnets"{
    type = list(string)
}
variable "public_subnets"{
    type = list(string)
}

variable "cluster_name" {
  default = "default"
}

variable "status_dns_name" {}

variable "mailchimp_cname_1" {}

variable "mailchimp_cname_2" {}

variable "mailchimp_dmarc" {}

variable "waf_nat_ip" {}

variable "wafv2_nat_ip" {
  type = list(string)
}

variable "whitelist_ips"{
  type = list(string)
}

variable "blacklist_ips"{
  type = list(string)
}

variable "whitelist_ips_dev"{
  type = list(string)
}

variable "blacklist_ips_dev"{
  type = list(string)
}

variable "ratelimit_ips_dev"{
  type = list(string)
}

variable "whitelist_ips_staging"{
  type = list(string)
}

variable "blacklist_ips_staging"{
  type = list(string)
}

variable "ratelimit_ips_staging"{
  type = list(string)
}

variable "whitelist_ips_prod"{
  type = list(string)
}

variable "blacklist_ips_prod"{
  type = list(string)
}

variable "ratelimit_ips_prod"{
  type = list(string)
}

variable "blacklist_custom_msg_ips_prod"{
  type = list(string)
}

variable "api_gateway_token" {
  type        = string
}
