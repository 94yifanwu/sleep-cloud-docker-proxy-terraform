# s3 ci_bucket
resource aws_s3_bucket ci_bucket {
  bucket        = "${local.prefix}mcs-docker-proxy-ci-bucket"
  force_destroy = true
  acl           = "private"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource aws_s3_bucket_public_access_block ci_bucket_block_public_access {
  bucket = aws_s3_bucket.ci_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  depends_on = [
    aws_s3_bucket_policy.ci_bucket_policy
  ]
}

resource aws_s3_bucket_policy ci_bucket_policy {
  bucket = aws_s3_bucket.ci_bucket.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${var.aws_account_id}"
      },
      "Action": "*",
      "Resource": [
        "${aws_s3_bucket.ci_bucket.arn}",
        "${aws_s3_bucket.ci_bucket.arn}/*"
      ]
    }
  ]
}
POLICY
}

# s3 code pipeline source bucket
resource aws_s3_bucket pipeline_source_bucket {
  bucket        = "${local.prefix}mcs-docker-proxy-pipeline-source-bucket"
  force_destroy = true
  acl           = "private"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  versioning {
    enabled = true
  }
}

resource aws_s3_bucket_public_access_block pipeline_source_bucket_block_public_access {
  bucket = aws_s3_bucket.pipeline_source_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  depends_on = [
    aws_s3_bucket_policy.pipeline_source_bucket_policy
  ]
}

resource aws_s3_bucket_policy pipeline_source_bucket_policy {
  bucket = aws_s3_bucket.pipeline_source_bucket.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${var.aws_account_id}"
      },
      "Action": "*",
      "Resource": [
        "${aws_s3_bucket.pipeline_source_bucket.arn}",
        "${aws_s3_bucket.pipeline_source_bucket.arn}/*"
      ]
    }
  ]
}
POLICY
}

# these env files are similar to `docker run --env-file` command
resource "aws_s3_bucket_object" "ecs_env_file_objects" {
  for_each               = fileset("${path.module}/ecs-container-env-file/", "*")
  bucket                 = aws_s3_bucket.ci_bucket.id
  acl                    = "private"
  key                    = "ecs-container-env-file/${each.value}"
  server_side_encryption = "AES256"
  source                 = "${path.module}/ecs-container-env-file/${each.value}"
  etag                   = filemd5("${path.module}/ecs-container-env-file/${each.value}")
}

# this file can start code pipeline
resource "aws_s3_bucket_object" "source_object" {
  bucket                 = aws_s3_bucket.pipeline_source_bucket.id
  acl                    = "private"
  server_side_encryption = "AES256"
  key                    = "source.zip"
  source                 = "${path.module}/empty_hash_file.zip"
}


