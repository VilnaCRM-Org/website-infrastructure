module "static-website-s3-cloudfront-acm" {
  source      = "git::https://github.com/joshuamkite/terraform-aws-static-website-s3-cloudfront-acm/tree/2.2.0/examples/simple-complete-website-with-sample-content?ref=dc27b0842a453458b7294352b3c8751198a33110"
  domain_name = var.site_domain
  region      = var.aws_region
}
