output "policy_arns" {
  value = {
    ci_cd_codepipeline_policy = { arn = "${aws_iam_policy.codepipeline_policy.arn}" }
    ci_cd_general_policy      = { arn = "${aws_iam_policy.general_policy.arn}" }
    ci_cd_iam_policy          = { arn = "${aws_iam_policy.iam_policy.arn}" }
    ci_cd_kms_policy          = { arn = "${aws_iam_policy.kms_policy.arn}" }
    ci_cd_sns_policy          = { arn = "${aws_iam_policy.sns_policy.arn}" }
    ci_cd_s3_policy           = { arn = "${aws_iam_policy.s3_policy.arn}" }
  }
  description = "ARNs of policies"
}