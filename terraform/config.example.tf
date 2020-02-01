variable "awsAccountId" {
  default = "XXXXXXXXXXXX"
  type = string
}

variable "awsRegion" {
  default = "us-east-1"
  type = string
}

variable "awsProfile" {
  default = "default"
  type = string
}

variable "s3WebApp" {
  default = "abcdefghijk.example.com"
  type = string
}

variable "esDomain" {
  default = "movies"
  type = string
}
