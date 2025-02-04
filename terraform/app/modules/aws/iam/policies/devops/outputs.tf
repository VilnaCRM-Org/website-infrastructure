output "policy_arns" {
  value = {
    devops_codepipeline_policy = { arn = "${aws_iam_policy.codepipeline_policy.arn}" }
    devops_cloudwatch_policy   = { arn = "${aws_iam_policy.cloudwatch_policy.arn}" }
    devops_cloudfront_policy   = { arn = "${aws_iam_policy.cloudfront_policy.arn}" }
    devops_s3_policy           = { arn = "${aws_iam_policy.s3_policy.arn}" }
    devops_iam_policy          = { arn = "${aws_iam_policy.iam_policy.arn}" }
    devops_lambda_policy       = { arn = "${aws_iam_policy.lambda_policy.arn}" }
    devops_kms_policy          = { arn = "${aws_iam_policy.kms_policy.arn}" }
  }
  description = "ARNs of policies"
}