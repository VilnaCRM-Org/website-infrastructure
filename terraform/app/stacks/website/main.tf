module "static-website-s3-cloudfront-acm" {
  source                = "joshuamkite/static-website-s3-cloudfront-acm/aws//examples/simple-complete-website-with-sample-content"
  domain_name           = var.site_domain
  region                = var.aws_region
}
