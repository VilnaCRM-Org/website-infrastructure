locals {
  ci_cd_website_single_value_metrics = [
    for stage_name in var.ci_cd_website_stage_names :
    ["AWS/CodeBuild", "Duration", "ProjectName", "${var.ci_cd_website_project_name}-${stage_name}"]
  ]
  ci_cd_website_duration_metrics = [
    for idx, stage_name in var.ci_cd_website_stage_names :
    ["AWS/CodeBuild", "Duration", "ProjectName", "${var.ci_cd_website_project_name}-${stage_name}", {
      region  = var.region
      id      = "m${idx + 1}"
      visible = false
    }]
  ]
  ci_cd_website_duration_metric_ids = [
    for idx, _ in var.ci_cd_website_stage_names : "m${idx + 1}"
  ]
  ci_cd_website_duration_expression = length(var.ci_cd_website_stage_names) > 0 ? "SUM([${join(",", local.ci_cd_website_duration_metric_ids)}])/60" : "0"
  ci_cd_website_duration_widget_metrics = concat(
    [[{
      expression = local.ci_cd_website_duration_expression
      label      = "CI/CD Pipeline Length (min)"
      id         = "e1"
      region     = var.region
    }]],
    local.ci_cd_website_duration_metrics
  )
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "codebuild-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type : "metric"

        x : 0,
        y : 0,
        width : 24,
        height : 3,

        properties : {
          metrics : local.ci_cd_website_single_value_metrics,
          sparkline : true,
          view : "singleValue",
          region : "${var.region}",
          liveData : false,
          title : "CI/CD Website Builds Duration"
      } },
      {
        x : 0,
        y : 3,
        width : 24,
        height : 3,
        type : "metric"
        properties : {
          metrics : [
            ["AWS/CodeBuild", "Duration", "ProjectName", "${var.ci_cd_project_name}-validate"],
            ["AWS/CodeBuild", "Duration", "ProjectName", "${var.ci_cd_project_name}-plan"],
            ["AWS/CodeBuild", "Duration", "ProjectName", "${var.ci_cd_project_name}-up"],
          ],
          sparkline : true,
          view : "singleValue",
          region : "${var.region}",
          liveData : false,
          title : "CI/CD Infrastructure Builds Duration"
      } },
      {
        type : "metric"
        x : 0,
        y : 6,
        width : 24,
        height : 3,
        properties : {
          metrics : [
            ["AWS/CodeBuild", "Duration", "ProjectName", "${var.website_project_name}-validate"],
            ["AWS/CodeBuild", "Duration", "ProjectName", "${var.website_project_name}-plan"],
            ["AWS/CodeBuild", "Duration", "ProjectName", "${var.website_project_name}-up"],
            ["AWS/CodeBuild", "Duration", "ProjectName", "${var.website_project_name}-deploy"],
            ["AWS/CodeBuild", "Duration", "ProjectName", "${var.website_project_name}-healthcheck"],
            ["AWS/CodeBuild", "Duration", "ProjectName", "${var.website_project_name}-destroy"],
          ],
          sparkline : true,
          view : "singleValue",
          region : "${var.region}",
          liveData : false,
          title : "Website Infrastructure Builds Duration"
        }
      },
      {
        type : "metric"
        x : 0,
        y : 9,
        width : 8,
        height : 4,
        properties : {
          metrics : local.ci_cd_website_duration_widget_metrics,
          liveData : false,
          region : "${var.region}",
          sparkline : true,
          title : "CI/CD Website Pipeline Duration",
          view : "singleValue",
          period : 300,
          stat : "Average"
        }
      },
      {
        type : "metric"
        x : 8,
        y : 9,
        width : 8,
        height : 4,
        properties : {
          metrics : [
            [{ "expression" : "SUM([m1,m2,m3])/60", "label" : "CI/CD Pipeline Length (min)", "id" : "e1", "region" : "${var.region}" }],
            ["AWS/CodeBuild", "Duration", "ProjectName", "${var.ci_cd_project_name}-validate",
              {
                "region" : "${var.region}", "id" : "m1", "visible" : false
            }],
            ["AWS/CodeBuild", "Duration", "ProjectName", "${var.ci_cd_project_name}-plan",
              {
                "region" : "${var.region}", "id" : "m2", "visible" : false
            }],
            ["AWS/CodeBuild", "Duration", "ProjectName", "${var.ci_cd_project_name}-up",
              {
                "region" : "${var.region}", "id" : "m3", "visible" : false
            }],
          ],
          liveData : false,
          region : "${var.region}",
          sparkline : true,
          title : "CI/CD Infrastructure Pipeline Duration",
          view : "singleValue",
          period : 300,
          stat : "Average"
        }
      },
      {
        type : "metric"
        x : 16,
        y : 9,
        width : 8,
        height : 4,
        properties : {
          metrics : [
            [{ "expression" : "SUM([m1,m2,m3,m4,m5,m6])/60", "label" : "CI/CD Pipeline Length (min)", "id" : "e1", "region" : "${var.region}" }],
            ["AWS/CodeBuild", "Duration", "ProjectName", "${var.website_project_name}-validate",
              {
                "region" : "${var.region}", "id" : "m1", "visible" : false
            }],
            ["AWS/CodeBuild", "Duration", "ProjectName", "${var.website_project_name}-plan",
              {
                "region" : "${var.region}", "id" : "m2", "visible" : false
            }],
            ["AWS/CodeBuild", "Duration", "ProjectName", "${var.website_project_name}-up",
              {
                "region" : "${var.region}", "id" : "m3", "visible" : false
            }],
            ["AWS/CodeBuild", "Duration", "ProjectName", "${var.website_project_name}-deploy",
              {
                "region" : "${var.region}", "id" : "m4", "visible" : false
            }],
            ["AWS/CodeBuild", "Duration", "ProjectName", "${var.website_project_name}-healthcheck",
              {
                "region" : "${var.region}", "id" : "m5", "visible" : false
            }],
            ["AWS/CodeBuild", "Duration", "ProjectName", "${var.website_project_name}-destroy",
              {
                "region" : "${var.region}", "id" : "m6", "visible" : false
            }]
          ],
          liveData : false,
          region : "${var.region}",
          sparkline : true,
          title : "Website Infrastructure Pipeline Duration",
          view : "singleValue",
          period : 300,
          stat : "Average"
        }
      },
    ]
  })
}
