data "aws_iam_policy_document" "cloudwatch_policy_doc" {
  statement {
    sid    = "ReadOnlyCloudwatchPolicy"
    effect = "Allow"
    actions = [
      "cloudwatch:ListDashboards",
      "cloudwatch:ListMetrics",
      "cloudwatch:ListMetricStreams",
      "cloudwatch:ListServiceLevelObjectives",
      "cloudwatch:ListServices",
      "cloudwatch:ListTagsForResource",
      "cloudwatch:BatchGetServiceLevelIndicatorReport",
      "cloudwatch:BatchGetServiceLevelObjectiveBudgetReport",
      "cloudwatch:DescribeAlarmHistory",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:DescribeAlarmsForMetric",
      "cloudwatch:DescribeAnomalyDetectors",
      "cloudwatch:DescribeInsightRules",
      "cloudwatch:GenerateQuery",
      "cloudwatch:GetDashboard",
      "cloudwatch:GetMetricData",
      "cloudwatch:GetInsightRuleReport",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:GetMetricStream",
      "cloudwatch:GetMetricWidgetImage",
      "cloudwatch:GetService",
      "cloudwatch:GetServiceData",
      "cloudwatch:GetServiceLevelObjective",
      "cloudwatch:GetTopologyDiscoveryStatus",
      "cloudwatch:GetTopologyMap",
      "cloudwatch:ListManagedInsightRules"
    ]
    resources = [
      "arn:aws:cloudfront::${local.account_id}:distribution/*"
    ]
  }
  statement {
    sid    = "ReadOnlyCloudwatchLogsPolicy"
    effect = "Allow"
    actions = [
      "logs:DescribeAccountPolicies",
      "logs:DescribeDeliveries",
      "logs:DescribeDeliveryDestinations",
      "logs:DescribeDeliverySources",
      "logs:DescribeDestinations",
      "logs:DescribeExportTasks",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:DescribeMetricFilters",
      "logs:DescribeQueries",
      "logs:DescribeQueryDefinitions",
      "logs:DescribeResourcePolicies",
      "logs:DescribeSubscriptionFilters",
      "logs:ListAnomalies",
      "logs:ListLogAnomalyDetectors",
      "logs:ListLogDeliveries",
      "logs:ListTagsForResource",
      "logs:ListTagsLogGroup",
      "logs:FilterLogEvents",
      "logs:GetDataProtectionPolicy",
      "logs:GetDelivery",
      "logs:GetDeliveryDestination",
      "logs:GetDeliveryDestinationPolicy",
      "logs:GetDeliverySource",
      "logs:GetLogAnomalyDetector",
      "logs:GetLogDelivery",
      "logs:GetLogEvents",
      "logs:GetLogGroupFields",
      "logs:GetLogRecord",
      "logs:GetQueryResults",
      "logs:StartLiveTail",
      "logs:StartQuery",
      "logs:StopLiveTail",
      "logs:StopQuery",
      "logs:TestMetricFilter",
    ]
    resources = [
      "arn:aws:logs:us-east-1:${local.account_id}:*",
      "arn:aws:logs:${var.region}:${local.account_id}:*"
    ]
  }
  statement {
    sid    = "ReadOnlyCloudTrailPolicy"
    effect = "Allow"
    actions = [
      "cloudtrail:ListChannels",
      "cloudtrail:ListEventDataStores",
      "cloudtrail:ListImports",
      "cloudtrail:ListQueries",
      "cloudtrail:ListServiceLinkedChannels",
      "cloudtrail:ListTrails",
      "cloudtrail:DescribeQuery",
      "cloudtrail:DescribeTrails",
      "cloudtrail:GetChannel",
      "cloudtrail:GetEventDataStore",
      "cloudtrail:GetEventDataStoreData",
      "cloudtrail:GetEventSelectors",
      "cloudtrail:GetImport",
      "cloudtrail:GetInsightSelectors",
      "cloudtrail:GetQueryResults",
      "cloudtrail:GetServiceLinkedChannel",
      "cloudtrail:GetTrail",
      "cloudtrail:GetTrailStatus",
      "cloudtrail:ListImportFailures",
      "cloudtrail:ListTags",
      "cloudtrail:LookupEvents"
    ]
    resources = [
      "arn:aws:cloudtrail:${var.region}:${local.account_id}:*"
    ]
  }
  statement {
    sid    = "SNSPolicy"
    effect = "Allow"
    actions = [
      "sns:ListTagsForResource",
      "sns:ListSubscriptionsByTopic",
      "sns:GetTopicAttributes",
      "sns:ListSMSSandboxPhoneNumbers",
      "sns:ListTopics",
      "sns:GetPlatformApplicationAttributes",
      "sns:GetSubscriptionAttributes",
      "sns:ListSubscriptions",
      "sns:CheckIfPhoneNumberIsOptedOut",
      "sns:GetDataProtectionPolicy",
      "sns:ListOriginationNumbers",
      "sns:ListPhoneNumbersOptedOut",
      "sns:ListEndpointsByPlatformApplication",
      "sns:GetEndpointAttributes",
      "sns:GetSMSSandboxAccountStatus",
      "sns:GetSMSAttributes",
      "sns:ListPlatformApplications"
    ]
    resources = [
      "arn:aws:sns:${var.region}:${local.account_id}:*",
      "arn:aws:sns:us-east-1:${local.account_id}:*"
    ]
  }
}

