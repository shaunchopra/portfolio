# Certificate for the apex + www, DNS-validated in the Route 53 zone.
resource "aws_acm_certificate" "site" {
  provider = aws.us_east_1

  domain_name               = var.domain_name
  subject_alternative_names = [var.domain_name, "www.${var.domain_name}"]
  validation_method         = "DNS"

  options {
    certificate_transparency_logging_preference = "ENABLED"
  }

  lifecycle {
    create_before_destroy = true
    prevent_destroy       = true
  }
}

# Logical resource only (no AWS object): waits until the cert is ISSUED.
resource "aws_acm_certificate_validation" "site" {
  provider = aws.us_east_1

  certificate_arn         = aws_acm_certificate.site.arn
  validation_record_fqdns = [for r in aws_route53_record.cert_validation : r.fqdn]
}
