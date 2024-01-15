module "static-website-s3-cloudfront-acm" {
  source      = "git::https://github.com/joshuamkite/terraform-aws-static-website-s3-cloudfront-acm.git?ref=8103476a4ed0a960a6bd1ebe1f012d66525ce78a"
  domain_name = var.site_domain
  providers = {
    aws.us-east-1 = aws.us-east-1
    aws           = aws
  }
}
