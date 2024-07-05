resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type : "metric",
        height : 6,
        width : 6,
        x : 0,
        y : 0,
        properties : {
          metrics : [
            ["AWS/WAFV2", "AllowedRequests", "WebACL", "${var.web_acl_name}", "Rule", "ALL", { "id" : "m1" }],
            [".", "BlockedRequests", ".", ".", ".", ".", { "id" : "m2" }]
          ],
          view : "timeSeries",
          stacked : true,
          region : "us-east-1",
          stat : "Sum",
          title : "Allowed vs Blocked Requests",
          period : 300,
          yAxis : {
            left : {
              showUnits : false
            }
          }
        }
      },
      {
        type : "metric",
        height : 6,
        width : 6,
        x : 6,
        y : 0,
        properties : {
          metrics : [
            [{ "id" : "e1", "expression" : "SEARCH('{AWS/WAFV2,Rule,WebACL} MetricName=\"AllowedRequests\" WebACL=\"${var.web_acl_name}\" Rule=\"ALL\"', 'Sum', 300)", "stat" : "Sum", "period" : 300, "visible" : false }],
            [{ "id" : "e2", "expression" : "SEARCH('{AWS/WAFV2,Rule,WebACL} MetricName=\"BlockedRequests\" WebACL=\"${var.web_acl_name}\" Rule=\"ALL\"', 'Sum', 300)", "stat" : "Sum", "period" : 300, "visible" : false }],
            [{ "id" : "e3", "expression" : "SEARCH('{AWS/WAFV2,LabelName,LabelNamespace,WebACL} MetricName=\"AllowedRequests\" LabelNamespace=\"awswaf:managed:aws:bot-control:bot:category\" WebACL=\"${var.web_acl_name}\"', 'Sum', 300)", "period" : 300, "visible" : false }],
            [{ "id" : "e4", "expression" : "SEARCH('{AWS/WAFV2,LabelName,LabelNamespace,WebACL} MetricName=\"BlockedRequests\" LabelNamespace=\"awswaf:managed:aws:bot-control:bot:category\" WebACL=\"${var.web_acl_name}\"', 'Sum', 300)", "period" : 300, "visible" : false }],
            [{ "id" : "e5", "expression" : "SUM([e3,e4])", "label" : "Bot requests", "color" : "#FF7F0E" }],
            [{ "id" : "e6", "expression" : "SUM([e1,e2,-e3,-e4])", "label" : "Non-bot requests", "color" : "#1F77B4" }]
          ],
          view : "timeSeries",
          stacked : true,
          region : "us-east-1",
          stat : "Average",
          title : "Bot requests vs Non-bot requests",
          period : 300,
          liveData : false,
          yAxis : {
            left : {
              showUnits : false,
              min : 0
            }
          }
        }
      },
      {
        type : "metric",
        height : 6,
        width : 6,
        x : 12,
        y : 0,
        properties : {
          metrics : [
            [{ "id" : "e1", "expression" : "SEARCH('{AWS/WAFV2,Rule,WebACL} MetricName=\"AllowedRequests\" WebACL=\"${var.web_acl_name}\" Rule=\"ALL\"', 'Sum', 300)", "stat" : "Sum", "period" : 300, "visible" : false }],
            [{ "id" : "e2", "expression" : "SEARCH('{AWS/WAFV2,Rule,WebACL} MetricName=\"BlockedRequests\" WebACL=\"${var.web_acl_name}\" Rule=\"ALL\"', 'Sum', 300)", "stat" : "Sum", "period" : 300, "visible" : false }],
            [{ "id" : "e3", "expression" : "SEARCH('{AWS/WAFV2,LabelName,LabelNamespace,WebACL} MetricName=\"AllowedRequests\" LabelNamespace=\"awswaf:managed:aws:bot-control:bot:category\" WebACL=\"${var.web_acl_name}\"', 'Sum', 300)", "period" : 300, "visible" : false }],
            [{ "id" : "e4", "expression" : "SEARCH('{AWS/WAFV2,LabelName,LabelNamespace,WebACL} MetricName=\"BlockedRequests\" LabelNamespace=\"awswaf:managed:aws:bot-control:bot:category\" WebACL=\"${var.web_acl_name}\"', 'Sum', 300)", "period" : 300, "visible" : false }],
            [{ "id" : "e5", "expression" : "SUM([e1,e2,-e3,-e4])", "period" : 300, "visible" : false }],
            [{ "id" : "e6", "expression" : "(SUM([e3,e4]) / SUM([e1,e2])) * 100", "period" : 300, "label" : "Bot requests", "color" : "#FF7F0E" }],
            [{ "id" : "e7", "expression" : "(e5 / SUM([e1,e2])) * 100", "period" : 300, "label" : "Non-bot requests", "color" : "#1F77B4" }]
          ],
          view : "singleValue",
          region : "us-east-1",
          stat : "Average",
          title : "Percentage of Bot requests",
          period : 300,
          liveData : false,
          setPeriodToTimeRange : true
        }
      },

    ]
  })
}