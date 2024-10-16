Explanation of Key Parts
VPC and Subnet Setup: Creates a VPC and subnet for each team with appropriate tags (Team and Environment) that align with the IAM policies.

IAM Roles, Policies, and Groups: Sets up roles and groups for each team with access control based on resource tags. It restricts actions to resources with matching Team and Environment tags, preventing unauthorized cross-team access.

Deny-All Policy: Enforces the "Deny" clause, ensuring that any resource without the correct tags cannot be accessed or modified by the team.

IAM Users and Console Login: Creates users for each team member with login profiles, setting password_reset_required = true to prompt users to set a new password at their first login.

SNS Notifications:

aws_sns_topic: Creates an SNS topic for each team for notifications.
aws_sns_topic_subscription: Subscribes each user email to the team’s SNS topic.
aws_sns_topic_policy: Adds a publish policy to each topic, allowing AWS to send login instructions.
This setup allows each team member to receive login notifications directly from AWS upon the creation of their user, making it easy to onboard new users without needing an external setup script.