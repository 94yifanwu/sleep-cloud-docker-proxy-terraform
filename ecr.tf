
resource "aws_ecr_repository" "ecr_repository" {
  name                 = local.docker_image_repository_name
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository_policy" "ecr_repo_policy" {
  repository = aws_ecr_repository.ecr_repository.name
  policy     = data.aws_iam_policy_document.ecr_policy_document.json
}

data "aws_iam_policy_document" "ecr_policy_document" {
  statement {
    sid    = "ECR Image crud operations"
    effect = "Allow"
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeRepositories",
      "ecr:GetRepositoryPolicy",
      "ecr:ListImages",
      "ecr:DeleteRepository",
      "ecr:BatchDeleteImage",
      "ecr:SetRepositoryPolicy",
      "ecr:DeleteRepositoryPolicy"
    ]
    principals {
      identifiers = [aws_iam_role.codebuild_role.arn]
      type        = "AWS"
    }
  }
  statement {
    sid    = "ECR Image read operations"
    effect = "Allow"
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:DescribeRepositories",
      "ecr:GetRepositoryPolicy",
      "ecr:ListImages"
    ]
    principals {
      identifiers = local.read_account_arn_list
      type        = "AWS"
    }
  }
}
