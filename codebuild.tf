resource aws_codebuild_project mcs_docker_proxy_codebuild {
  name          = "${local.prefix}mcs-docker-proxy-build"
  description   = "A CodeBuild project that builds the docker image proxy service and publish an image to ECR"
  build_timeout = var.build_timeout
  service_role  = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type     = "S3"
    location = aws_s3_bucket.ci_bucket.bucket
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = "true" # Allows running the Docker daemon inside a Docker container
  }

  source {
    type = "CODEPIPELINE"
    buildspec = templatefile("${path.module}/buildspec.yml.tpl", {
      project                    = "mcs"
      dockerfile_repo            = var.dockerfile_repo
      dockerfile_repo_path       = var.dockerfile_repo_path
      git_checkout_branch        = var.git_checkout_branch
      aws_account_id             = var.aws_account_id
      aws_region                 = var.aws_region
      bitbucket_secret_name      = data.aws_secretsmanager_secret.bitbucket_private_key.name
      bitbucket_public_key       = local.bitbucket_public_key
      docker_image_ecr           = local.docker_image_repository_name
      container_name_dps         = local.container_name_dps
      container_name_fus         = local.container_name_fus
      container_name_rhs         = local.container_name_rhs
    })
  }

  vpc_config {
    vpc_id             = var.vpc_id
    subnets            = [local.private_subnet]
    security_group_ids = [aws_security_group.codebuild_sg.id]
  }
}
