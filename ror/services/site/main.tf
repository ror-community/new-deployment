resource "aws_s3_bucket" "main-ror-community" {
  bucket = "main.ror.community"
  acl = "public-read"
  policy = templatefile("s3_cloudfront.json", {
    bucket_name = "main.ror.community"
  })

  website {
    index_document = "index.html"
  }

  tags = {
    site        = "ror"
    environment = "production"
  }
}
