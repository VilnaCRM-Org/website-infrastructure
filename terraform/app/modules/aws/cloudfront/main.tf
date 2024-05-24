resource "aws_cloudfront_distribution" "this" {
  provider = aws.us-east-1

  #ts:skip=AC-AW-IS-CD-M-0026 Geo restriction is not needed

  origin_group {
    origin_id = "${var.project_name}-groupS3"

    failover_criteria {
      status_codes = [500, 502]
    }

    member {
      origin_id = local.s3_origin_id
    }

    member {
      origin_id = local.s3_failover_origin_id
    }
  }

  origin {
    domain_name              = var.aws_s3_bucket_this_bucket_regional_domain_name
    origin_id                = local.s3_origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.this.id
  }

  origin {
    domain_name              = var.aws_s3_bucket_replication_bucket_regional_domain_name
    origin_id                = local.s3_failover_origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.replication.id
  }

  web_acl_id = aws_wafv2_web_acl.waf_web_acl.arn

  aliases = [
    var.domain_name,
    "www.${var.domain_name}"
  ]

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = var.cloudfront_default_root_object

  logging_config {
    include_cookies = false
    bucket          = var.logging_bucket_domain_name
    prefix          = "cloudfront-logs/"
  }

  default_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD",
    ]

    cached_methods = [
      "GET",
      "HEAD",
    ]
    response_headers_policy_id = aws_cloudfront_response_headers_policy.response_headers.id

    target_origin_id = "${var.project_name}-groupS3"

    cache_policy_id = aws_cloudfront_cache_policy.cloudfront_cache_policy.id

    viewer_protocol_policy = "redirect-to-https"

    # https://stackoverflow.com/questions/67845341/cloudfront-s3-etag-possible-for-cloudfront-to-send-updated-s3-object-before-t
    min_ttl     = var.cloudfront_configuration.min_ttl
    default_ttl = var.cloudfront_configuration.default_ttl
    max_ttl     = var.cloudfront_configuration.max_ttl

    compress = true

  }

  price_class = var.cloudfront_configuration.price_class

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  dynamic "viewer_certificate" {
    for_each = [var.aws_acm_certificate_id]
    content {
      acm_certificate_arn      = var.aws_acm_certificate_arn
      ssl_support_method       = "sni-only"
      minimum_protocol_version = var.cloudfront_minimum_protocol_version
    }
  }

  dynamic "custom_error_response" {
    for_each = var.cloudfront_custom_error_responses
    content {
      error_code            = custom_error_response.value.error_code
      response_code         = custom_error_response.value.response_code
      error_caching_min_ttl = custom_error_response.value.error_caching_min_ttl
      response_page_path    = custom_error_response.value.response_page_path
    }
  }

  wait_for_deployment = false
}

resource "aws_cloudfront_origin_access_control" "this" {
  name                              = var.domain_name
  description                       = "${var.domain_name} OAC"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_origin_access_control" "replication" {
  name                              = "${var.domain_name}-replication"
  description                       = "${var.domain_name} OAC"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}