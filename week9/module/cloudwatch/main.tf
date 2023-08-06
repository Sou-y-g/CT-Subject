#################################################
# CloudWatch Logs
#################################################
resource "aws_cloudwatch_log_group" "cwlog" {
  name = "/ecs/app"
  retention_in_days = 30
}