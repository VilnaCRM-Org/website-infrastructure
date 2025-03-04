data "http" "routing_function_source" {
  url = "https://raw.githubusercontent.com/VilnaCRM-Org/website/133-cloudfront-routing/scripts/cloudfront_routing.js"
}

resource "aws_cloudfront_function" "routing_function" {
  name    = "routing-function"
  runtime = "cloudfront-js-1.0"
  comment = "Routing logic for CloudFront"
  publish = true  
  
  code = data.http.routing_function_source.response_body
}