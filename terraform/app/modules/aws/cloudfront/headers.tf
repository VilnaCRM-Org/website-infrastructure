resource "aws_cloudfront_response_headers_policy" "response_headers" {
  provider = aws.us-east-1
  name     = "${var.project_name}-cloudfront-policy"
  #checkov:skip=CKV_AWS_259: Bugged checkov, already added

  security_headers_config {
    strict_transport_security {
      access_control_max_age_sec = var.cloudfront_access_control_max_age_sec
      include_subdomains         = true
      override                   = true
      preload                    = true
    }
    content_type_options {
      override = true
    }
    frame_options {
      frame_option = "DENY"
      override     = true
    }
    referrer_policy {
      referrer_policy = "same-origin"
      override        = true
    }
    xss_protection {
      mode_block = true
      protection = true
      override   = true
    }
    content_security_policy {
      content_security_policy = "frame-ancestors 'none'; default-src 'self'; img-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; object-src 'none'"
      override                = true
    }
  }
  custom_headers_config {
    items {
      header   = "Cross-Origin-Resource-Policy"
      override = true
      value    = "same-origin"
    }
    items {
      header   = "Cross-Origin-Opener-Policy"
      override = true
      value    = "same-origin"
    }
    items {
      header   = "Cross-Origin-Embedder-Policy"
      override = true
      value    = "require-corp"
    }
    items {
      header   = "Cache-Control"
      override = true
      value    = "max-age=3600, public"
    }
  }
}