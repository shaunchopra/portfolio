output "site_bucket_name" {
  description = "S3 bucket the site is deployed to."
  value       = aws_s3_bucket.site.bucket
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID (for invalidations)."
  value       = aws_cloudfront_distribution.site.id
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain."
  value       = aws_cloudfront_distribution.site.domain_name
}

output "github_deploy_role_arn" {
  description = "Role ARN for aws-actions/configure-aws-credentials (role-to-assume)."
  value       = aws_iam_role.github_deploy.arn
}

output "acm_certificate_arn" {
  description = "ACM certificate (us-east-1) used by the distribution."
  value       = aws_acm_certificate.site.arn
}
