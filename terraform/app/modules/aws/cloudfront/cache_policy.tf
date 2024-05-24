resource "aws_cloudfront_cache_policy" "cloudfront_cache_policy" {
  name        = "${var.project_name}-caching-policy"
  comment     = "Policy for CloudFront(CachingOptimized)"
  min_ttl     = var.cloudfront_configuration.min_ttl
  default_ttl = var.cloudfront_configuration.default_ttl
  max_ttl     = var.cloudfront_configuration.max_ttl

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"

    }
    headers_config {
      header_behavior = "none"

    }
    query_strings_config {
      query_string_behavior = "none"
    }
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true
  }
}