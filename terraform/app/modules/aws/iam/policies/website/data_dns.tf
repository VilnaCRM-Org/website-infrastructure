data "aws_iam_policy_document" "dns_policy_doc" {
  statement {
    sid    = "Route53Policy"
    effect = "Allow"
    actions = [
      "route53:ListTagsForResource"
    ]
    resources = [
      "arn:aws:route53:::healthcheck/*",
      "arn:aws:route53:::hostedzone/*"
    ]
  }
  statement {
    sid    = "Route53RecordsPolicy"
    effect = "Allow"
    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets",
      "route53:GetHostedZone"
    ]
    resources = [
      "arn:aws:route53:::hostedzone/*"
    ]
  }
  statement {
    sid    = "Route53GetChangePolicy"
    effect = "Allow"
    actions = [
      "route53:GetChange"
    ]
    resources = [
      "arn:aws:route53:::change/*"
    ]
  }
  statement {
    sid    = "ACMPolicy"
    effect = "Allow"
    actions = [
      "acm:ListTagsForCertificate",
      "acm:DescribeCertificate",
      "acm:DeleteCertificate"
    ]
    resources = [
      "arn:aws:acm:us-east-1:${local.account_id}:certificate/*"
    ]
  }
} 