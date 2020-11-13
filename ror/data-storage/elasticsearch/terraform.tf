terraform {
  required_version = ">= 0.12"

  backend "atlas" {
    name         = "ror/ror-data-storage-elasticsearch"
  }
}
