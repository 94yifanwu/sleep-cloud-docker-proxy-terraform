

locals {
  pipeline_source = {
    S3Bucket    = aws_s3_bucket_object.source_object.bucket
    S3ObjectKey = aws_s3_bucket_object.source_object.key
  }
}

# this code pipeline is triggered by Terraform Apply
# (After Terraform Apply, the pipeline will start to work)
resource aws_codepipeline pipeline {
  name     = "${local.prefix}mcs-docker-proxy-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn
  depends_on = [
    aws_codebuild_project.mcs_docker_proxy_codebuild
  ]

  artifact_store {
    location = aws_s3_bucket.ci_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "S3"
      output_artifacts = ["bitbucket_hash"]
      version          = "1"
      configuration = {
        S3Bucket    = local.pipeline_source.S3Bucket
        S3ObjectKey = local.pipeline_source.S3ObjectKey
      }
    }
  }

  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["bitbucket_hash"]
      output_artifacts = ["build_output"]
      version          = "1"
      configuration = {
        ProjectName = aws_codebuild_project.mcs_docker_proxy_codebuild.name
      }
    }
  }
  
  # (optional) The Deploy stage is for ecs-deploy testing purpose
  stage {
    name = "Deploy"
    action {
      name            = "Deploy-dps"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["build_output"]
      version         = "1"
      configuration   = {
        ClusterName   = "${local.prefix}mcs-docker-proxy-cluster"
        ServiceName   = "${local.prefix}mcs-docker-proxy-cluster-service-dps"
        FileName      = "imagedefinitions-dps.json"
        DeploymentTimeout = var.build_timeout
      }
    }
    action {
      name            = "Deploy-fus"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["build_output"]
      version         = "1"
      configuration   = {
        ClusterName   = "${local.prefix}mcs-docker-proxy-cluster"
        ServiceName   = "${local.prefix}mcs-docker-proxy-cluster-service-fus"
        FileName      = "imagedefinitions-fus.json"
        DeploymentTimeout = var.build_timeout
      }
    }
    action {
      name            = "Deploy-rhs"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["build_output"]
      version         = "1"
      configuration   = {
        ClusterName   = "${local.prefix}mcs-docker-proxy-cluster"
        ServiceName   = "${local.prefix}mcs-docker-proxy-cluster-service-rhs"
        FileName      = "imagedefinitions-rhs.json"
        DeploymentTimeout = var.build_timeout
      }
    }
  }
}