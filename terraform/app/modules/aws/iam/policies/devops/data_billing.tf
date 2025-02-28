data "aws_iam_policy_document" "billing_readonly_policy_doc" {
  statement {
    sid    = "BillingReadOnlyPolicy"
    effect = "Allow"
    actions = [
      "aws-portal:ViewBilling",
      "aws-portal:ViewUsage",
      "aws-portal:ViewAccount",
      "aws-portal:ViewPaymentMethods",
      "aws-portal:ViewPaymentHistory",
      "aws-portal:ViewCredits",
      "aws-portal:ViewBudget"
    ]
    resources = ["*"]
  }
}