output "policy_arns" {
  value = {
    admin_iam_policy = { arn = "${aws_iam_policy.iam_policy.arn}" }
  }
  description = "ARNs of policies"
}