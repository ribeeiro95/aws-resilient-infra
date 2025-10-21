######################
# Alarme CloudWatch
######################

resource "aws_cloudwatch_metric_alarm" "alb_unhealthy" {
  alarm_name          = "UnhealthyHosts-${var.alb_name}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Average"
  threshold           = 1

  dimensions = {
    LoadBalancer = var.alb_name
  }

  alarm_description = "Detecta hosts não saudáveis no ALB"
}
