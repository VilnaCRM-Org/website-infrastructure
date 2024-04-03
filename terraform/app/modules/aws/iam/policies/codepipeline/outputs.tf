output "policy_arns" {
  value = {
    codepipeline_policy = { arn = "${aws_iam_policy.codepipeline_policy.arn}" }
    general_policy    = { arn = "${aws_iam_policy.general_policy.arn}" }
    iam_policy        = { arn = "${aws_iam_policy.iam_policy.arn}" }
    kms_policy        = { arn = "${aws_iam_policy.kms_policy.arn}" }
    sns_policy        = { arn = "${aws_iam_policy.sns_policy.arn}" }
    terraform_policy  = { arn = "${aws_iam_policy.terraform_policy.arn}" }
    s3_policy         = { arn = "${aws_iam_policy.s3_policy.arn}" }
  }
  description = "ARNs of policies"
}