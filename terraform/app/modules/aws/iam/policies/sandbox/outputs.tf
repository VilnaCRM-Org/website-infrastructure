output "policy_arns" {
  value = {
    sandbox_infra_general_policy    = { arn = "${aws_iam_policy.general_policy.arn}" }
    sandbox_infra_s3_policy         = { arn = "${aws_iam_policy.s3_policy.arn}" }
  }
  description = "ARNs of policies"
}