resource "aws_s3_bucket" "s3WebApp" {
	bucket = var.s3WebApp
	acl    = "public-read"
	force_destroy = true
	website {
		index_document = "index.html"
		error_document = "index.html"
	}
}

output "s3WebAppBucket" {
	value = aws_s3_bucket.s3WebApp.bucket
}
