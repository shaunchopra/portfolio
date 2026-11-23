data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

# ---------------------------------------------------------------------------
# SAFE IMPROVEMENT: security response headers (AWS-managed policy).
#
# The distribution is on CloudFront's Free flat-rate pricing plan, which rejects
# CUSTOM response headers policies, so the AWS-managed policy is used instead:
#   Strict-Transport-Security: max-age=31536000 (no includeSubDomains/preload)
#   X-Content-Type-Options: nosniff
#   X-Frame-Options: SAMEORIGIN
#   Referrer-Policy: strict-origin-when-cross-origin
#   X-XSS-Protection: 1; mode=block
# It only ADDS headers; the CloudFront-generated `x-cache` / `x-amz-cf-pop`
# headers that js/main.js reads via a same-origin HEAD fetch are unaffected.
# Toggle with var.enable_security_headers.
# ---------------------------------------------------------------------------
data "aws_cloudfront_response_headers_policy" "security_headers" {
  name = "Managed-SecurityHeadersPolicy"
}

locals {
  s3_origin_id = "shaunchopra-portfolio.s3.ap-southeast-2.amazonaws.com-mv980koh5vg"
}

resource "aws_cloudfront_origin_access_control" "site" {
  # Name/description as created by the CloudFront console; changing the name is
  # an in-place update, but there is no reason to churn it.
  name                              = "oac-shaunchopra-portfolio.s3.ap-southeast-2.amazonaw-mv99vlg4f6x"
  description                       = "Created by CloudFront"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# ---------------------------------------------------------------------------
# Viewer-request function: apex -> www 301 (canonical host) and Astro
# directory-style URI rewriting. See functions/viewer-request.js.
# (The account's prod-/dev-canonical-host-redirect functions belong to other
# sites' distributions and are intentionally not referenced here.)
# ---------------------------------------------------------------------------
resource "aws_cloudfront_function" "viewer_request" {
  name    = "shaunchopra-portfolio-viewer-request"
  runtime = "cloudfront-js-2.0"
  comment = "Apex->www 301 and directory index rewrite for www.shaunchopra.com"
  publish = true
  code    = file("${path.module}/functions/viewer-request.js")
}

resource "aws_cloudfront_distribution" "site" {
  enabled             = true
  is_ipv6_enabled     = true
  http_version        = "http2"
  price_class         = "PriceClass_All"
  default_root_object = "index.html"
  comment             = ""
  aliases             = [var.domain_name, "www.${var.domain_name}"]
  web_acl_id          = var.waf_web_acl_arn

  origin {
    origin_id                = local.s3_origin_id
    domain_name              = aws_s3_bucket.site.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.site.id
    connection_attempts      = 3
    connection_timeout       = 10
  }

  default_cache_behavior {
    target_origin_id       = local.s3_origin_id
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    cache_policy_id        = data.aws_cloudfront_cache_policy.caching_optimized.id

    # SAFE IMPROVEMENT (not part of the original console setup): security headers.
    response_headers_policy_id = var.enable_security_headers ? data.aws_cloudfront_response_headers_policy.security_headers.id : null

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.viewer_request.arn
    }
  }

  # Real 404s instead of S3's 403 AccessDenied XML (a private bucket returns 403
  # for missing keys because the OAC principal has no s3:ListBucket).
  dynamic "custom_error_response" {
    for_each = [403, 404]
    content {
      error_code            = custom_error_response.value
      response_code         = 404
      response_page_path    = "/404.html"
      error_caching_min_ttl = 60
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.site.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = {
    Name = "shaunchopra-portfolio"
  }

  lifecycle {
    prevent_destroy = true
  }
}

