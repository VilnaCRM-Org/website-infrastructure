output "policy_arns" {
  value = {
    frontend_codepipeline_policy = { arn = "${aws_iam_policy.codepipeline_policy.arn}" }
    frontend_cloudwatch_policy   = { arn = "${aws_iam_policy.cloudwatch_policy.arn}" }
    frontend_cloudfront_policy   = { arn = "${aws_iam_policy.cloudfront_policy.arn}" }
    frontend_s3_policy           = { arn = "${aws_iam_policy.s3_policy.arn}" }
  }
  description = "ARNs of policies"
}