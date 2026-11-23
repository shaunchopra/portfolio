terraform {
  # >= 1.10 for S3-native state locking (use_lockfile).
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.60"
    }
  }

  # State bucket is created by ./bootstrap (local state). S3 native locking:
  # a `<key>.tflock` object is written next to the state; no DynamoDB table.
  backend "s3" {
    bucket       = "shaunchopra-portfolio-tfstate-051334264317"
    key          = "site/terraform.tfstate"
    region       = "ap-southeast-2"
    encrypt      = true
    use_lockfile = true
  }
}
