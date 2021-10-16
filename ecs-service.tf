# ecs service - dps
resource "aws_ecs_service" "docker-proxy-ecs-cluster-service-dps" {
  name                = "${local.prefix}mcs-docker-proxy-cluster-service-dps"
  cluster             = aws_ecs_cluster.docker-proxy-ecs-cluster.arn
  task_definition     = aws_ecs_task_definition.docker-proxy-ecs-task-definition-dps.arn
  desired_count       = var.ecs_service_desired_count # default is 1
  launch_type         = "FARGATE"
  scheduling_strategy = "REPLICA"

  network_configuration{
      subnets         = ["${local.private_subnet}"]
      security_groups = ["${aws_security_group.ecs_service_sg.id}"]
  }
}

# ecs service - fus
resource "aws_ecs_service" "docker-proxy-ecs-cluster-service-fus" {
  name                = "${local.prefix}mcs-docker-proxy-cluster-service-fus"
  cluster             = aws_ecs_cluster.docker-proxy-ecs-cluster.arn
  task_definition     = aws_ecs_task_definition.docker-proxy-ecs-task-definition-fus.arn
  desired_count       = var.ecs_service_desired_count # default is 1
  launch_type         = "FARGATE"
  scheduling_strategy = "REPLICA"

  network_configuration{
      subnets         = ["${local.private_subnet}"]
      security_groups = ["${aws_security_group.ecs_service_sg.id}"]
  }
}

# ecs service - rhs
resource "aws_ecs_service" "docker-proxy-ecs-cluster-service-rhs" {
  name                = "${local.prefix}mcs-docker-proxy-cluster-service-rhs"
  cluster             = aws_ecs_cluster.docker-proxy-ecs-cluster.arn
  task_definition     = aws_ecs_task_definition.docker-proxy-ecs-task-definition-rhs.arn
  desired_count       = var.ecs_service_desired_count # default is 1
  launch_type         = "FARGATE"
  scheduling_strategy = "REPLICA"

  network_configuration{
      subnets         = ["${local.private_subnet}"]
      security_groups = ["${aws_security_group.ecs_service_sg.id}"]
  }
}