output "policy_arns" {
  value = {
    website_infra_lambda_policy     = { arn = "${aws_iam_policy.lambda_policy.arn}" },
    website_infra_dns_policy        = { arn = "${aws_iam_policy.dns_policy.arn}" }
    website_infra_cloudfront_policy = { arn = "${aws_iam_policy.cloudfront_policy.arn}" }
    website_infra_general_policy    = { arn = "${aws_iam_policy.general_policy.arn}" }
    website_infra_iam_policy        = { arn = "${aws_iam_policy.iam_policy.arn}" }
    website_infra_kms_policy        = { arn = "${aws_iam_policy.kms_policy.arn}" }
    website_infra_sns_policy        = { arn = "${aws_iam_policy.sns_policy.arn}" }
    website_infra_s3_policy         = { arn = "${aws_iam_policy.s3_policy.arn}" }
  }
  description = "ARNs of policies"
}