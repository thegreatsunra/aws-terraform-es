provider "aws" {
  version    = "~> 2.46"
  profile    = var.awsProfile
  region     = var.awsRegion
}

provider "archive" {
  version    = "~> 1.3"
}

provider "template" {
  version    = "~> 2.1"
}
