output "vpc_ids" {
  description = "VPC IDs for each team"
  value       = { for team, vpc in aws_vpc.team_vpc : team => vpc.id }
}

output "subnet_ids" {
  description = "Subnet IDs for each team"
  value       = { for team, subnet in aws_subnet.team_subnet : team => subnet.id }
}

output "iam_role_arns" {
  description = "IAM Role ARNs for each team"
  value       = { for team, role in aws_iam_role.app_team_role : team => role.arn }
}

output "iam_user_names" {
  description = "IAM User names for each team member"
  value       = { for team, user in aws_iam_user.app_team_user : team => user.name }
}

output "sns_topic_arns" {
  description = "SNS Topic ARNs for each team"
  value       = { for team, topic in aws_sns_topic.team_notification : team => topic.arn }
}
