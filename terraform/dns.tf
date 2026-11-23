# Only the records that belong to this site are managed. The zone itself
# (registrar-created), NS/SOA and unrelated records (SES DKIM, DMARC, test, ...)
# are intentionally left alone.

locals {
  site_hostnames = {
    apex = var.domain_name
    www  = "www.${var.domain_name}"
  }

  # One alias record per hostname x record type.
  alias_records = {
    for pair in setproduct(keys(local.site_hostnames), ["A", "AAAA"]) :
    "${pair[0]}_${pair[1]}" => {
      name = local.site_hostnames[pair[0]]
      type = pair[1]
    }
  }
}

resource "aws_route53_record" "site_alias" {
  for_each = local.alias_records

  zone_id = var.hosted_zone_id
  name    = each.value.name
  type    = each.value.type

  alias {
    name                   = aws_cloudfront_distribution.site.domain_name
    zone_id                = aws_cloudfront_distribution.site.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.site.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id         = var.hosted_zone_id
  name            = each.value.name
  type            = each.value.type
  ttl             = 300
  records         = [each.value.record]
  allow_overwrite = false
}
