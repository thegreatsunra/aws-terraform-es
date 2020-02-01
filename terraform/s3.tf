resource "aws_s3_bucket" "s3WebApp" {
  bucket = var.s3WebApp
  acl    = "public-read"
  force_destroy = true
  website {
    index_document = "index.html"
    error_document = "index.html"
  }
  # cors_rule {
  #   allowed_headers = ["*"]
  #   allowed_methods = ["PUT", "POST"]
  #   allowed_origins = ["https://s3-website-test.hashicorp.com"]
  #   expose_headers  = ["ETag"]
  #   max_age_seconds = 3000
  # }
}
