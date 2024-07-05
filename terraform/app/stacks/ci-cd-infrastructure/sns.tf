module "cloudwatch_alerts_sns" {
  source       = "../../modules/aws/sns/ci-cd-alerts"
  project_name = var.project_name

  tags = var.tags

  cloudwatch_alarms_arns = concat(
    module.ci_cd_website_codepipeline.cloudwatch_alarms_arns,
    module.dynamodb_logging.cloudwatch_alarms_arns
  )
}