resource "aws_s3_bucket" "search" {
    bucket = "search.ror.org"
    acl = "public-read"
    policy = data.template_file.search.rendered

    website {
        index_document = "index.html"
    }

    tags = {
        Name = "search"
    }
    versioning {
        enabled = true
    }
}
