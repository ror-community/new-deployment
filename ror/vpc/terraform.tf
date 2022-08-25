terraform {
  required_version = ">= 0.13"

  backend "atlas" {
    name         = "ror/prod-vpc"
  }
}
