# AWS cost controls

Read-only account audit on 2026-09-19: August unblended totals including tax
were $32.03 for test and $89.35 for prod. No AWS configuration was applied.

## Default savings

- Stop artifact access-log recursion by directing four artifact buckets to the
  existing infrastructure logging bucket. Preserve access logs, unique source
  prefixes, scoped delivery permissions and existing objects.
- Make seven S3/notification-Lambda anomaly alarms opt-in through
  enable_storage_anomaly_alarms (default false). All reported INSUFFICIENT_DATA.
  Verify dimensions, request-metric configuration and a useful baseline before
  re-enabling. Keep the Lambda error alarm.
- Make two origin-latency alarms opt-in through enable_origin_latency_alarms
  (default false). Both distributions returned NoSuchMonitoringSubscription;
  OriginLatency requires additional metrics. Keep CloudFront 5xx, WAF and
  availability-canary alarms.
- Exclude changes confined to root README.md and diagrams/** from automatic
  main-branch infrastructure runs. Mixed code/docs commits and manual executions
  still run. This also avoids unnecessary downstream application deployments.

Together with CRM: fourteen fewer anomaly alarms and four fewer latency alarms,
approximately $4.60/month before free-tier and partial-month effects. Actual
August alarm charges were $7.10. Build and S3 savings are activity-dependent;
do not attribute their entire service bills to these changes. Test application
alarms and WAF were already disabled.

## Shared WAF ownership

This repo remains the sole owner of wafv2-web-acl and its log destination
aws-waf-logs-wafv2-web-acl, in the same account and us-east-1.
WAF_WEB_ACL_ARN exposes that contract. CRM discovers the ACL by name.
prevent_destroy guards the owner because separate states cannot detect consumers.
Do not rename, disable or remove the owner while CRM depends on it.

CRM's opt-in staged migration can retire its identical ACL, saving approximately
$9/month (one ACL and four rule entries), excluding tax and request charges.
Default CRM configuration retains its ACL until migration review. Sharing combines
website and CRM per-IP rate counters. Review that behavior and follow CRM's
docs/cost-optimization.md stages. Apply this owner change first. Existing WAF
rule groups, overrides and logging remain.

## Remaining bill and rollout

August prod: Security Hub $22.45, WAF $18.05, CodeBuild $7.40, CloudWatch $7.24,
WorkMail $4.00, KMS $3.97, Config $3.89, CodePipeline $3.67.
August test: Security Hub $11.92, KMS $4.97, Config $4.70,
Secrets Manager $2.00, GuardDuty $1.23.
Account security/bootstrap encryption belongs to separate bootstrap/Pulumi IaC.
Review recording scope, enabled regions and retained-key dependencies there.
Never delete encryption keys solely because they have a monthly fee.
CodeBuild already uses small compute; V2 pipeline fees are execution minutes.

Review state-backed plans for website and ci-cd-infrastructure in both environments.
Expected changes: diagnostic-alarm removals, in-place logging destination/policy
updates, trigger filters and an output. No application bucket, distribution or
WAF replacement is expected. Verify access-log delivery at the new prefix.
Existing logs expire under existing lifecycle rules; no bulk deletion is needed.

Backend-disabled validation checks configuration and provider schemas.
Authenticated plans and post-apply billing verification are still required.
Savings are prospective until applied.

Sources: [S3 recursion](https://docs.aws.amazon.com/AmazonS3/latest/userguide/enable-server-access-logging.html),
[CloudFront metrics](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/viewing-cloudfront-metrics.html),
[WAF pricing](https://aws.amazon.com/waf/pricing/),
[CodePipeline filters](https://docs.aws.amazon.com/codepipeline/latest/userguide/pipelines-triggers.html).
