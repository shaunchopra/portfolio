variable "aws_region" {
  description = "Primary region (site bucket, state bucket)."
  type        = string
  default     = "ap-southeast-2"
}

variable "domain_name" {
  description = "Apex domain of the site."
  type        = string
  default     = "shaunchopra.com"
}

variable "hosted_zone_id" {
  description = "Route 53 public hosted zone for domain_name (created by Route 53 Registrar; not managed here)."
  type        = string
  default     = "Z03490663UEOG1HXQIAW6"
}

variable "site_bucket_name" {
  description = "Private S3 bucket holding the static site."
  type        = string
  default     = "shaunchopra-portfolio"
}

variable "state_bucket_name" {
  description = "Terraform state bucket (created by ./bootstrap). Must match the backend block in versions.tf."
  type        = string
  default     = "shaunchopra-portfolio-tfstate-051334264317"
}

variable "state_key" {
  description = "Key of this config's state object in the state bucket. Must match the backend block in versions.tf."
  type        = string
  default     = "site/terraform.tfstate"
}

variable "waf_web_acl_arn" {
  description = "Existing WAFv2 web ACL (us-east-1, created by the CloudFront console) attached to the distribution. Not managed here. Set to null to detach."
  type        = string
  default     = "arn:aws:wafv2:us-east-1:051334264317:global/webacl/CreatedByCloudFront-adc39c39/bd6f293c-2c43-4d2c-91f1-5d5b6fa9fc4a"
}

variable "github_repository" {
  description = "GitHub repository (owner/name) allowed to assume the deploy role."
  type        = string
  default     = "shaunchopra/portfolio"
}

variable "github_oidc_subjects" {
  description = "Allowed OIDC `sub` claims (exact match) for the deploy role."
  type        = list(string)
  default = [
    "repo:shaunchopra@91772089/portfolio@1420312753:ref:refs/heads/main",
    "repo:shaunchopra@91772089/portfolio@1420312753:pull_request",
    "repo:shaunchopra@91772089/portfolio@1420312753:environment:production",
  ]
}

variable "deploy_role_name" {
  description = "Name of the IAM role assumed by GitHub Actions."
  type        = string
  default     = "shaunchopra-portfolio-github-deploy"
}

variable "enable_security_headers" {
  description = "Attach the AWS-managed Managed-SecurityHeadersPolicy (HSTS, nosniff, X-Frame-Options, Referrer-Policy) to the default cache behaviour."
  type        = bool
  default     = true
}
