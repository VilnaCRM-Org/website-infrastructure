resource "aws_cloudfront_continuous_deployment_policy" "continuous_deployment_policy" {
  enabled = true

  staging_distribution_dns_names {
    items    = [aws_cloudfront_distribution.staging_cloudfront_distribution.domain_name]
    quantity = 1
  }

  traffic_config {
    type = "SingleWeight"
    single_weight_config {
      weight = "0.15"
    }
  }
}