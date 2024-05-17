module "dns" {
  source = "../../modules/aws/dns"

  domain_name = var.domain_name

  ttl_validation     = var.ttl_validation
  ttl_route53_record = var.ttl_route53_record
  alias_zone_id      = var.alias_zone_id

  aws_cloudfront_distribution_this_domain_name = module.cloudfront.domain_name
}