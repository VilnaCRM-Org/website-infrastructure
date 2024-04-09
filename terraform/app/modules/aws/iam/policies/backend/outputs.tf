output "policy_arns" {
  value = {
    backend_cloudwatch_policy = { arn = "${aws_iam_policy.cloudwatch_policy.arn}" }
    backend_cloudfront_policy = { arn = "${aws_iam_policy.cloudfront_policy.arn}" }
    backend_s3_policy         = { arn = "${aws_iam_policy.s3_policy.arn}" }
  }
  description = "ARNs of policies"
}