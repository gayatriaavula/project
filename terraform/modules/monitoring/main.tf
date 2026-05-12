# ── SNS Topic for alarm notifications ─────────────────────────────────────────
resource "aws_sns_topic" "alarms" {
  name = "${var.app_name}-${var.environment}-alarms"
  tags = {
    Name        = "${var.app_name}-${var.environment}-alarms"
    Environment = var.environment
  }
}

resource "aws_sns_topic_subscription" "email" {
  count     = var.alarm_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.alarms.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

# ── ECS Alarms ─────────────────────────────────────────────────────────────────
resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
  alarm_name          = "${var.app_name}-${var.environment}-ecs-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "ECS CPU utilization above 80% for 10 minutes"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }
  tags = { Environment = var.environment }
}

resource "aws_cloudwatch_metric_alarm" "ecs_memory_high" {
  alarm_name          = "${var.app_name}-${var.environment}-ecs-memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "ECS memory utilization above 80% for 10 minutes"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }
  tags = { Environment = var.environment }
}

resource "aws_cloudwatch_metric_alarm" "ecs_tasks_low" {
  alarm_name          = "${var.app_name}-${var.environment}-ecs-tasks-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "RunningTaskCount"
  namespace           = "ECS/ContainerInsights"
  period              = 60
  statistic           = "Average"
  threshold           = var.desired_task_count
  alarm_description   = "Running ECS tasks below desired count — service may be down"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }
  tags = { Environment = var.environment }
}

# ── ALB Alarms ─────────────────────────────────────────────────────────────────
resource "aws_cloudwatch_metric_alarm" "alb_5xx_errors" {
  alarm_name          = "${var.app_name}-${var.environment}-alb-5xx-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "More than 10 ALB 5xx errors in 5 minutes"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  treat_missing_data  = "notBreaching"
  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }
  tags = { Environment = var.environment }
}

resource "aws_cloudwatch_metric_alarm" "alb_response_time" {
  alarm_name          = "${var.app_name}-${var.environment}-alb-slow-response"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Average"
  threshold           = 2
  alarm_description   = "ALB average target response time above 2 seconds"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  treat_missing_data  = "notBreaching"
  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }
  tags = { Environment = var.environment }
}

resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_hosts" {
  alarm_name          = "${var.app_name}-${var.environment}-alb-unhealthy-hosts"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Average"
  threshold           = 0
  alarm_description   = "ALB has unhealthy backend targets"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  treat_missing_data  = "notBreaching"
  dimensions = {
    LoadBalancer = var.alb_arn_suffix
    TargetGroup  = var.target_group_arn_suffix
  }
  tags = { Environment = var.environment }
}

# ── RDS Alarms ─────────────────────────────────────────────────────────────────
resource "aws_cloudwatch_metric_alarm" "rds_cpu_high" {
  alarm_name          = "${var.app_name}-${var.environment}-rds-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "RDS CPU utilization above 80% for 10 minutes"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  dimensions = {
    DBInstanceIdentifier = var.rds_identifier
  }
  tags = { Environment = var.environment }
}

resource "aws_cloudwatch_metric_alarm" "rds_storage_low" {
  alarm_name          = "${var.app_name}-${var.environment}-rds-storage-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 2147483648 # 2 GB in bytes
  alarm_description   = "RDS free storage below 2 GB"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  dimensions = {
    DBInstanceIdentifier = var.rds_identifier
  }
  tags = { Environment = var.environment }
}

resource "aws_cloudwatch_metric_alarm" "rds_connections_high" {
  alarm_name          = "${var.app_name}-${var.environment}-rds-connections-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "RDS connection count above 80 for 10 minutes"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  dimensions = {
    DBInstanceIdentifier = var.rds_identifier
  }
  tags = { Environment = var.environment }
}

# ── CloudWatch Dashboard ───────────────────────────────────────────────────────
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.app_name}-${var.environment}"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "text"
        x      = 0, y = 0, width = 24, height = 1
        properties = { markdown = "# ${upper(var.environment)} — ${var.app_name}" }
      },
      {
        type = "metric", x = 0, y = 1, width = 8, height = 6
        properties = {
          title   = "ECS — CPU Utilization (%)"
          region  = var.aws_region
          view    = "timeSeries"
          stat    = "Average"
          period  = 300
          yAxis   = { left = { min = 0, max = 100 } }
          metrics = [["AWS/ECS", "CPUUtilization", "ServiceName", var.ecs_service_name, "ClusterName", var.ecs_cluster_name]]
          annotations = { horizontal = [{ value = 80, label = "Alarm", color = "#ff6961" }] }
        }
      },
      {
        type = "metric", x = 8, y = 1, width = 8, height = 6
        properties = {
          title   = "ECS — Memory Utilization (%)"
          region  = var.aws_region
          view    = "timeSeries"
          stat    = "Average"
          period  = 300
          yAxis   = { left = { min = 0, max = 100 } }
          metrics = [["AWS/ECS", "MemoryUtilization", "ServiceName", var.ecs_service_name, "ClusterName", var.ecs_cluster_name]]
          annotations = { horizontal = [{ value = 80, label = "Alarm", color = "#ff6961" }] }
        }
      },
      {
        type = "metric", x = 16, y = 1, width = 8, height = 6
        properties = {
          title   = "ECS — Running Tasks"
          region  = var.aws_region
          view    = "timeSeries"
          stat    = "Average"
          period  = 60
          metrics = [["ECS/ContainerInsights", "RunningTaskCount", "ServiceName", var.ecs_service_name, "ClusterName", var.ecs_cluster_name]]
          annotations = { horizontal = [{ value = var.desired_task_count, label = "Desired", color = "#2ca02c" }] }
        }
      },
      {
        type = "metric", x = 0, y = 7, width = 8, height = 6
        properties = {
          title   = "ALB — Request Count"
          region  = var.aws_region
          view    = "timeSeries"
          stat    = "Sum"
          period  = 300
          metrics = [["AWS/ApplicationELB", "RequestCount", "LoadBalancer", var.alb_arn_suffix]]
        }
      },
      {
        type = "metric", x = 8, y = 7, width = 8, height = 6
        properties = {
          title   = "ALB — HTTP 5xx Errors"
          region  = var.aws_region
          view    = "timeSeries"
          stat    = "Sum"
          period  = 300
          metrics = [
            ["AWS/ApplicationELB", "HTTPCode_ELB_5XX_Count", "LoadBalancer", var.alb_arn_suffix],
            ["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer", var.alb_arn_suffix]
          ]
          annotations = { horizontal = [{ value = 10, label = "Alarm", color = "#ff6961" }] }
        }
      },
      {
        type = "metric", x = 16, y = 7, width = 8, height = 6
        properties = {
          title   = "ALB — Target Response Time (s)"
          region  = var.aws_region
          view    = "timeSeries"
          stat    = "Average"
          period  = 300
          metrics = [["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", var.alb_arn_suffix]]
          annotations = { horizontal = [{ value = 2, label = "Alarm", color = "#ff6961" }] }
        }
      },
      {
        type = "metric", x = 0, y = 13, width = 8, height = 6
        properties = {
          title   = "RDS — CPU Utilization (%)"
          region  = var.aws_region
          view    = "timeSeries"
          stat    = "Average"
          period  = 300
          yAxis   = { left = { min = 0, max = 100 } }
          metrics = [["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", var.rds_identifier]]
          annotations = { horizontal = [{ value = 80, label = "Alarm", color = "#ff6961" }] }
        }
      },
      {
        type = "metric", x = 8, y = 13, width = 8, height = 6
        properties = {
          title   = "RDS — Database Connections"
          region  = var.aws_region
          view    = "timeSeries"
          stat    = "Average"
          period  = 300
          metrics = [["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", var.rds_identifier]]
          annotations = { horizontal = [{ value = 80, label = "Alarm", color = "#ff6961" }] }
        }
      },
      {
        type = "metric", x = 16, y = 13, width = 8, height = 6
        properties = {
          title   = "RDS — Free Storage Space (GB)"
          region  = var.aws_region
          view    = "timeSeries"
          stat    = "Average"
          period  = 300
          metrics = [["AWS/RDS", "FreeStorageSpace", "DBInstanceIdentifier", var.rds_identifier, { id = "m1" }]]
          annotations = { horizontal = [{ value = 2147483648, label = "2 GB alarm", color = "#ff6961" }] }
        }
      }
    ]
  })
}
