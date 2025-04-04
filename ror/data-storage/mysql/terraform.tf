terraform {
  required_version = ">= 1.6"

  cloud {
    organization = "ror"

    workspaces {
      name = "ror-data-storage-mysql"
    }
  }
}