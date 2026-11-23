provider "aws" {
  region = var.aws_region
}

# CloudFront only accepts ACM certificates from us-east-1.
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}
