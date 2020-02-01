resource "aws_elasticsearch_domain" "esDomain" {
	domain_name           = var.esDomain
	elasticsearch_version = "7.1"

	cluster_config {
		instance_type = "t2.small.elasticsearch"
		instance_count = 1
	}

	ebs_options {
		ebs_enabled = true
		volume_type = "standard"
		volume_size = 10
	}

  access_policies = <<CONFIG
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Action": "es:*",
			"Principal": "*",
			"Effect": "Allow",
			"Resource": "arn:aws:es:${var.awsRegion}:${var.awsAccountId}:domain/${var.esDomain}/*"
		}
	]
}
CONFIG
}
