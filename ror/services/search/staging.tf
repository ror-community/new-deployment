resource "aws_s3_bucket" "search-staging" {
    bucket = "search.staging.ror.community"
    acl = "public-read"
    policy = data.template_file.search-dev.rendered

    website {
        index_document = "index.html"
    }

    tags = {
        Name = "search-staging"
    }
    versioning {
        enabled = true
    }
}