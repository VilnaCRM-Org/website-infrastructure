resource "aws_cloudfront_function" "routing_function" {
  name    = "routing-function"
  runtime = "cloudfront-js-1.0"
  comment = "Routing logic for CloudFront"
  publish = true

  code = <<EOT
function handler(event) {
    var request = event.request;
    var uri = request.uri;

    if (uri === "/index.html") {
        request.uri = "/";
    } else if (uri === "/swagger.html") {
        request.uri = "/swagger";
    }

    if (uri === "/test") {
        request.uri = "/_next/static/media/desktop.0ec56f83.jpg";
    }

    return request;
}
EOT
}