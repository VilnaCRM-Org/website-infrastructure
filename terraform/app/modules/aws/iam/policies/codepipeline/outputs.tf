output "policy_arns" {
  value = {
    ci_cd_infra_codepipeline_policy = { arn = "${aws_iam_policy.codepipeline_policy.arn}" }
    ci_cd_infra_general_policy      = { arn = "${aws_iam_policy.general_policy.arn}" }
    ci_cd_infra_iam_policy          = { arn = "${aws_iam_policy.iam_policy.arn}" }
    ci_cd_infra_kms_policy          = { arn = "${aws_iam_policy.kms_policy.arn}" }
    ci_cd_infra_sns_policy          = { arn = "${aws_iam_policy.sns_policy.arn}" }
    ci_cd_infra_s3_policy           = { arn = "${aws_iam_policy.s3_policy.arn}" }
  }
  description = "ARNs of policies"
}