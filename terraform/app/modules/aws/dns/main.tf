resource "aws_acm_certificate" "this" {
  provider    = aws.us-east-1 # Only can be created in us-east-1
  domain_name = var.domain_name
  subject_alternative_names = [
    "*.${var.domain_name}",
  ]
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "validation" {
  for_each = {
    for dvo in aws_acm_certificate.this.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = var.ttl_validation
  type            = each.value.type
  zone_id         = data.aws_route53_zone.this.zone_id
}

resource "aws_acm_certificate_validation" "this" {
  provider                = aws.us-east-1
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}

# Redirect 'www' subdomain to apex
resource "aws_route53_record" "www_domain_name" {
  type    = "CNAME"
  zone_id = data.aws_route53_zone.this.zone_id
  name    = "www.${var.domain_name}"
  records = [var.domain_name]
  ttl     = var.ttl_route53_record
}

resource "aws_route53_record" "domain_name" {
  type    = "A"
  zone_id = data.aws_route53_zone.this.zone_id
  name    = var.domain_name

  alias {
    name                   = var.aws_cloudfront_distribution_this_domain_name
    zone_id                = var.alias_zone_id
    evaluate_target_health = false
  }
}