# GitHub Actions -> AWS via OIDC (no long-lived keys).
#
# The role can:
#   * deploy: sync the site bucket and invalidate the distribution;
#   * run `terraform plan`: read the state bucket, write/delete the S3 lock
#     file, and read (not modify) the resources managed by this config.
# It can NOT run `terraform apply` – applies stay local/manual by design.

locals {
  github_oidc_host = "token.actions.githubusercontent.com"
  state_lock_key   = "${var.state_key}.tflock"
  role_tags = {
    Project   = "shaunchopra-portfolio"
    ManagedBy = "terraform"
  }
}

resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://${local.github_oidc_host}"
  client_id_list = ["sts.amazonaws.com"]
  # AWS validates GitHub's OIDC certificate via its trusted CA library, so no
  # thumbprint is required (provider >= 5.81 makes this optional).
  tags = local.role_tags
}

data "aws_iam_policy_document" "github_trust" {
  statement {
    sid     = "GitHubActionsOIDC"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.github_oidc_host}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.github_oidc_host}:sub"
      values   = var.github_oidc_subjects
    }
  }
}

resource "aws_iam_role" "github_deploy" {
  name                 = var.deploy_role_name
  description          = "Assumed by GitHub Actions (${var.github_repository}) to deploy the site and run terraform plan."
  assume_role_policy   = data.aws_iam_policy_document.github_trust.json
  max_session_duration = 3600
  tags                 = local.role_tags
}

# --- Deploy: S3 sync + CloudFront invalidation ------------------------------
data "aws_iam_policy_document" "deploy" {
  statement {
    sid       = "ListSiteBucket"
    actions   = ["s3:ListBucket", "s3:GetBucketLocation"]
    resources = [aws_s3_bucket.site.arn]
  }

  statement {
    sid       = "WriteSiteObjects"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${aws_s3_bucket.site.arn}/*"]
  }

  statement {
    sid       = "InvalidateDistribution"
    actions   = ["cloudfront:CreateInvalidation", "cloudfront:GetInvalidation", "cloudfront:ListInvalidations"]
    resources = [aws_cloudfront_distribution.site.arn]
  }
}

resource "aws_iam_role_policy" "deploy" {
  name   = "site-deploy"
  role   = aws_iam_role.github_deploy.id
  policy = data.aws_iam_policy_document.deploy.json
}

# --- terraform plan: state access + read-only on managed resources ----------
data "aws_iam_policy_document" "terraform_plan" {
  statement {
    sid       = "StateBucketList"
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${var.state_bucket_name}"]
  }

  statement {
    sid       = "StateRead"
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.state_bucket_name}/${var.state_key}"]
  }

  statement {
    sid       = "StateLockfile"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["arn:aws:s3:::${var.state_bucket_name}/${local.state_lock_key}"]
  }

  statement {
    sid       = "ReadSiteBucketConfig"
    actions   = ["s3:Get*", "s3:List*"]
    resources = [aws_s3_bucket.site.arn]
  }

  statement {
    sid = "ReadCloudFront"
    actions = [
      "cloudfront:Get*",
      "cloudfront:List*",
      "cloudfront:Describe*", # includes DescribeFunction
    ]
    resources = ["*"]
  }

  statement {
    sid       = "ReadAcm"
    actions   = ["acm:DescribeCertificate", "acm:GetCertificate", "acm:ListTagsForCertificate"]
    resources = [aws_acm_certificate.site.arn]
  }

  statement {
    sid       = "ReadRoute53Zone"
    actions   = ["route53:GetHostedZone", "route53:ListResourceRecordSets", "route53:ListTagsForResource"]
    resources = ["arn:aws:route53:::hostedzone/${var.hosted_zone_id}"]
  }

  statement {
    sid       = "ReadRoute53Global"
    actions   = ["route53:GetChange"]
    resources = ["arn:aws:route53:::change/*"]
  }

  statement {
    sid     = "ReadOwnIam"
    actions = ["iam:Get*", "iam:List*"]
    resources = [
      aws_iam_openid_connect_provider.github.arn,
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.deploy_role_name}",
    ]
  }
}

resource "aws_iam_role_policy" "terraform_plan" {
  name   = "terraform-plan-readonly"
  role   = aws_iam_role.github_deploy.id
  policy = data.aws_iam_policy_document.terraform_plan.json
}
