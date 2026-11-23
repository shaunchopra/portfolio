# Adoption of the pre-existing, console-created resources (Terraform >= 1.5
# import blocks). These are no-ops once the resources are in state and can be
# kept as documentation or deleted after the first successful apply.

import {
  to = aws_s3_bucket.site
  id = "shaunchopra-portfolio"
}

import {
  to = aws_s3_bucket_ownership_controls.site
  id = "shaunchopra-portfolio"
}

import {
  to = aws_s3_bucket_public_access_block.site
  id = "shaunchopra-portfolio"
}

import {
  to = aws_s3_bucket_server_side_encryption_configuration.site
  id = "shaunchopra-portfolio"
}

import {
  to = aws_s3_bucket_policy.site
  id = "shaunchopra-portfolio"
}

import {
  to = aws_cloudfront_origin_access_control.site
  id = "E200YBENURIN4A"
}

import {
  to = aws_cloudfront_distribution.site
  id = "E1I2IQ66RCXLWJ"
}

import {
  to = aws_acm_certificate.site
  id = "arn:aws:acm:us-east-1:051334264317:certificate/411840cf-f1e6-4790-a43b-98f23012330b"
}

import {
  for_each = {
    apex_A    = "shaunchopra.com"
    apex_AAAA = "shaunchopra.com"
    www_A     = "www.shaunchopra.com"
    www_AAAA  = "www.shaunchopra.com"
  }
  to = aws_route53_record.site_alias[each.key]
  id = "Z03490663UEOG1HXQIAW6_${each.value}_${split("_", each.key)[1]}"
}

import {
  to = aws_route53_record.cert_validation["shaunchopra.com"]
  id = "Z03490663UEOG1HXQIAW6__6bdc627502abb320f5fd246cd5509ecc.shaunchopra.com_CNAME"
}

import {
  to = aws_route53_record.cert_validation["www.shaunchopra.com"]
  id = "Z03490663UEOG1HXQIAW6__1d262b4a74fc3e685406795c2baa885e.www.shaunchopra.com_CNAME"
}
