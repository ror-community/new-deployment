resource "aws_s3_bucket" "search-dev" {
    bucket = "search.dev.ror.community"
    acl = "public-read"
    policy = data.template_file.search-dev.rendered

    website {
        index_document = "index.html"
    }

    tags = {
        Name = "search-dev"
    }
    versioning {
        enabled = true
    }
}