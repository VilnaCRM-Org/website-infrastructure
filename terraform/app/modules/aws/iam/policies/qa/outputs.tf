output "policy_arns" {
  value = {
    qa_codepipeline_policy = { arn = "${aws_iam_policy.codepipeline_policy.arn}" }
    qa_cloudwatch_policy   = { arn = "${aws_iam_policy.cloudwatch_policy.arn}" }
    qa_cloudfront_policy   = { arn = "${aws_iam_policy.cloudfront_policy.arn}" }
    qa_s3_policy           = { arn = "${aws_iam_policy.s3_policy.arn}" }
  }
  description = "ARNs of policies"
}