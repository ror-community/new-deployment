terraform {
  required_version = "= 0.12.29"

  backend "atlas" {
    name = "datacite-ng/ror-services-api-staging"
  }
}
