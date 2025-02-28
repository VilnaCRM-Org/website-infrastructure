resource "aws_cloudfront_function" "routing_function" {
  name    = "routing-function"
  runtime = "cloudfront-js-1.0"
  comment = "Routing logic for CloudFront"
  publish = true

  code = file("./output/cloudfront_routing.js")
}