terraform {
  required_version = "~> 1.1.2"

  required_providers {
    aws = {
      version = "~> 4.4.0"
      source  = "hashicorp/aws"
    }
  }
}

# Download AWS provider
provider "aws" {
  region = "us-east-2"
  default_tags {
    tags = {
      Owner = "IAM Pulse"
      Admin = "Kyler"
    }
  }
}

# Grab current AWS info and region
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Output region for docker bash scripting
output "region_name" {
  value = data.aws_region.current.name
}

# Create KMS key for ECR encryption
resource "aws_kms_key" "ecr_cmk" {
  description = "IAM Pulse ECR KMS Key"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Id" : "default-kms-policy",
      "Statement" : [
        {
          "Sid" : "Default IAM User Permissions",
          "Effect" : "Allow",
          "Principal" : {
            "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
          },
          "Action" : "kms:*",
          "Resource" : "*"
        }
      ]
    }
  )
}

# Create alias for easy KMS key finding
resource "aws_kms_alias" "ecr_key_alias" {
  name          = "alias/iam-pulse-ecr-key"
  target_key_id = aws_kms_key.ecr_cmk.key_id
}

# Create ECR with custom KMS key
resource "aws_ecr_repository" "our-new-ecr" {
  name                 = "our-new-ecr"
  image_tag_mutability = "MUTABLE"

  # Encrypt our ECR with custom KMS key, CMK we created above
  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_key.ecr_cmk.arn
  }

  image_scanning_configuration {
    scan_on_push = true
  }
}

output "ecr_repo_url" {
  value = aws_ecr_repository.our-new-ecr.repository_url
}

resource "aws_ecr_repository_policy" "our-new-ecr-policy" {
  repository = aws_ecr_repository.our-new-ecr.name

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "ECR Repository Policy",
          "Effect" : "Allow",
          "Principal" : "*",
          "Action" : [
            "ecr:*"
          ]
        },
        {
          "Sid" : "Deny upload",
          "Effect" : "Deny",
          "Principal" : {
            "AWS" : "${data.aws_caller_identity.current.arn}"
          },
          "Action" : [
            "ecr:PutImage",
            "ecr:InitiateLayerUpload"
          ]
        }
      ]
    }
  )
}