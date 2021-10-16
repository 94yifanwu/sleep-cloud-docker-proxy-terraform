# ecs cluster
resource "aws_ecs_cluster" "docker-proxy-ecs-cluster" {
  name = "${local.prefix}mcs-docker-proxy-cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# ecs cloudwatch log group
resource "aws_cloudwatch_log_group" "ecs_task_log_group" {
  name = "${local.prefix}mcs-docker-proxy-ecs-cloud-log-group"
}