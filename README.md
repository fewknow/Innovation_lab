
Explanation of Key Usage
Variables Passed to Module:

region: Specifies the AWS region.
vpc_cidr: Defines the VPC CIDR range.
teams: A map of team configurations, where each team has its own subnet_index and list of emails.
Outputs After Deployment:

VPC and Subnet IDs: Lists the VPC and subnet IDs for each team, useful for tracking networking resources.
IAM Role ARNs and Usernames: Provides each team’s IAM role and user details, helping administrators manage access.
SNS Topic ARNs: Returns the SNS topic ARNs used for login notifications, helpful for auditing and verifying notifications.
