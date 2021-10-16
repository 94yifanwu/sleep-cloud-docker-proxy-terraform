# ecs task definition container name
locals{
  container_name_dps     = "${local.prefix}mcs-docker-proxy-ecs-container-dps"
  container_name_fus     = "${local.prefix}mcs-docker-proxy-ecs-container-fus"
  container_name_rhs     = "${local.prefix}mcs-docker-proxy-ecs-container-rhs"
  container_env_file_dps = "ecs-container-env-file-dps.env"
  container_env_file_fus = "ecs-container-env-file-fus.env"
  container_env_file_rhs = "ecs-container-env-file-rhs.env"
}

# ecs task definition - dps
resource "aws_ecs_task_definition" "docker-proxy-ecs-task-definition-dps" {
  family                   = "${local.prefix}mcs-docker-proxy-ecs-task-definition-dps"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  cpu                      = 256
  memory                   = 512
  container_definitions    = jsonencode([
    {
      name             = local.container_name_dps
      image            = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${local.docker_image_repository_name}"
      environmentFiles = [{
          value        = "${aws_s3_bucket.ci_bucket.arn}/${local.container_env_file_dps}",
          type         = "s3"
      }]
      essential        = true
      logConfiguration = {
        logDriver      = "awslogs",
        secretOptions  = null,
        options        = {
          awslogs-group         = "${aws_cloudwatch_log_group.ecs_task_log_group.name}",
          awslogs-region        = "${var.aws_region}",
          awslogs-stream-prefix = "ecs"
        }
      },
    }
  ])
}

# ecs task definition - fus
resource "aws_ecs_task_definition" "docker-proxy-ecs-task-definition-fus" {
  family                   = "${local.prefix}mcs-docker-proxy-ecs-task-definition-fus"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  cpu                      = 256
  memory                   = 512
  container_definitions    = jsonencode([
    {
      name             = local.container_name_fus
      image            = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${local.docker_image_repository_name}"
      environmentFiles = [{
          value        = "${aws_s3_bucket.ci_bucket.arn}/${local.container_env_file_fus}",
          type         = "s3"
      }]
      essential        = true
      logConfiguration = {
        logDriver      = "awslogs",
        secretOptions  = null,
        options        = {
          awslogs-group         = "${aws_cloudwatch_log_group.ecs_task_log_group.name}",
          awslogs-region        = "${var.aws_region}",
          awslogs-stream-prefix = "ecs"
        }
      },
    }
  ])
}

# ecs task definition - rhs
resource "aws_ecs_task_definition" "docker-proxy-ecs-task-definition-rhs" {
  family                   = "${local.prefix}mcs-docker-proxy-ecs-task-definition-rhs"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  cpu                      = 256
  memory                   = 512
  container_definitions    = jsonencode([
    {
      name             = local.container_name_rhs
      image            = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${local.docker_image_repository_name}"
      environmentFiles = [{
          value        = "${aws_s3_bucket.ci_bucket.arn}/${local.container_env_file_rhs}",
          type         = "s3"
      }]
      essential        = true
      logConfiguration = {
        logDriver      = "awslogs",
        secretOptions  = null,
        options        = {
          awslogs-group         = "${aws_cloudwatch_log_group.ecs_task_log_group.name}",
          awslogs-region        = "${var.aws_region}",
          awslogs-stream-prefix = "ecs"
        }
      },
    }
  ])
}