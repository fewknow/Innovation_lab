provider "aws" {
  region = var.region
}

# VPC and Subnet Creation for each Team
resource "aws_vpc" "team_vpc" {
  for_each             = var.teams
  cidr_block           = cidrsubnet(var.vpc_cidr, 8, each.key)
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${each.key}-vpc"
    Team        = each.key
    Environment = var.environment
  }
}

resource "aws_subnet" "team_subnet" {
  for_each              = var.teams
  vpc_id                = aws_vpc.team_vpc[each.key].id
  cidr_block            = cidrsubnet(aws_vpc.team_vpc[each.key].cidr_block, 4, each.value.subnet_index)
  availability_zone     = element(var.availability_zones, each.value.subnet_index % length(var.availability_zones))
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = {
    Name        = "${each.key}-subnet"
    Team        = each.key
    Environment = var.environment
  }
}

# IAM Role and Group Creation for each Team
resource "aws_iam_role" "app_team_role" {
  for_each = var.teams

  name = "${each.key}-app-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = { Service = "ec2.amazonaws.com" }
      }
    ]
  })
}

# IAM Policy Creation with Broad Access Based on Team Tags
resource "aws_iam_policy" "app_team_policy" {
  for_each = var.teams

  name        = "${each.key}-app-policy"
  description = "Policy to restrict ${each.key} to their resources only"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # Allow EC2 actions, restricted to team-tagged resources
      {
        Effect    = "Allow",
        Action    = "ec2:*",
        Resource  = "*",
        Condition = {
          StringEquals = {
            "aws:ResourceTag/Team"       = each.key,
            "aws:ResourceTag/Environment" = var.environment
          }
        }
      },
      # Allow S3 actions, restricted to team-tagged resources
      {
        Effect    = "Allow",
        Action    = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject"
        ],
        Resource  = [
          "arn:aws:s3:::${each.key}-bucket",
          "arn:aws:s3:::${each.key}-bucket/*"
        ]
      },
      # Allow Lambda actions, restricted to team-tagged functions
      {
        Effect    = "Allow",
        Action    = "lambda:*",
        Resource  = "arn:aws:lambda:*:*:function:*",
        Condition = {
          StringEquals = {
            "lambda:FunctionTag/Team"       = each.key,
            "lambda:FunctionTag/Environment" = var.environment
          }
        }
      },
      # Allow DynamoDB actions, restricted to team-tagged tables
      {
        Effect    = "Allow",
        Action    = "dynamodb:*",
        Resource  = "arn:aws:dynamodb:*:*:table/${each.key}-*",
        Condition = {
          StringEquals = {
            "dynamodb:TableTag/Team"       = each.key,
            "dynamodb:TableTag/Environment" = var.environment
          }
        }
      },
      # Allow RDS actions, restricted to team-tagged instances
      {
        Effect    = "Allow",
        Action    = "rds:*",
        Resource  = "arn:aws:rds:*:*:db:${each.key}-*",
        Condition = {
          StringEquals = {
            "rds:DatabaseTag/Team"       = each.key,
            "rds:DatabaseTag/Environment" = var.environment
          }
        }
      },
      # Deny all actions on resources that do not have the correct tags
      {
        Effect    = "Deny",
        Action    = "*",
        Resource  = "*",
        Condition = {
          StringNotEqualsIfExists = {
            "aws:ResourceTag/Team"       = each.key,
            "aws:ResourceTag/Environment" = var.environment
          }
        }
      }
    ]
  })
}

# Attach IAM Policy to Role for each Team
resource "aws_iam_role_policy_attachment" "app_team_policy_attachment" {
  for_each = var.teams

  role       = aws_iam_role.app_team_role[each.key].name
  policy_arn = aws_iam_policy.app_team_policy[each.key].arn
}

# IAM Group and Memberships
resource "aws_iam_group" "app_team_group" {
  for_each = var.teams
  name     = "${each.key}-group"
}

resource "aws_iam_group_policy_attachment" "app_team_group_policy_attachment" {
  for_each = var.teams

  group      = aws_iam_group.app_team_group[each.key].name
  policy_arn = aws_iam_policy.app_team_policy[each.key].arn
}

# IAM User Creation with Console Access for each user email in each team
resource "aws_iam_user" "app_team_user" {
  for_each = { for team_name, team_data in var.teams : team_name => team_data.emails }

  name = "${each.key}-${each.value}-user"

  # Set a login profile to enable console access
  login_profile {
    password_reset_required = true
  }
}

# Add each user to the team group
resource "aws_iam_user_group_membership" "app_team_membership" {
  for_each = { for team_name, team_data in var.teams : team_name => team_data.emails }

  user   = aws_iam_user.app_team_user[each.key].name
  groups = [aws_iam_group.app_team_group[each.key].name]
}

# SNS Topic to notify each user with console login instructions
resource "aws_sns_topic" "team_notification" {
  for_each = var.teams
  name     = "${each.key}-user-login-notifications"
}

# SNS Subscription for each user email in each team
resource "aws_sns_topic_subscription" "email_subscription" {
  for_each = { for team_name, team_data in var.teams : team_name => team_data.emails }

  topic_arn = aws_sns_topic.team_notification[each.key].arn
  protocol  = "email"
  endpoint  = each.value
}

# Set SNS topic policy to allow notifications for login instructions
resource "aws_sns_topic_policy" "team_notification_policy" {
  for_each = var.teams

  arn = aws_sns_topic.team_notification[each.key].arn
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = "SNS:Publish",
        Resource  = aws_sns_topic.team_notification[each.key].arn
      }
    ]
  })
}
